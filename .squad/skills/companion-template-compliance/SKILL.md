# Skill: companion-template-compliance

**Description:** Full checklist for verifying that a Companion module matches the official JS or TS template. Covers required files, config file content, package.json rules, manifest.json rules, HELP.md validation, and husky hooks.  
**Confidence:** high  
**Last-updated:** 2026-04-02

## Template Source Directories

When in doubt, compare directly against the authoritative templates in the workspace:

| Type | Directory |
|------|-----------|
| **JavaScript** | `companion-module-template-js/` (in `companion-modules-reviewing/` workspace root) |
| **TypeScript** | `companion-module-template-ts/` (in `companion-modules-reviewing/` workspace root) |

---

## ⛔ Instant Rejection Checklist — Check These First

**Before doing anything else, verify every item below. Each one is an automatic 🔴 Critical blocking finding if it fails. Do not skip any of them.**

### Config Files — Content Must Match Template Exactly

| File | Expected content | Common failure |
|------|-----------------|----------------|
| `.gitattributes` | `* text=auto eol=lf` (single line) | Missing file, extra lines, wrong line endings |
| `.gitignore` | See Section 4 for exact content per JS/TS | Extra entries, missing entries, wrong entries |
| `.prettierignore` | `package.json` and `/LICENSE.md` (two lines) | Missing file, extra entries, different casing |
| `.yarnrc.yml` | `nodeLinker: node-modules` (single line) | Missing file, different value, extra content |

If the file is missing **or** the content doesn't match the template: **🔴 Critical — blocks approval.**

### `package.json` — Required Fields

| Field | Required | Common failure |
|-------|----------|----------------|
| `engines.node` | `"^22.20"` or `"^22.x"` | Field missing entirely, or still set to `^18` |
| `engines.yarn` | `"^4"` | Field missing entirely, or `engines` block absent |
| `prettier` | `"@companion-module/tools/.prettierrc.json"` | Field missing entirely |
| `packageManager` | `"yarn@4.x.x"` (must start with `yarn@4`) | Field missing, or set to npm/older yarn |
| `repository.type` | `"git"` | Field missing entirely |
| `repository.url` | `"git+https://github.com/bitfocus/companion-module-{name}.git"` | Field missing, wrong org, wrong format |

If **any** of these fields are missing or wrong: **🔴 Critical — blocks approval.**

### `LICENSE` File — Content Must Match the Template Repo

- The `LICENSE` file must exist (see Required Files checklist)
- The content **must match the template repo** (`companion-module-template-js/LICENSE`) — do a line-by-line comparison
- The only acceptable difference is the copyright line (`Copyright (c) {year} {Author}`) — year and author name may differ
- Any other deviation (different license type, extra text, missing text, wrong structure) is **🔴 Critical**
- The copyright line must reference a real author/organization — not `"Your name"` or similar placeholder

If `LICENSE` is missing, doesn't match the template, is a placeholder, or is not MIT: **🔴 Critical — blocks approval.**

---

## 1. Detecting JS vs TS

A module is **TypeScript** if either of these is true:
- `tsconfig.json` exists at the module root
- `package.json` contains `"type": "module"`

Otherwise treat it as **JavaScript**.

---

## 2. Required Files Checklist

### JavaScript modules

| File | Required |
|------|----------|
| `.gitattributes` | ✅ |
| `.gitignore` | ✅ |
| `.prettierignore` | ✅ |
| `.yarnrc.yml` | ✅ |
| `LICENSE` | ✅ |
| `package.json` | ✅ |
| `yarn.lock` | ✅ |
| `companion/manifest.json` | ✅ |
| `companion/HELP.md` | ✅ |
| `src/main.js` | ✅ |

### TypeScript modules

All JS files above, **plus**:

| File | Required |
|------|----------|
| `eslint.config.mjs` | ✅ |
| `tsconfig.build.json` | ✅ |
| `tsconfig.json` | ✅ |
| `.husky/pre-commit` | ✅ |
| `src/main.ts` | ✅ |

> **Note:** `package-lock.json` must **NOT** be present in either module type — presence is an automatic rejection.

---

## 3. Source Code Directory Rule

**All source code files must be in the `src/` directory.** No `.js` or `.ts` source files may exist at the module root or in any directory other than `src/` (and its subdirectories).

**Check:**
- For JS modules: `src/main.js` must exist; `main.js` at the root is a Critical violation
- For TS modules: `src/main.ts` must exist; `main.ts` at the root is a Critical violation
- If source files are at the root, the `package.json` `"main"` field will also be wrong (e.g., `"main.js"` instead of `"src/main.js"`) — flag both
- If source files are at the root, `manifest.json` `"entrypoint"` will also be wrong (e.g., `"../main.js"` instead of `"../src/main.js"`) — flag both

