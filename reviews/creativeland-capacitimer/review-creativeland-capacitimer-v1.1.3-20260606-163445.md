# Review — creativeland-capacitimer v1.1.3

| | |
|---|---|
| **Module** | creativeland-capacitimer |
| **Version (reviewTag)** | v1.1.3 |
| **Previous tag** | v1.0.1 |
| **Scope** | `tag` — only the `v1.0.1..v1.1.3` diff (new/regression only) |
| **Language / API** | JavaScript · `@companion-module/base` v1.x (`~1.12.1`) |
| **Protocols** | HTTP/REST · WebSocket · Bonjour/mDNS |
| **Build** | ✅ PASS — `yarn package` produced a clean `.tgz` |
| **Review date (UTC)** | 2026-06-06 |
| **Verdict** | ❌ **CHANGES REQUIRED** — 3 blocking |

> **Note on scope & history.** This is a tag-scoped review of the `v1.0.1..v1.1.3` delta. In that range the entire module was built out (v1.0.1 was a near-empty skeleton) and all source files were moved from the repo root into `src/`, so every code finding is **🆕 NEW**. A prior review exists for **v1.1.1** (`reviews/creativeland-capacitimer/review-…-v1.1.1-…md`); where its findings are relevant they are tracked below as resolved or regressed. A v1.1.3 review produced under the old (now-removed) tooling was deliberately invalidated — this supersedes it.

---

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 2 | 0 | 2 |
| 🟠 High | 1 | 0 | 1 |
| 🟡 Medium | 2 | 0 | 2 |
| 🟢 Low | 1 | 0 | 1 |
| 💡 Nice to Have | 0 | 0 | 0 |
| **Total** | **6** | **0** | **6** |

---

## ✋ Verdict

> ❌ **CHANGES REQUIRED** — 3 blocking issues (2 🔴 Critical, 1 🟠 High).

---

## 📋 Issues

**Blocking**

- [ ] [C1: Source file index.js at module root](#c1-source-file-indexjs-at-module-root)
- [ ] [C2: package.json main points to index.js instead of src/main.js](#c2-packagejson-main-points-to-indexjs-instead-of-srcmainjs)
- [ ] [H1: Upgrade script deletes still-valid set_timer_font actions](#h1-upgrade-script-deletes-still-valid-set_timer_font-actions)

**Non-blocking**

- [ ] [M5: set_display preset action step has no options — sends NaN displayId](#m5-set_display-preset-action-step-has-no-options--sends-nan-displayid)
- [ ] [M6: Upgrade migration creates duplicate timer_color feedbacks and drops custom styling](#m6-upgrade-migration-creates-duplicate-timer_color-feedbacks-and-drops-custom-styling)
- [ ] [L3: Preset name typo Subtract 5 Minute](#l3-preset-name-typo-subtract-5-minute)

---

## 🔴 Critical

### C1: Source file index.js at module root

**File:** `index.js:1` · **Source:** deterministic template check (`SRC-AT-ROOT`)

The module places an `index.js` (`module.exports = require('./src/main')`) at the repo root. The v1 JS template requires all source to live under `src/`, with no source file at the module root. The implementation files were correctly moved into `src/` in this release, but the root `index.js` shim was left behind.

**Fix:** Delete the root `index.js` and point the entry directly at `src/main.js` (see C2). The Companion manifest `entrypoint` is already `../src/main.js`, so runtime is unaffected — this is a structure/template-compliance fix.

### C2: package.json main points to index.js instead of src/main.js

**File:** `package.json:4` · **Source:** deterministic template check (`PKG-MAIN`)

`"main": "index.js"` should be `"main": "src/main.js"` to match the template now that source lives under `src/`. Paired with C1 (the leftover root shim).

**Fix:** Set `"main": "src/main.js"` and remove the root `index.js`.

---

## 🟠 High

### H1: Upgrade script deletes still-valid set_timer_font actions

**File:** `src/upgrades.js:15` · **Classification:** 🆕 NEW (regression in upgrade behavior) · *Independently flagged by both the QA and compliance reviewers and verified directly.*

```js
const updatedActions = props.actions.filter(a => a.actionId !== 'set_timer_font')
```

This removes **every** `set_timer_font` action from users' saved button configs on upgrade. But `set_timer_font` is **not** a removed or renamed action in v1.1.3 — it is registered unconditionally at `src/actions.js:417`, outside any `isPro` block; only its *callback* is license-gated (`src/actions.js:429-430`, logs a warning and returns when not Pro). So this upgrade silently destroys working buttons for both Pro and non-Pro users, discards the user's selected font, and the action immediately re-appears empty in the action list.

**Fix:** Remove the `set_timer_font` filter entirely — the action survives, so saved instances must be preserved:

```js
return {
    updatedConfig: null,
    updatedActions: props.actions,   // do not drop set_timer_font
    updatedFeedbacks,
}
```

The runtime `if (!isPro)` guard in the callback already handles the licensing concern. If the real intent was to migrate an old hardcoded font value to the new dynamic font list, rewrite it to *preserve* the action and remap `options.font` rather than deleting it.

---

## 🟡 Medium

### M5: set_display preset action step has no options — sends NaN displayId

**File:** `src/presets.js` (`set_display` preset) · **Classification:** 🆕 NEW

The `set_display` preset's action step omits `options`, so at runtime `event.options.displayId` is `undefined` and the callback does `parseInt(undefined)` → `NaN`, sending a malformed command. The button looks valid but does nothing useful.

**Fix:** Add `options: { displayId: 'windowed' }` (or another sensible default) to the action step in the preset.

### M6: Upgrade migration creates duplicate timer_color feedbacks and drops custom styling

**File:** `src/upgrades.js:5-13` · **Classification:** 🆕 NEW

The 3-old-feedback → `timer_color` remap is functionally correct (correct IDs, and returning only changed feedbacks matches the upgrade contract), but a button that carried all three old feedbacks (`timer_color_normal`/`_warning`/`_critical`) ends up with three identical `timer_color` entries. The old feedbacks were `boolean` type with per-feedback styles; the new `timer_color` is `advanced` and computes color from the timer phase, so any custom per-feedback styling the user set is silently dropped.

**Fix:** Dedupe — emit at most one `timer_color` per parent button. Confirm the importer accepts converting a `boolean` feedback to an `advanced` one in place; if custom styling matters, document that it won't carry over.

## 🟢 Low

### L3: Preset name typo Subtract 5 Minute

**File:** `src/presets.js:454` · **Classification:** 🆕 NEW

`'Subtract 5 Minute'` should be `'Subtract 5 Minutes'`. (The prior v1.1.1 `'Set Timer to 1 Minutes'` typo is now fixed at line 141 — this is a sibling that remains.)

**Fix:** Rename to `'Subtract 5 Minutes'`.

---
