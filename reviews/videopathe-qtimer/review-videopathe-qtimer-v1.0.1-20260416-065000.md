# Follow-up Review: videopathe-qtimer @ v1.0.1

| Field | Value |
|-------|-------|
| **Module** | `companion-module-videopathe-qtimer` |
| **Tag** | `v1.0.1` |
| **Commit** | `a6084a1` |
| **Previous reviewed version** | `v1.0.0` |
| **Reviewed** | 2026-04-16 |
| **Reviewer** | Mal (Lead) |
| **API version** | v1.14 (`@companion-module/base ~1.14.1`) |
| **Module type** | TypeScript / ESM |
| **Release diff** | `git diff v1.0.0 v1.0.1 -- .` → `.github/*`, `.yarn/install-state.gz`, `README.md`, `companion/HELP.md`, `companion/manifest.json`, `eslint.config.mjs`, `package.json`, `src/*.ts`, `tsconfig*.json`, `yarn.lock` |
| **Validation** | ⚠️ `corepack yarn install --immutable` (still emits `YN0086`) · ✅ `corepack yarn build` · ❌ `corepack yarn lint` · ❌ `corepack yarn package` |

---

## Verdict

### ❌ CHANGES REQUIRED — v1.0.1 fixes most runtime issues, but five template blockers remain and the tagged package still reports the old version

This follow-up stays constrained to the `v1.0.0` → `v1.0.1` release delta plus the prior videopathe-qtimer review. The patch materially improves the module: the fetch timeout, WebSocket handshake timeout, abort handling, stale-state reset, rule-id validation, and manifest metadata fixes all landed. But the required template files are still missing, `corepack yarn package` still fails under Yarn PnP, and the new `v1.0.1` tag still ships `package.json` with `"version": "1.0.0"`.

---

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 1 | 5 | 6 |
| 🟠 High | 0 | 0 | 0 |
| 🟡 Medium | 0 | 1 | 1 |
| 🟢 Low | 0 | 0 | 0 |
| **Total** | **1** | **6** | **7** |

**Blocking:** 6 issues (1 new critical, 5 carried-forward critical)  
**Fix complexity:** Medium — restore the missing template files, switch Yarn back to `node-modules`, and bump the release metadata correctly  
**Health delta:** 1 introduced · 6 pre-existing carried forward

---

## Fix Verification (v1.0.0 → v1.0.1)

**14 of 20 prior findings are fixed in this patch.**

### Fixed in v1.0.1

| ID | Prior finding | Severity | Resolution |
|----|---------------|----------|------------|
| C6 | `manifest.json` repository URL uses wrong GitHub org | 🔴 Critical | ✅ **Fixed** — `companion/manifest.json:9` now points to `git+https://github.com/bitfocus/companion-module-videopathe-qtimer.git`. |
| H1 | No HTTP fetch timeout | 🟠 High | ✅ **Fixed** — `src/api.ts:6-50` now wraps requests in an `AbortController` timeout and preserves caller abort signals. |
| H2 | No WebSocket handshake timeout | 🟠 High | ✅ **Fixed** — `src/main.ts:181` now constructs `new WebSocket(wsUrl, { handshakeTimeout: 10000 })`. |
| H3 | `@types/ws` in `dependencies` instead of `devDependencies` | 🟠 High | ✅ **Fixed** — `package.json:29-43` now keeps `@types/ws` in `devDependencies`. |
| M1 | WebSocket `error` event does not update `InstanceStatus` | 🟡 Medium | ✅ **Fixed** — `src/main.ts:212-220` now logs at error level and sets `InstanceStatus.ConnectionFailure`. |
| M2 | In-flight `fetch` calls not cancelled on `destroy()` | 🟡 Medium | ✅ **Fixed** — `src/main.ts:49`, `src/main.ts:87-93`, and `src/main.ts:296-319` add a shared abort controller and pass its signal into the poll requests. |
| M3 | Config change mid-poll clobbers new connection state | 🟡 Medium | ✅ **Fixed** — `src/main.ts:95-110` now aborts the old controller, creates a new one, and rejects stale poll results. |
| M4 | Audio sounds cleared on partial audio-endpoint failure | 🟡 Medium | ✅ **Fixed** — `src/main.ts:325-339` now preserves the previous `audioSounds` list when `/api/audio/settings` fails. |
| M5 | Empty `ruleId` sends malformed URL in audio rule actions | 🟡 Medium | ✅ **Fixed** — `src/actions.ts:462-500` trims and validates `ruleId` before building the URL. |
| M6 | Unsafe `as` cast for WebSocket state payload | 🟡 Medium | ✅ **Fixed** — `src/main.ts:227-233` now rejects `null` and arrays before casting the payload data. |
| M7 | `configUpdated()` does not clear stale state before reconnecting | 🟡 Medium | ✅ **Fixed** — `src/main.ts:99-108` resets `runtimeState`, variables, and feedbacks before reconnecting. |
| M8 | `manifest.json` version should be `0.0.0` | 🟡 Medium | ✅ **Fixed** — `companion/manifest.json:7` is now `0.0.0`. |
| M9 | `InstanceStatus.Disconnected` never used | 🟡 Medium | ✅ **Fixed** — `src/main.ts:164-170` now moves the module back to `Connecting` when a reconnect is scheduled, so the operator no longer sees stale `Ok` status during reconnect. |
| M11 | `package.json` scripts use `yarn` instead of `run` | 🟡 Medium | ✅ **Fixed** — `package.json:22-27` now uses `run build:main` and `run build` in the build/package scripts flagged in the prior review. |

