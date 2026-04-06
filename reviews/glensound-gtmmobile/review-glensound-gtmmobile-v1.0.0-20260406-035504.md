# Review: glensound-gtmmobile v1.0.0

**Module:** companion-module-glensound-gtmmobile  
**Version:** v1.0.0 (First Release)  
**API:** `@companion-module/base ~1.8.0` (v1.x API)  
**Protocol:** UDP  
**Requested by:** Justin James  
**Reviewed:** 2026-04-06  
**Lead Reviewer:** Mal

---

## Fix Summary for Maintainer

**Blocking fixes required before approval:**

1. **Add missing template files:** `.gitattributes`, `.prettierignore`, `.yarnrc.yml` — Root directory
2. **Fix `.gitignore`:** Replace with template content (`node_modules/`, `package-lock.json`, `/pkg`, `/*.tgz`, `DEBUG-*`, `/.yarn`) — `.gitignore`
3. **Fix `package.json` structure:** Add `repository.type`, change URL to `bitfocus`, add `engines.yarn: "^4"`, add `packageManager`, add `prettier` field, add `devDependencies` (`@companion-module/tools`, `prettier`), replace `scripts` with `format` and `package`, remove banned keywords (`companion`, `glensound`), update `engines.node` to `"^22.20"` — `package.json`
4. **Fix `manifest.json`:** Change `runtime.type` to `node22`, change `name` to `glensound-gtmmobile`, change repository URL to `bitfocus`, add `email` to maintainer, add `$schema` field — `companion/manifest.json`
5. **Fix channel array indexing:** Decide channel range (1-13 or 2-14) and make consistent across array init, volume parsing, variable definitions, and action/feedback choices — `src/main.js:77,288-306`, `src/variables.js:7`, `src/feedbacks.js:51`
6. **Add status update on sendCmd error:** Update `InstanceStatus.ConnectionFailure` when send fails — `src/main.js:215-218`
7. **Make socket closure async-safe:** Await socket close before calling `start()` in `configUpdated()` — `src/main.js:98-106`
8. **Generate `yarn.lock`:** Run `yarn install` after template compliance fixes — Root directory

---

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 15 | 0 | 15 |
| 🟠 High | 0 | 0 | 0 |
| 🟡 Medium | 6 | 0 | 6 |
| 🟢 Low | 10 | 0 | 10 |
| 💡 Nice to Have | 2 | 0 | 2 |
| **Total** | **33** | **0** | **33** |

**Blocking:** 15 issues (15 new critical — primarily template compliance + 3 logic errors)  
**Fix complexity:** Medium — template fixes are mechanical, logic fixes require code changes (~30 lines)  
**Health delta:** 33 introduced · 0 pre-existing (first release)

---

## Verdict: ❌ Changes Required

**Reason:** Build fails due to missing template files and incorrect `package.json` configuration. Additionally, 3 critical logic errors (channel array indexing, silent command failures, race condition on config update) must be fixed before approval.

---

## 📋 Issues

