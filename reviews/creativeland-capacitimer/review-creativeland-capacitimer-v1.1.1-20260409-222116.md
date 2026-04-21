# Review — creativeland-capacitimer v1.1.1

**Date:** 2026-04-09  
**Reviewer Team:** Mal 🏗️ · Wash 🔧 · Kaylee ⚛️ · Zoe 🧪 · Simon 🧬  
**Prior Approved Version:** v1.0.1  
**Change scope:** Significant update (~1,448 insertions across 12 files) adding Pro license gating, Bonjour/mDNS device discovery, WebSocket port scanning, display management, message overlays, and a unified `timer_color` feedback replacing three separate feedback IDs.

---

## 📊 Scorecard

| Severity | New | Pre-existing |
|----------|-----|--------------|
| 🔴 Critical | 0 | 0 |
| 🟠 High | 3 | 0 |
| 🟡 Medium | 0 | 0 |
| 🟢 Low | 3 | — |
| 💡 NTH | — | — |

**Tests:** None (non-blocking)  
**Build:** ✅ PASS (`yarn install` + `yarn package` clean)

---

## ✋ Verdict

> ⛔ **CHANGES REQUIRED** — 3 blocking issues (3 High NEW)

---

## 📋 Issues

**Blocking**
- [ ] [H1: Missing upgrade scripts for 3 removed feedback IDs](#h1--missing-upgrade-scripts-for-3-removed-feedback-ids)
- [ ] [H2: `set_timer_font` moved to Pro-only with no saved-config migration](#h2--set_timer_font-moved-to-pro-only-with-no-saved-config-migration)
- [ ] [H3: JavaScript files should be in `src` directory](#h3--javascript-files-should-be-in-src-directory)
- [ ] [L1: `manifest.runtime.apiVersion` set to `"1.12.0"` instead of `"0.0.0"`](#l1--manifestruntimeapiversion-set-to-1120-instead-of-000)
- [ ] [L2: Removed variables not documented in HELP](#l2--removed-variables-not-documented-in-help)
- [ ] [L3: Typo in preset name](#l3--typo-in-preset-name)

---

## 🟠 High Issues

### H1 🆕 Missing upgrade scripts for 3 removed feedback IDs

**File:** `upgrades.js` (empty)

Three advanced-color feedbacks present in v1.0.1 saved configs no longer exist in v1.1.1:

| Removed ID | Replaced by |
|------------|------------|
| `timer_color_normal` | `timer_color` |
| `timer_color_warning` | `timer_color` |
| `timer_color_critical` | `timer_color` |

`upgrades.js` remains an empty stub. Any user who had these feedbacks on a Companion button will silently find them orphaned — the button loses its color feedback behavior with no error message.

**Fix:** Add a single upgrade function as the first entry in `upgrades.js`:

```js
function upgradeV110(context, props) {
    const updatedFeedbacks = []
    const oldIds = ['timer_color_normal', 'timer_color_warning', 'timer_color_critical']
    for (const feedback of props.feedbacks) {
        if (oldIds.includes(feedback.feedbackId)) {
            updatedFeedbacks.push({
                ...feedback,
                feedbackId: 'timer_color',
                options: {},
            })
        }
    }
    return { updatedConfig: null, updatedActions: [], updatedFeedbacks }
}

module.exports = [upgradeV110]
```

Note: the new `timer_color` feedback takes no options and applies its color based on the current timer phase automatically — the best-effort migration is to remap all three old IDs to `timer_color` with empty options.

---

### H2 🆕 `set_timer_font` moved to Pro-only with no saved-config migration

**File:** `main.js` / `actions.js` / `upgrades.js`

In v1.0.1, `set_timer_font` was registered unconditionally (available to all users). In v1.1.1, it is only registered when `this.isPro` is `true`. Non-Pro users who had this action saved in a button config will have it silently become an orphaned unknown action after upgrade.

Two acceptable approaches:

**Option A (recommended):** Always register the action but disable or warn if not Pro:
```js
// In actions.js — always register, gate execution
set_timer_font: {
    name: 'Set Timer Font (Pro)',
    options: [...],
    callback: async (event) => {
        if (!self.isPro) {
            self.log('warn', 'set_timer_font requires a Pro license')
            return
        }
        // ... existing logic
    }
}
```

**Option B:** Add an upgrade script that removes `set_timer_font` actions from saved configs, so they are cleanly absent rather than silently dead (add to the `upgradeV110` function in H1):
```js
const updatedActions = props.actions.filter(a => a.actionId !== 'set_timer_font')
return { updatedConfig: null, updatedActions, updatedFeedbacks }
```

---

### H3 🆕 JavaScript files should be in `src` directory

**File:** Module root

All JavaScript implementation files (`main.js`, `actions.js`, `feedbacks.js`, `variables.js`, `presets.js`, `upgrades.js`) are located in the root of the module. Standard Companion module structure places implementation files in a `src/` subdirectory, with only `index.js` (or a symlink) at the root for the entry point.

**Fix:** Create a `src/` directory, move all implementation files into it, and ensure the entry point in `package.json` (or a root `index.js`) references `src/index.js` or `src/main.js` appropriately.

---

## 🟢 Low Issues

### L1 🆕 `manifest.runtime.apiVersion` set to `"1.12.0"` instead of `"0.0.0"`

**File:** `companion/manifest.json`

For v1.x modules, the standard template sets `"apiVersion": "0.0.0"` — `companion-module-build` auto-patches this to the actual base version at package time. Explicitly setting `"1.12.0"` deviates from the template and could cause confusion when reading the source manifest. Build verified clean, so functionally harmless.

**Recommendation:** Change to `"apiVersion": "0.0.0"` to match the standard v1.x template.

---

### L2 🆕 Removed variables not documented in HELP

**File:** `variables.js` / `companion/HELP.md`

Two variables present in v1.0.1 are gone in v1.1.1:
- `$(capacitimer:threshold_normal)` — removed entirely  
- `$(capacitimer:timer_font)` — moved to Pro-only

Users with these variable references in button text will see them stop resolving silently. The SDK has no upgrade path for variable removal, but HELP.md and README.md should note the change explicitly.

---

### L3 🆕 Typo in preset name

**File:** `presets.js:141`

`'Set Timer to 1 Minutes'` should be `'Set Timer to 1 Minute'` (singular).

---

## 🧪 Tests

**No tests found.** The module contains no test files (`*.test.js`, `*.spec.js`, or similar) and no `test` script in `package.json`.

**Non-blocking** — test coverage is not required for v1.x modules. A future release should introduce at least unit tests for WebSocket message parsing and the port-scan state machine.

**Build result:** `yarn install` + `yarn package` — ✅ PASS (clean, no errors)

---

## ✅ What's Solid

- **Pro feature gating is well-structured** — `isPro` cleanly gates actions, feedbacks, and variables; definitions rebuild correctly when license state changes via `fetchLicenseStatus()`
- **Bonjour/mDNS cleanup is correct** — `stopBonjourDiscovery()` calls both `bonjourBrowser.stop()` and `bonjour.destroy()`; `discoveredInstances` is cleared on `destroy()`; no resource leak on module teardown
- **WebSocket port-scan strategy is clever UX** — fetching `wsPort` from the REST endpoint first, then falling back to scanning 3001–3010, handles the common case and firmware variation cleanly
- **JSON message parsing is safe** — every `JSON.parse()` is wrapped in `try/catch`; malformed messages are logged and discarded without crashing
- **No-host guards are correct** — both `init()` and `configUpdated()` skip WebSocket connection when no host is configured and set `InstanceStatus.Disconnected` with a clear message
- **All action callbacks are void-returning** — `async` callbacks return `undefined` correctly per v1.x API requirement
- **Comprehensive preset library** — covers timer control, set timer (8 presets), adjust timer, display control, and status; Pro-only presets correctly gated
- **API.md is detailed and current** — covers all REST endpoints, WebSocket events, Pro-gated endpoints, and response formats; consistent with the implementation
- **No hardcoded credentials or secrets** found; no `eval` or `new Function` patterns
- **Manifest is clean** — version matches `package.json`, no banned `"companion"` keyword in keywords array
- **`sendCommand` guards the Pro error payload** — `data.success === true` check prevents a `{ success: false, message: "..." }` response from corrupting `this.messageState`
