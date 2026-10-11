# Review: touchpoint-meetings v0.2.1

| | |
| --- | --- |
| **Module** | `companion-module-touchpoint-meetings` ([repo](https://github.com/bitfocus/companion-module-touchpoint-meetings)) |
| **Version** | v0.2.1 (`2d98a01`, 2026-10-04) |
| **Previous tag** | none (first release) |
| **Scope:** | tag (first release, so the whole module was reviewed) |
| **Language** | TypeScript |
| **Template** | [API 2.0 TypeScript template](https://github.com/bitfocus/companion-module-template-ts/tree/d62230e88bf8aec4ea6db407106bff2a96c0fdb9) (`companion-module-template-ts` @ `d62230e`, 2026-08-28, the last API 2.0 commit) |
| **API** | 2.0 (base 2.0.4, yarn.lock) — requires Companion 4.3+ |
| **Build** | `yarn install --immutable`, `yarn package` and `yarn lint` pass |
| **Review date** | 2026-10-08 |

This is the module's first release, so there is no earlier tag to compare with. Every finding below is 🆕 NEW.

**About the template:** the official TypeScript template repository has moved to the module API 2.1. This module uses API 2.0, so every template finding below links to the API 2.0 version of the template, at commit [`d62230e`](https://github.com/bitfocus/companion-module-template-ts/tree/d62230e88bf8aec4ea6db407106bff2a96c0fdb9). Earlier versions of the template are no longer maintained, but that commit preserves the API 2.0 files.

## Verdict: ❌ Changes Required

## 📋 Issues

### Blocking

- [ ] [H1: The LICENSE copyright line differs from the template](#h1-the-license-copyright-line-differs-from-the-template)

### Non-blocking

- [ ] [M1: Feedbacks can briefly flip off and on when two refreshes overlap](#m1-feedbacks-can-briefly-flip-off-and-on-when-two-refreshes-overlap)
- [ ] [M2: A stalled TouchPoint response can freeze polling for about five minutes](#m2-a-stalled-touchpoint-response-can-freeze-polling-for-about-five-minutes)
- [ ] [L1: Requests already in flight stay open after the connection is removed or changed](#l1-requests-already-in-flight-stay-open-after-the-connection-is-removed-or-changed)
- [ ] [L2: Reservations across a daylight-saving change are an hour off](#l2-reservations-across-a-daylight-saving-change-are-an-hour-off)
- [ ] [L3: An out-of-range Minutes before or Minutes after expression skips the feedback](#l3-an-out-of-range-minutes-before-or-minutes-after-expression-skips-the-feedback)
- [ ] [L4: The monitored rooms variable leaves out child rooms](#l4-the-monitored-rooms-variable-leaves-out-child-rooms)

---

## 🟠 High

### H1: The LICENSE copyright line differs from the template

- **Source:** 🤖 validate-template (LICENSE-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`LICENSE:3`](https://github.com/bitfocus/companion-module-touchpoint-meetings/blob/2d98a01b795ecde4366e222af1a35f1306f2330e/LICENSE#L3)
- **Template:** [API 2.0 TypeScript template](https://github.com/bitfocus/companion-module-template-ts/tree/d62230e88bf8aec4ea6db407106bff2a96c0fdb9): [`LICENSE`](https://github.com/bitfocus/companion-module-template-ts/blob/d62230e88bf8aec4ea6db407106bff2a96c0fdb9/LICENSE)

**What goes wrong:** No effect for users. Bitfocus modules ship the template's `LICENSE` unchanged, and this module has changed its copyright line.

**Why it happens:** Commit `14f16f3` ("Correcting maintainers, updating copyright.") replaced the template's copyright holder with the maintainer's company.

**Evidence:**

```text
template LICENSE:3   Copyright (c) 2022 Bitfocus AS - Open Source
module   LICENSE:3   Copyright (c) 2026 Doxology Technologies
```

**Confirm by:** open [`LICENSE:3`](https://github.com/bitfocus/companion-module-touchpoint-meetings/blob/2d98a01b795ecde4366e222af1a35f1306f2330e/LICENSE#L3).

**Fix:** restore the template's `LICENSE` exactly, byte for byte.

---

## 🟡 Medium

### M1: Feedbacks can briefly flip off and on when two refreshes overlap

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:103-106`](https://github.com/bitfocus/companion-module-touchpoint-meetings/blob/2d98a01b795ecde4366e222af1a35f1306f2330e/src/main.ts#L103-L106), [`src/main.ts:212-219`](https://github.com/bitfocus/companion-module-touchpoint-meetings/blob/2d98a01b795ecde4366e222af1a35f1306f2330e/src/main.ts#L212-L219), [`src/main.ts:221-246`](https://github.com/bitfocus/companion-module-touchpoint-meetings/blob/2d98a01b795ecde4366e222af1a35f1306f2330e/src/main.ts#L221-L246), [`src/main.ts:302`](https://github.com/bitfocus/companion-module-touchpoint-meetings/blob/2d98a01b795ecde4366e222af1a35f1306f2330e/src/main.ts#L302)

**What goes wrong:** Two things can go wrong when the module fetches reservations twice at the same time:

- **A feedback flips false, then true again.** A user adds a "Room is in setup, in use, or in teardown" feedback for room 2 while a regular poll for room 1 is still running. The quick refresh for room 2 finishes first and the feedback turns true. Then the older poll finishes and overwrites the reservation list without room 2, so the feedback turns false until the next poll (30 s by default) turns it true again. On a Trigger, that looks like "becomes false" then "becomes true", which can stop and restart whatever the trigger drives. At startup, a quick refresh can also run before the room list has loaded, so **Include rooms inside these rooms** has nothing to expand.
- **A successful script update shows as a settings error.** At startup, the first poll and a quick refresh can both find the TouchPoint script out of date and both upload the new one. The second upload is refused because the script is no longer newer than the installed one, and the connection shows a `BadConfig` (bad configuration) status until the next poll, even though the update worked.

**Why it happens:** Three things start a refresh: the regular poll, a 500 ms delayed refresh after a feedback is added or removed, and the **Refresh from TouchPoint** action. Nothing stops them from running at once. The module's `generation` counter only discards results after a config change, not between two refreshes started under the same config, so whichever finishes last wins. The script refusing a same-version update is at `touchpoint/CompanionMeetings.py:213`.

**Fix:** run one refresh at a time. Keep the promise of the refresh in progress; if another is requested meanwhile, set a "pending" flag and run one follow-up when the current one finishes. At minimum, allow only one script upload in flight. Another option is to number each request and drop any result older than the last one applied.

### M2: A stalled TouchPoint response can freeze polling for about five minutes

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/touchpointApi.ts:116-159`](https://github.com/bitfocus/companion-module-touchpoint-meetings/blob/2d98a01b795ecde4366e222af1a35f1306f2330e/src/touchpointApi.ts#L116-L159), [`src/main.ts:204-210`](https://github.com/bitfocus/companion-module-touchpoint-meetings/blob/2d98a01b795ecde4366e222af1a35f1306f2330e/src/main.ts#L204-L210)

**What goes wrong:** If TouchPoint starts answering a request but then stalls before sending the rest, the **Request Timeout (ms)** setting (1–60 s) does not apply. The module waits roughly 300 s for Node's own built-in limit instead. Polling stops for that whole time, and the connection status stays at its last value, possibly OK, so feedbacks run on old reservation data without any warning.

**Why it happens:** The timeout timer is cleared as soon as the response headers arrive, before the response body is read. Reading the body (`response.json()`) then has no time limit from the module. The next poll is only scheduled after the current refresh returns, so one stuck body read holds up all polling.

**Fix:** keep the timeout running until the body has been read. Either wrap both `fetch()` and `response.json()` in one `try`/`finally` that clears the timer, or pass `signal: AbortSignal.timeout(this.requestTimeoutMs)` so one signal covers the whole request.

---

## 🟢 Low

### L1: Requests already in flight stay open after the connection is removed or changed

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:71-74`](https://github.com/bitfocus/companion-module-touchpoint-meetings/blob/2d98a01b795ecde4366e222af1a35f1306f2330e/src/main.ts#L71-L74), [`src/main.ts:176-184`](https://github.com/bitfocus/companion-module-touchpoint-meetings/blob/2d98a01b795ecde4366e222af1a35f1306f2330e/src/main.ts#L176-L184), [`src/touchpointApi.ts:116-118`](https://github.com/bitfocus/companion-module-touchpoint-meetings/blob/2d98a01b795ecde4366e222af1a35f1306f2330e/src/touchpointApi.ts#L116-L118)

**What goes wrong:** When the connection is deleted, disabled or its settings are changed, any request to TouchPoint that is already running keeps its HTTPS connection open until it times out. Together with M2, a stalled body read can stay open for minutes after the connection is gone.

**Why it happens:** `stop()` (called from `destroy()` and on config changes) clears the timers and bumps the `generation` counter, so late results are correctly ignored. But it does not cancel the requests themselves; each request only has its own timeout signal.

**Fix:** keep one `AbortController` per generation and call `abort()` on it in `stop()`. Pass its signal into `TouchPointClient.call()` and combine it with the timeout signal using `AbortSignal.any([instanceSignal, timeoutSignal])`.

### L2: Reservations across a daylight-saving change are an hour off

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/touchpointApi.ts:82-94`](https://github.com/bitfocus/companion-module-touchpoint-meetings/blob/2d98a01b795ecde4366e222af1a35f1306f2330e/src/touchpointApi.ts#L82-L94)

**What goes wrong:** Reservations on the far side of a daylight-saving change, or running across one, start and end an hour early or late in Companion until a poll after the change.

**Why it happens:** The TouchPoint script reports a single offset from UTC for the current moment ([`touchpoint/CompanionMeetings.py:162`](https://github.com/bitfocus/companion-module-touchpoint-meetings/blob/2d98a01b795ecde4366e222af1a35f1306f2330e/touchpoint/CompanionMeetings.py#L162)), and the module applies it to every reservation it fetched. That window reaches 60 minutes back and 24 hours or more ahead, so it can span a clock change.

**Fix:** have the script convert each reservation's start and end to UTC itself (`TimeZoneInfo.ConvertTimeToUtc`), or report the offset for each reservation.

### L3: An out-of-range Minutes before or Minutes after expression skips the feedback

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.ts:94-111`](https://github.com/bitfocus/companion-module-touchpoint-meetings/blob/2d98a01b795ecde4366e222af1a35f1306f2330e/src/feedbacks.ts#L94-L111)

**What goes wrong:** If a user drives **Minutes before** or **Minutes after** with an expression that returns a value beyond ±1440, the reviewer reports that Companion rejects the value as invalid and skips the feedback, instead of using the nearest allowed value.

**Why it happens:** Both number options set `min`/`max` to ±1440 but not `clampValues`. Without `clampValues`, Companion's API 2.0 treats an out-of-range expression result as invalid rather than pulling it into range. The module's own `toMinutes()` already clamps to ±1440, but never gets the chance to run.

**Fix:** add `clampValues: true` to both options.

### L4: The monitored rooms variable leaves out child rooms

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:357-360`](https://github.com/bitfocus/companion-module-touchpoint-meetings/blob/2d98a01b795ecde4366e222af1a35f1306f2330e/src/main.ts#L357-L360)

**What goes wrong:** With **Include rooms inside these rooms** ticked on a feedback, **Number of rooms being watched by feedbacks** (`monitored_rooms`) shows fewer rooms than are actually watched. For example, selecting one building with five rooms inside shows 1, not 6.

**Why it happens:** The variable counts only the rooms selected directly in feedbacks. The reservation fetch in `loadFrom` expands child rooms with `expandRoomIds`, but the variable does not.

**Fix:** build the set from `expandRoomIds(sub.watch, this.rooms)`, or rename the variable to "Number of rooms selected in feedbacks".
