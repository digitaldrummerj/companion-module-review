# Review: aimp-audioplayer v1.0.2

| | |
|---|---|
| **Module** | aimp-audioplayer |
| **Version** | v1.0.2 |
| **Scope** | tag (first release — no previous tag, so reviewed as a full `src/` review; all findings new) |
| **Language / API** | JS / @companion-module/base v2 (~2.0.4) |
| **Protocols** | HTTP |
| **Reviewed** | 2026-07-01 |

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 6 | 0 | 6 |
| 🟠 High | 0 | 0 | 0 |
| 🟡 Medium | 6 | 0 | 6 |
| 🟢 Low | 0 | 0 | 0 |

## Verdict: ❌ Changes Required

## 📋 Issues

**Blocking**

- [ ] [C1: manifest runtime.entrypoint points to a non-existent file — module will not load](#c1-manifest-runtimeentrypoint-points-to-a-non-existent-file--module-will-not-load)
- [ ] [C3: manifest id does not match name](#c3-manifest-id-does-not-match-name)
- [ ] [C4: banned/low-value manifest keyword aimp](#c4-bannedlow-value-manifest-keyword-aimp)
- [ ] [C5: package.json repository.url points to the wrong repo](#c5-packagejson-repositoryurl-points-to-the-wrong-repo)
- [ ] [C6: required .gitattributes file is missing](#c6-required-gitattributes-file-is-missing)

**Non-blocking**

- [ ] [M1: no reentrancy guard on _poll — overlapping polls can stack](#m1-no-reentrancy-guard-on-_poll--overlapping-polls-can-stack)
- [ ] [M2: failed track load poisons the cache permanently](#m2-failed-track-load-poisons-the-cache-permanently)
- [ ] [M3: aggressive 80 ms default poll plus full track re-fetch](#m3-aggressive-80-ms-default-poll-plus-full-track-re-fetch)
- [ ] [M5: destroy does not abort in-flight requests or block post-destroy callbacks](#m5-destroy-does-not-abort-in-flight-requests-or-block-post-destroy-callbacks)

## 🔴 Critical

### C1: manifest runtime.entrypoint points to a non-existent file — module will not load

**File:** `companion/manifest.json` (`runtime.entrypoint`)

`runtime.entrypoint` is `../main.js`, which resolves to a `main.js` at the repo root that does not exist (the entry class lives at `src/main.js`). Companion resolves the entrypoint relative to `companion/`, so it will fail to load the module. This is the single most severe issue — the module cannot start as shipped.

**Fix:** Point `runtime.entrypoint` at the real entry file, i.e. `../src/main.js`, and confirm it loads in Companion.

### C3: manifest id does not match name

**File:** `companion/manifest.json`

`id` is `aimp-audioplayer` but `name` is `AIMP Remote Control` (and `shortname` is `aimp-remote`). The template requires the `id` and `name` to be consistent.

**Fix:** Align `id`/`name`/`shortname` with the approved module identity for the Bitfocus listing.

### C4: banned/low-value manifest keyword aimp

**File:** `companion/manifest.json` (`keywords`)

`keywords` contains the banned/low-value keyword `aimp` (the product/vendor name is not a useful search keyword).

**Fix:** Remove `aimp`; use descriptive functional keywords (e.g. `audio`, `player`, `media`).

### C5: package.json repository.url points to the wrong repo

**File:** `package.json` (`repository.url`)

`repository.url` is `git+https://github.com/slv-tech/Companion-Aimp-Module.git`; it must be the Bitfocus fork `git+https://github.com/bitfocus/companion-module-aimp-audioplayer.git`.

**Fix:** Update `repository.url` to the Bitfocus repo.

### C6: required .gitattributes file is missing

**File:** `.gitattributes` (missing)

The template requires a `.gitattributes` file; it is absent.

**Fix:** Add the template `.gitattributes` (enforces LF line endings, etc.).


## 🟡 Medium

### M1: no reentrancy guard on _poll — overlapping polls can stack

**File:** `src/main.js:257-279` (`_startPolling`/`_poll`)

`_startPolling()` uses `setInterval(() => this._poll(), interval)` with an 80 ms default, but `_poll` awaits two HTTP requests (`/player/status`, `/playlists`) plus possible track preloads and has no in-flight guard (unlike `_bootstrapping` and `_tracksRefreshing`). Under latency/packet loss, with a 5 s abort timeout, dozens of poll cycles queue up (up to ~60 = 5000/80), each spawning more concurrent fetches and redundant `setActionDefinitions`/`checkFeedbacks` work.

**Fix:** Add a `_polling` boolean guard (bail if already polling, set/clear in try/finally), or switch to a `setTimeout`-chained loop that schedules the next poll only after the current settles.

### M2: failed track load poisons the cache permanently

**File:** `src/main.js:177-181, 192-197`

On a transient failure, `_loadTracks` sets `this.tracksCache[key] = [{ id: '0', label: '⚠ Failed to load' }]`. Because `_ensureTracksLoaded` returns early whenever `tracksCache[key]` is truthy, the placeholder is treated as valid and the real track list is never retried — the browse dropdown and `playlist_track_next/prev` stay stuck on the fake `id:'0'` entry until the connection drops (clearing the cache) or the playlist set changes.

**Fix:** Do not populate `tracksCache` with a sentinel on failure (leave it unset so `_ensureTracksLoaded` retries), or track a separate "failed" flag that still permits retry.

### M3: aggressive 80 ms default poll plus full track re-fetch

**File:** `src/config.js:32-39`, `src/main.js:231-246, 386-389`

Default `pollInterval` is 80 ms (~25 polls/s, 2 requests each ≈ 50 req/s). Every 5th poll (`_pollCount % 5`) calls `_refreshAllTracks`, which issues a separate `/tracks?limit=500` request per playlist — roughly N+2 requests every ~400 ms against a local media player. `min: 0` also permits pathological values (e.g. 1 ms). The config help text calls 80 ms "optimal," encouraging the heaviest setting. Combined with M1, this is the root of the request pile-up risk.

**Fix:** Raise the default (e.g. 250–500 ms), enforce a sane floor, and/or decouple the full track refresh onto a slower independent timer; soften the "optimal" wording.

### M5: destroy does not abort in-flight requests or block post-destroy callbacks

**File:** `src/main.js:58-60` (`destroy`), continuations at `:336-343, 375-377`

`destroy()` only stops the poll timer; it does not abort in-flight requests or prevent post-destroy callbacks. Pending `_request` promises and their `.then` chains (`_ensureTracksLoaded(...).then(() => setActionDefinitions/updateVariables/checkFeedbacks)`) can resolve after the instance is torn down and operate on a destroyed instance.

**Fix:** Set `this._destroyed = true` in `destroy()`, retain/abort active `AbortController`s, and early-return from poll/preload continuations when destroyed.