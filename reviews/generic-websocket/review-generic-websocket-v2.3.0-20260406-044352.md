# Review: generic-websocket v2.3.0

**Module:** companion-module-generic-websocket  
**Version:** v2.3.0 (diff from v2.2.0)  
**API:** `@companion-module/base` ~1.12.0 (v1.x)  
**Review Date:** 2026-04-06  
**Reviewers:** Mal (Lead), Wash (Protocol), Kaylee (Template), Zoe (QA), Simon (Tests)

---

## Fix Summary for Maintainer

1. **[C1]** Add WebSocket state check in `send_command` action — `main.js:443`
2. **[C2]** Fix bitwise OR (`|`) → logical OR (`||`) in upgrade script — `upgrade.js:38`
3. **[C4]** Add `.gitattributes` file with `* text=auto eol=lf`
4. **[C5]** Add `engines` field to `package.json`: `{ "node": "^22.20", "yarn": "^4" }`
5. **[H1]** Add error handling to `ws.send()` calls in ping timers — `main.js:62, 167`
6. **[H2]** Fix Origin header to use HTTPS for WSS connections — `main.js:149`

---

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 2 | 2 | 4 |
| 🟠 High | 1 | 1 | 2 |
| 🟡 Medium | 2 | 0 | 2 |
| 🟢 Low | 2 | 0 | 2 |
| **Total** | **7** | **3** | **10** |

**Blocking:** 6 issues (2 new critical, 2 pre-existing critical, 1 new high, 1 pre-existing high)  
**Fix complexity:** Medium — several logic fixes + missing file additions  
**Health delta:** 7 introduced · 3 pre-existing surfaced

---

## Verdict: **Changes Required**

6 blocking issues must be resolved: missing WebSocket state check, upgrade script logic error, missing .gitattributes, missing engines field, unhandled send rejections, and incorrect Origin protocol.

---

## 📋 Issues

