# Follow-up Review: generic-websocket @ v2.3.1

| Field | Value |
|-------|-------|
| **Module** | `companion-module-generic-websocket` |
| **Tag** | `v2.3.1` |
| **Commit** | `b53bfa0` |
| **Previous reviewed version** | `v2.3.0` |
| **Reviewed** | 2026-04-16 |
| **Reviewer** | Mal (Lead) |
| **API version** | v1.x (`@companion-module/base ~1.12.0`) |
| **Module type** | JavaScript / ESM |
| **Release diff** | `git diff v2.3.0 HEAD -- .` → `.gitattributes`, `.gitignore`, `.prettierignore`, `companion/manifest.json`, `main.js`, `package.json`, `upgrade.js`, `yarn.lock` |
| **Validation** | ✅ `yarn package` · ⚠️ `yarn test` is still the placeholder script (`Error: no test specified`) |

---

## Verdict

### ❌ CHANGES REQUIRED — v2.3.1 fixes most of the prior review, but the two carried-forward high issues still block release

This follow-up is constrained to the `v2.3.0` → current pending checkout delta plus the prior `generic-websocket` review. The patch closes 8 of the 10 previously reported findings, but the ping timer still sends without error handling and the custom Origin header still hardcodes `http://` even for `wss://` targets.

---

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 0 | 0 | 0 |
| 🟠 High | 0 | 2 | 2 |
| 🟡 Medium | 0 | 0 | 0 |
| 🟢 Low | 0 | 0 | 0 |
| **Total** | **0** | **2** | **2** |

**Blocking:** 2 issues (2 carried-forward high)  
**Fix complexity:** Quick — both remaining blockers are small targeted fixes in `main.js`  
**Health delta:** 0 introduced · 2 pre-existing carried forward

---

## Fix Verification (`v2.3.0` review → current pending checkout)

**8 of 10 prior findings are fixed in this patch.**

### Fixed in v2.3.1

| ID | Prior finding | Severity | Resolution |
|----|---------------|----------|------------|
| C1 | `send_command` lacked a WebSocket open-state guard | 🔴 Critical | ✅ **Fixed** — `main.js:438-440` now checks `this.ws` and `readyState === WebSocket.OPEN` before sending. |
| C2 | Upgrade script used bitwise `|` instead of logical `||` | 🔴 Critical | ✅ **Fixed** — `upgrade.js:38` now uses logical OR across the `append_new_line` checks. |
| C4 | Missing `.gitattributes` | 🔴 Critical | ✅ **Fixed** — `.gitattributes:1` now contains the required `* text=auto eol=lf`. |
| C5 | Missing `engines.node` / `engines.yarn` | 🔴 Critical | ✅ **Fixed** — `package.json:27-30` adds the required Node/Yarn engines block. |
| M3 | `.gitignore` content diverged from template | 🟡 Medium | ✅ **Fixed** — `.gitignore:1-7` now carries the corrected `/*.tgz`, `DEBUG-*`, `package-lock.json`, and `/.yarn` entries. |
| M4 | Missing `prettier` in `devDependencies` | 🟡 Medium | ✅ **Fixed** — `package.json:21-24` now includes `prettier`. |
| L3 | `.prettierignore` content diverged from template | 🟢 Low | ✅ **Fixed** — `.prettierignore:1-2` now matches the expected template entries. |
| L4 | `main.js` was missing a trailing newline | 🟢 Low | ✅ **Fixed** — file now ends cleanly after `runEntrypoint(...)`. |

### Still blocking

| ID | Finding | Severity | Current status |
|----|---------|----------|----------------|
| H1 | Ping timer `ws.send()` calls still have no error handling | 🟠 High | ❌ **Not fixed** — `main.js:62` and `main.js:167` still call `this.ws.send(...)` without a callback, so mid-send socket failures are still ignored. |
| H2 | Custom Origin header still forces `http://` for secure WebSockets | 🟠 High | ❌ **Not fixed** — `main.js:149` still builds `Origin: http://${new URL(url).hostname}` even when `url` is `wss://...`. |

---

## 📋 Issues

**Blocking**
- [ ] [H1: Ping timer `ws.send()` calls still have no error handling](#h1-ping-timer-wssend-calls-still-have-no-error-handling)
- [ ] [H2: Custom Origin header still forces `http://` for secure WebSockets](#h2-custom-origin-header-still-forces-http-for-secure-websockets)

---

## 🟠 High

### H1: Ping timer `ws.send()` calls still have no error handling

**Classification:** ⚠️ PRE-EXISTING  
**File:** `main.js:62`, `main.js:167`

Both ping timer paths are unchanged from the prior review:

```javascript
this.ws.send(this.hexToBuffer(this.config.ping_hex || '00'))
```

If the socket closes between the `readyState` check and the actual send, the failure path is still unobserved. Use the callback form of `ws.send()` and log the `err` so keepalive failures do not disappear silently.

---

### H2: Custom Origin header still forces `http://` for secure WebSockets

**Classification:** ⚠️ PRE-EXISTING  
**File:** `main.js:149`

```javascript
Origin: `http://${new URL(url).hostname}`,
```

This still mismatches `wss://` targets. Servers that validate Origin strictly can reject secure connections because the module advertises an insecure origin.

**Required fix:** derive the scheme from `new URL(url).protocol` and use `https://` for `wss:` URLs.

---

## New Issues Introduced in v2.3.1

None. I did not find any new release-delta issues beyond the two carried-forward highs above. The source `companion/manifest.json` change to `"version": "0.0.0"` is benign here: `yarn package` stamps `pkg/companion/manifest.json` to `2.3.1`, which matches `package.json`.

---

## 🧪 Validation

- ✅ `yarn package`
- ⚠️ `yarn test` — still the stock placeholder script and exits with `Error: no test specified`
- ✅ No `package-lock.json` present in the module root
- ✅ Built `pkg/companion/manifest.json` reports `version: "2.3.1"` and `runtime.apiVersion: "1.12.0"`

---

## ✅ Still Solid

- This is a real corrective follow-up, not a no-op resubmission: 8 prior findings are now closed.
- The template-compliance repairs landed cleanly (`.gitattributes`, `.gitignore`, `.prettierignore`, `package.json` metadata).
- `send_command` now matches `send_hex` on connection-state guarding, which removes the prior disconnect crash path.

---

*Follow-up review conducted by Mal only, constrained to the `v2.3.0` release delta and prior generic-websocket review context.*
