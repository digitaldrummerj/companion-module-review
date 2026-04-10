# Mal — Architecture & SDK Review
**Module:** `companion-module-noctavoxfilms-tallycomm`
**Version:** v1.0.0 (first release — all findings classified 🆕 NEW)
**Reviewed by:** Mal (Lead)
**Date:** 2026-04-09

---

## Verdict: ❌ CHANGES REQUIRED

Five structural violations block this release. The module works logically but does not meet the layout and package standards required to ship on the Companion module store.

---

## 🔴 Critical

### C1 — Source code not in `src/` directory
**File:** `main.js` (module root) — **Issue:** All source code lives at the module root. Per team decision 2026-04-02 and the companion-module-template-js reference, source files must live under `src/`. The module must be restructured so the entry point is `src/main.js`.

### C2 — `package.json` `main` field points to root
**File:** `package.json`, line 6 — **Issue:** `"main": "main.js"` must be `"main": "src/main.js"` once source is moved to `src/`. Incorrect `main` means Companion's module loader will look in the wrong place.

### C3 — Manifest entrypoint points to root
**File:** `companion/manifest.json`, line 16 — **Issue:** `"entrypoint": "../main.js"` must be `"entrypoint": "../src/main.js"`. This must change alongside the source move.

### C4 — No `scripts` field in `package.json`
**File:** `package.json` — **Issue:** No `scripts` field at all. Without a `package` script (typically wrapping `companion-module-build`), `yarn package` cannot run and the module cannot be built for distribution. This is a hard blocker for the Companion store pipeline.

### C5 — `UpgradeScripts` not exported
**File:** `main.js`, line 279 — **Issue:** `runEntrypoint(TallyCommInstance, [])` passes an anonymous inline array. Per review criteria, `UpgradeScripts` must be defined as a named export (e.g., `module.exports = { UpgradeScripts }`) even if it is empty. This is a charter requirement for all v1.x modules.

---

## 🟠 High

### H1 — No `packageManager` field
**File:** `package.json` — **Issue:** Missing `"packageManager"` field. Must specify the Yarn version in use (e.g., `"packageManager": "yarn@4.x.x"`). Required by the Companion module build pipeline.

### H2 — No `engines` field
**File:** `package.json` — **Issue:** Missing `"engines"` field. The module uses `fetch` (global) and `AbortSignal.timeout()` — both require Node 18+. The engines field must declare the minimum Node version (e.g., `"node": ">=18"`).

### H3 — No lockfile present
**File:** module root — **Issue:** Neither `yarn.lock` nor `package-lock.json` exists. Per team decision 2026-04-01, only `yarn.lock` is permitted. Without a lockfile, dependency resolution is non-deterministic and reproducible builds are not guaranteed.

### H4 — No `devDependencies` in `package.json`
**File:** `package.json` — **Issue:** No `devDependencies` at all. At minimum, `@companion-module/tools` is needed to provide the `companion-module-build` packaging command referenced by `scripts.package`. Without it, the scripts field (once added) will have nothing to call.

### H5 — `init()` sets `InstanceStatus.Ok` before connection check
**File:** `main.js`, line 20 — **Issue:** Status is set to `Ok` immediately on `init()`, before `checkConnection()` has run. Companion shows a green "OK" state even if the server is unreachable. Should set `InstanceStatus.Connecting` first, then update to `Ok` or `ConnectionFailure` inside `checkConnection()`'s resolution callbacks.

---

## 🟡 Medium

### M1 — `destroy()` does not clean up in-flight requests
**File:** `main.js`, lines 29–31 — **Issue:** `destroy()` only logs a message. Any in-flight `fetch()` calls (from `sendTally` or `checkConnection`) will continue running against a destroyed instance. Should use an `AbortController` to cancel pending requests on teardown, and reset `_isConnected`.

