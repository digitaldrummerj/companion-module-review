# Review: companion-module-showsign-signage v1.0.1 (follow-up)

| Field | Value |
| --- | --- |
| **Module** | [companion-module-showsign-signage](https://github.com/bitfocus/companion-module-showsign-signage) |
| **Version** | v1.0.1 |
| **Release** | Update — last published v1.0.0 |
| **API** | 2.0 (base 2.0.4, yarn.lock) — requires Companion 4.3+ |
| **Template** | `companion-module-template-js-v2.0.4` @ `e4caa76` (2026-08-28, pinned) |
| **Scope** | `tag` (`v1.0.0..v1.0.1`) |
| **Commit** | [`2bfab8f`](https://github.com/bitfocus/companion-module-showsign-signage/commit/2bfab8f4acee424cc294616bf6c720d70a7d6160) |
| **Previous review** | [v1.0.0](review-showsign-signage-v1.0.0-20261030-003407.md) |
| **Review date** | 2026-10-30 |

## Verdict: ✅ Approved

## 📋 Issues

### Non-blocking

- [ ] [L1: A press made before ShowSign has ever been reached blames a missing group instead of the network](#l1-a-press-made-before-showsign-has-ever-been-reached-blames-a-missing-group-instead-of-the-network)
- [ ] [L2: Last action failed on one group goes dark early when a press on another group fails or succeeds](#l2-last-action-failed-on-one-group-goes-dark-early-when-a-press-on-another-group-fails-or-succeeds)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟢 Low

### L1: A press made before ShowSign has ever been reached blames a missing group instead of the network

- **Source:** 🔎 protocol reviewer + QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:275-282`](https://github.com/bitfocus/companion-module-showsign-signage/blob/2bfab8f4acee424cc294616bf6c720d70a7d6160/src/main.js#L275-L282), [`src/main.js:294-303`](https://github.com/bitfocus/companion-module-showsign-signage/blob/2bfab8f4acee424cc294616bf6c720d70a7d6160/src/main.js#L294-L303)

**What goes wrong:** Companion starts while the venue network can't reach portal.showsign.io (or the URL is mistyped), so the module never loads the event's groups and cues. The connection status correctly says something like "fetch failed: host name not found (ENOTFOUND)". The operator then presses a saved button, for example the preset Fire "Please take your seats" on General Announcements. The log and `$(showsign:last_action_error)` show `Fire failed: no group "grp_123" in this ShowSign event`, and the "Last action failed" feedback lights red. That message suggests the group was deleted in the portal, when ShowSign simply can't be reached. In v1.0.0 the same press went out and reported the real network error. The press couldn't have worked either way, and the connection status still shows the right cause, so only the message is misleading.

**Why it happens:** New in v1.0.1, "Fire cue on group" and "Clear group" look up the chosen group and cue in the event data the module last loaded from ShowSign before sending anything, so that an expression can return a name instead of an id. That event data starts empty when the connection starts and is only filled by a successful poll. Until ShowSign has been reached once, every lookup fails, including a valid id from a dropdown or preset, and the press is rejected locally with the "not in this event" message. The event data is kept after later poll failures, so this only happens when ShowSign hasn't been reached since the connection started.

```js
// src/main.js:275-282
async fireCue(groupValue, cueValue, ttlSeconds) {
	const groupId = this.resolveGroup(groupValue)
	const cueId = this.resolveCue(cueValue)
	if (!groupId || !cueId) {
		const missing = !groupId ? `group "${groupValue ?? ''}"` : `cue "${cueValue ?? ''}"`
		this.actionFailed('Fire', new Error(`no ${missing} in this ShowSign event`), groupId ?? String(groupValue ?? ''))
		return
	}
```

**Fix:** when the lookup fails and no event has been loaded yet (`this.context.event` is null), report the connection problem instead, for example `ShowSign not reached yet: ${this.lastError}`. Another option is to send the raw option value as the id while the event data is empty, as v1.0.0 did, so the real network error is reported.

### L2: Last action failed on one group goes dark early when a press on another group fails or succeeds

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:236-273`](https://github.com/bitfocus/companion-module-showsign-signage/blob/2bfab8f4acee424cc294616bf6c720d70a7d6160/src/main.js#L236-L273)

**What goes wrong:** An operator has two Clear presets, one for Lobby and one for Main Hall, each with the red "Last action failed" feedback set to its own group. The Lobby Clear fails and its button turns red. Two seconds later a press on Main Hall either fails (Main Hall turns red and Lobby goes dark at once) or succeeds (Lobby goes dark at once). HELP.md says the button stays red for 10 seconds, so the operator can miss the Lobby failure.

**Why it happens:** The module remembers only one failure: the time, the group and the error text of the most recent failed press. A new failure overwrites the group with the newest one, and any successful press clears the failure for every group, whichever group it was on. The feedback compares its group against that single remembered group.

**Fix:** keep the failure times per group (a `Map` of group id to timestamp). Set the group's entry when a press fails, delete only that group's entry when a press on it succeeds, and have the feedback check its own group's entry (or any entry when "Any group" is chosen). The `last_action_error` variable can stay as it is.

## 📝 Additional Notes

- Follow-up to the [v1.0.0 review](review-showsign-signage-v1.0.0-20261030-003407.md) (approved, non-blocking findings only). All four of its findings are fixed in v1.0.1:
  - Prior L1 (status shows only "fetch failed"): fixed. Network failures now show the underlying reason in plain words, such as "host name not found (ENOTFOUND)" ([`src/main.js:36-44`](https://github.com/bitfocus/companion-module-showsign-signage/blob/2bfab8f4acee424cc294616bf6c720d70a7d6160/src/main.js#L36-L44)).
  - Prior L2 (failed press gives no visible sign): fixed. Error bodies from ShowSign are included in the message, a 401/403 on a press sets the "Invalid or revoked automation key" status, and the new "Last action failed" feedback and `last_action_error` variable show failures on the surface ([`src/main.js:123-148`](https://github.com/bitfocus/companion-module-showsign-signage/blob/2bfab8f4acee424cc294616bf6c720d70a7d6160/src/main.js#L123-L148), [`src/main.js:248-265`](https://github.com/bitfocus/companion-module-showsign-signage/blob/2bfab8f4acee424cc294616bf6c720d70a7d6160/src/main.js#L248-L265)).
  - Prior L3 (expression mode needs raw ids): fixed. The Group and Cue options accept a name or an id, carry an `expressionDescription`, and HELP.md documents it ([`src/actions.js:2-26`](https://github.com/bitfocus/companion-module-showsign-signage/blob/2bfab8f4acee424cc294616bf6c720d70a7d6160/src/actions.js#L2-L26)).
  - Prior N1 (no presets): fixed. [`src/presets.js`](https://github.com/bitfocus/companion-module-showsign-signage/blob/2bfab8f4acee424cc294616bf6c720d70a7d6160/src/presets.js) adds a section per screen group with a Fire button per cue and a Clear button, rebuilt when groups or cues change.
- `validate-template.ps1 -RunBuild` found no template differences, and the build (`yarn install --immutable` + `yarn package`) passed.
