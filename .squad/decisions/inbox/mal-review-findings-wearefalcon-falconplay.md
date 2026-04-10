# Mal Review Findings: companion-module-wearefalcon-falconplay v1.0.0

**Reviewer:** Mal (Lead)  
**Module:** companion-module-wearefalcon-falconplay  
**Version:** v1.0.0 (first release)  
**API Version:** v1.12 (@companion-module/base ~1.12.1)  
**Language:** JavaScript  
**Review Date:** 2026-04-09  
**Requested By:** Justin James

---

## VERDICT: ⚠️ CHANGES REQUIRED

This module cannot be merged as-is. Multiple structural and naming issues must be resolved before acceptance.

**Blocking Issues:**
- 🔴 Module name mismatch in package.json
- 🔴 Repository URL points to personal repo, not bitfocus
- 🟠 Duplicate source files at root level (outdated, confusing structure)
- 🟠 Outdated @companion-module/tools version

---

## 🔴 CRITICAL

### 1. Module Name Mismatch
**File:** `package.json:2`  
**Issue:** Package name is `companion-module-falcon-play` but the repo is named `companion-module-wearefalcon-falconplay`.

```json
"name": "companion-module-falcon-play",
```

**Expected:** `companion-module-wearefalcon-falconplay` (matching repository and manufacturer name).

**Impact:** Name inconsistency breaks module identification in Companion registry and creates confusion about manufacturer identity.

---

### 2. Repository URL Points to Personal Account
**File:** `package.json:10-12`  
**Issue:** Repository URL points to `github.com/MoodyJerup/companion-falconplay.git` instead of the official bitfocus repository.

```json
"repository": {
  "type": "git",
  "url": "git+https://github.com/MoodyJerup/companion-falconplay.git"
},
```

**Expected:** URL should point to `git+https://github.com/bitfocus/companion-module-wearefalcon-falconplay.git` once merged into the official modules repo.

**Impact:** Users cannot find the official repo; PRs and issues will go to wrong location.

---

## 🟠 HIGH

### 3. Duplicate Source Files at Root Level (Outdated Code)
**Files:** `actions.js`, `feedbacks.js`, `main.js`, `variables.js` (root level)  
**Issue:** The module has **two sets** of source files:
- Root level: `main.js` (227 lines, older code using `http` module)
- `src/` directory: `src/main.js` (192 lines, updated code using `fetch`)

The root-level files are **outdated** — `main.js` uses the Node.js `http` module with manual Promise wrappers, while `src/main.js` correctly uses modern `fetch` API with `AbortSignal.timeout()`.

**Difference Example (main.js):**
- Root `main.js:2`: imports `const http = require('http')`
- Root `main.js:73-88`: manual `httpGet()` using `http.get()` Promise wrapper
- `src/main.js:72-75`: clean `async httpGet()` using `fetch`

**Additional Differences:**
- `actions.js` (root): 311 lines, **missing** graphic stop/clear actions
- `src/actions.js`: 444 lines, **includes** `stopGraphic`, `clearGraphic`, `stopGraphicAll`, `clearGraphicAll` actions

**Why This Exists:** Likely leftover from development refactoring. The `package.json:4` correctly points to `"main": "src/main.js"`, so the root files are not loaded — but they are **confusing clutter** and contain outdated code.

**Impact:** Maintainer confusion, potential accidental edits to wrong files, bloated repository size.

**Fix:** Delete root-level `actions.js`, `feedbacks.js`, `main.js`, `variables.js`. Only `src/` directory should contain source files.

---

### 4. Outdated @companion-module/tools Version
**File:** `package.json:22`  
**Issue:** Uses `@companion-module/tools` version `^2.4.2` — this is outdated. Current template requires newer versions (2.5.x+).

```json
"@companion-module/tools": "^2.4.2"
```

**Impact:** Missing bug fixes, linting improvements, and build tool updates. May cause issues with future module packaging.

**Fix:** Update to `^2.5.0` or later (check latest stable version).

---

## 🟡 MEDIUM

### 5. Manifest ID Mismatch
**File:** `companion/manifest.json:2-3`  
**Issue:** Manifest uses `"id": "falcon-play"` and `"name": "falcon-play"`, but the package and repo name should be `wearefalcon-falconplay`.

