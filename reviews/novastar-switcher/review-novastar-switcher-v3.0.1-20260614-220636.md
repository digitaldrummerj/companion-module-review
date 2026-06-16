# Review — novastar-switcher v3.0.1

| | |
|---|---|
| **Module** | novastar-switcher |
| **Review tag** | v3.0.1 |
| **Previous tag** | v2.1.0 |
| **Scope** | tag (changes in `v2.1.0..v3.0.1`) |
| **Language / API** | TypeScript · @companion-module/base ^1.12.1 (v1) |
| **Protocols** | HTTP · WebSocket |
| **Date** | 2026-06-14 |

> **Note on scope:** v3.0.1 is a **complete JS→TS rewrite** — the prior `src/*.js` + `utils/*.js` are deleted and the entire module is re-authored in TypeScript. The `v2.1.0..v3.0.1` diff therefore covers essentially the whole `src/` tree, so the full current module was treated as the review surface. All findings are classified 🆕 NEW.

## Verdict: ❌ Changes Required

## 📋 Issues

**Blocking**

- [ ] [H1: retryTimeout is never cleared in destroy so a pending reconnect fires after teardown](#h1-retrytimeout-is-never-cleared-in-destroy-so-a-pending-reconnect-fires-after-teardown)
- [ ] [H4: status set to Ok before the socket opens and WS drops tear down all definitions on a 5s loop](#h4-status-set-to-ok-before-the-socket-opens-and-ws-drops-tear-down-all-definitions-on-a-5s-loop)
- [ ] [H5: manifest version is 2.2.0 but the release is 3.0.1](#h5-manifest-version-is-220-but-the-release-is-301)
- [ ] [H6: Pleae make all comments, skills, and commits in English](#h6-please-make-all-comments-skills-commits-in-english)

**Findings for you to review**

These are findings that the AI found that you will need to review and decide if they make sense to implement or not.

- [ ] [M2: action send failures are swallowed with no status change and a wrong log label](#m2-action-send-failures-are-swallowed-with-no-status-change-and-a-wrong-log-label)
- [ ] [M6: device discovery is performed twice per init and reconnect](#m6-device-discovery-is-performed-twice-per-init-and-reconnect)
- [ ] [M7: no InstanceStatus.Connecting transition before connect](#m7-no-instancestatusconnecting-transition-before-connect)
- [ ] [M10: boolean feedback dropdowns default to a value that can never match the choice ids](#m10-boolean-feedback-dropdowns-default-to-a-value-that-can-never-match-the-choice-ids)
- [ ] [L1: stray console.log in the FTB network path](#l1-stray-consolelog-in-the-ftb-network-path)
- [ ] [L4: realMerge leaves stale trailing array elements when a collection shrinks](#l4-realmerge-leaves-stale-trailing-array-elements-when-a-collection-shrinks)
- [ ] [L7: setTestPattern reads option fields that were removed and are always undefined](#l7-settestpattern-reads-option-fields-that-were-removed-and-are-always-undefined)
- [ ] [L8: typo and untranslated Chinese comments shipped in source](#l8-typo-and-untranslated-chinese-comments-shipped-in-source)

---

## 🟠 High

### H1: retryTimeout is never cleared in destroy so a pending reconnect fires after teardown

**File:** `src/main.ts:50` (`destroy`) → `:164` (`cleanup`) → `:181` (`cleanupConnections`); timer set at `:159` · **Classification:** 🆕 NEW

`error()` schedules `this.retryTimeout = setTimeout(() => void this.configUpdated(this.config), 5000)`. `retryTimeout` is cleared **only** in `configUpdated()` (`:61-63`) — never in `destroy()`/`cleanup()`/`cleanupConnections()` (verified: those paths clear connections and definitions but not the timer). If the instance is destroyed or removed inside the 5s retry window (e.g. a WebSocket `close`/`error` fired just before teardown), the timer survives and runs `configUpdated()` on a destroyed instance, re-opening HTTP/WebSocket connections that will never be cleaned up — a zombie reconnect and resource leak.

**Fix (for the maintainer):** clear and null `retryTimeout` inside `cleanup()` (or `cleanupConnections()`) so every teardown path — including `destroy()` — covers it.

### H4: status set to Ok before the socket opens and WS drops tear down all definitions on a 5s loop

**File:** `src/services/WebSocketClient.ts:15,25-29` · `src/main.ts:119,131,150` · **Classification:** 🆕 NEW

`WebSocketClient.create()` calls `connect()` and returns synchronously without awaiting the `open` event, and `main.ts` then immediately sets `InstanceStatus.Ok`. If the socket subsequently fails, `onError`/`onClose` → `instance.error()` → `cleanup()`, which clears **all** action/feedback/variable/preset definitions and re-runs a full `configUpdated()` every 5 seconds. On a flapping device this repeatedly tears down and rebuilds every definition (operator buttons momentarily lose feedbacks) and re-runs the full HTTP handshake — with no backoff, jitter, or cap.

**Fix (for the maintainer):** await the `open` event in `create()` (reject on first `error`) before reporting `Ok`; on transient WS drops reconnect the socket only (with exponential backoff + cap) rather than tearing down all definitions and re-discovering.

### H5: manifest version is 2.2.0 but the release is 3.0.1

**File:** `companion/manifest.json:6` · **Classification:** 🆕 NEW

`package.json` is `3.0.1` (matching tag `v3.0.1`), but `companion/manifest.json` `version` still reads `2.2.0`. The manifest version is what Companion surfaces to users, so this major-rewrite release reports a stale version.

**Fix (for the maintainer):** bump the manifest `version` to `0.0.0` as it will be auto updated to the version in the package.json during the publishing process.

### H6: Please make all comments, skills, commits in English

For Companion modules, English code comments, skills, and commits are a requirement.  This allows the global community to understand all of the code.

**Fix:** update the code comments and skills file to be in English.

---

## 🟡 Medium

### M2: action send failures are swallowed with no status change and a wrong log label

**File:** `src/actions.ts:226`, `:274` · **Classification:** 🆕 NEW

Both callbacks `catch {}` and only `self.log('error', …)`, leaving the instance showing `Ok` after a send failure (e.g. device goes offline mid-operation). The freeze handler also logs `'FTB send error'` (copy-paste) for a freeze failure. The `self.apiClient?.ftb(…)` optional chain also silently no-ops when the client is null.

**Fix (for the maintainer):** on failure call `self.updateStatus(InstanceStatus.ConnectionFailure, …)` (or `self.error()`); fix the freeze log message; log the null-client case.

### M6: device discovery is performed twice per init and reconnect

**File:** `src/main.ts:74` + `src/services/ApiClient.ts:65` · **Classification:** 🆕 NEW

`configUpdated()` calls `discoverDevices(host)`, then `ApiClient.setup()` calls `_getDeviceList()` again. With the 5s reconnect loop, this doubles HTTP load on the device every cycle.

**Fix (for the maintainer):** pass the already-discovered list into `ApiClient.create` instead of re-fetching.

### M7: no InstanceStatus.Connecting transition before connect

**File:** `src/main.ts:55-131` · **Classification:** 🆕 NEW

`configUpdated()` goes straight into discovery + API setup + WebSocket creation and only sets `Ok` (`:131`) or a failure status; during the (potentially long) connect sequence the status stays whatever it was.

**Fix (for the maintainer):** `this.updateStatus(InstanceStatus.Connecting)` immediately after the `host` check (`:71`).

### M10: boolean feedback dropdowns default to a value that can never match the choice ids

**File:** `src/feedbacks.ts:147,177,205,233` · **Classification:** 🆕 NEW

`screenState`, `screenFreezeState`, `screenFtbState`, and `screenTestPatternState` build their `screenId` choices from `screen.guid` (a `string`) and compare against it in the callback — internally consistent. But the dropdown `default` is `1`/`'1'`, which is never a valid guid, so a newly-dropped feedback resolves to "no screen" until the user reselects.

**Fix (for the maintainer):** default to the first available guid, e.g. `default: self.getScreens([…])[0]?.guid ?? ''`.

---

## 🟢 Low

### L1: stray console.log in the FTB network path

**File:** `src/services/ApiClient.ts:201` · **Classification:** 🆕 NEW

`console.log('debug', \`FTB Body: …\`)` writes to stdout (bypassing Companion's logger) on every FTB action, and the first arg `'debug'` is just printed as text.

**Fix (for the maintainer):** remove it or use `instance.log('debug', …)`.

### L4: realMerge leaves stale trailing array elements when a collection shrinks

**File:** `src/utils/utils.ts:16` · **Classification:** 🆕 NEW

`realMerge` mutates `to` in place and, for arrays (`typeof === 'object'`), recurses index-by-index rather than replacing — so a shrinking array (fewer backups/screens) keeps stale trailing elements, producing ghost variables/feedbacks. Used by `sourceBackupUpdated` and `updateScreens`.

**Fix (for the maintainer):** replace arrays wholesale (or truncate to the new length) rather than index-merging.

### L7: setTestPattern reads option fields that were removed and are always undefined

**File:** `src/actions.ts:1005-1006,1022-1023` · **Classification:** 🆕 NEW

The `screenBorder`/`interfaceBorder` checkbox options were commented out (`:912-925`) but the callback still reads `event.options.screenBorder` / `interfaceBorder` — always `undefined`, so both always resolve to `0`. Dead/misleading code.

**Fix (for the maintainer):** restore the option fields, or drop the references and hardcode `0`.

### L8: typo and untranslated Chinese comments shipped in source

**File:** `src/feedbacks.ts:313` · `src/updates/StripLegacyNovastarInstanceConfig.ts:4-6` · **Classification:** 🆕 NEW

`sourceBackupState` description reads "Input Bckup configuration" (typo). Untranslated Chinese comments/JSDoc are also shipped in source.

**Fix (for the maintainer):** correct "Bckup" → "Backup"; translate or remove the comments.

---
