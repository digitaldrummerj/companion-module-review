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
| 🔴 Critical | Break `src/main.js` into separate files per companion-module-template-js: `actions.js`, `feedbacks.js`, `variables.js`, `upgrades.js`, `presets.js` |
| 🟡 Medium | Log errors in silent catch blocks instead of swallowing (`src/main.js:140`, `src/main.js:288`) |
| 🟡 Medium | Silent error swallowing in `_scheduleReconnect()` — remove or log the empty catch (`src/main.js:278-289`) |
| 🟡 Medium | Add null/type check for `text` parameter in `_send()` (`src/main.js:264-276`) |
| 🟡 Medium | Add buffer size limit to prevent unbounded growth (`src/main.js:91-130`) |
| 🟡 Medium | Add `dist/` to `.gitignore` (`.gitignore:1-7`) |
| 🟠 High | Add `socket.setTimeout()` connection timeout — socket can hang indefinitely on unreachable host (`src/main.js:71-81`) |
| 🟢 Low | Remove unused `timerRunning` property or implement it (`src/main.js:7-9`) |
| 💡 Nice | Add presets for common button configurations |

---

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 1 | 0 | 1 |
| 🟠 High | 1 | 0 | 1 |
| 🟡 Medium | 5 | 0 | 5 |
| 🟢 Low | 1 | 0 | 1 |
| 💡 Nice to Have | 1 | 0 | 1 |
| **Total** | **9** | **0** | **9** |

**Blocking:** 7 issues (1 critical + 1 high + 5 medium — monolithic structure, socket hang, silent error swallowing, missing null check, unbounded buffer, missing gitignore entry)  
**Fix complexity:** Medium — refactor + defensive coding improvements  
**Health delta:** 9 introduced · 0 pre-existing (first release)

---

## Verdict: ❌ CHANGES REQUIRED

All API and template compliance checks pass, but 7 blocking issues require attention: the monolithic `src/main.js` structure, a socket hang risk, 5 medium-severity defensive coding and configuration gaps.

---

## 📋 Issues

**Blocking**
- [ ] [C1: Monolithic main.js — must be split into separate files](#c1-monolithic-mainjs--must-be-split-into-separate-files)
- [ ] [H1: TCP socket never times out](#h1-tcp-socket-never-times-out)
- [ ] [M1: Silent error swallowing in _disconnect()](#m1-silent-error-swallowing-in-_disconnect)
- [ ] [M2: Silent error swallowing in _scheduleReconnect()](#m2-silent-error-swallowing-in-_schedulereconnect)
- [ ] [M3: Missing null check in _send()](#m3-missing-null-check-in-_send)
- [ ] [M4: Potential unbounded buffer growth](#m4-potential-unbounded-buffer-growth)
- [ ] [M5: .gitignore should include dist/](#m5-gitignore-should-include-dist)

**Non-blocking**
- [ ] [L1: Unused timerRunning property](#l1-unused-timerrunning-property)
- [ ] [N1: Preset opportunities](#n1-preset-opportunities)

---

## 🔴 Critical

### C1: Monolithic main.js — must be split into separate files

**File:** `src/main.js` (330 lines)  
**Classification:** 🆕 NEW  

**Issue:** All module definitions — actions, feedbacks, variables — are implemented as private methods inside a single `src/main.js` file. The companion-module-template-js defines a clear file-per-concern structure that all JavaScript modules must follow:

| Required file | Purpose | Current state |
|--------------|---------|---------------|
| `src/actions.js` | All action definitions | ❌ Inlined in `main.js:146-208` as `_initActions()` |
| `src/feedbacks.js` | All feedback definitions | ❌ Inlined in `main.js:209+` as `_initFeedbacks()` |
| `src/variables.js` | Variable definitions | ❌ Inlined in `main.js:22-32` |
| `src/upgrades.js` | Upgrade scripts array | ❌ Missing (passed inline as `[]` to `runEntrypoint`) |
| `src/presets.js` | Preset definitions | ❌ Missing entirely |

Each file should export a function that receives `self` (the module instance) and calls the relevant setter:

```javascript
// src/actions.js
module.exports = function (self) {
    self.setActionDefinitions({
        // action definitions
    })
}

// src/main.js — wire it up in init()
const actions = require('./actions.js')
// ...
actions(this)
```

**Impact:** Deviates from the established template structure that all Companion JavaScript modules are expected to follow. Makes the module harder to maintain as it grows, and inconsistent with the ecosystem standard.

**Fix:** Extract each concern into its own file per the companion-module-template-js pattern. `main.js` should remain responsible only for connection lifecycle and module bootstrap.

---

## 🟠 High

### H1: TCP socket never times out

**File:** `src/main.js:71-81`  
**Classification:** 🆕 NEW  

**Issue:** The socket is created without a connection timeout. If the host is unreachable (not refusing, but black-holing packets), the connection attempt can hang indefinitely, leaving the module stuck in a connecting state with no recovery.

**Fix:** Add `socket.setTimeout()` and handle the `timeout` event:
```javascript
this.client.setTimeout(5000) // 5 second timeout
this.client.on('timeout', () => {
    this.log('warn', 'Connection timeout')
    this.client.destroy()
})
```

---

## 🟡 Medium

### M1: Silent error swallowing in _disconnect()

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

### M2: Silent error swallowing in _scheduleReconnect()

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

### M3: Missing null check in _send()

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

### M4: Potential unbounded buffer growth

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

### M5: .gitignore should include dist/

**File:** `.gitignore:1-7`  
**Classification:** 🆕 NEW  

Currently lists `package-lock.json` and `/pkg` but not `dist/`. The `dist/` directory doesn't exist yet (JS module), but should be gitignored to prevent accidental commits if the module is later converted to TypeScript or build output is generated.

**Fix:** Add `dist/` to `.gitignore`.

---

## 🟢 Low

### L1: Unused timerRunning property

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

### N1: Preset opportunities

**Classification:** 🆕 NEW  

The module has well-structured actions and feedbacks but no presets are defined. Users would benefit from ready-to-use button configurations.

**Suggested presets:**
- Timer Start/Pause/Reset buttons with feedback showing current time
- +1 Minute / -1 Minute buttons
- NDI Next/Previous slide buttons
- Combined timer display with control actions

**Why useful:** Presets significantly improve user onboarding by providing working examples of module functionality.

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