```json
"id": "falcon-play",
"name": "falcon-play",
```

**Expected:** 
```json
"id": "wearefalcon-falconplay",
"name": "wearefalcon-falconplay",
```

**Impact:** Module ID inconsistency can cause Companion module registry conflicts if another manufacturer creates a "falcon-play" module.

---

### 6. Manifest Repository URL Mismatch
**File:** `companion/manifest.json:8-9`  
**Issue:** Same as #2 — repository URL in manifest points to personal repo.

```json
"repository": "git+https://github.com/MoodyJerup/companion-falconplay.git",
"bugs": "https://github.com/MoodyJerup/companion-falconplay/issues",
```

**Fix:** Update to bitfocus repository URLs once merged.

---

### 7. No Explicit CJS Declaration (Minor Risk)
**File:** `package.json`  
**Issue:** The module does not explicitly declare `"type": "commonjs"` in package.json. For v1.x modules using CJS (which this is), this is normally implicit, but being explicit is safer.

**Current State:**
- Uses `require()` throughout (CJS)
- No `"type"` field in package.json → defaults to CJS
- Manifest correctly sets `"type": "node22"` with `"api": "nodejs-ipc"`

**Risk:** Low. The module will work as-is, but explicit declaration prevents accidental ESM interpretation if a future maintainer adds ESM features.

**Recommendation (non-blocking):** Add `"type": "commonjs"` to package.json for clarity.

---

## 🟢 LOW

### 8. Missing upgrades.js at Root Level
**File:** Root directory  
**Issue:** There's `src/upgrades.js` but no `upgrades.js` at the root. This is consistent with the other files being outdated at root, but worth noting.

**Impact:** None — package.json correctly points to `src/main.js`, which imports `./upgrades` from `src/`.

