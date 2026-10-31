# Review: companion-module-showsign-signage v1.0.3 (follow-up)

| Field | Value |
| --- | --- |
| **Module** | [companion-module-showsign-signage](https://github.com/bitfocus/companion-module-showsign-signage) |
| **Version** | v1.0.3 |
| **Release** | Update — last published v1.0.1 |
| **API** | 2.0 (base 2.0.4, yarn.lock) — requires Companion 4.3+ |
| **Template** | `companion-module-template-js-v2.0.4` @ `e4caa76` (2026-08-28, pinned) · `.yarnrc.yml` from `companion-module-template-js` @ `76d25b2` (2026-10-11) |
| **Scope** | `tag` (`v1.0.1..v1.0.3`) |
| **Commit** | [`8878730`](https://github.com/bitfocus/companion-module-showsign-signage/commit/8878730279dac8c52342417631f47932e197d3ca) |
| **Previous review** | [v1.0.1](review-showsign-signage-v1.0.1-20261030-192328.md) |
| **Review date** | 2026-10-31 |

## Verdict: ✅ Approved

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | ShowSign's `/automation/context` endpoint may return group ids as numbers rather than strings. If they are always strings (for example UUIDs), L2 has no visible effect | The module passes `g.id` through unchanged from the API response ([`src/main.js:212`](https://github.com/bitfocus/companion-module-showsign-signage/blob/8878730279dac8c52342417631f47932e197d3ca/src/main.js#L212), [`src/main.js:227`](https://github.com/bitfocus/companion-module-showsign-signage/blob/8878730279dac8c52342417631f47932e197d3ca/src/main.js#L227)); the ShowSign API's id type was not checked | [L2](#l2-last-action-failed-for-one-group-may-not-light-or-clear-if-showsign-group-ids-are-numbers) |

## 📋 Issues

### Non-blocking

- [ ] [L1: The help page doesn't say the API base URL must now start with https](#l1-the-help-page-doesnt-say-the-api-base-url-must-now-start-with-https)
- [ ] [L2: Last action failed for one group may not light or clear if ShowSign group ids are numbers](#l2-last-action-failed-for-one-group-may-not-light-or-clear-if-showsign-group-ids-are-numbers)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟢 Low

### L1: The help page doesn't say the API base URL must now start with https

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`companion/HELP.md:12`](https://github.com/bitfocus/companion-module-showsign-signage/blob/8878730279dac8c52342417631f47932e197d3ca/companion/HELP.md#L12), [`src/main.js:125-135`](https://github.com/bitfocus/companion-module-showsign-signage/blob/8878730279dac8c52342417631f47932e197d3ca/src/main.js#L125-L135)

**What goes wrong:** From v1.0.3, a connection whose "ShowSign API base URL" is a plain `http://` address on another machine (for example `http://192.168.1.20/api`) goes to the Bad Configuration status with "The API base URL must start with https:// …", and every Fire or Clear press fails. The status message explains this. But the help page the user opens to fix the setting only says the URL is "usually `https://portal.showsign.io/api`". It doesn't say that `http://` is refused, except for `localhost`, `127.0.0.1` and `[::1]`. Users of the default portal URL are not affected.

**Why it happens:** v1.0.3 added a check that refuses any non-https base URL before polling or sending a press, so the automation key is never sent unencrypted. The HELP.md changes in this release cover only the per-group failure behaviour, not this new rule.

**Fix:** add a sentence under the "ShowSign API base URL" bullet in `companion/HELP.md`.

```markdown
   - **ShowSign API base URL** — usually `https://portal.showsign.io/api`. It must start with
     `https://`; plain `http://` is accepted only for `localhost`, `127.0.0.1` or `[::1]` (testing).
```

### L2: Last action failed for one group may not light or clear if ShowSign group ids are numbers

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:259`](https://github.com/bitfocus/companion-module-showsign-signage/blob/8878730279dac8c52342417631f47932e197d3ca/src/main.js#L259), [`src/main.js:271`](https://github.com/bitfocus/companion-module-showsign-signage/blob/8878730279dac8c52342417631f47932e197d3ca/src/main.js#L271), [`src/main.js:290-291`](https://github.com/bitfocus/companion-module-showsign-signage/blob/8878730279dac8c52342417631f47932e197d3ca/src/main.js#L290-L291)

**What goes wrong:** Nothing visible while ShowSign group ids are strings, which is how the rest of the module treats them (see [A1](#-assumptions-to-confirm)). If ShowSign ever returned a number (for example `42`), a failed "Fire cue on group" press on that group would be remembered under the text `"42"`. The "Last action failed" feedback set to that group would look up the number `42`, find nothing, and never light. A later successful press on the same group would not clear the remembered failure either, so a button set to "Any group" would stay red for the full 10 seconds.

**Why it happens:** v1.0.2 keeps failures per group in a lookup table. A failed press stores its entry under the group id turned into text, but a successful press removes the entry, and the feedback reads it, using the group id exactly as ShowSign returned it. The lookup table only treats two keys as the same when they have the same type, so the two sides only match while the ids are strings.

```js
// src/main.js:259
const had = this.failures.delete(groupId)
// src/main.js:271
this.failures.set(String(groupId ?? ''), Date.now())
// src/main.js:290-291
const key = this.resolveGroup(groupValue) ?? String(groupValue)
return fresh(this.failures.get(key))
```

**Fix:** turn the group id into text in one place and use it for every read and write of the table.

```js
failureKey(id) {
	return String(id ?? '')
}
// this.failures.set(this.failureKey(groupId), …)
// this.failures.delete(this.failureKey(groupId))
// this.failures.get(this.failureKey(key))
```

Storing `String(g.id)` when the event data is loaded in `poll()` works too.

## 📝 Additional Notes

- Follow-up to the [v1.0.1 review](review-showsign-signage-v1.0.1-20261030-192328.md) (approved, non-blocking findings only). Both of its findings are fixed in v1.0.3:
  - Prior L1 (a press before ShowSign is reached blames a missing group): fixed. When no event has been loaded yet, a failed lookup now reports "ShowSign not reached yet" with the connection's reason, and HELP.md says so ([`src/main.js:298-303`](https://github.com/bitfocus/companion-module-showsign-signage/blob/8878730279dac8c52342417631f47932e197d3ca/src/main.js#L298-L303), [`src/main.js:310`](https://github.com/bitfocus/companion-module-showsign-signage/blob/8878730279dac8c52342417631f47932e197d3ca/src/main.js#L310), [`src/main.js:327`](https://github.com/bitfocus/companion-module-showsign-signage/blob/8878730279dac8c52342417631f47932e197d3ca/src/main.js#L327)).
  - Prior L2 ("Last action failed" on one group goes dark early): fixed. Failures are kept per group with their own 10 seconds, a success clears only its own group, and `destroy()` stops every pending 10-second timer ([`src/main.js:73-78`](https://github.com/bitfocus/companion-module-showsign-signage/blob/8878730279dac8c52342417631f47932e197d3ca/src/main.js#L73-L78), [`src/main.js:258-292`](https://github.com/bitfocus/companion-module-showsign-signage/blob/8878730279dac8c52342417631f47932e197d3ca/src/main.js#L258-L292)). L2 above is a small key-type inconsistency in that new code.
- Connections saved with a plain `http://` address on another machine show Bad Configuration after upgrading to v1.0.3. This is a deliberate security change and the status message says what to fix, so it is not a finding (L1 asks only for the help page to mention it).
- `validate-template.ps1 -RunBuild` found no template differences, and the build (`yarn install --immutable` + `yarn package`) passed.
