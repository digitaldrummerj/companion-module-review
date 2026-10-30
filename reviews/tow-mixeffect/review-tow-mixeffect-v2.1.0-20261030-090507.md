# Review: tow-mixeffect v2.1.0

| | |
| --- | --- |
| **Module** | [companion-module-tow-mixeffect](https://github.com/bitfocus/companion-module-tow-mixeffect) |
| **Scope** | `tag` (v2.0.6..v2.1.0) |
| **Version** | v2.1.0 (`0d4e47d`) |
| **Release** | Update — last published v2.0.6 |
| **API** | 1 (base 1.8.0, yarn.lock) |
| **Template** | `companion-module-template-js-v1` @ `9e222b4` (2026-03-26, pinned) · `.yarnrc.yml` from `companion-module-template-js` @ `76d25b2` (2026-10-11) |
| **Review date** | 2026-10-30 |

## Verdict: ❌ Changes Required

## 📋 Issues

### Blocking

- [ ] [C1: The module cannot be installed on Node 22](#c1-the-module-cannot-be-installed-on-node-22)
- [ ] [C2: The module package cannot be built](#c2-the-module-package-cannot-be-built)
- [ ] [C3: The module still uses Yarn 1 instead of Yarn 4](#c3-the-module-still-uses-yarn-1-instead-of-yarn-4)
- [ ] [C4: The manifest asks Companion to run the module on Node 18](#c4-the-manifest-asks-companion-to-run-the-module-on-node-18)
- [ ] [C5: The template's .gitattributes file is missing](#c5-the-templates-gitattributes-file-is-missing)
- [ ] [C6: The template's .yarnrc.yml file is missing](#c6-the-templates-yarnrcyml-file-is-missing)
- [ ] [C7: .gitignore lacks the template's package, debug and Yarn entries](#c7-gitignore-lacks-the-templates-package-debug-and-yarn-entries)
- [ ] [C8: .prettierignore does not match the template](#c8-prettierignore-does-not-match-the-template)
- [ ] [C9: package.json has no engines field](#c9-packagejson-has-no-engines-field)
- [ ] [C10: package.json has no prettier field](#c10-packagejson-has-no-prettier-field)
- [ ] [C11: package.json has no format script](#c11-packagejson-has-no-format-script)
- [ ] [H1: The module checks workflow adds a Node 18 test job the template does not have](#h1-the-module-checks-workflow-adds-a-node-18-test-job-the-template-does-not-have)
- [ ] [H2: The LICENSE copyright year differs from the template](#h2-the-license-copyright-year-differs-from-the-template)

## 🔴 Critical

### C1: The module cannot be installed on Node 22

- **Source:** 🤖 validate-template (BUILD-INSTALL)
- **Classification:** 🆕 NEW
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-tow-mixeffect/blob/0d4e47df61e2b5f2e65f528e962914b46069d242/package.json)

**What goes wrong:** Installing the dependencies with `yarn install --immutable` on Node 22 (the version the template and the Bitfocus build use) fails, so nothing after it can run.

**Why it happens:** The module is set up with Yarn 1 and `@companion-module/base` ~1.8.0. That base version declares it only supports Node `^18.12`, and Yarn 1 enforces that engines check, so it refuses to install on Node 22. Moving to the template's Yarn 4, Node 22 and a current base 1.x release removes the conflict.

**Evidence:**

```text
error @companion-module/base@1.8.0: The engine "node" is incompatible with this module. Expected version "^18.12". Got "22.21.1"
```

**Confirm by:** `yarn install --immutable` succeeds on Node 22 with Yarn 4.

**Fix:** switch to Yarn 4 (see [C3](#c3-the-module-still-uses-yarn-1-instead-of-yarn-4)) and update `@companion-module/base` to the template's `~1.14.1`, then regenerate `yarn.lock`.

### C2: The module package cannot be built

- **Source:** 🤖 validate-template (BUILD-PACKAGE)
- **Classification:** 🆕 NEW
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-tow-mixeffect/blob/0d4e47df61e2b5f2e65f528e962914b46069d242/package.json)

**What goes wrong:** `yarn package` does not produce the `.tgz` that Companion installs, so this release cannot be built.

**Why it happens:** This follows from [C1](#c1-the-module-cannot-be-installed-on-node-22): the install fails, so there is no `node_modules` folder and the build tool (`companion-module-build`) is not available.

**Confirm by:** `yarn package` produces the `.tgz` after C1 is fixed.

**Fix:** fix C1; no separate change is needed.

### C3: The module still uses Yarn 1 instead of Yarn 4

- **Source:** 🤖 validate-template (PKG-YARN)
- **Classification:** 🆕 NEW
- **File:** [`package.json:16`](https://github.com/bitfocus/companion-module-tow-mixeffect/blob/0d4e47df61e2b5f2e65f528e962914b46069d242/package.json#L16)

**What goes wrong:** The module declares Yarn 1 as its package manager, while the template (and the Bitfocus build) expect Yarn 4. The lockfile is also in the Yarn 1 format (`# yarn lockfile v1`).

**Why it happens:** The `packageManager` field added in this release names `yarn@1.22.22`; the template has `yarn@4.12.0`.

**Evidence:**

```json
// package.json:16
"packageManager": "yarn@1.22.22",
```

**Confirm by:** open [`package.json:16`](https://github.com/bitfocus/companion-module-tow-mixeffect/blob/0d4e47df61e2b5f2e65f528e962914b46069d242/package.json#L16); the template has `"packageManager": "yarn@4.12.0"`.

**Fix:** set the package manager to Yarn 4 and regenerate the lockfile with it.

```json
"packageManager": "yarn@4.12.0"
```

### C4: The manifest asks Companion to run the module on Node 18

- **Source:** 🤖 validate-template (MAN-RUNTIME)
- **Classification:** 🆕 NEW
- **File:** [`companion/manifest.json:22`](https://github.com/bitfocus/companion-module-tow-mixeffect/blob/0d4e47df61e2b5f2e65f528e962914b46069d242/companion/manifest.json#L22)

**What goes wrong:** Companion picks the Node runtime for a module from its manifest. This module asks for Node 18, while the template requires Node 22.

**Why it happens:** `runtime.type` is still `node18`.

**Evidence:**

```json
// companion/manifest.json:22
"type": "node18",
```

**Confirm by:** open [`companion/manifest.json:22`](https://github.com/bitfocus/companion-module-tow-mixeffect/blob/0d4e47df61e2b5f2e65f528e962914b46069d242/companion/manifest.json#L22); the template has `"type": "node22"`.

**Fix:** change the runtime to Node 22.

```json
"type": "node22",
```

### C5: The template's .gitattributes file is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.gitattributes` (missing)

**What goes wrong:** The repository has no `.gitattributes`, so it lacks the line-ending rule every template-based module carries.

**Why it happens:** The template tracks a `.gitattributes` file and the module never added it.

**Confirm by:** `.gitattributes` is not in the repository root at the review commit.

**Fix:** copy `.gitattributes` from `companion-module-template-js-v1` unchanged.

### C6: The template's .yarnrc.yml file is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.yarnrc.yml` (missing)

**What goes wrong:** Without `.yarnrc.yml`, Yarn 4 would use Plug'n'Play instead of a `node_modules` folder, would run dependency install scripts, and would install freshly published packages without the template's safety delay.

**Why it happens:** The template tracks a `.yarnrc.yml` file and the module never added it.

**Confirm by:** `.yarnrc.yml` is not in the repository root at the review commit.

**Fix:** add the template's file.

```yaml
enableScripts: false

nodeLinker: node-modules

npmMinimalAgeGate: 3d

npmPreapprovedPackages:
  - "@companion-module/*"
```

### C7: .gitignore lacks the template's package, debug and Yarn entries

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.gitignore`](https://github.com/bitfocus/companion-module-tow-mixeffect/blob/0d4e47df61e2b5f2e65f528e962914b46069d242/.gitignore)

**What goes wrong:** Built packages (`*.tgz`), Companion debug logs and Yarn 4's `.yarn` folder can be committed by accident.

**Why it happens:** The module's `.gitignore` is missing three template entries: `/*.tgz`, `DEBUG-*` and `/.yarn`. It has `/pkg.tgz` instead of `/*.tgz`.

**Evidence:**

```text
# .gitignore:1-7
node_modules/
package-lock.json
.DS_Store

# Companion 3.0
/pkg
/pkg.tgz
```

**Confirm by:** open [`.gitignore`](https://github.com/bitfocus/companion-module-tow-mixeffect/blob/0d4e47df61e2b5f2e65f528e962914b46069d242/.gitignore); `/*.tgz`, `DEBUG-*` and `/.yarn` are absent.

**Fix:** add the missing template entries.

```text
/*.tgz
DEBUG-*
/.yarn
```

### C8: .prettierignore does not match the template

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.prettierignore:1-9`](https://github.com/bitfocus/companion-module-tow-mixeffect/blob/0d4e47df61e2b5f2e65f528e962914b46069d242/.prettierignore#L1-L9)

**What goes wrong:** Formatting runs over different files than in other modules. The template's `/LICENSE.md` entry is missing, and the file lists `node_modules`, `yarn.lock` and `CHANGELOG.md` instead.

**Why it happens:** The template's `.prettierignore` is exactly `package.json` and `/LICENSE.md`; the module kept its own version.

**Evidence:**

```text
# .prettierignore:1-9
# dependencies
node_modules

# Ignore package related files:
package.json
yarn.lock

# Docs
CHANGELOG.md
```

**Confirm by:** open [`.prettierignore:1-9`](https://github.com/bitfocus/companion-module-tow-mixeffect/blob/0d4e47df61e2b5f2e65f528e962914b46069d242/.prettierignore#L1-L9) and compare with the template's two lines.

**Fix:** replace the file with the template's contents.

```text
package.json
/LICENSE.md
```

### C9: package.json has no engines field

- **Source:** 🤖 validate-template (PKG-FIELD)
- **Classification:** 🆕 NEW
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-tow-mixeffect/blob/0d4e47df61e2b5f2e65f528e962914b46069d242/package.json)

**What goes wrong:** Nothing tells a developer or the tooling which Node and Yarn versions the module needs, so an install on the wrong version fails late (as in [C1](#c1-the-module-cannot-be-installed-on-node-22)) instead of up front.

**Why it happens:** The template declares an `engines` block; the module's `package.json` has none.

**Confirm by:** open [`package.json`](https://github.com/bitfocus/companion-module-tow-mixeffect/blob/0d4e47df61e2b5f2e65f528e962914b46069d242/package.json); there is no `engines` key.

**Fix:** add the template's `engines` block.

```json
"engines": {
	"node": "^22.20",
	"yarn": "^4"
}
```

### C10: package.json has no prettier field

- **Source:** 🤖 validate-template (PKG-FIELD)
- **Classification:** 🆕 NEW
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-tow-mixeffect/blob/0d4e47df61e2b5f2e65f528e962914b46069d242/package.json)

**What goes wrong:** The module does not use the shared Companion formatting rules, so its code style drifts from other modules.

**Why it happens:** The template points Prettier at `@companion-module/tools/.prettierrc.json` from `package.json`; the module has no `prettier` field.

**Confirm by:** open [`package.json`](https://github.com/bitfocus/companion-module-tow-mixeffect/blob/0d4e47df61e2b5f2e65f528e962914b46069d242/package.json); there is no `prettier` key.

**Fix:** add the template's field.

```json
"prettier": "@companion-module/tools/.prettierrc.json"
```

### C11: package.json has no format script

- **Source:** 🤖 validate-template (PKG-SCRIPT)
- **Classification:** 🆕 NEW
- **File:** [`package.json:6-10`](https://github.com/bitfocus/companion-module-tow-mixeffect/blob/0d4e47df61e2b5f2e65f528e962914b46069d242/package.json#L6-L10)

**What goes wrong:** `yarn format`, the standard way to format a Companion module, does not exist in this module.

**Why it happens:** The scripts block has `test`, `prettier` and `package`, but not the template's `format` script.

**Evidence:**

```json
// package.json:6-10
"scripts": {
	"test": "node --test",
	"prettier": "prettier",
	"package": "companion-module-build"
},
```

**Confirm by:** open [`package.json:6-10`](https://github.com/bitfocus/companion-module-tow-mixeffect/blob/0d4e47df61e2b5f2e65f528e962914b46069d242/package.json#L6-L10); there is no `format` entry.

**Fix:** add the template's script.

```json
"format": "prettier -w ."
```

## 🟠 High

### H1: The module checks workflow adds a Node 18 test job the template does not have

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.github/workflows/companion-module-checks.yaml:7-21`](https://github.com/bitfocus/companion-module-tow-mixeffect/blob/0d4e47df61e2b5f2e65f528e962914b46069d242/.github/workflows/companion-module-checks.yaml#L7-L21)

**What goes wrong:** Every push runs an extra CI job on Node 18 with Yarn 1 commands, so CI tests the module on a different setup than the one Companion and the template use. Once the module moves to Yarn 4 (C3), `yarn install --frozen-lockfile` and `yarn audit` are Yarn 1 commands and this job will break.

**Why it happens:** The workflow file, added in this release, has a whole `test:` job that the template's `companion-module-checks.yaml` does not contain. The template file has only the `check:` job.

**Evidence:**

```yaml
# .github/workflows/companion-module-checks.yaml:7-21
  test:
    name: Test module
    runs-on: ubuntu-latest
    permissions:
      contents: read
    steps:
      - uses: actions/checkout@v6
      - uses: actions/setup-node@v6
        with:
          node-version: '18'
      - run: corepack enable
      - run: yarn install --frozen-lockfile
      - run: yarn test
      - name: Audit dependencies
        run: yarn audit
```

**Confirm by:** `diff` [`.github/workflows/companion-module-checks.yaml`](https://github.com/bitfocus/companion-module-tow-mixeffect/blob/0d4e47df61e2b5f2e65f528e962914b46069d242/.github/workflows/companion-module-checks.yaml) against `companion-module-template-js-v1/.github/workflows/companion-module-checks.yaml` shows no differences other than the accepted `upload-artifact` lines.

**Fix:** remove the `test:` job so the file matches the template. If you want the tests in CI, run them in a separate workflow file on Node 22 with Yarn 4.

### H2: The LICENSE copyright year differs from the template

- **Source:** 🤖 validate-template (LICENSE-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`LICENSE:3`](https://github.com/bitfocus/companion-module-tow-mixeffect/blob/0d4e47df61e2b5f2e65f528e962914b46069d242/LICENSE#L3)

**What goes wrong:** The license text does not match the standard Bitfocus license used by the template.

**Why it happens:** The copyright line says 2021 where the template says 2022.

**Evidence:**

```text
# LICENSE:3
Copyright (c) 2021 Bitfocus AS - Open Source
```

**Confirm by:** open [`LICENSE:3`](https://github.com/bitfocus/companion-module-tow-mixeffect/blob/0d4e47df61e2b5f2e65f528e962914b46069d242/LICENSE#L3); the template has `Copyright (c) 2022 Bitfocus AS - Open Source`.

**Fix:** replace `LICENSE` with the template's file.

```text
Copyright (c) 2022 Bitfocus AS - Open Source
```