**Severity:** 🔴 Critical — blocks approval.

---

## 4. Config File Content Rules
### `.gitattributes`

**JS and TS (identical):**
```
* text=auto eol=lf
```

### `.gitignore`

**JS template:**
```
node_modules/
package-lock.json
/pkg
/*.tgz
DEBUG-*
/.yarn
```

**TS template** — same as JS plus these two lines:
```
/dist
/.vscode
```

### `.prettierignore`

**JS and TS (identical):**
```
package.json
/LICENSE.md
```

### `.yarnrc.yml`

**JS and TS (identical):**
```yaml
nodeLinker: node-modules
```

### `eslint.config.mjs` (TS only)

```js
import { generateEslintConfig } from '@companion-module/tools/eslint/config.mjs'
export default generateEslintConfig({ enableTypescript: true })
```

### `tsconfig.build.json` (TS only)

```json
{
  "extends": "@companion-module/tools/tsconfig/node22/recommended",
  "include": ["src/**/*.ts"],
  "exclude": ["node_modules/**", "src/**/*spec.ts", "src/**/__tests__/*", "src/**/__mocks__/*"],
  "compilerOptions": {
    "outDir": "./dist",
    "baseUrl": "./",
    "paths": {"*": ["./node_modules/*"]},
    "module": "Node16",
    "moduleResolution": "Node16"
  }
}
```

> Deviations (e.g. `nodenext` instead of `Node16`) must be justified in the review.

### `tsconfig.json` (TS only)

```json
{
  "extends": "./tsconfig.build.json",
  "include": ["src/**/*.ts"],
  "exclude": ["node_modules/**"],
  "compilerOptions": {"types": ["node"]}
}
```

---

## 5. `package.json` Rules

### 4a. JavaScript modules

**Required fields and expected values:**

| Field | Expected value / pattern |
|-------|--------------------------|
| `name` | module name (no `companion-module-` prefix required, but must be consistent with repo) |
| `version` | must match git tag without the `v` prefix (e.g. tag `v2.1.0` → `"2.1.0"`) |
| `main` | `"src/main.js"` |
| `license` | `"MIT"` |
| `repository.type` | `"git"` |
| `repository.url` | `"git+https://github.com/bitfocus/companion-module-{module-name}.git"` |
| `engines.node` | `"^22.20"` or broader `"^22.x"` pattern |
| `engines.yarn` | `"^4"` |
| `prettier` | `"@companion-module/tools/.prettierrc.json"` |
| `packageManager` | must start with `"yarn@4"` (e.g. `"yarn@4.12.0"`) |

**Required `scripts`:**

| Script | Required |
|--------|----------|
| `format` | ✅ (`prettier -w .`) |
| `package` | ✅ (`companion-module-build`) |

**Required `dependencies`:**

| Package | Notes |
|---------|-------|
| `@companion-module/base` | required; semver flexibility allowed (e.g. `~1.14.1`) |

**Required `devDependencies`:**

| Package | Notes |
|---------|-------|
| `@companion-module/tools` | required |
| `prettier` | required |

---

### 4b. TypeScript modules

All JS rules above, **plus**:

**`main`** must be `"dist/main.js"` (not `src/`)  
**`type`** must be `"module"`

**Required `scripts` (TS adds):**

| Script | Required |
|--------|----------|
| `postinstall` | ✅ (`husky`) |
| `build` | ✅ (`rimraf dist && run build:main`) |
| `build:main` | ✅ (`tsc -p tsconfig.build.json`) |
| `dev` | ✅ (`tsc -p tsconfig.build.json --watch`) |
| `lint:raw` | ✅ (`eslint`) |
| `lint` | ✅ (`run lint:raw .`) |
| `package` | ✅ (`run build && companion-module-build`) |
| `format` | ✅ (`prettier -w .`) |

**Required `devDependencies` (TS adds):**

| Package | Notes |
|---------|-------|
| `@types/node` | required |
| `eslint` | required |
| `husky` | required |
| `lint-staged` | required |
| `rimraf` | required |
| `typescript` | required |
| `typescript-eslint` | required |

**Required extra sections:**

| Section | Expected value |
|---------|----------------|
| `lint-staged` | must be present with at least `*.{ts,tsx,js,jsx}` and `*.{css,json,md,scss}` entries |

---

## 6. `manifest.json` Rules (JS and TS)