**Action:** None required (will be resolved when root files are deleted as per #3).

---

## 💡 NICE TO HAVE

### 9. Config Field Width Declaration (Deprecated Pattern)
**Files:** `src/main.js:50`, `src/main.js:57`  
**Issue:** Config fields use `width: 8` and `width: 4` — this is a deprecated layout hint from older Companion versions. As of v1.14 (API v1.14), Companion uses automated config layout by default.

```js
{
  type: 'textinput',
  id: 'host',
  label: 'Falcon Play Server IP',
  width: 8,  // ← deprecated
  regex: Regex.IP,
  default: '127.0.0.1',
},
```

**Impact:** The `width` field is ignored in Companion 4.2+ (API v1.14). No functional issue, but clutters the code.

**Recommendation:** Remove `width` fields from config definitions. Companion handles layout automatically.

---

### 10. Engine Field Specifies Exact Node Version
**File:** `package.json:14-17`  
**Issue:** Engines field specifies `"node": "^22.20"` — this is overly specific. The caret range means "22.20.x or higher", but this excludes Node 22.0–22.19, which are valid Node 22 LTS versions.

```json
"engines": {
  "node": "^22.20",
  "yarn": "^4"
},
```

**Recommendation:** Use `"node": "^22"` to accept any Node 22.x version (more flexible, aligns with manifest's `"type": "node22"`).

---

## 🔮 FUTURE CONSIDERATIONS

### Module API Upgrade Path (Next Release)
This module is on **API v1.12** (Companion 4.0+). Consider upgrading to **v1.13** (Companion 4.1+) or **v1.14** (Companion 4.2+) in a future release:

**v1.13 benefits:**
- Auto variable parsing in textinput fields with `useVariables`
- `secret-text` config field type for passwords/API keys
- Value-type feedbacks (not just boolean)

**v1.14 benefits:**
- Automated config layout (already applies — just removes need for width fields)
- Improved option field descriptions

**v2.0 (Breaking):**
- Full expression support in options
- Node 22 required (this module already uses Node 22)
- Major API modernization

**Recommendation:** Stay on v1.12 for initial release. Upgrade to v1.13+ in a later version if features are needed.

---

## ✅ WHAT'S SOLID

This module demonstrates several **strong architectural patterns**:

### Excellent SDK Compliance
- ✅ `src/main.js:193` — `runEntrypoint(ModuleInstance, UpgradeScripts)` correctly called at end of file (v1.x requirement)
- ✅ `src/upgrades.js:1` — `UpgradeScripts` exported (empty array is valid for first release)
- ✅ `src/main.js:8-20` — Extends `InstanceBase` correctly with proper constructor
- ✅ `src/main.js:22-29` — `init()` implemented with polling startup
- ✅ `src/main.js:31-34` — `destroy()` implemented with cleanup (`stopPolling()`)
- ✅ `src/main.js:36-41` — `configUpdated()` implemented with restart logic
- ✅ `src/main.js:43-62` — `getConfigFields()` implemented with proper validation (Regex.IP, Regex.PORT)

### Modern Async HTTP Implementation (src/ version)
- ✅ `src/main.js:72-85` — Uses `fetch` API with `AbortSignal.timeout(5000)` for clean timeout handling
- ✅ No manual Promise wrappers needed
- ✅ Proper error handling in polling methods

### Smart Polling Strategy
- ✅ `src/main.js:124-146` — Separate timers for status (2s) and list refresh (10s) — efficient API usage
- ✅ `src/main.js:102-110` — `stopPolling()` properly clears both timers and deletes references
- ✅ Uses `Promise.allSettled()` for parallel list fetching without cascading failures

### Well-Structured Actions
- ✅ `src/actions.js` — 13 actions covering vision mixer, rundown, graphics, media playback
- ✅ Dynamic dropdown choices built from polled server data
- ✅ Proper error handling with `try/catch` and logging

### Clean Feedbacks
- ✅ `src/feedbacks.js` — 3 boolean feedbacks (connection status, device status, input on-air)
- ✅ Proper use of `combineRgb()` for default styles
- ✅ Dynamic feedback evaluation using `self.serverStatus`

### Good Variable Definitions
- ✅ `src/variables.js` — 9 variables covering server version, rundown state, device connectivity
- ✅ Clear naming convention: `server_version`, `vision_mixer_connected`, etc.

### Solid Project Configuration
- ✅ `.gitignore` — Correctly ignores `package-lock.json`, `node_modules/`, `dist/`
- ✅ No `package-lock.json` present (yarn-only policy)
- ✅ No `dist/` directory committed
- ✅ `yarn.lock` present (dependency lock)
- ✅ Manifest uses `"type": "node22"` — modern Node.js runtime

### Comprehensive Documentation
- ✅ `companion/HELP.md` — Clear action/feedback/variable documentation
- ✅ Configuration instructions included

---

## SUMMARY FOR SUBMITTER

**Justin James,**

This module has a **solid foundation** — the architecture is clean, SDK compliance is correct, and the feature set is well-designed. The `src/` directory code is production-ready.

**However, it cannot be merged until these issues are fixed:**

1. **🔴 Package name** must be `companion-module-wearefalcon-falconplay` (not `falcon-play`)
2. **🔴 Repository URLs** must point to bitfocus repo (not MoodyJerup personal repo)
3. **🟠 Delete root-level source files** — only `src/` should contain code
4. **🟠 Update @companion-module/tools** to `^2.5.0` or later

**Recommended (non-blocking):**
- Update manifest ID to `wearefalcon-falconplay`
- Add `"type": "commonjs"` to package.json
- Remove `width` fields from config definitions (deprecated)

Once these are addressed, this module is **approved for merge**.

---

## ACTION ITEMS

**For Submitter (Blocking):**
- [ ] Update `package.json` name to `companion-module-wearefalcon-falconplay`
- [ ] Update repository URLs in `package.json` and `companion/manifest.json` to bitfocus repo
- [ ] Delete root-level `actions.js`, `feedbacks.js`, `main.js`, `variables.js`
- [ ] Update `@companion-module/tools` to `^2.5.0`+
- [ ] Update manifest ID/name to `wearefalcon-falconplay`

**For Submitter (Recommended):**
- [ ] Add `"type": "commonjs"` to package.json
- [ ] Remove `width` fields from config (lines 50, 57 in src/main.js)
- [ ] Consider changing `engines.node` to `^22` instead of `^22.20`

**For Next Review:**
- [ ] Re-review after fixes applied
- [ ] Delegate protocol testing to Wash (REST API validation)
- [ ] Delegate action/feedback testing to Kaylee (UI behavior)

---

**Review complete. Module shows strong potential but needs cleanup before merge.**

— Mal
