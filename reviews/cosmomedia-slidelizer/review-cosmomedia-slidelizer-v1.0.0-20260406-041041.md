# Review: cosmomedia-slidelizer v1.0.0

**Reviewer:** Mal (Lead)  
**Date:** 2026-04-06  
**Requested by:** Justin James  
**Module:** companion-module-cosmomedia-slidelizer  
**Version:** v1.0.0  
**Previous Tag:** (none — first release)  
**API Version:** v1.14 (`@companion-module/base ~1.14.1`)  
**Protocol:** TCP  
**Language:** JavaScript

---

## Fix Summary for Maintainer

| Priority | Fix |
|----------|-----|
| 🟠 High | Add try-catch to `configUpdated()` for unhandled promise rejection (`src/main.js:38-42`) |
| 🟠 High | Add connection lock/guard to prevent race condition in rapid config updates (`src/main.js:38-42`) |
| 🟠 High | Add `removeAllListeners()` before destroying socket to prevent listener accumulation (`src/main.js:136-144`) |
| 🟡 Medium | Update `@companion-module/tools` to `^2.7.1` or later (`package.json:23`) |
| 🟢 Low | Add `author` field to package.json |
| 🟢 Low | Add `keywords` field to package.json |
| 🟢 Low | Log errors in silent catch blocks instead of swallowing (`src/main.js:140`, `src/main.js:288`) |
| 🟢 Low | Add null/type check for `text` parameter in `_send()` (`src/main.js:264-276`) |
| 🟢 Low | Add buffer size limit to prevent unbounded growth (`src/main.js:91-130`) |
| 🟢 Low | Validate port range (1-65535) in connection logic (`src/main.js:61`) |
| 🟢 Low | Remove unused `timerRunning` property or implement it (`src/main.js:7-9`) |
| 💡 Nice | Add `dist/` to `.gitignore` |
| 💡 Nice | Consider adding `socket.setTimeout()` for connection timeout |
| 💡 Nice | Add presets for common button configurations |

---

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 0 | 0 | 0 |
| 🟠 High | 3 | 0 | 3 |
| 🟡 Medium | 1 | 0 | 1 |
| 🟢 Low | 7 | 0 | 7 |
| 💡 Nice to Have | 3 | 0 | 3 |
| **Total** | **14** | **0** | **14** |

**Blocking:** 3 issues (3 new high — race condition, unhandled rejection, listener accumulation)  
**Fix complexity:** Medium — requires connection locking logic and try-catch wrapper  
**Health delta:** 14 introduced · 0 pre-existing (first release)

---

## Verdict: ⚠️ CHANGES REQUIRED

Well-structured v1.14 TCP module with solid fundamentals, but 3 High severity race condition and error handling issues in `configUpdated()` flow need to be addressed for production robustness.

---

## 📋 Issues