**Blocking**
- [ ] [C1: Missing required template files](#c1-missing-required-template-files)
- [ ] [C2: Incorrect `.gitignore` content](#c2-incorrect-gitignore-content)
- [ ] [C3: Missing required `package.json` fields](#c3-missing-required-packagejson-fields)
- [ ] [C4: Missing required `package.json` scripts](#c4-missing-required-packagejson-scripts)
- [ ] [C5: Missing required `devDependencies`](#c5-missing-required-devdependencies)
- [ ] [C6: Banned keywords in `package.json`](#c6-banned-keywords-in-packagejson)
- [ ] [C7: Incorrect `manifest.json` repository URL](#c7-incorrect-manifestjson-repository-url)
- [ ] [C8: Outdated runtime in `manifest.json`](#c8-outdated-runtime-in-manifestjson)
- [ ] [C9: Missing `$schema` field in `manifest.json`](#c9-missing-schema-field-in-manifestjson)
- [ ] [C10: Missing `maintainers[0].email` in `manifest.json`](#c10-missing-maintainers0email-in-manifestjson)
- [ ] [C11: Incorrect manifest `name` field](#c11-incorrect-manifest-name-field)
- [ ] [C12: Outdated `@companion-module/base` version](#c12-outdated-companion-modulebase-version)
- [ ] [C13: Channel volume array index mismatch — logic error](#c13-channel-volume-array-index-mismatch-logic-error)
- [ ] [C14: Floating promise rejection in sendCmd() — unhandled error](#c14-floating-promise-rejection-in-sendcmd-unhandled-error)
- [ ] [C15: Race condition in configUpdated() — state corruption risk](#c15-race-condition-in-configupdated-state-corruption-risk)

**Non-blocking**
- [ ] [M1: Manifest declares node18 but apiVersion 1.12.1 — consider node22](#m1-manifest-declares-node18-but-apiversion-1121-consider-node22)
- [ ] [M2: Missing error handler on bind operations](#m2-missing-error-handler-on-bind-operations)
- [ ] [M3: Inconsistent error handling in socket creation](#m3-inconsistent-error-handling-in-socket-creation)
- [ ] [M4: Mute toggle with null state — logic issue](#m4-mute-toggle-with-null-state-logic-issue)
- [ ] [M5: Channel volume toggle unsafe on null — logic issue](#m5-channel-volume-toggle-unsafe-on-null-logic-issue)
- [ ] [M6: Missing error propagation in action callbacks](#m6-missing-error-propagation-in-action-callbacks)
- [ ] [L1: Inconsistent whitespace in feedbacks.js channel choices](#l1-inconsistent-whitespace-in-feedbacksjs-channel-choices)
- [ ] [L2: Unhandled promise rejection risk in action callbacks](#l2-unhandled-promise-rejection-risk-in-action-callbacks)
- [ ] [L3: No reconnection logic after socket close/error](#l3-no-reconnection-logic-after-socket-closeerror)
- [ ] [L4: Potential race condition in configUpdated](#l4-potential-race-condition-in-configupdated)
- [ ] [L5: dropMembership called without checking if membership was added](#l5-dropmembership-called-without-checking-if-membership-was-added)
- [ ] [L6: Message parsing lacks buffer bounds validation](#l6-message-parsing-lacks-buffer-bounds-validation)
- [ ] [L7: Comment mismatch in variable loop](#l7-comment-mismatch-in-variable-loop)
- [ ] [L8: Channel 1 not controllable but listed in feedbacks](#l8-channel-1-not-controllable-but-listed-in-feedbacks)
- [ ] [L9: No validation of config.port type](#l9-no-validation-of-configport-type)
- [ ] [L10: Performance: 500ms poll rate](#l10-performance-500ms-poll-rate)
- [ ] [N1: Variables defined for channels 2-14 but feedback allows channel 1](#n1-variables-defined-for-channels-2-14-but-feedback-allows-channel-1)
- [ ] [N2: Port config field uses textinput instead of number type](#n2-port-config-field-uses-textinput-instead-of-number-type)

---

## 🔴 Critical

### C1: Missing required template files

**File:** Root directory  
**Classification:** 🆕 NEW

| File | Status |
|------|--------|
| `.gitattributes` | ❌ Missing |
| `.prettierignore` | ❌ Missing |
| `.yarnrc.yml` | ❌ Missing |
| `yarn.lock` | ❌ Missing |

**Template expects:**
- `.gitattributes`: `* text=auto eol=lf`
- `.prettierignore`: `package.json` and `/LICENSE.md`
- `.yarnrc.yml`: `nodeLinker: node-modules`
- `yarn.lock`: Generated by `yarn install` with yarn v4+

---

### C2: Incorrect `.gitignore` content

**File:** `.gitignore:1-3`  
**Classification:** 🆕 NEW

**Found:**
```
node_modules/
*.log
.DS_Store
```

**Template expects:**
```
node_modules/
package-lock.json
/pkg
/*.tgz
DEBUG-*
/.yarn
```

Missing required entries and contains non-template entries.

---

### C3: Missing required `package.json` fields

**File:** `package.json`  
**Classification:** 🆕 NEW

| Field | Required | Found |
|-------|----------|-------|
| `repository.type` | `"git"` | ❌ Missing |
| `repository.url` | `bitfocus` org URL | Personal account URL |
| `engines.node` | `"^22.20"` | `">=18.0.0"` ❌ |
| `engines.yarn` | `"^4"` | ❌ Missing |
| `prettier` | `"@companion-module/tools/.prettierrc.json"` | ❌ Missing |
| `packageManager` | `"yarn@4.x.x"` | ❌ Missing |

---

### C4: Missing required `package.json` scripts

**File:** `package.json:6-8`  
**Classification:** 🆕 NEW

**Found:**
```json
"scripts": {
  "start": "node src/main.js"
}
```

**Required:**
```json
"scripts": {
  "format": "prettier -w .",
  "package": "companion-module-build"
}
```

---

### C5: Missing required `devDependencies`

**File:** `package.json`  
**Classification:** 🆕 NEW

No `devDependencies` section exists. Template requires:
```json
"devDependencies": {
  "@companion-module/tools": "^2.6.1",
  "prettier": "^3.7.4"
}
```

---

### C6: Banned keywords in `package.json`

**File:** `package.json:10`  
**Classification:** 🆕 NEW

**Found:**
```json
"keywords": ["companion", "glensound", "gtm", "mute", "udp"]
```

Banned keywords that must be removed:
- ❌ `"companion"` — adds no value
- ❌ `"glensound"` — manufacturer name already in manifest

---

### C7: Incorrect `manifest.json` repository URL

**File:** `companion/manifest.json:8`  
**Classification:** 🆕 NEW

**Found:** `git+https://github.com/Althertime/companion-module-glensound-gtmmobile.git`  
**Expected:** `git+https://github.com/bitfocus/companion-module-glensound-gtmmobile.git`

Uses personal GitHub account instead of `bitfocus` organization.

---

### C8: Outdated runtime in `manifest.json`

**File:** `companion/manifest.json:13`  
**Classification:** 🆕 NEW

**Found:** `"type": "node18"`  
**Expected:** `"type": "node22"`

Node 22 is required for current tooling. This prevents the module from building.

---

### C9: Missing `$schema` field in `manifest.json`

**File:** `companion/manifest.json`  
**Classification:** 🆕 NEW

**Expected:**
```json
"$schema": "../node_modules/@companion-module/base/assets/manifest.schema.json"
```

---

### C10: Missing `maintainers[0].email` in `manifest.json`

**File:** `companion/manifest.json:10`  
**Classification:** 🆕 NEW

**Found:**
```json
"maintainers": [{"name": "Przemysław Matusiak"}]
```

Each maintainer must have both `name` **and** `email` fields.

---

### C11: Incorrect manifest `name` field

**File:** `companion/manifest.json:3`  
**Classification:** 🆕 NEW

**Found:** `"name": "GlenSound GTM Mobile"`  
**Expected:** `"name": "glensound-gtmmobile"`

The `name` field must equal the `id` field. Display name belongs in `shortname` only.

---

### C12: Outdated `@companion-module/base` version

**File:** `package.json:12`  
**Classification:** 🆕 NEW

**Found:** `@companion-module/base ~1.8.0`  
**Template uses:** `@companion-module/base ~1.14.1`

The module is 6 API versions behind and cannot be built with current tooling due to Node version mismatch.

---

### C13: Channel volume array index mismatch — logic error

**File:** `src/main.js:77,288-306`, `src/variables.js:7`  
**Classification:** 🆕 NEW

The `channelVolumes` array is declared with size 14 (line 77), but the volume parsing loop iterates `knob = 2; knob <= 14`, accessing index 14 (out of bounds).

Channel ranges are inconsistent across the codebase:
- Variable definitions: `k = 2; k <= 14` (variables.js:7)
- Volume report loop: `knob = 2; knob <= 14` (main.js:288)
- Variable update loop: `k = 1; k <= 13` (main.js:302)

**Impact:** Channel 14 volume data may be lost; channel 1 shows "unknown".

**Fix:** Decide on channel range (1-13 or 2-14) and make consistent everywhere.

---

### C14: Floating promise rejection in sendCmd() — unhandled error

**File:** `src/main.js:215-218`  
**Classification:** 🆕 NEW

`udpCmd.send()` callback logs errors but doesn't update `InstanceStatus`. Actions appear to succeed but silently fail.

**Fix:** Add `this.updateStatus(InstanceStatus.ConnectionFailure, ...)` on send error.

---

### C15: Race condition in configUpdated() — state corruption risk

**File:** `src/main.js:98-106`  
**Classification:** 🆕 NEW

`configUpdated()` calls `closeSockets()` synchronously then immediately `start()`. Socket close is async — new sockets may fail to bind with EADDRINUSE.

**Fix:** Make `closeSockets()` return a Promise and await it before calling `start()`.

---

## 🟡 Medium

### M1: Manifest declares node18 but apiVersion 1.12.1 — consider node22

**File:** `companion/manifest.json:11-12`  
**Classification:** 🆕 NEW

The `apiVersion` field declares `1.12.1` but `package.json` uses `@companion-module/base ~1.8.0`. These should be aligned.

---

### M2: Missing error handler on bind operations

**File:** `src/main.js:166`  
**Classification:** 🆕 NEW

The `udpStatus.bind()` call doesn't have error handling for bind failure itself. If port is in use, no error event fires because socket isn't fully initialized.

---

### M3: Inconsistent error handling in socket creation

**File:** `src/main.js:150-190`  
**Classification:** 🆕 NEW

Socket creation uses try/catch, but errors within async callbacks (bind, addMembership) are not caught. If `addMembership()` fails, socket is bound but module shows ConnectionFailure while still listening.

---

### M4: Mute toggle with null state — logic issue

**File:** `src/main.js:222`  
**Classification:** 🆕 NEW

```javascript
sendToggle() { this.muteState === false ? this.sendMute() : this.sendUnmute() }
```

When `muteState` is `null` (unknown), toggle defaults to unmute. Should either do nothing or request status first.

---

### M5: Channel volume toggle unsafe on null — logic issue

**File:** `src/actions.js:154-160`  
**Classification:** 🆕 NEW

```javascript
const current = self.channelVolumes[ch]
const newVol = current === 100 ? 0 : 100
```

If `channelVolumes[ch]` is `null`, toggle defaults to 100%. Could cause unexpected audio level changes.

---

### M6: Missing error propagation in action callbacks

**File:** `src/actions.js:55-161`  
**Classification:** 🆕 NEW

All action callbacks are `async` but never throw errors. Actions don't provide feedback to Companion about success/failure.

---

## 🟢 Low

### L1: Inconsistent whitespace in feedbacks.js channel choices

**File:** `src/feedbacks.js:51-65`  
**Classification:** 🆕 NEW

Channel 1 has proper formatting, but channels 2-14 have inconsistent indentation (tabs vs spaces). Cosmetic only.

---

### L2: Unhandled promise rejection risk in action callbacks

**File:** `src/actions.js:55,64,73,92,110,136,154`  
**Classification:** 🆕 NEW

Action callbacks are `async` but never use `await`. If async operations are added later without error handling, unhandled rejections could occur.

**Recommendation:** Remove `async` keyword since no await is used.

---

### L3: No reconnection logic after socket close/error

**File:** `src/main.js:152,163`  
**Classification:** 🆕 NEW

When socket error occurs, module logs error but doesn't attempt reconnection. Timeout handler detects loss but doesn't auto-reconnect.

---

### L4: Potential race condition in configUpdated

**File:** `src/main.js:98-106`  
**Classification:** 🆕 NEW

(Lower severity note related to C15) Very low risk in practice since UDP cleanup is fast.

---

### L5: dropMembership called without checking if membership was added

**File:** `src/main.js:202`  
**Classification:** 🆕 NEW

`closeSockets()` calls `dropMembership()` regardless of whether `addMembership()` succeeded. Caught by try/catch but wasteful.

---

### L6: Message parsing lacks buffer bounds validation

**File:** `src/main.js:254-310`  
**Classification:** 🆕 NEW

Bounds checking is actually present and correct — this is an acknowledgment note. Good defensive programming.

---

### L7: Comment mismatch in variable loop

**File:** `src/main.js:288`  
**Classification:** 🆕 NEW

Comment says offset formula is `knob + 61` but code uses `knob * 2 + 52`. No impact (comment only).

---

### L8: Channel 1 not controllable but listed in feedbacks

**File:** `src/feedbacks.js:52`  
**Classification:** 🆕 NEW

Feedback lists "Channel 1 (stereo)" but actions don't include channel 1. Operators can set feedback but can't control it.

---

### L9: No validation of config.port type

**File:** `src/main.js:213`  
**Classification:** 🆕 NEW

`parseInt(this.config?.port)` is redundant if port is already a number. Falls back to 41161 silently on invalid port.

---

### L10: Performance: 500ms poll rate

**File:** `src/main.js:179`  
**Classification:** 🆕 NEW

Polling every 500ms generates 2 packets/second. Acceptable for single device but could be configurable.

---

## 💡 Nice to Have

### N1: Variables defined for channels 2-14 but feedback allows channel 1

**File:** `src/variables.js:7`, `src/feedbacks.js:51`  
**Classification:** 🆕 NEW

Not breaking — feedback returns false for channel 1 — but inconsistent.

---

### N2: Port config field uses textinput instead of number type

**File:** `src/main.js:119-125`  
**Classification:** 🆕 NEW

Could use `type: 'number'` with min/max constraints for better UX.

---

## 🔮 Next Release

- Upgrade to API v1.14+ for `isVisibleExpression`, Node permissions model, and automated config layout
- Add upgrade scripts if config schema changes
- Consider adding presets for common button configurations
- Make poll interval configurable (200-2000ms range)
- Add auto-reconnect logic on socket errors

---

## 🧪 Tests

No automated tests exist for this module. Manual testing should verify:

1. ✅ Module loads without errors
2. ⚠️ Channel 14 volume control (blocked by C13)
3. ⚠️ Mute toggle before first status response (blocked by M4)
4. ⚠️ Rapid config changes (blocked by C15)
5. ⚠️ Network disconnect recovery

---

## ✅ What's Solid

Despite the critical template compliance violations, the **module code itself is well-written**:

1. **Entry point correct:** `runEntrypoint(GlenSoundGTMMobile, [])` at `src/main.js:313` ✓
2. **All lifecycle methods implemented:** `init()`, `destroy()`, `configUpdated()`, `getConfigFields()` ✓
3. **Clean socket cleanup:** `closeSockets()` properly clears intervals and closes both UDP sockets ✓
4. **No package-lock.json** ✓
5. **No dist/ committed** ✓
6. **`main` field correct:** `"main": "src/main.js"` matches actual entry point ✓
7. **Well-documented HELP.md** with clear setup instructions
8. **Good separation of concerns:** actions, feedbacks, variables in separate files
9. **Smart multicast interface detection:** `findInterfaceForDevice()` auto-selects correct network interface
10. **Connection timeout handling:** `resetTimeout()` provides feedback when device goes offline
11. **Protocol implementation:** Clean GlenSound protocol handling with proper packet building
12. **Defensive message parsing:** Bounds checks and validation present
13. **Proper InstanceStatus state machine:** Correct transitions for all connection states
14. **No blocking operations:** All I/O is asynchronous
15. **Valid MIT License** with real copyright holder

**Once template compliance and logic issues are fixed, this will be a solid first release.**