**Blocking**
- [x] [C1: Missing WebSocket state check in send_command action](#c1-missing-websocket-state-check-in-send_command-action)
- [x] [C2: Bitwise OR instead of logical OR in upgrade script](#c2-bitwise-or-instead-of-logical-or-in-upgrade-script)
- [x] [C4: Missing required file .gitattributes](#c4-missing-required-file-gitattributes)
- [x] [C5: Missing engines.node and engines.yarn in package.json](#c5-missing-enginesnode-and-enginesyarn-in-packagejson)
- [ ] [H1: Unhandled WebSocket send rejections in ping logic](#h1-unhandled-websocket-send-rejections-in-ping-logic)
- [x] [H2: Origin header always uses HTTP for WSS connections](#h2-origin-header-always-uses-http-for-wss-connections)

**Non-blocking**
- [x] [M3: Invalid .gitignore content](#m3-invalid-gitignore-content)
- [x] [M4: Missing prettier in devDependencies](#m4-missing-prettier-in-devdependencies)
- [x] [L3: Invalid .prettierignore content](#l3-invalid-prettierignore-content)
- [x] [L4: Missing newline at end of file](#l4-missing-newline-at-end-of-file)

---

## 🔴 Critical

### C1: Missing WebSocket state check in send_command action

**Classification:** 🆕 NEW (regression)  
**Status:** ✅ Fixed  
**File:** `main.js`, line 443  
**Found by:** Zoe, Wash

The `send_command` action does not check if `this.ws` exists or if the WebSocket is in OPEN state before sending. This causes a runtime crash when users trigger the action while disconnected.

```javascript
// send_command (BAD - no check)
return new Promise((resolve, reject) => {
    this.ws.send(`${value}${termination}`, (err) => {  // ❌ Crashes if this.ws is null
```

The new `send_hex` action correctly implements this check (line 475-478), making this a regression in consistency:

```javascript
// send_hex (GOOD - has check)
if (!this.ws || this.ws.readyState !== WebSocket.OPEN) {
    this.log('error', `Cannot send hex: WebSocket is not connected.`)
    return
}
```

**Fix:** Add the same guard to `send_command`.

---

### C2: Bitwise OR instead of logical OR in upgrade script

**Classification:** ⚠️ PRE-EXISTING  
**Status:** ✅ Fixed  
**File:** `upgrade.js`, line 38  
**Found by:** Zoe

The upgrade script uses bitwise OR (`|`) instead of logical OR (`||`):

```javascript
if (config.append_new_line === '' | config.append_new_line === 'rn' | ...)
```

While this happens to work due to boolean coercion (0|1 arithmetic), it's incorrect and could cause edge-case issues.

**Fix:** Replace `|` with `||`.

---

### C4: Missing required file .gitattributes

**Classification:** ⚠️ PRE-EXISTING  
**Status:** ✅ Fixed  
**File:** `.gitattributes` (missing)  
**Found by:** Kaylee

The `.gitattributes` file is required for consistent line endings across platforms.

**Fix:** Create `.gitattributes` with:
```
* text=auto eol=lf
```

---

### C5: Missing engines.node and engines.yarn in package.json

**Classification:** ⚠️ PRE-EXISTING  
**Status:** ✅ Fixed  
**File:** `package.json`  
**Found by:** Kaylee

The `engines` field is missing entirely. This is required to specify compatible Node.js and Yarn versions.

**Fix:** Add to `package.json`:
```json
"engines": {
  "node": "^22.20",
  "yarn": "^4"
}
```

---

## 🟠 High

### H1: Unhandled WebSocket send rejections in ping logic

**Classification:** ⚠️ PRE-EXISTING  
**Status:** ⏳ Not Fixed  
**File:** `main.js`, lines 62, 167  
**Found by:** Wash

Ping timer sends messages via `this.ws.send()` without error handling. If send fails (socket closed mid-transmission, network error, buffer full), the error is silently ignored or could crash the Node.js process.

```javascript
this.ws.send(this.hexToBuffer(this.config.ping_hex || '00'))  // No error handling
```

**Fix:** Use callback-based error handling:
```javascript
this.ws.send(payload, (err) => {
    if (err) {
        this.log('warn', `Ping failed: ${err.message}`)
    }
})
```

---

### H2: Origin header always uses HTTP for WSS connections

**Classification:** 🆕 NEW  
**Status:** ✅ Fixed  
**File:** `main.js`, line 149  
**Found by:** Zoe

The Origin header is always set to `http://` regardless of connection protocol:

```javascript
Origin: `http://${new URL(url).hostname}`,  // ❌ Always HTTP
```

Some WebSocket servers reject connections with mismatched Origin protocols, causing failures for WSS connections.

**Fix:**
```javascript
const urlObj = new URL(url)
Origin: `${urlObj.protocol === 'wss:' ? 'https' : 'http'}://${urlObj.hostname}`
```

---

## 🟡 Medium

### M3: Invalid .gitignore content

**Classification:** 🆕 NEW  
**Status:** ✅ Fixed  
**File:** `.gitignore`  
**Found by:** Kaylee

Several deviations from template:
- Missing: `package-lock.json`, `/.yarn`
- Wrong pattern: `/pkg.tgz` should be `/*.tgz`
- Wrong pattern: `/DEBUG-*` should be `DEBUG-*`

---

### M4: Missing prettier in devDependencies

**Classification:** 🆕 NEW  
**Status:** ✅ Fixed  
**File:** `package.json`  
**Found by:** Kaylee

The `prettier` config field correctly references `@companion-module/tools/.prettierrc.json`, but `prettier` package is not listed in `devDependencies`.

**Fix:** Add to `devDependencies`:
```json
"prettier": "^3.0.0"
```

---

## 🟢 Low

### L3: Invalid .prettierignore content

**Classification:** 🆕 NEW  
**Status:** ✅ Fixed  
**File:** `.prettierignore`  
**Found by:** Kaylee

Content doesn't match template:
- Missing: `/LICENSE.md`
- Wrong entry: `pkg` instead of `/LICENSE.md`

---

### L4: Missing newline at end of file

**Classification:** 🆕 NEW  
**Status:** ✅ Fixed  
**File:** `main.js`, line 508  
**Found by:** Zoe

File ends without a trailing newline, violating POSIX standards.

---

## 🧪 Tests

**Status:** No automated tests

- Placeholder test script: `"test": "echo \"Error: no test specified\" && exit 1"`
- No test framework configured (no jest/vitest)
- No `*.test.js` or `*.spec.js` files
- CI relies on external `bitfocus/actions` workflow

---

## ✅ What's Solid

- **runEntrypoint** correctly called at bottom of `main.js` (line 508) with `upgradeScripts`
- **Lifecycle methods** all implemented: `init()`, `destroy()`, `configUpdated()`, `getConfigFields()`
- **destroy()** properly cleans up both `reconnect_timer` AND `ping_timer` — no timer leaks
- **upgrade.js** exports `upgradeScripts` array with v2_1 and v2_2 migration logic
- **New send_hex action** correctly uses `context.parseVariablesInString()` and has WebSocket state check
- **Ping timer cleanup** handled in all right places: `destroy()`, `initWebSocket()`, `configUpdated()`, WS close event
- **ESM structure** correct: `"type": "module"`, proper `.js` extensions
- **No package-lock.json** — correctly uses `yarn.lock`
- **manifest.json** uses `node22` runtime
- **HELP.md** is comprehensive, well-written documentation
- **Build passes**: `yarn package` creates `generic-websocket-2.3.0.tgz` successfully

---

## ⚠️ Pre-existing Notes

| Issue | Severity | Notes |
|-------|----------|-------|
| Bitwise OR in upgrade.js (C2) | Critical | Logic error, happens to work by accident |
| Missing .gitattributes (C4) | Critical | Template requirement |
| Missing engines field (C5) | Critical | Template requirement |
| Unhandled ping send errors (H1) | High | Could crash module on network issues |

---

**Review assembled by:** Mal, Lead Reviewer  
**Auto-fixes applied:** 2026-04-09 — C1, C2, C4, C5, H2, M3, M4, L3, L4