| Field | Rule |
|-------|------|
| `id` | must equal the module name **without** the `companion-module-` prefix |
| `name` | must equal `id` |
| `maintainers[].name` | must NOT be `"Your name"` or any obvious placeholder |
| `maintainers[].email` | must NOT be `"Your email"` or any obvious placeholder |
| `maintainers` | must NOT be empty array `[]` |
| `repository` | must be `"git+https://github.com/bitfocus/companion-module-{module-name}.git"` |
| `runtime.type` | `"node22"` |
| `runtime.api` | `"nodejs-ipc"` |
| `runtime.entrypoint` | JS: `"../src/main.js"` — TS: `"../dist/main.js"` |
| `version` | `"0.0.0"` is acceptable/preferred in source control; if a real version string is committed instead, it must exactly match `package.json` |
| `keywords` | see below |
| `$schema` | should reference `../node_modules/@companion-module/base/assets/manifest.schema.json` |

### Banned `keywords`

The `keywords` array must NOT contain any of:
- `"companion"`
- `"module"`
- `"stream deck"`
- The manufacturer name (e.g. `"bitfocus"`, `"softouch"`)
- The module/product name (e.g. `"easyworship"`, `"tallyccupro"`)
- The full product name (e.g. `"EasyWorship"`, `"Generic SNMP"`)

Flag any keyword that matches these patterns — it adds no value and pollutes search.

---

## 7. `companion/HELP.md` Rules (JS and TS)

The file must contain real user-facing documentation. Flag it if:

- It contains the exact string `"Write some help for your users here"` → stub, not acceptable
- The only heading is `## Your module` with no additional content → stub, not acceptable
- The file is fewer than 5 meaningful lines → likely placeholder

A good HELP.md covers: what the module does, how to configure it (host/port/auth), what actions/feedbacks/variables are available, and any troubleshooting tips.

---

## 8. TS-only: `.husky` Directory

- The `.husky/` directory must be committed to the repo (must NOT appear in `.gitignore`)
- Must contain a `pre-commit` file
- The `pre-commit` file must contain (at minimum):
  ```
  lint-staged
  ```
- The hook runs `lint-staged` before every commit, ensuring code is linted and formatted

---

## 9. Severity Table

> **⚠️ All template compliance violations are CRITICAL severity — they always block approval.**

| Violation | Severity |
|-----------|----------|
| Missing required file | **🔴 Critical** (blocks) |
| `package-lock.json` present | **🔴 Critical** (blocks) |
| Source code files not in `src/` directory | **🔴 Critical** (blocks) |
| `version` in `package.json` doesn't match git tag | **🔴 Critical** (blocks) |
| Missing `repository` field in `package.json` (entirely absent) | **🔴 Critical** (blocks) |
| Wrong `repository` URL (package.json or manifest.json) | **🔴 Critical** (blocks) |
| `LICENSE` file is missing, doesn't match template repo, is a placeholder, or is not MIT | **🔴 Critical** (blocks) |
| Placeholder maintainer `name` or `email` in manifest | **🔴 Critical** (blocks) |
| Empty `maintainers` array | **🔴 Critical** (blocks) |
| Stub `companion/HELP.md` | **🔴 Critical** (blocks) |
| Banned keyword in `manifest.json` keywords | **🔴 Critical** (blocks) |
| Missing `engines`, `prettier`, or `packageManager` fields | **🔴 Critical** (blocks) |
| Missing required `scripts` (TS) | **🔴 Critical** (blocks) |
| Missing required `devDependencies` | **🔴 Critical** (blocks) |
| `.husky` missing or not committed (TS) | **🔴 Critical** (blocks) |
| `manifest.json` id or name doesn't match module name | **🔴 Critical** (blocks) |
| Config file content differs from template (`.gitattributes`, `.gitignore`, `.prettierignore`, `.yarnrc.yml`) | **🔴 Critical** (blocks) |
| Extra `.gitignore` entries beyond template | **🔴 Critical** (blocks) |
| `tsconfig` deviations without justification | **🔴 Critical** (blocks) |

---

## 10. How to Report Findings

Show side-by-side comparisons so the maintainer can see exactly what to change:

```
Template expects:  "repository.url": "git+https://github.com/bitfocus/companion-module-{name}.git"
Found:             "repository.url": "git+https://github.com/personal-user/companion-module-name.git"
```

```
Template expects:  engines.node = "^22.20"
Found:             engines.node field missing entirely
```

```
Template expects:  keywords = [] (or non-banned terms only)
Found:             keywords = ["companion", "module", "easyworship"]
  → Banned: "companion", "module", "easyworship" (product name)
```

For missing files:
```
Required file missing: .husky/pre-commit
  → TS modules must commit the husky pre-commit hook
```

For maintainer placeholders:
```
manifest.json maintainers[0].name = "Your name"  ← placeholder, must be replaced
manifest.json maintainers[0].email = "Your email"  ← placeholder, must be replaced
```
