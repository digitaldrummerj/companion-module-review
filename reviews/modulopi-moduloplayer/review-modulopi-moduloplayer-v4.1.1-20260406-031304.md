# Review: modulopi-moduloplayer v4.1.1

| Field | Value |
|-------|-------|
| **Module** | `companion-module-modulopi-moduloplayer` |
| **Review tag** | v4.1.1 |
| **Previous tag** | v4.0.8 |
| **API** | `@companion-module/base` ~1.12.1 (v1.x) |
| **Language** | TypeScript, ESM (`"type": "module"`) |
| **Protocol** | WebSocket (`ws` package) — dual connections (ModuloPlayer + Spydog) |
| **Reviewed by** | Mal · Wash · Kaylee · Zoe · Simon |
| **Requested by** | Justin James |
| **Date** | 2026-04-06 |

---

## Fix Summary for Maintainer

**6 issues must be fixed before approval. All are quick:**

1. **[C1]** Create `.prettierignore` with content: `package.json` / `/LICENSE.md`
2. **[C2]** Replace `.gitattributes` content with: `* text=auto eol=lf`
3. **[C3]** Create `.husky/pre-commit` file containing: `lint-staged`
4. **[H1]** Clear `this.pollAPI` interval in `destroy()` — `src/main.ts` ~line 91
5. **[H2]** Add upgrade script for `current_Cue` feedback option changing from `type: 'number'` to `type: 'textinput'`
6. **[H3]** Replace all `isVisible: () => false` with `isVisibleExpression: "false"` in `src/actions.ts` (22 occurrences) and `src/feedbacks.ts` (7 occurrences)

---

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 1 | 2 | 3 |
| 🟠 High | 2 | 1 | 3 |
| 🟡 Medium | 1 | 0 | 1 |
| 🟢 Low | 1 | 2 | 3 |
| 💡 Nice to Have | 1 | 0 | 1 |
| **Total** | **6** | **5** | **11** |

**Blocking:** 6 issues (3 Critical + 3 High)  
**Fix complexity:** Quick — file creates, two code fixes, and one upgrade script  
**Health delta:** 5 introduced · 6 pre-existing surfaced

---

## Verdict

**❌ Changes Required** — 6 blocking issues: 3 template compliance mismatches, 1 stale interval timer in `destroy()`, 1 missing upgrade script for option type change, and 1 deprecated API pattern. The code quality is solid — all issues are structural or configuration.

---

## 📋 Issues

