# Review: adder-ccs-pro v0.1.2

**Module:** companion-module-adder-ccs-pro  
**Version:** v0.1.2  
**Previous Version:** *(none — first release)*  
**API:** v1.x (`@companion-module/base ~1.14.1`)  
**Language:** JavaScript  
**Reviewed:** 2026-04-10  
**Reviewers:** Mal (Lead), Wash (Protocol), Kaylee (Dev), Zoe (QA), Simon (Tests)

---

## Fix Summary for Maintainer

Three quick fixes are required before this module can be approved:

1. **Create `.prettierignore`** — Add this file to the repo root with exactly two lines: `package.json` and `/LICENSE.md`
2. **Replace `.gitignore`** — Remove the extra markdown-blocking rules (`.claude/`, `*.md` block) and align to the standard template content
3. **Remove banned keywords from `companion/manifest.json`** — Remove `"adder"`, `"ccs-pro"`, and `"ccs-pro8"` from the `keywords` array; keep `"kvm"` and `"switch"`

All three are small file edits. No code changes required.

---

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 3 | 0 | 3 |
| 🟠 High | 0 | 0 | 0 |
| 🟡 Medium | 5 | 0 | 5 |
| 🟢 Low | 3 | 0 | 3 |
| 💡 Nice to Have | 3 | 0 | 3 |
| **Total** | **14** | **0** | **14** |

**Blocking:** 3 issues (3 new critical — all template compliance)  
**Fix complexity:** Quick — three small file edits, no code changes  
**Health delta:** 14 introduced · 0 pre-existing (first release)

---

## Verdict

**❌ CHANGES REQUIRED**

The module is well-built — clean HTTP polling implementation, correct v1.x SDK usage, excellent documentation, and a thorough `companion/HELP.md`. However, three template compliance violations block approval. All three are small file fixes with no code impact.

Once the three Critical items are resolved, this module is ready for release.

---

## 📋 Issues