### M2 — `checkConnection()` sends a live tally payload as a ping
**File:** `main.js`, lines 257–275 — **Issue:** The health check sends `{ camera: 0, bus: 'ping', room: 'companion-check' }` to the `/api/tally` endpoint. This is a live API call using sentinel values. If the server processes `camera: 0` or doesn't recognise `bus: 'ping'`, this could produce side effects or unexpected state on the TallyComm server. A dedicated status/health endpoint (`GET /api/status` or similar) would be safer — or at minimum document that the server ignores `camera: 0 / bus: ping`.

### M3 — Config UI labels are in Spanish
**File:** `main.js`, lines 46, 53, 60, 61 — **Issue:** `getConfigFields()` uses Spanish strings: `'Servidor'`, `'Sala / Evento'`, tooltip text, placeholder, and the static-text description. Companion module store modules are expected to use English for UI labels so all users can configure the module without language barrier.

---

## 🟢 Low

### L1 — `camChoices` array built twice
**File:** `main.js`, lines 72–75 and 171–174 — **Issue:** The same camera choices loop is duplicated in `initActions()` and `initFeedbacks()`. Extract to a helper (e.g., `getCamChoices()`) or compute it once in the constructor.

### L2 — `MAX_CAMS` hardcoded at 6
**File:** `main.js`, line 4 — **Issue:** Six cameras is a low ceiling for professional broadcast setups (8–12 cameras common). Not a blocker but limits usefulness out of the box.

### L3 — Manifest `name` field looks like an ID
**File:** `companion/manifest.json`, line 3 — **Issue:** `"name": "noctavoxfilms-tallycomm"` reads as a module identifier, not a display name. The manifest `name` field is shown to users in Companion. A human-readable value like `"TallyComm"` or `"Noctavox Films TallyComm"` would be appropriate here (distinct from the `id` and `shortname` fields).

---

## 💡 Nice to Have

### N1 — No `prettier` config
**File:** `package.json` — **Issue:** No prettier or code formatting config present. Companion template modules include a `prettier` config in `package.json`. Not a blocker, but adds consistency with the template baseline.

### N2 — `connected` variable uses freeform strings
**File:** `main.js`, lines 225–226 — **Issue:** Variable `connected` emits `'online'` / `'offline'`. These are arbitrary strings. Documenting this in README (already done — good) is fine, but a numeric `1`/`0` or standardized value would be more portable for triggers.

---

## 🔮 Next Release

### R1 — No reconnect polling
The module checks connection once on `init()` and again on `configUpdated()` but never re-attempts after failure. A periodic health check (e.g., every 30s when `_isConnected === false`) would allow the module to recover automatically if the TallyComm server restarts.

### R2 — Camera count should be user-configurable
`MAX_CAMS` is a compile-time constant. Moving it to `getConfigFields()` (e.g., a number input with min=1, max=32) would let operators configure the module for their rig without code changes.

---

## ✅ What's Solid

- ✅ `runEntrypoint(TallyCommInstance, [])` called correctly at the bottom of the file (line 279)
- ✅ All four required lifecycle methods implemented: `init()`, `destroy()`, `configUpdated()`, `getConfigFields()`
- ✅ `set_pgm_auto` / `set_pvw_auto` with automatic clear-previous is excellent UX — exactly what switcher trigger workflows need
- ✅ `AbortSignal.timeout(5000)` used correctly on all fetch calls — no hanging requests
- ✅ `Promise.all()` in `clear_all` is the right pattern for concurrent tally sends
- ✅ Feedback definitions are clean: boolean type, proper `defaultStyle` colors (red PGM, green PVW)
- ✅ Variable definitions sensible: `pgm`, `pvw`, `room`, `connected` all useful for triggers
- ✅ Version parity: `package.json` (1.0.0) matches `manifest.json` (1.0.0) — ✅
- ✅ README is excellent — clear action table, real ATEM trigger example, Variables table with `$(tallycomm:x)` syntax
- ✅ `@companion-module/base ^1.12.1` dependency is correct for v1.x SDK
- ✅ MIT license consistent across `package.json` and `manifest.json`
