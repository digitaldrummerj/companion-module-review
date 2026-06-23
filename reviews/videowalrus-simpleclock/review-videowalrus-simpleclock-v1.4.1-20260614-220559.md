# Review: videowalrus-simpleclock v1.4.1

| | |
|---|---|
| **Module** | videowalrus-simpleclock |
| **Version** | v1.4.1 |
| **Scope** | tag |
| **Language / API** | JS / @companion-module/base v1.x (~1.14.1) |
| **Protocols** | WebSocket |
| **Reviewed** | 2026-06-14 |

> **First release** — no `previousTag` exists, so there is no `previousTag..reviewTag` diff. Per the review policy this `tag`-scope review falls back to a full review of the current `src/`; all findings are treated as 🆕 NEW.

## Verdict: ❌ Changes Required

## 📋 Issues

**Blocking**

- [ ] [C1: LICENSE file missing](#c1-license-file-missing)
- [ ] [C2: .gitattributes missing](#c2-gitattributes-missing)
- [ ] [C3: .prettierignore missing](#c3-prettierignore-missing)
- [ ] [C4: .yarnrc.yml missing](#c4-yarnrcyml-missing)
- [ ] [C5: .gitignore missing required template entries](#c5-gitignore-missing-required-template-entries)
- [ ] [C6: package.json missing prettier config field](#c6-packagejson-missing-prettier-config-field)
- [ ] [C7: package.json missing packageManager field](#c7-packagejson-missing-packagemanager-field)
- [ ] [C8: package.json missing format script](#c8-packagejson-missing-format-script)
- [ ] [C9: package.json missing prettier devDependency](#c9-packagejson-missing-prettier-devdependency)
- [ ] [C11: manifest runtime type node18 should be node22](#c11-manifest-runtime-type-node18-should-be-node22)
- [ ] [C12: Action definitions rebuilt on every inbound state message](#c12-action-definitions-rebuilt-on-every-inbound-state-message)

## 🔴 Critical

### C1: LICENSE file missing

**File:** `LICENSE`

The required `LICENSE` file is missing. The manifest and package.json both declare `MIT`, but the official template ships a `LICENSE` file at the repo root and it is required for release.

**Fix:** Add an MIT `LICENSE` file at the repo root (copy from the official template, update the copyright holder to Video Walrus Ltd).

### C2: .gitattributes missing

**File:** `.gitattributes`

Required template file `.gitattributes` is missing.

**Fix:** Copy `.gitattributes` from `companion-module-template-js-v1`.

### C3: .prettierignore missing

**File:** `.prettierignore`

Required template file `.prettierignore` is missing.

**Fix:** Copy `.prettierignore` from the official template.

### C4: .yarnrc.yml missing

**File:** `.yarnrc.yml`

Required template file `.yarnrc.yml` is missing. The template uses Yarn 4 / Corepack; this file is required for the documented toolchain.

**Fix:** Copy `.yarnrc.yml` from the official template and adopt the template's Yarn 4 setup.

### C5: .gitignore missing required template entries

**File:** `.gitignore`

The committed `.gitignore` is missing template entries: `package-lock.json`, `/pkg`, `/*.tgz`, `DEBUG-*`, `/.yarn`.

**Fix:** Add the missing entries so build artifacts, debug dumps, and the Yarn cache are not committed.

### C6: package.json missing prettier config field

**File:** `package.json`

The required `prettier` config field (present in the template) is absent.

**Fix:** Add the template's `prettier` configuration block to `package.json`.

### C7: package.json missing packageManager field

**File:** `package.json`

The required `packageManager` field (present in the template, e.g. `yarn@4.x`) is absent. Corepack relies on this to pin the toolchain.

**Fix:** Add the `packageManager` field matching the template.

### C8: package.json missing format script

**File:** `package.json`

The required `format` script is missing. The module currently defines only a `package` script.

**Fix:** Add the template's `format` script (`prettier --write .`) and the other expected scripts.

### C9: package.json missing prettier devDependency

**File:** `package.json`

The `prettier` devDependency (present in the template) is missing — required for the `format` script.

**Fix:** Add `prettier` to `devDependencies` at the template's version.

### C11: manifest runtime type node18 should be node22

**File:** `companion/manifest.json:17`

`runtime.type` is `node18`; the current template targets `node22`. There is no reason to ship a brand-new release on the older runtime, and `package.json` `engines` already allows `^22.8`.

**Fix:** Change `"type": "node18"` to `"type": "node22"`.

### C12: action definitions rebuilt on every inbound state message

**File:** `src/main.js:98`

`setActionDefinitions(getActions(this))` runs inside the `'message'` handler on every inbound state message. For a running clock these arrive ~once per second, so the full action/choice set is reallocated and re-registered with Companion every tick. The speaker/message dropdown labels only change when the `speakers`/`messages` lists change, not every tick — this is needless churn and UI re-registration overhead in the action editor.

**Fix:** Rebuild action definitions only when `state.speakers` or `state.messages` actually change (shallow-compare or hash the prior vs. new lists before calling `setActionDefinitions`).
