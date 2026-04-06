# Module Review: companion-module-optisigns-digitalsignage v1.0.3

| Field | Value |
|-------|-------|
| **Module** | `companion-module-optisigns-digitalsignage` |
| **Version** | 1.0.3 |
| **Release type** | First release (no previous approved tag) |
| **API version** | v1.14 (`@companion-module/base ~1.14.1`) |
| **Language** | JavaScript |
| **Protocol** | GraphQL over HTTPS (`fetch()`) |
| **Date** | 2026-04-05 |
| **Review team** | Mal (Lead), Wash (Protocol), Kaylee (Template/Build), Zoe (QA), Simon (Tests) |

---

## Fix Summary for Maintainer

**17 blocking issues must be resolved before approval.** Most are template compliance fixes — straightforward file additions and `package.json`/`manifest.json` field corrections.

1. **C1:** Add `.gitattributes` with content: `* text=auto eol=lf`
2. **C2:** Add `.prettierignore` with content: `package.json` + `/LICENSE.md`
3. **C3:** Rename `build` script → `package` in `package.json`
4. **C4:** Add `"format": "prettier -w ."` script to `package.json`
5. **C5:** Add `"prettier": "@companion-module/tools/.prettierrc.json"` to `package.json`
6. **C6:** Add `prettier` to `devDependencies` in `package.json`
7. **C7:** Add `"repository": { "type": "git", "url": "git+https://github.com/bitfocus/companion-module-optisigns-digitalsignage.git" }` to `package.json`
8. **C8:** Change `manifest.json` `"name"` from `"OptiSigns"` → `"optisigns-digitalsignage"` (must match `id`)
9. **C9:** Change `manifest.json` `"repository"` to `"git+https://github.com/bitfocus/companion-module-optisigns-digitalsignage.git"`
10. **C10:** Remove `"optisigns"` from `manifest.json` `keywords`
11. **C11:** Update `.gitignore` to match JS template exactly (see C11 details below)
12. **H1:** Add `signal: AbortSignal.timeout(30_000)` to `fetch()` in `src/api.js` line 6
13. **M1:** Change `api_key` config field type from `'textinput'` → `'secret-text'` in `src/main.js` line 59
14. **M2:** Replace `Promise.all` with `Promise.allSettled` in `src/main.js` line 84, handle partial failures
15. **M3:** Fix `sanitizeKey()` in `src/variables.js` line 52 to avoid variable ID collisions (e.g., append device ID suffix)
16. **M4:** Fix `HELP.md` to say "every 5 minutes" (not "30 seconds") or change `poll_interval` default to 30
17. **N1:** Remove `keywords` field from `package.json`

---

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 11 | 0 | 11 |
| 🟠 High | 1 | 0 | 1 |
| 🟡 Medium | 5 | 0 | 5 |
| 🟢 Low | 6 | 0 | 6 |
| 💡 Nice to Have | 2 | 0 | 2 |
| **Total** | **25** | **0** | **25** |

**Blocking:** 17 issues (11 critical, 1 high, 5 medium — all new)
**Fix complexity:** Medium — 11 template/config fixes (one-liners), 1 one-liner fetch timeout, 5 small code/config changes
**Health delta:** 25 introduced · 0 pre-existing (first release)

---

## Verdict

**❌ Changes Required** — 17 blocking issues. The module's architecture and application logic are solid, but template compliance violations and one operational risk (no fetch timeout) must be resolved.

---

## 📋 Issues

