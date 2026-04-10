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
| 🟡 Medium | 4 | 0 | 4 |
| 🟢 Low | 0 | 0 | 0 |
| 💡 Nice to Have | 1 | 0 | 1 |
| **Total** | **8** | **0** | **8** |

**Blocking:** 3 issues (3 new critical — all template compliance)  
**Fix complexity:** Quick — three small file edits, no code changes  
**Health delta:** 8 introduced · 0 pre-existing (first release)

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
- [ ] [M1: manifest.json version should be 0.0.0](#m1-manifestjson-version-should-be-000)
- [ ] [M2: Module name does not match id in manifest.json](#m2-module-name-does-not-match-id-in-manifestjson)
- [ ] [M3: LICENSE file does not match template](#m3-license-file-does-not-match-template)
- [ ] [M4: Concurrent polls possible when poll duration exceeds interval](#m4-concurrent-polls-possible-when-poll-duration-exceeds-interval)
- [ ] [N1: No debug log when HTML parsing fails to extract a channel](#n1-no-debug-log-when-html-parsing-fails-to-extract-a-channel)

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

### M1: manifest.json version should be 0.0.0

**File:** `companion/manifest.json`  
**Classification:** 🆕 New  
**Reviewer:** Kaylee

**Issue:**  
The `version` field in `companion/manifest.json` should be set to `"0.0.0"` per the module template. The version in this file is not used for packaging — `package.json` controls the published version — but having a non-`0.0.0` value is a template deviation.

**Fix:** Set `"version": "0.0.0"` in `companion/manifest.json`.

---

### M2: Module name does not match id in manifest.json

**File:** `companion/manifest.json`  
**Classification:** 🆕 New  
**Reviewer:** Kaylee

**Issue:**  
The `name` field in `companion/manifest.json` should match the `id` field. Mismatched values can cause confusion in the Companion module registry.

**Fix:** Set `"name"` to match the `"id"` value in `companion/manifest.json`.

---

### M3: LICENSE file does not match template

**File:** `LICENSE`  
**Classification:** 🆕 New  
**Reviewer:** Kaylee

**Issue:**  
The `LICENSE` file contents do not match the standard LICENSE file from the companion-module-template repository. The template LICENSE file should be used as-is.

**Fix:** Replace `LICENSE` with the content from the companion-module-template repo's LICENSE file.

---

### M4: Concurrent polls possible when poll duration exceeds interval

**File:** `src/main.js` (polling setup)  
**Classification:** 🆕 New  
**Reviewer:** Wash

**Issue:**  
`pollDevice()` is fired via `setInterval`. If a poll takes longer than the configured interval (e.g., slow device response + 4 s timeout on a 2 s interval), two polls can run concurrently, potentially causing rapid status flipping if one succeeds and one fails.

**Impact:** Low in practice — the 4 s request timeout is above the 5 s default interval, so overlap requires both a slow device and a user-configured minimum (2 s) interval.

**Recommended fix:** Use a self-scheduling pattern (call `setTimeout` at the end of each poll) rather than `setInterval`, or skip a poll if one is already in flight.

---

## 💡 Nice to Have

### N1: No debug log when HTML parsing fails to extract a channel

**File:** `src/main.js` (parseStatusPage)  
**Classification:** 🆕 New  
**Reviewer:** Wash

A low-cost debug log when a channel regex fails to match would help diagnose future firmware-related state-sync failures. No code change needed until a user reports issues.

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
