# Module Review: companion-module-wearefalcon-falconplay v1.0.0

**Review date:** 2026-04-09
**Reviewer team:** Mal 🏗️ · Wash 🔧 · Kaylee ⚛️ · Zoe 🧪 · Simon 🧪
**Module version:** v1.0.0 (first release — no previous tag)
**Language:** JavaScript (CommonJS — no `"type"` field)
**API version:** v1.x (`@companion-module/base ~1.12.1`)
**Protocol:** HTTP REST polling — `GET /api/status` every 2s, list refresh every 10s
**Source layout:** Multi-file — `src/main.js`, `src/actions.js`, `src/feedbacks.js`, `src/variables.js`, `src/upgrades.js`

---

## 📊 Scorecard

| Category | New | Existing | Total |
|----------|-----|----------|-------|
| 🔴 Critical | 3 | 0 | **3** |
| 🟠 High | 1 | 0 | **1** |
| 🟡 Medium | 1 | 0 | **1** |
| 🟢 Low | 1 | 0 | **1** |
| **Total** | **6** | **0** | **6** |

---

## ✋ Verdict

> ### 🔴 CHANGES REQUIRED
>
> **4 blocking issues** (3 Critical metadata/manifest violations + 1 High functional bug).
>
> The module builds successfully but ships with its identity entirely pointing at the author's personal GitHub repo — the manifest `id`, both repository URLs, the bugs URL, and the package name all need updating to match the canonical Bitfocus repository. These are not cosmetic issues: the wrong `id` causes the built package to be named `falcon-play-1.0.0.tgz` and would cause install and upgrade mismatches in Companion.
>
> One functional bug also blocks merge: the `onAirInput` feedback has a permanently empty dropdown (never re-populated after the initial empty state). Once these 4 issues are resolved, the module is ready for merge.

---

## 📋 Issues TOC

