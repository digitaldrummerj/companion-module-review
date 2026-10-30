# Review: breeze-overlay v1.1.1 (follow-up to the v1.1.0 review)

| | |
| --- | --- |
| **Module** | `companion-module-breeze-overlay` |
| **Scope** | `tag` |
| **Version** | v1.1.1 |
| **Release** | New module — never published |
| **API** | 2.1 (base 2.1.3, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Commit** | [`fa71cf1`](https://github.com/bitfocus/companion-module-breeze-overlay/blob/fa71cf18778b93f10f7a4b7c9a78a5ce97d73c0f) |
| **Previous tag** | none (first release, so there is no diff and the whole module was reviewed) |
| **Prior review** | [v1.1.0 (2026-10-05)](review-breeze-overlay-v1.1.0-20261005-024911.md) |
| **Review date** | 2026-10-30 |

> This is still the module's first release to Bitfocus: v1.1.0 was reviewed but never published. There is no published `previousTag..v1.1.1` diff to limit the review to, so the whole module was reviewed again and every finding is classed as 🆕 NEW.
>
> **Follow-up on the v1.1.0 review:** all 18 findings from that review are fixed in v1.1.1 (details in [📝 Additional Notes](#-additional-notes)). The findings below are new; none of them repeats a prior finding.
>
> Build and lint: `yarn install --immutable`, `yarn package` and `yarn lint` all pass. The template check reports no differences.

## Verdict: ✅ Approved

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | A typical web server that isn't Breeze answers unknown paths such as `/healthz` or `/api/control/...` with an error status (usually 404), not with a 200 and an HTML page. With a 200 HTML answer the module fails to parse the body, does not count the server as reachable, and the problem does not occur | Common web server behaviour; the module only counts a non-2xx HTTP answer as "reachable". Not tested against a real server | [M1](#m1-connection-turns-green-when-the-address-or-port-points-at-a-web-server-that-isnt-breeze) |

## 📋 Issues

### Non-blocking

- [ ] [M1: Connection turns green when the address or port points at a web server that isn't Breeze](#m1-connection-turns-green-when-the-address-or-port-points-at-a-web-server-that-isnt-breeze)
- [ ] [M2: A PLAY, STOP or CLEAR with a blank channel fires on whichever graphic a button happened to name first](#m2-a-play-stop-or-clear-with-a-blank-channel-fires-on-whichever-graphic-a-button-happened-to-name-first)
- [ ] [L1: Playback state is idle feedback lights up while the server is unreachable](#l1-playback-state-is-idle-feedback-lights-up-while-the-server-is-unreachable)
- [ ] [L2: Camera list is frozen feedback does not update when a failed camera becomes frozen](#l2-camera-list-is-frozen-feedback-does-not-update-when-a-failed-camera-becomes-frozen)
- [ ] [L3: Channel and ticker variables keep the old project's values after the config is saved](#l3-channel-and-ticker-variables-keep-the-old-projects-values-after-the-config-is-saved)
- [ ] [L4: Two camera lists whose ids differ only in punctuation share one CHECK CAMERAS preset](#l4-two-camera-lists-whose-ids-differ-only-in-punctuation-share-one-check-cameras-preset)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟡 Medium

### M1: Connection turns green when the address or port points at a web server that isn't Breeze

- **Source:** 🔎 protocol reviewer + QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:710-718`](https://github.com/bitfocus/companion-module-breeze-overlay/blob/fa71cf18778b93f10f7a4b7c9a78a5ce97d73c0f/src/main.ts#L710-L718), [`src/main.ts:742`](https://github.com/bitfocus/companion-module-breeze-overlay/blob/fa71cf18778b93f10f7a4b7c9a78a5ce97d73c0f/src/main.ts#L742), [`src/main.ts:755-764`](https://github.com/bitfocus/companion-module-breeze-overlay/blob/fa71cf18778b93f10f7a4b7c9a78a5ce97d73c0f/src/main.ts#L755-L764), [`src/api.ts:390-394`](https://github.com/bitfocus/companion-module-breeze-overlay/blob/fa71cf18778b93f10f7a4b7c9a78a5ce97d73c0f/src/api.ts#L390-L394)

**What goes wrong:** A user types the wrong port, for example 80 or 8080 on a machine that runs another web app or a router page, instead of Breeze's 7331. On save, the connection briefly reports the problem correctly ("answered, but not as Breeze — check the address and port"), or stays at Connecting. About a second later the first poll gets a 404 from the other web server, and the connection status turns green (Ok) and stays green. Every PLAY, STOP or NEXT press then fails with a "not found — check the project and channel keys" log line and the feedbacks never light, so the user hunts for a typo in the project or channel name when the real mistake is the port.

**Why it happens:** Both poll paths treat any HTTP answer that isn't a network error as proof the server is up. That includes a 404 from a foreign server and the module's own 502 "not Breeze" error from the health check. The "server is back" handler then sets the status to Ok, overwriting the "not Breeze" diagnosis. The version re-check it starts fails against the foreign server, but it swallows the error, so nothing corrects the status. A 404 from `/healthz` during connect is also logged as a wrong project or channel key rather than a wrong address or port.

**Evidence:**

```ts
// src/main.ts:710-718
let reachable: boolean
try {
	await this.api.health()
	reachable = true
} catch (error) {
	reachable = error instanceof BreezeError && error.status !== 0
}
if (!this.isCurrent(generation)) return
this.markReachable(reachable)
// src/main.ts:742
if (error instanceof BreezeError && error.status !== 0) reachable = true
// src/api.ts:390-394
async health(): Promise<{ ok: boolean; version: string }> {
	const body = await this.request<unknown>('/healthz')
	if (!isRecord(body) || typeof body.version !== 'string' || body.version === '') {
		throw new BreezeError(`${this.base} answered, but not as Breeze — check the address and port`, 502)
	}
```

**Confirm by:** open [`src/main.ts:715`](https://github.com/bitfocus/companion-module-breeze-overlay/blob/fa71cf18778b93f10f7a4b7c9a78a5ce97d73c0f/src/main.ts#L715) and [`src/main.ts:742`](https://github.com/bitfocus/companion-module-breeze-overlay/blob/fa71cf18778b93f10f7a4b7c9a78a5ce97d73c0f/src/main.ts#L742). Any non-zero status, including the 502 that [`src/api.ts:393`](https://github.com/bitfocus/companion-module-breeze-overlay/blob/fa71cf18778b93f10f7a4b7c9a78a5ce97d73c0f/src/api.ts#L393) throws for "not Breeze", counts as reachable, and [`markReachable`](https://github.com/bitfocus/companion-module-breeze-overlay/blob/fa71cf18778b93f10f7a4b7c9a78a5ce97d73c0f/src/main.ts#L755-L764) then shows Ok.

**Fix:** count the server as reachable only once it has answered as Breeze. In the no-channel branch, call `markReachable(true)` only when `health()` succeeds, and treat a 404 or 502 from `/healthz` as a configuration error ("answered, but not as Breeze — check the address and port"). In the per-channel branch, leave the reachable state unchanged while `serverVersion` is still empty. Alternatively, have `recheckVersion()` set an error status when `health()` fails with a 404 or 502, so the green status gets corrected. In `connect()`, report a 404 from `/healthz` as a wrong address or port.

```ts
// no-channel branch
} catch (error) {
	reachable = error instanceof BreezeError && error.status !== 0 && error.status !== 404 && error.status !== 502
}
// per-channel branch
if (error instanceof BreezeError && error.status !== 0 && this.serverVersion !== '') reachable = true
```

### M2: A PLAY, STOP or CLEAR with a blank channel fires on whichever graphic a button happened to name first

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:907-942`](https://github.com/bitfocus/companion-module-breeze-overlay/blob/fa71cf18778b93f10f7a4b7c9a78a5ce97d73c0f/src/main.ts#L907-L942), [`src/actions.ts:84-91`](https://github.com/bitfocus/companion-module-breeze-overlay/blob/fa71cf18778b93f10f7a4b7c9a78a5ce97d73c0f/src/actions.ts#L84-L91), [`src/actions.ts:128`](https://github.com/bitfocus/companion-module-breeze-overlay/blob/fa71cf18778b93f10f7a4b7c9a78a5ce97d73c0f/src/actions.ts#L128)

**What goes wrong:** Every action's channel option is labelled "Scene or element channel (blank = connection default)", but the connection settings have no default-channel field. A user adds a PLAY action by hand and leaves the channel blank, on a page that also has preset buttons for `lower-third` and `scoreboard`. One day the blank PLAY puts `lower-third` on air. After a Companion restart, a different subscribe order makes it put `scoreboard` on air instead, and deleting the `lower-third` buttons also moves it to `scoreboard`. When no channel has been named yet, the log says "no default set in the connection config", which sends the user looking for a setting that doesn't exist.

**Why it happens:** A blank channel falls back to an internal default channel. That default is set by the first action or feedback in the connection's project that names a channel explicitly, whichever Companion happens to evaluate first, and it moves to another watched channel when that button goes away. Actions use the same fallback as the variables, so this implicit choice decides which graphic an on-air command targets. The code comment at [`src/main.ts:927-935`](https://github.com/bitfocus/companion-module-breeze-overlay/blob/fa71cf18778b93f10f7a4b7c9a78a5ce97d73c0f/src/main.ts#L927-L935) says there is deliberately no config field, because a default that silently drives a different graphic is worse than a button that does nothing, yet blank-channel actions still do that.

**Evidence:**

```ts
// src/main.ts:920-924
if (!fallbackProject) return null
const channel = value || this.defaultChannel
if (!channel) return null
this.nominateDefault(fallbackProject, channel)
return { project: fallbackProject, channel }
// src/actions.ts:88-91
const target = self.track(actionId, channel)
if (!target) {
	self.log('warn', `No channel given for ${what}, and no default set in the connection config`)
	return
```

**Fix:** pick one of two approaches. (a) Add a "Default channel" config field and make a blank channel resolve only to that field. (b) Make actions refuse a blank channel (log "no channel set" and send nothing), and keep the implicit default only for the connection variables. Either way, update the option label and the "no default set in the connection config" log text so they match how it works.

## 🟢 Low

### L1: Playback state is idle feedback lights up while the server is unreachable

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.ts:99-102`](https://github.com/bitfocus/companion-module-breeze-overlay/blob/fa71cf18778b93f10f7a4b7c9a78a5ce97d73c0f/src/feedbacks.ts#L99-L102)

**What goes wrong:** A button uses the "Playback state is…" feedback with State = idle, for example to show that a graphic is ready to roll. If Breeze is down, the channel name is wrong, or Companion has just started, the button still shows the idle colour. That tells the operator the graphic is idle and ready when the module has no information at all. Only the "idle" choice is affected; the other states stay unlit.

**Why it happens:** When there is no cached state, the feedback substitutes `'idle'`, and the poll deletes the cached state on any error, so "unknown" turns into "idle". The "No browser source attached" feedback in the same file avoids this on purpose ("Unknown is not the same as zero").

**Fix:** return false when there is no state, the same way the on-air and source-connected feedbacks do.

```ts
const playback = state?.playback?.state
if (!playback) return false
return playback === feedback.options.state
```

### L2: Camera list is frozen feedback does not update when a failed camera becomes frozen

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:394-396`](https://github.com/bitfocus/companion-module-breeze-overlay/blob/fa71cf18778b93f10f7a4b7c9a78a5ce97d73c0f/src/main.ts#L394-L396)

**What goes wrong:** A camera list has 1 failed camera and 0 frozen. The camera then becomes frozen, so the list has 0 failed and 1 frozen. A button using the "Camera list is…" feedback with State "A camera is frozen" stays unlit until some other source value changes (cameras up or down, or a source's backup or failing state). The `media_down` variable is unaffected, because it is still 1.

**Why it happens:** The change check for the source list records only cameras up (ok + unchecked) and cameras down (failed + frozen). A move between failed and frozen leaves both sums the same, so the module decides nothing changed and skips re-checking the feedbacks, even though it has stored the new counts.

**Fix:** add the individual counts to the change signature, for example `s.status.media?.failed` and `s.status.media?.frozen`, or include the whole `status.media` object.

### L3: Channel and ticker variables keep the old project's values after the config is saved

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:208-241`](https://github.com/bitfocus/companion-module-breeze-overlay/blob/fa71cf18778b93f10f7a4b7c9a78a5ce97d73c0f/src/main.ts#L208-L241)

**What goes wrong:** After a user changes the Project URL key (or the server) and saves, `$(breeze-overlay:channel)`, `$(breeze-overlay:playback_state)`, `$(breeze-overlay:cycle_seconds_left)`, and likewise the server version and project variables, keep the old values until the first poll round finishes. The values correct themselves within about one poll interval, so the effect is cosmetic.

**Why it happens:** Saving the config clears the state cache and the default channel, but it doesn't republish the default-channel variables or stop the 250 ms countdown ticker. The ticker keeps running but returns early, so it does no visible harm and is never duplicated.

**Fix:** in `configUpdated()`, call `this.stopTicker()` and `this.publishDefaultVariables()` right after clearing the owners and the default channel, and reset `server_version` and `project` there too.

### L4: Two camera lists whose ids differ only in punctuation share one CHECK CAMERAS preset

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/presets.ts:241`](https://github.com/bitfocus/companion-module-breeze-overlay/blob/fa71cf18778b93f10f7a4b7c9a78a5ce97d73c0f/src/presets.ts#L241)

**What goes wrong:** A project has two camera-list data sources, `cams.north` and `cams_north`. The Presets panel's camera-list section shows only one CHECK CAMERAS button, listed twice, so the user can't drag in a check button for the other list. Real projects rarely have ids that differ only in punctuation.

**Why it happens:** The preset id replaces every character other than letters, digits, `_` and `-` with `_`, so both ids map to the same key and the second preset overwrites the first. The mode presets ([`src/presets.ts:278`](https://github.com/bitfocus/companion-module-breeze-overlay/blob/fa71cf18778b93f10f7a4b7c9a78a5ce97d73c0f/src/presets.ts#L278)) and PAGE presets ([`src/presets.ts:162`](https://github.com/bitfocus/companion-module-breeze-overlay/blob/fa71cf18778b93f10f7a4b7c9a78a5ce97d73c0f/src/presets.ts#L162)) add a name hash to avoid exactly this.

**Fix:** append the hash, the same way the mode and PAGE presets do. Consider doing the same for the `source__…__backup` ids at [`src/presets.ts:208`](https://github.com/bitfocus/companion-module-breeze-overlay/blob/fa71cf18778b93f10f7a4b7c9a78a5ce97d73c0f/src/presets.ts#L208).

```ts
const id = `media__${source.def.id.replace(/[^A-Za-z0-9_-]/g, '_')}__${nameHash(source.def.id)}__check`
```

## 📝 Additional Notes

- Follow-up on the v1.1.0 review: every finding is fixed in v1.1.1.
- C1 (`tsconfig.build.json`), C2–C5 (`postinstall`, `husky`, `lint-staged` and its config block) and H1 (`LICENSE`) now match the template; the template check reports no differences.
- H2 (overlapping connects leak a poll interval): fixed with a connect generation counter and a `destroyed` flag ([`src/main.ts:124-135`](https://github.com/bitfocus/companion-module-breeze-overlay/blob/fa71cf18778b93f10f7a4b7c9a78a5ce97d73c0f/src/main.ts#L124-L135)), and `startPolling()` now clears the old timer first ([`src/main.ts:660-666`](https://github.com/bitfocus/companion-module-breeze-overlay/blob/fa71cf18778b93f10f7a4b7c9a78a5ce97d73c0f/src/main.ts#L660-L666)).
- M1 (wrong API key never shows AuthenticationFailure): a refused command, or a server that needs a key when none is set, now holds AuthenticationFailure through every poll until a command succeeds ([`src/main.ts:1022-1043`](https://github.com/bitfocus/companion-module-breeze-overlay/blob/fa71cf18778b93f10f7a4b7c9a78a5ce97d73c0f/src/main.ts#L1022-L1043)). The maintainer explains that Breeze checks the key only on commands, so a poll can't detect it.
- M2 (status never recovers with no channel watched): the poll now falls back to `/healthz` when no channel is read. M3 (`context.signal`): every action passes the signal through, and `request()` combines it with the timeout.
- L1 (slow `init`): `connect()` now runs in the background. L2 (unchecked casts): responses and socket states go through `src/validate.ts`. L4, L6, L7, L8: fixed (variables reset, per-generation poll guard, `disableAutoExpression` on the cycle dropdown, preset names use the label fallback).
- N1 (WebSocket welcome timeout), N2 (feedbacks and status re-sent every tick) and N3 (`restart()` comment): fixed.
