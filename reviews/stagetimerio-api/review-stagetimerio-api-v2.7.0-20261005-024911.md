# Review: stagetimerio-api v2.7.0

| | |
| --- | --- |
| **Module** | `companion-module-stagetimerio-api` ([repo](https://github.com/bitfocus/companion-module-stagetimerio-api)) |
| **Version** | v2.7.0 (`8a95d1f`, 2026-10-03) |
| **Previous tag** | v2.6.1 (`67017b7`, 2026-08-03) |
| **Scope:** | tag (`v2.6.1..v2.7.0`) |
| **Language** | JavaScript (ESM) |
| **Template** | [API 1 JavaScript template](https://github.com/bitfocus/companion-module-template-js/tree/9e222b4d0b1a68b2acda7d8adb52c9f90ee4c3d1) (`companion-module-template-js` @ `9e222b4`, 2026-03-26, the last API 1 commit) |
| **API** | 1 (base 1.14.1, yarn.lock) |
| **Build** | `yarn install` passes; `yarn package` fails (no `package` script, see C11) |
| **Review date** | 2026-10-08 |

This release adds a **Transport: Jump playhead** action and its presets, and rewords "highlighted" to "selected" in the action descriptions. The release changes themselves raise no blocking issues. The blocking items are template-compliance checks on the whole module: none of the affected files changed in this release (apart from the version fields), but a release that doesn't match the template or can't be packaged can't ship.

**About the template:** the official JavaScript template repository has moved to the module API 2.1 (Companion 5). This module uses API 1, so every template finding below links to the API 1 version of the template, at commit [`9e222b4`](https://github.com/bitfocus/companion-module-template-js/tree/9e222b4d0b1a68b2acda7d8adb52c9f90ee4c3d1). Earlier versions of the template are no longer maintained, but that commit preserves the API 1 files.

## Verdict: ❌ Changes Required

## 📋 Issues

### Blocking

- [ ] [C1: The repo has no .gitattributes, so line endings are not fixed to LF](#c1-the-repo-has-no-gitattributes-so-line-endings-are-not-fixed-to-lf)
- [ ] [C2: .gitignore does not ignore build archives, debug logs and the Yarn folder the way the template does](#c2-gitignore-does-not-ignore-build-archives-debug-logs-and-the-yarn-folder-the-way-the-template-does)
- [ ] [C3: The repo has no .prettierignore](#c3-the-repo-has-no-prettierignore)
- [ ] [C4: The version-sync script syncVersions.js isn't needed](#c4-the-version-sync-script-syncversionsjs-isnt-needed)
- [ ] [C5: package.json does not declare the Node and Yarn versions it needs](#c5-packagejson-does-not-declare-the-node-and-yarn-versions-it-needs)
- [ ] [C6: package.json has no prettier setting](#c6-packagejson-has-no-prettier-setting)
- [ ] [C7: package.json has no format script](#c7-packagejson-has-no-format-script)
- [ ] [C8: package.json has no package script](#c8-packagejson-has-no-package-script)
- [ ] [C9: prettier is not installed as a devDependency](#c9-prettier-is-not-installed-as-a-devdependency)
- [ ] [C10: The manifest keywords include Companion](#c10-the-manifest-keywords-include-companion)
- [ ] [C11: The module cannot be packaged for release](#c11-the-module-cannot-be-packaged-for-release)
- [ ] [C12: The Stagetimer API key is written to the logs](#c12-the-stagetimer-api-key-is-written-to-the-logs)

---

## 🔴 Critical

### C1: The repo has no .gitattributes, so line endings are not fixed to LF

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** ⚠️ PRE-EXISTING
- **File:** `.gitattributes` (missing)
- **Template:** [API 1 JavaScript template](https://github.com/bitfocus/companion-module-template-js/tree/9e222b4d0b1a68b2acda7d8adb52c9f90ee4c3d1): [`.gitattributes`](https://github.com/bitfocus/companion-module-template-js/blob/9e222b4d0b1a68b2acda7d8adb52c9f90ee4c3d1/.gitattributes)

**What goes wrong:** No direct user-visible effect. Without this file, a contributor on Windows can commit files with Windows (CRLF) line endings, which then show up as whole-file diffs and can end up in the packaged module.

**Why it happens:** The template ships a one-line `.gitattributes` that tells git to store every text file with Unix (LF) line endings. The module never added it.

**Evidence:**

```text
expected: .gitattributes (tracked by the template)
found:    no .gitattributes in the module
```

**Confirm by:** list the repo root at v2.7.0. There is no `.gitattributes`.

**Fix:** add `.gitattributes` from the template.

```text
* text=auto eol=lf
```

### C2: .gitignore does not ignore build archives, debug logs and the Yarn folder the way the template does

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** ⚠️ PRE-EXISTING
- **File:** [`.gitignore:1-14`](https://github.com/bitfocus/companion-module-stagetimerio-api/blob/8a95d1f25808f8792beaeaad8f3f4c031c67ed2e/.gitignore#L1-L14)
- **Template:** [API 1 JavaScript template](https://github.com/bitfocus/companion-module-template-js/tree/9e222b4d0b1a68b2acda7d8adb52c9f90ee4c3d1): [`.gitignore`](https://github.com/bitfocus/companion-module-template-js/blob/9e222b4d0b1a68b2acda7d8adb52c9f90ee4c3d1/.gitignore)

**What goes wrong:** No direct user-visible effect. Package archives other than `pkg.tgz`, and `DEBUG-*` log files, aren't ignored, so they can be committed by accident.

**Why it happens:** The module ignores only `/pkg.tgz` rather than every `.tgz` at the root, has no `DEBUG-*` entry, and writes the Yarn folder as `.yarn/` where the template uses `/.yarn`.

**Evidence:**

```text
expected (template): /*.tgz, DEBUG-*, /.yarn
found (module):      /pkg.tgz, .yarn/ ; no DEBUG-* entry
```

**Confirm by:** open [`.gitignore:5-10`](https://github.com/bitfocus/companion-module-stagetimerio-api/blob/8a95d1f25808f8792beaeaad8f3f4c031c67ed2e/.gitignore#L5-L10).

**Fix:** align the file with the template. Extra entries such as `.DS_Store` and `.claude/` can stay.

```text
node_modules/
package-lock.json
/pkg
/*.tgz
DEBUG-*
/.yarn
```

### C3: The repo has no .prettierignore

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** ⚠️ PRE-EXISTING
- **File:** `.prettierignore` (missing)
- **Template:** [API 1 JavaScript template](https://github.com/bitfocus/companion-module-template-js/tree/9e222b4d0b1a68b2acda7d8adb52c9f90ee4c3d1): [`.prettierignore`](https://github.com/bitfocus/companion-module-template-js/blob/9e222b4d0b1a68b2acda7d8adb52c9f90ee4c3d1/.prettierignore)

**What goes wrong:** No direct user-visible effect. Once the `format` script exists (C7), running it would also reformat `package.json` and the licence file, which the template leaves alone.

**Why it happens:** The template ships a `.prettierignore` that keeps the code formatter (Prettier) away from those two files. The module never added it.

**Evidence:**

```text
expected: .prettierignore (tracked by the template)
found:    no .prettierignore in the module
```

**Confirm by:** list the repo root at v2.7.0. There is no `.prettierignore`.

**Fix:** add `.prettierignore` from the template.

```text
package.json
/LICENSE.md
```

### C4: The version-sync script syncVersions.js isn't needed

- **Source:** 🤖 validate-template (SRC-AT-ROOT)
- **Classification:** ⚠️ PRE-EXISTING
- **File:** [`syncVersions.js:1-9`](https://github.com/bitfocus/companion-module-stagetimerio-api/blob/8a95d1f25808f8792beaeaad8f3f4c031c67ed2e/syncVersions.js#L1-L9), [`package.json:10`](https://github.com/bitfocus/companion-module-stagetimerio-api/blob/8a95d1f25808f8792beaeaad8f3f4c031c67ed2e/package.json#L10), [`companion/manifest.json:6`](https://github.com/bitfocus/companion-module-stagetimerio-api/blob/8a95d1f25808f8792beaeaad8f3f4c031c67ed2e/companion/manifest.json#L6)
- **Template:** [API 1 JavaScript template](https://github.com/bitfocus/companion-module-template-js/tree/9e222b4d0b1a68b2acda7d8adb52c9f90ee4c3d1): [`src/`](https://github.com/bitfocus/companion-module-template-js/tree/9e222b4d0b1a68b2acda7d8adb52c9f90ee4c3d1/src), [`companion/manifest.json`](https://github.com/bitfocus/companion-module-template-js/blob/9e222b4d0b1a68b2acda7d8adb52c9f90ee4c3d1/companion/manifest.json)

**What goes wrong:** No user-visible effect. The module keeps a script at the repository root, outside `src/` where the template keeps all source, only to copy the `package.json` version into `companion/manifest.json`. That copy isn't needed: Companion's release process writes the version into the manifest automatically when the module is built.

**Why it happens:** The `version` script runs `node syncVersions.js && git add .`, and the script rewrites the manifest's `version` line with `sed`.

**Evidence:**

```js
// syncVersions.js:3, 9
const version = process.env.npm_package_version
exec(`sed -i '' 's/"version": .*$/"version": "${version}",/' companion/manifest.json`)
```

```json
// package.json:10
    "version": "node syncVersions.js && git add ."
```

**Confirm by:** open [`package.json:10`](https://github.com/bitfocus/companion-module-stagetimerio-api/blob/8a95d1f25808f8792beaeaad8f3f4c031c67ed2e/package.json#L10) and [`syncVersions.js`](https://github.com/bitfocus/companion-module-stagetimerio-api/blob/8a95d1f25808f8792beaeaad8f3f4c031c67ed2e/syncVersions.js).

**Fix:** delete `syncVersions.js` and the `version` script from `package.json`, and set the manifest's `version` back to the template's placeholder, `"0.0.0"`. The release build fills in the real version.

### C5: package.json does not declare the Node and Yarn versions it needs

- **Source:** 🤖 validate-template (PKG-FIELD)
- **Classification:** ⚠️ PRE-EXISTING
- **File:** [`package.json:1-27`](https://github.com/bitfocus/companion-module-stagetimerio-api/blob/8a95d1f25808f8792beaeaad8f3f4c031c67ed2e/package.json#L1-L27)
- **Template:** [API 1 JavaScript template](https://github.com/bitfocus/companion-module-template-js/tree/9e222b4d0b1a68b2acda7d8adb52c9f90ee4c3d1): [`package.json`](https://github.com/bitfocus/companion-module-template-js/blob/9e222b4d0b1a68b2acda7d8adb52c9f90ee4c3d1/package.json)

**What goes wrong:** No user-visible effect. A developer building with an unsupported Node or Yarn version gets no warning.

**Why it happens:** The template's `package.json` has an `engines` field that names the supported Node and Yarn versions. The module's doesn't.

**Evidence:**

```text
expected: "engines" field (present in template)
found:    no "engines" field
```

**Confirm by:** open [`package.json:1-27`](https://github.com/bitfocus/companion-module-stagetimerio-api/blob/8a95d1f25808f8792beaeaad8f3f4c031c67ed2e/package.json#L1-L27). There is no `engines` key.

**Fix:** add the template's `engines` field.

```json
"engines": {
  "node": "^22.20",
  "yarn": "^4"
}
```

### C6: package.json has no prettier setting

- **Source:** 🤖 validate-template (PKG-FIELD)
- **Classification:** ⚠️ PRE-EXISTING
- **File:** [`package.json:1-27`](https://github.com/bitfocus/companion-module-stagetimerio-api/blob/8a95d1f25808f8792beaeaad8f3f4c031c67ed2e/package.json#L1-L27)
- **Template:** [API 1 JavaScript template](https://github.com/bitfocus/companion-module-template-js/tree/9e222b4d0b1a68b2acda7d8adb52c9f90ee4c3d1): [`package.json`](https://github.com/bitfocus/companion-module-template-js/blob/9e222b4d0b1a68b2acda7d8adb52c9f90ee4c3d1/package.json)

**What goes wrong:** No user-visible effect. Without it, the code formatter doesn't use the shared Companion formatting rules.

**Why it happens:** The template's `package.json` points Prettier at the shared config from `@companion-module/tools`. The module's has no `prettier` key.

**Evidence:**

```text
expected: "prettier": "@companion-module/tools/.prettierrc.json"
found:    no "prettier" field
```

**Confirm by:** open [`package.json:1-27`](https://github.com/bitfocus/companion-module-stagetimerio-api/blob/8a95d1f25808f8792beaeaad8f3f4c031c67ed2e/package.json#L1-L27). There is no `prettier` key.

**Fix:** add the shared Prettier config.

```json
"prettier": "@companion-module/tools/.prettierrc.json"
```

### C7: package.json has no format script

- **Source:** 🤖 validate-template (PKG-SCRIPT)
- **Classification:** ⚠️ PRE-EXISTING
- **File:** [`package.json:7-11`](https://github.com/bitfocus/companion-module-stagetimerio-api/blob/8a95d1f25808f8792beaeaad8f3f4c031c67ed2e/package.json#L7-L11)
- **Template:** [API 1 JavaScript template](https://github.com/bitfocus/companion-module-template-js/tree/9e222b4d0b1a68b2acda7d8adb52c9f90ee4c3d1): [`package.json`](https://github.com/bitfocus/companion-module-template-js/blob/9e222b4d0b1a68b2acda7d8adb52c9f90ee4c3d1/package.json)

**What goes wrong:** No user-visible effect. `yarn format`, the template's way to format the code, doesn't exist.

**Why it happens:** The `scripts` block has `lint`, `test` and `version`, but not the template's `format`.

**Evidence:**

```text
expected: "format": "prettier -w ."
found:    scripts = lint, test, version
```

**Confirm by:** open [`package.json:7-11`](https://github.com/bitfocus/companion-module-stagetimerio-api/blob/8a95d1f25808f8792beaeaad8f3f4c031c67ed2e/package.json#L7-L11).

**Fix:** add the script.

```json
"format": "prettier -w ."
```

### C8: package.json has no package script

- **Source:** 🤖 validate-template (PKG-SCRIPT)
- **Classification:** ⚠️ PRE-EXISTING
- **File:** [`package.json:7-11`](https://github.com/bitfocus/companion-module-stagetimerio-api/blob/8a95d1f25808f8792beaeaad8f3f4c031c67ed2e/package.json#L7-L11)
- **Template:** [API 1 JavaScript template](https://github.com/bitfocus/companion-module-template-js/tree/9e222b4d0b1a68b2acda7d8adb52c9f90ee4c3d1): [`package.json`](https://github.com/bitfocus/companion-module-template-js/blob/9e222b4d0b1a68b2acda7d8adb52c9f90ee4c3d1/package.json)

**What goes wrong:** `yarn package`, the command that builds the module archive Companion installs, doesn't exist, so the release can't be packaged (see C11).

**Why it happens:** The template's `package` script runs `companion-module-build` from `@companion-module/tools`. The module has that tool installed but no script that calls it.

**Evidence:**

```text
expected: "package": "companion-module-build"
found:    scripts = lint, test, version
```

**Confirm by:** open [`package.json:7-11`](https://github.com/bitfocus/companion-module-stagetimerio-api/blob/8a95d1f25808f8792beaeaad8f3f4c031c67ed2e/package.json#L7-L11).

**Fix:** add the script.

```json
"package": "companion-module-build"
```

### C9: prettier is not installed as a devDependency

- **Source:** 🤖 validate-template (PKG-DEVDEP)
- **Classification:** ⚠️ PRE-EXISTING
- **File:** [`package.json:22-25`](https://github.com/bitfocus/companion-module-stagetimerio-api/blob/8a95d1f25808f8792beaeaad8f3f4c031c67ed2e/package.json#L22-L25)
- **Template:** [API 1 JavaScript template](https://github.com/bitfocus/companion-module-template-js/tree/9e222b4d0b1a68b2acda7d8adb52c9f90ee4c3d1): [`package.json`](https://github.com/bitfocus/companion-module-template-js/blob/9e222b4d0b1a68b2acda7d8adb52c9f90ee4c3d1/package.json)

**What goes wrong:** No user-visible effect. The `format` script (C7) would fail because Prettier isn't installed.

**Why it happens:** The template lists `prettier` as a development dependency. The module lists only `@companion-module/tools` and `eslint`.

**Evidence:**

```text
expected: devDependency "prettier" (template: ^3.7.4)
found:    devDependencies = @companion-module/tools, eslint
```

**Confirm by:** open [`package.json:22-25`](https://github.com/bitfocus/companion-module-stagetimerio-api/blob/8a95d1f25808f8792beaeaad8f3f4c031c67ed2e/package.json#L22-L25).

**Fix:** install Prettier as a dev dependency.

```bash
yarn add -D prettier
```

### C10: The manifest keywords include Companion

- **Source:** 🤖 validate-template (MAN-KEYWORD)
- **Classification:** ⚠️ PRE-EXISTING
- **File:** [`companion/manifest.json:29-34`](https://github.com/bitfocus/companion-module-stagetimerio-api/blob/8a95d1f25808f8792beaeaad8f3f4c031c67ed2e/companion/manifest.json#L29-L34)
- **Template:** [API 1 JavaScript template](https://github.com/bitfocus/companion-module-template-js/tree/9e222b4d0b1a68b2acda7d8adb52c9f90ee4c3d1): [`companion/manifest.json`](https://github.com/bitfocus/companion-module-template-js/blob/9e222b4d0b1a68b2acda7d8adb52c9f90ee4c3d1/companion/manifest.json)

**What goes wrong:** Searching for "Companion" in Companion's connection list matches every module, so the keyword adds nothing for users looking for this one.

**Why it happens:** The keyword list is `Stagetimer`, `stagetimer.io`, `Timer`, `Companion`. `Companion` is on the banned keyword list; the other three are fine.

**Evidence:**

```json
// companion/manifest.json:29-34
"keywords": [
  "Stagetimer",
  "stagetimer.io",
  "Timer",
  "Companion"
]
```

**Confirm by:** open [`companion/manifest.json:29-34`](https://github.com/bitfocus/companion-module-stagetimerio-api/blob/8a95d1f25808f8792beaeaad8f3f4c031c67ed2e/companion/manifest.json#L29-L34).

**Fix:** remove `Companion` from `keywords`.

### C11: The module cannot be packaged for release

- **Source:** 🤖 validate-template (BUILD-PACKAGE)
- **Classification:** ⚠️ PRE-EXISTING
- **File:** [`package.json:7-11`](https://github.com/bitfocus/companion-module-stagetimerio-api/blob/8a95d1f25808f8792beaeaad8f3f4c031c67ed2e/package.json#L7-L11)
- **Template:** [API 1 JavaScript template](https://github.com/bitfocus/companion-module-template-js/tree/9e222b4d0b1a68b2acda7d8adb52c9f90ee4c3d1): [`package.json`](https://github.com/bitfocus/companion-module-template-js/blob/9e222b4d0b1a68b2acda7d8adb52c9f90ee4c3d1/package.json)

**What goes wrong:** The build step that produces the module archive Companion installs fails, so this release can't be packaged as it stands.

**Why it happens:** `yarn install` succeeds, but `yarn package` stops straight away because there is no `package` script (C8).

**Evidence:**

```text
validate-template -RunBuild:
  yarn install  -> ok
  yarn package  -> failed (package.json has no "package" script)
```

**Confirm by:** run `yarn package` in a clean checkout of v2.7.0.

**Fix:** add the `package` script from C8, then confirm `yarn package` produces a `.tgz`.

### C12: The Stagetimer API key is written to the logs

- **Source:** 🧑 review maintainer
- **Classification:** ⚠️ PRE-EXISTING (added in `8dce22e`, 2026-03-07)
- **File:** [`src/api.js:54-65`](https://github.com/bitfocus/companion-module-stagetimerio-api/blob/8a95d1f25808f8792beaeaad8f3f4c031c67ed2e/src/api.js#L54-L65), [`src/socket.js:64`](https://github.com/bitfocus/companion-module-stagetimerio-api/blob/8a95d1f25808f8792beaeaad8f3f4c031c67ed2e/src/socket.js#L64)

**What goes wrong:** The room's **API Key** ends up in the logs. Every action writes the full request URL, including the `api_key`, and every connect writes the socket's auth details, including the key. Anyone who can see the logs, or a log file or debug export someone shares when asking for help, gets a key that controls the user's Stagetimer room. API keys must never be logged.

**Why it happens:** two debug lines added in `8dce22e` ("add connection debug logging") print the values that carry the key.

**Evidence:**

```js
// src/api.js:54-65
      const params = {
        room_id: this.roomId,
        api_key: this.apiKey,
        ...queryParams,
      }
      ...
      const url = `${this.apiUrl}${path}${query}`
      console.info('[API] Request URL:', url)
```

```js
// src/socket.js:64
  console.info('[Socket] Auth:', JSON.stringify({ room_id: roomId, api_key: apiKey }))
```

**Confirm by:** search `src/` for `console.info`: [`src/api.js:65`](https://github.com/bitfocus/companion-module-stagetimerio-api/blob/8a95d1f25808f8792beaeaad8f3f4c031c67ed2e/src/api.js#L65) logs the URL built with `api_key`, and [`src/socket.js:64`](https://github.com/bitfocus/companion-module-stagetimerio-api/blob/8a95d1f25808f8792beaeaad8f3f4c031c67ed2e/src/socket.js#L64) logs `api_key` directly.

**Fix:** never log the key. Log the request path without the query string (or with `api_key` replaced by `***`), and drop `api_key` from the socket log line.