**Blocking**
- [ ] [C1: Missing `.prettierignore` file](#c1-missing-prettierignore-file)
- [ ] [C2: `.gitignore` contains non-template content](#c2-gitignore-contains-non-template-content)
- [ ] [C3: Banned keywords in `manifest.json`](#c3-banned-keywords-in-manifestjson)

**Non-blocking**
- [ ] [M1: Deprecated `isVisible` function — use `isVisibleExpression`](#m1-deprecated-isvisible-function--use-isvisibleexpression)
- [ ] [M2: Password field should use `secret-text` type](#m2-password-field-should-use-secret-text-type)
- [ ] [M3: In-flight HTTP requests not aborted on `destroy()`](#m3-in-flight-http-requests-not-aborted-on-destroy)
- [ ] [M4: No `InstanceStatus.Disconnected` set in `destroy()`](#m4-no-instancestatusdisconnected-set-in-destroy)
- [ ] [M5: Concurrent polls possible when poll duration exceeds interval](#m5-concurrent-polls-possible-when-poll-duration-exceeds-interval)
- [ ] [L1: No retry logic on command failure](#l1-no-retry-logic-on-command-failure)
- [ ] [L2: Parse failure leaves stale state silently](#l2-parse-failure-leaves-stale-state-silently)
- [ ] [L3: `res.on('error')` not handled in `pollDevice()`](#l3-resonerror-not-handled-in-polldevice)
- [ ] [N1: `dist/` not explicitly ignored in `.gitignore`](#n1-dist-not-explicitly-ignored-in-gitignore)
- [ ] [N2: No debug log when HTML parsing fails to extract a channel](#n2-no-debug-log-when-html-parsing-fails-to-extract-a-channel)
- [ ] [N3: `configUpdated()` does not cancel in-flight poll before restarting](#n3-configupdated-does-not-cancel-in-flight-poll-before-restarting)

---

## 🔴 Critical

### C1: Missing `.prettierignore` file

**File:** `.prettierignore` (missing entirely)  
**Classification:** 🆕 New  
**Reviewer:** Kaylee

**Issue:**  
The `.prettierignore` file is absent from the repository root. This file is required by the JS module template.

**Required content (exact):**
```
package.json
/LICENSE.md
```

**Fix:** Create `.prettierignore` at the repo root with the two lines above.

---

### C2: `.gitignore` contains non-template content

**File:** `.gitignore`  
**Classification:** 🆕 New  
**Reviewer:** Kaylee

**Issue:**  
The `.gitignore` contains extra entries not present in the JS module template:

```
.claude/

# Markdown — private by default; only README + Companion HELP ship in the repo
*.md
!README.md
!companion/HELP.md
```

Additionally, `*.tgz` and `pkg/` use slightly different glob patterns compared to the template (`/*.tgz` and `/pkg`).

**Template content (exact):**
```
node_modules/
package-lock.json
/pkg
/*.tgz
DEBUG-*
/.yarn
```

**Fix:** Replace `.gitignore` contents with the template above. Remove the `.claude/` entry and the entire markdown-blocking block.

---

### C3: Banned keywords in `manifest.json`

**File:** `companion/manifest.json`  
**Classification:** 🆕 New  
**Reviewer:** Kaylee

**Issue:**  
The `keywords` array contains manufacturer and product names, which are banned per template compliance rules:

```json
"keywords": ["kvm", "adder", "ccs-pro", "ccs-pro8", "switch"]
```

- `"adder"` — manufacturer name (banned)
- `"ccs-pro"` — product name (banned)
- `"ccs-pro8"` — product name variant (banned)

**Fix:**
```json
"keywords": ["kvm", "switch"]
```

---

## 🟡 Medium

### M1: Deprecated `isVisible` function — use `isVisibleExpression`

**File:** `src/main.js`, lines 89 and 96  
**Classification:** 🆕 New  
**Reviewer:** Mal

**Issue:**  
Config fields for `username` and `password` use the deprecated function-based `isVisible` pattern, which was deprecated in v1.12 in favour of `isVisibleExpression`.

```javascript
isVisible: (config) => !!config.useAuth,  // lines 89 and 96
```

While this works in v1.14, it is a known breaking removal in v2.0+.

**Recommended fix:**
```javascript
isVisibleExpression: 'this.useAuth == true'
```

---

### M2: Password field should use `secret-text` type

**File:** `src/main.js`, line 91  
**Classification:** 🆕 New  
**Reviewer:** Mal

**Issue:**  
The `password` config field uses `type: 'textinput'`, exposing the password in plain text in Companion exports. The `secret-text` type (available since v1.13) masks the input and protects credentials from export.

**Current:**
```javascript
{ type: 'textinput', id: 'password', label: 'Password', ... }
```

**Recommended fix:**
```javascript
{ type: 'secret-text', id: 'password', label: 'Password', ... }
```

---

### M3: In-flight HTTP requests not aborted on `destroy()`

**File:** `src/main.js`, lines 31–34  
**Classification:** 🆕 New  
**Reviewer:** Wash

**Issue:**  
`destroy()` clears the poll timer but does not cancel any in-flight HTTP requests. Orphaned polls can still fire callbacks (log entries, status updates) after the module has been destroyed.

**Impact:** Minimal for stateless HTTP — no resource leak — but can produce misleading log output.

**Recommended fix:** Track the active request (`this._activeReq = req`) in `pollDevice()` and call `this._activeReq?.destroy()` in `destroy()` before `stopPolling()`.

---

### M4: No `InstanceStatus.Disconnected` set in `destroy()`

**File:** `src/main.js`, lines 31–34  
**Classification:** 🆕 New  
**Reviewer:** Wash

**Issue:**  
`destroy()` does not call `this.updateStatus(InstanceStatus.Disconnected)`. Companion's UI may not immediately reflect that the connection has been torn down.

**Recommended fix:** Add `this.updateStatus(InstanceStatus.Disconnected)` as the first line of `destroy()`.

---

### M5: Concurrent polls possible when poll duration exceeds interval

**File:** `src/main.js` (polling setup)  
**Classification:** 🆕 New  
**Reviewer:** Wash

**Issue:**  
`pollDevice()` is fired via `setInterval`. If a poll takes longer than the configured interval (e.g., slow device response + 4 s timeout on a 2 s interval), two polls can run concurrently, potentially causing rapid status flipping if one succeeds and one fails.

**Impact:** Low in practice — the 4 s request timeout is above the 5 s default interval, so overlap requires both a slow device and a user-configured minimum (2 s) interval.

**Recommended fix:** Use a self-scheduling pattern (call `setTimeout` at the end of each poll) rather than `setInterval`, or skip a poll if one is already in flight.

---

## 🟢 Low

### L1: No retry logic on command failure

**File:** `src/api.js`  
**Classification:** 🆕 New  
**Reviewer:** Wash

**Issue:**  
If `sendCommand()` fails (network error, timeout, non-200 response), no retry is attempted. The operator must press the button again.

**Impact:** Acceptable for user-initiated commands; the Companion operator is present to retry. Document this behaviour in `companion/HELP.md` so users know what to expect.

---

### L2: Parse failure leaves stale state silently

**File:** `src/main.js`, lines 169–201  
**Classification:** 🆕 New  
**Reviewer:** Zoe

**Issue:**  
If `parseStatusPage()` fails to match any regex patterns (e.g., after a firmware update changes the HTML structure), the module silently retains the last-known channel state. Variables and feedbacks will show stale values with no warning to the operator.

**Recommended fix:** Log a `debug` message when a regex fails to match so that support or the maintainer can diagnose state-sync issues after firmware changes.

---

### L3: `res.on('error')` not handled in `pollDevice()`

**File:** `src/main.js`, lines 136–161  
**Classification:** 🆕 New  
**Reviewer:** Zoe

**Issue:**  
The response object in `pollDevice()` has no `error` event handler. If the device sends a malformed HTTP response or closes the connection mid-body, Node.js emits an error on the response stream. Without a handler, this becomes an unhandled rejection that could crash the Companion module process.

**Recommended fix:**
```javascript
res.on('error', (err) => {
    this.log('warn', `Response stream error: ${err.message}`)
    this.updateStatus(InstanceStatus.ConnectionFailure, err.message)
})
```

---

## 💡 Nice to Have

### N1: `dist/` not explicitly ignored in `.gitignore`

**File:** `.gitignore`  
**Classification:** 🆕 New  
**Reviewer:** Mal

`dist/` is not currently committed, but explicitly listing it in `.gitignore` prevents accidental commits after a local `yarn package` run.

**Recommended addition:**
```
dist/
```

*(Note: after resolving C2, add this to the corrected `.gitignore` as well.)*

---

### N2: No debug log when HTML parsing fails to extract a channel

**File:** `src/main.js` (parseStatusPage)  
**Classification:** 🆕 New  
**Reviewer:** Wash

A low-cost debug log when a channel regex fails to match would help diagnose future firmware-related state-sync failures. No code change needed until a user reports issues.

---

### N3: `configUpdated()` does not cancel in-flight poll before restarting

**File:** `src/main.js`, lines 36–43  
**Classification:** 🆕 New  
**Reviewer:** Zoe

If a poll is in flight when the operator saves a config change, the old poll completes against the old host and briefly updates state/feedbacks before the new host's poll takes over. The window is short (<4 s), not a bug, and unlikely to affect normal use. Related to M3 — fixing M3 resolves this too.

---

## 🔮 Next Release

1. **Migrate to `isVisibleExpression`** — Replace `isVisible` function callbacks on `username` and `password` config fields (resolves M1)
2. **Use `secret-text` for the password field** (resolves M2)
3. **Abort in-flight HTTP requests on `destroy()`** — Track active request and destroy it before stopping polling (resolves M3 and N3)
4. **Set `InstanceStatus.Disconnected` in `destroy()`** (resolves M4)
5. **Self-scheduling poll pattern** — Eliminate setInterval overlap (resolves M5)
6. **Add `res.on('error')` handler in `pollDevice()`** (resolves L3)
7. **Log debug message on parse failure** in `parseStatusPage()` (resolves L2 and N2)
8. **Document command retry behaviour** in `companion/HELP.md` (resolves L1)
9. **Add `dist/` to `.gitignore`** (resolves N1)
10. **Consider v2.0 migration** when ready — module already runs on Node 22 which satisfies the v2.0 runtime requirement

---

## 🧪 Tests

**No tests present — none required.**

No Jest or Vitest configuration, test files, or `test` script detected. Absence of tests does not affect the verdict.

---

## ✅ What's Solid

- **Correct v1.x SDK usage** — `runEntrypoint`, `UpgradeScripts`, `InstanceBase` extension, all lifecycle methods (`init`, `destroy`, `configUpdated`, `getConfigFields`) implemented correctly
- **Clean HTTP polling pattern** — Stateless request-per-poll model with proper timeout, error handling, and socket drainage (`res.resume()` in command path)
- **Strong error handling** — All four HTTP failure modes handled: network error, 401 auth, non-200, and timeout; each maps to the correct `InstanceStatus`
- **Good resource cleanup** — Timer cleared on `destroy()` and `configUpdated()` with no double-clear risk; no event listener accumulation
- **Hardware model support** — `channel-range.js` elegantly handles PRO4 vs PRO8 by adapting channel choices throughout actions, feedbacks, and presets
- **Comprehensive `companion/HELP.md`** — Full documentation of config fields, all actions, feedbacks, variables, and presets with troubleshooting notes; well above minimum
- **Strong preset coverage** — 20 presets (PRO4) or 40 presets (PRO8) dynamically generated; categories match peripherals cleanly
- **Solid package.json** — All required fields present and correct: `engines.node`, `engines.yarn`, `packageManager`, `prettier`, `repository`, MIT license with real author name
- **Manifest.json** — Correct runtime (`node22`), entrypoint, schema reference, and `legacyIds` for backwards compatibility with saved connections
- **Code organisation** — Clean separation into `actions.js`, `feedbacks.js`, `variables.js`, `presets.js`, `api.js`, and `channel-range.js`; easy to navigate and extend
- **No package-lock.json** — Only `yarn.lock` present ✅
- **Build passes** — `yarn install && yarn package` succeeds, producing `adder-ccs-pro-0.1.2.tgz` ✅
