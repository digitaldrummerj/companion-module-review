# Review: companion-module-renewedvision-propresenter-api v1.1.1

| | |
|---|---|
| **Module** | renewedvision-propresenter-api |
| **Review tag** | v1.1.1 |
| **Previous tag** | v1.0.5 |
| **Scope** | `tag` (v1.0.5 .. v1.1.1 diff) |
| **Language / API** | TypeScript · @companion-module/base v1.x (~1.10.0) |
| **Protocol** | HTTP + persistent status connection via `renewedvision-propresenter` library (OSC/WebSocket internal to the library) |
| **Build** | ❌ `yarn install --immutable` and `yarn package` fail |
| **Reviewed** | 2026-06-09 |

> **Note on scope & deterministic checks:** This is a `tag`-scope review — code findings come from the `v1.0.5..v1.1.1` diff and are classified 🆕 NEW. The diff is dominated by Prettier reformatting; the substantive changes are concentrated in `src/main.ts` (async slide-count tracking, a new `active_presentation_slides_remaining` variable, `systemTimeUpdated` status-gating, rate-limited `initFeedbacks()`), plus a `midi_base_page` config field and a new `code-style.yaml` workflow. The 🔴 Critical template/build/toolchain items (C1–C3) are **full-module deterministic checks** — most reflect module state that predates v1.1.1, but they block this release because the module no longer installs, builds, or packages against the current Node 22 / Yarn 4 toolchain. A release that can't be packaged can't ship, so they are carried here per review policy.

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 3 | 0 | 3 |
| 🟠 High | 1 | 0 | 1 |
| 🟡 Medium | 3 | 0 | 3 |
| 🟢 Low | 2 | 0 | 2 |
| **Total** | **9** | **0** | **9** |

## Verdict: ❌ Changes Required

## 📋 Issues

