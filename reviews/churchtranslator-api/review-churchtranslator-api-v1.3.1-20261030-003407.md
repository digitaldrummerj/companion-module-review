# Review: companion-module-churchtranslator-api v1.3.1

| Field | Value |
| --- | --- |
| **Module** | `companion-module-churchtranslator-api` |
| **Scope** | `tag` |
| **Version** | v1.3.1 |
| **Release** | New module — never published |
| **API** | 2.1 (base 2.1.3, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-js` @ `76d25b2` (2026-10-11) |
| **Commit** | [`0692b6d`](https://github.com/bitfocus/companion-module-churchtranslator-api/commit/0692b6d1abfc3bc8ee8a542fd65e1f84f1c6a3ac) |
| **Reviewed** | 2026-10-30 |

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | When the user aborts a button's running actions, Companion aborts `context.signal` for those action callbacks, so a module that honours the signal would cancel its HTTP request | The `signal` doc comment in `@companion-module/base` 2.1.3 `action.d.ts` ("aborts when the result of this execution is no longer needed (eg the user aborted the running actions)"); the Companion host side was not checked | [M1](#m1-cancelled-button-actions-still-start-or-stop-the-service) |
| A2 | Companion passes a checkbox's expression-mode result to the callback without coercing it, so an expression that returns `1` or `"true"` does not arrive as the boolean `true` | The general 2.x expression rules; checkbox coercion was not confirmed in the Companion host source | [L5](#l5-checkbox-and-fixed-choice-options-accept-expressions-they-do-not-need) |

## 📋 Issues

### Blocking

- [ ] [C1: `.prettierignore` does not match the template](#c1-prettierignore-does-not-match-the-template)
- [ ] [C2: Module is declared to run on Node 22 instead of the Node 26 runtime API 2.1 expects](#c2-module-is-declared-to-run-on-node-22-instead-of-the-node-26-runtime-api-21-expects)
- [ ] [H1: Module checks workflow differs from the template](#h1-module-checks-workflow-differs-from-the-template)

### Non-blocking

- [ ] [M1: Cancelled button actions still start or stop the service](#m1-cancelled-button-actions-still-start-or-stop-the-service)
- [ ] [M2: Input level meter is drawn with the discouraged bitmap feedback type](#m2-input-level-meter-is-drawn-with-the-discouraged-bitmap-feedback-type)
- [ ] [M3: Release workflow is missing, so published releases are not packaged by CI](#m3-release-workflow-is-missing-so-published-releases-are-not-packaged-by-ci)
- [ ] [L1: Disabling the connection while it is still starting can leave the status poll running](#l1-disabling-the-connection-while-it-is-still-starting-can-leave-the-status-poll-running)
- [ ] [L2: Speaker language lamp and variable can stay on the old language for up to 5 minutes on older servers](#l2-speaker-language-lamp-and-variable-can-stay-on-the-old-language-for-up-to-5-minutes-on-older-servers)
- [ ] [L3: When the language list cannot be loaded, every status refresh fetches it again and waits for it](#l3-when-the-language-list-cannot-be-loaded-every-status-refresh-fetches-it-again-and-waits-for-it)
- [ ] [L4: Per-language variable names can stay as bare language codes](#l4-per-language-variable-names-can-stay-as-bare-language-codes)
- [ ] [L5: Checkbox and fixed-choice options accept expressions they do not need](#l5-checkbox-and-fixed-choice-options-accept-expressions-they-do-not-need)
- [ ] [N1: A mistyped Server URL shows a misleading connection error instead of a config error](#n1-a-mistyped-server-url-shows-a-misleading-connection-error-instead-of-a-config-error)
- [ ] [N2: Pressing a button on an unconfigured connection briefly shows Authentication Failure](#n2-pressing-a-button-on-an-unconfigured-connection-briefly-shows-authentication-failure)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🔴 Critical

### C1: `.prettierignore` does not match the template

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.prettierignore:1-3`](https://github.com/bitfocus/companion-module-churchtranslator-api/blob/0692b6d1abfc3bc8ee8a542fd65e1f84f1c6a3ac/.prettierignore#L1-L3)

**What goes wrong:** The module's Prettier ignore list is not the one every Companion JS module ships with. Formatting runs on files the template keeps Prettier away from (`package.json`, `LICENSE.md`), so a format pass in this repo behaves differently from every other module, which makes later troubleshooting against the template confusing.

**Why it happens:** The file was replaced with a custom list instead of the template's.

**Evidence:**

```text
Template expects:
package.json
/LICENSE.md

Found:
node_modules/
pkg/
yarn.lock
```

**Confirm by:** open [`.prettierignore`](https://github.com/bitfocus/companion-module-churchtranslator-api/blob/0692b6d1abfc3bc8ee8a542fd65e1f84f1c6a3ac/.prettierignore) and compare it with the template's.

**Fix:** replace the file with the template's `.prettierignore`.

```text
package.json
/LICENSE.md
```

### C2: Module is declared to run on Node 22 instead of the Node 26 runtime API 2.1 expects

- **Source:** 🤖 validate-template (MAN-RUNTIME)
- **Classification:** 🆕 NEW
- **File:** [`companion/manifest.json:19-24`](https://github.com/bitfocus/companion-module-churchtranslator-api/blob/0692b6d1abfc3bc8ee8a542fd65e1f84f1c6a3ac/companion/manifest.json#L19-L24)

**What goes wrong:** Companion starts this module on Node 22, while every other API 2.1 module (and the template it was built from) runs on Node 26. Any problem a user reports would have to be debugged on a different runtime from the one the template and the rest of the 2.1 modules use.

**Why it happens:** The manifest's `runtime.type` is `node22`; the API 2.1 template sets `node26`.

**Evidence:**

```text
Template expects:  "runtime": { "type": "node26", ... }
Found:             "runtime": { "type": "node22", ... }
```

**Confirm by:** open [`companion/manifest.json:19-24`](https://github.com/bitfocus/companion-module-churchtranslator-api/blob/0692b6d1abfc3bc8ee8a542fd65e1f84f1c6a3ac/companion/manifest.json#L19-L24).

**Fix:** set the runtime type to Node 26.

```json
"runtime": {
	"type": "node26",
```

## 🟠 High

### H1: Module checks workflow differs from the template

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.github/workflows/companion-module-checks.yaml:1-11`](https://github.com/bitfocus/companion-module-churchtranslator-api/blob/0692b6d1abfc3bc8ee8a542fd65e1f84f1c6a3ac/.github/workflows/companion-module-checks.yaml#L1-L11)

**What goes wrong:** The CI workflow still calls Bitfocus's shared module checks, but it no longer looks like the template's: it runs on both push and pull request, the job is renamed, and the template's repository guard and `packages: read` permission are gone. Comparing CI runs against other modules is harder.

**Why it happens:** The file was rewritten by hand: a 5-line comment header was added, the trigger became `on: [push, pull_request]` (template: `on: push:`), the job was renamed `module-checks` (template: `check` with `name: Check module`), and the `if: ${{ !contains(github.repository, 'companion-module-template-') }}` guard and `permissions: packages: read` were dropped.

**Confirm by:** compare [`.github/workflows/companion-module-checks.yaml`](https://github.com/bitfocus/companion-module-churchtranslator-api/blob/0692b6d1abfc3bc8ee8a542fd65e1f84f1c6a3ac/.github/workflows/companion-module-checks.yaml) with the template's file.

**Fix:** replace the file with the template's `.github/workflows/companion-module-checks.yaml`. Uncommenting `upload-artifact: true` there is fine.

## 🟡 Medium

### M1: Cancelled button actions still start or stop the service

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.js:28-125`](https://github.com/bitfocus/companion-module-churchtranslator-api/blob/0692b6d1abfc3bc8ee8a542fd65e1f84f1c6a3ac/src/actions.js#L28-L125), [`src/api.js:73`](https://github.com/bitfocus/companion-module-churchtranslator-api/blob/0692b6d1abfc3bc8ee8a542fd65e1f84f1c6a3ac/src/api.js#L73)

**What goes wrong:** An operator presses "Start service", "Stop service" or "Set speaker's language", then aborts the button's running actions (an abort action, or a trigger that cancels the run). The request to the ChurchTranslator server still goes out and can wait up to 8 seconds, and a full status refresh follows. A press the operator meant to cancel can still start or stop the service. Depends on [A1](#-assumptions-to-confirm).

**Why it happens:** In API 2.1 every action callback receives a cancel signal (`context.signal`, an `AbortSignal`) that fires when the action's result is no longer needed. None of the callbacks takes the `context` argument, and the request helper builds its own timeout signal (`AbortSignal.timeout(this.timeoutMs)`) without combining it with the action's.

**Fix:** pass the action's signal down to the request, and skip the follow-up refresh when it was cancelled.

```js
callback: async (_action, context) =>
	instance.runAction('Start service', () => instance.api.start({ signal: context.signal })),

// in ControlApi #request
signal: AbortSignal.any([AbortSignal.timeout(this.timeoutMs), signal].filter(Boolean)),
```

### M2: Input level meter is drawn with the discouraged bitmap feedback type

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.js:182-203`](https://github.com/bitfocus/companion-module-churchtranslator-api/blob/0692b6d1abfc3bc8ee8a542fd65e1f84f1c6a3ac/src/feedbacks.js#L182-L203), [`src/health.js:186-220`](https://github.com/bitfocus/companion-module-churchtranslator-api/blob/0692b6d1abfc3bc8ee8a542fd65e1f84f1c6a3ac/src/health.js#L186-L220)

**What goes wrong:** Nothing is broken today: the "Input level meter" feedback draws a 10-segment bar on the button. But advanced (bitmap) feedbacks are discouraged in API 2.1 and likely to be removed in a future major version, at which point every meter button would need rebuilding.

**Why it happens:** API 2.1 replaces hand-drawn RGBA bitmaps with composite elements (`setCompositeElementDefinitions`) and layered presets driven by value feedbacks. The module draws the pixels itself in `drawMeter` and returns them as `imageBuffer`.

**Fix:** plan a move to a value feedback that returns the level (or segment count and mode) and render it with a composite element or layered preset. Keeping the advanced feedback for this release is fine.

### M3: Release workflow is missing, so published releases are not packaged by CI

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.github/workflows/release.yaml` (missing)

**What goes wrong:** When the maintainer publishes a GitHub release, nothing builds the module package and attaches it to the release, as it does for every module made from the template. Testers and users can't download the `.tgz` from the release page, and the repo no longer behaves like the template when someone troubleshoots a release.

**Why it happens:** The template ships `.github/workflows/release.yaml`, which runs Bitfocus's shared module checks against the release tag and attaches the built package. The module's `.github/workflows/` only contains `companion-module-checks.yaml`.

**Evidence:**

```text
Required file is missing (tracked by the template): .github/workflows/release.yaml
```

**Confirm by:** browse [`.github/workflows/`](https://github.com/bitfocus/companion-module-churchtranslator-api/tree/0692b6d1abfc3bc8ee8a542fd65e1f84f1c6a3ac/.github/workflows). Only `companion-module-checks.yaml` is there.

**Fix:** copy `.github/workflows/release.yaml` from the template unchanged.

## 🟢 Low

### L1: Disabling the connection while it is still starting can leave the status poll running

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:145-161`](https://github.com/bitfocus/companion-module-churchtranslator-api/blob/0692b6d1abfc3bc8ee8a542fd65e1f84f1c6a3ac/src/main.js#L145-L161), [`src/main.js:173-185`](https://github.com/bitfocus/companion-module-churchtranslator-api/blob/0692b6d1abfc3bc8ee8a542fd65e1f84f1c6a3ac/src/main.js#L173-L185), [`src/main.js:262-284`](https://github.com/bitfocus/companion-module-churchtranslator-api/blob/0692b6d1abfc3bc8ee8a542fd65e1f84f1c6a3ac/src/main.js#L262-L284)

**What goes wrong:** A user enables the connection while the server can't be reached, then disables or deletes it within the roughly 8 seconds the first status request takes to time out. The status poll is then started after the connection was shut down and keeps polling the server every 3-60 seconds in the background until Companion stops the module process. Nothing shows in the UI, and since Companion normally ends the process on disable or delete, this is rarely seen.

**Why it happens:** `init()` and `configUpdated()` wait for the first language and status requests, then start the poll loop. Starting the loop clears the "stopped" flag that `destroy()` set while the requests were in flight, and never checks whether the connection was destroyed meanwhile. The clock and meter code already check `this.destroyed`; the poll loop doesn't.

**Fix:** don't arm the poll timer on a destroyed instance.

```js
#startPolling() {
	if (this.destroyed) return
	// ...
```

### L2: Speaker language lamp and variable can stay on the old language for up to 5 minutes on older servers

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:355-363`](https://github.com/bitfocus/companion-module-churchtranslator-api/blob/0692b6d1abfc3bc8ee8a542fd65e1f84f1c6a3ac/src/main.js#L355-L363), [`src/main.js:374`](https://github.com/bitfocus/companion-module-churchtranslator-api/blob/0692b6d1abfc3bc8ee8a542fd65e1f84f1c6a3ac/src/main.js#L374)

**What goes wrong:** A church whose server predates the speaker-language feature changes the language from the dashboard or by schedule, for example from Russian (`ru`) to English (`en`). The status reply already says `en`, but the "Speaker's language is" feedback keeps lighting the RU button and `$(ct:source_language)` keeps showing `ru`. It corrects only on the 5-minute re-probe, then can go stale again on the next change. Servers that have the speaker-language endpoint are not affected.

**Why it happens:** Once the module has noted that the speaker-language endpoint is missing, each poll fills in the language from the last stored value, and the state is then built as "stored value, else the status reply's value". The stored value is never empty, so it always wins over the fresh value from the status reply. The branch for other failures of that endpoint does the same.

**Fix:** when the endpoint is missing or failed, fall back to the live value from the status reply.

```js
language = { sourceLanguage: status.sourceLanguage || this.state.sourceLanguage }
```

### L3: When the language list cannot be loaded, every status refresh fetches it again and waits for it

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:387-389`](https://github.com/bitfocus/companion-module-churchtranslator-api/blob/0692b6d1abfc3bc8ee8a542fd65e1f84f1c6a3ac/src/main.js#L387-L389)

**What goes wrong:** If the language list request keeps failing (a server with the status endpoint but no language roster, or one returning 500) or returns an empty list, every successful status refresh (every 3 seconds by default) sends an extra request and waits for it before updating the buttons, so the status lamp can lag by up to the 8-second timeout. With an empty list, the log also shows "Loaded 0 languages from the server" every 3 seconds and all action, feedback and preset definitions are re-sent each time.

**Why it happens:** The status refresh re-fetches the language list whenever it is empty, before updating the buttons. Nothing records that a fetch was tried recently, and an empty reply leaves the list empty, so the condition stays true forever.

**Fix:** rate-limit the retry the way the speaker-language re-probe is (for example at most once a minute), run it after updating the buttons or without waiting for it, and treat an empty roster as loaded.

### L4: Per-language variable names can stay as bare language codes

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:464-472`](https://github.com/bitfocus/companion-module-churchtranslator-api/blob/0692b6d1abfc3bc8ee8a542fd65e1f84f1c6a3ac/src/main.js#L464-L472), [`src/main.js:160`](https://github.com/bitfocus/companion-module-churchtranslator-api/blob/0692b6d1abfc3bc8ee8a542fd65e1f84f1c6a3ac/src/main.js#L160)

**What goes wrong:** In the Variables list, `$(ct:listeners_ru)` and `$(ct:health_ru)` can be described as "Listeners on ru (ru)" instead of "Listeners on Russian (ru)". This happens when the first status reply arrives before the language list, or when the language list fails to load, and the names are never corrected. The values are right; this is cosmetic.

**Why it happens:** `init()` fetches the language list and the status at the same time. If the status arrives first, the variable names are built without language labels. The module re-sends variable definitions only when the set of variable IDs changes; when the labels arrive later the IDs are the same, so the corrected names are never sent.

**Fix:** compare the whole definitions (names included), not just the IDs, before deciding whether to re-send them.

```js
const key = JSON.stringify(definitions)
if (key !== this.variableDefsKey) {
	this.variableDefsKey = key
	this.setVariableDefinitions(definitions)
}
```

### L5: Checkbox and fixed-choice options accept expressions they do not need

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.js:82-96`](https://github.com/bitfocus/companion-module-churchtranslator-api/blob/0692b6d1abfc3bc8ee8a542fd65e1f84f1c6a3ac/src/actions.js#L82-L96), [`src/feedbacks.js:130-140`](https://github.com/bitfocus/companion-module-churchtranslator-api/blob/0692b6d1abfc3bc8ee8a542fd65e1f84f1c6a3ac/src/feedbacks.js#L130-L140), [`src/feedbacks.js:162-172`](https://github.com/bitfocus/companion-module-churchtranslator-api/blob/0692b6d1abfc3bc8ee8a542fd65e1f84f1c6a3ac/src/feedbacks.js#L162-L172)

**What goes wrong:** In "Set speaker's language", a user can switch "Switch the running service now" to expression mode; the same goes for "Light when" on "Language in trouble" and "Alarm" on "Input alarm". An expression that returns `1` or `"true"` instead of the boolean `true` is treated as off, so the change applies only to the next service and the user gets no hint why. Depends on [A2](#-assumptions-to-confirm).

**Why it happens:** In API 2.x every option can be switched to expression mode unless it sets `disableAutoExpression: true`, and the action checks `action.options.apply_now === true` strictly.

**Fix:** add `disableAutoExpression: true` to the `apply_now` checkbox and the `when` and `which` dropdowns, or, to keep expression mode on `apply_now`, accept truthy values (`Boolean(action.options.apply_now)`).

## 💡 Nice to Have

### N1: A mistyped Server URL shows a misleading connection error instead of a config error

- **Source:** 🔎 protocol reviewer, QA reviewer, compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:200-207`](https://github.com/bitfocus/companion-module-churchtranslator-api/blob/0692b6d1abfc3bc8ee8a542fd65e1f84f1c6a3ac/src/main.js#L200-L207), [`src/api.js:51`](https://github.com/bitfocus/companion-module-churchtranslator-api/blob/0692b6d1abfc3bc8ee8a542fd65e1f84f1c6a3ac/src/api.js#L51)

**What goes wrong:** The "Server URL" field accepts anything without warning. Typing `api.churchtranslator.ai` (no `https://`) puts the connection in Connection Failure with "Cannot reach api.churchtranslator.ai: Failed to parse URL ..." rather than a config error, and the meter WebSocket can't open either. A pasted URL with a trailing space (`https://api.churchtranslator.ai/`, then a space) sends requests to `/%20/v1/control/...`, and the status then reads "Not found — the church may no longer exist", which sends the operator in the wrong direction.

**Why it happens:** The text field has no `regex` and no `minLength`, and the API client only strips trailing slashes from the URL. It never trims whitespace or checks for an `http://` or `https://` scheme.

**Fix:** validate the field and clean the value before use.

```js
{
	type: 'textinput',
	id: 'baseUrl',
	label: 'Server URL',
	minLength: 1,
	regex: '/^https?:\\/\\/\\S+$/',
	// ...
}

// src/api.js
this.baseUrl = String(baseUrl || '').trim().replace(/\/+$/, '')
```

### N2: Pressing a button on an unconfigured connection briefly shows Authentication Failure

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/api.js:62-64`](https://github.com/bitfocus/companion-module-churchtranslator-api/blob/0692b6d1abfc3bc8ee8a542fd65e1f84f1c6a3ac/src/api.js#L62-L64), [`src/main.js:640-642`](https://github.com/bitfocus/companion-module-churchtranslator-api/blob/0692b6d1abfc3bc8ee8a542fd65e1f84f1c6a3ac/src/main.js#L640-L642)

**What goes wrong:** With no capture token entered, the connection correctly shows Bad Config ("Server URL and capture token required"). Pressing a "Start service" button switches it to Authentication Failure for about 3 seconds until the next status refresh switches it back. The flicker points to a revoked token rather than a missing one; nothing else is affected.

**Why it happens:** The "not configured" error is raised as an authentication error, and the action runner turns every authentication error into an Authentication Failure status.

**Fix:** raise the "not configured" error without the authentication flag and report it as Bad Config, or skip the status update when the API client isn't configured.

## 📝 Additional Notes

- First release: the module has never been published, so there is no previous tag to diff against. The whole module was reviewed and every finding is classified 🆕 NEW.