### 🔴 Critical
- [C-1: manifest.json id and package.json name has wrong module name](#c-1-manifestjson-id-and-packagejson-name-has-wrong-module-name)
- [C-2: `manifest.json` + `package.json` repository URLs point to personal GitHub repo](#c-2-manifestjson--packagejson-repository-urls-point-to-personal-github-repo)
- [C-3: `manifest.json` `bugs` URL points to personal GitHub repo](#c-3-manifestjson-bugs-url-points-to-personal-github-repo)

### 🟠 High
- [H-1: `onAirInput` feedback dropdown permanently empty — `updateFeedbacks()` never re-called](#h-1-onairinput-feedback-dropdown-permanently-empty--updatefeedbacks-never-re-called)

### 🟡 Medium
- [M-1: Keywords include partial manufacturer name and third-party system reference](#m-1-keywords-include-partial-manufacturer-name-and-third-party-system-reference)

### 🟢 Low
- [L-1: `companion/HELP.md` missing 4 of 13 actions](#l-1-companionhelpmd-missing-4-of-13-actions)

---

## 🔴 Critical

### C-1: manifest.json id and package.json name has wrong module name

- **Severity:** 🔴 Critical
- **Classification:** 🆕 NEW — Template Compliance / Identity
- **Files:** `companion/manifest.json`, `package.json`

The manifest `id` and package `name` both use `"falcon-play"` / `"companion-module-falcon-play"` — derived from the author's personal repo name — rather than the canonical Bitfocus repository slug. Companion uses the manifest `id` to identify, install, and upgrade modules; a mismatch causes upgrade detection failures. The built package is named `falcon-play-1.0.0.tgz` instead of `wearefalcon-falconplay-1.0.0.tgz`.

**Evidence:**
```json
// companion/manifest.json
"id": "falcon-play"                              // ← should be "wearefalcon-falconplay"

// package.json
"name": "companion-module-falcon-play"           // ← should be "companion-module-wearefalcon-falconplay"
```

**Recommendation:**
- `manifest.json`: `"id": "wearefalcon-falconplay"`
- `package.json`: `"name": "companion-module-wearefalcon-falconplay"`

---

### C-2: `manifest.json` + `package.json` repository URLs point to personal GitHub repo

- **Severity:** 🔴 Critical
- **Classification:** 🆕 NEW — Template Compliance / Identity
- **Files:** `companion/manifest.json`, `package.json`

Both repository URL fields point to `MoodyJerup/companion-falconplay` — the author's personal fork — rather than the Bitfocus repository where the module will be maintained and reviewed. Bitfocus CI checks, update resolution, and community issue tracking all depend on these pointing to the correct location.

**Evidence:**
```json
// companion/manifest.json
"repository": "git+https://github.com/MoodyJerup/companion-falconplay.git"

// package.json
"repository": { "url": "git+https://github.com/MoodyJerup/companion-falconplay.git" }
```

**Recommendation:**
- `manifest.json`: `"repository": "git+https://github.com/bitfocus/companion-module-wearefalcon-falconplay.git"`
- `package.json`: `"url": "git+https://github.com/bitfocus/companion-module-wearefalcon-falconplay.git"`

---

### C-3: `manifest.json` `bugs` URL points to personal GitHub repo

- **Severity:** 🔴 Critical
- **Classification:** 🆕 NEW — Template Compliance / Identity
- **File:** `companion/manifest.json`

The `bugs` field links users to the author's personal repo issue tracker. Bug reports filed there will not reach the Bitfocus maintainer workflow.

**Found:** `"bugs": "https://github.com/MoodyJerup/companion-falconplay/issues"`
**Expected:** `"bugs": "https://github.com/bitfocus/companion-module-wearefalcon-falconplay/issues"`

---

## 🟠 High

### H-1: `onAirInput` feedback dropdown permanently empty — `updateFeedbacks()` never re-called

- **Severity:** 🟠 High
- **Classification:** 🆕 NEW
- **Files:** `src/feedbacks.js:54`, `src/main.js`

The `onAirInput` feedback builds its `choices` array from `self.inputs` at definition time:

```js
choices: self.inputs.map((inp) => ({ id: inp.input, label: inp.name })),
```

`updateFeedbacks()` is called exactly once — in `init()` when `self.inputs = []` (empty array, freshly constructed). The `refreshLists()` method later populates `self.inputs` but only calls `this.updateActions()` — `this.updateFeedbacks()` is never called again. `configUpdated()` also only calls `updateActions()`. The `onAirInput` dropdown is frozen at empty for the entire lifetime of the module instance.

**Evidence (confirmed):**
```js
// main.js — init()
this.updateFeedbacks()    // ← only call; self.inputs = [] at this point

// main.js — refreshLists() — after populating self.inputs:
if (listsChanged) {
    this.updateActions()  // ← called; updateFeedbacks() NOT called
}

// main.js — configUpdated():
this.updateActions()      // ← called; updateFeedbacks() NOT called
```

**Impact:** The `onAirInput` feedback is completely unusable. Users adding it to a button see an empty dropdown and cannot select any input.

**Recommendation:** Add `this.updateFeedbacks()` wherever `this.updateActions()` is called after list data changes — in `refreshLists()` and `configUpdated()`:
```js
if (listsChanged) {
    this.updateActions()
    this.updateFeedbacks()   // ← add this
}
```

---

## 🟡 Medium

### M-1: Keywords include partial manufacturer name and third-party system reference

- **Severity:** 🟡 Medium
- **Classification:** 🆕 NEW
- **File:** `companion/manifest.json`

Current keywords: `["falcon", "play", "casparcg", "playout", "vision mixer", "graphics"]`

Two concerns:
1. **`"falcon"`** — `"Falcon Play"` is the manufacturer. While not the full manufacturer name, `"falcon"` is the distinctive component of that name. It functions as a partial manufacturer name keyword, which should be avoided per Companion guidelines.
2. **`"casparcg"`** — CasparCG is a separate open-source playout system that Falcon Play Server controls internally. This module controls Falcon Play Server; it does not directly control CasparCG. Including `"casparcg"` as a keyword implies a direct CasparCG integration that doesn't exist at the Companion API level, and will mislead users searching for a CasparCG module.

`"play"`, `"playout"`, `"vision mixer"`, `"graphics"` are all generic descriptors that are acceptable.

**Recommendation:** Remove `"falcon"` and `"casparcg"` from keywords.

---

## 🟢 Low

### L-1: `companion/HELP.md` missing 4 of 13 actions

- **Severity:** 🟢 Low
- **Classification:** 🆕 NEW
- **File:** `companion/HELP.md`

`HELP.md` documents 8 actions but the module implements 13. The four graphic stop/clear actions are documented in `README.md` but absent from `HELP.md` (which is what Companion shows in the module help panel):

Missing: `stopGraphic`, `clearGraphic`, `stopGraphicAll`, `clearGraphicAll`

**Recommendation:** Add the four missing actions to the HELP.md actions table.

---

## 🧪 Tests

No test files found (`*.test.js`, `*.spec.js`, `__tests__/`). No test framework configured. No `test` script in `package.json`.

**Status: ✅ Non-blocking.** Expected for a first-release module. The polling and HTTP helpers would be good candidates for unit testing in a future release.

---

## ✅ What's Solid

- **Multi-file structure is clean and well-organized.** Splitting actions, feedbacks, variables, and upgrades into separate files is the correct pattern for a module of this scope
- **`Promise.allSettled` in `refreshLists()`** — each of the four list endpoints can fail independently without blocking the others; correct resilient design
- **`AbortSignal.timeout(5000)` on every HTTP call** — no indefinitely-hanging requests
- **`stopPolling()` correctly guards against double-clear** — `if (this.pollStatusTimer)` checks prevent errors on repeated calls
- **`destroy()` calls `stopPolling()`** — timer cleanup is handled correctly
- **All 13 action callbacks have `try/catch`** — no unhandled rejections from action execution
- **`pollStatus()` correctly sets `InstanceStatus.ConnectionFailure` and clears `serverStatus` on catch** — connection failure state is correct
- **`switchInput` transition options** are well thought out — cut/mix/dip/wipe/sting with configurable duration covers standard broadcast transitions
- **`graphicChannelChoices` A–Z generated programmatically** — avoids 26 copy-pasted entries; good code hygiene
- **9 variables** cover the most useful runtime state (version, rundown, on-air, cued, all device connections, file server)
- **`runEntrypoint` with `UpgradeScripts = []`** correctly wired for first release
- **`companion/HELP.md`** is real, substantive content (not a stub) — covers configuration, actions, feedbacks, and variables
