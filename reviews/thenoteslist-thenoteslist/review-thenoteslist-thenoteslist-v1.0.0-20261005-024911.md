# Review: companion-module-thenoteslist-thenoteslist v1.0.0

| | |
| --- | --- |
| **Module** | `companion-module-thenoteslist-thenoteslist` ([repo](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist)) |
| **Version** | v1.0.0 (`6499fdc`) |
| **Previous tag** | none (first release, so the whole module was reviewed) |
| **Scope:** | tag |
| **Language** | TypeScript |
| **Template** | [API 1 TypeScript template](https://github.com/bitfocus/companion-module-template-ts/tree/42609d8dab515a25ec2f3b3c7adafe57aa41b7be) (`companion-module-template-ts` @ `42609d8`, 2026-03-03, the last API 1 commit) · `.yarnrc.yml` from [`main`](https://github.com/bitfocus/companion-module-template-ts/blob/4373e07847fafb537db6fcef3178715c839504d6/.yarnrc.yml) @ `4373e07` (2026-10-08) |
| **API** | 1 (base 1.14.1, package-lock.json; no committed yarn.lock) |
| **Build** | `yarn package` fails (C5); `yarn lint` does not finish (H2) |
| **Transports** | HTTP (global `fetch`, polling the cloud API) · OSC over TCP to an ETC Eos desk (`osc` 2.4.5, read-only) |
| **Review date** | 2026-10-08 |

This is the module's first release, so there is no previous tag to diff against. Every finding below is classified as new.

**About the template:** the official TypeScript template repository has moved to the module API 2.1 (Companion 5). This module uses API 1, so every template finding below links to the API 1 version of the template, at commit [`42609d8`](https://github.com/bitfocus/companion-module-template-ts/tree/42609d8dab515a25ec2f3b3c7adafe57aa41b7be). Earlier versions of the template are no longer maintained, but that commit preserves the API 1 files.

## Verdict: ❌ Changes Required

## 📋 Issues

### Blocking

- [ ] [C1: The module is installed with npm instead of yarn](#c1-the-module-is-installed-with-npm-instead-of-yarn)
- [ ] [C2: No yarn.lock is committed](#c2-no-yarnlock-is-committed)
- [ ] [C3: .yarnrc.yml is missing](#c3-yarnrcyml-is-missing)
- [ ] [C4: package.json is missing the packageManager field](#c4-packagejson-is-missing-the-packagemanager-field)
- [ ] [C5: The module cannot be packaged from a clean checkout](#c5-the-module-cannot-be-packaged-from-a-clean-checkout)
- [ ] [C6: Required package.json scripts are missing](#c6-required-packagejson-scripts-are-missing)
- [ ] [C7: Required devDependencies are missing](#c7-required-devdependencies-are-missing)
- [ ] [C8: Pre-commit tooling is missing (.husky/pre-commit and lint-staged)](#c8-pre-commit-tooling-is-missing-huskypre-commit-and-lint-staged)
- [ ] [C9: Required template files are missing (.gitattributes, .prettierignore, tsconfig.build.json)](#c9-required-template-files-are-missing-gitattributes-prettierignore-tsconfigbuildjson)
- [ ] [C10: .gitignore is missing template entries](#c10-gitignore-is-missing-template-entries)
- [ ] [C11: eslint.config.mjs differs from the template and switches a rule off for all code](#c11-eslintconfigmjs-differs-from-the-template-and-switches-a-rule-off-for-all-code)
- [ ] [C12: The manifest asks for Node 18 instead of Node 22](#c12-the-manifest-asks-for-node-18-instead-of-node-22)
- [ ] [C13: Actions, feedbacks, presets, variables and upgrade scripts are not in their own files](#c13-actions-feedbacks-presets-variables-and-upgrade-scripts-are-not-in-their-own-files)
- [ ] [H1: LICENSE copyright line differs from the template](#h1-license-copyright-line-differs-from-the-template)
- [ ] [H2: Lint never finishes, so the code could not be lint-checked](#h2-lint-never-finishes-so-the-code-could-not-be-lint-checked)
- [ ] [H3: GitHub issue templates and workflows are missing](#h3-github-issue-templates-and-workflows-are-missing)

### Non-blocking

- [ ] [M1: Keep cursor offset leaves the selected cue behind when the show moves on](#m1-keep-cursor-offset-leaves-the-selected-cue-behind-when-the-show-moves-on)
- [ ] [M2: The Eos connected button colour shows the wrong state](#m2-the-eos-connected-button-colour-shows-the-wrong-state)
- [ ] [M3: Saving settings during a slow request can double the polling or leave it running after removal](#m3-saving-settings-during-a-slow-request-can-double-the-polling-or-leave-it-running-after-removal)
- [ ] [M4: A slow or hung server can stall startup and break pairing](#m4-a-slow-or-hung-server-can-stall-startup-and-break-pairing)
- [ ] [M5: The station token is saved in plain text and included in exports](#m5-the-station-token-is-saved-in-plain-text-and-included-in-exports)
- [ ] [M6: Changing the Eos desk or cue list keeps the old selected cue, and every save reconnects to the desk](#m6-changing-the-eos-desk-or-cue-list-keeps-the-old-selected-cue-and-every-save-reconnects-to-the-desk)
- [ ] [M7: A replaced Eos connection can mark the new one as disconnected](#m7-a-replaced-eos-connection-can-mark-the-new-one-as-disconnected)
- [ ] [M8: The osc library is CommonJS only; moving to node-osc saves upgrade work later](#m8-the-osc-library-is-commonjs-only-moving-to-node-osc-saves-upgrade-work-later)
- [ ] [L1: Saving an old settings window after pairing can throw away the new pairing](#l1-saving-an-old-settings-window-after-pairing-can-throw-away-the-new-pairing)
- [ ] [L2: A network outage can show the connection as OK for up to a minute](#l2-a-network-outage-can-show-the-connection-as-ok-for-up-to-a-minute)
- [ ] [L3: A revoked station keeps calling the server every 5 seconds](#l3-a-revoked-station-keeps-calling-the-server-every-5-seconds)
- [ ] [L4: A malformed expiry from the server makes a pairing code never expire](#l4-a-malformed-expiry-from-the-server-makes-a-pairing-code-never-expire)
- [ ] [L5: A wrong Eos desk IP leaves nothing in the log](#l5-a-wrong-eos-desk-ip-leaves-nothing-in-the-log)
- [ ] [L6: Reconnects to an unreachable Eos desk have no backoff or connect timeout](#l6-reconnects-to-an-unreachable-eos-desk-have-no-backoff-or-connect-timeout)
- [ ] [L7: The Eos reader keeps sending cue requests after the desk disconnects](#l7-the-eos-reader-keeps-sending-cue-requests-after-the-desk-disconnects)
- [ ] [L8: After an Eos reconnect, unanswered cues are never retried](#l8-after-an-eos-reconnect-unanswered-cues-are-never-retried)
- [ ] [L9: A bogus cue count from the desk is trusted without limits](#l9-a-bogus-cue-count-from-the-desk-is-trusted-without-limits)
- [ ] [L10: Cue edits on the desk may refresh the wrong cues](#l10-cue-edits-on-the-desk-may-refresh-the-wrong-cues)
- [ ] [L11: Option visibility uses the deprecated isVisible function](#l11-option-visibility-uses-the-deprecated-isvisible-function)
- [ ] [N1: A mistyped Base URL gives an unhelpful connection error](#n1-a-mistyped-base-url-gives-an-unhelpful-connection-error)
- [ ] [N2: The cue list is copied and sorted on every lookup](#n2-the-cue-list-is-copied-and-sorted-on-every-lookup)
- [ ] [N3: Station and production names are inserted into the settings banner as raw HTML](#n3-station-and-production-names-are-inserted-into-the-settings-banner-as-raw-html)
- [ ] [N4: Several actions have no description in the action picker](#n4-several-actions-have-no-description-in-the-action-picker)
- [ ] [N5: The Pairing code box looks editable but ignores what you type](#n5-the-pairing-code-box-looks-editable-but-ignores-what-you-type)
- [ ] [N6: Stepping to the next cue can go past the end of the list while it is still loading](#n6-stepping-to-the-next-cue-can-go-past-the-end-of-the-list-while-it-is-still-loading)

---

## 🔴 Critical

### C1: The module is installed with npm instead of yarn

- **Source:** 🤖 validate-template (NPM-LOCK, GITIGNORED-COMMITTED)
- **Classification:** 🆕 NEW
- **File:** [`package-lock.json`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/package-lock.json)
- **Template:** [API 1 TypeScript template](https://github.com/bitfocus/companion-module-template-ts/tree/42609d8dab515a25ec2f3b3c7adafe57aa41b7be): [`.gitignore`](https://github.com/bitfocus/companion-module-template-ts/blob/42609d8dab515a25ec2f3b3c7adafe57aa41b7be/.gitignore), [`package.json`](https://github.com/bitfocus/companion-module-template-ts/blob/42609d8dab515a25ec2f3b3c7adafe57aa41b7be/package.json)

**What goes wrong:** No user-visible effect. The repository commits an npm lockfile (`package-lock.json`). Companion modules must be installed and built with yarn, so a committed npm lockfile is an automatic rejection.

**Why it happens:** The template's `.gitignore` excludes `package-lock.json`, but this module's `.gitignore` doesn't (see C10), so the file got committed.

**Fix:** stop tracking the npm lockfile and install with yarn 4 instead (C2 to C4).

```bash
git rm --cached package-lock.json
```

### C2: No yarn.lock is committed

- **Source:** 🤖 validate-template (NPM-LOCK); `git ls-files` at v1.0.0 lists no `yarn.lock`
- **Classification:** 🆕 NEW
- **File:** `yarn.lock` (missing)
- **Template:** [API 1 TypeScript template](https://github.com/bitfocus/companion-module-template-ts/tree/42609d8dab515a25ec2f3b3c7adafe57aa41b7be): [`package.json`](https://github.com/bitfocus/companion-module-template-ts/blob/42609d8dab515a25ec2f3b3c7adafe57aa41b7be/package.json) (yarn 4 via `packageManager`)

**What goes wrong:** No user-visible effect, but the build isn't reproducible: anyone building the module can get different dependency versions.

**Why it happens:** No `yarn.lock` is tracked in git. The review's `yarn install --immutable` only passed against a lockfile the review setup generated locally with yarn classic 1.22.22. Every module must commit its `yarn.lock`.

**Fix:** after adding `.yarnrc.yml` and `packageManager` (C3, C4), run `yarn install` with yarn 4 and commit the `yarn.lock` it writes.

### C3: .yarnrc.yml is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.yarnrc.yml` (missing)
- **Template:** [`.yarnrc.yml` on `main`](https://github.com/bitfocus/companion-module-template-ts/blob/4373e07847fafb537db6fcef3178715c839504d6/.yarnrc.yml) (Bitfocus keeps this file current only on `main`, so it applies to every API version)

**What goes wrong:** No user-visible effect. Installs don't get the template's yarn settings or its supply-chain protections.

**Why it happens:** The template ships a `.yarnrc.yml` with `nodeLinker: node-modules`, `enableScripts: false`, `npmMinimalAgeGate: 3d` and `npmPreapprovedPackages`. The module has none.

**Fix:** copy [`.yarnrc.yml`](https://github.com/bitfocus/companion-module-template-ts/blob/4373e07847fafb537db6fcef3178715c839504d6/.yarnrc.yml) from the TS template's `main` branch. Bitfocus keeps this file current only on `main`, so it applies to API 1 modules too.

### C4: package.json is missing the packageManager field

- **Source:** 🤖 validate-template (PKG-FIELD)
- **Classification:** 🆕 NEW
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/package.json)
- **Template:** [API 1 TypeScript template](https://github.com/bitfocus/companion-module-template-ts/tree/42609d8dab515a25ec2f3b3c7adafe57aa41b7be): [`package.json`](https://github.com/bitfocus/companion-module-template-ts/blob/42609d8dab515a25ec2f3b3c7adafe57aa41b7be/package.json)

**What goes wrong:** No user-visible effect. Without the field, corepack doesn't pick yarn 4, so the build isn't reproducible.

**Why it happens:** The template pins yarn 4 with a `"packageManager"` entry in `package.json`; this module has no such entry.

**Fix:** add the [template's](https://github.com/bitfocus/companion-module-template-ts/blob/42609d8dab515a25ec2f3b3c7adafe57aa41b7be/package.json) `"packageManager": "yarn@4.x.x"` line to `package.json`.

### C5: The module cannot be packaged from a clean checkout

- **Source:** 🤖 validate-template (BUILD-PACKAGE)
- **Classification:** 🆕 NEW
- **File:** [`package.json:12-18`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/package.json#L12-L18)
- **Template:** [API 1 TypeScript template](https://github.com/bitfocus/companion-module-template-ts/tree/42609d8dab515a25ec2f3b3c7adafe57aa41b7be): [`package.json`](https://github.com/bitfocus/companion-module-template-ts/blob/42609d8dab515a25ec2f3b3c7adafe57aa41b7be/package.json)

**What goes wrong:** `yarn package` fails with webpack's `Module not found: Error: Can't resolve './dist/main.js'`, so the module can't be built into an installable package from a fresh clone.

**Why it happens:** The `package` script is plain `companion-module-build`, which bundles the compiled `dist/` folder. On a clean checkout `dist/` doesn't exist yet, and nothing builds it first. The template's `package` script runs the build before bundling.

**Fix:** use the [template's scripts](https://github.com/bitfocus/companion-module-template-ts/blob/42609d8dab515a25ec2f3b3c7adafe57aa41b7be/package.json), which build before packaging.

```json
"package": "run build && companion-module-build",
"build": "rimraf dist && run build:main",
"build:main": "tsc -p tsconfig.build.json",
```

### C6: Required package.json scripts are missing

- **Source:** 🤖 validate-template (PKG-SCRIPT)
- **Classification:** 🆕 NEW
- **File:** [`package.json:12-18`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/package.json#L12-L18)
- **Template:** [API 1 TypeScript template](https://github.com/bitfocus/companion-module-template-ts/tree/42609d8dab515a25ec2f3b3c7adafe57aa41b7be): [`package.json`](https://github.com/bitfocus/companion-module-template-ts/blob/42609d8dab515a25ec2f3b3c7adafe57aa41b7be/package.json)

**What goes wrong:** No user-visible effect. The template's build, lint and install hooks aren't there.

**Why it happens:** The template scripts `postinstall`, `build:main` and `lint:raw` are missing. `lint` is `eslint src` rather than the template form, and `build` calls `tsc -p tsconfig.json` directly.

**Fix:** replace the `scripts` block with the [template's](https://github.com/bitfocus/companion-module-template-ts/blob/42609d8dab515a25ec2f3b3c7adafe57aa41b7be/package.json).

### C7: Required devDependencies are missing

- **Source:** 🤖 validate-template (PKG-DEVDEP)
- **Classification:** 🆕 NEW
- **File:** [`package.json:23-28`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/package.json#L23-L28)
- **Template:** [API 1 TypeScript template](https://github.com/bitfocus/companion-module-template-ts/tree/42609d8dab515a25ec2f3b3c7adafe57aa41b7be): [`package.json`](https://github.com/bitfocus/companion-module-template-ts/blob/42609d8dab515a25ec2f3b3c7adafe57aa41b7be/package.json)

**What goes wrong:** No user-visible effect, but the module's own `format` script calls `prettier`, which isn't installed, and the template's `build` script needs `rimraf`.

**Why it happens:** These template devDependencies are missing: `@types/node`, `husky`, `lint-staged`, `prettier`, `rimraf`.

**Fix:** add them at the [template's](https://github.com/bitfocus/companion-module-template-ts/blob/42609d8dab515a25ec2f3b3c7adafe57aa41b7be/package.json) versions.

### C8: Pre-commit tooling is missing (.husky/pre-commit and lint-staged)

- **Source:** 🤖 validate-template (FILE-MISSING, PKG-LINTSTAGED)
- **Classification:** 🆕 NEW
- **File:** `.husky/pre-commit` (missing), [`package.json`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/package.json) (no `lint-staged` section)
- **Template:** [API 1 TypeScript template](https://github.com/bitfocus/companion-module-template-ts/tree/42609d8dab515a25ec2f3b3c7adafe57aa41b7be): [`.husky/pre-commit`](https://github.com/bitfocus/companion-module-template-ts/blob/42609d8dab515a25ec2f3b3c7adafe57aa41b7be/.husky/pre-commit), [`package.json`](https://github.com/bitfocus/companion-module-template-ts/blob/42609d8dab515a25ec2f3b3c7adafe57aa41b7be/package.json)

**What goes wrong:** No user-visible effect. Nothing formats or lints files before they're committed.

**Why it happens:** The template's pre-commit hook and the `lint-staged` section of `package.json` are both absent.

**Fix:** copy [`.husky/pre-commit`](https://github.com/bitfocus/companion-module-template-ts/blob/42609d8dab515a25ec2f3b3c7adafe57aa41b7be/.husky/pre-commit) and the `lint-staged` section of the [template's `package.json`](https://github.com/bitfocus/companion-module-template-ts/blob/42609d8dab515a25ec2f3b3c7adafe57aa41b7be/package.json), together with the `postinstall` script from C6.

### C9: Required template files are missing (.gitattributes, .prettierignore, tsconfig.build.json)

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.gitattributes`, `.prettierignore`, `tsconfig.build.json` (all missing)
- **Template:** [API 1 TypeScript template](https://github.com/bitfocus/companion-module-template-ts/tree/42609d8dab515a25ec2f3b3c7adafe57aa41b7be): [`.gitattributes`](https://github.com/bitfocus/companion-module-template-ts/blob/42609d8dab515a25ec2f3b3c7adafe57aa41b7be/.gitattributes), [`.prettierignore`](https://github.com/bitfocus/companion-module-template-ts/blob/42609d8dab515a25ec2f3b3c7adafe57aa41b7be/.prettierignore), [`tsconfig.build.json`](https://github.com/bitfocus/companion-module-template-ts/blob/42609d8dab515a25ec2f3b3c7adafe57aa41b7be/tsconfig.build.json)

**What goes wrong:** No user-visible effect. The template tracks all three files; `tsconfig.build.json` is the build configuration that the template's `build:main` script compiles with.

**Fix:** copy the three files from the template: [`.gitattributes`](https://github.com/bitfocus/companion-module-template-ts/blob/42609d8dab515a25ec2f3b3c7adafe57aa41b7be/.gitattributes), [`.prettierignore`](https://github.com/bitfocus/companion-module-template-ts/blob/42609d8dab515a25ec2f3b3c7adafe57aa41b7be/.prettierignore) and [`tsconfig.build.json`](https://github.com/bitfocus/companion-module-template-ts/blob/42609d8dab515a25ec2f3b3c7adafe57aa41b7be/tsconfig.build.json).

### C10: .gitignore is missing template entries

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.gitignore:1-5`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/.gitignore#L1-L5)
- **Template:** [API 1 TypeScript template](https://github.com/bitfocus/companion-module-template-ts/tree/42609d8dab515a25ec2f3b3c7adafe57aa41b7be): [`.gitignore`](https://github.com/bitfocus/companion-module-template-ts/blob/42609d8dab515a25ec2f3b3c7adafe57aa41b7be/.gitignore)

**What goes wrong:** No user-visible effect. Files that should never be committed can be, which is how `package-lock.json` got in (C1).

**Why it happens:** The template entries `node_modules/`, `package-lock.json`, `/dist`, `/.yarn` and `/.vscode` are missing.

**Fix:** replace `.gitignore` with the [template's version](https://github.com/bitfocus/companion-module-template-ts/blob/42609d8dab515a25ec2f3b3c7adafe57aa41b7be/.gitignore).

### C11: eslint.config.mjs differs from the template and switches a rule off for all code

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`eslint.config.mjs:3`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/eslint.config.mjs#L3), [`eslint.config.mjs:9-12`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/eslint.config.mjs#L9-L12)
- **Template:** [API 1 TypeScript template](https://github.com/bitfocus/companion-module-template-ts/tree/42609d8dab515a25ec2f3b3c7adafe57aa41b7be): [`eslint.config.mjs`](https://github.com/bitfocus/companion-module-template-ts/blob/42609d8dab515a25ec2f3b3c7adafe57aa41b7be/eslint.config.mjs)

**What goes wrong:** No user-visible effect. The lint rule that requires explicit return types on exported functions is turned off for the whole of `src/`, not just the file that needed it.

**Why it happens:** Line 3 has `const config = await generateEslintConfig({` where the template has `export default generateEslintConfig({`. The override appended at lines 9-12 sets `'@typescript-eslint/explicit-module-boundary-types': 'off'` with no `files:` entry to limit where it applies.

**Fix:** use the [template's `eslint.config.mjs`](https://github.com/bitfocus/companion-module-template-ts/blob/42609d8dab515a25ec2f3b3c7adafe57aa41b7be/eslint.config.mjs). If the return types in `src/api.ts` should stay inferred, add explicit types there or a targeted disable comment instead of a global override.

### C12: The manifest asks for Node 18 instead of Node 22

- **Source:** 🤖 validate-template (MAN-RUNTIME)
- **Classification:** 🆕 NEW
- **File:** [`companion/manifest.json:20`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/companion/manifest.json#L20)
- **Template:** [API 1 TypeScript template](https://github.com/bitfocus/companion-module-template-ts/tree/42609d8dab515a25ec2f3b3c7adafe57aa41b7be): [`companion/manifest.json`](https://github.com/bitfocus/companion-module-template-ts/blob/42609d8dab515a25ec2f3b3c7adafe57aa41b7be/companion/manifest.json), [`package.json`](https://github.com/bitfocus/companion-module-template-ts/blob/42609d8dab515a25ec2f3b3c7adafe57aa41b7be/package.json)

**What goes wrong:** Companion starts the module on its Node 18 runtime rather than the Node 22 runtime the template targets. On Node 18 the global `fetch` the module relies on ([`src/api.ts:34-36`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/src/api.ts#L34-L36)) is still marked experimental.

**Why it happens:** `runtime.type` in the manifest is `"node18"`; it should be `"node22"`.

**Fix:** set `"type": "node22"` in the manifest, and change `engines.node` in `package.json` to match the [template](https://github.com/bitfocus/companion-module-template-ts/blob/42609d8dab515a25ec2f3b3c7adafe57aa41b7be/package.json).

### C13: Actions, feedbacks, presets, variables and upgrade scripts are not in their own files

- **Source:** 🧑 review maintainer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:358-618`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/src/main.ts#L358-L618), [`src/main.ts:630`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/src/main.ts#L630), [`src/main.ts:829`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/src/main.ts#L829)
- **Template:** [API 1 TypeScript template](https://github.com/bitfocus/companion-module-template-ts/tree/42609d8dab515a25ec2f3b3c7adafe57aa41b7be): [`src/`](https://github.com/bitfocus/companion-module-template-ts/tree/42609d8dab515a25ec2f3b3c7adafe57aa41b7be/src)

**What goes wrong:** No user-visible effect. The module's whole Companion interface is defined inside one 829-line `src/main.ts`, so it doesn't follow the layout every module built from the template shares. That makes it hard for other maintainers to find their way around, to review changes, and to add upgrade scripts when an action or option is renamed later.

**Why it happens:** `defineEntities()` builds every action, feedback and variable inline and registers them together, `buildPresets()` sits in the same class, and the upgrade scripts are an inline empty list passed to `runEntrypoint`. The config fields are already in their own file, `src/config.ts`, as the template has them.

**Evidence:**

```ts
// src/main.ts:614-617 (end of defineEntities(), which starts at :358)
		this.setActionDefinitions(actions)
		this.setFeedbackDefinitions(feedbacks)
		this.setVariableDefinitions(variables)
		this.setPresetDefinitions(this.buildPresets())
```

```ts
// src/main.ts:829
runEntrypoint(NotesListInstance, [])
```

**Confirm by:** open [`src/main.ts`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/src/main.ts) and compare its `src/` folder with the template's [`src/`](https://github.com/bitfocus/companion-module-template-ts/tree/42609d8dab515a25ec2f3b3c7adafe57aa41b7be/src).

**Fix:** split the definitions into the template's files. This module is on API 1, so follow the [API 1 TypeScript template](https://github.com/bitfocus/companion-module-template-ts/tree/42609d8dab515a25ec2f3b3c7adafe57aa41b7be):

| File | Holds | Template file |
| --- | --- | --- |
| `src/config.ts` | the config fields (already done) | [`src/config.ts`](https://github.com/bitfocus/companion-module-template-ts/blob/42609d8dab515a25ec2f3b3c7adafe57aa41b7be/src/config.ts) |
| `src/actions.ts` | `UpdateActions(self)` with every action | [`src/actions.ts`](https://github.com/bitfocus/companion-module-template-ts/blob/42609d8dab515a25ec2f3b3c7adafe57aa41b7be/src/actions.ts) |
| `src/feedbacks.ts` | `UpdateFeedbacks(self)` with every feedback | [`src/feedbacks.ts`](https://github.com/bitfocus/companion-module-template-ts/blob/42609d8dab515a25ec2f3b3c7adafe57aa41b7be/src/feedbacks.ts) |
| `src/presets.ts` | `UpdatePresets(self)`, the current `buildPresets()` | [`src/presets.ts`](https://github.com/bitfocus/companion-module-template-ts/blob/42609d8dab515a25ec2f3b3c7adafe57aa41b7be/src/presets.ts) |
| `src/variables.ts` | `UpdateVariableDefinitions(self)` | [`src/variables.ts`](https://github.com/bitfocus/companion-module-template-ts/blob/42609d8dab515a25ec2f3b3c7adafe57aa41b7be/src/variables.ts) |
| `src/upgrades.ts` | `export const UpgradeScripts: CompanionStaticUpgradeScript<ModuleConfig>[] = []`, passed to `runEntrypoint` | [`src/upgrades.ts`](https://github.com/bitfocus/companion-module-template-ts/blob/42609d8dab515a25ec2f3b3c7adafe57aa41b7be/src/upgrades.ts) |

`src/main.ts` then keeps the instance class (connection, polling and Eos handling) and calls these functions, as the template's [`src/main.ts`](https://github.com/bitfocus/companion-module-template-ts/blob/42609d8dab515a25ec2f3b3c7adafe57aa41b7be/src/main.ts) does.

---

## 🟠 High

### H1: LICENSE copyright line differs from the template

- **Source:** 🤖 validate-template (LICENSE-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`LICENSE:3`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/LICENSE#L3)
- **Template:** [API 1 TypeScript template](https://github.com/bitfocus/companion-module-template-ts/tree/42609d8dab515a25ec2f3b3c7adafe57aa41b7be): [`LICENSE`](https://github.com/bitfocus/companion-module-template-ts/blob/42609d8dab515a25ec2f3b3c7adafe57aa41b7be/LICENSE)

**What goes wrong:** No user-visible effect. The copyright line reads `Copyright (c) 2026 The Notes List LLC`; the template has `Copyright (c) 2022 Bitfocus AS - Open Source`. The rest of the MIT text matches.

**Fix:** use the [template's `LICENSE`](https://github.com/bitfocus/companion-module-template-ts/blob/42609d8dab515a25ec2f3b3c7adafe57aa41b7be/LICENSE).

### H2: Lint never finishes, so the code could not be lint-checked

- **Source:** 🤖 validate-template (LINT)
- **Classification:** 🆕 NEW
- **File:** [`package.json:15`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/package.json#L15), [`eslint.config.mjs`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/eslint.config.mjs)
- **Template:** [API 1 TypeScript template](https://github.com/bitfocus/companion-module-template-ts/tree/42609d8dab515a25ec2f3b3c7adafe57aa41b7be): [`eslint.config.mjs`](https://github.com/bitfocus/companion-module-template-ts/blob/42609d8dab515a25ec2f3b3c7adafe57aa41b7be/eslint.config.mjs), [`package.json`](https://github.com/bitfocus/companion-module-template-ts/blob/42609d8dab515a25ec2f3b3c7adafe57aa41b7be/package.json), [`tsconfig.json`](https://github.com/bitfocus/companion-module-template-ts/blob/42609d8dab515a25ec2f3b3c7adafe57aa41b7be/tsconfig.json)

**What goes wrong:** No user-visible effect, but this release's code could not be lint-checked. `yarn lint` (`eslint src`) went idle at 0% CPU after parsing its first file, `src/api.ts`, and was killed after about 14 minutes. A separate manual run also hung and was stopped after 180 s. No specific lint errors are claimed; the problem is that lint never completes.

**Fix:** once the template configuration is in place (C6, C9, C11), run `yarn lint` locally and make sure it finishes cleanly before resubmitting.

### H3: GitHub issue templates and workflows are missing

- **Source:** 🤖 validate-template (FILE-MISSING; raised to High by the review maintainer)
- **Classification:** 🆕 NEW
- **File:** `.github/` (missing)
- **Template:** [API 1 TypeScript template](https://github.com/bitfocus/companion-module-template-ts/tree/42609d8dab515a25ec2f3b3c7adafe57aa41b7be): [`.github/`](https://github.com/bitfocus/companion-module-template-ts/tree/42609d8dab515a25ec2f3b3c7adafe57aa41b7be/.github)

**What goes wrong:** No user-visible effect. Users get no bug-report or feature-request forms, and pushes get no module checks.

**Evidence:** the repository has no `.github/` folder at v1.0.0, while the template tracks these files:

| Missing file | Template file |
| --- | --- |
| `.github/ISSUE_TEMPLATE/bug_report.yml` | [`bug_report.yml`](https://github.com/bitfocus/companion-module-template-ts/blob/42609d8dab515a25ec2f3b3c7adafe57aa41b7be/.github/ISSUE_TEMPLATE/bug_report.yml) |
| `.github/ISSUE_TEMPLATE/config.yml` | [`config.yml`](https://github.com/bitfocus/companion-module-template-ts/blob/42609d8dab515a25ec2f3b3c7adafe57aa41b7be/.github/ISSUE_TEMPLATE/config.yml) |
| `.github/ISSUE_TEMPLATE/feature_request.yml` | [`feature_request.yml`](https://github.com/bitfocus/companion-module-template-ts/blob/42609d8dab515a25ec2f3b3c7adafe57aa41b7be/.github/ISSUE_TEMPLATE/feature_request.yml) |
| `.github/workflows/companion-module-checks.yaml` | [`companion-module-checks.yaml`](https://github.com/bitfocus/companion-module-template-ts/blob/42609d8dab515a25ec2f3b3c7adafe57aa41b7be/.github/workflows/companion-module-checks.yaml) |
| `.github/workflows/node.yaml` | [`node.yaml`](https://github.com/bitfocus/companion-module-template-ts/blob/42609d8dab515a25ec2f3b3c7adafe57aa41b7be/.github/workflows/node.yaml) |

**Confirm by:** open the [repository at v1.0.0](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/tree/6499fdc69fb153c123b51f40e1bd02d368c13fa6): there is no `.github` folder.

**Fix:** copy the whole [`.github/` folder from the API 1 TypeScript template](https://github.com/bitfocus/companion-module-template-ts/tree/42609d8dab515a25ec2f3b3c7adafe57aa41b7be/.github) into the repository. You may uncomment `upload-artifact: true` in `companion-module-checks.yaml` if you want CI to upload the built package; otherwise keep the files as they are.

---

## 🟡 Medium

### M1: Keep cursor offset leaves the selected cue behind when the show moves on

- **Source:** 🔎 QA reviewer — verified (downgraded from High)
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:218-231`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/src/main.ts#L218-L231), [`src/main.ts:243-258`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/src/main.ts#L243-L258)

**What goes wrong:** An operator ticks **Keep cursor offset when the desk fires the next cue**, then presses **Selected cue ▶** twice, so the selected cue sits two places ahead of the live cue (live 10, selected 12, in a list without cue parts). When the desk fires cue 11, the selection should move to 13 to stay two ahead. It stays on 12 instead, and after cue 12 fires it is level with live. If the desk fires a cue the module hasn't loaded yet, the selection snaps back to following live. A **New note** pressed with the default cue number then lands on that cue, not on live plus two. The option is off by default, so operators who never tick it aren't affected, and the `selected_cue` and `selected_cue_offset` variables do show where the selection really is.

**Why it happens:** When the desk reports a new live cue, the module records the new live cue first and only then measures how far the selection is from live. So it measures the distance from the *new* live cue, and adding that distance back to the new live cue gives exactly the position the selection already had. The distance has to be measured before the live cue is updated.

**Evidence:**

```ts
// src/main.ts:218-231
			onLive: (num) => {
				const changed = num !== this.liveCue
				this.liveCue = num
				if (changed) {
					const c = this.cues.find((x) => x.number === num && x.part === 0)
					this.log('info', `Live cue ${num}${c?.label ? ` ${c.label}` : ''}`)
					if (this.config.eosKeepOffset && this.cursorIndex !== null) {
						const offset = this.cursorOffset()
						const liveIdx = this.cues.find((c) => c.number === num && c.part === 0)?.index
						this.cursorIndex = liveIdx !== undefined ? Math.max(0, liveIdx + offset) : null
					} else {
						this.cursorIndex = null // follow live
					}
				}
```

```ts
// src/main.ts:243-258
	private liveIndex(): number | null {
		if (this.liveCue === null) return null
		const c = this.cues.find((x) => x.number === this.liveCue && x.part === 0)
		return c ? c.index : null
	}

	/** Sheet index the cursor points at: stepped, else live. */
	private cursorPos(): number | null {
		return this.cursorIndex !== null ? this.cursorIndex : this.liveIndex()
	}

	private cursorOffset(): number {
		const pos = this.cursorPos()
		const live = this.liveIndex()
		return pos === null || live === null ? 0 : pos - live
	}
```

```ts
// src/main.ts:394
					if (!cueNumber || cueNumber === '$NA') cueNumber = this.cursorCue()?.number
```

**Confirm by:** open [`src/main.ts:220-227`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/src/main.ts#L220-L227). `this.liveCue = num` runs before `this.cursorOffset()`, so `liveIndex()` already returns the new live index L'. That makes `offset = cursorIndex - L'`, and line 227 sets `cursorIndex = L' + (cursorIndex - L')`, which is unchanged. If the new live cue isn't cached, the offset is 0 and `liveIdx` is undefined, so the cursor resets to null and follows live.

**Fix:** measure the offset before recording the new live cue.

```ts
onLive: (num) => {
	const changed = num !== this.liveCue
	const offset = this.cursorOffset() // measured against the previous live cue
	this.liveCue = num
	if (changed) {
		// ...
		if (this.config.eosKeepOffset && this.cursorIndex !== null) {
			const liveIdx = this.cues.find((c) => c.number === num && c.part === 0)?.index
			this.cursorIndex = liveIdx !== undefined ? Math.max(0, liveIdx + offset) : null
		}
		// ...
```

### M2: The Eos connected button colour shows the wrong state

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:581-587`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/src/main.ts#L581-L587), [`src/main.ts:214-217`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/src/main.ts#L214-L217), [`src/main.ts:306`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/src/main.ts#L306)

**What goes wrong:** The **Eos desk connected (read-only reader)** feedback, used by the built-in **Selected cue = live** preset to turn the key green, doesn't follow the real connection. On first connect it stays off while the cue list loads, and after the desk disconnects it stays green. The `eos_connected` variable is correct; only the feedback is wrong.

**Why it happens:** The feedback doesn't look at the connection at all. It reports "connected" when the module has any cached cues or knows a live cue. On connect the reader clears its cache ([`src/eos.ts:133`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/src/eos.ts#L133)) and no live cue is known yet, so it reports false; the feedback is only re-checked on connect and disconnect, not while cues load. On disconnect the cache is still full, so it reports true.

**Fix:** store the connected flag that the reader reports (for example in `this.eosConnected`) and return that from the feedback.

### M3: Saving settings during a slow request can double the polling or leave it running after removal

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:91-120`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/src/main.ts#L91-L120), [`src/main.ts:123-146`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/src/main.ts#L123-L146), [`src/main.ts:158-186`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/src/main.ts#L158-L186), [`src/main.ts:75-79`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/src/main.ts#L75-L79)

**What goes wrong:** If the user saves the connection settings, or deletes or disables the connection, while a request to the server is still in progress:

- Two quick saves in a row leave two sets of polling timers running, so the module polls the server twice as often.
- Saving to start a new pairing leaves the old token's polling running; its rejected requests replace the "PAIR CODE ..." status with "Not paired" every 5 s.
- Deleting or disabling the connection during startup leaves polling timers running that keep calling the server and updating the status of a connection that no longer exists.

**Why it happens:** Saving the settings and removing the connection both cancel the module's timers first. But the polling timers are only created *after* waiting for a server reply (the first `/me` call, the pairing start, the pairing poll). A request that was already in flight when the timers were cancelled finishes afterwards and starts a fresh set of timers that nothing cancels. `destroy()` must stop every timer the module starts, and these slip past it.

**Fix:** keep a counter that `configUpdated()` and `destroy()` both increase. Read it at the start of each async path, and after every `await` return early if it has changed, before creating timers, calling `startPolling()` or updating the status.

### M4: A slow or hung server can stall startup and break pairing

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/api.ts:36`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/src/api.ts#L36), [`src/main.ts:106`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/src/main.ts#L106), [`src/main.ts:117-118`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/src/main.ts#L117-L118), [`src/main.ts:146`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/src/main.ts#L146), [`src/main.ts:158-196`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/src/main.ts#L158-L196), [`src/main.ts:339-355`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/src/main.ts#L339-L355)

**What goes wrong:**

- If the server stops answering, requests pile up and the connection can sit in startup for minutes, because startup waits for the first `/me` reply and a request has no time limit short of Node's 300 s header timeout.
- During pairing, if the server takes more than 3.5 s to answer, two pairing checks can run at once. Both can receive the token and start polling twice; or one receives the token and starts polling, then the other gets "code already used" back, cancels the new polling and sets the status to "Pairing ended", even though pairing succeeded.
- A slow server also gets overlapping `/counts` and `/me` calls.

**Why it happens:** `fetch` is called without a timeout, and polling uses fixed timers (counts every 5 s, pairing every 3.5 s) that start a new request whether or not the previous one has finished. A failed `/counts` call with 401/402/403/410 also fires an extra `/me` call.

**Fix:** give every request a timeout (`signal: AbortSignal.timeout(10000)`, combined with an `AbortController` that `destroy()` and `configUpdated()` abort). Don't start a pairing check or counts poll while the previous one is still running, or schedule the next one with `setTimeout` after each finishes. In `pollPairing`, ignore a result when `this.pairing` no longer matches the code that was polled.

### M5: The station token is saved in plain text and included in exports

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:172-181`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/src/main.ts#L172-L181), [`src/config.ts:6-7`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/src/config.ts#L6-L7)

**What goes wrong:** The token that lets a Companion station post to The Notes List is stored in clear text in the connection's settings and goes out with every connection or configuration export. Anyone given an export can act as that station.

**Why it happens:** After pairing, the module saves the token into the ordinary connection settings with `saveConfig`, and no settings field declares it. Companion only protects values held in a `secret-text` field. The comment on line 172 ("the config form shows it as a secret and never in full") is wrong: there is no such field.

**Fix:** raise `@companion-module/base` to `^1.13.0` (the version that adds `secret-text`) and declare `token` as a `secret-text` field, so Companion keeps it out of exports. If the token has to stay in plain settings, correct the comment and say in the help that exports contain the station token.

### M6: Changing the Eos desk or cue list keeps the old selected cue, and every save reconnects to the desk

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:96`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/src/main.ts#L96), [`src/main.ts:199-212`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/src/main.ts#L199-L212)

**What goes wrong:** After the user changes **Eos desk IP** or **Cue list**, a selection they had stepped to still points at the same position, now in a different list, so a **New note** can land on the wrong cue. If the new desk reports the same live cue number, the selection is never reset. Clearing the desk IP leaves `cue_live_label` showing the old cue's label. Separately, every save of the settings (including the automatic save after pairing) drops the desk connection and re-reads the whole cue list.

**Why it happens:** Starting a new Eos reader doesn't reset the live cue, the stepped position or the cue count, and the reset for an empty IP leaves `cue_live_label` out. The reader is restarted on every save, whether or not any Eos setting changed.

**Fix:** when starting the Eos reader, reset `liveCue`, `cursorIndex` and `cueCount` and clear every Eos variable, `cue_live_label` included. Only restart the reader when **Eos desk IP**, **Use TCP SLIP** or **Cue list** actually changed.

### M7: A replaced Eos connection can mark the new one as disconnected

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/eos.ts:80-92`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/src/eos.ts#L80-L92), [`src/eos.ts:151-157`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/src/eos.ts#L151-L157)

**What goes wrong:** After a settings save restarts the Eos reader (see M6), the `eos_connected` variable can flip to false even though the new connection is up. When the desk is unreachable, the old connection attempt also lingers until the operating system gives up on it.

**Why it happens:** Stopping the reader only half-closes its socket: osc.js's `close()` calls `socket.end()`, which says goodbye but doesn't destroy the socket. A socket still trying to reach the desk stays open until the OS connect timeout, and a connected one stays half-open until the desk closes its side. When the old socket finally closes, its close handler still reports "disconnected", which overwrites the new reader's status. Cleanup on stop must release the socket completely.

**Fix:** in `stop()`, destroy the underlying socket after `close()` (for example `(this.socket as any).socket?.destroy()`, or add a `destroy()` passthrough in `osc.d.ts`). In the `'close'` and `'error'` handlers, return early when `this.closed` is set, or remove the listeners in `stop()`.

### M8: The osc library is CommonJS only; moving to node-osc saves upgrade work later

- **Source:** 🧑 review maintainer
- **Classification:** 🆕 NEW
- **File:** [`package.json:21`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/package.json#L21), [`src/eos.ts:23-25`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/src/eos.ts#L23-L25), [`src/osc.d.ts`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/src/osc.d.ts)

**What goes wrong:** No user-visible effect today. The Eos connection uses the `osc` package (2.4.5), which is CommonJS only: it has no ES module build and no type definitions, so the module needs its own hand-written `src/osc.d.ts`. Future versions of Companion use ES modules, so this dependency is likely to need replacing at the next big upgrade anyway. Switching now saves that upgrade time later.

**Why it happens:** `osc` declares only a CommonJS `main` (`src/platforms/osc-node.js`), with no `"type": "module"` and no `exports`. The module (an ES module, `"type": "module"`) reaches it through Node's CommonJS interop: `import osc from 'osc'` followed by `const { TCPSocketPort } = osc`.

**Fix:** replace `osc` with [`node-osc`](https://github.com/MylesBorins/node-osc), which ships native ES modules and its own TypeScript types (and is already used by other Companion modules). Then delete `src/osc.d.ts`.

Keep the Eos link on TCP. node-osc's `Client` and `Server` are UDP only, so open the TCP socket yourself (for example with Companion's `TCPHelper`) and use node-osc's `encode()` / `decode()` for the messages. Keep the module's current framing and ports: length-prefixed OSC 1.0 on port 3032, or SLIP (OSC 1.1) on port 3037, as `useSLIP` selects today.

Don't switch to OSC over UDP. Eos supports it, but ETC calls TCP the preferred method and says UDP messages "may be dropped or delivered out of order". UDP also needs the operator to set receive and transmit ports and the OSC TX IP on the desk. This module requests the whole cue list and matches each reply to its request, so lost or reordered replies would break it.

**Sources:**

- [TCP port for OSC communication with Eos Software](https://support.etcconnect.com/ETC/Consoles/Eos_Family/Software_and_Programming/TCP_port_for_OSC_communication_with_Eos_Software) (ETC Support)
- [Eos OSC Setup](https://www.etcconnect.com/WebDocs/Controls/EosFamilyOnlineHelp/en/Content/23_Show_Control/08_OSC/Using_OSC_with_Eos/Eos_OSC_Setup.htm) (ETC Eos Family Online Help)
- [OSC Networks](https://www.etcconnect.com/WebDocs/Controls/EosFamilyOnlineHelp/en/Content/23_Show_Control/08_OSC/About_OSC/OSC_Networks.htm) (ETC Eos Family Online Help)
- [Network settings](https://www.etcconnect.com/WebDocs/Controls/EosFamilyOnlineHelp/en/Content/07_Setup/03_Device/Network.htm) (ETC Eos Family Online Help)

---

## 🟢 Low

### L1: Saving an old settings window after pairing can throw away the new pairing

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:98`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/src/main.ts#L98), [`src/main.ts:140-141`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/src/main.ts#L140-L141), [`src/main.ts:173-181`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/src/main.ts#L173-L181)

**What goes wrong:** A user ticks **Start pairing**, saves, and completes pairing in The Notes List while the settings window is still open. If they then click Save in that window, the module starts a fresh pairing with a new code, and the server keeps an "Active" station nobody uses. This depends on how Companion saves a form opened before the pairing finished (not checked); the help already tells users to close and reopen the window, which lowers the risk.

**Why it happens:** Pairing stores the new token with `saveConfig`, but the open form still holds **Start pairing** ticked and an empty token. When it's saved, the module sees "start pairing, or no token" and begins pairing again.

**Fix:** in `configUpdated`, keep the in-memory token when the incoming one is empty but `this.config.token` is set, or only start pairing when **Start pairing** changes from unticked to ticked.

### L2: A network outage can show the connection as OK for up to a minute

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:351-354`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/src/main.ts#L351-L354), [`src/main.ts:187-195`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/src/main.ts#L187-L195), [`src/main.ts:112-116`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/src/main.ts#L112-L116)

**What goes wrong:** If the network to the server drops, the connection status stays OK and the **Connected** feedback stays green for up to 60 s. Network errors during pairing aren't logged at all, and on startup with a token the status never shows Connecting before the first reply.

**Why it happens:** A network error (no HTTP status) in the counts poll is ignored; only the `/me` check every 60 s notices. The pairing poll drops non-HTTP errors silently, and startup goes straight to the first `/me` request.

**Fix:** when an error has no HTTP status, set `connected = false`, set the status to Connection Failure and re-check the **Connected** feedback. Log pairing errors at debug level, and set Connecting before the first `/me` request.

### L3: A revoked station keeps calling the server every 5 seconds

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:353`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/src/main.ts#L353)

**What goes wrong:** After the station is removed in The Notes List, the module keeps sending two requests every 5 s (a counts poll and a `/me` check) forever, all rejected, until the user pairs again.

**Why it happens:** A 401 from the counts poll triggers a `/me` call, but nothing stops the polling timers.

**Fix:** when `/me` returns 401, cancel the timers and wait for the user to pair again.

### L4: A malformed expiry from the server makes a pairing code never expire

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:132`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/src/main.ts#L132), [`src/main.ts:160`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/src/main.ts#L160), [`src/main.ts:101`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/src/main.ts#L101)

**What goes wrong:** If the server's `expiresAt` is missing or not a valid date, the pairing poll never stops, the settings window never shows the code, and every save creates a new code.

**Why it happens:** `Date.parse` returns NaN for a bad date, and any comparison with NaN is false, so "has it expired?" and "is it still valid?" are both always false.

**Fix:** if the parsed value isn't a finite number, use `Date.now() + 10 * 60_000` instead.

### L5: A wrong Eos desk IP leaves nothing in the log

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/eos.ts:148-150`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/src/eos.ts#L148-L150)

**What goes wrong:** With a mistyped or unreachable **Eos desk IP**, errors such as "connection refused" or "host unreachable" never reach the log, so the user can't tell why the desk won't connect.

**Why it happens:** Socket errors are only logged while the reader is already connected.

**Fix:** log the first error of each disconnected period at `warn` (skipping repeats), using `err?.message ?? String(err)`.

### L6: Reconnects to an unreachable Eos desk have no backoff or connect timeout

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/eos.ts:126-128`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/src/eos.ts#L126-L128), [`src/eos.ts:166-172`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/src/eos.ts#L166-L172)

**What goes wrong:** When the desk is off, the module keeps retrying every 5 s for as long as it's down, and each attempt can hang for the operating system's TCP timeout (about 75 s on macOS, about 2 minutes on Linux).

**Why it happens:** The reconnect delay is a fixed 5 s, and no connect timeout is set on the socket.

**Fix:** back off exponentially (5 s up to 60 s, reset on `'ready'`) and add a connect timeout that destroys the socket and lets the close handler schedule the next try.

### L7: The Eos reader keeps sending cue requests after the desk disconnects

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/eos.ts:151-157`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/src/eos.ts#L151-L157), [`src/eos.ts:182-203`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/src/eos.ts#L182-L203)

**What goes wrong:** No visible effect beyond wasted work: after the desk disconnects, the module keeps working through its request queue (one request every 22 ms, up to the whole cue list) against a dead connection, then runs its retry pass against nothing.

**Why it happens:** The close handler doesn't clear the request queues or stop the queue timer, and send errors are swallowed.

**Fix:** stop draining the queue while disconnected (clear `drainTimer`) and empty the queues in the close handler; `'ready'` already starts a new walk.

### L8: After an Eos reconnect, unanswered cues are never retried

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/eos.ts:130-143`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/src/eos.ts#L130-L143), [`src/eos.ts:206-207`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/src/eos.ts#L206-L207), [`src/eos.ts:251-270`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/src/eos.ts#L251-L270)

**What goes wrong:** After the desk reconnects with the same number of cues, cues the desk didn't answer during the re-read aren't asked for again, and the "cue list walk complete" log and final publish never happen.

**Why it happens:** On reconnect the reader clears its cue cache but not the flags that say the first walk already finished. With an unchanged cue count, the end-of-walk step sees those flags and returns early.

**Fix:** reset `walkAnnounced`, `walkRetried` and `announcedCount` in the `'ready'` handler.

### L9: A bogus cue count from the desk is trusted without limits

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/eos.ts:254`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/src/eos.ts#L254)

**What goes wrong:** If the desk (or something answering on its port) reports a nonsensical cue count, the module tries to queue a request for every index in one go, which could stall the module.

**Why it happens:** The count is taken straight from the reply and drives the loops in `walkAll()` and `onQueueIdle()`.

**Fix:** ignore the reply unless `Number.isInteger(n) && n >= 0 && n <= 100000`.

### L10: Cue edits on the desk may refresh the wrong cues

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/eos.ts:314`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/src/eos.ts#L314)

**What goes wrong:** When cues are edited on the desk, the module may drop and re-read a cue that wasn't edited, and miss cues edited as part of a range, so their labels stay out of date. This depends on the Eos message format, which wasn't checked against ETC's documentation or a desk.

**Why it happens:** Eos edit notifications appear to start with a sequence number, followed by cue numbers or ranges such as `"1-5"`. The module treats every argument that looks like a number as a cue number, so it takes the sequence number as a cue, and it skips ranges. The re-count on line 319 only covers inserts and deletes.

**Fix:** skip the first argument and expand `a-b` ranges.

### L11: Option visibility uses the deprecated isVisible function

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:818-819`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/src/main.ts#L818-L819)

**What goes wrong:** No user-visible effect today: the per-module **Type** and **Priority** dropdowns still show and hide correctly. But this is new code written against an API that will be removed in the Companion module API 2.0.

**Why it happens:** `perModuleChoices` uses the function form `isVisible: (options, data) => ...` with `isVisibleData`. Both are marked `@deprecated` in base 1.14.1.

**Fix:** use an expression instead and drop `isVisibleData`.

```ts
isVisibleExpression: `$(options:module) == '${m.id}'`,
```

---

## 💡 Nice to Have

### N1: A mistyped Base URL gives an unhelpful connection error

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:93-94`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/src/main.ts#L93-L94), [`src/config.ts:49`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/src/config.ts#L49)

**What goes wrong:** A malformed **Base URL** only shows up as a generic connection failure from `fetch`.

**Fix:** check it with `new URL()` in `configUpdated` and set the status to Bad Config when it fails. Consider a warning for `http:` URLs, since the station token would then travel unencrypted.

### N2: The cue list is copied and sorted on every lookup

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:63-65`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/src/main.ts#L63-L65) (used at [`src/main.ts:245`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/src/main.ts#L245), [`src/main.ts:274`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/src/main.ts#L274), [`src/main.ts:298`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/src/main.ts#L298), [`src/main.ts:586`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/src/main.ts#L586))

**What goes wrong:** No user-visible effect, just wasted work on large shows: every access copies and sorts the whole cue cache, several times per cursor update and once per step of the stepping loop.

**Fix:** add an index lookup to `EosReader` (for example `getByIndex(i)`) and a cue-number-to-index map.

### N3: Station and production names are inserted into the settings banner as raw HTML

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/config.ts:38`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/src/config.ts#L38)

**What goes wrong:** A station or production name containing `<` or `&` can break the "Paired as ..." banner in the settings window.

**Fix:** HTML-escape `stationName` and `productionName` before building the banner.

### N4: Several actions have no description in the action picker

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:411-497`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/src/main.ts#L411-L497)

**What goes wrong:** **Selected cue ▶**, **Eos: reload the cue list**, **Selected cue = live**, **Highlight previous note**, **Set status of highlighted note**, **Undo** and **Redo** show no description when a user picks an action.

**Fix:** add one-line descriptions like the ones on **New note** and **Highlight next note**.

### N5: The Pairing code box looks editable but ignores what you type

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/config.ts:60-66`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/src/config.ts#L60-L66)

**What goes wrong:** The **Pairing code** field is an ordinary text box, but anything the user types into it is ignored and overwritten by the module.

**Fix:** show the code only in the existing banner, or make the label say clearly that the field is read-only.

### N6: Stepping to the next cue can go past the end of the list while it is still loading

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:271-279`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/6499fdc69fb153c123b51f40e1bd02d368c13fa6/src/main.ts#L271-L279)

**What goes wrong:** Before the desk has reported how many cues there are, **Selected cue ▶** can step beyond the end of the list. A **New note** then falls back to the live cue while `selected_cue_offset` still shows a non-zero offset.

**Why it happens:** With no cue count yet, the upper limit is `Number.MAX_SAFE_INTEGER`, and the module requests indexes that don't exist.

**Fix:** ignore stepping until `cueCount > 0`.

---

## 📝 Additional Notes

- `tsconfig.json` differs from the template: it sets its own `compilerOptions` (Node16 module, `outDir`/`rootDir`) instead of `"extends": "./tsconfig.build.json"`. Fine as long as the module builds; it lines up naturally once the template's `tsconfig.build.json` is added (C9).
