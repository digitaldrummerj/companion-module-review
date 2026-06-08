# Review: novastar-switcher v3.0.0

| | |
|---|---|
| **Module** | companion-module-novastar-switcher |
| **Review tag** | v3.0.0 |
| **Previous tag** | v2.1.0 |
| **Scope** | `tag` (only this release's changes) |
| **Language / API** | TypeScript / @companion-module/base v1.x (^1.12.1) |
| **Protocols** | HTTP + WebSocket |
| **Reviewed** | 2026-06-07 |

> **Scope note:** v3.0.0 is a complete rewrite (old JavaScript → new TypeScript). The `v2.1.0..v3.0.0` diff replaces the entire codebase, so the whole current `src/` is the review surface and **every finding is classified 🆕 NEW**.

## Verdict: ❌ Changes Required

## 📋 Issues

**Blocking**

- [ ] [C1: manifest runtime.entrypoint points to src instead of dist](#c1-manifest-runtimeentrypoint-points-to-src-instead-of-dist)
- [ ] [C2: manifest runtime.type is node18, should be node22](#c2-manifest-runtimetype-is-node18-should-be-node22)
- [ ] [C3: placeholder maintainer in manifest](#c3-placeholder-maintainer-in-manifest)
- [ ] [C4: banned low-value keyword NovaStar in manifest](#c4-banned-low-value-keyword-novastar-in-manifest)
- [ ] [C5: required file .gitattributes missing](#c5-required-file-gitattributes-missing)
- [ ] [C6: required file .husky/pre-commit missing](#c6-required-file-huskypre-commit-missing)
- [ ] [C7: .gitignore missing template entries](#c7-gitignore-missing-template-entries)
- [ ] [C8: tsconfig.json differs from template](#c8-tsconfigjson-differs-from-template)
- [ ] [C9: tsconfig.build.json targets node18 not node22](#c9-tsconfigbuildjson-targets-node18-not-node22)
- [ ] [C10: .yarn/install-state.gz committed but gitignored](#c10-yarninstall-stategz-committed-but-gitignored)

**Non-blocking**

- [ ] [M2: updatePresets rebuilt twice per presetNamesChanged](#m2-updatepresets-rebuilt-twice-per-presetnameschanged)
- [ ] [L2: terminate() used instead of graceful close()](#l2-terminate-used-instead-of-graceful-close)
- [ ] [L4: leftover console.log debug calls in production paths](#l4-leftover-consolelog-debug-calls-in-production-paths)
- [ ] [L5: info-level logging on every feedback evaluation and WS message](#l5-info-level-logging-on-every-feedback-evaluation-and-ws-message)
- [ ] [L6: parseInt without NaN guard sends NaN to the device](#l6-parseint-without-nan-guard-sends-nan-to-the-device)
- [ ] [N4: stray @types/jest devDependency with no Jest](#n4-stray-typesjest-devdependency-with-no-jest)

---

## 🔴 Critical

### C1: manifest runtime.entrypoint points to src instead of dist

**Classification:** 🆕 NEW
`companion/manifest.json` — `runtime.entrypoint` is `../src/main.js` but for a TypeScript module it must be `../dist/main.js` (the compiled output). As shipped, Companion will try to load uncompiled source. *Fix:* set `runtime.entrypoint` to `../dist/main.js`.

### C2: manifest runtime.type is node18, should be node22

**Classification:** 🆕 NEW
`companion/manifest.json` — `runtime.type` is `node18`. The current template/base targets `node22` (and this module's own `package.json` engines requires `node ^22.14`). *Fix:* set `runtime.type` to `node22`.

### C3: placeholder maintainer in manifest

**Classification:** 🆕 NEW
`companion/manifest.json` — maintainer is a placeholder: `name='NovaStar'`, `email=''`. A real maintainer name is required. *Fix:* populate `maintainer`/`author` with a real name and email/github user name.

### C4: banned low-value keyword NovaStar in manifest

**Classification:** 🆕 NEW
`companion/manifest.json` — `keywords` contains the banned/low-value keyword `NovaStar` (the manufacturer name duplicates the product and adds no search value). *Fix:* remove `NovaStar` from `keywords`; use functional keywords (e.g. `video`, `switcher`, `led`).

### C5: required file .gitattributes missing

**Classification:** 🆕 NEW
`.gitattributes` — required template file is missing. *Fix:* copy the template's `.gitattributes` into the repo root.

### C6: required file .husky/pre-commit missing

**Classification:** 🆕 NEW
`.husky/pre-commit` — required template file is missing. *Fix:* add the husky `pre-commit` hook (running `lint-staged`) from the template.

### C7: .gitignore missing template entries

**Classification:** 🆕 NEW
`.gitignore` — missing template entries: `/*.tgz`, `/dist`, `DEBUG-*`, `/.yarn`, `/.vscode`. *Fix:* add the missing entries to match the template `.gitignore`. 

### C8: tsconfig.json differs from template

**Classification:** 🆕 NEW
`tsconfig.json` (line 6) — found `"types": ["jest", "node"]`, template is `"types": ["node" /* , "jest" ] // uncomment this if using jest */]`. The module declares `jest` types but ships no Jest. *Fix:* restore the template `types` value (or genuinely adopt Jest — see N4).

### C9: tsconfig.build.json targets node18 not node22

**Classification:** 🆕 NEW
`tsconfig.build.json` (line 2) — extends `@companion-module/tools/tsconfig/node18/recommended`, template uses `.../node22/recommended`. *Fix:* extend the `node22` recommended config.

### C10: .yarn/install-state.gz committed but gitignored

**Classification:** 🆕 NEW
`.yarn/install-state.gz` — committed to the repo even though the template `.gitignore` excludes `/.yarn`. *Fix:* remove `.yarn/install-state.gz` from version control and add the `/.yarn` ignore entry (see C7).

## 🟡 Medium

### M2: updatePresets rebuilt twice per presetNamesChanged

**Classification:** 🆕 NEW
`src/services/WebSocketHandling.ts:148-162` — `self.updatePresets()` is called at line 159 and again at line 161 (duplicate full preset-definition rebuild per message). Line 152 also uses `find(...)!` immediately followed by an `if (!newPreset) return` guard, so the non-null assertion contradicts the check. *Fix:* remove the duplicate `updatePresets()`; drop the `!`.

## 🟢 Low

### L2: terminate() used instead of graceful close()

**Classification:** 🆕 NEW
`src/services/WebSocketClient.ts:50-52` — `terminate()` is used unconditionally even on normal `destroy()`/reconfigure, hard-aborting the socket. Harmless for cleanup, but `close()` would let the server end the session cleanly. *Fix:* prefer `close()` for graceful teardown.

### L4: leftover console.log debug calls in production paths

**Classification:** 🆕 NEW
`src/actions.ts:174` (`console.log(result)`), `src/actions.ts:634` (`console.log(umd)`), `src/services/ApiClient.ts:201` (`console.log('debug', \`FTB Body...\`)` — also a misuse, `'debug'` is passed as the first console.log arg). These bypass Companion's logger. *Fix:* remove or convert to `self.log('debug', ...)`.

### L5: info-level logging on every feedback evaluation and WS message

**Classification:** 🆕 NEW
`src/feedbacks.ts:380-383` logs at `info` on every `sourceSignalState` evaluation (every `checkFeedbacks`, every button), and `src/services/WebSocketClient.ts:70` logs every matched message at `info` — high-volume log spam. *Fix:* demote to `debug` or remove.

### L6: parseInt without NaN guard sends NaN to the device

**Classification:** 🆕 NEW
`src/actions.ts:571-574` (`changeLayerBounds` x/y/width/height) and the `take` family time parsing (`parseInt(parsedTime)` at 57/104/160) parse without a NaN check, so empty/invalid input sends `{x: NaN, ...}` or `NaN` time. (`setEffectTime` and `getLayerBySelection` guard correctly.) *Fix:* validate with `Number.isNaN` and fall back to a sane default before sending.

## 💡 Nice to Have

### N4: stray @types/jest devDependency with no Jest

**Classification:** 🆕 NEW
`package.json` lists `@types/jest` (and `tsconfig.json` references `jest` types — see C8) but there is no Jest runtime, config, or test files. Harmless but misleading. *Fix:* remove `@types/jest` (and revert the `tsconfig.json` `types` change), or genuinely adopt Jest with tests.