**Blocking**
- [ ] [H1: Race condition in configUpdated() — multiple parallel connections](#h1-race-condition-in-configupdated-multiple-parallel-connections)
- [ ] [H2: Event listener accumulation / memory leak risk](#h2-event-listener-accumulation--memory-leak-risk)
- [ ] [H3: Unhandled promise rejection in configUpdated()](#h3-unhandled-promise-rejection-in-configupdated)

**Non-blocking**
- [ ] [M1: Outdated @companion-module/tools version](#m1-outdated-companion-moduletools-version)
- [ ] [L1: Missing author field in package.json](#l1-missing-author-field-in-packagejson)
- [ ] [L2: Missing keywords field in package.json](#l2-missing-keywords-field-in-packagejson)
- [ ] [L3: Silent error swallowing in _disconnect()](#l3-silent-error-swallowing-in-_disconnect)
- [ ] [L4: Silent error swallowing in _scheduleReconnect()](#l4-silent-error-swallowing-in-_schedulereconnect)
- [ ] [L5: Missing null check in _send()](#l5-missing-null-check-in-_send)
- [ ] [L6: Potential unbounded buffer growth](#l6-potential-unbounded-buffer-growth)
- [ ] [L7: No validation of port configuration range](#l7-no-validation-of-port-configuration-range)
- [ ] [L8: Unused timerRunning property](#l8-unused-timerrunning-property)
- [ ] [N1: .gitignore should include dist/](#n1-gitignore-should-include-dist)
- [ ] [N2: TCP socket never times out](#n2-tcp-socket-never-times-out)
- [ ] [N3: Preset opportunities](#n3-preset-opportunities)

---

## 🟠 High

### H1: Race condition in configUpdated() — multiple parallel connections

**File:** `src/main.js:38-42`  
**Classification:** 🆕 NEW  

```javascript
async configUpdated(config) {
    this.config = config || {}
    await this._disconnect()
    await this._maybeConnect()
}
```

**Issue:** If `configUpdated()` is called multiple times rapidly (e.g., user changes config twice quickly), there's no guard to prevent multiple concurrent connection attempts. Each call will disconnect and immediately start reconnecting, potentially creating race conditions where:
- Multiple `_connect()` calls execute in parallel
- `this.client` could be overwritten while a previous connection is still establishing
- Event listeners from abandoned connections may still fire

**Impact:** Could lead to multiple active connections, orphaned sockets, memory leaks from accumulated event listeners, and unpredictable state.

**Fix:** Add a connection lock/flag or cancel pending connection attempts before starting a new one.

---

### H2: Event listener accumulation / memory leak risk

**File:** `src/main.js:69-134`  
**Classification:** 🆕 NEW  

```javascript
async _connect(host, port) {
    try {
        this.client = new net.Socket()
        this.client.setEncoding('utf8')
        this.client.connect(port, host, () => { ... })
        this.client.on('error', (err) => { ... })
        this.client.on('close', () => { ... })
        this.client.on('data', (chunk) => { ... })
```

**Issue:** When `_connect()` is called multiple times (on reconnection or config updates), a new socket is created but the old one may not have its listeners properly cleaned up. While `_disconnect()` calls `client.destroy()`, if there's a race condition (H1), old sockets with active listeners could accumulate.

**Impact:** Memory leak from accumulated event listeners and socket objects that aren't garbage collected.

**Fix:** 
- Explicitly call `removeAllListeners()` before destroying the socket in `_disconnect()`
- Store event handler references and use `off()` instead of inline arrow functions
- Ensure only one connection attempt is active at a time (addresses H1)

---

### H3: Unhandled promise rejection in configUpdated()

**File:** `src/main.js:38-42`  
**Classification:** 🆕 NEW  

```javascript
async configUpdated(config) {
    this.config = config || {}
    await this._disconnect()
    await this._maybeConnect()
}
```

**Issue:** Both `_disconnect()` and `_maybeConnect()` can throw exceptions, but `configUpdated()` has no try-catch. Since this is an async function called by the Companion framework, any unhandled rejection could crash the module or leave it in an undefined state.

**Impact:** Module crash or undefined behavior if connection errors occur during config updates.

**Fix:** Wrap in try-catch with appropriate error logging:
```javascript
async configUpdated(config) {
    this.config = config || {}
    try {
        await this._disconnect()
        await this._maybeConnect()
    } catch (e) {
        this.log('error', `Config update failed: ${e.message}`)
    }
}
```

---

## 🟡 Medium

### M1: Outdated @companion-module/tools version

**File:** `package.json:23`  
**Classification:** 🆕 NEW  

Template recommends: `"@companion-module/tools": "^2.7.1"` or later  
Found: `"@companion-module/tools": "^2.6.1"`

**Impact:** Missing latest build tooling improvements and bug fixes.

**Fix:** Update to `^2.7.1` or later.

**Note:** Severity downgraded from Critical — build succeeds with ^2.6.1 and the template compliance skill doesn't mandate a specific version. This is a tooling improvement, not a blocking defect.

---

## 🟢 Low

### L1: Missing author field in package.json

**File:** `package.json` (field absent)  
**Classification:** 🆕 NEW  

Template recommends: `"author": "Name <email>"` or `"author": { "name": "...", "email": "..." }`  
Found: Field missing entirely

**Impact:** No authorship attribution in npm package metadata.

**Fix:** Add an `author` field matching the maintainer info in manifest.json:
```json
"author": "cosmomedia <info@cosmomedia.de>"
```

**Note:** Severity downgraded from Critical — `author` is not listed as a required field in the template compliance skill.

---

### L2: Missing keywords field in package.json

**File:** `package.json` (field absent)  
**Classification:** 🆕 NEW  

Recommended: `"keywords": []` field present (may be empty or contain non-banned terms)  
Found: Field missing entirely

**Impact:** Reduces discoverability on npm. Note: `manifest.json` already has proper keywords.

**Fix:** Add a `keywords` array (avoid banned terms: `"companion"`, `"module"`, `"stream deck"`, manufacturer/product names):
```json
"keywords": ["timer", "ndi", "presenter", "slides", "control"]
```

**Note:** Severity downgraded from Critical — `keywords` in package.json is not listed as required in template compliance skill, and manifest.json already has proper keywords.

---

### L3: Silent error swallowing in _disconnect()

**File:** `src/main.js:136-144`  
**Classification:** 🆕 NEW  

```javascript
async _disconnect() {
    if (this.client) {
        try {
            this.client.destroy()
        } catch (e) {}  // ← Silent catch
        this.client = null
    }
    this.updateStatus(InstanceStatus.Disconnected)
}
```

**Issue:** Exceptions during disconnect are silently swallowed. While this may be intentional defensive coding, it makes debugging harder and could hide genuine issues.

**Fix:** Log at debug/warn level: `catch (e) { this.log('debug', 'Disconnect cleanup: ' + e.message) }`

---

### L4: Silent error swallowing in _scheduleReconnect()

**File:** `src/main.js:278-289`  
**Classification:** 🆕 NEW  

```javascript
_scheduleReconnect() {
    try {
        // ... scheduling logic
    } catch {}  // ← Silent outer catch
}
```

**Issue:** The entire function is wrapped in an empty catch block. If something fails during reconnect scheduling, it fails silently.

**Fix:** Log at debug level or remove the outer try-catch if internal operations are already safe.

---

### L5: Missing null check in _send()

**File:** `src/main.js:264-276`  
**Classification:** 🆕 NEW  

```javascript
_send(text) {
    if (!this.client) {
        this.updateStatus(InstanceStatus.Disconnected)
        this.log('warn', 'Not connected')
        return
    }
    try {
        this.client.write(text)  // ← No check if text is null/undefined
```

**Issue:** The `text` parameter is not validated. If called with `null`, `undefined`, or non-string values, `client.write()` may throw or behave unexpectedly.

**Impact:** Low (callers currently always pass strings), but poor defensive programming.

**Fix:** Add validation: `if (!text || typeof text !== 'string') return`

---

### L6: Potential unbounded buffer growth

**File:** `src/main.js:91-130`  
**Classification:** 🆕 NEW  

```javascript
let buffer = ''
this.client.on('data', (chunk) => {
    buffer += chunk
    let nl
    while ((nl = buffer.indexOf('\n')) >= 0) {
        const line = buffer.substring(0, nl).trim()
        buffer = buffer.substring(nl + 1)
```

**Issue:** If the server sends a very long line without a newline character (malformed data or attack), the `buffer` string will grow unbounded in memory.

**Impact:** Low (Slidelizer protocol is well-defined), but a malicious or buggy server could cause memory issues.

**Fix:** Add a maximum buffer size check (e.g., 64KB) and reset/warn if exceeded:
```javascript
buffer += chunk
if (buffer.length > 65536) {
    this.log('error', 'Buffer overflow - resetting')
    buffer = ''
}
```

---

### L7: No validation of port configuration range

**File:** `src/main.js:61`  
**Classification:** 🆕 NEW  

```javascript
const port = Number(this.config?.port || 12345)
if (!host || !port || Number.isNaN(port)) {
```

**Issue:** The check validates if `port` is truthy, but `Number(0)` is falsy. While port 0 is invalid for this use case, the logic should explicitly check the range (1-65535) as defined in `getConfigFields()`.

**Impact:** Very low (UI already enforces min: 1), but inconsistent with config definition.

**Fix:** Change to: `if (!host || port < 1 || port > 65535 || Number.isNaN(port))`

---

### L8: Unused timerRunning property

**File:** `src/main.js:7-9, 112`  
**Classification:** 🆕 NEW  

```javascript
constructor(internal) {
    // ...
    this.currentTime = '00:00'
    this.videoRemaining = '--:--'
    this.timerRunning = false  // ← Never used/updated
```

**Issue:** The `timerRunning` property is initialized but never read or written elsewhere in the code. This suggests incomplete implementation or dead code.

**Impact:** None (unused variable), but indicates potential confusion about intended functionality.

**Fix:** Remove the unused property or implement timer state tracking if needed.

---

## 💡 Nice to Have

### N1: .gitignore should include dist/

**File:** `.gitignore:1-7`  
**Classification:** 🆕 NEW  

Currently lists `package-lock.json` and `/pkg` but not `dist/`. The `dist/` directory doesn't exist yet (JS module), but should be gitignored to prevent accidental commits if the module is later converted to TypeScript or build output is generated.

---

### N2: TCP socket never times out

**File:** `src/main.js:71-81`  
**Classification:** 🆕 NEW  

**Issue:** The socket is created without a connection timeout. If the host is unreachable (not refusing, but black-holing packets), the connection attempt can hang indefinitely.

**Recommendation:** Consider adding `socket.setTimeout()` or connection timeout logic:
```javascript
this.client.setTimeout(5000) // 5 second timeout
this.client.on('timeout', () => {
    this.log('warn', 'Connection timeout')
    this.client.destroy()
})
```

---

### N3: Preset opportunities

**Classification:** 🆕 NEW  

The module has well-structured actions and feedbacks but no presets are defined. Users would benefit from ready-to-use button configurations.

**Suggested presets:**
- Timer Start/Pause/Reset buttons with feedback showing current time
- +1 Minute / -1 Minute buttons
- NDI Next/Previous slide buttons
- Combined timer display with control actions

**Why useful:** Presets significantly improve user onboarding by providing working examples of module functionality.

---

## 🔮 Next Release

### Upgrade to @companion-module/base v2.0 (Companion 4.3+)

Consider upgrading to v2.0 API in a future release for:
- Expression support in action options
- Improved variable parsing
- Full API modernization
- Node 22 required (drops Node 18 support)

**Prerequisites:** Review breaking changes at https://companion.free/for-developers/module-development/api-changes/v2.0

---

## 🧪 Tests

No automated tests defined in this module. For future releases, consider adding:
- Unit tests for time formatting logic (`_formatVariants()`)
- Connection state machine tests
- Protocol message parsing tests

---

## ✅ What's Solid

### Entry Point & Lifecycle
- ✅ **Entry point correct:** `runEntrypoint(SlidelizerInstance, [])` at line 330 — properly bootstraps the module
- ✅ **Empty UpgradeScripts:** Correct for first release — passed as empty array `[]`
- ✅ **All lifecycle methods implemented:**
  - `init()` at line 19 — sets up connection, variables, actions, feedbacks
  - `destroy()` at line 51 — properly closes socket AND clears reconnect timer
  - `configUpdated()` at line 38 — disconnects and reconnects cleanly
  - `getConfigFields()` at line 44 — returns host/port config panel

### Template Compliance
- ✅ All required files present (`.gitattributes`, `.gitignore`, `.prettierignore`, `.yarnrc.yml`, `LICENSE`, `package.json`, `yarn.lock`, `companion/manifest.json`, `companion/HELP.md`, `src/main.js`)
- ✅ No `package-lock.json` present (correct for yarn-based module)
- ✅ Source code properly located in `src/` directory
- ✅ Config file content matches template
- ✅ `LICENSE` file is valid MIT license with proper attribution
- ✅ Manifest uses `node22` runtime — correct for v1.14
- ✅ Version `1.0.0` matches git tag `v1.0.0`

### TCP Connection Management
- ✅ **Proper cleanup in `destroy()`** — disconnects client and clears reconnect timer
- ✅ **Reconnect timer properly cleared** on successful connection
- ✅ **Exponential backoff** with max cap (10s) on reconnect attempts
- ✅ **Graceful error handling** on socket errors and close events
- ✅ **Encoding set correctly** (`utf8`)
- ✅ **Client nulled after destroy** — prevents use-after-free
- ✅ **Connection state checked before send**
- ✅ **Status transitions match socket state** throughout lifecycle
- ✅ **Line-buffered parsing** — handles partial TCP packets correctly
- ✅ **Proper newline splitting** prevents data corruption across packet boundaries

### API v1.14 Compliance
- ✅ No deprecated `isVisible` function patterns
- ✅ No redundant `parseVariablesInString()` calls
- ✅ No `disableNewConfigLayout` opt-out
- ✅ No permissions needed (no workers/filesystem/child_process)

### Code Quality
- ✅ Clean, well-structured class-based implementation
- ✅ Clear separation of timer and video remaining time handling
- ✅ Comprehensive variable formatting with multiple output variants (mm:ss, mm, ss, hh:mm)
- ✅ **11 Actions implemented:** Timer start/pause/reset, add/subtract minute/second, set time, toggle clock/timer, NDI next/previous
- ✅ **5 Feedbacks implemented:** Timer display in multiple formats, video remaining time
- ✅ **9 Variables defined:** Timer values, mode indicator, video remaining time variants

### Documentation
- ✅ Comprehensive HELP.md with configuration table, action list, variable reference, and feedback descriptions
- ✅ No placeholder text

---

## Build Verification

✅ **SUCCESS** — `yarn install && yarn package` completed successfully

```
Writing compressed package output to cosmomedia-slidelizer-1.0.0.tgz
```

---

*Review assembled by Mal (Lead) from findings by: Mal, Wash, Kaylee, Zoe*
