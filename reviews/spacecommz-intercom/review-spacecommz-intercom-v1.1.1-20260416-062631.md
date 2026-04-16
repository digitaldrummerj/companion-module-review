# Follow-up Review: spacecommz-intercom @ v1.1.1

| Field | Value |
|-------|-------|
| **Module** | `companion-module-spacecommz-intercom` |
| **Tag** | `v1.1.1` |
| **Commit** | `d873eef` |
| **Previous reviewed version** | `v1.1.0` |
| **Reviewed** | 2026-04-16 |
| **Reviewer** | Mal (Lead) |
| **API version** | v1.x (`@companion-module/base ^1.8.0`) |
| **Module type** | TypeScript / CommonJS output |
| **Release diff** | `git diff v1.1.0 v1.1.1 -- .` → `.gitattributes`, `.husky/pre-commit`, `.yarn/install-state.gz`, `.yarnrc.yml`, `LICENSE`, `companion/HELP.md`, `eslint.config.mjs`, `package.json`, `src/actions.ts`, `src/feedbacks.ts`, `src/main.ts`, `src/preset.ts`, `src/upgrades.ts`, `yarn.lock` |
| **Validation** | ✅ `corepack yarn install --immutable` · ❌ `corepack yarn lint` · ✅ `corepack yarn package` |

---

## Verdict

### ❌ CHANGES REQUIRED — v1.1.1 fixes most of the prior review, but one critical template blocker remains and the new lint path does not pass

This follow-up stayed constrained to the `v1.1.0` → `v1.1.1` release delta plus the prior `spacecommz-intercom` review. The patch closes 11 prior findings, including the server teardown, upgrade script, status-reset, and socket error-handling problems, but `package.json` still does not match the TypeScript template because the required `"type": "module"` field is still missing. The new lint tooling added in this release also fails in a clean checkout, so the release is improved but still not ready.

---

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 0 | 1 | 1 |
| 🟠 High | 0 | 0 | 0 |
| 🟡 Medium | 1 | 3 | 4 |
| 🟢 Low | 0 | 7 | 7 |
| 💡 Nice to Have | 0 | 3 | 3 |
| **Total** | **1** | **14** | **15** |

**Blocking:** 1 issue (1 carried-forward critical)  
**Fix complexity:** Medium — the last blocking item is still the template-required ESM package alignment in `package.json`  
**Health delta:** 1 introduced · 14 pre-existing carried forward

---

## Fix Verification (`v1.1.0` review → `v1.1.1`)

### Fixed in v1.1.1

| ID | Prior finding | Severity | Current status |
|----|---------------|----------|----------------|
| C1 | HTTP / Socket.IO server not closed in `destroy()` | 🔴 Critical | ✅ **Fixed** — `src/main.ts:149-156` now closes both `this.io` and `this.http` during teardown. |
| C2 | Missing required template files | 🔴 Critical | ✅ **Fixed** — `.gitattributes`, `.yarnrc.yml`, `LICENSE`, `eslint.config.mjs`, and `.husky/pre-commit` were added. |
| C4 | Missing upgrade script for `listenState` feedback type change | 🔴 Critical | ✅ **Fixed** — `src/upgrades.ts:4-24` now defines a migration for existing `listenState` feedbacks. |
| H1 | `talkState` feedback returned `{}` instead of `false` | 🟠 High | ✅ **Fixed** — `src/feedbacks.ts:35-40` now returns `false` for an out-of-range talk index. |
| H2 | No error handling on HTTP server listen | 🟠 High | ✅ **Fixed** — `src/main.ts:96-103` now handles `EADDRINUSE` and other server errors. |
| H3 | Array out-of-bounds in action callbacks | 🟠 High | ✅ **Fixed** — `src/actions.ts:18-35` now bounds-checks PL indices before emitting. |
| H4 | Array out-of-bounds in feedback callbacks | 🟠 High | ✅ **Fixed** — `src/feedbacks.ts:35-55` now logs out-of-range feedback indices and uses the correct fallback values. |
| M1 | Disconnect handler no longer reset module status | 🟡 Medium | ✅ **Fixed** — `src/main.ts:39-50` now tracks connected clients and returns to `Connecting` when the last client disconnects. |
| M2 | No error handling on Socket.IO event handlers | 🟡 Medium | ✅ **Fixed** — `src/main.ts:52-93` now validates incoming payloads and wraps each handler in `try/catch`. |
| M4 | `console.log` used instead of Companion logging | 🟡 Medium | ✅ **Fixed** — the changed paths now use `this.log(...)` / `self.log(...)` instead of raw console output. |
| M6 | `main` field had a leading slash | 🟡 Medium | ✅ **Fixed** — `package.json:4` is now `dist/main.js`. |

### Carried-forward findings

