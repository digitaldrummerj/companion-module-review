# Module Review: eventsync-server v0.9.8

**Module:** companion-module-eventsync-server  
**Version:** v0.9.8 (first release)  
**API:** @companion-module/base ~1.10.0 (v1.x)  
**Language:** TypeScript (ESM)  
**Protocol:** WebSocket (ws library)  
**Reviewed:** 2026-04-06  
**Requested by:** Justin James  
**Previous Tag:** (none — first release)

---

## Fix Summary for Maintainer

**Blocking fixes required (17 issues):**

1. **C1:** Create `.gitattributes` with `* text=auto eol=lf` (root directory)
2. **C2:** Create `.prettierignore` with `package.json` and `/LICENSE.md` (root directory)
3. **C3:** Create `.yarnrc.yml` with `nodeLinker: node-modules` (root directory)
4. **C4:** Create `tsconfig.build.json` from template and update `tsconfig.json` (root directory)
5. **C5:** Create `.husky/pre-commit` with `lint-staged` content (`.husky/` directory)
6. **C6:** Replace `.gitignore` content with template version (root directory)
7. **C7:** Add `engines` field to `package.json:~3` with `"node": "^22.20", "yarn": "^4"`
8. **C8:** Add `packageManager` field to `package.json:~4` with `"yarn@4.12.0"`
9. **C9:** Replace `prettier` object in `package.json:~45` with `"@companion-module/tools/.prettierrc.json"`
10. **C10:** Fix `repository.url` in `package.json:~10` to `bitfocus/companion-module-eventsync-server`
11. **C11:** Fix `repository` in `companion/manifest.json:~5` to match package.json URL
12. **C12:** Replace all `scripts` in `package.json:~20` with template versions
13. **H1:** Add `ws.removeAllListeners()` before `ws.close()` in `src/connection.ts:67-75`
14. **H2:** Add `shouldReconnect` flag to prevent reconnect on auth failure in `src/connection.ts:89-92`
15. **H3:** Upgrade `@companion-module/base` to `~1.14.1` in `package.json:~30`
16. **H4:** Upgrade `@companion-module/tools` to `^2.7.1` in `package.json:~35`
17. **H5:** Add `lint-staged` configuration section to `package.json:~50`

---

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 12 | 0 | 12 |
| 🟠 High | 5 | 0 | 5 |
| 🟡 Medium | 5 | 0 | 5 |
| 🟢 Low | 4 | 0 | 4 |
| 💡 Nice to Have | 2 | 0 | 2 |
| **Total** | **28** | **0** | **28** |

**Blocking:** 17 issues (12 critical, 5 high)  
**Fix complexity:** Medium — template compliance fixes are straightforward but numerous; WebSocket lifecycle changes require careful implementation  
**Health delta:** 28 introduced · 0 pre-existing (first release)

---

## Verdict

🔴 **CHANGES REQUIRED** — 12 critical template compliance violations and 5 high-severity WebSocket/dependency issues block approval. Module cannot build until template files are added and dependencies upgraded.

---

## 📋 Issues

