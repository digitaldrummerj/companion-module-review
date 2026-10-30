# Review: touchpoint-meetings v1.0.0 (follow-up to v0.2.1)

| | |
| --- | --- |
| **Module** | `companion-module-touchpoint-meetings` ([repo](https://github.com/bitfocus/companion-module-touchpoint-meetings)) |
| **Scope** | `tag` (`v0.2.1..v1.0.0`) |
| **Version** | v1.0.0 (`bb09759`, 2026-10-19) |
| **Release** | Update — last published v0.2.1 |
| **API** | 2.0 (base 2.0.4, yarn.lock) — requires Companion 4.3+ |
| **Template** | `companion-module-template-ts-v2.0.4` @ `d62230e` (2026-08-28, pinned) |
| **Previous review** | [v0.2.1](review-touchpoint-meetings-v0.2.1-20261005-024911.md) |
| **Language** | TypeScript |
| **Build** | `yarn install --immutable`, `yarn package` and `yarn lint` pass |
| **Review date** | 2026-10-30 |

This is a follow-up to the [v0.2.1 review](review-touchpoint-meetings-v0.2.1-20261005-024911.md). Every finding from that review is fixed in v1.0.0:

| Prior finding | Status in v1.0.0 |
| --- | --- |
| H1: LICENSE copyright line differs from the template | ✅ Fixed. [`LICENSE`](https://github.com/bitfocus/companion-module-touchpoint-meetings/blob/bb0975968524677800ded2a227d68351344660bd/LICENSE#L3) matches the template again |
| M1: Feedbacks can flip off and on when two refreshes overlap | ✅ Fixed. Refreshes now run one at a time, with one follow-up ([`src/main.ts:272-296`](https://github.com/bitfocus/companion-module-touchpoint-meetings/blob/bb0975968524677800ded2a227d68351344660bd/src/main.ts#L272-L296)) |
| M2: A stalled response can freeze polling for about five minutes | ✅ Fixed. The timeout now covers reading the body ([`src/touchpointApi.ts:120-137`](https://github.com/bitfocus/companion-module-touchpoint-meetings/blob/bb0975968524677800ded2a227d68351344660bd/src/touchpointApi.ts#L120-L137)) |
| L1: Requests in flight stay open after the connection stops | ✅ Fixed. `stop()` aborts a shared `AbortController` ([`src/main.ts:184-198`](https://github.com/bitfocus/companion-module-touchpoint-meetings/blob/bb0975968524677800ded2a227d68351344660bd/src/main.ts#L184-L198)) |
| L2: Reservations across a daylight-saving change are an hour off | ✅ Fixed. The script converts each reservation to UTC by its own date ([`touchpoint/CompanionMeetings.py`](https://github.com/bitfocus/companion-module-touchpoint-meetings/blob/bb0975968524677800ded2a227d68351344660bd/touchpoint/CompanionMeetings.py)) |
| L3: Out-of-range Minutes before / after expression skips the feedback | ✅ Fixed. Both options set `clampValues: true` ([`src/feedbacks.ts:94-113`](https://github.com/bitfocus/companion-module-touchpoint-meetings/blob/bb0975968524677800ded2a227d68351344660bd/src/feedbacks.ts#L94-L113)) |
| L4: The monitored rooms variable leaves out child rooms | ✅ Fixed. The count now uses `expandRoomIds` ([`src/main.ts:441-446`](https://github.com/bitfocus/companion-module-touchpoint-meetings/blob/bb0975968524677800ded2a227d68351344660bd/src/main.ts#L441-L446)) |

The findings below are new in this review.

## Verdict: ❌ Changes Required

## 📋 Issues

### Blocking

- [ ] [C1: The Prettier ignore list differs from the template](#c1-the-prettier-ignore-list-differs-from-the-template)

### Non-blocking

- [ ] [L1: Pressing Refresh with incomplete settings hides the settings error and can start retrying every 30 seconds](#l1-pressing-refresh-with-incomplete-settings-hides-the-settings-error-and-can-start-retrying-every-30-seconds)

---

## 🔴 Critical

### C1: The Prettier ignore list differs from the template

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW (not raised in the v0.2.1 review; the file itself has not changed since v0.2.1)
- **File:** [`.prettierignore:3`](https://github.com/bitfocus/companion-module-touchpoint-meetings/blob/bb0975968524677800ded2a227d68351344660bd/.prettierignore#L3)
- **Template:** [API 2.0 TypeScript template](https://github.com/bitfocus/companion-module-template-ts/tree/d62230e88bf8aec4ea6db407106bff2a96c0fdb9) (`companion-module-template-ts-v2.0.4` @ `d62230e`): `.prettierignore`

**What goes wrong:** No effect for users. Bitfocus modules keep the template's tool configuration files unchanged, and this module's `.prettierignore` has an extra line that tells Prettier to skip `src/scriptSource.ts`.

**Why it happens:** `src/scriptSource.ts` is a generated file, written by `scripts/embed-script.mjs` from the TouchPoint script, and the module excludes it from formatting by adding it to the template's ignore list.

**Evidence:**

```text
template .prettierignore   package.json
                           /LICENSE.md
module   .prettierignore   package.json
                           /LICENSE.md
                           src/scriptSource.ts      <- line 3, not in the template
```

**Confirm by:** open [`.prettierignore:3`](https://github.com/bitfocus/companion-module-touchpoint-meetings/blob/bb0975968524677800ded2a227d68351344660bd/.prettierignore#L3) and compare it with the template's `.prettierignore`.

**Fix:** restore the template's `.prettierignore` exactly (remove line 3). If the generated file must not be reformatted, have `embed-script.mjs` write it in Prettier's format instead.

---

## 🟢 Low

### L1: Pressing Refresh with incomplete settings hides the settings error and can start retrying every 30 seconds

- **Source:** 🔎 protocol reviewer, QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:110-113`](https://github.com/bitfocus/companion-module-touchpoint-meetings/blob/bb0975968524677800ded2a227d68351344660bd/src/main.ts#L110-L113), [`src/main.ts:165-173`](https://github.com/bitfocus/companion-module-touchpoint-meetings/blob/bb0975968524677800ded2a227d68351344660bd/src/main.ts#L165-L173), [`src/main.ts:245-250`](https://github.com/bitfocus/companion-module-touchpoint-meetings/blob/bb0975968524677800ded2a227d68351344660bd/src/main.ts#L245-L250)

**What goes wrong:** A user sets **Refresh Interval (seconds)** to 0 and leaves **API Password** empty. The connection correctly shows a bad-configuration status, "API password is required". If they then press a button with the **Refresh from TouchPoint** action, the module still sends a request to TouchPoint with the incomplete settings. That request fails, and the status changes to a connection or authentication failure such as "TouchPoint returned HTTP 401", which hides the real cause. Because automatic refreshing is off, the retry added in this release then repeats the failing request every 30 seconds, with an error in the log each time, until the settings are fixed or the connection is disabled. The timer is cleared correctly on `destroy()` and on a settings change, so nothing leaks.

**Why it happens:** When the settings are incomplete, `restart()` stops early with the bad-configuration status and does not start the connection, but the generation counter still matches. `refreshNow()`, which the Refresh action calls, does not check whether the connection started, so the request goes ahead. When it fails, the new `retryIfAutomaticRefreshIsOff()` sees a failed refresh and no poll timer, and schedules another attempt in 30 seconds. `scheduleWindowsRefresh()` already guards this case with `!this.tickTimer` ("not started"); `refreshNow()` and the retry do not.

**Fix:** return early from `refreshNow()` when the connection has not started, and skip the retry in that case too.

```ts
async refreshNow(): Promise<void> {
	if (!this.tickTimer) return // not started: the settings are incomplete
	this.roomsLoadedMs = 0
	await this.refresh(this.generation)
}

private retryIfAutomaticRefreshIsOff(generation: number): void {
	if (generation !== this.generation || this.pollDelayMs() !== undefined || !this.tickTimer) return
	// ...
}
```