### Carried-forward findings

| ID | Prior finding | Severity | Current status |
|----|---------------|----------|----------------|
| C1 | Missing `.yarnrc.yml` | 🔴 Critical | ❌ **Not fixed** — the file is still absent, so Yarn 4 still defaults to PnP and `corepack yarn package` fails with `Yarn PnP (Plug'n'Play) is not supported... add "nodeLinker: node-modules" to your .yarnrc.yml file`. |
| C2 | Missing `.gitignore` | 🔴 Critical | ❌ **Not fixed** — the file is still absent. The tagged delta even adds `.yarn/install-state.gz`, and after install the generated `.pnp.cjs` is picked up by `eslint .`, which is exactly the artifact-spill problem the original finding called out. |
| C3 | Missing `.gitattributes` | 🔴 Critical | ❌ **Not fixed** — the required line-ending normalization file is still missing. |
| C4 | Missing `.husky/pre-commit` hook | 🔴 Critical | ❌ **Not fixed** — `.husky/pre-commit` is still absent, so `lint-staged` is still not wired into commits. |
| C5 | Missing `.prettierignore` | 🔴 Critical | ❌ **Not fixed** — `.prettierignore` is still absent. |
| M10 | Yarn peer dependency warning | 🟡 Medium | ❌ **Not fixed** — `corepack yarn install --immutable` still emits `YN0086: Some peer dependencies are incorrectly met`. |

---

## New issues introduced in v1.0.1

### C7: `package.json` version still reports `1.0.0` in the `v1.0.1` tag

**Classification:** 🆕 NEW  
**Severity:** 🔴 Critical  
**File:** `package.json:3`

The previous reviewed tag (`v1.0.0`) correctly shipped `"version": "1.0.0"`, but the new `v1.0.1` tag still ships the same value. That means the submitted release metadata does not match the tag being reviewed.

**Why this matters:** Companion and downstream tooling will report this build as `1.0.0`, not `1.0.1`. That breaks release traceability and makes it harder to verify which fixes are actually deployed.

**Required fix:** update `package.json` to `"version": "1.0.1"` before cutting the release tag.

---

## 🧪 Validation

- ⚠️ `corepack yarn install --immutable` — succeeds, but still emits the carried-forward `YN0086` peer warning
- ✅ `corepack yarn build` — succeeds in the submitted tag
- ❌ `corepack yarn lint` — after install, Yarn PnP generates `.pnp.cjs`; with no `.gitignore`, the module's `eslint .` path lints that generated file and fails
- ❌ `corepack yarn package` — fails in the submitted tag because Yarn is still running in PnP mode and Companion packaging requires `.yarnrc.yml` with `nodeLinker: node-modules`
- ✅ No `package-lock.json` present in the module root

---

## ✅ Still Solid

- This is a real corrective follow-up, not a no-op resubmission: the main runtime robustness fixes from the first review landed in the right places.
- The module now has proper request timeout handling, handshake timeout handling, abort-on-destroy/config-change behavior, and better reconnect status reporting.
- The manifest-side metadata repairs are real: the repository URL is now correct and the source manifest version is back to `0.0.0`.
- I did not find any new runtime regressions in the reviewed source delta beyond the release metadata / template issues above.

---

*Follow-up review conducted by Mal only, constrained to the `v1.0.0` → `v1.0.1` release delta and prior review context.*
