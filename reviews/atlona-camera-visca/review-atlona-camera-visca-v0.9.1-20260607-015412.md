# Review — atlona-camera-visca v0.9.1

| | |
|---|---|
| **Module** | atlona-camera-visca |
| **Review tag** | v0.9.1 |
| **Previous tag** | (none — first release) |
| **Scope** | `tag` (first release → no diff; full-module review, all findings NEW) |
| **Language / API** | JavaScript ESM · @companion-module/base v2 (^2.0.4) |
| **Template** | companion-module-template-js |
| **Reviewed at** | 2026-06-07 |

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 6 | 0 | 6 |
| 🟠 High | 1 | 0 | 1 |
| 🟡 Medium | 4 | 0 | 4 |
| 🟢 Low | 6 | 0 | 6 |
| 💡 Nice to Have | 3 | 0 | 3 |
| **Total** | **20** | **0** | **20** |

## Verdict: ❌ Changes Required

## 📋 Issues

**Blocking**

- [ ] [C1: Missing package script — yarn package build fails](#c1-missing-package-script--yarn-package-build-fails)
- [ ] [C2: `.gitattributes` required file is missing](#c2-gitattributes-required-file-is-missing)
- [ ] [C3: .gitignore missing template entry DEBUG-*](#c3-gitignore-missing-template-entry-debug-)
- [ ] [C5: `LICENSE` differs from template](#c5-license-differs-from-template)
- [ ] [C6: `repository.url` missing `git+` prefix](#c6-repositoryurl-missing-git-prefix)
- [ ] [C7: Low-value manifest keywords Camera and VISCA](#c7-low-value-manifest-keywords-camera-and-visca)
- [ ] [H1: parseVariablesInString does not exist on v2 — variable resolution silently fails](#h1-parsevariablesinstring-does-not-exist-on-v2--variable-resolution-silently-fails)
- [ ] [M1: irisLabel variable never populated due to risLabel typo](#m1-irislabel-variable-never-populated-due-to-rislabel-typo)
- [ ] [M2: lastCmdSent variable overwritten by undefined state](#m2-lastcmdsent-variable-overwritten-by-undefined-state)
- [ ] [M3: Dangling presetSelectorSet action drops the Preset Selector preset](#m3-dangling-presetselectorset-action-drops-the-preset-selector-preset)
- [ ] [M4: Context feature is non-functional — state never initialized](#m4-context-feature-is-non-functional--state-never-initialized)

**Non-blocking**

- [ ] [L1: Duplicate config field id info](#l1-duplicate-config-field-id-info)
- [ ] [L2: Socket error handler never attempts reconnect](#l2-socket-error-handler-never-attempts-reconnect)
- [ ] [L3: Action-owned timers not cleared on destroy or configUpdated](#l3-action-owned-timers-not-cleared-on-destroy-or-configupdated)
- [ ] [L4: configUpdated does not reset inquiry locks after a model change](#l4-configupdated-does-not-reset-inquiry-locks-after-a-model-change)
- [ ] [L5: Discrete pan/tilt buttons do not update panStatus/tiltStatus](#l5-discrete-pantilt-buttons-do-not-update-panstatustiltstatus)
- [ ] [L6: Sequence not-found sentinel treats seq 0 as no match](#l6-sequence-not-found-sentinel-treats-seq-0-as-no-match)
- [ ] [N1: Stale VISCA/HTTP comment in main.js](#n1-stale-viscahttp-comment-in-mainjs)
- [ ] [N2: console.error used instead of the instance logger](#n2-consoleerror-used-instead-of-the-instance-logger)
- [ ] [N3: getActionDefinitions rebuilt on every rotary invocation](#n3-getactiondefinitions-rebuilt-on-every-rotary-invocation)

---

## 🔴 Critical

### C1: Missing package script  yarn package build fails

**File:** `package.json` (scripts)
**Classification:** 🆕 NEW

`package.json` has no `package` script, so the official packaging step fails: `yarn package` exits non-zero (deterministic build gate failed). The JS template defines `"package": "companion-module-build"`; without it the module cannot be built into a distributable bundle.

**Fix (maintainer):** add `"package": "companion-module-build"` to `scripts` (and confirm `@companion-module/tools` provides the binary, which it does at `^3.0.1`). Re-run `yarn package` to confirm a clean build. Also, remove the prepare-release.py file since it is not the proper way to package a module for release.  The src/help.js file can also be removed The help.md does not need to list the actions/presets/feedbacks/variables since those are easily found using the Companion UI.  Along with removing the help.js file you should remove the hard coded help function in actions, feedbacks, presets, and variables.

### C2: .gitattributes required file is missing

**File:** `.gitattributes`
**Classification:** 🆕 NEW

The required `.gitattributes` is absent. The template ships one enforcing `* text=auto eol=lf` so line endings stay normalized across contributors.

**Fix (maintainer):** copy the template `.gitattributes` into the module root.

### C3: .gitignore missing template entry DEBUG-*

**File:** `.gitignore`
**Classification:** 🆕 NEW

The module's `.gitignore` is missing the template entry `DEBUG-*`, so Companion debug dumps could be committed accidentally.

**Fix (maintainer):** add `DEBUG-*` to `.gitignore` (extra entries beyond the template are fine).

### C5: `LICENSE` differs from template

**File:** `LICENSE`
**Classification:** 🆕 NEW

The `LICENSE` file does not match the template MIT license (line count differs). Only the copyright holder/year line may differ from the template.

**Fix (maintainer):** replace with the standard template MIT `LICENSE`, editing only the copyright line.

### C6: `repository.url` missing `git+` prefix

**File:** `package.json` (repository.url)
**Classification:** 🆕 NEW

`repository.url` is `https://github.com/bitfocus/companion-module-atlona-camera-visca.git`; the template/registry convention requires the `git+` prefix: `git+https://github.com/bitfocus/companion-module-atlona-camera-visca.git`.

**Fix (maintainer):** prefix the URL with `git+`.

### C7: Low-value manifest keywords Camera and VISCA

**File:** `companion/manifest.json` (keywords)
**Classification:** 🆕 NEW

The manifest `keywords` include `Camera` and `VISCA`, both of which duplicate words already in the module name (`atlona-camera-visca`). Keywords that restate the module name add no search value and are rejected by the registry keyword policy.

**Fix (maintainer):** remove `Camera` and `VISCA`; use distinguishing keywords (e.g. `ptz`, `atlona`, `pan-tilt-zoom`) or leave the list minimal.

---

## 🟠 High

### H1: parseVariablesInString does not exist on v2 — variable resolution silently fails

**Files:** `src/feedbacks.js:13-14`, `src/actions/utils.js:391-392`
**Classification:** 🆕 NEW

Both `parseVar`-style helpers call `self.parseVariablesInString(val)`, a method that was **removed in @companion-module/base v2** (verified: zero references in the installed `@companion-module/base@2.0.4`). The code guards with `if (self.parseVariablesInString)`, so on v2 the guard is always false and the helper returns the **raw, unparsed** string. That raw string (e.g. `$(internal:custom_x)`) is then `parseInt`/`parseFloat`-ed → `NaN`. Net effect: every `textinput` option with `useVariables: true` that a user fills with a variable fails to resolve at runtime — affects the `selectedPreset` feedback, `preset_recall` / `preset_save`, and `ptPosition` pan/tilt entry.

**Fix (maintainer):** in v2, `textinput` options with `useVariables: true` are auto-resolved by Companion before the callback runs — `event.options.<id>` already holds the resolved string. Delete the `parseVar`/`parseVariablesInString` helper and read `event.options.<id>` directly, then `parseInt`/`parseFloat`. The literal-sentinel branches (e.g. `=== 'ps'`) still work since the resolved value is a plain string.

### H2: The current jest tests are not super useful and should be removed

The current Jest test do not feel like they add value over the companion build process and should be removed.

---

## 🟡 Medium

### M1: irisLabel variable never populated due to risLabel typo

**Files:** `src/variables.js:52` (value), `src/variables.js:150` (definition)
**Classification:** 🆕 NEW

`updateVariables()` writes the key `risLabel` (typo) into the values object, but the defined variable id is `irisLabel`. `risLabel` is not a defined variable, so the active-id filter drops it and `$(atlona:irisLabel)` always renders empty.

**Fix (maintainer):** rename the value key on `variables.js:52` from `risLabel` to `irisLabel`.

### M2: lastCmdSent variable overwritten by undefined state

**Files:** `src/visca.js:468-469`, `src/variables.js:66`
**Classification:** 🆕 NEW

`#sendPacket` sets `lastCmdSent` directly via `setVariableValues({ lastCmdSent })`, but `updateVariables()` (called after almost every action) overwrites it with `this.state.lastCmdSent`, which is never assigned (always `undefined`). The variable flickers to a value and is then immediately blanked.

**Fix (maintainer):** write into `this.state.lastCmdSent` in `#sendPacket` (instead of, or in addition to, the direct variable set) so `updateVariables()` reads a real value.

### M3: Dangling presetSelectorSet action drops the Preset Selector preset

**File:** `src/presets/preset-selector.js:497-498`
**Classification:** 🆕 NEW

The "Preset Selector" rotary preset references `actionId: 'presetSelectorSet'`, which is not defined in any registered action file (`actions.js` aggregates only pan-tilt/lens/exposure/color/system/camera-presets). `presetActionsAvailable` (`presets/utils.js:17`) therefore filters the whole preset out, so it silently never appears in Companion.

**Fix (maintainer):** define a `presetSelectorSet` action (inc/dec/set of `state.presetSelector`) or remove the dangling reference.

### M4: Context feature is non-functional — state never initialized

**File:** `src/actions/contexts.js:209,275`
**Classification:** 🆕 NEW

`self.customContexts` and `self.contextState` are never initialized in `init()`/`configUpdated()`. `configureContext` early-returns on `if (self.customContexts && …)` and silently saves nothing (no log); `contextRotary` always returns at line 275. `getContextActions` is also never imported in `actions.js`, so it is dead code.

**Fix (maintainer):** initialize `this.customContexts` and `this.contextState` in `init()`, and import/register the context actions if the feature is meant to ship; otherwise gate it behind a clearly-unreleased flag.

---

## 🟢 Low

### L1: Duplicate config field id info

**File:** `src/config.js:12,42`
**Classification:** 🆕 NEW

Two `static-text` config fields share `id: 'info'`. Config field IDs should be unique; duplicates can cause one block to be dropped or to collide in stored config.

**Fix (maintainer):** give the second field a distinct id (e.g. `cameraInfo`).

### L2: Socket error handler never attempts reconnect

**File:** `src/main.js:185-192`
**Classification:** 🆕 NEW

On a socket `'error'` the status goes to `ConnectionFailure` and the socket is closed/nulled, but nothing schedules a re-init, so the instance stays dead until the user edits config or restarts Companion. The VISCA timeout path (`visca.js` `resetSequenceNumber`) recovers polling but not the socket.

**Fix (maintainer):** on socket `'error'` (and on the 10-consecutive-timeout hard reset), schedule a debounced `init_udp()` retry with backoff so the module self-heals after a transient drop.

### L3: Action-owned timers not cleared on destroy or configUpdated

**Files:** `src/actions/camera-presets.js:101`, `src/actions/lens.js:213` (and the `preset_recall` deferred `setTimeout`s)
**Classification:** 🆕 NEW

`destroy()` (`main.js:96`) clears only the VISCA poller and UDP socket. Action-owned timers (`presetSavingResetTimer`, `zoomSmoothTimer`) and deferred inquiry `setTimeout`s are not cleared, so they fire after teardown and touch `self.state`/`checkAllFeedbacks`/`VISCA.send`. Harmless today (`VISCA.send` no-ops without a socket) but leaves dangling timers across config changes.

**Fix (maintainer):** track these timers on the instance and clear them in `destroy()` and at the top of `configUpdated()`.

### L4: configUpdated does not reset inquiry locks after a model change

**File:** `src/main.js:108-116`
**Classification:** 🆕 NEW

`configUpdated()` re-runs `setupInquiries()`/`init_udp()` but does not reset `inquiryLocks`/`lastActionTime`. The reconnect itself is sequenced safely (old socket close is awaited before re-create), but stale per-key inquiry locks and telemetry from the previous model persist after the model/choices change.

**Fix (maintainer):** reset `this.inquiryLocks = {}` and `this.lastActionTime = {}` in `configUpdated()`.

### L5: Discrete pan/tilt buttons do not update panStatus/tiltStatus

**File:** `src/actions/pan-tilt.js:240-275`
**Classification:** 🆕 NEW

`panRotate`/`tiltRotate` read `self.panStatus`/`self.tiltStatus` for "same direction" speed-ramp logic, but the discrete direction buttons (`left`/`right`/`up`/`down`) never set those properties (only `stop`/`panTiltStop` do). After a discrete-direction button, a subsequent `panRotate` mis-detects direction and resets speed to 1. Logic inconsistency, not a crash.

**Fix (maintainer):** set `self.panStatus`/`self.tiltStatus` in the discrete direction callbacks too, or document the rotary actions as independent of the discrete ones.

### L6: Sequence not-found sentinel treats seq 0 as no match

**File:** `src/visca.js:172`
**Classification:** 🆕 NEW

The not-found sentinel uses falsy checks (`if (!seq)` / `seq ? … : null`) on `seq`, which comes from `#packetCounter`. Today the counter is pre-incremented so 0 is never a live key, but the falsy guard is a latent bug if the counter logic ever changes.

**Fix (maintainer):** use explicit `seq === null` / `seq !== null` for the sentinel instead of falsy checks.

---

## 💡 Nice to Have

### N1: Stale VISCA/HTTP comment in main.js

**File:** `src/main.js` (file header / line ~3)
**Classification:** 🆕 NEW

A comment references "VISCA/HTTP connections" but there is no HTTP transport. Remove the HTTP reference to avoid implying an unreviewed transport.

### N2: console.error used instead of the instance logger

**File:** `src/inquiries.js:19,34,65`
**Classification:** 🆕 NEW

`nibbleConcat`/`nibbleConcatSigned`/the no-`log` branch of `parseInquiryResponse` log via `console.error` instead of `this.log`, so they never surface in Companion's log UI. The function already accepts a `log` param (`inquiries.js:42`) — thread the instance logger through from the callback in `main.js:225`.

### N3: getActionDefinitions rebuilt on every rotary invocation

**Files:** `src/actions/exposure.js:341-384`, `src/actions/contexts.js:305,372`
**Classification:** 🆕 NEW

`smartExpRotary`/`contextRotary`/`smartExecute` call `getActionDefinitions(self)` on every invocation, rebuilding the entire action map (and re-wrapping every callback) per keypress. Bounded but wasteful on rapid rotary input.

**Fix (maintainer):** cache the built definitions, or look up the single target callback directly.

---