**Blocking**
- [ ] [C1: Missing `.gitattributes`](#c1-missing-gitattributes)
- [ ] [C2: Missing `.prettierignore`](#c2-missing-prettierignore)
- [ ] [C3: Missing `package` script in `package.json`](#c3-missing-package-script-in-packagejson)
- [ ] [C4: Missing `format` script in `package.json`](#c4-missing-format-script-in-packagejson)
- [ ] [C5: Missing `prettier` field in `package.json`](#c5-missing-prettier-field-in-packagejson)
- [ ] [C6: Missing `prettier` devDependency](#c6-missing-prettier-devdependency)
- [ ] [C7: Missing `repository` field in `package.json`](#c7-missing-repository-field-in-packagejson)
- [ ] [C8: `manifest.json` `name` does not match `id`](#c8-manifestjson-name-does-not-match-id)
- [ ] [C9: `manifest.json` `repository` URL wrong format](#c9-manifestjson-repository-url-wrong-format)
- [ ] [C10: Product/manufacturer name in `manifest.json` keywords](#c10-productmanufacturer-name-in-manifestjson-keywords)
- [ ] [C11: `.gitignore` deviates from JS template](#c11-gitignore-deviates-from-js-template)
- [ ] [H1: No request timeout on `fetch()` calls](#h1-no-request-timeout-on-fetch-calls)
- [ ] [M1: API key config field should use `secret-text`](#m1-api-key-config-field-should-use-secret-text)
- [ ] [M2: `Promise.all` coupling causes full-refresh failure on single-endpoint error](#m2-promiseall-coupling-causes-full-refresh-failure-on-single-endpoint-error)
- [ ] [M3: `sanitizeKey()` collision silently corrupts device variables](#m3-sanitizekey-collision-silently-corrupts-device-variables)
- [ ] [M4: Poll interval default contradicts HELP.md documentation](#m4-poll-interval-default-contradicts-helpmd-documentation)
- [ ] [N1: `keywords` field not permitted in `package.json`](#n1-keywords-field-not-permitted-in-packagejson)

**Non-blocking**
- [ ] [L1: No action/feedback definitions if initial `refreshData()` fails](#l1-no-actionfeedback-definitions-if-initial-refreshdata-fails)
- [ ] [L2: Dead `.catch()` on poll timer callback](#l2-dead-catch-on-poll-timer-callback)
- [ ] [L3: `_listSignature()` misses renames; stale dropdown labels](#l3-_listsignature-misses-renames-stale-dropdown-labels)
- [ ] [L4: Optimistic cache update targets orphaned object after concurrent poll](#l4-optimistic-cache-update-targets-orphaned-object-after-concurrent-poll)
- [ ] [L5: `err.message` undefined for non-Error rejections](#l5-errmessage-undefined-for-non-error-rejections)
- [ ] [L6: Concurrent `configUpdated()` calls race on shared state](#l6-concurrent-configupdated-calls-race-on-shared-state)
- [ ] [N2: `manifest.json` version should be `0.0.0`](#n2-manifestjson-version-should-be-000)
- [ ] [N3: Several action options missing `tooltip`](#n3-several-action-options-missing-tooltip)

---

## 🔴 Critical

### C1: Missing `.gitattributes`

**Classification:** 🆕 NEW
**File:** `.gitattributes` (missing)
**Reviewer:** Kaylee

Required for all JS modules. Must contain exactly:
```
* text=auto eol=lf
```

---

### C2: Missing `.prettierignore`

**Classification:** 🆕 NEW
**File:** `.prettierignore` (missing)
**Reviewer:** Kaylee

Required for all JS modules. Must contain:
```
package.json
/LICENSE.md
```

---

### C3: Missing `package` script in `package.json`

**Classification:** 🆕 NEW
**File:** `package.json`, line 7
**Reviewer:** Kaylee

The `package` script is always required for Companion modules. The module has a `build` script that runs `companion-module-build` — correct behavior but wrong name. CI/CD that calls `yarn package` will fail.

Template expects:
```json
"scripts": {
  "package": "companion-module-build",
  "format": "prettier -w ."
}
```
Found:
```json
"scripts": {
  "build": "companion-module-build",
  "dev": "companion-module-build --watch"
}
```

---

### C4: Missing `format` script in `package.json`

**Classification:** 🆕 NEW
**File:** `package.json`, line 7
**Reviewer:** Kaylee

JS modules require: `"format": "prettier -w ."`

---

### C5: Missing `prettier` field in `package.json`

**Classification:** 🆕 NEW
**File:** `package.json` (top-level field missing)
**Reviewer:** Kaylee

Template expects:
```json
"prettier": "@companion-module/tools/.prettierrc.json"
```
Found: field absent entirely.

---

### C6: Missing `prettier` devDependency

**Classification:** 🆕 NEW
**File:** `package.json`, `devDependencies`
**Reviewer:** Kaylee

`prettier` is a required devDependency for JS modules. Only `@companion-module/tools` is present.

---

### C7: Missing `repository` field in `package.json`

**Classification:** 🆕 NEW
**File:** `package.json` (top-level field missing)
**Reviewer:** Kaylee

Template expects:
```json
"repository": {
  "type": "git",
  "url": "git+https://github.com/bitfocus/companion-module-optisigns-digitalsignage.git"
}
```
Found: field absent entirely.

---

### C8: `manifest.json` `name` does not match `id`

**Classification:** 🆕 NEW
**File:** `companion/manifest.json`, lines 3–4
**Reviewer:** Kaylee

Per compliance rules, `name` must equal `id`. The human-readable display name belongs in `shortname` (already set correctly to `"OptiSigns"`).

Found:
```json
"id": "optisigns-digitalsignage",
"name": "OptiSigns"
```
Fix: `"name": "optisigns-digitalsignage"`

---

### C9: `manifest.json` `repository` URL wrong format

**Classification:** 🆕 NEW
**File:** `companion/manifest.json`, line 9
**Reviewer:** Kaylee

Template expects:
```
"repository": "git+https://github.com/bitfocus/companion-module-optisigns-digitalsignage.git"
```
Found:
```
"repository": "https://github.com/bitfocus/companion-module-optisigns-digitalsignage"
```
Missing `git+` prefix and `.git` suffix.

---

### C10: Product/manufacturer name in `manifest.json` keywords

**Classification:** 🆕 NEW
**File:** `companion/manifest.json`, line 26
**Reviewer:** Kaylee

`"optisigns"` is the product/manufacturer name. Module keywords should not include the product or manufacturer name — those are already represented by the `shortname` and `name` fields.

Found: `["digital signage", "optisigns", "screens", "displays"]`
Fix: `["digital signage", "screens", "displays"]`

---

### C11: `.gitignore` deviates from JS template

**Classification:** 🆕 NEW
**File:** `.gitignore`
**Reviewer:** Kaylee

JS template expects:
```
node_modules/
package-lock.json
/pkg
/*.tgz
DEBUG-*
/.yarn
```
Found:
```
node_modules/
pkg/
*.tgz
package-lock.json
.yarn/cache
.yarn/install-state.gz
```

Deviations:
- `pkg/` should be `/pkg` (root-anchored)
- `*.tgz` should be `/*.tgz` (root-anchored)
- `DEBUG-*` is missing
- `/.yarn` replaced with partial `.yarn/cache` and `.yarn/install-state.gz`

---

## 🟠 High

### H1: No request timeout on `fetch()` calls

**Classification:** 🆕 NEW
**File:** `src/api.js`, line 6
**Reviewer:** Wash

`graphqlRequest()` passes no `signal` to `fetch()`. If the OptiSigns API hangs at the TCP level, the fetch never resolves and never rejects. Combined with `setInterval` polling (`src/main.js` line 148), every new poll tick spawns three more stuck Promises. At the minimum configurable poll interval (1 second), pending Promises accumulate at 3/second with no upper bound.

In a live show with an intermittent API outage, this silently builds a growing backlog of hung network requests. Node.js will not clean these up until the OS-level socket timeout fires (typically 2+ minutes).

**Fix:** Add `signal: AbortSignal.timeout(30_000)` to the `fetch()` options:
```js
const response = await fetch(GRAPHQL_ENDPOINT, {
    method: 'POST',
    headers: { ... },
    body: JSON.stringify({ query, variables }),
    signal: AbortSignal.timeout(30_000),
})
```

---

## 🟡 Medium

### M1: API key config field should use `secret-text`

**Classification:** 🆕 NEW
**File:** `src/main.js`, line 59
**Reviewer:** Kaylee

The `api_key` config field uses `type: 'textinput'`. As of v1.13, fields holding API keys and credentials should use `type: 'secret-text'` to protect values in exports and logs.

Found:
```js
{ id: 'api_key', type: 'textinput', label: 'API Key', ... }
```
Fix: `type: 'secret-text'`

---

### M2: `Promise.all` coupling causes full-refresh failure on single-endpoint error

**Classification:** 🆕 NEW
**File:** `src/main.js`, lines 84–88
**Reviewer:** Wash

`Promise.all` short-circuits on the first rejection. A transient error or rate-limit on any single GraphQL endpoint causes the entire refresh to fail — all three results are discarded, `InstanceStatus` flips to `ConnectionFailure`, and cached data goes stale even though the other endpoints may have succeeded.

**Fix:** Use `Promise.allSettled()` and apply results individually:
```js
const [devicesResult, playlistsResult, assetsResult] = await Promise.allSettled([...])
// Apply each fulfilled result, log each rejected one
```

---

### M3: `sanitizeKey()` collision silently corrupts device variables

**Classification:** 🆕 NEW
**File:** `src/variables.js`, lines 52–54
**Reviewer:** Zoe

Any two devices whose names reduce to the same sanitized key collide silently. Examples: `"Screen A"` and `"Screen_A"` both → `screen_a`; `"Lobby 1"` and `"Lobby.1"` both → `lobby_1`.

When this happens, `setVariableDefinitions()` receives duplicate IDs (second overwrites first), and `setVariableValues()` writes both devices' values under the same key. No warning, no log, no indication to the operator.

**Fix:** Append a device ID suffix to avoid collisions:
```js
function sanitizeKey(name, id) {
    const namePart = name.toLowerCase().replace(/[^a-z0-9_]/g, '_')
    return `${namePart}_${id.slice(-6)}`
}
```

---

### M4: Poll interval default contradicts HELP.md documentation

**Classification:** 🆕 NEW
**File:** `src/main.js`, line 69 / `companion/HELP.md`, line 43
**Reviewer:** Kaylee

`poll_interval` defaults to `300` seconds (5 minutes), but `HELP.md` states "Data is polled from OptiSigns every **30 seconds**." One of these is wrong.

Fix: Update HELP.md to say "every **5 minutes** (configurable)" or change the default to `30`.

---

### N1: `keywords` field not permitted in `package.json`

**Classification:** 🆕 NEW
**File:** `package.json`, line 15
**Reviewer:** Kaylee

The `keywords` field should not be present in `package.json` for Companion modules. Remove it entirely.

Found: `"keywords": ["bitfocus", "companion", "optisigns"]`
Fix: Remove the `keywords` field from `package.json`.

---

## 🟢 Low

### L1: No action/feedback definitions if initial `refreshData()` fails

**Classification:** 🆕 NEW
**File:** `src/main.js`, lines 25–36
**Reviewer:** Wash

If the API is unavailable at startup (but `api_key` is set), `refreshData()` catches the error and returns without calling `updateActions()` / `updateFeedbacks()` / `updateVariableDefinitions()`. The module enters `ConnectionFailure` with zero definitions. Users see an empty action list for up to 5 minutes (default poll interval).

Fix: Call the three update methods before `refreshData()` in `init()` to register empty-list definitions.

---

### L2: Dead `.catch()` on poll timer callback

**Classification:** 🆕 NEW
**File:** `src/main.js`, line 149
**Reviewer:** Zoe

`refreshData()` internally catches all errors and returns normally (never rejects). The `.catch()` on line 149 is dead code — it will never fire. This is misleading to future maintainers.

Fix: Remove the `.catch()` or restructure `refreshData()` to propagate errors when appropriate.

---

### L3: `_listSignature()` misses renames; stale dropdown labels

**Classification:** 🆕 NEW
**File:** `src/main.js`, line 164
**Reviewer:** Zoe

The signature is built from `_id` only. Device/playlist/asset renames don't change the signature, so `updateActions()` / `updateFeedbacks()` are never called and dropdown labels show the old name until the item is deleted and recreated.

Fix: Include display name in the signature:
```js
function _listSignature(list) {
    return list.map((item) => `${item._id}:${item.deviceName ?? item.name ?? item.filename}`).sort().join(',')
}
```

---

### L4: Optimistic cache update targets orphaned object after concurrent poll

**Classification:** 🆕 NEW
**File:** `src/actions.js`, lines 55–59, 105–109
**Reviewer:** Zoe

Action callbacks capture a reference to an object in `self.devices` via `.find()`, then `await` the GraphQL mutation. If a poll completes during the await and replaces `self.devices` with a fresh array, the captured reference is orphaned — the optimistic update mutates a detached object. The UI stays stale until the next poll.

Fix: Re-query `self.devices.find()` after the await.

---

### L5: `err.message` undefined for non-Error rejections

**Classification:** 🆕 NEW
**File:** `src/main.js`, lines 97, 149; `src/actions.js`, lines 64, 114, 164, 206, 258
**Reviewer:** Zoe

All catch blocks use `err.message`. If a rejection is a plain string, `null`, or a non-Error object, `.message` is `undefined` and the log reads `"… failed: undefined"`.

Fix: `self.log('error', \`… failed: ${err?.message ?? String(err)}\`)`

---

### L6: Concurrent `configUpdated()` calls race on shared state

**Classification:** 🆕 NEW
**File:** `src/main.js`, lines 42–54
**Reviewer:** Zoe

`configUpdated()` is async and awaits `refreshData()`. If config is saved twice in quick succession, two concurrent calls write to `this.devices` / `this.playlists` / `this.assets`. If the API key changed between calls, stale data from the old key could overwrite fresh data. Low probability but worth noting.

---

## 💡 Nice to Have

### N2: `manifest.json` version should be `0.0.0`

**Classification:** 🆕 NEW
**File:** `companion/manifest.json`, line 7
**Reviewer:** Kaylee

`"version": "1.0.3"`. Recommended value is `"0.0.0"` — Companion uses the `package.json` version and git tag, not this field. Setting a real version creates maintenance burden.

---

### N3: Several action options missing `tooltip`

**Classification:** 🆕 NEW
**File:** `src/actions.js`, lines 128–130, 178–183, 216–224, 237–238
**Reviewer:** Kaylee

`add_asset_to_playlist`, `remove_asset_from_playlist`, and `set_asset_duration_in_playlist` have some options without `tooltip` fields. The first two actions (`assign_playlist`, `assign_asset`) consistently include tooltips — worth extending the pattern.

---

## ⚠️ Pre-existing Notes

N/A — first release.

---

## 🧪 Tests

**Verdict:** ✅ No tests present — not required

No test files, test runner config, or test scripts found. Per review policy, absence of tests is explicitly acceptable.

---

## ✅ What's Solid

- **Clean module architecture** — `runEntrypoint(OptiSignsInstance, UpgradeScripts)` correctly at bottom of `src/main.js`. All 4 lifecycle methods properly implemented.
- **`destroy()` cleanup** — `_stopPolling()` correctly calls `clearInterval` and nulls `_pollTimer`. No timer leak.
- **`_startPolling()` guard** — Calls `_stopPolling()` before setting a new interval, preventing double-timer on `configUpdated()`.
- **All action callbacks wrapped in try/catch** — every mutation callback has proper error handling. No unhandled rejections.
- **GraphQL error handling** — `src/api.js` checks both `response.ok` (HTTP-level) and `json.errors` (GraphQL-level). Correct and thorough.
- **`InstanceStatus` transitions** — `Connecting` on entry, `Ok` on success, `ConnectionFailure` on error, `BadConfig` when key is absent. All correct.
- **`configUpdated()` lifecycle** — stops polling, applies new config, validates, then restarts. Clean teardown sequence.
- **Smart polling optimization** — `_listSignature()` avoids rebuilding action/feedback definitions on every poll when lists haven't changed. Prevents wiping feedback instances from buttons.
- **Build succeeds** — `yarn build` produces a valid `.tgz` package cleanly.
- **Real HELP.md documentation** — covers setup, actions, feedbacks, variables with examples. Not a stub.
- **UpgradeScripts empty array** — correct for first release, no saved user setups to migrate.
- **API key not logged** — Bearer token in Authorization header is never exposed in logs.
- **No deprecated patterns** — no `isVisible` functions, no `self.parseVariablesInString()`, no custom feedback invert. Clean v1.14 usage.
- **Feedbacks use `showInvert: true`** — correct v1.5+ approach instead of custom invert option.
- **Version matches tag** — `package.json` version `1.0.3` matches git tag `v1.0.3`.
