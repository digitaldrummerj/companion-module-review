# Review: companion-module-biamp-tesira v3.0.2

| | |
|---|---|
| **Module** | biamp-tesira |
| **Review tag** | v3.0.2 |
| **Previous tag** | v2.1.1-beta.3 |
| **Scope** | `tag` (v2.1.1-beta.3 .. v3.0.2 diff) |
| **Language / API** | TypeScript · @companion-module/base v1.x (~1.14.1) |
| **Protocol** | Tesira Text Protocol (TTP) over Telnet/TCP |
| **Build** | ✅ `yarn build` passes |
| **Reviewed** | 2026-06-08 |

> **Note on scope:** v3.0.2 is a full JS→TS rewrite — the old `index.js`/`actions.js`/`feedbacks.js` are deleted and replaced by a new `src/` TypeScript tree. Under `tag` scope the diff is effectively the entire new `src/`, so every code finding is classified **🆕 NEW**.


## Verdict: ❌ Changes Required

## 📋 Issues

**Blocking**

- [ ] [C1: Empty upgrade scripts despite breaking rename of every action and option ID](#h1-empty-upgrade-scripts-despite-breaking-rename-of-every-action-and-option-id)
- [ ] [M1: Feedback callbacks use self.parseVariablesInString instead of context](#m1-feedback-callbacks-use-selfparsevariablesinstring-instead-of-context)
- [ ] [M2: levelRangeOverrides config is never applied to manual feedbacks](#m2-levelrangeoverrides-config-is-never-applied-to-manual-feedbacks)
- [ ] [M4: Polling-socket errors never update InstanceStatus](#m4-polling-socket-errors-never-update-instancestatus)
- [ ] [M5: One-shot polls added mid-cycle can be deleted before being sent](#m5-one-shot-polls-added-mid-cycle-can-be-deleted-before-being-sent)
- [ ] [M6: Several action option fields lack tooltips](#m6-several-action-option-fields-lack-tooltips)
- [ ] [M7: Low-value keyword tesira in manifest](#m7-low-value-keyword-tesira-in-manifest)

---

## 🔴 Critical

### H1: Empty upgrade scripts despite breaking rename of every action and option ID

**File:** `src/upgrades.ts:4` · **Classification:** 🆕 NEW

`UpgradeScripts` is empty (`export const UpgradeScripts = []`), yet the v3 rewrite renamed **every** saved-data identifier. Old v2 action IDs (`setFaderLevel`, `incFaderLevel`, `incFaderLevelTimer`, `incFaderLevelStop`, `faderMute`, `recallPreset`, `customCommand`, `customPolling`, `removeCustomPolling`, `pollOnce`, `subscribeParameter`, `unsubscribeParameter`) all became new IDs (`level_set`, `level_adjust`, `level_hold_start`, `level_hold_stop`, `mute_control`, `recall_preset`, `ttp_command`/`raw_command`, `poll_add`, `poll_remove`, `poll_once`, `subscribe_helper`, `unsubscribe_helper`). Option IDs also changed (e.g. `instanceID` → `instanceTag`; the old numeric `level` is now a `textinput`). Because the manifest `id` is unchanged (`biamp-tesira`) and this ships as an in-place upgrade, every existing user's buttons will silently stop resolving after they update.

**Fix (maintainer):** add upgrade script(s) in `src/upgrades.ts` mapping each old `actionId` to its new ID and renaming/converting the changed option keys (`instanceID`→`instanceTag`, coerce the old numeric `level` to string, etc.). If a clean break is genuinely intended, that is a product decision — but for a same-`id` version bump an upgrade path is expected.

---

## 🟡 Medium

### M1: Feedback callbacks use self.parseVariablesInString instead of context

**File:** `src/feedbacks.ts:16-23, 394, 455-456, 499, 535-536, 591` (and the `*_meter` feedbacks) · **Classification:** 🆕 NEW

Every async feedback callback parses its `source`/`expected`/`activeValues` text via `self.parseVariablesInString(...)`. Per the v1.8 rule, `self.parseVariablesInString()` does **not** register variable-usage tracking, so these feedbacks won't auto-re-evaluate when a referenced variable changes — they only redraw because `main.ts` blanket-calls `checkFeedbacks(...)` on every parsed line. The defaults reference real module variables (`$(biamp-tesira:last_response_numeric)`, `:meter_ch1`, `:level_ch1`), so this is genuinely a feedback-on-variables case.

**Fix (maintainer):** add a 2nd argument onto the callback's called context and use `context.parseVariablesInString(...)`. Also, Companion now handles the parse variables for you, so you can actually remove the parseVariablesInString entirely which is the better option and in the API v2.x version, the parseVariablesInString method is removed.

### M2: levelRangeOverrides config is never applied to manual feedbacks

**File:** `src/config.ts:124-130`, `src/presets.ts:861`, `src/feedbacks.ts:84-143` · **Classification:** 🆕 NEW

The "Level range overrides" config is only consulted inside preset generation (`presets.ts:861`). The feedback range resolvers (`resolveLevelRange`/`resolveMeterRange`/`resolveGenericRange`) consult only live learned ranges and per-feedback min/max options — they never read `self.config.levelRangeOverrides`. An operator who sets an override to fix meter scaling sees presets honor it but manually-placed meter feedbacks silently ignore it, producing wrong bar fill. The tooltip implies the override governs the level range generally.

**Fix (maintainer):** have the feedback range resolvers fall back to the parsed `levelRangeOverrides` map (after live ranges, before hard-coded defaults), or scope the config tooltip to "presets only."

### M4: Polling-socket errors never update InstanceStatus

**File:** `src/main.ts:629-632` · **Classification:** 🆕 NEW

The command-socket `error` handler sets `ConnectionFailure` (line 599), but the **polling-socket** `error` handler only updates `lastError` and calls `updateVariables()` — it never calls `updateStatus()`. If the poll socket fails while the command socket stays up, the module reports `Ok` while metering is silently dead, with no signal to the operator.

**Fix (maintainer):** reflect poll-socket failures in `InstanceStatus` (at least a degraded/warning state or a `log('warn', ...)`), and confirm `pollTimer` restarts on the poll socket's `connect` re-fire (it is re-armed at 634-638 — good).

### M5: One-shot polls added mid-cycle can be deleted before being sent

**File:** `src/main.ts:974-1009` (`doPolling`) · **Classification:** 🆕 NEW

`doPolling()` early-returns when `pollingInProgress` is true (line 975). Several paths fire `void this.doPolling()` opportunistically (`subscribeToAttribute` 491, `queueRangeProbeForInstance` 510, `queueStartupInitialPolling` 954, `queueDiscoveredRangePolling` 971). If these land while a cycle is running the trigger is a no-op, but the cleanup loop at 1003-1005 then deletes **all** `runOnce` entries currently in `trackedPolling` after the race resolves — including ones added mid-cycle that were never sent. Net effect: a one-shot GET added during an active poll can be deleted without ever being issued, so its initial value never arrives.

**Fix (maintainer):** snapshot the variableIds actually queued/sent this cycle and only delete those `runOnce` entries; or re-trigger `doPolling()` once after a cycle completes if new commands were added meanwhile.

### M6: Several action option fields lack tooltips

**File:** `src/actions.ts` (various `textinput` fields) · **Classification:** 🆕 NEW

Many new action options (instance tag, channel, indices, rate, variable name) have no `tooltip`/`description`, where the equivalent v2 fields and the new config fields are well-documented. Purely additive; consider adding `tooltip` (or v1.13 `description`) for discoverability.

### M7: Low-value keyword tesira in manifest

**File:** `companion/manifest.json:42` · **Classification:** 🆕 NEW

`keywords` contains `"tesira"`, which duplicates the module name/`shortname`/product and is flagged as a banned/low-value keyword. Keywords should describe capability, not repeat the product name.

**Fix (maintainer):** drop `"tesira"` from the keywords array (the remaining `audio`, `dsp`, `metering`, `subscriptions` are fine).