| ID | Prior finding | Severity | Current status |
|----|---------------|----------|----------------|
| C3 | `package.json` template violations | 🔴 Critical | ❌ **Not fixed** — the release repaired most of the earlier metadata/scripts issues, but `package.json` still lacks the template-required `"type": "module"` field (`package.json:1-56`; template `package.json` still includes it). |
| M3 | `configUpdated()` doesn't restart server when port changes | 🟡 Medium | ❌ **Not fixed** — `src/main.ts:159-161` still only stores the new config and never rebinds the HTTP server. |
| M5 | `.gitignore` deviates from template | 🟡 Medium | ❌ **Not fixed** — `.gitignore:1-8` still carries `/pkg.tgz` and `ReleaseV1.zip`, and still lacks the template's `/.yarn` / `/.vscode` entries. |
| M7 | Missing `$schema` in `manifest.json` | 🟡 Medium | ❌ **Not fixed** — `companion/manifest.json:1-26` still omits the schema reference. |
| L1 | `@companion-module/base` and tools significantly outdated | 🟢 Low | ❌ **Partially fixed, still open** — `@companion-module/tools` was updated to `^2.6.1`, but `@companion-module/base` is still `^1.8.0`, and `corepack yarn install --immutable` still warns that it does not satisfy the tools peer range. |
| L2 | `pls` typed as `any` with no interface | 🟢 Low | ❌ **Not fixed** — `src/main.ts:18` still uses `pls: any = []`. |
| L3 | `checkFeedbacks()` references commented-out `soloState` feedback | 🟢 Low | ❌ **Not fixed** — `src/main.ts:61` still calls `this.checkFeedbacks('soloState', 'talkState', 'listenState')` even though `soloState` remains commented out. |
| L4 | Manifest `runtime.type` is `node18` | 🟢 Low | ❌ **Not fixed** — `companion/manifest.json:16-20` and `tsconfig.build.json:2` still target the node18 toolchain rather than the node22 template baseline. |
| L5 | `@ts-ignore` comments masking real type issues | 🟢 Low | ❌ **Not fixed** — the release removed some suppressions, but they still remain in `src/actions.ts`, `src/preset.ts`, and `src/variables.ts`. |
| L6 | Commented-out code left in source | 🟢 Low | ❌ **Not fixed** — the commented `soloPlByIndex` action and `soloState` feedback are still present in `src/actions.ts` and `src/feedbacks.ts`. |
| L7 | Mute preset overwritten on every loop iteration | 🟢 Low | ❌ **Not fixed** — `src/preset.ts:78-111` still defines `presets['mute']` inside the `self.pls.forEach(...)` loop. |
| N1 | Manifest version should be `0.0.0` | 💡 Nice to Have | ❌ **Not fixed** — source `companion/manifest.json:6` still hardcodes `1.1.0`. `yarn package` does stamp `pkg/companion/manifest.json` to `1.1.1`, so I am keeping this as the same non-blocking advisory. |
| N2 | Unsafe CORS configuration | 💡 Nice to Have | ❌ **Not fixed** — `src/main.ts:29-34` still allows `origin: '*'` with no inline rationale. |
| N3 | Loose `tsconfig.json` strictness settings | 💡 Nice to Have | ❌ **Not fixed** — the TypeScript config remains unchanged from the prior review, so this advisory still stands. |

---

## New issues introduced in v1.1.1

### M8: New lint path fails in a clean checkout

**Classification:** 🆕 NEW  
**Severity:** 🟡 Medium  
**Files:** `package.json`, `src/actions.ts`, `src/feedbacks.ts`, `src/preset.ts`, `src/upgrades.ts`, `src/variables.ts`

`v1.1.1` adds the missing ESLint tooling and a proper `lint` script, but the new validation path is not shippable yet: `corepack yarn lint` currently fails with 11 errors. The release still contains banned `@ts-ignore` directives, several `prefer-const` violations, and an untyped upgrade function signature, so the newly added lint script does not actually pass on the submitted code.

**Why this matters:** this is a release-delta issue, not just an old advisory. The module did not have a lint entrypoint in `v1.1.0`; `v1.1.1` introduces one, and it currently reports a broken validation state in a clean environment.

**Required fix:** make `corepack yarn lint` pass cleanly for the submitted release.

---

## 🧪 Validation

- ✅ `corepack yarn install --immutable`
- ❌ `corepack yarn lint` — fails with 11 ESLint errors across `src/actions.ts`, `src/feedbacks.ts`, `src/preset.ts`, `src/upgrades.ts`, and `src/variables.ts`
- ✅ `corepack yarn package` — produced `spacecommz-intercom-1.1.1.tgz`
- ✅ No `package-lock.json` present in the module root
- ✅ Built `pkg/companion/manifest.json` reports `version: "1.1.1"` and `runtime.apiVersion: "1.8.0"`
- ⚠️ Immutable install still emits the existing peer warning because `@companion-module/base ^1.8.0` is behind the range requested by `@companion-module/tools`

---

## ✅ Still Solid

- This is a real corrective follow-up, not a no-op resubmission: 11 prior findings are closed.
- The lifecycle fixes landed in the right places: server teardown, connection-status reset, and Socket.IO payload validation all improved materially.
- The upgrade script now exists, the package builds cleanly, and the built manifest is version-correct for `v1.1.1`.
- `package-lock.json` is still absent, and the module remains constrained to the expected `src/` layout.

---

*Follow-up review conducted by Mal only, constrained to the `v1.1.0` → `v1.1.1` release delta and prior review context.*
