# Review: companion-module-outline-et v1.0.1 (follow-up)

| Field | Value |
| --- | --- |
| **Module** | `companion-module-outline-et` |
| **Scope** | `tag` |
| **Version** | `v1.0.1` |
| **Release** | New module — never published |
| **API** | 2.0 (base 2.0.4, yarn.lock) — requires Companion 4.3+ |
| **Template** | `companion-module-template-ts-v2.0.4` @ `d62230e` (2026-08-28, pinned) |
| **Commit** | [`770eac0`](https://github.com/bitfocus/companion-module-outline-et/tree/770eac051230fed38a9c0052b2870c8f089316a7) |
| **Previous review** | [v1.0.0, 2026-10-30](review-outline-et-v1.0.0-20261030-090507.md) |
| **Review date** | 2026-11-06 |

This is a follow-up to the v1.0.0 review. The module has never been published, so there is no published release to diff against: the whole module was reviewed again, and every finding is classified 🆕 NEW. `yarn install --immutable`, `yarn package` and `yarn lint` all succeeded, and the template check found nothing.

All four findings of the v1.0.0 review are fixed:

| Prior finding | Status |
| --- | --- |
| C1: Prettier ignore file differs from the template | ✅ Fixed. [`.prettierignore`](https://github.com/bitfocus/companion-module-outline-et/blob/770eac051230fed38a9c0052b2870c8f089316a7/.prettierignore) now matches the template |
| H1: CI workflow differs from the template | ✅ Fixed. [`.github/workflows/node.yaml`](https://github.com/bitfocus/companion-module-outline-et/blob/770eac051230fed38a9c0052b2870c8f089316a7/.github/workflows/node.yaml) is the template's copy, with the template's optional `test` job uncommented, which is fine |
| L1: A cancelled command's reply timer can outlive the connection | ✅ Fixed. A STOP-cancelled command is now tracked, and closing the channel clears its reply timer and returns its send turn ([`src/protocol/command-channel.ts:95`](https://github.com/bitfocus/companion-module-outline-et/blob/770eac051230fed38a9c0052b2870c8f089316a7/src/protocol/command-channel.ts#L95), [`src/protocol/command-channel.ts:105-114`](https://github.com/bitfocus/companion-module-outline-et/blob/770eac051230fed38a9c0052b2870c8f089316a7/src/protocol/command-channel.ts#L105-L114)), with a new test |
| N1: Port-in-use warning blames a duplicate connection that may not exist | ✅ Fixed. The warning is worded neutrally ([`src/et-session.ts:197`](https://github.com/bitfocus/companion-module-outline-et/blob/770eac051230fed38a9c0052b2870c8f089316a7/src/et-session.ts#L197)), and HELP.md names all three causes |

The fixes introduced no new issues. The one finding below is in code that has not changed since v1.0.0; the v1.0.0 review did not raise it.

## Verdict: ✅ Approved

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Companion 4.3+ catches and logs a rejected action callback promise, so it does not become an unhandled rejection. The module relies on this on purpose: STOP, Step, Nudge, Go to angle and Set zero here reject with a readable reason when they are refused | base 2.0.4 only passes the action definitions to the host (`dist/module-api/base.js:44-46`, the callback type in `dist/module-api/action.d.ts:48`). The actions run in the Companion host, which was not checked | No finding. It is why none was raised on the actions that reject ([`src/actions.ts:51-138`](https://github.com/bitfocus/companion-module-outline-et/blob/770eac051230fed38a9c0052b2870c8f089316a7/src/actions.ts#L51-L138)) |

## 📋 Issues

### Non-blocking

- [ ] [L1: A single missed position reply after STOP logs a misleading "3 consecutive polls" warning](#l1-a-single-missed-position-reply-after-stop-logs-a-misleading-3-consecutive-polls-warning)

## 🟢 Low

### L1: A single missed position reply after STOP logs a misleading "3 consecutive polls" warning

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/et-session.ts:535-543`](https://github.com/bitfocus/companion-module-outline-et/blob/770eac051230fed38a9c0052b2870c8f089316a7/src/et-session.ts#L535-L543), [`src/et-session.ts:648-661`](https://github.com/bitfocus/companion-module-outline-et/blob/770eac051230fed38a9c0052b2870c8f089316a7/src/et-session.ts#L648-L661)

**What goes wrong:** An operator presses the STOP button. If the turntable misses a single position reply in the next second, the Companion log shows `warn: No position reply from 192.168.1.120:6668 (3 consecutive polls)` about 1.3 s later. About 1 s after that it shows `info: Position replies from 192.168.1.120:6668 restored`. Only one request went unanswered. HELP.md (the Compatibility table, ET250-3D legacy row) says such a miss "may happen now and then: the module retries automatically, without a warning". Instead the operator sees a warning with a wrong count and may think the network link is failing. The QA reviewer reproduced this against the module's own fake turntable with the production settings, dropping exactly one reply: the warning appeared at 1.30 s, "restored" and "STOP confirmed" followed at 2.31 s, and only 3 position requests were sent.

Movements, the connection status, feedbacks and the automatic fail-safe STOP are not affected. Only the log is wrong. At the idle and moving poll rates a single miss stays below the warning threshold, so only the seconds after a STOP show the problem.

**Why it happens:** While a STOP is being confirmed, the module asks for the position every 250 ms (`stopConfirmIntervalMs`). It never sends a new position request while the previous one is less than 2 s old (`positionRequestGuardMs`). It waits for a late reply instead. That waiting step is counted as a failed poll: it goes through the same handler as a real reply timeout, which raises the failure count and checks the warning threshold. So one real timeout plus two skipped polls 250 ms apart reach the first-warning threshold of 3 within about 1 s. `src/settings.ts` also describes the fail-safe count as "consecutive position requests failed", and a skipped poll is not a failed request.

**Evidence:**

```ts
// src/et-session.ts:535-543 (poll)
if (
	this.positionRequestSentAt !== null &&
	now - this.positionRequestSentAt < this.settings.positionRequestGuardMs
) {
	// The previous request is still unanswered: wait for its late reply
	// instead of adding traffic. At most one request is in flight.
	this.onPollFailed()
	return
}
// src/et-session.ts:651-659 (onPollFailed)
this.settleReadingWaiters(null)
this.failedPolls++
this.lossStartedAt ??= performance.now()
if (this.failedPolls === POLL_FIRST_WARNING || this.failedPolls % POLL_WARNING_EVERY === 0) {
	this.host.log(
		'warn',
		`No position reply from ${telemetryEndpoint(run.target)} (${this.failedPolls} consecutive polls)`,
	)
}
// src/et-session.ts:79
const POLL_FIRST_WARNING = 3
```

**Fix:** when a poll is skipped because the previous request is still unanswered, retry without counting a failure, but keep the fail-safe check. The failure count, and with it the "N consecutive polls" warning and the later "restored" message, then counts only requests that really timed out, could not be sent, or got an invalid reply. In the QA reviewer's run with production timings, the automatic STOP still fires after about 9 s of telemetry loss while moving, the same as today.

```ts
// src/et-session.ts, poll(): the guard branch
if (
	this.positionRequestSentAt !== null &&
	now - this.positionRequestSentAt < this.settings.positionRequestGuardMs
) {
	// The previous request is still unanswered: wait for its late reply
	// instead of adding traffic. At most one request is in flight.
	this.settleReadingWaiters(null)
	this.checkFailSafe()
	this.schedulePoll(this.nextPollDelay(false))
	return
}
```
