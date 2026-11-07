# Review: companion-module-google-nest v1.0.4 (follow-up to the v1.0.1 review)

| | |
| --- | --- |
| **Module** | [companion-module-google-nest](https://github.com/bitfocus/companion-module-google-nest) |
| **Scope** | `tag` |
| **Version** | v1.0.4 (`2864fae`) |
| **Release** | New module — never published |
| **API** | 2.0 (base 2.0.4, yarn.lock) — requires Companion 4.3+ |
| **Template** | `companion-module-template-ts-v2.0.4` @ `d62230e` (2026-08-28, pinned) |
| **Prior review** | [v1.0.1, 2026-10-30](review-google-nest-v1.0.1-20261030-090507.md) — ❌ Changes Required |
| **Review date** | 2026-11-06 |

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Companion shows the message a module passes with its status next to the connection's status in the Connections list, so the user sees the text "fetch failed" | General knowledge of the Companion 4.x Connections page; the host-side rendering is not in `@companion-module/base` | [N1](#n1-when-the-companion-machine-cant-reach-google-the-status-only-says-fetch-failed-as-an-unknown-error) |
| A2 | Companion can store, and pass to the module, a Poll Interval value outside the field's 15-300 range or an empty value; its settings page does not always block saving an out-of-range number | `@companion-module/base` 2.0.4 number-field typings ("values may not conform to this, you should validate the value in your code"); the host's config editor was not checked or live-tested | [L1](#l1-a-poll-interval-of-0-empty-or-below-15-makes-the-module-poll-google-back-to-back) |
| A3 | Node 22's built-in `fetch` does not hand a connection back for reuse until an unread response body is read, cancelled or garbage-collected | undici documentation on unconsumed bodies; not checked in this module's runtime | [N9](#n9-successful-command-responses-are-never-read) |
| A4 | Google lets two homes in one Device Access project each hold a thermostat with the same custom name, so the feedback Device dropdown can show two identical labels | The module itself adds the home name to the action dropdown labels and the variable names ([`src/actionsThermostat.ts:74`](https://github.com/bitfocus/companion-module-google-nest/blob/2864faeb318e5f4c598c089a784f01feb3e2cf59/src/actionsThermostat.ts#L74), [`src/variables.ts:23`](https://github.com/bitfocus/companion-module-google-nest/blob/2864faeb318e5f4c598c089a784f01feb3e2cf59/src/variables.ts#L23)), which suggests the maintainer expects this; Google's naming rules were not checked | [L3](#l3-the-feedbacks-device-dropdown-cant-tell-apart-same-named-thermostats-in-different-homes) |

## 📋 Issues

### Blocking

- [ ] [C1: The .gitignore file no longer matches the template and re-allows committing parts of the .yarn folder](#c1-the-gitignore-file-no-longer-matches-the-template-and-re-allows-committing-parts-of-the-yarn-folder)

### Non-blocking

- [ ] [L1: A Poll Interval of 0, empty or below 15 makes the module poll Google back-to-back](#l1-a-poll-interval-of-0-empty-or-below-15-makes-the-module-poll-google-back-to-back)
- [ ] [L2: With an expired or revoked refresh token, the module still sends one more failing request after the poll interval](#l2-with-an-expired-or-revoked-refresh-token-the-module-still-sends-one-more-failing-request-after-the-poll-interval)
- [ ] [L3: The feedbacks' Device dropdown can't tell apart same-named thermostats in different homes](#l3-the-feedbacks-device-dropdown-cant-tell-apart-same-named-thermostats-in-different-homes)
- [ ] [L4: The current temperature preset looks the same whether the thermostat is online or offline](#l4-the-current-temperature-preset-looks-the-same-whether-the-thermostat-is-online-or-offline)
- [ ] [L5: The Refresh Token tooltip points to the help page for instructions, but the help page has none](#l5-the-refresh-token-tooltip-points-to-the-help-page-for-instructions-but-the-help-page-has-none)
- [ ] [L6: Action option types are re-declared and cast in the callbacks instead of coming from the schema](#l6-action-option-types-are-re-declared-and-cast-in-the-callbacks-instead-of-coming-from-the-schema)
- [ ] [N1: When the Companion machine can't reach Google, the status only says fetch failed, as an unknown error](#n1-when-the-companion-machine-cant-reach-google-the-status-only-says-fetch-failed-as-an-unknown-error)
- [ ] [N2: No feedback shows that a thermostat is in ECO mode, although ECO blocks every setpoint button](#n2-no-feedback-shows-that-a-thermostat-is-in-eco-mode-although-eco-blocks-every-setpoint-button)
- [ ] [N3: The Mode dropdown in Thermostat: Mode active can still be switched to an expression](#n3-the-mode-dropdown-in-thermostat-mode-active-can-still-be-switched-to-an-expression)
- [ ] [N4: Pressing Adjust Temperature right after a mode change logs a warning that contradicts itself](#n4-pressing-adjust-temperature-right-after-a-mode-change-logs-a-warning-that-contradicts-itself)
- [ ] [N5: Fan Timer always shows Run Time (seconds), even when its Mode is Off](#n5-fan-timer-always-shows-run-time-seconds-even-when-its-mode-is-off)
- [ ] [N6: Variable names in the variable list are raw Google API identifiers](#n6-variable-names-in-the-variable-list-are-raw-google-api-identifiers)
- [ ] [N7: Action and feedback names, descriptions and mode labels are inconsistent](#n7-action-and-feedback-names-descriptions-and-mode-labels-are-inconsistent)
- [ ] [N8: Variable definitions are re-sent, and a debug line is logged, on every poll even when nothing changed](#n8-variable-definitions-are-re-sent-and-a-debug-line-is-logged-on-every-poll-even-when-nothing-changed)
- [ ] [N9: Successful command responses are never read](#n9-successful-command-responses-are-never-read)
- [ ] [N10: A stale comment and unused code are left from the previous version](#n10-a-stale-comment-and-unused-code-are-left-from-the-previous-version)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🔴 Critical

### C1: The .gitignore file no longer matches the template and re-allows committing parts of the .yarn folder

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW (introduced after the v1.0.1 review)
- **File:** [`.gitignore:1-52`](https://github.com/bitfocus/companion-module-google-nest/blob/2864faeb318e5f4c598c089a784f01feb3e2cf59/.gitignore#L1-L52)

**What goes wrong:** Since the v1.0.1 review, the `.gitignore` was rewritten (commit `0137018` "Enhance .gitignore with more ignored patterns"). It no longer contains the template's entries `/pkg`, `/*.tgz`, `/dist`, `/.yarn` and `/.vscode`, and it adds exceptions that let parts of the `.yarn` folder be committed again (`.yarn/patches`, `.yarn/plugins`, `.yarn/releases`, `.yarn/sdks`, `.yarn/versions`). The template ignores the whole `.yarn` folder. A developer who runs `git add .` after Yarn has written, for example, a release binary or a plugin into `.yarn/` would commit it to the module repository, and the file no longer matches the template that Bitfocus compares against when troubleshooting a module.

**Why it happens:** The template's 8-line `.gitignore` was replaced by a general-purpose Node / Yarn Berry ignore file instead of being extended. That file uses its own patterns (`dist/`, `pkg/`, `*.tgz`, `.vscode/`, `.yarn/*` plus `!` exceptions) in place of the template's root-anchored ones.

**Evidence:** validator message (verbatim): `Missing template .gitignore entries: /pkg, /*.tgz, /dist, /.yarn, /.vscode`

```text
# .gitignore (module) lines 5-17 and 44-45
# Yarn (Berry)
.yarn/*
!.yarn/patches
!.yarn/plugins
!.yarn/releases
!.yarn/sdks
!.yarn/versions

# Build artifacts
dist/
build/
pkg/
*.tgz
...
# IDE/editor
.vscode/
```

```text
# .gitignore (companion-module-template-ts-v2.0.4)
node_modules/
package-lock.json
/pkg
/*.tgz
/dist
DEBUG-*
/.yarn
/.vscode
```

**Confirm by:** in the module clone, `for e in /pkg '/*.tgz' /dist /.yarn /.vscode; do grep -qxF "$e" .gitignore || echo "missing $e"; done` prints nothing once fixed. Today it prints all five.

**Fix:** start from the template's `.gitignore` and remove the `!.yarn/...` exceptions, which conflict with the template's `/.yarn`. Extra module entries (logs, `.env`, caches, OS files) may stay below the template's lines.

```text
node_modules/
package-lock.json
/pkg
/*.tgz
/dist
DEBUG-*
/.yarn
/.vscode
```

## 🟢 Low

### L1: A Poll Interval of 0, empty or below 15 makes the module poll Google back-to-back

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:113`](https://github.com/bitfocus/companion-module-google-nest/blob/2864faeb318e5f4c598c089a784f01feb3e2cf59/src/main.ts#L113), [`src/main.ts:116-121`](https://github.com/bitfocus/companion-module-google-nest/blob/2864faeb318e5f4c598c089a784f01feb3e2cf59/src/main.ts#L116-L121)

**What goes wrong:** The 'Poll Interval (seconds)' setting asks for 15 to 300, but the module uses whatever value it receives. If the saved value is 0 or empty, the poll timer fires every millisecond, so the module sends a new 'list devices' request as soon as the previous one finishes. A value of 2 polls every 2 seconds. Either way it soon passes the 5-requests-a-minute sandbox limit that the setting's own tooltip warns about, and the connection status flips between OK and an error such as "SDM GET ... failed (429)". Whether Companion lets such a value be saved is [A2](#-assumptions-to-confirm).

**Why it happens:** The module falls back to 30 seconds only when the value is missing altogether (`null` or `undefined`). A 0, an empty value or a number below the minimum goes straight into the timer. The `@companion-module/base` 2.0.4 typings for number fields say the min/max "may not conform to this, you should validate the value in your code".

**Evidence:**

```ts
// src/main.ts:113-121
		this.startPolling(this.config.pollIntervalSec ?? 30)
	}

	private startPolling(intervalSec: number): void {
		this.stopPolling() // never leave an older timer running
		this.pollTimer = setInterval(() => {
			void this.getGoogleNestDevices()
		}, intervalSec * 1000)
	}
```

**Fix:** clamp the value to the field's range before starting the timer.

```ts
const sec = Math.min(300, Math.max(15, Number(this.config.pollIntervalSec) || 30))
this.startPolling(sec)
```

### L2: With an expired or revoked refresh token, the module still sends one more failing request after the poll interval

- **Source:** 🔎 protocol reviewer + QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:98-114`](https://github.com/bitfocus/companion-module-google-nest/blob/2864faeb318e5f4c598c089a784f01feb3e2cf59/src/main.ts#L98-L114), [`src/main.ts:211-217`](https://github.com/bitfocus/companion-module-google-nest/blob/2864faeb318e5f4c598c089a784f01feb3e2cf59/src/main.ts#L211-L217)

**What goes wrong:** A user's OAuth Refresh Token has expired (for example the 7-day expiry the help page warns about) or was pasted wrong. When Companion starts, or the user clicks Save in the connection settings, the status correctly changes to Authentication failure ("Google rejected the refresh token. Generate a new one and save the connection settings"). But one poll interval later (30 s by default) the module asks Google for a token again, logs a second "Poll failed: Token refresh failed (400): ... invalid_grant" line, and only then stops polling. The status shown stays correct; the only effects are one duplicate log line and one wasted request. The code's own comment says it should "stop hammering Google until the user fixes it".

**Why it happens:** When the connection starts, the module waits for the first poll and then always starts the poll timer. If that first poll is rejected with `invalid_grant`, it tries to stop polling before any timer exists, so nothing is stopped; the startup code then starts the timer anyway. Polling only stops after the next poll fails the same way.

**Evidence:**

```ts
// src/main.ts:109-113
		this.client = new SdmClient(this.config, this.secrets)
		this.updateStatus(InstanceStatus.Connecting)

		await this.getGoogleNestDevices()
		this.startPolling(this.config.pollIntervalSec ?? 30)
```

```ts
// src/main.ts:211-217
			if (message.includes('invalid_grant')) {
				// A dead refresh token won't recover on its own, so stop hammering Google until the user fixes it
				this.stopPolling()
				this.updateStatus(
					InstanceStatus.AuthenticationFailure,
```

**Fix:** remember that the first poll hit a dead token, and don't start the timer in that case. For example, set `this.authFailed = true` in the `invalid_grant` branch, reset it to `false` at the start of `restart()`, and start polling only when it is still `false`:

```ts
		await this.getGoogleNestDevices()
		if (!this.authFailed) this.startPolling(this.config.pollIntervalSec ?? 30)
```

### L3: The feedbacks' Device dropdown can't tell apart same-named thermostats in different homes

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.ts:28-37`](https://github.com/bitfocus/companion-module-google-nest/blob/2864faeb318e5f4c598c089a784f01feb3e2cf59/src/feedbacks.ts#L28-L37)

**What goes wrong:** A user has two homes, each with a thermostat called "Living Room". Every action's Device dropdown shows them as "[Home] Living Room" and "[Cabin] Living Room", but the 'Device: Online', 'Thermostat: Mode active' and 'Thermostat: HVAC running' feedbacks list both as just "Living Room". The user may pick the wrong one, and the button then shows the other thermostat's state. Users with one home, or with unique thermostat names, are not affected ([A4](#-assumptions-to-confirm)).

**Why it happens:** The feedback dropdowns label each device with its display name only. The action dropdowns ([`src/actionsThermostat.ts:72-75`](https://github.com/bitfocus/companion-module-google-nest/blob/2864faeb318e5f4c598c089a784f01feb3e2cf59/src/actionsThermostat.ts#L72-L75)) put the home name in front.

**Fix:** use the same label as the actions for both `deviceChoices` and `deviceThermostatChoices`.

```ts
label: `[${d.structureName}] ${getDisplayName(d)}`,
```

### L4: The current temperature preset looks the same whether the thermostat is online or offline

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/presets.ts:56-68`](https://github.com/bitfocus/companion-module-google-nest/blob/2864faeb318e5f4c598c089a784f01feb3e2cf59/src/presets.ts#L56-L68)

**What goes wrong:** A user drags the "Living Room current temperature" preset onto a button. It has the 'Device: Online' feedback attached, but that feedback's style (white text on black) is exactly the button's own style. When the thermostat goes offline the button doesn't change, so the operator gets no warning that the temperature shown is stale.

**Why it happens:** The preset's base style is white on black, and the feedback, which is true while the device is online, also applies white on black. So nothing changes when the device is online, and nothing changes when it goes offline either.

**Evidence:**

```ts
// src/presets.ts:59-66
			style: { text: `${name}\\n$(${self.label}:${tempVar})°C`, size: 'auto', color: WHITE, bgcolor: BLACK },
			steps: [],
			feedbacks: [
				{
					feedbackId: 'device_online',
					options: { deviceId },
					style: { bgcolor: BLACK, color: WHITE },
```

**Fix:** make the offline state visible, for example by inverting the feedback so it applies a red background while the device is offline.

```ts
{
	feedbackId: 'device_online',
	options: { deviceId },
	isInverted: true,
	style: { bgcolor: 0xcc0000, color: WHITE },
},
```

### L5: The Refresh Token tooltip points to the help page for instructions, but the help page has none

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`companion/HELP.md:1-7`](https://github.com/bitfocus/companion-module-google-nest/blob/2864faeb318e5f4c598c089a784f01feb3e2cf59/companion/HELP.md#L1-L7), [`src/config.ts:62`](https://github.com/bitfocus/companion-module-google-nest/blob/2864faeb318e5f4c598c089a784f01feb3e2cf59/src/config.ts#L62)

**What goes wrong:** In the connection settings, the 'OAuth Refresh Token' tooltip says "Obtained from the Google OAuth flow — see HELP.md for instructions". A user who opens the module's help page finds step 4, "Get OAuth tokens", with a bare link and no steps. Step 2 tells them to "enter the Client ID and Client Secret below", but nothing follows it on the help page. The help page also says nothing about the 'Device Access Project ID' field, the actions, feedbacks, presets or variables, or that temperatures are in Celsius only.

**Why it happens:** HELP.md was copied from the settings page's information text ([`src/config.ts:20-25`](https://github.com/bitfocus/companion-module-google-nest/blob/2864faeb318e5f4c598c089a784f01feb3e2cf59/src/config.ts#L20-L25)) and not adapted. This release added step 5 (the 7-day token expiry warning), but the rest is unchanged.

**Fix:** expand `companion/HELP.md`: give the refresh-token steps (or a precise link to the right section of Google's page), say where to find the Device Access Project ID, drop the word "below", and briefly list the actions, feedbacks, presets and the variable naming (`dev_<last 8 characters of the device id>_...`). Or change the tooltip so it no longer promises instructions in HELP.md.

### L6: Action option types are re-declared and cast in the callbacks instead of coming from the schema

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:11-12`](https://github.com/bitfocus/companion-module-google-nest/blob/2864faeb318e5f4c598c089a784f01feb3e2cf59/src/actions.ts#L11-L12), [`src/actionsThermostat.ts:346`](https://github.com/bitfocus/companion-module-google-nest/blob/2864faeb318e5f4c598c089a784f01feb3e2cf59/src/actionsThermostat.ts#L346)

**What goes wrong:** No visible effect for users; this is code quality. The action type list and the action callbacks can drift apart without the compiler noticing. For example, 'Set mode' → Mode is typed as any text, so a typo in a choice id (such as `HEAT_COOL`) would still compile, and the 'Set ECO mode' callback declares its Mode as any text while the type list allows only `OFF` or `MANUAL_ECO`.

**Why it happens:** `set_mode` is declared with `mode: string` in `ActionsSchema`, so its callback needs a cast (`event.options.mode as ThermostatMode`). Every callback also declares its own `CompanionActionEvent<{ ... }>` type ([`src/actionsThermostat.ts:102`](https://github.com/bitfocus/companion-module-google-nest/blob/2864faeb318e5f4c598c089a784f01feb3e2cf59/src/actionsThermostat.ts#L102), [`:149`](https://github.com/bitfocus/companion-module-google-nest/blob/2864faeb318e5f4c598c089a784f01feb3e2cf59/src/actionsThermostat.ts#L149), [`:206-207`](https://github.com/bitfocus/companion-module-google-nest/blob/2864faeb318e5f4c598c089a784f01feb3e2cf59/src/actionsThermostat.ts#L206-L207), [`:275-281`](https://github.com/bitfocus/companion-module-google-nest/blob/2864faeb318e5f4c598c089a784f01feb3e2cf59/src/actionsThermostat.ts#L275-L281), [`:335`](https://github.com/bitfocus/companion-module-google-nest/blob/2864faeb318e5f4c598c089a784f01feb3e2cf59/src/actionsThermostat.ts#L335), [`:369`](https://github.com/bitfocus/companion-module-google-nest/blob/2864faeb318e5f4c598c089a784f01feb3e2cf59/src/actionsThermostat.ts#L369), [`:415`](https://github.com/bitfocus/companion-module-google-nest/blob/2864faeb318e5f4c598c089a784f01feb3e2cf59/src/actionsThermostat.ts#L415)) instead of letting `CompanionActionDefinitions<ActionsSchema>` supply it, and some of those copies are looser than the schema.

**Fix:** type the schema precisely (`set_mode: { options: { deviceId: string; mode: ThermostatMode } }`, and the same for the `thermostat_mode` feedback), drop the explicit `CompanionActionEvent<...>` annotations so each callback's `event.options` comes from `ActionsSchema`, then remove the `as ThermostatMode` cast.

## 💡 Nice to Have

### N1: When the Companion machine can't reach Google, the status only says fetch failed, as an unknown error

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:207-220`](https://github.com/bitfocus/companion-module-google-nest/blob/2864faeb318e5f4c598c089a784f01feb3e2cf59/src/main.ts#L207-L220)

**What goes wrong:** Companion often runs on an isolated show network. If the machine can't reach Google (no internet, DNS down, a firewall), every poll fails. The connection shows Unknown error with the message "fetch failed" ([A1](#-assumptions-to-confirm)), and the log shows "Poll failed: fetch failed". Nothing tells the user it is a network or DNS problem. They do see that the connection is down, just not why.

**Why it happens:** Node's built-in `fetch` rejects with a generic "fetch failed" error and puts the real reason (for example `ENOTFOUND`) in the error's `cause`. The module's error handler only reads the message, and reports every failure other than a rejected token as an unknown error.

**Fix:** add the cause to the message, and report network-level failures as a connection failure.

```ts
const cause = (err as { cause?: { code?: string; message?: string } })?.cause
const detail = cause?.code ?? cause?.message
const message = detail ? `${err.message} (${detail})` : err.message
// use InstanceStatus.ConnectionFailure for a fetch TypeError (no HTTP status), keep UnknownError otherwise
```

### N2: No feedback shows that a thermostat is in ECO mode, although ECO blocks every setpoint button

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.ts:39-117`](https://github.com/bitfocus/companion-module-google-nest/blob/2864faeb318e5f4c598c089a784f01feb3e2cf59/src/feedbacks.ts#L39-L117)

**What goes wrong:** While a thermostat is in ECO, the module refuses 'Adjust Temperature', 'Set Temperature' and their Heat/Cool variants, and logs "is in ECO mode; Google rejects setpoint changes". The operator has the 'Set ECO mode' action but no button feedback that shows ECO is on, so the only way to find out why the setpoint buttons do nothing is to read the log.

**Why it happens:** The feedbacks cover Online, the thermostat mode (Heat, Cool, Heat/Cool, Off) and HVAC running, but not the ECO state, which the module already reads for its ECO check.

**Fix:** add a boolean feedback such as 'Thermostat: ECO active' (true when `traits['sdm.devices.traits.ThermostatEco']?.mode === 'MANUAL_ECO'`), include it in the `checkFeedbacks(...)` calls, and optionally add an ECO toggle preset.

### N3: The Mode dropdown in Thermostat: Mode active can still be switched to an expression

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW (the remaining part of v1.0.1 N1)
- **File:** [`src/feedbacks.ts:77-88`](https://github.com/bitfocus/companion-module-google-nest/blob/2864faeb318e5f4c598c089a784f01feb3e2cf59/src/feedbacks.ts#L77-L88)

**What goes wrong:** No visible problem by default. A user can switch the feedback's Mode dropdown to an expression, where a value like `heat` (lower case) fails validation and Companion skips the feedback without saying why. The action Mode dropdowns were fixed in this release, but this feedback dropdown was not.

**Why it happens:** The fixed-choice Mode dropdown in 'Thermostat: Mode active' doesn't set `disableAutoExpression`.

**Fix:** add `disableAutoExpression: true` to the feedback's Mode dropdown, as the actions already do.

### N4: Pressing Adjust Temperature right after a mode change logs a warning that contradicts itself

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actionsThermostat.ts:112-141`](https://github.com/bitfocus/companion-module-google-nest/blob/2864faeb318e5f4c598c089a784f01feb3e2cf59/src/actionsThermostat.ts#L112-L141)

**What goes wrong:** An operator presses a 'Heat' mode button and, within about 3 seconds, presses 'TEMP ▲'. Nothing changes, and the log says 'Living Room is in HEAT mode; "Adjust Temperature" needs Heat or Cool mode', which reads as a contradiction.

**Why it happens:** 'Set mode' updates only the cached mode. The cached setpoint still holds only the previous mode's value until the follow-up poll 3 seconds later (the module's own comment at [`src/main.ts:136`](https://github.com/bitfocus/companion-module-google-nest/blob/2864faeb318e5f4c598c089a784f01feb3e2cf59/src/main.ts#L136) notes that Google returns only the current mode's setpoints). The action falls through to its warning because the heat setpoint isn't loaded yet, but the message only blames the mode.

**Fix:** tell the two cases apart. When the mode is Heat or Cool but the matching setpoint is missing, log something like "Living Room: heat setpoint not loaded yet, try again in a few seconds".

### N5: Fan Timer always shows Run Time (seconds), even when its Mode is Off

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actionsThermostat.ts:405-413`](https://github.com/bitfocus/companion-module-google-nest/blob/2864faeb318e5f4c598c089a784f01feb3e2cf59/src/actionsThermostat.ts#L405-L413)

**What goes wrong:** A user adds 'Fan Timer' with Mode = Off. The 'Run Time (seconds)' field (900) is still shown, although the action ignores it when Mode is Off. Slightly confusing, but harmless.

**Why it happens:** The Run Time option has no visibility rule.

**Fix:** hide it unless the fan is being turned on. The Mode dropdown already sets `disableAutoExpression: true`, so it can be referenced in a visibility expression (supported by base 2.0.4).

```ts
isVisibleExpression: '$(options:fanMode) == "ON"',
```

### N6: Variable names in the variable list are raw Google API identifiers

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/variables.ts:33`](https://github.com/bitfocus/companion-module-google-nest/blob/2864faeb318e5f4c598c089a784f01feb3e2cf59/src/variables.ts#L33), [`src/variables.ts:46`](https://github.com/bitfocus/companion-module-google-nest/blob/2864faeb318e5f4c598c089a784f01feb3e2cf59/src/variables.ts#L46)

**What goes wrong:** In Companion's variable list, users see names like "[My Home / Living Room] thermostattemperaturesetpoint: heatCelsius", "[My Home / Living Room] thermostathvac: status" or "[My Home / Living Room] info: customName". They are hard to read, and hard to find by searching for "Heat setpoint" or "HVAC status".

**Why it happens:** Each variable's name is built from the lower-cased Google trait name and the raw attribute key.

**Fix:** map the known traits and attributes to friendly names (for example "Heat setpoint (°C)", "Cool setpoint (°C)", "Ambient temperature (°C)", "HVAC status", "Mode", "ECO mode", "Humidity (%)"), and keep the raw form only as a fallback for unknown traits. The variable ids don't need to change.

### N7: Action and feedback names, descriptions and mode labels are inconsistent

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actionsThermostat.ts:317-318`](https://github.com/bitfocus/companion-module-google-nest/blob/2864faeb318e5f4c598c089a784f01feb3e2cf59/src/actionsThermostat.ts#L317-L318), [`src/actionsThermostat.ts:353-354`](https://github.com/bitfocus/companion-module-google-nest/blob/2864faeb318e5f4c598c089a784f01feb3e2cf59/src/actionsThermostat.ts#L353-L354), [`src/actionsThermostat.ts:390-391`](https://github.com/bitfocus/companion-module-google-nest/blob/2864faeb318e5f4c598c089a784f01feb3e2cf59/src/actionsThermostat.ts#L390-L391), [`src/feedbacks.ts:85`](https://github.com/bitfocus/companion-module-google-nest/blob/2864faeb318e5f4c598c089a784f01feb3e2cf59/src/feedbacks.ts#L85)

**What goes wrong:** In the action picker, users see 'Set Temperature' and 'Adjust Temperature' (title case) next to 'Set mode' and 'Set ECO mode' (sentence case). 'Set mode', 'Set ECO mode' and 'Fan Timer' have no description, while the other four actions do. The same mode is labelled 'Heat/Cool' in the actions but 'Heat + Cool' in the 'Thermostat: Mode active' feedback. Cosmetic only.

**Fix:** use one casing style (for example 'Set Mode', 'Set ECO Mode'), add short descriptions to 'Set mode', 'Set ECO mode' and 'Fan Timer', and label HEATCOOL the same way ('Heat/Cool') in the actions and the feedback.

### N8: Variable definitions are re-sent, and a debug line is logged, on every poll even when nothing changed

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:204`](https://github.com/bitfocus/companion-module-google-nest/blob/2864faeb318e5f4c598c089a784f01feb3e2cf59/src/main.ts#L204), [`src/variables.ts:13`](https://github.com/bitfocus/companion-module-google-nest/blob/2864faeb318e5f4c598c089a784f01feb3e2cf59/src/variables.ts#L13), [`src/variables.ts:66-67`](https://github.com/bitfocus/companion-module-google-nest/blob/2864faeb318e5f4c598c089a784f01feb3e2cf59/src/variables.ts#L66-L67)

**What goes wrong:** No visible effect for most users. Every 30 seconds, and after every button press, the module rebuilds and re-sends its full list of variable definitions and writes "Updating variable definitions" to the debug log, even when no device was added or removed. With debug logging on, the log fills with this line, and Companion redoes work for definitions that didn't change.

**Why it happens:** Each poll and each successful command calls the variable update, which always sends both the definitions and the values. The module already has a device-list check for its dropdowns ([`src/main.ts:197-202`](https://github.com/bitfocus/companion-module-google-nest/blob/2864faeb318e5f4c598c089a784f01feb3e2cf59/src/main.ts#L197-L202)) but doesn't use it here.

**Fix:** split the update in two: send the definitions only when the set of variable ids changes (reuse the device signature, plus the set of trait keys), and send just the values (`setVariableValues()`) on every poll. Drop or rate-limit the debug line.

### N9: Successful command responses are never read

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/sdm-client.ts:89-104`](https://github.com/bitfocus/companion-module-google-nest/blob/2864faeb318e5f4c598c089a784f01feb3e2cf59/src/sdm-client.ts#L89-L104)

**What goes wrong:** No visible effect in normal use. After a successful thermostat command, the HTTP response body is left unread, so the connection behind it isn't handed back for reuse until garbage collection ([A3](#-assumptions-to-confirm)).

**Why it happens:** The command helper reads the response body only when the request fails. On success it returns without reading or cancelling it.

**Fix:** on success, read or cancel the body before returning, for example `await res.body?.cancel()`.

### N10: A stale comment and unused code are left from the previous version

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:145-149`](https://github.com/bitfocus/companion-module-google-nest/blob/2864faeb318e5f4c598c089a784f01feb3e2cf59/src/main.ts#L145-L149), [`src/sdm-client.ts:84-87`](https://github.com/bitfocus/companion-module-google-nest/blob/2864faeb318e5f4c598c089a784f01feb3e2cf59/src/sdm-client.ts#L84-L87), [`src/presets.ts:34`](https://github.com/bitfocus/companion-module-google-nest/blob/2864faeb318e5f4c598c089a784f01feb3e2cf59/src/presets.ts#L34)

**What goes wrong:** No visible effect; code quality only. The comment on `buildDeviceSignature()` says the thermostat actions "filter on mode and setpoint presence, so those are included". Neither is included, and the actions no longer filter, which can mislead a future maintainer. `SdmClient.getDevice()` is never called, and the preset id `online` is defined but never used.

**Why it happens:** Left over from the v1.0.1 code after the actions and presets were reworked.

**Fix:** update the comment to say the signature covers the device id, type, home name and display name, and remove `getDevice()` and the unused `online` preset id (or start using them).

## 📝 Additional Notes

- First release: the module has never been published, so there is no published version to diff against. The whole module at v1.0.4 was reviewed, and every finding is classified 🆕 NEW.
- Follow-up to the [v1.0.1 review](review-google-nest-v1.0.1-20261030-090507.md): every finding from that review is fixed, except H1 (the CI workflow), which is no longer reported. [C1](#c1-the-gitignore-file-no-longer-matches-the-template-and-re-allows-committing-parts-of-the-yarn-folder) was introduced after that review. The table below lists each prior finding.
- Build and lint passed (`yarn install --immutable`, `yarn package`, `yarn lint`).

### Prior findings from the v1.0.1 review

| v1.0.1 | Finding | Status in v1.0.4 |
| --- | --- | --- |
| H1 | CI workflow differs from the template and tests on Node 26 | ➖ No longer reported |
| H2 | Every config save adds another poll timer | ✅ Fixed: starting the timer stops the old one first ([`src/main.ts:116-121`](https://github.com/bitfocus/companion-module-google-nest/blob/2864faeb318e5f4c598c089a784f01feb3e2cf59/src/main.ts#L116-L121)), and a restart stops polling before reconnecting ([`src/main.ts:98-99`](https://github.com/bitfocus/companion-module-google-nest/blob/2864faeb318e5f4c598c089a784f01feb3e2cf59/src/main.ts#L98-L99)) |
| H3 | Feedbacks never update after the first draw | ✅ Fixed: the feedbacks are re-checked after every poll ([`src/main.ts:205`](https://github.com/bitfocus/companion-module-google-nest/blob/2864faeb318e5f4c598c089a784f01feb3e2cf59/src/main.ts#L205)) and after every successful command ([`src/actionsThermostat.ts:64`](https://github.com/bitfocus/companion-module-google-nest/blob/2864faeb318e5f4c598c089a784f01feb3e2cf59/src/actionsThermostat.ts#L64)) |
| H4 | Device dropdowns stay empty after the credentials are entered | ✅ Fixed: the definitions are registered in `init()` ([`src/main.ts:45`](https://github.com/bitfocus/companion-module-google-nest/blob/2864faeb318e5f4c598c089a784f01feb3e2cf59/src/main.ts#L45)) and rebuilt whenever the device list changes ([`src/main.ts:197-202`](https://github.com/bitfocus/companion-module-google-nest/blob/2864faeb318e5f4c598c089a784f01feb3e2cf59/src/main.ts#L197-L202)) |
| H5 | Set Temperature ignores its Mode option | ✅ Fixed: the chosen Mode is checked against the thermostat's mode, with a warning when they differ ([`src/actionsThermostat.ts:217-223`](https://github.com/bitfocus/companion-module-google-nest/blob/2864faeb318e5f4c598c089a784f01feb3e2cf59/src/actionsThermostat.ts#L217-L223)) |
| M1 | Thermostats that are Off are missing from the Device dropdowns | ✅ Fixed: every thermostat is listed ([`src/actionsThermostat.ts:70-75`](https://github.com/bitfocus/companion-module-google-nest/blob/2864faeb318e5f4c598c089a784f01feb3e2cf59/src/actionsThermostat.ts#L70-L75)) |
| M2 | Thermostat actions silently do nothing on a mode mismatch | ✅ Fixed: each action logs a warning naming the device and the mode it needs |
| M3 | Variables don't show a setpoint change until the next poll | ✅ Fixed: a successful command updates the cache, the variables and the feedbacks ([`src/actionsThermostat.ts:61-65`](https://github.com/bitfocus/companion-module-google-nest/blob/2864faeb318e5f4c598c089a784f01feb3e2cf59/src/actionsThermostat.ts#L61-L65)) |
| M4 | Client Secret and Refresh Token stored as plain-text config | ✅ Fixed: both are `secret-text` fields kept in Companion's secrets store ([`src/config.ts:9-12`](https://github.com/bitfocus/companion-module-google-nest/blob/2864faeb318e5f4c598c089a784f01feb3e2cf59/src/config.ts#L9-L12), [`src/config.ts:34-39`](https://github.com/bitfocus/companion-module-google-nest/blob/2864faeb318e5f4c598c089a784f01feb3e2cf59/src/config.ts#L34-L39), [`src/config.ts:56-63`](https://github.com/bitfocus/companion-module-google-nest/blob/2864faeb318e5f4c598c089a784f01feb3e2cf59/src/config.ts#L56-L63)) |
| L1 | Minimum poll interval exceeds the rate limit | ✅ Fixed: the minimum is now 15 s, and the home list is fetched at most every 10 minutes, so a normal poll is one request ([`src/config.ts:64-74`](https://github.com/bitfocus/companion-module-google-nest/blob/2864faeb318e5f4c598c089a784f01feb3e2cf59/src/config.ts#L64-L74), [`src/main.ts:164-184`](https://github.com/bitfocus/companion-module-google-nest/blob/2864faeb318e5f4c598c089a784f01feb3e2cf59/src/main.ts#L164-L184)) |
| L2 | A failed command is not logged | ✅ Fixed: failures are logged with the device name ([`src/actionsThermostat.ts:54-59`](https://github.com/bitfocus/companion-module-google-nest/blob/2864faeb318e5f4c598c089a784f01feb3e2cf59/src/actionsThermostat.ts#L54-L59)) |
| L3 | Two token refreshes at once | ✅ Fixed: concurrent requests share one refresh ([`src/sdm-client.ts:49-58`](https://github.com/bitfocus/companion-module-google-nest/blob/2864faeb318e5f4c598c089a784f01feb3e2cf59/src/sdm-client.ts#L49-L58)) |
| L4 | Two config fields share the id `info` | ✅ Fixed: the ids are now `instructions` and `instructions-refreshtoken` ([`src/config.ts:18`](https://github.com/bitfocus/companion-module-google-nest/blob/2864faeb318e5f4c598c089a784f01feb3e2cf59/src/config.ts#L18), [`src/config.ts:50`](https://github.com/bitfocus/companion-module-google-nest/blob/2864faeb318e5f4c598c089a784f01feb3e2cf59/src/config.ts#L50)) |
| L5 | Variable ids change when a device or home is renamed | ✅ Fixed: the ids are built from Google's stable device id ([`src/helpers.ts:19-43`](https://github.com/bitfocus/companion-module-google-nest/blob/2864faeb318e5f4c598c089a784f01feb3e2cf59/src/helpers.ts#L19-L43)) |
| L6 | Template placeholder preset ships in the Presets tab | ✅ Fixed: replaced with real thermostat presets ([`src/presets.ts`](https://github.com/bitfocus/companion-module-google-nest/blob/2864faeb318e5f4c598c089a784f01feb3e2cf59/src/presets.ts)) |
| N1 | Fixed-choice dropdowns allow expression mode | ✅ Fixed in the actions; the 'Thermostat: Mode active' feedback's Mode dropdown still allows it, now [N3](#n3-the-mode-dropdown-in-thermostat-mode-active-can-still-be-switched-to-an-expression) |
