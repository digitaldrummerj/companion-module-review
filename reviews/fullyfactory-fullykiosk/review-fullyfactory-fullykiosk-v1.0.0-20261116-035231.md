# Review: fullyfactory-fullykiosk v1.0.0

| Item | Detail |
| --- | --- |
| **Module** | `companion-module-fullyfactory-fullykiosk` |
| **Version** | v1.0.0 |
| **Release** | New module — never published |
| **API** | 2.1 (base 2.1.3, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Scope** | `tag`: this is the first release and there is no published version to diff against, so the whole module was reviewed |
| **Review commit** | [`168c36b`](https://github.com/bitfocus/companion-module-fullyfactory-fullykiosk/tree/168c36be8ce41780dba77c5d785a5d609c29d6ba) |
| **Reviewed** | 2026-11-16 |

## Verdict: ✅ Approved

## ❓ Assumptions

Some findings depend on assumptions the reviewers couldn't check. They're listed in [❓ Assumptions to Confirm](#-assumptions-to-confirm) at the end of this review.

## 📋 Issues

### Non-blocking

- [ ] [M1: Aborting a button's running actions doesn't cancel a pending Fully Kiosk request](#m1-aborting-a-buttons-running-actions-doesnt-cancel-a-pending-fully-kiosk-request)
- [ ] [L1: Connection status shows only "fetch failed" for every network error](#l1-connection-status-shows-only-fetch-failed-for-every-network-error)
- [ ] [L2: Pressing the volume step buttons several times quickly loses steps](#l2-pressing-the-volume-step-buttons-several-times-quickly-loses-steps)
- [ ] [L3: Screen toggle button flips colour even when the command failed](#l3-screen-toggle-button-flips-colour-even-when-the-command-failed)
- [ ] [L4: Buttons with the toggle, step actions or feedbacks stop working when polling is turned off](#l4-buttons-with-the-toggle-step-actions-or-feedbacks-stop-working-when-polling-is-turned-off)
- [ ] [L5: Device state feedback shows two invert checkboxes](#l5-device-state-feedback-shows-two-invert-checkboxes)
- [ ] [L6: Stream option needs bare Android stream numbers in expression mode](#l6-stream-option-needs-bare-android-stream-numbers-in-expression-mode)
- [ ] [L7: Type casts turn off schema checking for presets, actions, feedbacks and variables](#l7-type-casts-turn-off-schema-checking-for-presets-actions-feedbacks-and-variables)
- [ ] [N1: Host typed as a URL or with a trailing space shows Connection Failure instead of Bad Config](#n1-host-typed-as-a-url-or-with-a-trailing-space-shows-connection-failure-instead-of-bad-config)
- [ ] [N2: Wrong Remote Admin password shows as Connection Failure instead of Authentication Failure](#n2-wrong-remote-admin-password-shows-as-connection-failure-instead-of-authentication-failure)
- [ ] [N3: Battery, volume and screen variables are published as text, not numbers or booleans](#n3-battery-volume-and-screen-variables-are-published-as-text-not-numbers-or-booleans)
- [ ] [N4: Custom command breaks parameter values that contain an ampersand or a plus sign](#n4-custom-command-breaks-parameter-values-that-contain-an-ampersand-or-a-plus-sign)
- [ ] [N5: A missing poll interval would make polling run back-to-back](#n5-a-missing-poll-interval-would-make-polling-run-back-to-back)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟡 Medium

### M1: Aborting a button's running actions doesn't cancel a pending Fully Kiosk request

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:83`](https://github.com/bitfocus/companion-module-fullyfactory-fullykiosk/blob/168c36be8ce41780dba77c5d785a5d609c29d6ba/src/actions.ts#L83), [`src/api.ts:65`](https://github.com/bitfocus/companion-module-fullyfactory-fullykiosk/blob/168c36be8ce41780dba77c5d785a5d609c29d6ba/src/api.ts#L65), [`src/main.ts:86-89`](https://github.com/bitfocus/companion-module-fullyfactory-fullykiosk/blob/168c36be8ce41780dba77c5d785a5d609c29d6ba/src/main.ts#L86-L89)

**What goes wrong:** A user stops a running button (Companion's abort-actions function, or a press that cancels the button's running actions) while a slow tablet is still answering. The module ignores the abort and keeps waiting for the reply for up to 5 seconds. If the request then times out, the connection turns red with "Connection failure: The operation was aborted due to timeout", even though the user had already cancelled the action. Most of the time the only effect is the wait.

**Why it happens:** Companion gives every action callback an abort signal (`context.signal`), which fires when the result is no longer needed, for example when the user aborts the running actions. Every action goes through `run()` → `send()` → `callApi()`, and the request only uses its own 5-second timeout, so the user's abort never reaches it. The base package says respecting the signal is optional, but the API 2.1 compliance rules recommend it for actions that make network requests.

**Fix:** pass the callback's signal down to the request, combined with the timeout, and don't mark the connection as failed when the user aborted.

```ts
// src/actions.ts: take the context and pass its signal on
callback: async (e, ctx) => void (await run('setAudioVolume', { level: e.options.level, stream: e.options.stream }, ctx.signal)),

// src/api.ts: combine the user's abort with the timeout
const signal = abort ? AbortSignal.any([abort, AbortSignal.timeout(5000)]) : AbortSignal.timeout(5000)
const res = await fetch(buildUrl(config, secrets, cmd, params), { signal })

// src/main.ts send(): a user abort is not a connection failure
} catch (e) {
	if (abort?.aborted) throw e // Companion ignores errors thrown after an abort
	this.fail(e)
	return undefined
}
```

Reference: companion-v2-actions skill (abort signals).

## 🟢 Low

### L1: Connection status shows only "fetch failed" for every network error

- **Source:** 🔎 protocol reviewer + QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:92-96`](https://github.com/bitfocus/companion-module-fullyfactory-fullykiosk/blob/168c36be8ce41780dba77c5d785a5d609c29d6ba/src/main.ts#L92-L96)

**What goes wrong:** A user adds a Fully Kiosk connection and types a wrong IP (e.g. 192.168.1.99), the wrong port (e.g. 2324), or the tablet is asleep or off Wi-Fi. The connection goes red with "Connection Failure: fetch failed", and the log says only "fetch failed", once per poll (every 5 seconds by default) for as long as the tablet stays unreachable. The message is the same whether the name doesn't resolve, the port is closed or the host can't be reached, so the user gets no hint about what to fix. Timeouts and a wrong password (HTTP 403) already get clear messages; this is only about plain network errors.

**Why it happens:** Node's built-in `fetch` reports every network error as `TypeError('fetch failed')` and puts the real reason in the error's `cause` (e.g. `{ code: 'ECONNREFUSED' }`). The module's `fail()` shows only the error's `message`, so the reason is dropped. The reviewers checked this with Node's `fetch`: a wrong host and a closed port both give "fetch failed", and the cause carries the real code (ENOTFOUND for the bad host).

**Fix:** add the cause's error code to the message when there is one, so the status reads e.g. "fetch failed (ECONNREFUSED)".

```ts
private fail(e: unknown): void {
	let msg = e instanceof Error ? e.message : String(e)
	const cause = e instanceof Error ? e.cause : undefined
	if (cause instanceof Error) msg += ` (${(cause as NodeJS.ErrnoException).code ?? cause.message})`
	this.log('error', msg)
	this.updateStatus(InstanceStatus.ConnectionFailure, msg)
}
```

### L2: Pressing the volume step buttons several times quickly loses steps

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:160-169`](https://github.com/bitfocus/companion-module-fullyfactory-fullykiosk/blob/168c36be8ce41780dba77c5d785a5d609c29d6ba/src/actions.ts#L160-L169)

**What goes wrong:** With polling on and the music volume at 50, a user presses the "Vol +10" preset (action "Audio: change volume by step", Stream "Music / media") three times quickly. The first press sets 60. A press that lands before the next successful poll still sees 50 and sends 60 again, so the tablet ends at 60 or 70 instead of 80. The `volume_music` variable also stays at 50 until a poll comes back. "Screen: change brightness by step" doesn't have this problem, because it remembers the level it just set.

**Why it happens:** The step action works out the new level from the last polled values and never stores the level it just sent. It relies on the follow-up poll to catch up, but that poll isn't awaited, and it is skipped entirely when an interval poll is already running (`if (this.polling) return` in [`src/main.ts:100`](https://github.com/bitfocus/companion-module-fullyfactory-fullykiosk/blob/168c36be8ce41780dba77c5d785a5d609c29d6ba/src/main.ts#L100)); then the old value stays until the next interval poll. The brightness step action sets `self.info.screenBrightness = level` right after sending ([`src/actions.ts:232`](https://github.com/bitfocus/companion-module-fullyfactory-fullykiosk/blob/168c36be8ce41780dba77c5d785a5d609c29d6ba/src/actions.ts#L232)); the volume step action has no equivalent.

**Fix:** after a successful volume command, store the new level for that stream, the same way the brightness step action does (and update the matching `volume_*` variable).

```ts
const reply = await run('setAudioVolume', { level, stream: e.options.stream })
if (reply !== undefined && !replyError(reply)) {
	const key = String(e.options.stream)
	self.info.audioVolumes = [...(self.info.audioVolumes ?? []).filter((v) => !(key in v)), { [key]: level }]
}
void self.poll()
```

### L3: Screen toggle button flips colour even when the command failed

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:208-218`](https://github.com/bitfocus/companion-module-fullyfactory-fullykiosk/blob/168c36be8ce41780dba77c5d785a5d609c29d6ba/src/actions.ts#L208-L218), [`src/actions.ts:231-232`](https://github.com/bitfocus/companion-module-fullyfactory-fullykiosk/blob/168c36be8ce41780dba77c5d785a5d609c29d6ba/src/actions.ts#L231-L232)

**What goes wrong:** A user presses the "Screen toggle" preset (action "Screen: toggle on/off") while the tablet is unreachable, or while Fully rejects the command with an error reply. The button still switches at once from green (screen on) to dark red (screen off), although nothing changed on the tablet. If the tablet stays unreachable, the follow-up poll fails too, so the button keeps showing the wrong state until a poll succeeds. "Screen: change brightness by step" does the same with the stored brightness.

**Why it happens:** `send()` returns nothing on a network error and returns the reply on a Fully error reply (`{ status: 'Error' }`), but the toggle ignores the result. It flips the stored screen state and refreshes the feedbacks either way.

**Fix:** only update the stored state when the command succeeded. Do the same in the brightness step action before it stores the new level.

```ts
const reply = await run(self.info.screenOn ? 'screenOff' : 'screenOn')
if (reply === undefined || replyError(reply)) return
self.info.screenOn = !self.info.screenOn
self.checkFeedbacks('state')
void self.poll()
```

### L4: Buttons with the toggle, step actions or feedbacks stop working when polling is turned off

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:261-266`](https://github.com/bitfocus/companion-module-fullyfactory-fullykiosk/blob/168c36be8ce41780dba77c5d785a5d609c29d6ba/src/actions.ts#L261-L266), [`src/feedbacks.ts:21-25`](https://github.com/bitfocus/companion-module-fullyfactory-fullykiosk/blob/168c36be8ce41780dba77c5d785a5d609c29d6ba/src/feedbacks.ts#L21-L25)

**What goes wrong:** A user has built buttons with "Screen: toggle on/off", "Audio: change volume by step" or "Screen: change brightness by step", or with the "Device state" or "Battery level below threshold" feedbacks. They then untick "Poll device status" in the connection settings, for example to cut network traffic. Those actions and feedbacks stop existing for the connection, so the buttons show them as unknown and pressing them does nothing. Ticking polling again brings them back. HELP.md says "None of these are shown when polling is off", but a user who already placed the buttons gets no warning on the buttons themselves.

**Why it happens:** When polling is off, the module deletes the three actions from its action list and offers no feedbacks at all. Buttons that already use them then point at actions and feedbacks the connection no longer offers.

**Fix:** always define these actions and feedbacks, and keep saying in their descriptions and in HELP.md that they need polling. The actions already log a warning and stop when the state is unknown ("Screen state unknown; waiting for the first poll", "enable polling"), and the feedbacks already return false when there is no polled data. Hiding only the presets when polling is off is fine.

### L5: Device state feedback shows two invert checkboxes

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.ts:40-44`](https://github.com/bitfocus/companion-module-fullyfactory-fullykiosk/blob/168c36be8ce41780dba77c5d785a5d609c29d6ba/src/feedbacks.ts#L40-L44)

**What goes wrong:** When a user adds the "Device state" feedback to a button, Companion shows its own built-in "Inverted" checkbox and also the module's "Invert (true while NOT set)" checkbox. Ticking both cancels out, so a feedback set to "Screen is on" with both boxes ticked lights up while the screen is on, which is confusing.

**Why it happens:** Companion adds its own "Inverted" checkbox to every boolean feedback unless the feedback sets `showInvert: false` (base 2.1.3: "If `undefined` or true, Companion will add an 'Inverted' checkbox for your feedback, and handle the logic for you"). The module adds its own invert option on top and applies it in the callback; the screen-toggle preset uses that option ([`src/presets.ts:47-48`](https://github.com/bitfocus/companion-module-fullyfactory-fullykiosk/blob/168c36be8ce41780dba77c5d785a5d609c29d6ba/src/presets.ts#L47-L48)).

**Fix:** keep only one invert. Either remove the module's `invert` option (callback `return typeof v === 'boolean' && v`, and `isInverted: true` in the preset instead of `options: { invert: true }`), or keep it and set `showInvert: false` on the feedback. The second option keeps today's behaviour that the feedback is off while the state is still unknown. This is a first release, so no upgrade script is needed either way.

### L6: Stream option needs bare Android stream numbers in expression mode

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:61-72`](https://github.com/bitfocus/companion-module-fullyfactory-fullykiosk/blob/168c36be8ce41780dba77c5d785a5d609c29d6ba/src/actions.ts#L61-L72)

**What goes wrong:** A user switches the "Stream" option of "Audio: set volume", "Audio: change volume by step" or "Audio: play sound" to expression mode. They then have to type a bare Android stream number (`3` = Music / media, `9` = Text-to-speech, `4` = Alarm), and neither the option nor HELP.md lists these numbers. In normal (value) mode the dropdown works as expected.

**Why it happens:** The dropdown uses the raw Android stream numbers as its choice ids (`{ id: 3, label: 'Music / media' }`, …). In expression mode the user types the id, not the label. The v2 compliance rules recommend readable ids for this reason.

**Fix:** use readable ids (`'music'`, `'alarm'`, `'tts'`, …) and map them to the stream number in the callbacks and in `streamVolume`. Doing it before the first release means no upgrade script is needed. Or, at least, add an `expressionDescription` to the Stream option that lists the numbers.

### L7: Type casts turn off schema checking for presets, actions, feedbacks and variables

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/presets.ts:12-20`](https://github.com/bitfocus/companion-module-fullyfactory-fullykiosk/blob/168c36be8ce41780dba77c5d785a5d609c29d6ba/src/presets.ts#L12-L20), [`src/presets.ts:47-48`](https://github.com/bitfocus/companion-module-fullyfactory-fullykiosk/blob/168c36be8ce41780dba77c5d785a5d609c29d6ba/src/presets.ts#L47-L48), [`src/presets.ts:60`](https://github.com/bitfocus/companion-module-fullyfactory-fullykiosk/blob/168c36be8ce41780dba77c5d785a5d609c29d6ba/src/presets.ts#L60), [`src/actions.ts:85`](https://github.com/bitfocus/companion-module-fullyfactory-fullykiosk/blob/168c36be8ce41780dba77c5d785a5d609c29d6ba/src/actions.ts#L85), [`src/actions.ts:268`](https://github.com/bitfocus/companion-module-fullyfactory-fullykiosk/blob/168c36be8ce41780dba77c5d785a5d609c29d6ba/src/actions.ts#L268), [`src/feedbacks.ts:23`](https://github.com/bitfocus/companion-module-fullyfactory-fullykiosk/blob/168c36be8ce41780dba77c5d785a5d609c29d6ba/src/feedbacks.ts#L23), [`src/variables.ts:30`](https://github.com/bitfocus/companion-module-fullyfactory-fullykiosk/blob/168c36be8ce41780dba77c5d785a5d609c29d6ba/src/variables.ts#L30)

**What goes wrong:** Nothing visible today: the reviewers checked every preset's action and feedback ids and options against the definitions by hand, and they all match. The risk is in future edits. A renamed action, feedback or option (e.g. `volume_step` → `volumeStep`, or `{ step: 10, stream: 3 }` → `{ amount: 10, stream: 3 }`) would still compile, and the preset button would ship broken.

**Why it happens:** Several casts switch off the module's typed schema:

- The preset helper takes a plain `actionId: string` and casts each step action and feedback `as never`.
- The actions are collected in a `Record<string, unknown>` and cast to the typed definitions at the end.
- The empty feedback and variable definitions are passed as `{} as never`.

**Fix:** write the preset actions and feedbacks with their real types (`CompanionPresetAction<ModuleSchema['actions']>`, `CompanionPresetFeedback<ModuleSchema['feedbacks']>`, or inline objects inside `CompanionPresetDefinitions<ModuleSchema>`), and build the action definitions as one typed object with the simple commands spread into it. If the polling gating is kept, make the gated feedback and variable keys optional in the schema instead of casting `{}`.

## 💡 Nice to Have

### N1: Host typed as a URL or with a trailing space shows Connection Failure instead of Bad Config

- **Source:** 🔎 protocol reviewer + QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/config.ts:25-30`](https://github.com/bitfocus/companion-module-fullyfactory-fullykiosk/blob/168c36be8ce41780dba77c5d785a5d609c29d6ba/src/config.ts#L25-L30), [`src/api.ts:48`](https://github.com/bitfocus/companion-module-fullyfactory-fullykiosk/blob/168c36be8ce41780dba77c5d785a5d609c29d6ba/src/api.ts#L48)

**What goes wrong:** A user pastes `http://192.168.1.10` into "Tablet IP / hostname", which is easy to do when copying from Fully's Remote Admin page. The connection shows "Connection Failure: fetch failed" and the field gives no warning. A trailing space ("192.168.1.10 ") gives "Connection Failure: Invalid URL". In both cases the problem is the setting, but the status says the connection failed.

**Why it happens:** The host field only checks that it isn't empty (`Regex.SOMETHING`), and the module puts the raw value into `http://${host}:${port}/`. For `http://192.168.1.10` that becomes `http://http://192.168.1.10:2323/`, whose host is read as "http"; a value with a space makes the URL invalid.

**Fix:** validate the field with `regex: Regex.HOSTNAME` (it accepts IP addresses too), and/or trim the value and strip a leading `http://` or `https://` before building the URL. In `start()`, build the URL once and set `InstanceStatus.BadConfig` if that throws.

### N2: Wrong Remote Admin password shows as Connection Failure instead of Authentication Failure

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/api.ts:67-71`](https://github.com/bitfocus/companion-module-fullyfactory-fullykiosk/blob/168c36be8ce41780dba77c5d785a5d609c29d6ba/src/api.ts#L67-L71)

**What goes wrong:** A user types the wrong Remote Admin password. The connection shows the generic "Connection failure" status (with the message "Wrong Remote Admin password (HTTP 403)") instead of Companion's own authentication-failure status, so in the connections list it looks like a network problem.

**Why it happens:** An HTTP 403 reply is thrown as a plain error, and `fail()` always reports `InstanceStatus.ConnectionFailure`. Base 2.1.3 has `InstanceStatus.AuthenticationFailure` for this case.

**Fix:** mark the 403 error (a small error class, or a status field on the error) and call `this.updateStatus(InstanceStatus.AuthenticationFailure, msg)` for it in `fail()`.

### N3: Battery, volume and screen variables are published as text, not numbers or booleans

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:143-168`](https://github.com/bitfocus/companion-module-fullyfactory-fullykiosk/blob/168c36be8ce41780dba77c5d785a5d609c29d6ba/src/main.ts#L143-L168), [`src/variables.ts:3-25`](https://github.com/bitfocus/companion-module-fullyfactory-fullykiosk/blob/168c36be8ce41780dba77c5d785a5d609c29d6ba/src/variables.ts#L3-L25)

**What goes wrong:** Users who write expressions or triggers on the variables get text. `$(fullyfactory-fullykiosk:battery)` is the string "73", and `$(fullyfactory-fullykiosk:screen_on)` is "Yes" or "No". Using `screen_on` as a trigger condition, or doing arithmetic like `$(fullyfactory-fullykiosk:brightness) + 25`, needs string comparison or a conversion first. Showing the values on buttons works fine.

**Why it happens:** Every variable is typed as `string`, and the values are converted with `String(v)` or turned into "Yes"/"No". API 2 variables can hold numbers and booleans directly.

**Fix:** type `battery`, `brightness`, `wifi_signal`, `current_tab` and the `volume_*` variables as `number | undefined`, and `plugged`, `screen_on`, `screensaver` and `kiosk_locked` as `boolean | undefined`, and publish the raw values. Doing it in the first release avoids changing variable types for existing users later.

### N4: Custom command breaks parameter values that contain an ampersand or a plus sign

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:248-256`](https://github.com/bitfocus/companion-module-fullyfactory-fullykiosk/blob/168c36be8ce41780dba77c5d785a5d609c29d6ba/src/actions.ts#L248-L256)

**What goes wrong:** A user sets up "Custom command" with Command `loadUrl` and Parameters `url=https://example.com/show?scene=1&cam=2`. Fully receives `url=https://example.com/show?scene=1` plus a separate `cam=2` parameter, so the wrong page opens. In the same way, `text=C++` arrives as "C" followed by two spaces. The action doesn't say that values must be URL-encoded.

**Why it happens:** The Parameters text is parsed as a URL query string, which splits on every `&` and turns `+` into a space, before the values are encoded again for the request.

**Fix:** say in the option label or description that values must be URL-encoded (`%26` for &, `%2B` for +). Or use a format that can't be ambiguous, such as one `key=value` per line, split only at the first `=`.

### N5: A missing poll interval would make polling run back-to-back

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:61`](https://github.com/bitfocus/companion-module-fullyfactory-fullykiosk/blob/168c36be8ce41780dba77c5d785a5d609c29d6ba/src/main.ts#L61)

**What goes wrong:** No visible effect with normal settings: new connections get the default of 5 seconds. But if the poll interval were ever missing from a connection's config (for example an incomplete imported config), the module would poll the tablet continuously, one request straight after another.

**Why it happens:** `Math.max(1, undefined)` is `NaN`, so the interval delay becomes `NaN` milliseconds, and Node treats a `NaN` timer delay as 1 ms.

**Fix:** fall back to the default when the value isn't a number.

```ts
const s = Number(this.config.pollInterval)
const interval = Math.max(1, Number.isFinite(s) ? s : 5) * 1000
```

## 📝 Additional Notes

- `companion/manifest.json` commits `"version": "0.1.0"` while `package.json` is `1.0.0`. The build writes `1.0.0` into the packaged manifest, so nothing breaks, but the template keeps `"0.0.0"` in source control, which avoids the two disagreeing.

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Companion aborts an action callback's `context.signal` when the user aborts a button's running actions | The JSDoc on `CompanionActionCallbackContext.signal` in base 2.1.3 (`dist/module-api/action.d.ts`); the host's exact triggers were not checked | [M1](#m1-aborting-a-buttons-running-actions-doesnt-cancel-a-pending-fully-kiosk-request) |
| A2 | On a normal Wi-Fi network, a volume command plus the follow-up status poll takes a few hundred milliseconds, so a user can press a step button again before the poll returns | General LAN/Wi-Fi latency for HTTP calls to an Android app; not measurable from the code | [L2](#l2-pressing-the-volume-step-buttons-several-times-quickly-loses-steps) |
| A3 | When a connection stops defining an action or feedback at runtime (polling turned off), Companion keeps the entry on existing buttons but shows it as unknown and doesn't run or evaluate it until the definition comes back | General Companion host behaviour for missing definitions; not checked in the module or the base package, which only send the definitions | [L4](#l4-buttons-with-the-toggle-step-actions-or-feedbacks-stop-working-when-polling-is-turned-off) |
| A4 | Companion fills config fields with their defaults when a connection is created, so the poll interval is normally 5 and the missing-value case only happens with incomplete or imported configs | Companion host behaviour for config defaults; the module only declares `default: 5` | [N5](#n5-a-missing-poll-interval-would-make-polling-run-back-to-back) |
