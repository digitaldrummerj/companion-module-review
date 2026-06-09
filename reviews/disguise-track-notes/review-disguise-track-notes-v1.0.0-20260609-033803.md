# Review — disguise-track-notes v1.0.0

| | |
|---|---|
| **Module** | disguise-track-notes |
| **Version** | v1.0.0 |
| **Scope** | tag (first release — no prior tag, so reviewed as a full module) |
| **Language / API** | JS · @companion-module/base v1 (~1.14.1) |
| **Protocol** | HTTP polling (Disguise Transport API) |
| **Reviewed** | 2026-06-09 |

> First release: `previousTag` is `(none — first release)`, so there is no diff to scope against. The whole module was reviewed and every finding is classified **🆕 New**.

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 2 | 0 | 2 |
| 🟠 High | 2 | 0 | 2 |
| 🟡 Medium | 5 | 0 | 5 |
| 🟢 Low | 5 | 0 | 5 |
| 💡 Nice to Have | 4 | 0 | 4 |
| **Total** | **18** | **0** | **18** |

## Verdict: ❌ Changes Required

## 📋 Issues

**Blocking**
- [ ] [C1: Source files live at the repo root instead of src](#c1-source-files-live-at-the-repo-root-instead-of-src)
- [ ] [C2: Manufacturer name Disguise used as a manifest keyword](#c2-manufacturer-name-disguise-used-as-a-manifest-keyword)
- [ ] [H1: fetchProjectFps halves any frame rate above 30 fps](#h1-fetchprojectfps-halves-any-frame-rate-above-30-fps)
- [ ] [H2: secondsToTimecode produces wrong frames for non-integer fps](#h2-secondstotimecode-produces-wrong-frames-for-non-integer-fps)

**Non-blocking**
- [ ] [M1: The 5s timeout budgets the whole poll cycle, not each request](#m1-the-5s-timeout-budgets-the-whole-poll-cycle-not-each-request)
- [ ] [M2: setInterval polling can overlap and starve under load](#m2-setinterval-polling-can-overlap-and-starve-under-load)
- [ ] [M3: fetchProjectFps silently substitutes 25 fps on failure](#m3-fetchprojectfps-silently-substitutes-25-fps-on-failure)
- [ ] [M4: Fire-and-forget checkConnection calls have no catch](#m4-fire-and-forget-checkconnection-calls-have-no-catch)
- [ ] [M5: Track entries uid and name are used unvalidated](#m5-track-entries-uid-and-name-are-used-unvalidated)
- [ ] [L1: secondsToTimecode has no guard for zero or undefined fps](#l1-secondstotimecode-has-no-guard-for-zero-or-undefined-fps)
- [ ] [L2: An abort during the fps fetch is masked as fps 25](#l2-an-abort-during-the-fps-fetch-is-masked-as-fps-25)
- [ ] [L3: Feedback lookup is exact-string-match only and fails silently](#l3-feedback-lookup-is-exact-string-match-only-and-fails-silently)
- [ ] [L4: Feedback awaits the synchronous getVariableValue](#l4-feedback-awaits-the-synchronous-getvariablevalue)
- [ ] [L5: Connecting status is not recorded in lastStatus](#l5-connecting-status-is-not-recorded-in-laststatus)
- [ ] [N1: track_notes exposes a raw JSON blob as a user variable](#n1-track_notes-exposes-a-raw-json-blob-as-a-user-variable)
- [ ] [N2: runEntrypoint is passed an inline empty array](#n2-runentrypoint-is-passed-an-inline-empty-array)
- [ ] [N3: Port is not validated in initPolling](#n3-port-is-not-validated-in-initpolling)
- [ ] [N4: Feedback options lack variable support and discovery is manual](#n4-feedback-options-lack-variable-support-and-discovery-is-manual)

---

## 🔴 Critical

### C1: Source files live at the repo root instead of src

**File:** `main.js`, `feedbacks.js`, `variables.js` (repo root)
**Classification:** 🆕 New

All three source files sit at the repository root. The official JS v1 template requires module source to live under `src/`, with the manifest entrypoint pointing into it. The deterministic template check flags each file (`SRC-AT-ROOT`).

**Fix for the maintainer:** Move `main.js`, `feedbacks.js`, and `variables.js` into `src/`, update the requires accordingly, and point `package.json` `main` and the manifest `runtime.entrypoint` at the relocated entry (`../src/main.js`).

### C2: Manufacturer name Disguise used as a manifest keyword

**File:** `companion/manifest.json` (`keywords`)
**Classification:** 🆕 New

`keywords` includes `"Disguise"`, which is the manufacturer name. The manufacturer is already declared in the dedicated `manufacturer` field, so repeating it as a keyword is a banned/low-value keyword (`MAN-KEYWORD`). Keywords should describe capability/protocol, not restate the vendor.

**Fix for the maintainer:** Remove `"Disguise"` from `keywords`. Keep capability/protocol terms (e.g. `Media Server`, `D3`) and add functional descriptors if helpful (e.g. `timecode`, `notes`, `transport`).

---

## 🟠 High

### H1: fetchProjectFps halves any frame rate above 30 fps

**File:** `main.js:104`
**Classification:** 🆕 New

`fetchProjectFps` returns `refreshRate <= 30 ? refreshRate : refreshRate / 2`. Any project running above 30 fps is silently halved — a real 50/60 fps project is treated as 25/30, and 59.94 becomes 29.97. Every `secondsToTimecode` call (`main.js:187`) for that project then produces timecode keys with the wrong frame numbering, so timecode-keyed note lookups in the feedback silently miss. (CUE-keyed notes are unaffected, since they key off the CUE name rather than a computed timecode.)

**Fix for the maintainer:** Use the reported `globalRefreshRate` directly as the project fps and validate it (finite, positive). If the `/2` was meant to handle a known field-rate quirk of the disguise API, gate it behind a verified condition or a config option rather than applying it unconditionally to every rate over 30.

### H2: secondsToTimecode produces wrong frames for non-integer fps

**File:** `main.js:110-119`
**Classification:** 🆕 New

For a fractional fps (e.g. 23.976, 29.97 — exactly the values H1's `/2` path can yield), `frames = totalFrames % fps` is itself fractional and the second/minute/hour rollover is computed against a fractional divisor, so the boundary frames drift. `pad()` masks the fractional frame with `Math.floor`, but the resulting timecode string no longer matches what disguise displays, so the feedback's timecode-key lookup fails silently.

**Fix for the maintainer:** Compute frames against an integer nominal frame rate (e.g. 24 for 23.976, 30 for 29.97, with drop-frame handling if disguise uses it), or document that only integer fps is supported. Round the divisor to a positive integer before the modulo/division so keys are stable and matchable. Pairs with H1.

---

## 🟡 Medium

### M1: The 5s timeout budgets the whole poll cycle, not each request

**File:** `main.js:137`, `main.js:152-201`
**Classification:** 🆕 New

A single `timeoutId` (5000 ms) is armed once at the top of `checkConnection`, but the method then performs `fetchProjectFps` + a `/tracks` fetch + **one `/annotations` fetch per track** sequentially. On a project with many tracks the cumulative time easily exceeds 5 s, the controller aborts mid-loop, and the catch reports `Connection timeout` / Disconnected even though the device is healthy and responding. The timeout budgets the entire cycle rather than each request.

**Fix for the maintainer:** Give each fetch its own timeout — e.g. `AbortSignal.any([controller.signal, AbortSignal.timeout(5000)])` per request — or re-arm `timeoutId` before each fetch, so a healthy-but-large project is not falsely reported as disconnected.

### M2: setInterval polling can overlap and starve under load

**File:** `main.js:85-87`, `main.js:132-133`
**Classification:** 🆕 New

`initPolling` starts a fixed `setInterval` (interval min is 100 ms). If one cycle outruns the interval, the next tick calls `checkConnection`, which aborts the still-in-flight controller (`abort('superseded')`). On a slow or large project no cycle ever completes, so `track_notes` never updates while the abort path returns silently — the operator gets no signal that data has gone stale.

**Fix for the maintainer:** Switch to a self-scheduling `setTimeout` that arms the next poll from `checkConnection`'s `finally` block only after the current cycle resolves. This guarantees non-overlapping cycles and removes the need to abort the previous request on every tick. Pairs with M1.

### M3: fetchProjectFps silently substitutes 25 fps on failure

**File:** `main.js:100`, `main.js:105-107`
**Classification:** 🆕 New

A non-OK response (`return 25`) and any JSON/`asDouble` parse failure (`catch { return 25 }`) both fall back to 25 fps with no log and no status change. If the disguise API contract changes or returns an error body, every timecode is silently computed at 25 fps with no diagnostic for the operator or the maintainer. The nested `JSON.parse(data.returnValue).asDouble` (`main.js:103`) is also fragile — it assumes `returnValue` is always a JSON string of a specific shape.

**Fix for the maintainer:** Log at `debug`/`warn` when falling back (include the response status or parse error), and defensively handle the case where `returnValue` is already an object or `asDouble` is missing/non-finite. Status can stay Ok (tracks may still load), but the fallback should not be invisible.

### M4: Fire-and-forget checkConnection calls have no catch

**File:** `main.js:83`, `main.js:85-87`
**Classification:** 🆕 New

`checkConnection()` is an `async` method invoked without `await` and without `.catch()` (both the initial call and the interval callback). It currently has an exhaustive internal `try/catch/finally`, so in practice it never rejects — but the guarantee depends on that staying true. Anything thrown outside the `try` (e.g. `new AbortController()` / `setTimeout` setup at `main.js:135-137`) would become an unhandled promise rejection.

**Fix for the maintainer:** Attach `.catch((e) => this.log('error', e.message))` to both invocations so no future edit can produce an unhandled rejection.

### M5: Track entries uid and name are used unvalidated

**File:** `main.js:147-152`, `main.js:154`, `main.js:192`
**Classification:** 🆕 New

`trackData.result || []` guards a missing `result`, but the loop then reads `track.uid` (built into the annotations URL) and `track.name` (used as the notes-map key) without checking them. A track missing `uid` produces `...?uid=undefined`; a track missing `name` produces an `undefined` map key. `await trackRes.json()` can also throw on a non-JSON body — it is caught by the outer handler, but that conflates a malformed payload with a genuine connection drop.

**Fix for the maintainer:** Skip tracks lacking a truthy `uid`/`name`, and parse the `/tracks` body defensively so a malformed payload is distinguishable from a disconnect.

---

## 🟢 Low

### L1: secondsToTimecode has no guard for zero or undefined fps

**File:** `main.js:110-119`
**Classification:** 🆕 New

If `this.projectFps` is ever `0` or `undefined`, the modulo/division produce `NaN`/`Infinity` and the timecode keys become garbage. The current code path always assigns a number, so this is defensive only.

**Fix for the maintainer:** Add `if (!fps || fps <= 0) fps = 25` (or `Math.max(1, Math.round(fps))`) at the top of `secondsToTimecode`. Complements H1/H2.

### L2: An abort during the fps fetch is masked as fps 25

**File:** `main.js:101-107`
**Classification:** 🆕 New

If the controller aborts (timeout/supersede) while reading the fps response body, the `AbortError` is swallowed by the local `catch` and returned as `25` rather than propagating. It is benign today — the subsequent `/tracks` fetch on the same aborted signal then fails and correctly sets Disconnected — but the abort is briefly masked as a valid value.

**Fix for the maintainer:** Re-throw when `signal.aborted` (or `e.name === 'AbortError'`) inside the catch so aborts are never treated as a real fps.

### L3: Feedback lookup is exact-string-match only and fails silently

**File:** `feedbacks.js:34`
**Classification:** 🆕 New

`trackNotes[track][cue]` requires the operator to type the track name and cue/timecode exactly as disguise reports them (case, spacing, `CUE 2.1` form, zero-padded `00:00:01:15`). Any mismatch returns `{}` with no indication that the key simply was not found — which compounds H1/H2, since the timecode format depends on the (possibly wrong) fps.

**Fix for the maintainer:** Consider trimmed/case-insensitive matching, and keep the exact expected formats documented in the option labels (already partly done in the feedback `description`).

### L4: Feedback awaits the synchronous getVariableValue

**File:** `feedbacks.js:25`
**Classification:** 🆕 New

`await self.getVariableValue('track_notes')` awaits a non-Promise — the v1 SDK signature is `getVariableValue(variableId): CompanionVariableValue | undefined` (synchronous). The `await` is harmless but misleading and suggests the API was assumed to be async.

**Fix for the maintainer:** Drop the `await`.

### L5: Connecting status is not recorded in lastStatus

**File:** `main.js:79`, `main.js:209-211`, `main.js:220-221`
**Classification:** 🆕 New

`initPolling` sets `lastStatus = null` then `updateStatus(Connecting)` without recording `Connecting` in `lastStatus`. The Ok/Disconnected de-dup still works, but the dedup is only uniform by coincidence — `Connecting` transitions are not tracked.

**Fix for the maintainer:** Record every applied status in `lastStatus` (including `Connecting`) so the de-dup logic is uniform and intentional.

---

## 💡 Nice to Have

### N1: track_notes exposes a raw JSON blob as a user variable

**File:** `variables.js:2-7`, `main.js:203-205`
**Classification:** 🆕 New

The single exposed variable is set to `JSON.stringify(trackNotesMap)` — the whole nested project map as one string. Dragging `$(disguise-track-notes:track_notes)` onto a button shows raw JSON, the value grows unbounded with project size, and the feedback must `JSON.parse` it on every `checkFeedbacks`. It functions correctly (defined before values are set, valid id/name), but it is a design smell. HELP.md does document the `jsonpath()` path, which mitigates the usability concern.

**Fix for the maintainer:** Consider keeping the map as internal instance state and exposing resolved per-track/per-cue dynamic variables, which would also remove the repeated parse cost in the feedback callback.

### N2: runEntrypoint is passed an inline empty array

**File:** `main.js:240`
**Classification:** 🆕 New

`runEntrypoint(ModuleInstance, [])` works and an empty upgrade-script list is correct for a first release. As a convention, a named `const UpgradeScripts = []` (ideally in `upgrades.js`) gives future migrations a home and matches the template.

**Fix for the maintainer:** Declare and pass a named `UpgradeScripts` array.

### N3: Port is not validated in initPolling

**File:** `main.js:74-77`
**Classification:** 🆕 New

`initPolling` only checks `config.host` before building URLs. The port config field constrains 1–65535 with a default, so the UI normally enforces a value, but a blank/legacy config could yield `http://host:undefined/...`.

**Fix for the maintainer:** Add `if (!this.config.port)` alongside the host check and set `BadConfig`.

### N4: Feedback options lack variable support and discovery is manual

**File:** `feedbacks.js:9-22`, `main.js:42-49`
**Classification:** 🆕 New

The `track`/`cue` textinputs could set `useVariables: true` so operators can drive them from variables. If disguise devices advertise via mDNS, a `bonjour-device` config field (v1.7+) would improve setup UX over the manual host field. Both are optional polish.

**Fix for the maintainer:** Consider `useVariables: true` on the feedback options and a Bonjour config field if the device supports mDNS.
