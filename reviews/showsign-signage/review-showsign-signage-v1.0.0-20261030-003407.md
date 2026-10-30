# Review: companion-module-showsign-signage v1.0.0

| Field | Value |
| --- | --- |
| **Module** | [companion-module-showsign-signage](https://github.com/bitfocus/companion-module-showsign-signage) |
| **Version** | v1.0.0 |
| **Release** | New module — never published |
| **API** | 2.0 (base 2.0.4, yarn.lock) — requires Companion 4.3+ |
| **Template** | `companion-module-template-js-v2.0.4` @ `e4caa76` (2026-08-28, pinned) |
| **Scope** | `tag` (first release: no previous tag, so the whole module was reviewed) |
| **Commit** | [`1902d1a`](https://github.com/bitfocus/companion-module-showsign-signage/commit/1902d1a4d95bb56ec3cb6fa54d83166029761346) |
| **Review date** | 2026-10-30 |

## Verdict: ✅ Approved

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | On Node 22 (the manifest runtime), the built-in `fetch` rejects network-level failures with a `TypeError` whose message is just "fetch failed", and keeps the real reason (ENOTFOUND, ECONNREFUSED, TLS errors) on `e.cause` | Known Node/undici `fetch` behaviour; not checked by running the module | [L1](#l1-connection-status-shows-only-fetch-failed-when-the-showsign-server-cant-be-reached) |
| A2 | The group and cue IDs returned by the ShowSign `/automation/context` endpoint are opaque identifiers (UUIDs or numbers), not friendly names a user would type | The code maps `g.id` / `c.id` straight into the dropdown ids; the real ID format was not checked against the ShowSign API | [L3](#l3-the-group-and-cue-fields-need-raw-showsign-ids-in-expression-mode-and-nothing-says-so) |

## 📋 Issues

### Non-blocking

- [ ] [L1: Connection status shows only fetch failed when the ShowSign server can't be reached](#l1-connection-status-shows-only-fetch-failed-when-the-showsign-server-cant-be-reached)
- [ ] [L2: A failed Fire cue on group or Clear group press gives no visible sign on the button or status](#l2-a-failed-fire-cue-on-group-or-clear-group-press-gives-no-visible-sign-on-the-button-or-status)
- [ ] [L3: The Group and Cue fields need raw ShowSign IDs in expression mode, and nothing says so](#l3-the-group-and-cue-fields-need-raw-showsign-ids-in-expression-mode-and-nothing-says-so)
- [ ] [N1: No presets, so users have to build every ShowSign button by hand](#n1-no-presets-so-users-have-to-build-every-showsign-button-by-hand)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟢 Low

### L1: Connection status shows only fetch failed when the ShowSign server can't be reached

- **Source:** 🔎 protocol reviewer + QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:131-136`](https://github.com/bitfocus/companion-module-showsign-signage/blob/1902d1a4d95bb56ec3cb6fa54d83166029761346/src/main.js#L131-L136)

**What goes wrong:** A user mistypes the host in "ShowSign API base URL" (for example `https://portal.showsing.io/api`), or the venue network blocks the portal. The connection turns red, but the status text and the log only say "fetch failed". They don't say whether the host name couldn't be resolved, the connection was refused, or a certificate check failed, so the user can't tell what to fix.

**Why it happens:** When polling fails, the module shows the error's message as the connection status. For network-level failures, Node's built-in `fetch` uses the generic message "fetch failed" and stores the real reason in a separate `cause` field, which the module never reads.

```js
// src/main.js:134-136
} else {
	this.setError(InstanceStatus.ConnectionFailure, String(e.message || e))
}
```

**Fix:** add the underlying cause to the status message when there is one.

```js
const reason = e.cause?.code || e.cause?.message
this.setError(InstanceStatus.ConnectionFailure, reason ? `${e.message}: ${reason}` : String(e.message || e))
```

### L2: A failed Fire cue on group or Clear group press gives no visible sign on the button or status

- **Source:** 🔎 protocol reviewer + QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:160-178`](https://github.com/bitfocus/companion-module-showsign-signage/blob/1902d1a4d95bb56ec3cb6fa54d83166029761346/src/main.js#L160-L178), [`src/main.js:94-98`](https://github.com/bitfocus/companion-module-showsign-signage/blob/1902d1a4d95bb56ec3cb6fa54d83166029761346/src/main.js#L94-L98)

**What goes wrong:** An operator presses a button with "Fire cue on group" (Group: Main Stage, Cue: Doors Open), and the ShowSign server rejects it, for example with 404 because the cue was deleted in the portal. Nothing changes on screen: the connection stays green and the button gives no indication. The only trace is a "Fire failed: 404 Not Found" line in the connection log, which operators rarely watch during a show.

**Why it happens:** The "Fire cue on group" and "Clear group" handlers catch every error and only write it to the log. They don't change the connection status, and the shared request helper builds its error from the HTTP status code alone, without reading the server's explanation from the response body.

```js
// src/main.js:166-168
} catch (e) {
	this.log('error', `Fire failed: ${e.message || e}`)
}
```

**Fix:** optional UX improvement. When a request fails, read the server's error text (`await res.text().catch(() => '')`) and include it in the error message. On 401/403 from an action, set the BadConfig status as polling already does. You could also add a "last action failed" variable or feedback so operators see failures on the surface.

### L3: The Group and Cue fields need raw ShowSign IDs in expression mode, and nothing says so

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.js:10-11`](https://github.com/bitfocus/companion-module-showsign-signage/blob/1902d1a4d95bb56ec3cb6fa54d83166029761346/src/actions.js#L10-L11), [`src/actions.js:28`](https://github.com/bitfocus/companion-module-showsign-signage/blob/1902d1a4d95bb56ec3cb6fa54d83166029761346/src/actions.js#L28), [`src/feedbacks.js:14-15`](https://github.com/bitfocus/companion-module-showsign-signage/blob/1902d1a4d95bb56ec3cb6fa54d83166029761346/src/feedbacks.js#L14-L15)

**What goes wrong:** A user switches the "Group" or "Cue" option of "Fire cue on group", "Clear group" or "Group is showing cue" to expression mode and has the expression return the name they see in the dropdown, such as "General Announcements". That value matches no choice, so the action or feedback does nothing and shows no error. The expression has to return the internal ShowSign ID instead, and nothing in the UI says so. Normal dropdown use is not affected.

**Why it happens:** The dropdown choices use the server's internal ID as the value and the name only as the label ([`src/main.js:142-148`](https://github.com/bitfocus/companion-module-showsign-signage/blob/1902d1a4d95bb56ec3cb6fa54d83166029761346/src/main.js#L142-L148)). In API 2.x every option can be switched to an expression, and the expression's result is compared with the choice values. The fields have no `expressionDescription` (the hint Companion shows under an option in expression mode) to explain this.

**Fix:** add an `expressionDescription` to the group and cue dropdowns in `actions.js` and `feedbacks.js`, for example "Expression must return the ShowSign group id (see the `group_<id>_cue` variable names)". If expressions make no sense on these fields, set `disableAutoExpression: true` instead.

## 💡 Nice to Have

### N1: No presets, so users have to build every ShowSign button by hand

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:151-158`](https://github.com/bitfocus/companion-module-showsign-signage/blob/1902d1a4d95bb56ec3cb6fa54d83166029761346/src/main.js#L151-L158)

**What goes wrong:** The Presets tab for a ShowSign connection is empty. To make the "take your seats" buttons described in HELP.md ("5 minutes", "About to begin", "Starting now"), the user has to build each one by hand: add the "Fire cue on group" action, then the "Group is showing cue" feedback. Nothing is broken, and presets are optional for a first release.

**Why it happens:** The module publishes actions, feedbacks and variables when the groups or cues change, but never publishes preset definitions.

**Fix:** optionally call `this.setPresetDefinitions(structure, presets)` from `defineAll()`, using the v2 shape (type `simple` and a sections structure, with no `category`). Generate one preset per group and cue, each with the "Fire cue on group" action and the "Group is showing cue" feedback, plus a "Clear group" preset per group. Rebuild them whenever the groups or cues change, the same way the actions are rebuilt.

## 📝 Additional Notes

- This is the module's first release, so there is no previous tag to diff against; the whole module was reviewed and every finding is classified 🆕 NEW.
- `validate-template.ps1 -RunBuild` found no template differences, and the build (`yarn install --immutable` + `yarn package`) passed.