**Blocking**
- [ ] [C1: Build fails — yarn install --immutable and yarn package both fail](#c1-build-fails-yarn-install-immutable-and-yarn-package-both-fail)
- [ ] [C2: Module not migrated to the current Node 22 / Yarn 4 template](#c2-module-not-migrated-to-the-current-node-22-yarn-4-template)
- [ ] [C3: manifest name does not match id](#c3-manifest-name-does-not-match-id)
- [ ] [H1: activePresentationUpdated is an unguarded async status callback parsing untyped hardware payload](#h1-activepresentationupdated-is-an-unguarded-async-status-callback-parsing-untyped-hardware-payload)

**Non-blocking**
- [ ] [M1: active_presentation_slides_remaining can resolve to NaN](#m1-active_presentation_slides_remaining-can-resolve-to-nan)
- [ ] [M2: systemTimeUpdated gating regresses the time_since_last_status_update watchdog variable](#m2-systemtimeupdated-gating-regresses-the-time_since_last_status_update-watchdog-variable)
- [ ] [M3: Duplicate config field id connection](#m3-duplicate-config-field-id-connection)
- [ ] [L1: MIDI message listener re-registered on every configUpdated without removeAllListeners](#l1-midi-message-listener-re-registered-on-every-configupdated-without-removealllisteners)
- [ ] [L2: MIDI button-press fetch reports error to log only, no InstanceStatus signal](#l2-midi-button-press-fetch-reports-error-to-log-only-no-instancestatus-signal)

---

## 🔴 Critical

### C1: Build fails — yarn install --immutable and yarn package both fail

**File:** `package.json` · **Classification:** 🆕 NEW (blocks this release)

The deterministic build step fails at both `yarn install --immutable` (`BUILD-INSTALL`) and `yarn package` (`BUILD-PACKAGE`). Root cause confirmed by running install directly:

```
error renewedvision-propresenter-api@1.1.1: The engine "node" is incompatible with this module.
Expected version "^18.12". Got "22.21.1"
error Found incompatible module.
```

`engines.node` is pinned to `^18.12`, which rejects the Node 22 runtime the current Companion build toolchain uses. There is also no `packageManager` field (see C2), so Corepack falls back to Yarn 1 classic instead of the template's Yarn 4 — `--immutable` and the `package` script behave differently from CI. Net result: the module cannot be installed or packaged as-is.

**Fix (maintainer):** bump `engines.node` to the template value (`^22.x` — the template uses Node 22), add the `packageManager` field (C2), and re-run `yarn install --immutable && yarn package` in a clean checkout to confirm it builds.

### C2: Module not migrated to the current Node 22 / Yarn 4 template

**File:** `package.json`, `companion/manifest.json`, `tsconfig.build.json`, `.gitignore`, `.prettierignore`, and missing toolchain files · **Classification:** 🆕 NEW (blocks this release)

The module still tracks an older template. The deterministic template comparison reports the following Critical items (carried verbatim):

| ID | File | Message |
|----|------|---------|
| FILE-MISSING | `.gitattributes` | Required file is missing |
| FILE-MISSING | `.yarnrc.yml` | Required file is missing |
| FILE-MISSING | `eslint.config.mjs` | Required file is missing |
| FILE-MISSING | `.husky/pre-commit` | Required file is missing |
| CONFIG-DIFF | `.gitignore` | Missing template entries: `/*.tgz`, `/dist`, `DEBUG-*`, `/.yarn`, `/.vscode` |
| CONFIG-DIFF | `.prettierignore` | Differs from template (line 3: found `dist`, template `<missing>`) |
| CONFIG-DIFF | `tsconfig.build.json` | Extends `…/node18/recommended`; template extends `…/node22/recommended` |
| PKG-FIELD | `package.json` | Missing required field `packageManager` (present in template) |
| PKG-SCRIPT | `package.json` | Missing required script `postinstall` |
| PKG-SCRIPT | `package.json` | Missing required script `package` |
| PKG-DEVDEP | `package.json` | Missing devDependency `eslint` |
| PKG-DEVDEP | `package.json` | Missing devDependency `prettier` |
| PKG-DEVDEP | `package.json` | Missing devDependency `typescript-eslint` |
| MAN-RUNTIME | `companion/manifest.json` | `runtime.type` is `node18`, should be `node22` |

A related lint failure (`LINT`, High) is downstream of this gap: `yarn lint` reports problems because the ESLint/Prettier toolchain the template installs (`eslint`, `prettier`, `typescript-eslint`, `eslint.config.mjs`) is not present. The module instead ships an ad-hoc `lint:raw`/`format` setup.

**Fix (maintainer):** re-base on the current `companion-module-template-ts` (v1): add `.gitattributes`, `.yarnrc.yml`, `eslint.config.mjs`, `.husky/pre-commit`; add the `packageManager` field and the `postinstall`/`package` scripts; add the `eslint`/`prettier`/`typescript-eslint` devDeps; switch `tsconfig.build.json` to `node22/recommended`; set `runtime.type` to `node22`; and update `.gitignore`/`.prettierignore` to match the template. Then re-run `yarn lint` clean.

### C3: manifest name does not match id

**File:** `companion/manifest.json:2-3` · **Classification:** 🆕 NEW

The manifest `id` is `renewedvision-propresenter-api` but `name` (and `shortname`) is `Propresenter-API` (`MAN-IDNAME`). Companion expects the manifest `name` to match the `id`. This is unchanged in v1.1.1 (the repository/bugs URLs were corrected to the `-api` repo, but `name`/`shortname` were left as `Propresenter-API`).

**Fix (maintainer):** set `name` to `renewedvision-propresenter-api` to match `id`. Keep a human-friendly product label in `shortname`/`description` if desired, but `name` must equal `id`.

---

## 🟠 High

### H1: activePresentationUpdated is an unguarded async status callback parsing untyped hardware payload

**File:** `src/main.ts:643-709` (`activePresentationUpdated`) · **Classification:** 🆕 NEW

This release changed `activePresentationUpdated` from synchronous to `async` and added an `await this.ProPresenter.playlistActiveGet()` network round-trip, with **no `try/catch`** around the body. It is registered as a fire-and-forget status callback (`'presentation/active': this.activePresentationUpdated`), so the library invokes it without awaiting the returned promise. The body then dereferences deeply-nested, untyped fields off live hardware data with no null guards:

- `statusJSONObject.data.presentation.arrangements.find(...)` — `arrangements` is absent on older ProPresenter (the code's own comments note arrangement info "was not added until ~version 21");
- `statusJSONObject.data.presentation.groups` iterated via `for…of`, plus `currentArrangement.groups.length` and `group.slides.length`;
- `activePlaylistResponse.data.presentation.playlist_item.presentation_info.arrangement_uuid`.

If any of these is `undefined` (older Pro, a presentation type that omits the field, or the awaited `playlistActiveGet()` rejecting), the throw becomes an **unhandled promise rejection** that can destabilize/crash the instance — or, if the library does await it, the error is silently swallowed, `active_presentation_slides_count` is left stale, and no `InstanceStatus` is updated. Payload-shape variation across ProPresenter versions/platforms is expected, so these missing fields are a realistic runtime condition rather than an edge case.

**Fix (maintainer):** wrap the whole async body in `try { … } catch (e) { this.log('error', 'activePresentationUpdated failed: ' + e) }`, and guard the nested accesses (e.g. `const arrangements = statusJSONObject.data.presentation?.arrangements ?? []`, `const groups = statusJSONObject.data.presentation?.groups ?? []`, check `group?.slides` before reading `.length`). Optionally debounce the new `playlistActiveGet()` round-trip — it now fires on every active-presentation change, a high-frequency event path.

---

## 🟡 Medium

### M1: active_presentation_slides_remaining can resolve to NaN

**File:** `src/main.ts:617` (`presentationSlideIndexUpdate`) · **Classification:** 🆕 NEW

`active_presentation_slides_remaining` is computed as `Math.floor((this.getVariableValue('active_presentation_slides_count') as number) - statusJSONObject.data.presentation_index.index - 1)`. The `active_presentation_slides_count` it depends on is only set later, by the async `activePresentationUpdated` (H1) — and is never set when that path throws or on older ProPresenter versions that omit arrangement/group data. When the count is unset, `getVariableValue` returns `undefined`, `undefined - n - 1` is `NaN`, and the operator sees the literal string `NaN`. There is also an ordering race: `presentation/slide_index` updates can arrive before the async `presentation/active` count finishes.

**Fix (maintainer):** guard the count before subtracting — e.g. `const count = Number(this.getVariableValue('active_presentation_slides_count')); SetVariableValues(this, { active_presentation_slides_remaining: Number.isFinite(count) ? Math.floor(count - index - 1) : '' })`.

### M2: systemTimeUpdated gating regresses the time_since_last_status_update watchdog variable

**File:** `src/main.ts:486-490` (`systemTimeUpdated`); watchdog at `src/main.ts:392` · **Classification:** 🆕 NEW

Previously `systemTimeUpdated` refreshed `this.timeOfLastStatusUpdate = Date.now()` on **every** `timer/system_time` tick (~once per second) and set `InstanceStatus.Ok`. This release gates the whole block behind `if (Date.now() - this.timeOfLastStatusUpdate >= 5000)`, so `timeOfLastStatusUpdate` is now refreshed at most once every 5 seconds even on a perfectly healthy connection. The watchdog variable `time_since_last_status_update` is derived from that same field (`(Date.now() - this.timeOfLastStatusUpdate) / 1000`), so on a healthy link it now sawtooths 0→5 continuously instead of hovering near 0 — degrading the diagnostic operators watch to judge connection health. (Delaying the `Ok` re-assertion so transient errors stay visible ~5s appears intentional; the side effect on the watchdog variable likely is not.)

**Fix (maintainer):** keep updating `this.timeOfLastStatusUpdate = Date.now()` on every system_time tick so the watchdog stays accurate, and gate only the `updateStatus(InstanceStatus.Ok)` call behind a separate timestamp field if the 5-second visibility delay is the intent.

### M3: Duplicate config field id connection

**File:** `src/config.ts:62` and `src/config.ts:134` · **Classification:** 🆕 NEW

This release adds a second `static-text` field with `id: 'connection'` (a `<br>` spacer at line 134), colliding with the existing connection-settings header at line 62. Companion config field IDs must be unique; a duplicate id keys the field's value/state ambiguously and is a latent source of UI bugs.

**Fix (maintainer):** give the new spacer a unique id (e.g. `id: 'spacer1'`).

---

## 🟢 Low

### L1: MIDI message listener re-registered on every configUpdated without removeAllListeners

**File:** `src/main.ts:123` (registration); `src/main.ts:166-169` (`configUpdated`) · **Classification:** 🆕 NEW

`this.midi_input.on('message', …)` is registered every time `configUpdated()` runs, but the port is only `closePort()`ed — the message listener is never removed. After N reconfigs, N handlers are stacked on the same `Input`, so one MIDI note fires N duplicate button-press `fetch()` calls. The `fetch` body was reworked in this release, which is why this sits inside the changed hunk.

**Fix (maintainer):** call `this.midi_input.removeAllListeners('message')` before re-registering (or register the handler once in `init()`). While here, the empty `destroy()` leaves the MIDI port open and the watchdog/poll `setInterval`s running after the instance is deleted — see 🔮 Next Release.

### L2: MIDI button-press fetch reports error to log only, no InstanceStatus signal

**File:** `src/main.ts:149-161` · **Classification:** 🆕 NEW

The MIDI button-press `fetch()` is correctly non-blocking — it has a 2000 ms `AbortSignal.timeout` and a `.catch` handler, and this release upgraded that catch from `debug` to `error` logging (an improvement). It still only logs, with no `InstanceStatus` change. Acceptable for a best-effort local button press; flagged only because it is a catch-and-continue in changed code.

**Fix (maintainer):** none required. Optionally surface repeated failures as a warning status so a misconfigured local API endpoint is visible to the operator.

---

## 🔮 Next Release

These are **pre-existing** issues (present at v1.0.5, outside the v1.1.1 changed hunks) that all three reviewers surfaced. They are **not blocking** for this tag review and are **not counted** in the scorecard — captured here so they aren't lost on a future `module`/`both` pass:

- **Empty `destroy()` leaves timers and the MIDI port live** (`src/main.ts:108`). `destroy()` only logs; it never closes the MIDI port or clears the watchdog/poll `setInterval`s created on each (re)connect, so timers and listeners accumulate after the instance is deleted.
- **`transportLayerCurrent('presentation')` copy/paste** (`src/main.ts:362/376`). The announcement and audio layers both poll `'presentation'`, and all three layers assign `stageScreensResult.data` — likely a copy/paste bug producing wrong per-layer state.
- **`runEntrypoint(ModuleInstance, [])`** passes an inline empty upgrade array instead of importing the `UpgradeScripts` export from `src/upgrades.ts`. No saved-data ID renames ship in this release, so no upgrade script is required now, but the entrypoint should reference the dedicated `upgrades.ts` export so future migrations are wired in.
