# Review: companion-module-neol-epowerswitch @ 1.1.1

**Reviewed by:** Mal, Wash, Kaylee, Zoe, Simon  
**Requested by:** Justin James  
**Module:** [companion-module-neol-epowerswitch](https://github.com/bitfocus/companion-module-neol-epowerswitch)  
**Release tag:** `1.1.1`  
**Previous tag:** *(none — first release)*  
**API version:** v1.x (`@companion-module/base ~1.11.3`)  
**Language:** JavaScript (ESM, `"type": "module"`)  
**Date:** 2026-04-06

---

## Fix Summary for Maintainer

The module code is genuinely solid — good HTTP implementation, clean architecture, and thorough operator UX. The rejection is entirely template compliance. Here's what needs to change:

1. **`package.json`** — rename `build` script to `package`; add `"format": "prettier -w ."`; change `engines.node` to `"^22.x"`; add `"yarn": "^4"` to engines; change `prettier` field to `"@companion-module/tools/.prettierrc.json"`; add `git+` prefix to `repository.url`
2. **`companion/manifest.json`** — add `git+` prefix to `repository`; change `runtime.type` to `"node22"`; change `runtime.entrypoint` to `"../src/main.js"`; remove `"neol"` and `"epowerswitch"` from `keywords`
3. **Entry point** — rename `src/index.js` → `src/main.js`; update `package.json` `main` to `"src/main.js"`; delete root `index.js`
4. **`.prettierignore`** — replace contents with just `package.json` and `/LICENSE.md`
5. **`src/upgrade.js`** — remove dead upgrade scripts (they reference actions/config that don't exist in this module)
6. **`.gitignore`** — add `dist/` (and optionally `*.log`, `.DS_Store`)
7. **`src/index.js`** — add explicit `stopPolling(this)` at the top of `configUpdated()` before any re-initialization

---

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 10 | 0 | 10 |
| 🟠 High | 3 | 0 | 3 |
| 🟡 Medium | 3 | 0 | 3 |
| 🟢 Low | 1 | 0 | 1 |
| 💡 Nice to Have | 5 | 0 | 5 |
| **Total** | **22** | **0** | **22** |

**Blocking:** 16 issues (10 new critical, 3 new high, 3 new medium)  
**Fix complexity:** Medium — multiple one-line config fixes plus a source file rename and entry point restructure  
**Health delta:** 22 introduced · 0 pre-existing

---

## Verdict

**❌ CHANGES REQUIRED**  
10 template compliance violations block approval. The module code itself is well-written — all blocking issues are configuration, packaging, and structural corrections.

---

## 📋 Issues

**Blocking**
- [ ] [C1: Root `index.js` wrapper — entry point must be `src/main.js`](#c1-root-indexjs-wrapper--entry-point-must-be-srcmainjs)
- [ ] [C2: `manifest.json` `runtime.entrypoint` must be `../src/main.js`](#c2-manifestjson-runtimeentrypoint-must-be-srcmainjs)
- [ ] [C3: `package.json` missing `format` script](#c3-packagejson-missing-format-script)
- [ ] [C4: `package.json` `build` script must be named `package`](#c4-packagejson-build-script-must-be-named-package)
- [ ] [C5: `package.json` `engines.node` must be `^22.x`](#c5-packagejson-enginesnode-must-be-22x)
- [ ] [C6: `package.json` missing `engines.yarn` field](#c6-packagejson-missing-enginesyarn-field)
- [ ] [C7: `package.json` `prettier` field points to wrong path](#c7-packagejson-prettier-field-points-to-wrong-path)
- [ ] [C8: `package.json` `repository.url` missing `git+` prefix](#c8-packagejson-repositoryurl-missing-git-prefix)
- [ ] [C9: `manifest.json` `repository` URL missing `git+` prefix](#c9-manifestjson-repository-url-missing-git-prefix)
- [ ] [C10: `manifest.json` banned keywords present](#c10-manifestjson-banned-keywords-present)
- [ ] [H1: `.prettierignore` contains extra entries beyond template](#h1-prettierignore-contains-extra-entries-beyond-template)
- [ ] [H2: `manifest.json` `runtime.type` is `node18` — must be `node22`](#h2-manifestjson-runtimetype-is-node18--must-be-node22)
- [ ] [H3: `@companion-module/tools` peer dependency mismatch](#h3-companion-moduletools-peer-dependency-mismatch)
- [ ] [M1: `.gitignore` missing `dist/` and build artifacts](#m1-gitignore-missing-dist-and-build-artifacts)
- [ ] [M2: Upgrade scripts are dead code from another module](#m2-upgrade-scripts-are-dead-code-from-another-module)
- [ ] [M3: Race condition in `configUpdated()` — missing explicit `stopPolling()` call](#m3-race-condition-in-configupdated--missing-explicit-stoppolling-call)

**Non-blocking**
- [ ] [L2: Swallowed errors in poll intervals — no persistent-failure signal](#l2-swallowed-errors-in-poll-intervals--no-persistent-failure-signal)
- [ ] [N1: Use `Connecting` status during initial startup](#n1-use-connecting-status-during-initial-startup)
- [ ] [N2: Default config object duplicated in `init()` and `configUpdated()`](#n2-default-config-object-duplicated-in-init-and-configupdated)
- [ ] [N3: Error logs missing URL/outlet context](#n3-error-logs-missing-urloutlet-context)
- [ ] [N4: Config fields use `tooltip` instead of `help`](#n4-config-fields-use-tooltip-instead-of-help)
- [ ] [N5: Action and feedback descriptions are too technical](#n5-action-and-feedback-descriptions-are-too-technical)

---

## 🔴 Critical

### C1: Root `index.js` wrapper — entry point must be `src/main.js`

**File:** `index.js`, `package.json` line 4  
**Classification:** 🆕 NEW  

The module has a root-level `index.js` that contains only `import './src/index.js'` — a shim to work around `"main": "index.js"` in `package.json`. The template requires all source code to live in `src/`, with `package.json` pointing directly to `src/main.js`.

**Required changes:**
1. Rename `src/index.js` → `src/main.js`
2. Change `package.json` `"main"` from `"index.js"` to `"src/main.js"`
3. Delete root-level `index.js`

---

### C2: `manifest.json` `runtime.entrypoint` must be `../src/main.js`

**File:** `companion/manifest.json` line 21  
**Classification:** 🆕 NEW  

Tied directly to C1. The manifest entrypoint is `"../index.js"` — must be updated to `"../src/main.js"` after renaming the entry file.

**Required change:**
```json
"entrypoint": "../src/main.js"
```

---

### C3: `package.json` missing `format` script

**File:** `package.json` lines 20–23  
**Classification:** 🆕 NEW  

The `scripts` section has no `format` script. Template requires:

```json
"format": "prettier -w ."
```

Current scripts only have `build` and `lint`.

---

### C4: `package.json` `build` script must be named `package`

**File:** `package.json` line 21  
**Classification:** 🆕 NEW  

The `companion-module-build` command is registered as `"build"`. Template standardizes on `"package"` as the script name for the packaging command across all modules.

**Required change:**
```json
"package": "companion-module-build"
```

(Remove `"build": "companion-module-build"` and add `"package": "companion-module-build"`.)

---

### C5: `package.json` `engines.node` must be `^22.x`

**File:** `package.json` lines 16–18  
**Classification:** 🆕 NEW  

Current value is `">=18 <21"`. Template requires `"^22.20"` or `"^22.x"`.

**Required change:**
```json
"engines": {
  "node": "^22.x",
  "yarn": "^4"
}
```

---

### C6: `package.json` missing `engines.yarn` field

**File:** `package.json` lines 16–18  
**Classification:** 🆕 NEW  

The `engines` object only contains `node`. Template requires `yarn` to also be specified.

**Required addition:**
```json
"yarn": "^4"
```

---

### C7: `package.json` `prettier` field points to wrong path

**File:** `package.json` line 34  
**Classification:** 🆕 NEW  

Current value: `"@companion-module/tools/prettier"`  
Required value: `"@companion-module/tools/.prettierrc.json"`

---

### C8: `package.json` `repository.url` missing `git+` prefix

**File:** `package.json` line 10  
**Classification:** 🆕 NEW  

Current: `"https://github.com/bitfocus/companion-module-neol-epowerswitch.git"`  
Required: `"git+https://github.com/bitfocus/companion-module-neol-epowerswitch.git"`

---

### C9: `manifest.json` `repository` URL missing `git+` prefix

**File:** `companion/manifest.json` line 8  
**Classification:** 🆕 NEW  

Current: `"https://github.com/bitfocus/companion-module-neol-epowerswitch.git"`  
Required: `"git+https://github.com/bitfocus/companion-module-neol-epowerswitch.git"`

---

### C10: `manifest.json` banned keywords present

**File:** `companion/manifest.json` lines 27–37  
**Classification:** 🆕 NEW  

The `keywords` array contains the manufacturer name (`"neol"`) and product name (`"epowerswitch"`), both of which are banned per template rules.

**Required change — remove these two entries:**
```json
"neol",        ← remove
"epowerswitch" ← remove
```

Remaining keywords (`"power"`, `"pdu"`, `"relay"`, `"outlet"`, `"http"`, `"power-switch"`, `"remote-power"`) are all fine.

---

## 🟠 High

### H1: `.prettierignore` contains extra entries beyond template

**File:** `.prettierignore` lines 1–6  
**Classification:** 🆕 NEW  

The `.prettierignore` file has been populated with what appears to be `.gitignore` content. Template requires exactly two entries:

```
package.json
/LICENSE.md
```

Current file contains `node_modules/`, `yarn.lock`, `package-lock.json`, `.yarn/`, `dist/`, `build/` — none of which should be in `.prettierignore`.

---

### H2: `manifest.json` `runtime.type` is `node18` — must be `node22`

**File:** `companion/manifest.json` line 18  
**Classification:** 🆕 NEW  

Node 18 reached end-of-life in April 2025. The runtime entry must declare `"node22"`:

```json
"runtime": {
  "type": "node22",
  ...
}
```

---

### H3: `@companion-module/tools` peer dependency mismatch

**File:** `package.json` line 32  
**Classification:** 🆕 NEW  

`@companion-module/tools@2.5.0` declares a peer dependency of `@companion-module/base ^1.12.0`, but this module uses `~1.11.3`. Yarn warns on install:

```
YN0060: @companion-module/base is listed by your project with version 1.11.3, 
        which doesn't satisfy what @companion-module/tools requests (^1.12.0).
```

**Resolution options (choose one):**
1. Upgrade `@companion-module/base` to `~1.12.0` (preferred — picks up latest v1.x fixes)
2. Pin `@companion-module/tools` to a version compatible with `base` `1.11.3`

The build succeeded despite the warning, but peer mismatches can cause unexpected runtime behavior.

---

## 🟡 Medium

### M1: `.gitignore` missing `dist/` and build artifacts

**File:** `.gitignore`  
**Classification:** 🆕 NEW  

`dist/` is not listed in `.gitignore`. If a contributor ever runs the build locally, the output could be accidentally committed. Template includes `dist/` plus common OS artifacts (`.DS_Store`, `*.log`, `.vscode/`, `.idea/`).

**Required addition at minimum:**
```
dist/
```

---

### M2: Upgrade scripts are dead code from another module

**File:** `src/upgrade.js` lines 2–36  
**Classification:** 🆕 NEW  

The two upgrade script functions reference things that have never existed in this module:

- `v1_1_4` targets action IDs `post`, `put`, `patch` — this module only has `toggle_outlet_hidden`
- `v1_1_6` sets a `rejectUnauthorized` config key — this module has no such config field

The scripts are harmless (they'll never match anything), but they indicate copy-paste from another module without cleanup and are confusing for future maintainers. Since this is a first release, the correct action is to **remove both functions** and export an empty array (or remove the export entirely if Companion allows it).

---

### M3: Race condition in `configUpdated()` — missing explicit `stopPolling()` call

**File:** `src/index.js` lines 17–33  
**Classification:** 🆕 NEW  

`startPolling()` internally calls `stopPolling()` (polling.js line 13), but if `configUpdated()` is called rapidly (e.g., user typing a new IP), the actions/feedbacks/variables are re-initialized on lines 26–29 while the old polling timer may still be mid-tick. Adding an explicit `stopPolling(this)` at the top of `configUpdated()` guarantees clean teardown before any state changes.

**Required change:**
```javascript
configUpdated(config) {
    stopPolling(this)       // ← add this line
    this.config = { ... }
    this.updateStatus(InstanceStatus.Ok)
    initActions(this)
    // ...
}
```

---

## 🟢 Low

### L2: Swallowed errors in poll intervals — no persistent-failure signal

**File:** `src/polling.js` lines 19, 22, 71  
**Classification:** 🆕 NEW  

`pollStatus()` is called with `.catch(() => {})` in three places. While individual errors are caught and logged inside `pollStatus()`, there's no mechanism to signal "this has been failing for an extended period." An operator has no way to distinguish a one-time hiccup from a module that's been offline for an hour.

A simple failure counter (reset on success, log a warning after N consecutive failures) would improve troubleshooting on live shows.

---

## 💡 Nice to Have

### N1: Use `Connecting` status during initial startup

**File:** `src/index.js` lines 25, 43  
**Classification:** 🆕 NEW  

Both `init()` and `configUpdated()` set `InstanceStatus.Ok` before any successful HTTP poll. Consider setting `InstanceStatus.Connecting` first, then transitioning to `Ok` only after the first successful `pollStatus()`. Users get clearer feedback during startup.

---

### N2: Default config object duplicated in `init()` and `configUpdated()`

**File:** `src/index.js` lines 18–23, 36–41  
**Classification:** 🆕 NEW  

`{ prefix: '', hiddenPath: '/hidden.htm', statusPollInterval: 1000 }` is copy-pasted in two places. Extract to a `DEFAULT_CONFIG` constant.

---

### N3: Error logs missing URL/outlet context

**File:** `src/polling.js` lines 73–75, 132–134  
**Classification:** 🆕 NEW  

Error log messages don't include the target URL or outlet number. Adding context (e.g., `"Hidden command error for outlet 2: ECONNREFUSED"`) makes log inspection faster on live shows.

---

### N4: Config fields use `tooltip` instead of `help`

**File:** `src/config.js`  
**Classification:** 🆕 NEW  

The config fields use the older `tooltip` property (hover-only hint) rather than `help` (always-visible hint text below the input). `help` is the modern standard in `@companion-module/base` v1.13+.

---

### N5: Action and feedback descriptions are too technical

**File:** `src/actions.js` line 6, `src/feedbacks.js` line 7  
**Classification:** 🆕 NEW  

Action description: `"Sends hidden.htm command M0:O{n}=ON/OFF. Toggle uses current polled state."` — exposes device-internal HTTP details the operator doesn't need to know.

Feedback description: `"Outlet is ON (state comes from shared polling of hidden.htm)"` — same issue.

Suggested replacements:
- Action: `"Control power outlet — turn on, off, or toggle based on current state."`
- Feedback: `"Returns true when the outlet is powered on."`

---

## 🔮 Next Release

**Add configurable HTTP timeout** — `src/polling.js` lines 59, 88. The 5-second timeout is hardcoded. Users on slow or congested networks (e.g., venue Wi-Fi) may benefit from a configurable timeout field in the config schema.

**Consider retry logic with backoff** — both `sendOutletCommand()` and `pollStatus()` fail immediately on network errors. One or two retries with a short delay would improve reliability during transient issues without adding significant latency.

---

## 🧪 Tests

No tests present — none required. *(Simon)*

---

## ✅ What's Solid

**HTTP implementation is production-ready.** All `got` calls are wrapped in `try/catch`, timeouts are configured correctly (5s via `got` v14 `timeout: { request: 5000 }`), `throwHttpErrors: false` is used correctly to allow manual status code checking, and there are zero unhandled promise rejections. *(Wash)*

**SDK compliance is clean.** `runEntrypoint(EPowerSwitchInstance, upgradeScripts)` is correctly called (v1.x requirement). `init()`, `configUpdated()`, `destroy()`, and `getConfigFields()` are all properly implemented. All relative imports use `.js` extensions as required for ESM. *(Mal)*

**Polling lifecycle is solid.** `startPolling()` always calls `stopPolling()` first (preventing timer leaks), `destroy()` properly clears the interval timer, and an immediate poll fires on start to populate state quickly. *(Wash, Mal)*

**Source code architecture is well-structured.** Clean separation of concerns across `actions.js`, `feedbacks.js`, `presets.js`, `variables.js`, `config.js`, `polling.js`, and `upgrade.js`. The main entry file delegates cleanly with no mixed concerns. *(Mal)*

**Response parsing is defensive.** Regex extraction of outlet states from the `hidden.htm` response validates that at least one outlet was found; sets `InstanceStatus.UnknownError` on malformed/unexpected device responses rather than silently using stale data. *(Wash, Zoe)*

**Operator UX is thorough.** Presets are provided for all four outlets (action + feedback bundled). Eight variables cover both current state and next-command-direction per outlet. `HELP.md` is genuine documentation with setup screenshots and variable reference — not a placeholder. *(Kaylee)*

**No memory leaks.** `got` manages connection pooling internally. No manually added event listeners that skip cleanup. `destroy()` is sufficient for full resource release. *(Zoe)*

**Build succeeds cleanly.** `yarn install && yarn build` completes without errors and produces `neol-epowerswitch-1.1.1.tgz`. No `package-lock.json` present. `yarn.lock` is committed and current. *(Kaylee)*

**`LICENSE` is valid MIT** with a real copyright holder (`Copyright (c) 2026 Alex Zahel`) — no placeholder text. *(Kaylee)*

**URL construction handles edge cases.** The `buildUrl()` function correctly strips duplicate slashes when both the base URL and path contain `/`, preventing malformed requests like `http://10.3.0.235//hidden.htm`. *(Wash)*
