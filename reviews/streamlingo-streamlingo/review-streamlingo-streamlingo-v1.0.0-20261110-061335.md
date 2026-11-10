# Review: streamlingo-streamlingo v1.0.0

| Field | Value |
| --- | --- |
| **Module** | [`companion-module-streamlingo-streamlingo`](https://github.com/bitfocus/companion-module-streamlingo-streamlingo) |
| **Scope** | `tag` (first release: the whole module was reviewed) |
| **Version** | v1.0.0 ([`e80129e`](https://github.com/bitfocus/companion-module-streamlingo-streamlingo/commit/e80129e3858fd790935fb390b27f2400650d7100)) |
| **Release** | New module — never published |
| **API** | 2.1 (base 2.1.3, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Reviewed** | 2026-11-09 |

## Verdict: ❌ Changes Required

## ❓ Assumptions

Some findings depend on assumptions the reviewers couldn't check. They're listed in [❓ Assumptions to Confirm](#-assumptions-to-confirm) at the end of this review.

## 📋 Issues

### Blocking

- [ ] [C1: The module still targets Node 22, but the API 2.1 template runs on Node 26](#c1-the-module-still-targets-node-22-but-the-api-21-template-runs-on-node-26)
- [ ] [H1: The manifest claims the legacy id "streamlingo" although this module has never been published](#h1-the-manifest-claims-the-legacy-id-streamlingo-although-this-module-has-never-been-published)

### Non-blocking

- [ ] [M1: Memory use keeps growing for as long as the connection runs](#m1-memory-use-keeps-growing-for-as-long-as-the-connection-runs)
- [ ] [M2: Aborting a button's actions doesn't cancel a Streamlingo command that is still waiting for a reply](#m2-aborting-a-buttons-actions-doesnt-cancel-a-streamlingo-command-that-is-still-waiting-for-a-reply)
- [ ] [L1: A Streamlingo server outage shows as "API key rejected"](#l1-a-streamlingo-server-outage-shows-as-api-key-rejected)
- [ ] [L2: The start and stop toggle sends Stop while the status is still Unknown](#l2-the-start-and-stop-toggle-sends-stop-while-the-status-is-still-unknown)
- [ ] [L3: The help page describes preset colours and status values that don't match the module](#l3-the-help-page-describes-preset-colours-and-status-values-that-dont-match-the-module)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🔴 Critical

### C1: The module still targets Node 22, but the API 2.1 template runs on Node 26

- **Source:** 🤖 validate-template (NODE-VERSION)
- **Classification:** 🆕 NEW
- **File:** [`companion/manifest.json:19`](https://github.com/bitfocus/companion-module-streamlingo-streamlingo/blob/e80129e3858fd790935fb390b27f2400650d7100/companion/manifest.json#L19)

**What goes wrong:** The module is built on `@companion-module/base` 2.1, whose template runs on Node 26, but the manifest asks Companion to run it on Node 22. A module that doesn't match its own template is confusing to troubleshoot later: when something misbehaves, people look for the cause in the module when the real difference is the runtime. M1 below is an example: the memory growth it describes only happens on Node 22.

**Why it happens:** The Node version is named in several places, and all of them were left on 22 when the module moved to API 2.1.

**Evidence:** validator: `The API 2.1 template runs on Node 26; update every place still on another version` — each place below is `found -> template value`.

**Fix:** update every place to Node 26, as the template does:

- [ ] [`companion/manifest.json:19`](https://github.com/bitfocus/companion-module-streamlingo-streamlingo/blob/e80129e3858fd790935fb390b27f2400650d7100/companion/manifest.json#L19): `"runtime": { "type": "node26" }` (now `node22`)
- [ ] [`package.json:25`](https://github.com/bitfocus/companion-module-streamlingo-streamlingo/blob/e80129e3858fd790935fb390b27f2400650d7100/package.json#L25): `"engines": { "node": "^26" }` (now `>=22.20`)
- [ ] [`package.json:33`](https://github.com/bitfocus/companion-module-streamlingo-streamlingo/blob/e80129e3858fd790935fb390b27f2400650d7100/package.json#L33): `"@types/node": "^26.6.4"` in `devDependencies` (now `^22.20.5`)
- [ ] [`tsconfig.build.json:2`](https://github.com/bitfocus/companion-module-streamlingo-streamlingo/blob/e80129e3858fd790935fb390b27f2400650d7100/tsconfig.build.json#L2): `"extends": "@companion-module/tools/tsconfig/node26/recommended.json"` (now `…/node22/recommended-esm.json`)
- [ ] [`.github/workflows/node.yaml`](https://github.com/bitfocus/companion-module-streamlingo-streamlingo/blob/e80129e3858fd790935fb390b27f2400650d7100/.github/workflows/node.yaml#L21-L25): `- name: Use Node.js 26.x` (line 21) and `node-version: 26.x` (line 25), plus the same two lines in the commented-out `test:` job (lines 53 and 56)

## 🟠 High

### H1: The manifest claims the legacy id "streamlingo" although this module has never been published

- **Source:** 🤖 validate-template (MAN-LEGACYIDS)
- **Classification:** 🆕 NEW
- **File:** [`companion/manifest.json:24`](https://github.com/bitfocus/companion-module-streamlingo-streamlingo/blob/e80129e3858fd790935fb390b27f2400650d7100/companion/manifest.json#L24)

**What goes wrong:** `legacyIds` tells Companion which older module ids this module replaces; Companion moves connections of those modules over to this one. This module replaces nothing, so the entry only claims the id `streamlingo`. If a module with that id is ever published, Companion would move its users' connections to this module.

**Why it happens:** The template ships `"legacyIds": []`, and a first release has nothing to list there.

**Evidence:** validator: `legacyIds lists 'streamlingo' but the module has never been published; it must be [] as in the template`

```json
// companion/manifest.json:24
	"legacyIds": ["streamlingo"],
```

**Fix:** empty the list, as in the template: `"legacyIds": []`.

## 🟡 Medium

### M1: Memory use keeps growing for as long as the connection runs

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/api.ts:53-58`](https://github.com/bitfocus/companion-module-streamlingo-streamlingo/blob/e80129e3858fd790935fb390b27f2400650d7100/src/api.ts#L53-L58), [`src/main.ts:67-69`](https://github.com/bitfocus/companion-module-streamlingo-streamlingo/blob/e80129e3858fd790935fb390b27f2400650d7100/src/main.ts#L67-L69)

**What goes wrong:** Companion is left running for days with the default **Status Poll Interval (ms)** of 2000. The module's memory grows by about 7–8 MB a day (about 30 MB a day at the 500 ms minimum), roughly 225 MB over a month. The connection stays green; memory only drops when the connection's settings are saved or it is restarted.

**Why it happens:** Every status poll and every command combines the connection's long-lived abort signal with a new 5-second timeout signal (`AbortSignal.any([this.#abort.signal, timeoutSignal])`). On Node 22 each combined signal stays attached to the long-lived signal until that controller is replaced, which only happens in `configUpdated()` or `destroy()`. The reviewer reproduced this with the module's request pattern: the heap grew about 180 bytes per request on Node 22.14 and 22.21, and stayed flat on Node 24 and 26.

**Fix:** moving the runtime to Node 26 (C1) removes the growth. If the module stays on Node 22, don't combine the long-lived signal with a new timeout on every request: create a per-request `AbortController`, abort it from a `{ once: true }` listener on `this.#abort.signal`, and remove that listener in a `finally`.

### M2: Aborting a button's actions doesn't cancel a Streamlingo command that is still waiting for a reply

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:19-64`](https://github.com/bitfocus/companion-module-streamlingo-streamlingo/blob/e80129e3858fd790935fb390b27f2400650d7100/src/actions.ts#L19-L64), [`src/main.ts:96-103`](https://github.com/bitfocus/companion-module-streamlingo-streamlingo/blob/e80129e3858fd790935fb390b27f2400650d7100/src/main.ts#L96-L103)

**What goes wrong:** A user presses a button with **Start translation** (or Stop, Pause, Resume, or a toggle) while Streamlingo is slow to answer, then aborts the button's running actions. The module keeps waiting up to 5 seconds and still applies the answer, so the button colour and `$(streamlingo:status)` change after the user aborted.

**Why it happens:** Since API 2.1, each action callback receives a `context.signal` that Companion aborts when the user aborts the running actions. No action callback here takes the `context` argument; `sendCommand` only passes the module's own abort signal, which fires only on `configUpdated()` or `destroy()`. `callStreamlingo` already accepts a signal and combines it with its timeout, so the change is small.

**Fix:** pass the action's signal through: `callback: async (_action, context) => self.sendCommand('start', context.signal)`. Give `sendCommand` an optional `signal` parameter, combine it with `this.#abort.signal` for the request, and return quietly in the `catch` when `signal?.aborted` is true.

## 🟢 Low

### L1: A Streamlingo server outage shows as "API key rejected"

- **Source:** 🔎 protocol reviewer, QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/api.ts:61-63`](https://github.com/bitfocus/companion-module-streamlingo-streamlingo/blob/e80129e3858fd790935fb390b27f2400650d7100/src/api.ts#L61-L63), [`src/main.ts:149-150`](https://github.com/bitfocus/companion-module-streamlingo-streamlingo/blob/e80129e3858fd790935fb390b27f2400650d7100/src/main.ts#L149-L150), [`src/main.ts:106-108`](https://github.com/bitfocus/companion-module-streamlingo-streamlingo/blob/e80129e3858fd790935fb390b27f2400650d7100/src/main.ts#L106-L108)

**What goes wrong:** If the Streamlingo service (or a proxy in front of it) briefly answers with HTTP 502, 503 or 429, the connection turns to a bad-configuration status: "API key rejected. Check that Remote Control via URL is enabled." The key is fine, but the user may regenerate it for nothing. A command pressed during the outage logs `Streamlingo rejected "start" while translation is unknown: <error page>`, which reads as if Streamlingo refused the command. An HTML error page goes into the log in full. The status recovers on the next successful poll.

**Why it happens:** The code comment says Streamlingo uses HTTP 400 for a bad key or an action not allowed in the current state, but `callStreamlingo` throws the same `StreamlingoRequestError` for every non-2xx response. `#poll` maps that error to `BadConfig`, and `sendCommand` logs it as a rejection.

**Fix:** throw `StreamlingoRequestError` only for HTTP 400; report other codes as `ConnectionFailure` with the HTTP status (e.g. `HTTP 503 Service Unavailable`), log them as "Failed to send", and shorten the body (e.g. `body.trim().slice(0, 200)`) before logging it.

### L2: The start and stop toggle sends Stop while the status is still Unknown

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:58-64`](https://github.com/bitfocus/companion-module-streamlingo-streamlingo/blob/e80129e3858fd790935fb390b27f2400650d7100/src/actions.ts#L58-L64)

**What goes wrong:** Right after Companion starts or the settings are saved, and after any single failed poll, the status shows "Unknown". Pressing the **Start / stop toggle with status** preset then sends `stop`. Streamlingo is already stopped, so nothing happens and a warning is logged; the operator has to press again. The **Toggle pause / resume** action handles Unknown by doing nothing, so the two toggles behave differently.

**Why it happens:** `self.status === 'stopped' ? 'start' : 'stop'` treats every status other than `stopped`, including the module's own `unknown` placeholder, as running.

**Fix:** when the status is `unknown`, log at info level and return, as `toggle_pause` does, or fetch the status first and decide from the fresh value.

### L3: The help page describes preset colours and status values that don't match the module

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`companion/HELP.md:45`](https://github.com/bitfocus/companion-module-streamlingo-streamlingo/blob/e80129e3858fd790935fb390b27f2400650d7100/companion/HELP.md#L45), [`companion/HELP.md:63`](https://github.com/bitfocus/companion-module-streamlingo-streamlingo/blob/e80129e3858fd790935fb390b27f2400650d7100/companion/HELP.md#L63)

**What goes wrong:**

- The help says presets turn "amber while starting, waiting or paused". On the **Start / stop toggle with status** and **Status display** presets, Paused is blue ([`src/presets.ts:66`](https://github.com/bitfocus/companion-module-streamlingo-streamlingo/blob/e80129e3858fd790935fb390b27f2400650d7100/src/presets.ts#L66), [`src/presets.ts:86`](https://github.com/bitfocus/companion-module-streamlingo-streamlingo/blob/e80129e3858fd790935fb390b27f2400650d7100/src/presets.ts#L86)); only the pause presets show amber.
- The Variables table lists the raw values of `$(streamlingo:status)` as `stopped`, `starting`, `waiting_for_input`, `running`, `paused`. When Streamlingo can't be reached or the key is rejected, the module sets `unknown`, so a user writing `$(streamlingo:status) == 'unknown'` can't learn from the help that this value exists.

**Why it happens:** The help text describes the general colour scheme rather than each preset, and the raw-value list leaves out the module's own placeholder.

**Fix:** say on line 63 that Paused is blue on the start/stop toggle and the status display and amber on the pause presets (or use one colour everywhere), and add `unknown` to the raw-value list on line 45.

## 📝 Additional Notes

- `tsconfig.build.json` adds `"module": "node20"` to `compilerOptions`, which the template doesn't set. The module builds, so no change is required.

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | The Node 22 build that Companion uses keeps signals combined with `AbortSignal.any` attached to the source signal, as Node 22.14.0 and 22.21.1 do | the manifest's `node22` runtime and local runs on those Node versions; the exact Node build Companion bundles was not checked | [M1](#m1-memory-use-keeps-growing-for-as-long-as-the-connection-runs) |
| A2 | Companion 5.0 aborts an action callback's `context.signal` when the user aborts a button's running actions | the base 2.1.3 typing comment in `node_modules/@companion-module/base/dist/module-api/action.d.ts:59-62`; the Companion host was not checked | [M2](#m2-aborting-a-buttons-actions-doesnt-cancel-a-streamlingo-command-that-is-still-waiting-for-a-reply) |
