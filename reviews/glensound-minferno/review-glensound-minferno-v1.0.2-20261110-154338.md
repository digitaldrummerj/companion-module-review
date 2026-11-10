# Companion Module Review: glensound-minferno v1.0.2

| Field | Value |
| --- | --- |
| **Module** | [companion-module-glensound-minferno](https://github.com/bitfocus/companion-module-glensound-minferno) |
| **Version** | v1.0.2 (commit [`4fa6bb2`](https://github.com/bitfocus/companion-module-glensound-minferno/commit/4fa6bb2576344d51be46ff1e49c9ad415542a8b3)) |
| **Release** | Update — last published v1.0.1 (tag `1.0.1`) |
| **API** | 1 (base 1.15.1, yarn.lock) |
| **Template** | `companion-module-template-js-v1` @ `9e222b4` (2026-03-26, pinned) · `.yarnrc.yml` from `companion-module-template-js` @ `89da037` (2026-11-01) |
| **Scope** | `tag` — `1.0.1..v1.0.2`. This release moves the module to Node 26 (`@companion-module/base` `~1.7.0` → `~1.15.1`, `@companion-module/tools` `^1.5.0` → `^2.9.1`, runtime `node18` → `node26`) and adds the module checks workflow; no source file changed |
| **Reviewed** | 2026-11-10 |

## Verdict: ✅ Approved

## 📋 Issues

### Non-blocking

- [ ] [NR1: The source files sit at the top of the repository instead of in src/](#nr1-the-source-files-sit-at-the-top-of-the-repository-instead-of-in-src)
- [ ] [NR2: The template's .gitattributes and .yarnrc.yml are missing](#nr2-the-templates-gitattributes-and-yarnrcyml-are-missing)
- [ ] [NR3: yarn package and yarn format fail, and package.json doesn't name the Node and Yarn versions](#nr3-yarn-package-and-yarn-format-fail-and-packagejson-doesnt-name-the-node-and-yarn-versions)
- [ ] [NR4: .gitignore and .prettierignore are missing the template's entries](#nr4-gitignore-and-prettierignore-are-missing-the-templates-entries)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🔮 Next Release

The module's own code works unchanged on base 1.15.1 and Node 26. The items below are differences from the API 1 JavaScript template; all but the missing `prettier` dev tool were already in 1.0.1. They don't block v1.0.2. Please fix them in the next release.

### NR1: The source files sit at the top of the repository instead of in src/

- **Source:** 🤖 validate-template (SRC-AT-ROOT ×5)
- **Classification:** full-module template check (unchanged since 1.0.1)
- **File:** [`main.js`](https://github.com/bitfocus/companion-module-glensound-minferno/blob/4fa6bb2576344d51be46ff1e49c9ad415542a8b3/main.js), [`actions.js`](https://github.com/bitfocus/companion-module-glensound-minferno/blob/4fa6bb2576344d51be46ff1e49c9ad415542a8b3/actions.js), [`feedbacks.js`](https://github.com/bitfocus/companion-module-glensound-minferno/blob/4fa6bb2576344d51be46ff1e49c9ad415542a8b3/feedbacks.js), [`upgrades.js`](https://github.com/bitfocus/companion-module-glensound-minferno/blob/4fa6bb2576344d51be46ff1e49c9ad415542a8b3/upgrades.js), [`variables.js`](https://github.com/bitfocus/companion-module-glensound-minferno/blob/4fa6bb2576344d51be46ff1e49c9ad415542a8b3/variables.js)

**What goes wrong:** Users see no difference. Maintainers do: the template keeps the module's code in `src/`, and every other API 1 JavaScript module follows that layout, so anyone comparing this module with the template or applying a template update has to work around a different structure.

**Why it happens:** The module predates the template's `src/` layout, and its five source files were never moved.

**Fix:** Move the five files into `src/`, then point `package.json` `main` at `src/main.js` ([`package.json:4`](https://github.com/bitfocus/companion-module-glensound-minferno/blob/4fa6bb2576344d51be46ff1e49c9ad415542a8b3/package.json#L4)) and the manifest's `runtime.entrypoint` at `../src/main.js` ([`companion/manifest.json:20`](https://github.com/bitfocus/companion-module-glensound-minferno/blob/4fa6bb2576344d51be46ff1e49c9ad415542a8b3/companion/manifest.json#L20)).

### NR2: The template's .gitattributes and .yarnrc.yml are missing

- **Source:** 🤖 validate-template (FILE-MISSING ×2)
- **Classification:** full-module template check (unchanged since 1.0.1)
- **Files:** `.gitattributes`, `.yarnrc.yml` (neither is in the repository)

**What goes wrong:** Users see no difference. For contributors, line endings aren't normalised (a commit from Windows can turn every line of a file into a change), and once the module moves to Yarn 4 ([NR3](#nr3-yarn-package-and-yarn-format-fail-and-packagejson-doesnt-name-the-node-and-yarn-versions)) it has none of the template's install settings: dependency install scripts stay enabled and newly published packages are installed straight away.

**Why it happens:** The template tracks both files and the module has neither.

**Fix:** Copy both files from the template:

```text
# .gitattributes
* text=auto eol=lf
```

```yaml
# .yarnrc.yml
enableScripts: false

nodeLinker: node-modules

npmMinimalAgeGate: 3d

npmPreapprovedPackages:
  - "@companion-module/*"
```

### NR3: yarn package and yarn format fail, and package.json doesn't name the Node and Yarn versions

- **Source:** 🤖 validate-template (PKG-SCRIPT, PKG-DEVDEP, PKG-FIELD ×2, BUILD-PACKAGE)
- **Classification:** full-module template check; the missing `prettier` dev tool is 🆕 NEW in this release
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-glensound-minferno/blob/4fa6bb2576344d51be46ff1e49c9ad415542a8b3/package.json)

**What goes wrong:** Users see no difference. A contributor who runs `yarn package` gets "Couldn't find a script named package", because the module has no packaging script. Since this release, `yarn format` fails too: `prettier` is no longer installed. Nothing in `package.json` says which Node and Yarn versions the module expects, so tooling can't warn someone on the wrong versions.

**Why it happens:**

- The `scripts` block has only `format`; the template also has `"package": "companion-module-build"`.
- `prettier` used to come in through `@companion-module/tools` 1.5.0. Tools 2.9.1 only lists it as a peer dependency, so after this release's update it is no longer installed, and the template lists it as its own dev dependency.
- The template's `engines` and `packageManager` fields are missing. The committed `yarn.lock` is in Yarn 1 format.

**Evidence:**

```text
PKG-SCRIPT    package.json: Missing required script 'package'
PKG-DEVDEP    package.json: Missing devDependency 'prettier' (present in template)
PKG-FIELD     package.json: Missing required field 'engines' (present in template)
PKG-FIELD     package.json: Missing required field 'packageManager' (present in template)
BUILD-PACKAGE package.json: yarn package (build) failed
```

**Fix:** Add the template's fields, then switch to Yarn 4 (for example `corepack use yarn@4.12.0`) and commit the regenerated `yarn.lock`. Use the Node version of the manifest's runtime (`node26`) in `engines`:

```json
"scripts": {
	"format": "prettier -w .",
	"package": "companion-module-build"
},
"engines": {
	"node": "^26",
	"yarn": "^4"
},
"devDependencies": {
	"@companion-module/tools": "^2.9.1",
	"prettier": "^3.7.4"
},
"packageManager": "yarn@4.12.0"
```

### NR4: .gitignore and .prettierignore are missing the template's entries

- **Source:** 🤖 validate-template (CONFIG-DIFF ×2)
- **Classification:** full-module template check (unchanged since 1.0.1)
- **File:** [`.gitignore`](https://github.com/bitfocus/companion-module-glensound-minferno/blob/4fa6bb2576344d51be46ff1e49c9ad415542a8b3/.gitignore), [`.prettierignore`](https://github.com/bitfocus/companion-module-glensound-minferno/blob/4fa6bb2576344d51be46ff1e49c9ad415542a8b3/.prettierignore)

**What goes wrong:** Users see no difference. A contributor can commit a `package-lock.json`, a built `pkg/` folder, `DEBUG-*` logs or Yarn 4's `.yarn/` folder by mistake, and `yarn format` rewrites `LICENSE.md`, which the template keeps out of Prettier.

**Why it happens:** `.gitignore` is a generic Node.js ignore file rather than the template's, and `.prettierignore` lists `pkg` where the template has `/LICENSE.md`.

**Evidence:**

```text
CONFIG-DIFF .gitignore:      Missing template .gitignore entries: package-lock.json, /pkg, /*.tgz, DEBUG-*, /.yarn
CONFIG-DIFF .prettierignore: Differs from template (line 2: found 'pkg', template '/LICENSE.md')
```

**Fix:** Add the template's entries; the module's own extra entries can stay.

```text
# .gitignore
node_modules/
package-lock.json
/pkg
/*.tgz
DEBUG-*
/.yarn

# .prettierignore
package.json
/LICENSE.md
```

## 📝 Additional Notes

- The manifest's runtime moved from `node18` to `node26` in this release ([`companion/manifest.json:17`](https://github.com/bitfocus/companion-module-glensound-minferno/blob/4fa6bb2576344d51be46ff1e49c9ad415542a8b3/companion/manifest.json#L17)). The API 1 template still uses `node22`, but `@companion-module/base` 1.15.1 accepts `node26`, so this is not a finding.
