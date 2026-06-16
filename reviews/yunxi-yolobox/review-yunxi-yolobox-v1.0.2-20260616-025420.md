# Review: yunxi-yolobox (YoloBox) — v1.0.2

| | |
|---|---|
| **Module** | yunxi-yolobox (YoloBox) |
| **Version** | v1.0.2 |
| **Scope** | `tag` (first release — no previous tag; whole `src/` reviewed, all findings NEW) |
| **Language** | JavaScript (v1 API, `@companion-module/base ~1.12.0`) |
| **Transport** | WebSocket (`ws ^8.20.1`) — the fact-sheet OSC/HTTP/Bonjour entries are false positives from base64 image data in `src/icons.generated.js` |
| **Build/Package** | ✅ `yarn package` (companion-module-build) succeeds |
| **Lint/Format** | ❌ broken in a clean checkout (see C8) |
| **Reviewed** | 2026-06-16 |

## Verdict: ❌ Changes Required

## 📋 Issues

**Blocking**

- [ ] [C1: Please update all comments and commits in English](#c1-please-make-all-comments-and-commits-in-english)
- [ ] [C3: Required file .gitattributes is missing](#c3-required-file-gitattributes-is-missing)
- [ ] [C4: Required file .prettierignore is missing](#c4-required-file-prettierignore-is-missing)
- [ ] [C5: .gitignore is missing required template entries](#c5-gitignore-is-missing-required-template-entries)
- [ ] [C6: .yarnrc.yml differs from the template](#c6-yarnrcyml-differs-from-the-template)
- [ ] [C7: package.json is missing the required prettier config field](#c7-packagejson-is-missing-the-required-prettier-config-field)


## 🔴 Critical

### C1: Please make all comments and commits in English

For Companion modules, English code comments, skills, and commits are a requirement.  This allows the global community to understand all of the code.

**Fix:** update the code comments and skills file to be in English.

### C3: Required file .gitattributes is missing

**Classification:** 🆕 NEW · `.gitattributes` (deterministic: FILE-MISSING)

The template-required `.gitattributes` is absent. Add the file from the official `companion-module-template-js-v1`.

### C4: Required file .prettierignore is missing

**Classification:** 🆕 NEW · `.prettierignore` (deterministic: FILE-MISSING)

The template-required `.prettierignore` is absent. Add the file from the official template.

### C5: .gitignore is missing required template entries

**Classification:** 🆕 NEW · `.gitignore` (deterministic: CONFIG-DIFF)

Missing template entries: `package-lock.json`, `/pkg`, `/*.tgz`, `DEBUG-*`, `/.yarn`. Without these, build artifacts (e.g. the `*.tgz` package, the `pkg` dir) and a stray `package-lock.json` can be committed. Add the missing lines to match the template.

### C6: .yarnrc.yml differs from the template

**Classification:** 🆕 NEW · `.yarnrc.yml` (deterministic: CONFIG-DIFF)

The first line is `approvedGitRepositories:` rather than the template's `nodeLinker: node-modules`. The file does still set `nodeLinker: node-modules` lower down, but it adds non-template keys (`approvedGitRepositories: ["**"]`, `enableScripts: true`). Restore the file to match the template ordering/content unless these additions are deliberate and justified.

### C7: package.json is missing the required prettier config field

**Classification:** 🆕 NEW · `package.json` (deterministic: PKG-FIELD)

The template's `package.json` carries a top-level `prettier` config key; this module has none (it ships a separate `.prettierrc.json` instead). Add the `prettier` field to `package.json` to match the template, or confirm the standalone `.prettierrc.json` is the intended convention and align with the template either way.

### C8: prettier and eslint are not installed — lint and format scripts fail in a clean checkout

**Classification:** 🆕 NEW · `package.json` (deterministic: PKG-DEVDEP, plus verified by build)

The only declared devDependency is `@companion-module/ools ^2.6.1` (resolved 2.7.1), which lists `eslint ^9.36.0`, `prettier ^3.6.2`, and `typescript-eslint ^8.44.1` as **peer dependencies** — they are not auto-installed. The module declares none of them, so after a clean `yarn install` neither `eslint` nor `prettier` is present in `node_modules/.bin`. As a result the advertised scripts break:

- `yarn lint` (`eslint src/`) → eslint binary not found
- `yarn format` / `yarn format:check` (`prettier ...`) → prettier binary not found

`yarn package` itself succeeds, so the module builds — but the maintainer's own lint/format gates cannot run.

**Fix:** Add `eslint`, `prettier`, and `typescript-eslint` (at the peer-required ranges) to `devDependencies`, matching the official template. Then re-run `yarn install && yarn lint && yarn format:check` to confirm they pass.

