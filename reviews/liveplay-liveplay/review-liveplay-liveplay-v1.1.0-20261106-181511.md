# Review: liveplay-liveplay v1.1.0 (follow-up to v1.0.0)

| Field | Value |
| --- | --- |
| **Module** | [companion-module-liveplay-liveplay](https://github.com/bitfocus/companion-module-liveplay-liveplay) |
| **Scope** | `tag` |
| **Version** | v1.1.0 |
| **Release** | New module — never published |
| **API** | 2.1 (base 2.1.3, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Commit** | [`c213b7a`](https://github.com/bitfocus/companion-module-liveplay-liveplay/commit/c213b7a830f6018cd25b7e98cbc83c1ab923b38c) |
| **Previous review** | [v1.0.0, 2026-10-30](review-liveplay-liveplay-v1.0.0-20261030-003407.md) — Changes Required |
| **Reviewed** | 2026-11-06 |

This is a follow-up to the v1.0.0 review. The module has still never been published, so there is no published release to diff against: the whole module was reviewed again, and every finding is classified 🆕 NEW. The v1.0.0..v1.1.0 changes (19 files) were also checked against each finding of the earlier review. **All 13 earlier findings are fixed**; the per-finding check is in [📝 Additional Notes](#-additional-notes).

Both High findings below were already in v1.0.0 and are unchanged in this release; the earlier review should have raised them.

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | When Companion starts a connection it passes the saved config to `init()` as stored, without filling in missing fields from the config field defaults, so `config.host` can be `undefined` for a config that never had that key (for example one carried over from the `liveplay` id, or an imported one) | Field defaults are applied when a connection is created; no default-filling for existing configs was found in `@companion-module/base` 2.1.3, which only forwards the config it gets from Companion. Companion's own host code was not checked | [L2](#l2-a-saved-config-with-no-host-stops-the-connection-from-starting-instead-of-showing-a-config-error) |

## 📋 Issues

### Blocking

- [ ] [H1: The manifest takes over the module id liveplay, which this new module does not own](#h1-the-manifest-takes-over-the-module-id-liveplay-which-this-new-module-does-not-own)

### Non-blocking

- [ ] [L1: Every cue that starts makes the module download the whole LivePlay project again](#l1-every-cue-that-starts-makes-the-module-download-the-whole-liveplay-project-again)
- [ ] [L2: A saved config with no host stops the connection from starting instead of showing a config error](#l2-a-saved-config-with-no-host-stops-the-connection-from-starting-instead-of-showing-a-config-error)
- [ ] [N1: The Bus fader adjust action changes the shown bus level even when LivePlay never received the command](#n1-the-bus-fader-adjust-action-changes-the-shown-bus-level-even-when-liveplay-never-received-the-command)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟠 High

### H1: The manifest takes over the module id liveplay, which this new module does not own

- **Source:** 🤖 validate-template (MAN-LEGACYIDS)
- **Classification:** 🆕 NEW
- **File:** [`companion/manifest.json:24`](https://github.com/bitfocus/companion-module-liveplay-liveplay/blob/c213b7a830f6018cd25b7e98cbc83c1ab923b38c/companion/manifest.json#L24)

**What goes wrong:** `legacyIds` tells Companion "this module replaces an older module with this id", and Companion moves every connection that uses that id over to this module. This module has never been published, so it replaces nothing in Companion's module list, and `"liveplay"` only claims an id the module doesn't own. If a module with the id `liveplay` is ever published, Companion would hand its users' connections to this module instead. The line is unchanged since v1.0.0.

**Why it happens:** The manifest lists `"legacyIds": ["liveplay"]` where the template has an empty list. `legacyIds` is for a published module that was later renamed. A first release has no earlier id to carry over, so the list must stay empty.

**Evidence:**

| File | Template expects | Found |
| --- | --- | --- |
| `companion/manifest.json:24` | `"legacyIds": []` | `"legacyIds": ["liveplay"]` |

**Confirm by:** open [`companion/manifest.json:24`](https://github.com/bitfocus/companion-module-liveplay-liveplay/blob/c213b7a830f6018cd25b7e98cbc83c1ab923b38c/companion/manifest.json#L24); it should read `"legacyIds": []`.

**Fix:** empty the list, as in the template.

```json
"legacyIds": [],
```

## 🟢 Low

### L1: Every cue that starts makes the module download the whole LivePlay project again

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:476-489`](https://github.com/bitfocus/companion-module-liveplay-liveplay/blob/c213b7a830f6018cd25b7e98cbc83c1ab923b38c/src/main.ts#L476-L489), [`src/main.ts:597`](https://github.com/bitfocus/companion-module-liveplay-liveplay/blob/c213b7a830f6018cd25b7e98cbc83c1ab923b38c/src/main.ts#L597), [`src/main.ts:696-706`](https://github.com/bitfocus/companion-module-liveplay-liveplay/blob/c213b7a830f6018cd25b7e98cbc83c1ab923b38c/src/main.ts#L696-L706), [`src/main.ts:715-729`](https://github.com/bitfocus/companion-module-liveplay-liveplay/blob/c213b7a830f6018cd25b7e98cbc83c1ab923b38c/src/main.ts#L715-L729)

**What goes wrong:** During a show, every time a cue starts that wasn't already on air (GO, a "Trigger cart slot" button, a Cart preset), the module fetches the state summary and then the whole project document from the LivePlay machine, although nothing in the project changed. The same happens when Up Next changes or a cart slot is bound or cleared. Firing a cart wall quickly on a 400-cue show can mean up to four full-project downloads a second. Buttons look the same, but the LivePlay machine does extra work mid-show. If one download takes longer than the module's 3-second limit, the log shows "Could not fetch the open project (no response); keeping the previous cue list, retrying", and a 5-second retry starts for a project that never changed. The code's own comment says the project is "never polled" and is only re-read after document edits.

**Why it happens:** A new cue (or a playback snapshot with a cue the module hasn't seen yet) schedules a summary refresh, to fill in the cue's name, duration and colour. That refresh (`scheduleSummaryRefresh()`) always re-reads the project document afterwards (`await this.refreshCatalog()`), whether the document changed or not. The `next_item_set`, `cart_slot_set` and `cart_slot_cleared` messages go through the same refresh.

**Fix:** re-read the project document only when it changed. For example, set a flag only for `project_changed`, `item_added`, `item_updated`, `item_removed` and `items_reordered` (and when the summary shows a different project), and have the summary refresh call `refreshCatalog()` only when the flag is set. Cue starts, snapshots, Up Next and cart-slot changes then fetch only the summary.

```ts
private catalogDirty = false
// in the doc_patch switch, for project_changed / item_* only:
this.catalogDirty = true
this.scheduleSummaryRefresh()
// in scheduleSummaryRefresh(), after this.applySummary(summary):
if (this.catalogDirty) {
	this.catalogDirty = false
	await this.refreshCatalog()
}
```

### L2: A saved config with no host stops the connection from starting instead of showing a config error

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:74-76`](https://github.com/bitfocus/companion-module-liveplay-liveplay/blob/c213b7a830f6018cd25b7e98cbc83c1ab923b38c/src/main.ts#L74-L76), [`src/main.ts:106`](https://github.com/bitfocus/companion-module-liveplay-liveplay/blob/c213b7a830f6018cd25b7e98cbc83c1ab923b38c/src/main.ts#L106), [`src/main.ts:126`](https://github.com/bitfocus/companion-module-liveplay-liveplay/blob/c213b7a830f6018cd25b7e98cbc83c1ab923b38c/src/main.ts#L126)

**What goes wrong:** If a LivePlay connection's saved config has no host value at all, starting the connection fails with "Cannot read properties of undefined (reading 'trim')". The connection then shows an error instead of the intended "Bad configuration: Server host is not set". That can happen with an imported config that lacks the field, or with a connection carried over from the `liveplay` id while `legacyIds` still lists it (see [H1](#h1-the-manifest-takes-over-the-module-id-liveplay-which-this-new-module-does-not-own)). Connections created in this module's own config panel always have a host value (the field defaults to empty text) and are not affected. v1.0.0 didn't have this problem: the trim was added in this release to fix the earlier review's stray-space finding. This depends on [A1](#-assumptions-to-confirm).

**Why it happens:** The new `normalizeConfig()` calls `config.host.trim()` without checking that `host` exists. The TypeScript type says `host` is always a string, but the value comes from the config Companion saved, and nothing guarantees the field is there.

**Fix:** guard the value. The existing "host is not set" check in `startConnection()` then reports the bad config as intended.

```ts
return { ...config, host: String(config.host ?? '').trim() }
```

## 💡 Nice to Have

### N1: The Bus fader adjust action changes the shown bus level even when LivePlay never received the command

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:532-541`](https://github.com/bitfocus/companion-module-liveplay-liveplay/blob/c213b7a830f6018cd25b7e98cbc83c1ab923b38c/src/actions.ts#L532-L541)

**What goes wrong:** While LivePlay is unreachable (connection status Disconnected or Connection Failure), pressing a "Bus fader: adjust" button set to +1 dB three times makes `$(liveplay:bus_music_gain)` read 3.0 instead of 0.0, although LivePlay received nothing. The only sign is the log line "Cannot send bus_gain: not connected to LivePlay", and each further press steps from the wrong value. The variable snaps back to the real level after the next reconnect. Nothing goes wrong while connected, because LivePlay echoes every move back.

**Why it happens:** The action writes the new level into the module's cached bus state before sending the command. The send helper (`wsSend()`) only logs a warning when the socket isn't open and doesn't report the failure, so the action can't tell that the send failed.

**Fix:** have `wsSend()` return whether it sent the message, and update the cached level only when it did.

```ts
if (self.wsSend({ type: 'bus_gain', busId: bus.id, gainDb: db })) bus.gainDb = db
```

## 📝 Additional Notes

- **v1.0.0 C1 (Node 22 runtime), fixed:** the manifest runtime is `node26`, `tsconfig.build.json` extends `@companion-module/tools/tsconfig/node26/recommended.json`, `engines.node` is `^26` and `@types/node` is `^26.6.4`.
- **v1.0.0 C2 (pre-commit hook), fixed:** `.husky/pre-commit` is the template's `lint-staged`.
- **v1.0.0 M1 (Abort doesn't cancel the request), fixed:** `apiRequest()` takes an abort signal and combines it with its 5-second timeout (`AbortSignal.any`), and every network action passes `context.signal`.
- **v1.0.0 M2 (advanced feedbacks), fixed:** all six advanced feedbacks are gone. The presets use the value-feedback gauges instead, plus new `cue_state` and cart-slot value feedbacks (`cart_progress`, `cart_color_rgb`, `cart_text_rgb`, `cart_name`).
- **v1.0.0 M3 (CI on Node 22), fixed:** `node.yaml` uses `26.x`, and the checkout step has `persist-credentials: false`.
- **v1.0.0 M4 (custom release workflow), fixed:** `release.yaml` matches the template, using the shared `module-checks` workflow and `gh release upload`.
- **v1.0.0 L1 (stray space in the host), fixed:** `normalizeConfig()` trims the host in `init()` and `configUpdated()`. See [L2](#l2-a-saved-config-with-no-host-stops-the-connection-from-starting-instead-of-showing-a-config-error) for the one case the trim doesn't cover.
- **v1.0.0 L2 (a failed project fetch blanks the cue list), fixed:** `refreshCatalog()` keeps the previous catalog, logs a warning with the status, and retries every 5 seconds on a timeout or server error. The retry timer is cleared on teardown.
- **v1.0.0 L3 (memory growth), fixed:** the cue-id map entry is removed when a cue stops and cleared in `clearPlayback()`.
- **v1.0.0 L4 (feedback UUID field ignores variables), fixed:** `useVariables: true` is on the Item UUID fields of "Item is playing", "Item is paused", "Item is selected" and "Item is armed as Up Next". "Item color by UUID" was removed.
- **v1.0.0 L5 (expression mode on fixed-choice dropdowns), fixed:** all six Mode / Direction dropdowns set `disableAutoExpression: true`.
- **v1.0.0 L6 (one preset and two variables per cue), fixed:** each "Cues: …" preset group is now a template group over the single "Cue by UUID" preset, and the per-cue name variables are an opt-in checkbox ("Per-cue name variables", off by default).
- **v1.0.0 N1 (config info text), fixed:** the missing space between the two sentences is added.