**Blocking**
- [ ] [C1: Missing `.prettierignore` file](#c1-missing-prettierignore-file)
- [ ] [C2: Wrong `.gitattributes` content](#c2-wrong-gitattributes-content)
- [ ] [C3: Missing `.husky/pre-commit` file](#c3-missing-huskypre-commit-file)
- [ ] [H1: `pollAPI` interval not cleared in `destroy()`](#h1-pollapi-interval-not-cleared-in-destroy)
- [ ] [H2: Missing upgrade script for `current_Cue` option type change](#h2-missing-upgrade-script-for-current_cue-option-type-change)
- [ ] [H3: Deprecated `isVisible: () => false` usage](#h3-deprecated-isvisible---false-usage)

**Non-blocking**
- [ ] [M1: `engines.node` set to `^22.14` instead of template value](#m1-enginesnode-set-to-2214-instead-of-template-value)
- [ ] [L1: Duplicate action name "Next Cue on Playlist"](#l1-duplicate-action-name-next-cue-on-playlist)
- [ ] [L2: French comments in source files](#l2-french-comments-in-source-files)
- [ ] [L3: No explicit `close()` in `WSConnection.destroy()` before nulling](#l3-no-explicit-close-in-wsconnectiondestroy-before-nulling)
- [ ] [N1: Remove unused hidden `task` option from `launch_task` action](#n1-remove-unused-hidden-task-option-from-launch_task-action)

---

## 🔴 Critical

### C1: Missing `.prettierignore` file

**Classification:** 🆕 NEW (file has never existed in any release)  
**File:** `.prettierignore`  
**Issue:** The `.prettierignore` file does not exist at the module root. The TypeScript template requires it.

**Required content:**
```
package.json
/LICENSE.md
```

**Fix:** Create the file with the content above.

---

### C2: Wrong `.gitattributes` content

**Classification:** ⚠️ PRE-EXISTING  
**File:** `.gitattributes`  
**Issue:** The file contains `/.yarn/** linguist-vendored` instead of the required line-ending directive.

**Template requires:**
```
* text=auto eol=lf
```

**Found:**
```
/.yarn/** linguist-vendored
```

**Fix:** Replace the entire file content with `* text=auto eol=lf`.

---

### C3: Missing `.husky/pre-commit` file

**Classification:** ⚠️ PRE-EXISTING  
**File:** `.husky/pre-commit`  
**Issue:** The `.husky/` directory exists but is empty. TypeScript template modules must commit the pre-commit hook file. `husky` is listed as a `postinstall` dependency — it runs on `yarn install` but needs the hook file present in the repo to function.

**Required file content:**
```
lint-staged
```

**Fix:** Create `.husky/pre-commit` with the single line `lint-staged` and commit it.

---

## 🟠 High

### H1: `pollAPI` interval not cleared in `destroy()`

**Classification:** 🆕 NEW  
**File:** `src/main.ts`, lines 91–95  
**Issue:** The module-level `destroy()` method does not clear the `pollAPI` setInterval timer. `pollAPI` is assigned via `setInterval()` in `initPolling()` (line ~232), but `destroy()` only calls `this.mpConnection.destroy()` and `this.sdConnection.destroy()`. This leaves a stale interval firing after the module is destroyed — causing log output, unnecessary API calls, and a potential memory leak.

**Current:**
```typescript
async destroy(): Promise<void> {
    this.mpConnection.destroy()
    this.sdConnection.destroy()
    this.log('debug', 'destroy')
}
```

**Required fix:**
```typescript
async destroy(): Promise<void> {
    if (this.pollAPI !== null && this.pollAPI !== undefined) {
        clearInterval(this.pollAPI)
        this.pollAPI = null
    }
    this.mpConnection.destroy()
    this.sdConnection.destroy()
    this.log('debug', 'destroy')
}
```

---

### H2: Missing upgrade script for `current_Cue` option type change

**Classification:** 🆕 NEW  
**File:** `src/feedbacks.ts`, lines 69–75 and `src/upgrades.ts`  
**Issue:** The `current_Cue` feedback's `current_Cue` option changed from `type: 'number'` (default `1`) in v4.0.8 to `type: 'textinput'` (default `''`) in v4.1.1. This is a breaking change — saved buttons from v4.0.x store a numeric cue index; the new feedback expects a UUID string. No upgrade script addresses this migration.

**v4.0.8 option:**
```typescript
{ id: 'current_Cue', type: 'number', label: 'ID', default: 1, min: 1, max: 10000 }
```

**v4.1.1 option:**
```typescript
{ id: 'current_Cue', type: 'textinput', label: 'Cue UUID', default: '', isVisible: () => false }
```

The feedback callback does have a numeric fallback (lines ~89–90), but the stored option type mismatch still needs an explicit upgrade script to correctly migrate saved button data.

**Fix:** Add an upgrade script entry that converts stored `current_Cue` numeric values to `''` (or a suitable default) so existing saved buttons do not silently break.

---

### H3: Deprecated `isVisible: () => false` usage

**Classification:** ⚠️ PRE-EXISTING  
**File:** `src/actions.ts` (22 occurrences), `src/feedbacks.ts` (7 occurrences)  
**Issue:** The module uses `isVisible: () => false` (function form) on hidden legacy/migration options. This was deprecated in `@companion-module/base` v1.12. The module is on v1.12.1. Per review policy, pre-existing High issues block regardless of source — prior reviews missed this.

**All usages are the same pattern — constant false:**
```typescript
isVisible: () => false,   // deprecated
```

**Required replacement:**
```typescript
isVisibleExpression: "false",   // API v1.12+
```

**Affected files:** `src/actions.ts` lines 34, 74, 81, 124, 131, 166, 192, 218, 244, 277, 318, 357, 397, 438, 477 (and others); `src/feedbacks.ts` lines 15, 36, 43, 50, 75, 82, 143.

Since all usages are constant `false` (not conditional), migration is a straight find-and-replace.

---

## 🟡 Medium

### M1: `engines.node` set to `^22.14` instead of template value

**Classification:** 🔙 REGRESSION (changed this release)  
**File:** `package.json`, line ~22  
**Issue:** `engines.node` is `"^22.14"` but the template standard is `"^22.x"` (or `"^22.20"`). While `^22.14` is valid Node semver, it deviates from the template baseline and may cause unnecessary failures on Node 22.1–22.13 environments that are otherwise supported by `@companion-module/base` v1.12.

**Found:** `"node": "^22.14"`  
**Template expects:** `"node": "^22.x"` (or `"^22.20"`)

**Fix:** Change to `"^22.x"` for consistency with the module template.

---

## 🟢 Low

### L1: Duplicate action name "Next Cue on Playlist"

**Classification:** ⚠️ PRE-EXISTING  
**File:** `src/actions.ts`, lines ~209 and ~235  
**Issue:** Both the `next_cue` and `prev_cue` actions share the label `"Next Cue on Playlist"`. The `prev_cue` action should be labelled `"Previous Cue on Playlist"`.

---

### L2: French comments in source files

**Classification:** 🆕 NEW  
**Files:** `src/types.ts` (lines 1–4, 59–64, 88–90), `src/variables.ts` (line 102), `src/spydog.ts` (lines 60–61), `src/main.ts` (line 49)  
**Issue:** Several source files contain French comments (e.g., `// DONNÉES BRUTES JSON`, `// Restaure les valeurs Spydog du cache states`). The Companion project uses English for all code comments.

---

### L3: No explicit `close()` in `WSConnection.destroy()` before nulling

**Classification:** ⚠️ PRE-EXISTING  
**File:** `src/wsconnection.ts`, lines 87–93  
**Issue:** `destroy()` sets `this.websocket = null` without first calling `this.websocket?.terminate()`. The socket becomes eligible for GC and Node.js will eventually close it, but no TCP FIN is sent immediately. The server may see an ungraceful disconnect until TCP timeout. Compare with `disconnect()` which correctly calls `this.websocket?.close()` before releasing the reference.

---

## 💡 Nice to Have

### N1: Remove unused hidden `task` option from `launch_task` action

**File:** `src/actions.ts`, lines 28–35  
**Issue:** After the upgrade script migrates `task` → `tl`, the hidden `task` textinput field in the `launch_task` action becomes permanently unused. Consider removing it in a future release to clean up the action schema. (Do not remove it now — upgrade scripts referencing it need it present until the migration window has passed.)

---

## 🔮 Next Release

- **Upgrade to `@companion-module/base` v1.14** — no breaking changes from v1.12, enables latest security patches and Companion 4.2+ features
- **Add JSON.parse try/catch in message handlers** — see Pre-existing Notes
- **Add WebSocket connection timeout** — see Pre-existing Notes
- **Remove `task` hidden option from `launch_task`** once upgrade migration window has passed (see N1)

---

## ⚠️ Pre-existing Notes

Non-blocking issues that existed in v4.0.8 and were not introduced in v4.1.1. Noted for awareness — address in a future release.

| ID | File | Issue |
|----|------|-------|
| P1 | `src/moduloplayer.ts:34`, `src/spydog.ts:23` | `JSON.parse(data)` not wrapped in `try/catch` — malformed JSON from hardware throws in the WebSocket `'message'` handler. Caught by Companion's global handler, but no clean error message. Add `try/catch` with `this.instance.log('error', ...)`. |
| P2 | `src/wsconnection.ts:87–93` | `destroy()` nulls `websocket` without calling `terminate()` first — socket released to GC rather than explicitly closed. Low impact, but slightly unclean. |
| P3 | `src/wsconnection.ts:40–72` | No timeout on WebSocket connection attempt — if the device's port is firewalled, the socket hangs in CONNECTING state indefinitely. Add a 10s timeout: `setTimeout(() => { if (this.websocket?.readyState === WebSocket.CONNECTING) this.websocket.close() }, 10000)`. |
| P4 | `src/actions.ts:9–12` | Legacy playlist index fallback in `resolvePlaylistUuid()` doesn't log a warning when the index is out of bounds — silent action failure. Consider adding a debug log for out-of-bounds legacy indices. |
| P5 | `src/actions.ts:333, 372, 453, 492` | `Number(instance.states[plName])` can produce `NaN` if the state hasn't been populated yet. Arithmetic with NaN sends `NaN` fader values to the device. Fix: `const value = Number(instance.states[plName]) \|\| 0`. |
| P6 | `src/moduloplayer.ts:96` | `parseInt(String(playlist.index))` — if `playlist.index` is `null`, produces `NaN` displayed in Companion UI. Use `Number(playlist.index) \|\| 0` for safety. |

---

## 🧪 Tests

No tests found — not required. Module does not include a test configuration or test files. (Simon)

---

## ✅ What's Solid

**Architecture & SDK (Mal)**
- ✅ `runEntrypoint(MPinstance, UpgradeScripts)` correctly called at bottom of `src/main.ts`
- ✅ All lifecycle methods implemented: `init()`, `destroy()`, `configUpdated()`, `getConfigFields()`
- ✅ `UpgradeScripts` exported and populated — contains migration for `launch_task` and `color_cue` changes
- ✅ ESM compliance excellent — all relative imports use `.js` extensions
- ✅ TypeScript quality good — proper types in `src/types.ts`, no `any` abuse
- ✅ `dist/` not committed; only `yarn.lock` present (no `package-lock.json`)
- ✅ Manifest: correct `node22` runtime, matching `id`/`name`, real maintainer info, no banned keywords

**Protocol (Wash)**
- ✅ DRY principle applied correctly — unified `WSConnection` class replaces ~200 lines of duplicated `MPconnection`/`SDconnection` code
- ✅ `shouldBeConnected` flag prevents reconnect after intentional disconnect or destroy
- ✅ Exponential backoff reconnection (1.2× multiplier, capped at 16.5s)
- ✅ `'error'` event handler present on WebSocket — prevents unhandled Node.js exceptions
- ✅ `readyState === OPEN` guard before `send()` — no "not open" runtime errors
- ✅ `configUpdated()` correctly disconnects both sockets before reconnecting
- ✅ Dual-connection status logic correct — users see which service (ModuloPlayer vs. Spydog) is offline

**Module Dev (Kaylee)**
- ✅ `yarn install && yarn package` succeeds — produces `modulopi-moduloplayer-4.1.1.tgz`
- ✅ `HELP.md` comprehensive (162 lines) — covers actions, feedbacks, presets, variables with examples
- ✅ UUID-based action/feedback options with backward-compatible index fallback — excellent upgrade story
- ✅ 1122-line presets file — task list, per-playlist controls, show management, Spydog monitoring
- ✅ `prettier`, `packageManager`, `repository`, `license` fields all correct

**QA (Zoe)**
- ✅ No unhandled promise rejections — all async action callbacks are `async/await` with no floating `.then()`
- ✅ Structural hash optimization in `updateInstance()` prevents redundant action/feedback re-registration when only dynamic state changes
- ✅ Array guards in message handlers (`if (!Array.isArray(newList)) return`) — defensive against malformed API responses
- ✅ `resolvePlaylistUuid()` type-checks option before using (`typeof playlistOption === 'string'`)
- ✅ Optional chaining on dropdown defaults (`instance.dropdownTaskList[0]?.id ?? ''`) — safe on empty list