**Blocking**
- [ ] [C1: Missing `.gitattributes` file](#c1-missing-gitattributes-file)
- [ ] [C2: Missing `.prettierignore` file](#c2-missing-prettierignore-file)
- [ ] [C3: Missing `.yarnrc.yml` file](#c3-missing-yarnrcyml-file)
- [ ] [C4: Missing `tsconfig.build.json` file](#c4-missing-tsconfigbuildjson-file)
- [ ] [C5: Missing `.husky` directory and pre-commit hook](#c5-missing-husky-directory-and-pre-commit-hook)
- [ ] [C6: `.gitignore` content does not match template](#c6-gitignore-content-does-not-match-template)
- [ ] [C7: Missing `engines` field in `package.json`](#c7-missing-engines-field-in-packagejson)
- [ ] [C8: Missing `packageManager` field in `package.json`](#c8-missing-packagemanager-field-in-packagejson)
- [ ] [C9: Wrong `prettier` field in `package.json`](#c9-wrong-prettier-field-in-packagejson)
- [ ] [C10: Wrong `repository.url` in `package.json`](#c10-wrong-repositoryurl-in-packagejson)
- [ ] [C11: Wrong `repository` in `manifest.json`](#c11-wrong-repository-in-manifestjson)
- [ ] [C12: Missing required `package.json` scripts](#c12-missing-required-packagejson-scripts)
- [ ] [H1: WebSocket Event Listeners Not Removed (Resource Leak)](#h1-websocket-event-listeners-not-removed-resource-leak)
- [ ] [H2: Reconnect on `authFailed` Creates Persistent Failure Loop](#h2-reconnect-on-authfailed-creates-persistent-failure-loop)
- [ ] [H3: Outdated `@companion-module/base` version](#h3-outdated-companion-modulebase-version)
- [ ] [H4: Outdated `@companion-module/tools` version](#h4-outdated-companion-moduletools-version)
- [ ] [H5: Missing `lint-staged` configuration](#h5-missing-lint-staged-configuration)

**Non-blocking**
- [ ] [M1: Version Mismatch Between package.json and manifest.json](#m1-version-mismatch-between-packagejson-and-manifestjson)
- [ ] [M2: Passcode Field Should Use `secret-text` Type](#m2-passcode-field-should-use-secret-text-type)
- [ ] [M3: No Backoff on Reconnect Attempts](#m3-no-backoff-on-reconnect-attempts)
- [ ] [M4: Unhandled Promise Rejection in Action Callbacks](#m4-unhandled-promise-rejection-in-action-callbacks)
- [ ] [M5: `send()` Called on Closed WebSocket Silently Fails](#m5-send-called-on-closed-websocket-silently-fails)
- [ ] [L1: Ping Interval May Accumulate](#l1-ping-interval-may-accumulate)
- [ ] [L2: `onStateUpdate()` Overwrites `serverStatus` from Server](#l2-onstateupdate-overwrites-serverstatus-from-server)
- [ ] [L3: Empty Dropdown Defaults Can Cause Invalid Action Options](#l3-empty-dropdown-defaults-can-cause-invalid-action-options)
- [ ] [L4: No Timeout on WebSocket Connection Attempt](#l4-no-timeout-on-websocket-connection-attempt)
- [ ] [N1: Remove banned keywords from package.json](#n1-remove-banned-keywords-from-packagejson)
- [ ] [N2: Consider adding connection retry logic improvements](#n2-consider-adding-connection-retry-logic-improvements)

---

## 🔴 Critical

### C1: Missing `.gitattributes` file
**File:** (missing)  
**Classification:** 🆕 NEW

The `.gitattributes` file does not exist.

**Expected:**
```
* text=auto eol=lf
```

**Impact:** Without this file, the repository does not enforce consistent LF line endings across platforms, leading to git diffs polluted with line-ending changes.

**Fix:** Create `.gitattributes` with the exact content shown above.

---

### C2: Missing `.prettierignore` file
**File:** (missing)  
**Classification:** 🆕 NEW

The `.prettierignore` file does not exist.

**Expected:**
```
package.json
/LICENSE.md
```

**Impact:** Without this file, Prettier will reformat `package.json` and `LICENSE.md`, breaking the standard formatting conventions expected by Companion tooling.

**Fix:** Create `.prettierignore` with the exact content shown above.

---

### C3: Missing `.yarnrc.yml` file
**File:** (missing)  
**Classification:** 🆕 NEW

The `.yarnrc.yml` file does not exist.

**Expected:**
```yaml
nodeLinker: node-modules
```

**Impact:** Without this file, Yarn will use Plug'n'Play mode by default, which is incompatible with Companion's module loading expectations. This will cause module installation failures.

**Fix:** Create `.yarnrc.yml` with the exact content shown above.

---

### C4: Missing `tsconfig.build.json` file
**File:** (missing)  
**Classification:** 🆕 NEW

The `tsconfig.build.json` file does not exist. The module only has `tsconfig.json`, which does not match the template structure.

**Current tsconfig.json:**
```json
{
  "compilerOptions": {
    "target": "ES2022",
    "lib": ["ES2022"],
    "module": "ES2022",
    "moduleResolution": "node",
    ...
  }
}
```

**Expected tsconfig.build.json:**
```json
{
  "extends": "@companion-module/tools/tsconfig/node22/recommended",
  "include": ["src/**/*.ts"],
  "exclude": ["node_modules/**", "src/**/*spec.ts", "src/**/__tests__/*", "src/**/__mocks__/*"],
  "compilerOptions": {
    "outDir": "./dist",
    "baseUrl": "./",
    "paths": { "*": ["./node_modules/*"] },
    "module": "Node16",
    "moduleResolution": "Node16"
  }
}
```

**Impact:** The current tsconfig does not use the recommended Companion module configuration. The `package.json` scripts reference `tsconfig.build.json`, which doesn't exist, so the build will fail.

**Fix:** Rename `tsconfig.json` to `tsconfig.build.json` and replace its content with the template version.

---

### C5: Missing `.husky` directory and pre-commit hook
**File:** (missing)  
**Classification:** 🆕 NEW

The `.husky/` directory does not exist. TypeScript modules must include a committed `.husky/pre-commit` hook.

**Expected:** `.husky/pre-commit` file with content:
```
lint-staged
```

**Impact:** Without the husky pre-commit hook, code will not be automatically linted and formatted before commits.

**Fix:** Create `.husky/pre-commit` with the content shown above and ensure `.husky/` is committed.

---

### C6: `.gitignore` content does not match template
**File:** `.gitignore`  
**Classification:** 🆕 NEW

**Current:** Contains extra entries not in template (comments, `.idea/`, `.DS_Store`, `Thumbs.db`, etc.)

**Template expects:**
```
node_modules/
package-lock.json
/pkg
/*.tgz
/dist
DEBUG-*
/.yarn
/.vscode
```

**Issues:**
- Missing required entries: `package-lock.json`, `/pkg`, `/*.tgz`, `DEBUG-*`
- Paths don't match: `dist/` should be `/dist`, `.yarn/` should be `/.yarn`

**Fix:** Replace the entire `.gitignore` content with the template version.

---

### C7: Missing `engines` field in `package.json`
**File:** `package.json`  
**Classification:** 🆕 NEW

`package.json` does not contain an `engines` field.

**Expected:**
```json
"engines": {
  "node": "^22.20",
  "yarn": "^4"
}
```

**Impact:** Without the `engines` field, Yarn and Node.js version enforcement is not applied.

**Fix:** Add the `engines` field to `package.json`.

---

### C8: Missing `packageManager` field in `package.json`
**File:** `package.json`  
**Classification:** 🆕 NEW

`package.json` does not contain a `packageManager` field.

**Expected:**
```json
"packageManager": "yarn@4.12.0"
```

**Impact:** Without this field, the package manager version is not locked.

**Fix:** Add the `packageManager` field to `package.json`.

---

### C9: Wrong `prettier` field in `package.json`
**File:** `package.json:~45`  
**Classification:** 🆕 NEW

**Current:** Inline Prettier configuration object
```json
"prettier": {
  "semi": false,
  "singleQuote": true,
  ...
}
```

**Expected:**
```json
"prettier": "@companion-module/tools/.prettierrc.json"
```

**Impact:** Custom Prettier configuration breaks consistency with other Companion modules.

**Fix:** Replace the `prettier` object with the string reference.

---

### C10: Wrong `repository.url` in `package.json`
**File:** `package.json:~10`  
**Classification:** 🆕 NEW

**Current:**
```json
"repository": {
  "type": "git",
  "url": "git+https://github.com/eventsync/companion-module-eventsync.git"
}
```

**Expected:**
```json
"repository": {
  "type": "git",
  "url": "git+https://github.com/bitfocus/companion-module-eventsync-server.git"
}
```

**Impact:** Repository URL points to wrong organization and module name.

**Fix:** Change `repository.url` to point to `bitfocus/companion-module-eventsync-server`.

---

### C11: Wrong `repository` in `manifest.json`
**File:** `companion/manifest.json:~5`  
**Classification:** 🆕 NEW

**Current:**
```json
"repository": "git+https://github.com/eventsync/companion-module-eventsync.git"
```

**Expected:**
```json
"repository": "git+https://github.com/bitfocus/companion-module-eventsync-server.git"
```

**Fix:** Change the `repository` field in `manifest.json` to match the corrected `package.json` URL.

---

### C12: Missing required `package.json` scripts
**File:** `package.json:~20`  
**Classification:** 🆕 NEW

**Missing scripts:** `postinstall`, `package`, `build:main`, `lint:raw`

**Current:**
```json
"scripts": {
  "build": "tsc -p tsconfig.json",
  "dev": "tsc -p tsconfig.json --watch",
  "lint": "eslint .",
  "format": "prettier --write src"
}
```

**Expected:**
```json
"scripts": {
  "postinstall": "husky",
  "format": "prettier -w .",
  "package": "run build && companion-module-build",
  "build": "rimraf dist && run build:main",
  "build:main": "tsc -p tsconfig.build.json",
  "dev": "tsc -p tsconfig.build.json --watch",
  "lint:raw": "eslint",
  "lint": "run lint:raw ."
}
```

**Impact:** The `yarn package` command (required for creating distributable modules) is missing. Format script only formats `src/`.

**Fix:** Replace all scripts with the template versions.

---

## 🟠 High

### H1: WebSocket Event Listeners Not Removed (Resource Leak)
**File:** `src/connection.ts:67-75`  
**Classification:** 🆕 NEW

The `disconnect()` method calls `ws.close()` but does not remove event listeners (`on('open')`, `on('message')`, `on('close')`, `on('error')`) attached at lines 30-59.

**Current Code:**
```typescript
disconnect(): void {
    if (this.reconnectTimer) {
        clearTimeout(this.reconnectTimer)
        this.reconnectTimer = null
    }
    this.stopPing()
    this.ws?.close()  // ← closes socket but listeners remain
    this.ws = null
}
```

**Impact:**
- Memory leaks (listeners hold closure references)
- Ghost events firing on stale connection objects
- Multiple reconnects triggering duplicate handlers

**Required Fix:**
```typescript
disconnect(): void {
    if (this.reconnectTimer) {
        clearTimeout(this.reconnectTimer)
        this.reconnectTimer = null
    }
    this.stopPing()
    if (this.ws) {
        this.ws.removeAllListeners()  // ← add this
        this.ws.close()
    }
    this.ws = null
}
```

---

### H2: Reconnect on `authFailed` Creates Persistent Failure Loop
**File:** `src/connection.ts:89-92`  
**Classification:** 🆕 NEW

When authentication fails (wrong passcode), the connection is disconnected. However, the `'close'` event handler **always** schedules a reconnect via `scheduleReconnect()`, creating an infinite loop:

1. Bad passcode → server sends `authFailed`
2. `disconnect()` called → WebSocket closes
3. `'close'` event fires → `scheduleReconnect()` called
4. After 5 seconds, reconnect → repeat from step 1

**Impact:**
- Spams server with failed auth attempts every 5 seconds
- Sets status to `BadConfig` but keeps trying to connect anyway
- No way to stop the loop except destroying the module instance

**Required Fix:**
```typescript
private shouldReconnect: boolean = true

disconnect(permanent: boolean = false): void {
    if (permanent) this.shouldReconnect = false
    // ... existing cleanup ...
}

private scheduleReconnect(): void {
    if (!this.shouldReconnect || this.reconnectTimer) return
    // ... existing reconnect logic ...
}

// In handleMessage authFailed case:
case 'authFailed':
    this.onStatus(InstanceStatus.BadConfig)
    this.disconnect(true)  // ← permanent disconnect
    break
```

---

### H3: Outdated `@companion-module/base` version
**File:** `package.json:~30`  
**Classification:** 🆕 NEW

**Current:** `"@companion-module/base": "~1.10.0"`  
**Recommended:** `"@companion-module/base": "~1.14.1"`

**Why upgrade:**
- API v1.10 targets Companion 3.4+; v1.14 targets Companion 4.2+
- v1.13 added `secret-text` field type for protecting credentials
- v1.10 requires Node 18 (`"^18.12"`), incompatible with template's required Node 22
- Upgrading to v1.14 is necessary to use Node 22

**Build Status:** ❌ FAILED
```
error @companion-module/base@1.10.0: The engine "node" is incompatible. Expected "^18.12". Got "22.22.2"
```

**Fix:** Update to `"@companion-module/base": "~1.14.1"`.

---

### H4: Outdated `@companion-module/tools` version
**File:** `package.json:~35`  
**Classification:** 🆕 NEW

**Current:** `"@companion-module/tools": "^2.6.1"`  
**Expected:** `"@companion-module/tools": "^2.7.1"`

**Why upgrade:**
- v2.7.1+ includes the Node 22 recommended TypeScript configuration
- The template's `tsconfig.build.json` extends `@companion-module/tools/tsconfig/node22/recommended`, which requires v2.7.1+

**Fix:** Update to `"@companion-module/tools": "^2.7.1"`.

---

### H5: Missing `lint-staged` configuration
**File:** `package.json`  
**Classification:** 🆕 NEW

`package.json` does not contain a `lint-staged` configuration section.

**Expected:**
```json
"lint-staged": {
  "*.{css,json,md,scss}": [
    "prettier --write"
  ],
  "*.{ts,tsx,js,jsx}": [
    "yarn lint:raw --fix"
  ]
}
```

**Impact:** Without this configuration, the husky pre-commit hook won't know which commands to run.

**Fix:** Add the `lint-staged` configuration section to `package.json`.

---

## 🟡 Medium

### M1: Version Mismatch Between package.json and manifest.json
**Files:** `package.json:3`, `companion/manifest.json:7`  
**Classification:** 🆕 NEW

- `package.json:3` — `"version": "0.9.8"`
- `companion/manifest.json:7` — `"version": "0.9.6"`

**Impact:** Companion uses manifest.json for display, package.json for npm. Mismatched versions cause confusion in bug reports.

**Fix:** Update `companion/manifest.json` line 7 to `"version": "0.9.8"`.

---

### M2: Passcode Field Should Use `secret-text` Type
**File:** `src/config.ts:29-35`  
**Classification:** 🆕 NEW

```typescript
{
    type: 'textinput',   // ← should be 'secret-text'
    id: 'passcode',
    label: 'Passcode',
    ...
}
```

**Issue:** The `passcode` config field is a credential. Using `textinput` exposes it in Companion configuration exports. Since API v1.13, `secret-text` type is available.

**Note:** Module uses API ~1.10.0. Upgrading to ~1.13.0+ would enable `secret-text`.

**Recommended Fix (requires API upgrade):**
```typescript
{
    type: 'secret-text',
    id: 'passcode',
    label: 'Passcode',
    ...
}
```

---

### M3: No Backoff on Reconnect Attempts
**File:** `src/connection.ts:107-114`  
**Classification:** 🆕 NEW

Reconnect always waits exactly 5 seconds. If the server is down, this hammers it with connection attempts indefinitely.

**Recommendation:** Implement exponential backoff (5s → 10s → 20s → 40s, capped at ~60s).

---

### M4: Unhandled Promise Rejection in Action Callbacks
**File:** `src/actions.ts:16-448`  
**Classification:** 🆕 NEW

All action callbacks are defined as `async` but never use `await`, and they call methods that could throw. Since callbacks are fire-and-forget, errors are silently swallowed.

```typescript
callback: async () => {
    instance.getConnection()?.globalGo()  // If this throws, no error handling
},
```

**Impact:**
- Operators press buttons but actions fail silently
- No feedback that command was not sent

**Recommendation:** Wrap action callback bodies in try/catch or make callbacks NOT async since they don't await anything.

---

### M5: `send()` Called on Closed WebSocket Silently Fails
**File:** `src/connection.ts:77-80`  
**Classification:** 🆕 NEW

The `send()` method only checks `readyState === WebSocket.OPEN` but doesn't log or notify when send is called on a non-open socket.

```typescript
send(message: object): void {
    if (this.ws?.readyState === WebSocket.OPEN) {
        this.ws.send(JSON.stringify(message))
    }
}
```

**Impact:** Actions silently fail when disconnected; operators may think command was sent.

**Recommendation:** Log a warning when send is called but socket is not open.

---

## 🟢 Low

### L1: Ping Interval May Accumulate
**File:** `src/connection.ts:116-120`  
**Classification:** 🆕 NEW

If `startPing()` is called multiple times without calling `stopPing()` first, multiple ping intervals will be created. The code lacks a guard check.

**Recommendation:** Add safety check: `if (this.pingInterval) return;`

---

### L2: `onStateUpdate()` Overwrites `serverStatus` from Server
**File:** `src/main.ts:70-71`  
**Classification:** 🆕 NEW

```typescript
newState.serverStatus = this.isConnected ? 'online' : 'offline'
```

The server sends its own `serverStatus` in the state update, but this is always overridden by the client's connection state.

**Impact:** If server wants to report "degraded" or "maintenance" status, it's ignored.

**Recommendation:** Use a different variable name for connection state vs server application state.

---

### L3: Empty Dropdown Defaults Can Cause Invalid Action Options
**Files:** `src/actions.ts`, `src/feedbacks.ts`  
**Classification:** 🆕 NEW

When generating actions/feedbacks, dropdown defaults use:
```typescript
default: stackChoices[0]?.id || ''
```

If `stackChoices` is empty (no stacks received from server), the default is an empty string. Actions configured before receiving state will send `{type: 'stackGo', stack: ''}`.

**Recommendation:** Validate action options before sending or show warning when choices are empty.

---

### L4: No Timeout on WebSocket Connection Attempt
**File:** `src/connection.ts:21-64`  
**Classification:** 🆕 NEW

If the server is unreachable, the WebSocket constructor will hang indefinitely waiting for TCP handshake. Node.js `ws` library doesn't have a built-in connection timeout.

**Recommendation:** Add a 10-second connection timeout that terminates the socket and triggers reconnect.

---

## 💡 Nice to Have

### N1: Remove banned keywords from package.json
**File:** `package.json`  
**Classification:** 🆕 NEW

**Current keywords:** `["bitfocus", "companion", "eventsync", "show-control", "osc"]`

**Banned keywords:**
- `"bitfocus"` — manufacturer name
- `"companion"` — generic term
- `"eventsync"` — module/product name

**Recommendation:** Remove banned keywords, keep only `"show-control"` and `"osc"`.

---

### N2: Consider adding connection retry logic improvements
**File:** `src/connection.ts`  
**Classification:** 🆕 NEW

Consider adding automatic reconnection with exponential backoff when the WebSocket connection is lost. This improves user experience during temporary network issues.

---

## 🔮 Next Release

1. **Upgrade to @companion-module/base ~1.13.0+** — enables `secret-text` config field type for the passcode
2. **Add Bonjour discovery** — if EventSync server advertises via mDNS, could auto-detect server IP (API v1.7+)
3. **API v2.0 upgrade** — When Companion 4.3 is released, consider upgrading to v2.0 for full expression support

---

## 🧪 Tests

**Test Detection Summary:**

| Item | Status |
|------|--------|
| Test files (*.test.ts, *.spec.ts) | ✅ Not found |
| Test directories (tests/, __tests__/) | ✅ Not found |
| Jest configuration | ✅ Not found |
| Vitest configuration | ✅ Not found |
| "test" script in package.json | ✅ Not found |

**Conclusion:** No tests exist, which is acceptable per charter. No action required.

---

## ✅ What's Solid

### SDK Compliance
- `runEntrypoint(EventSyncModule, [])` correctly placed at end of `main.ts:114`
- Empty `UpgradeScripts` array (correct for first release)
- All lifecycle methods implemented: `init()`, `destroy()`, `configUpdated()`, `getConfigFields()`
- Clean `destroy()` — disconnects WebSocket, nulls reference

### TypeScript Quality
- No `any` abuse — all types properly defined
- Clean interface definitions in `state.ts` (StackInfo, CueInfo, ModuleInfo, ServerMessage)
- Proper generic typing with `InstanceBase<EventSyncConfig>`

### Architecture
- Clean separation: actions, feedbacks, presets, variables, connection, state each in own file
- WebSocket connection with proper reconnection logic (5s timeout)
- Ping/keepalive every 30s
- Clean timer cleanup in `disconnect()` and `stopPing()`
- Dynamic preset/variable generation per cue stack
- State updates trigger `checkFeedbacks()` and `setVariableValues()`

### Build & Packaging
- No `package-lock.json` (yarn-only ✓)
- No committed `dist/` folder
- `dist/` in `.gitignore`
- `yarn.lock` present
- ESM with proper `.js` import extensions
- `"type": "module"` in package.json
- Manifest uses `node22` runtime

### Code Quality
- 32 well-documented actions with descriptions
- 14 boolean feedbacks with sensible default styles
- Rich preset library with transport controls, info displays, system status
- Variables for all stack states with formatted time displays
- Error Handler Registered — WebSocket `'error'` event is handled, preventing unhandled errors
- Defensive Message Parsing — `handleMessage()` is wrapped in try-catch
- ReadyState Check on Send — prevents errors on closed sockets
- Proper use of `InstanceStatus` enum for connection states

### Documentation
- LICENSE file is valid MIT license with proper copyright
- HELP.md is comprehensive and well-written (not a stub)
- Manifest maintainers are not placeholders (real email and organization)

---

*Review assembled by Mal (Lead) from findings by Wash, Kaylee, Zoe, and Simon*
