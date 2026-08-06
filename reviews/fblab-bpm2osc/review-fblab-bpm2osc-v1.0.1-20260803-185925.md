# Module Review — fblab-bpm2osc v1.0.1

| | |
|---|---|
| **Module** | `companion-module-fblab-bpm2osc` |
| **Review tag** | `v1.0.1` |
| **Previous tag** | *(none — first release)* |
| **Scope** | `tag` |
| **Language / API** | TypeScript · `@companion-module/base` v2 (2.0.4) |
| **Transport** | HTTP (`node:http` POST) + SSE (`eventsource` 3.0.7) |
| **Reviewed** | 2026-08-03 |

> **First release** — there is no `previousTag..reviewTag` diff, so the `tag` scope falls back to a full review of the module at `v1.0.1`. Every finding is therefore **NEW**.

> **Transport note:** the manifest keywords list `osc`, but the module itself speaks no OSC. It is a client for the BPM2OSC desktop app's HTTP API (outbound commands via `POST`, inbound state via Server-Sent Events); the OSC output happens inside the BPM2OSC app. The findings below are about the HTTP/SSE layer.
> Kind of odd that it is called BPM2OSC but this module does not do any OSC communication.  

## Verdict: ❌ Changes Required

## 📋 Issues

**Blocking**

- please add the direct link to the BPM2OSC software in the help file.  The currently link points to your home page instead of [https://bpm2osc.fblab.it/](https://bpm2osc.fblab.it/)
- please document in the help.md that this is only for Windows
- [ ] [H1: new EventSource() can throw synchronously and is unguarded at all three call sites](#h1-new-eventsource-can-throw-synchronously-and-is-unguarded-at-all-three-call-sites)
- [ ] [H2: Unvalidated SSE payload replaces the whole state object and silently stops all updates](#h2-unvalidated-sse-payload-replaces-the-whole-state-object-and-silently-stops-all-updates)
- [ ] [H3: SSE hot path pushes all variables and re-checks all feedbacks at up to 50 Hz](#h3-sse-hot-path-pushes-all-variables-and-re-checks-all-feedbacks-at-up-to-50-hz)
- [ ] [H4: legacyIds claims an id this module never published](#h4-legacyids-claims-an-id-this-module-never-published)
- [ ] [H5: SSE Handlers overwrites this._es](#h5-sse-handlers-overwrites-this_es)
- [ ] [H6: Display-only presets use steps: []](#h6-display-only-presets-use-steps-)
- [ ] [H7: HELP.md does not stand alone](#h7-helpmd-does-not-stand-alone)

**Non-blocking**

- [ ] [M3: postCmd() always resolves, so failed actions report success](#m3-postcmd-always-resolves-so-failed-actions-report-success)
- [ ] [M5: State is never reset on disconnect, so toggle can send the wrong command](#m5-state-is-never-reset-on-disconnect-so-toggle-can-send-the-wrong-command)
- [ ] [L6: checkFeedbacks() hand-enumerates all eight feedback ids](#l6-checkfeedbacks-hand-enumerates-all-eight-feedback-ids)

---

## 🟠 High

### H1: new EventSource() can throw synchronously and is unguarded at all three call sites

**File:** `src/main.ts:114` (call sites `:43`, `:53`, `:156`)
**Classification:** 🆕 NEW

`baseUrl()` builds `http://${host}:${port}` with no validation, and `new EventSource(url)` throws synchronously on a malformed URL (verified against the bundled `eventsource@3.0.7`, which does `new URL(url, …)` and rethrows). An empty host yields `http://:5000/api/stream` and throws `DOMException: An invalid or illegal string was specified`; a host with whitespace, or a pasted `http://10.0.0.5`, does the same. `config.host` is a plain `textinput` with no `required` and no regex, so a user clearing the field reproduces this directly.

The consequences differ per call site:

- **`init()` (`:43`) / `configUpdated()` (`:53`)** — the throw rejects the lifecycle promise. Because `_connectSSE()` sets `InstanceStatus.Connecting` on `:110` *before* the throw, and `configUpdated()` has already torn the old connection down, the instance is left with no EventSource, no reconnect timer, and the status pinned at **Connecting** indefinitely. Only another config save recovers it, and the user gets a generic error rather than a pointer to the bad field.
- **Reconnect timer (`:156`)** — the throw escapes a `setTimeout` callback, i.e. an **uncaught exception**, not a rejected promise.

**Suggested fix:** validate before connecting, and wrap the constructor so nothing can escape:

```ts
private _connectSSE(): void {
    const host = (this.config.host ?? '').trim()
    if (!host || !this.config.port) {
        this.updateStatus(InstanceStatus.BadConfig, 'Host and port are required')
        return   // no retry — a retry loop cannot fix bad config
    }
    let es: EventSource
    try {
        es = new EventSource(`http://${host}:${this.config.port}/api/stream`)
    } catch (e) {
        this.updateStatus(InstanceStatus.BadConfig, `Invalid host/port: ${e}`)
        return
    }
    this._es = es
    // …handlers
}
```

### H2: Unvalidated SSE payload replaces the whole state object and silently stops all updates

**File:** `src/main.ts:127`
**Classification:** 🆕 NEW

```ts
this.state = JSON.parse(e.data as string) as BPM2OSCState
```

The parsed object is assigned to `this.state` before anything validates it, and it **replaces** the state rather than merging into it. A partial payload (e.g. `{"bpm":120}`), a non-state message on the default `message` event, or an off-version server all leave required fields `undefined`. `updateVariableValues` then hits `s.bpm.toFixed(2)` (`src/variables.ts:32`) → `TypeError`.

That throw is swallowed by the `catch` on `:146`, which logs `SSE parse error` — at up to 50 Hz (the README documents "state updates arrive at up to 50 Hz") that is a log flood. Because the throw happens *before* `checkFeedbacks`, feedbacks and presets stop updating entirely while `InstanceStatus` stays **Ok**. The poisoned state also persists: feedback callbacks that Companion invokes later read it *outside* the try/catch — `Math.round(self.state.conf * 100)` → `NaN`, so `confidence_above` becomes silently always false and the `confidence` variable renders `NaN%`.

**Suggested fix:** parse into `unknown`, validate field-by-field, and merge over a fresh default so the shape can never break:

```ts
const parsed = JSON.parse(e.data as string) as Partial<BPM2OSCState>
this.state = { ...createDefaultState(), ...parsed }
```

Type-check every field you dereference (`typeof parsed.bpm === 'number'`, `Array.isArray(parsed.presets)`), clamp `conf` to 0–1, and only assign `this.state` once validation succeeds. Separate the `JSON.parse` try/catch from the variable/feedback/preset update block, and rate-limit the failure log.

### H3: SSE hot path pushes all variables and re-checks all feedbacks at up to 50 Hz

**File:** `src/main.ts:125-149`
**Classification:** 🆕 NEW

Every SSE message runs, unconditionally: a `JSON.parse` of the whole state (including the `vu: number[]` meter array), **two** `JSON.stringify` calls to compare preset lists, `setVariableValues` for all 9 variables, and `checkFeedbacks(...)` with all 8 feedback ids. `checkFeedbacks` forces the Companion host to re-evaluate and re-render every button bound to those feedbacks — at the documented 50 Hz, across all 8 feedback types, across the entire surface.

Most of the state (`running`, `locked`, `auto_locked`, `factor`, `preset`) changes rarely; only `bar_beat`, `bpm`, `conf` and `vu` move fast.

**Suggested fix:** keep the previous state and diff it.

- Call `checkFeedbacks` only with the ids whose backing fields actually changed (`running` → `running`/`stopped`, `locked`/`auto_locked`, `factor` → `factor_active`, `preset` → `preset_active`, `conf` → `confidence_above`, `bar_beat` → `beat_one`).
- Call `setVariableValues` with only the changed keys.

---

### H4: legacyIds claims an id this module never published

**File:** `companion/manifest.json:20`
**Classification:** 🆕 NEW

`"legacyIds": ["bpm2osc"]` on a module whose first release is this one. `legacyIds` exists so a renamed or migrated module can adopt its predecessor's saved connections; claiming an id that was never shipped means any future or third-party `bpm2osc` module would be shadowed.

**Suggested fix:** remove the `legacyIds` array unless a module with id `bpm2osc` was genuinely published previously.

---

### H5: SSE handlers overwrites this._es

**File:** `src/main.ts:114-161`
**Classification:** 🆕 NEW

`this._es = new EventSource(url)` overwrites whatever is in `_es` without closing it.

In the destroy it checks if _es is not null and closes it.  

**Suggested fix:** check if _es is not null and close it before creating new

---

### H6: Display-only presets use steps: []

**File:** `src/presets.ts:75`, `src/presets.ts:82`
**Classification:** 🆕 NEW

The display-only `confidence` and `preset_display` presets declare an empty `steps` array.

**Suggested fix:** use `steps: [{ down: [], up: [] }]` so the placed button has one well-formed empty step.

---

### H7: HELP.md does not stand alone

**File:** `companion/HELP.md`
**Classification:** 🆕 NEW

HELP.md is what users see inside Companion, but it lists internal ids (`div2`, `bar_beat`, `auto_locked`) rather than UI names, documents no configuration fields, and defers to the GitHub README for "full details".

**Suggested fix:** add a Configuration section describing Host/IP and Port; remove the list of actions, feedbacks and variables; add a short troubleshooting note (BPM2OSC web server not enabled, wrong port, firewall).  Remove the link the readme.md since it won't resolve when the module is installed in Companion.

## 🟡 Medium

### M3: postCmd() always resolves, so failed actions report success

**File:** `src/main.ts:80-107`
**Classification:** 🆕 NEW

Both failure paths — `req.on('error')` (`:98-101`) and an HTTP status `>= 400` (`:91-93`) — only log and then `resolve()`. The action therefore reports success, the button gives the operator no error indication, and `InstanceStatus` is never touched. With the SSE stream up but the POST endpoint failing (404 from an older BPM2OSC that lacks the endpoint, auth, half-open socket), the module still reads **Ok** while every button silently does nothing.

There is also no agent/connection management, so rapid Tap Tempo presses open unbounded concurrent sockets, and command ordering (e.g. `div2` then `mul2`) is not guaranteed.

**Suggested fix:** reject the promise on transport error and on status `>= 400` so Companion surfaces the failure to the operator, and call `this.updateStatus(InstanceStatus.ConnectionFailure, …)` on transport failure (restoring `Ok` on the next success). Consider serialising commands through a small queue to preserve ordering and bound concurrency.

### M5: State is never reset on disconnect, so toggle can send the wrong command

**File:** `src/main.ts:151-161`, `src/actions.ts:30`
**Classification:** 🆕 NEW

When the stream drops, `this.state` keeps its last received values. The `bpm`, `running` and `confidence` variables keep displaying live-looking data for an unreachable device, and the `running`/`stopped` feedbacks stay lit.

More seriously, `toggle` decides client-side:

```ts
self.postCmd(self.state.running ? 'stop' : 'start')
```

After a reconnect where the engine's state changed while disconnected — or at first connect, where `DEFAULT_STATE.running === false` — the first press sends the opposite of what the operator intended.

**Suggested fix:** in the `onerror` handler (and in `configUpdated`), reset `this.state` to a fresh default, reset `_lastPresets`, then call `updateVariableValues(this)` and `checkFeedbacks(...)` so the surface reflects "unknown/disconnected". For `toggle`, prefer a server-side `/api/toggle` endpoint if BPM2OSC offers one; otherwise refuse the action with a warning when the SSE stream is not open, since the local `running` flag is not authoritative.

---

## 🟢 Low

### L6: checkFeedbacks() hand-enumerates all eight feedback ids

**File:** `src/main.ts:136-145`
**Classification:** 🆕 NEW

The call lists all eight ids literally, so a ninth feedback added later will silently never be checked.

**Suggested fix:** use `this.checkAllFeedbacks()` if you are just going to check all of the feedbacks

---
