# Review: companion-module-showsign-signage v1.0.2 (follow-up)

| Field | Value |
| --- | --- |
| **Module** | [companion-module-showsign-signage](https://github.com/bitfocus/companion-module-showsign-signage) |
| **Version** | v1.0.2 |
| **Release** | Update — last published v1.0.1 |
| **API** | 2.0 (base 2.0.4, yarn.lock) — requires Companion 4.3+ |
| **Template** | `companion-module-template-js-v2.0.4` @ `e4caa76` (2026-08-28, pinned) · `.yarnrc.yml` from `companion-module-template-js` @ `76d25b2` (2026-10-11) |
| **Scope** | `tag` (`v1.0.1..v1.0.2`) |
| **Commit** | [`cb0f4d7`](https://github.com/bitfocus/companion-module-showsign-signage/commit/cb0f4d7138fb9e9426d10dfae4cf6743ddce145b) |
| **Previous review** | [v1.0.1](review-showsign-signage-v1.0.1-20261030-192328.md) |
| **Review date** | 2026-10-31 |

## Verdict: ✅ Approved

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | ShowSign's `/automation/context` endpoint returns group ids as strings (for example UUIDs), so the string-versus-raw key mismatch has no visible effect today | The module's id sanitising (`groupVarId`, `safe()`) replaces non-alphanumeric characters, which suggests string ids; the real API response was not observed | [L2](#l2-last-action-failed-set-to-one-group-would-miss-failures-if-showsign-ever-sends-numeric-group-ids) |

## 📋 Issues

### Non-blocking

- [ ] [L1: The failure reason goes blank while another group's Last action failed button is still red](#l1-the-failure-reason-goes-blank-while-another-groups-last-action-failed-button-is-still-red)
- [ ] [L2: Last action failed set to one group would miss failures if ShowSign ever sends numeric group ids](#l2-last-action-failed-set-to-one-group-would-miss-failures-if-showsign-ever-sends-numeric-group-ids)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟢 Low

### L1: The failure reason goes blank while another group's Last action failed button is still red

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:238-244`](https://github.com/bitfocus/companion-module-showsign-signage/blob/cb0f4d7138fb9e9426d10dfae4cf6743ddce145b/src/main.js#L238-L244)

**What goes wrong:** An operator has preset buttons for two screen groups, "Lobby" and "Stage". A Fire press on Lobby fails, for example because the cue was deleted in ShowSign. The Lobby button turns red and `$(showsign:last_action_error)` shows "Fire failed: 404 Not Found — cue not found". Two seconds later the operator fires a cue on Stage, and it works. As HELP.md now promises, the Lobby button stays red for the rest of its 10 seconds. But `$(showsign:last_action_error)` has already gone blank, so a button or trigger that shows the reason is empty while Lobby is still red. The same happens with the "Last action failed" feedback set to "Any group": it stays lit with no reason shown.

**Why it happens:** v1.0.2 keeps failures per group, but the error text is still one shared value for the whole connection. When a press succeeds, the module removes only that group's failure, then always empties the shared error text, even when the text describes another group's failure that is still active.

```js
// src/main.js:238-244
actionSucceeded(groupId) {
	const had = this.failures.delete(groupId)
	if (!had && !this.lastActionError) return
	this.lastActionError = ''
	updateVariableValues(this)
	this.checkFeedbacks('action_failed')
}
```

**Fix:** only empty the error text when no other group still has a fresh failure.

```js
const stillFailing = [...this.failures.values()].some((at) => Date.now() - at < FAILED_FEEDBACK_MS)
if (!stillFailing) this.lastActionError = ''
```

Another option is to store the message with each group's failure (`{ at, message }` in the map) and show the newest one that hasn't expired.

### L2: Last action failed set to one group would miss failures if ShowSign ever sends numeric group ids

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:239`](https://github.com/bitfocus/companion-module-showsign-signage/blob/cb0f4d7138fb9e9426d10dfae4cf6743ddce145b/src/main.js#L239), [`src/main.js:251`](https://github.com/bitfocus/companion-module-showsign-signage/blob/cb0f4d7138fb9e9426d10dfae4cf6743ddce145b/src/main.js#L251), [`src/main.js:270-271`](https://github.com/bitfocus/companion-module-showsign-signage/blob/cb0f4d7138fb9e9426d10dfae4cf6743ddce145b/src/main.js#L270-L271)

**What goes wrong:** Nothing visible today, as long as ShowSign's group ids are strings (see [A1](#-assumptions-to-confirm)). If a group id ever arrives as a number (for example `5`), a failed Fire on that group would never light that group's "Last action failed" preset button, and a later successful press on it would not clear its failure. The feedback set to "Any group" would still work.

**Why it happens:** The module remembers failures in a map keyed by group id. A failure is stored under the id converted to text (`"5"`), but a successful press removes it, and the feedback looks it up, using the id exactly as ShowSign sent it (`5`). The map treats `"5"` and `5` as different keys, so the lookup and the removal miss.

```js
// src/main.js:239
const had = this.failures.delete(groupId)
// src/main.js:251
this.failures.set(String(groupId ?? ''), Date.now())
// src/main.js:270-271
const key = this.resolveGroup(groupValue) ?? String(groupValue)
return fresh(this.failures.get(key))
```

**Fix:** convert the key to text the same way everywhere, with one small helper used for `set`, `delete` and `get`.

```js
const failKey = (id) => String(id ?? '')
this.failures.delete(failKey(groupId))
return fresh(this.failures.get(failKey(key)))
```

## 📝 Additional Notes

- Follow-up to the [v1.0.1 review](review-showsign-signage-v1.0.1-20261030-192328.md) (approved, non-blocking findings only). Both of its findings are fixed in v1.0.2:
  - Prior L1 (a press before ShowSign is reached blames a missing group): fixed. When no event has been loaded yet, the press now reports "ShowSign not reached yet" with the connection's reason ([`src/main.js:274-283`](https://github.com/bitfocus/companion-module-showsign-signage/blob/cb0f4d7138fb9e9426d10dfae4cf6743ddce145b/src/main.js#L274-L283)).
  - Prior L2 (one group's red button goes dark when another group's press fails or succeeds): fixed. Failures are kept per group, each with its own 10-second timer, and `destroy()` cancels every timer ([`src/main.js:73-78`](https://github.com/bitfocus/companion-module-showsign-signage/blob/cb0f4d7138fb9e9426d10dfae4cf6743ddce145b/src/main.js#L73-L78), [`src/main.js:246-272`](https://github.com/bitfocus/companion-module-showsign-signage/blob/cb0f4d7138fb9e9426d10dfae4cf6743ddce145b/src/main.js#L246-L272)). The shared error text is the one part that still isn't per group ([L1](#l1-the-failure-reason-goes-blank-while-another-groups-last-action-failed-button-is-still-red)).
- `validate-template.ps1 -RunBuild` found no template differences, and the build (`yarn install --immutable` + `yarn package`) passed.
