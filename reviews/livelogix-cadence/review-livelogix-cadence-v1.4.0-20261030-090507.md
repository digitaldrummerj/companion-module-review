# Review: companion-module-livelogix-cadence v1.4.0

| | |
| --- | --- |
| **Module** | [`companion-module-livelogix-cadence`](https://github.com/bitfocus/companion-module-livelogix-cadence) |
| **Scope** | `tag` |
| **Version** | `v1.4.0` |
| **Release** | New module — never published |
| **API** | 1 (base 1.14.1, yarn.lock) |
| **Template** | `companion-module-template-js-v1` @ `9e222b4` (2026-03-26, pinned) · `.yarnrc.yml` from `companion-module-template-js` @ `76d25b2` (2026-10-11) |
| **Commit** | [`b2f8c49`](https://github.com/bitfocus/companion-module-livelogix-cadence/tree/b2f8c4951f15d72cf0e9d67fd0a597ed561827e5) |
| **Review date** | 2026-10-30 |

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Companion shows the message a module passes to `updateStatus(status, message)` next to the connection, so a misleading message reaches the operator | General Companion connection-list behaviour; not verifiable from the module code | [L2](#l2-wrong-port-and-internal-errors-are-reported-as-no-response-from-cadence) |

## 📋 Issues

### Blocking

- [ ] [C1: Module source files are at the repository root instead of in src](#c1-module-source-files-are-at-the-repository-root-instead-of-in-src)
- [ ] [H1: Module checks workflow is missing the templates job guard](#h1-module-checks-workflow-is-missing-the-templates-job-guard)

### Non-blocking

- [ ] [M1: GitHub issue templates are missing](#m1-github-issue-templates-are-missing)
- [ ] [M2: Planning Center LIVE presets do not appear when a schedule is linked after Companion connects](#m2-planning-center-live-presets-do-not-appear-when-a-schedule-is-linked-after-companion-connects)
- [ ] [M3: Variables in action text fields are expanded twice](#m3-variables-in-action-text-fields-are-expanded-twice)
- [ ] [L1: Put on air and Start immediately still run after the first command fails](#l1-put-on-air-and-start-immediately-still-run-after-the-first-command-fails)
- [ ] [L2: Wrong-port and internal errors are reported as No response from Cadence](#l2-wrong-port-and-internal-errors-are-reported-as-no-response-from-cadence)
- [ ] [L3: A poll can finish and stray abort timers fire after the connection is removed](#l3-a-poll-can-finish-and-stray-abort-timers-fire-after-the-connection-is-removed)
- [ ] [L4: Every poll resends every variable and re-checks every feedback even when nothing changed](#l4-every-poll-resends-every-variable-and-re-checks-every-feedback-even-when-nothing-changed)
- [ ] [L5: Negative durations are accepted when typed as plain seconds](#l5-negative-durations-are-accepted-when-typed-as-plain-seconds)
- [ ] [L6: Conditional option fields use the deprecated isVisible function](#l6-conditional-option-fields-use-the-deprecated-isvisible-function)
- [ ] [N1: Offline blanking also wipes fixed values such as an automation trigger time](#n1-offline-blanking-also-wipes-fixed-values-such-as-an-automation-trigger-time)
- [ ] [NR1: Plan a move to the v2 module API](#nr1-plan-a-move-to-the-v2-module-api)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🔴 Critical

### C1: Module source files are at the repository root instead of in src

- **Source:** 🤖 validate-template (SRC-AT-ROOT)
- **Classification:** 🆕 NEW
- **Files:** [`actions.js`](https://github.com/bitfocus/companion-module-livelogix-cadence/blob/b2f8c4951f15d72cf0e9d67fd0a597ed561827e5/actions.js), [`config.js`](https://github.com/bitfocus/companion-module-livelogix-cadence/blob/b2f8c4951f15d72cf0e9d67fd0a597ed561827e5/config.js), [`definitions.js`](https://github.com/bitfocus/companion-module-livelogix-cadence/blob/b2f8c4951f15d72cf0e9d67fd0a597ed561827e5/definitions.js), [`feedbacks.js`](https://github.com/bitfocus/companion-module-livelogix-cadence/blob/b2f8c4951f15d72cf0e9d67fd0a597ed561827e5/feedbacks.js), [`helpers.js`](https://github.com/bitfocus/companion-module-livelogix-cadence/blob/b2f8c4951f15d72cf0e9d67fd0a597ed561827e5/helpers.js), [`main.js`](https://github.com/bitfocus/companion-module-livelogix-cadence/blob/b2f8c4951f15d72cf0e9d67fd0a597ed561827e5/main.js), [`presets.js`](https://github.com/bitfocus/companion-module-livelogix-cadence/blob/b2f8c4951f15d72cf0e9d67fd0a597ed561827e5/presets.js), [`roundtrip-test.js`](https://github.com/bitfocus/companion-module-livelogix-cadence/blob/b2f8c4951f15d72cf0e9d67fd0a597ed561827e5/roundtrip-test.js), [`test-harness.js`](https://github.com/bitfocus/companion-module-livelogix-cadence/blob/b2f8c4951f15d72cf0e9d67fd0a597ed561827e5/test-harness.js), [`upgrades.js`](https://github.com/bitfocus/companion-module-livelogix-cadence/blob/b2f8c4951f15d72cf0e9d67fd0a597ed561827e5/upgrades.js), [`variables.js`](https://github.com/bitfocus/companion-module-livelogix-cadence/blob/b2f8c4951f15d72cf0e9d67fd0a597ed561827e5/variables.js)

**What goes wrong:** All 11 JavaScript files of the module sit at the top of the repository. The v1 JS template, and every module built from it, keeps its source under `src/`. Anyone who later maintains or troubleshoots the module expects that layout.

**Why it happens:** The module was laid out flat rather than following the template. The validator reports each of the 11 files above as "Source file at module root — all source must be under src/".

**Evidence:** the validator found these files at the repository root; the template has `src/main.js`, `src/actions.js`, and so on. The entry points also point at the root: [`package.json`](https://github.com/bitfocus/companion-module-livelogix-cadence/blob/b2f8c4951f15d72cf0e9d67fd0a597ed561827e5/package.json) has `"main": "main.js"` and [`companion/manifest.json`](https://github.com/bitfocus/companion-module-livelogix-cadence/blob/b2f8c4951f15d72cf0e9d67fd0a597ed561827e5/companion/manifest.json) has `"entrypoint": "../main.js"`.

**Fix:** move the module source into `src/` the way the v1 JS template does (`src/main.js`, `src/actions.js`, …). Then update the entry points to match:

```json
"main": "src/main.js"
```

```json
"entrypoint": "../src/main.js"
```

Move the root test and smoke scripts (`roundtrip-test.js`, `test-harness.js`) under `src/` or `test/`, and update the `smoke` script in `package.json` to the new path.

## 🟠 High

### H1: Module checks workflow is missing the templates job guard

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.github/workflows/companion-module-checks.yaml:8-13`](https://github.com/bitfocus/companion-module-livelogix-cadence/blob/b2f8c4951f15d72cf0e9d67fd0a597ed561827e5/.github/workflows/companion-module-checks.yaml#L8-L13)

**What goes wrong:** The GitHub workflow that runs the Bitfocus module checks on every push is not the template's file. It lacks the guard line the template uses to decide when the job runs, and the commented hint that shows how to upload the built package as an artifact.

**Why it happens:** The module's workflow goes straight from `name: Check module` to `permissions:`. The template's job guard (template line 10) and its commented `# with:` / `#   upload-artifact: true` hint lines (template lines 16-17) were left out.

**Evidence:**

```yaml
# .github/workflows/companion-module-checks.yaml:8-13 (module)
    name: Check module

    permissions:
      packages: read

    uses: bitfocus/actions/.github/workflows/module-checks.yaml@main
```

```yaml
# .github/workflows/companion-module-checks.yaml:8-17 (template)
    name: Check module

    if: ${{ !contains(github.repository, 'companion-module-template-') }}

    permissions:
      packages: read

    uses: bitfocus/actions/.github/workflows/module-checks.yaml@main
    # with:
    #   upload-artifact: true # uncomment this to upload the built package as an artifact to this workflow that you can download and share with others
```

**Confirm by:** `diff companion-module-template-js-v1/.github/workflows/companion-module-checks.yaml .github/workflows/companion-module-checks.yaml`. The `if:` line shows as removed (see [`.github/workflows/companion-module-checks.yaml:8-13`](https://github.com/bitfocus/companion-module-livelogix-cadence/blob/b2f8c4951f15d72cf0e9d67fd0a597ed561827e5/.github/workflows/companion-module-checks.yaml#L8-L13)).

**Fix:** copy the template's workflow file over the module's, verbatim.

## 🟡 Medium

### M1: GitHub issue templates are missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **Files:** `.github/ISSUE_TEMPLATE/bug_report.yml`, `.github/ISSUE_TEMPLATE/config.yml`, `.github/ISSUE_TEMPLATE/feature_request.yml`

**What goes wrong:** Users who open an issue on the module's GitHub repository get a blank form instead of the standard bug-report and feature-request forms, so reports arrive without the version and setup details the maintainer needs.

**Why it happens:** The three issue-template files the v1 JS template tracks are not in the repository.

**Fix:** copy the three files from the template's `.github/ISSUE_TEMPLATE/` folder.

### M2: Planning Center LIVE presets do not appear when a schedule is linked after Companion connects

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`helpers.js:239-267`](https://github.com/bitfocus/companion-module-livelogix-cadence/blob/b2f8c4951f15d72cf0e9d67fd0a597ed561827e5/helpers.js#L239-L267)

**What goes wrong:** An operator has Companion connected to Cadence and then links the schedule "Sunday 9am" to Planning Center Services LIVE. Companion's Presets panel never shows the "Planning Center LIVE: Next item / Back / Take control" buttons for that schedule, and the "Schedule (Planning Center)" dropdown in the "Schedule: Planning Center LIVE" action keeps listing every schedule. Both refresh only after something else changes (renaming or adding a timer, for example) or after the operator disables and re-enables the connection.

**Why it happens:** The module rebuilds its action, feedback and preset definitions only when a "shape signature" of the Cadence data changes. For schedules that signature is just the id and name, so a schedule gaining or losing its Planning Center link leaves it unchanged. The Planning Center presets ([`presets.js:230`](https://github.com/bitfocus/companion-module-livelogix-cadence/blob/b2f8c4951f15d72cf0e9d67fd0a597ed561827e5/presets.js#L230)) and the schedule dropdown both depend on that link, which the signature doesn't include. The comment in `pcoScheduleChoices` shows the module expects the link to appear later in a session.

**Fix:** include the Planning Center link in the schedule part of the signature. Also check every other field that presets or dropdown labels read (for example the output `kind`) and make sure it is either in the signature or truly static.

```js
ids(s.schedules, (x) => `${x.id}:${x.pco ? 'pco' : ''}`),
```

### M3: Variables in action text fields are expanded twice

- **Source:** 🔎 compliance reviewer, QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`actions.js:24-28`](https://github.com/bitfocus/companion-module-livelogix-cadence/blob/b2f8c4951f15d72cf0e9d67fd0a597ed561827e5/actions.js#L24-L28), plus lines 84, 108, 131, 154, 218, 318, 404, 447, 495, 497, 571, 626, 706

**What goes wrong:** Usually nothing a user can see. In one case the output changes: a variable whose value itself contains `$(...)` text is expanded a second time. If a custom variable holds the literal text `Use $(internal:time_hms)`, "Message: Set text" sends the current time instead of that text. Each of the 14 calls is also an extra round trip to Companion on every button press.

**Why it happens:** Companion already replaces variables in every text field marked `useVariables: true` before it runs the action's callback. The module then runs `self.parseVariablesInString()` on the already-resolved value again. That instance method is also marked `@deprecated` in `@companion-module/base` 1.14.1 ("Companion now handles this for you, for actions and feedbacks"). The module uses no local variables, so the calls aren't needed for those either.

**Fix:** remove the `self.parseVariablesInString(...)` wrappers and read the option values directly, keeping `useVariables: true` on the fields so Companion keeps parsing them. For example, in `resolveOverride`:

```js
return String(options.overrideId || '').trim() || options.pick
```

## 🟢 Low

### L1: Put on air and Start immediately still run after the first command fails

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`actions.js:110-111`](https://github.com/bitfocus/companion-module-livelogix-cadence/blob/b2f8c4951f15d72cf0e9d67fd0a597ed561827e5/actions.js#L110-L111), [`actions.js:186-187`](https://github.com/bitfocus/companion-module-livelogix-cadence/blob/b2f8c4951f15d72cf0e9d67fd0a597ed561827e5/actions.js#L186-L187), [`actions.js:405-406`](https://github.com/bitfocus/companion-module-livelogix-cadence/blob/b2f8c4951f15d72cf0e9d67fd0a597ed561827e5/actions.js#L405-L406)

**What goes wrong:** An operator uses "Message: Set text" with "Also put it on air (Shown)" ticked to change the lower-third to "Doors close in 5 min". If Cadence rejects the text update, the module still puts the message on air, so the old text goes out. In the same way, "Timer: Set duration" or "Timer: Load edit-window preset slot" with "Start immediately" can start the timer with its previous duration after a failed update.

**Why it happens:** The module's send helper never throws; on failure it returns a reply with `ok: false`. The action callbacks ignore that reply and always send the follow-up command.

**Fix:** check the reply before sending the second command.

```js
const ack = await self.sendCommand({ action: 'msgText', message, text })
if (ack?.ok === false) return
if (event.options.show) await self.sendCommand({ action: 'msgVis', message, vis: 'shown' })
```

### L2: Wrong-port and internal errors are reported as No response from Cadence

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`main.js:66-81`](https://github.com/bitfocus/companion-module-livelogix-cadence/blob/b2f8c4951f15d72cf0e9d67fd0a597ed561827e5/main.js#L66-L81)

**What goes wrong:** If the user enters a port that serves an HTML page, or a Cadence reply has an unexpected shape that makes the module's own code throw, the connection status reads "No response from Cadence at 192.168.1.20:8730 (Unexpected token '<' …)" and asks "Is Cadence open on that Mac?". The user is sent to check the network when the real cause is the wrong service or a module bug, and no stack trace is logged.

**Why it happens:** One `try/catch` wraps the request, the JSON parse and all of the reply handling (variables, definitions, feedbacks). Every error in that block is turned into the same "No response from Cadence" message.

**Fix:** handle the three steps separately. Report a JSON parse failure as "Not a Cadence reply" (`BadConfig` or `UnknownError`), and for an error from the reply handling log `e.stack` and set `InstanceStatus.UnknownError` instead of a network failure.

### L3: A poll can finish and stray abort timers fire after the connection is removed

- **Source:** 🔎 QA reviewer, compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`main.js:24-26`](https://github.com/bitfocus/companion-module-livelogix-cadence/blob/b2f8c4951f15d72cf0e9d67fd0a597ed561827e5/main.js#L24-L26), [`main.js:66-81`](https://github.com/bitfocus/companion-module-livelogix-cadence/blob/b2f8c4951f15d72cf0e9d67fd0a597ed561827e5/main.js#L66-L81)

**What goes wrong:** Mostly invisible. If a user disables or deletes the connection while a poll is in flight, or right after a button press queued a re-poll, that request still finishes, can start one more request, and can update status and variables on a connection that has already been shut down. Separately, while Cadence is closed each 250 ms poll fails at once and leaves a 4-second abort timer running, so about 16 stray timers are alive at any moment, and some keep running for up to 4 seconds after `destroy()`.

**Why it happens:** `destroy()` only clears the polling interval. Nothing marks the instance as destroyed, so the poll's `finally` block (`if (this.repoll) this.poll()`) and the reply handling carry on. The abort timer is cleared only on the success path, after the request resolves; when the request fails, control jumps to `catch` and the timer is left running.

**Fix:** set a `destroyed` flag in `destroy()` and return early from `poll()`, its `finally` block and the reply handling when it is set. Clear the abort timer in `finally` (or use `AbortSignal.timeout(4000)`), and optionally abort the current request in `destroy()`.

```js
let to
try {
	const ctrl = new AbortController()
	to = setTimeout(() => ctrl.abort(), 4000)
	// …
} finally {
	clearTimeout(to)
	this.polling = false
	if (this.repoll && !this.destroyed) this.poll()
}
```

### L4: Every poll resends every variable and re-checks every feedback even when nothing changed

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`definitions.js:19-22`](https://github.com/bitfocus/companion-module-livelogix-cadence/blob/b2f8c4951f15d72cf0e9d67fd0a597ed561827e5/definitions.js#L19-L22)

**What goes wrong:** With the default "Poll interval (ms)" of 250 and a show with, say, 8 timers, 10 clocks, 3 schedules and 2 polls, the module sends several hundred variable values to Companion and re-evaluates every feedback on every button 4 times a second, even while every clock is paused. On a busy Companion host this adds CPU load that does no useful work. It is not a functional bug.

**Why it happens:** After every poll the module sends the full set of variable values and then calls `checkFeedbacks()` with no feedback ids, which re-checks all of them. `setVariableValues()` in `@companion-module/base` 1.14.1 forwards every entry without comparing it to the previous value.

**Fix:** remember the last values sent and pass only the changed ones to `setVariableValues()`. Skip `checkFeedbacks()` when the snapshot (without its `now` field) is unchanged, or pass only the affected feedback ids.

### L5: Negative durations are accepted when typed as plain seconds

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`helpers.js:43-55`](https://github.com/bitfocus/companion-module-livelogix-cadence/blob/b2f8c4951f15d72cf0e9d67fd0a597ed561827e5/helpers.js#L43-L55)

**What goes wrong:** In "Timer: Set duration", "Timer: Set remaining" or "Cue Stack: Add a time", typing `-5:00` is correctly ignored, but typing `-300` (or a variable that resolves to a negative number) sends a duration of -300 seconds to Cadence. The two input formats are validated inconsistently.

**Why it happens:** The `mm:ss` branch of the duration parser rejects negative parts, but the plain-number branch accepts any finite number.

**Fix:** reject negative plain numbers too.

```js
return Number.isFinite(n) && n >= 0 ? Math.round(n) : null
```

### L6: Conditional option fields use the deprecated isVisible function

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`actions.js:544`](https://github.com/bitfocus/companion-module-livelogix-cadence/blob/b2f8c4951f15d72cf0e9d67fd0a597ed561827e5/actions.js#L544), [`actions.js:650`](https://github.com/bitfocus/companion-module-livelogix-cadence/blob/b2f8c4951f15d72cf0e9d67fd0a597ed561827e5/actions.js#L650), [`actions.js:691`](https://github.com/bitfocus/companion-module-livelogix-cadence/blob/b2f8c4951f15d72cf0e9d67fd0a597ed561827e5/actions.js#L691)

**What goes wrong:** Nothing visible today. The "Row number" field in "Cue Stack: Select a preset", "Answers per phone" in "Poll: Open answers" and "Rank" in "Poll: Selected answer" all show and hide correctly. They rely on `isVisible` functions, which API 1.12 deprecated and API 2.x no longer supports, so they will need rewriting when the module moves to v2.

**Why it happens:** The three fields use `isVisible: (o) => …` functions instead of `isVisibleExpression`, the replacement since v1.12.

**Fix:** replace each function with an expression.

```js
isVisibleExpression: "$(options:which) == 'number'",
isVisibleExpression: "$(options:what) == 'perPhone'",
isVisibleExpression: "$(options:what) == 'rank'",
```

## 💡 Nice to Have

### N1: Offline blanking also wipes fixed values such as an automation trigger time

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`variables.js:352-360`](https://github.com/bitfocus/companion-module-livelogix-cadence/blob/b2f8c4951f15d72cf0e9d67fd0a597ed561827e5/variables.js#L352-L360)

**What goes wrong:** When Cadence goes offline, variables such as `$(cadence:automation_<id>_time)` (a configured trigger time like "2:30 PM"), `schedule_<id>_ondeck_time`, `schedule_<id>_next_time` and `schedule_<id>_pco_remaining` change to "--:--" or blank. The Automation preset button then shows "--:--" instead of its fixed trigger time. This is cosmetic.

**Why it happens:** The blanking is meant for live clock times, but its pattern `/_(time|remaining_hms)$/` matches every variable whose id ends in `_time`.

**Fix:** limit the blanking to the live-time variables, for example `/^(timer_\d+|clock_.+)_(time|remaining_hms)$/`, or flag the live fields in the variable tables and blank only those.

## 🔮 Next Release

### NR1: Plan a move to the v2 module API

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-livelogix-cadence/blob/b2f8c4951f15d72cf0e9d67fd0a597ed561827e5/package.json)

**What goes wrong:** Nothing breaks today; API 1.14 works on Companion 4.2 and later. Moving to `@companion-module/base` v2.0 (Companion 4.3+) or v2.1 (Companion 5.0+) gives users expression support in options and removes the deprecated patterns above ([M3](#m3-variables-in-action-text-fields-are-expanded-twice), [L6](#l6-conditional-option-fields-use-the-deprecated-isvisible-function)).

**Fix:** in a future release, follow the v1-to-v2 migration guidance: ESM entry point, `isVisibleExpression`, no `parseVariablesInString`, and the v2 preset and feedback shapes.

## 📝 Additional Notes

- First release: the module has never been published, so there is no previous tag to diff against. The whole module was reviewed, and every finding is classified 🆕 NEW.
