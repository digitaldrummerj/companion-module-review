# Re-Review: eventsync-server @ v0.9.8

| Field | Value |
|-------|-------|
| **Module** | `companion-module-eventsync-server` |
| **Tag** | `v0.9.8` |
| **Commit** | `041753d` |
| **Previous reviewed version** | `v0.9.8` |
| **Reviewed** | 2026-04-16 |
| **Reviewer** | Mal (Lead) |
| **API version** | v1.x (`@companion-module/base ~1.10.0`) |
| **Module type** | TypeScript / ESM |
| **Release diff** | `git diff v0.9.8 HEAD -- .` → `.github/*` scaffolding + `yarn.lock` only |
| **Validation** | ❌ `yarn install` fails (`@companion-module/base@1.10.0` still rejects Node 22) |

---

## Verdict

### ⚠️ CHANGES REQUIRED

This is a same-tag follow-up. The pending checkout is still `v0.9.8`, and the only post-tag delta is repository metadata (`.github/*`) plus a transitive `yarn.lock` bump. None of the previously reported module blockers were fixed in the submitted release delta, one prior package-keywords finding closes on re-check, and no new module issues were introduced.

---

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 0 | 13 | 13 |
| 🟠 High | 0 | 5 | 5 |
| 🟡 Medium | 0 | 2 | 2 |
| 🟢 Low | 0 | 4 | 4 |
| 💡 Nice to Have | 0 | 1 | 1 |
| **Total** | **0** | **25** | **25** |

**Blocking:** 18 issues (13 carried-forward critical, 5 carried-forward high)  
**Fix complexity:** Medium — still mostly template scaffolding plus the same two WebSocket lifecycle fixes  
**Health delta:** 0 introduced · 25 pre-existing carried forward

---

## Fix Verification (prior v0.9.8 review → current pending checkout)

### Closed on re-check

| ID | Prior finding | Status | Notes |
|----|---------------|--------|-------|
| M3 | Remove banned keywords from `package.json` | ✅ Closed on re-check | Current `manifest.json` keywords are already acceptable (`companion/manifest.json:25`), and Companion template rules do not require removing `package.json` keywords. No release change needed here. |

### Still not fixed — blocking findings

| ID | Prior finding | Status | Current evidence |
|----|---------------|--------|------------------|
| C1 | Missing `.gitattributes` | ❌ Not fixed | File is still absent from the repo root. |
| C2 | Missing `.prettierignore` | ❌ Not fixed | File is still absent from the repo root. |
| C3 | Missing `.yarnrc.yml` | ❌ Not fixed | File is still absent from the repo root. |
| C4 | Missing `tsconfig.build.json`; `tsconfig.json` not template-aligned | ❌ Not fixed | `tsconfig.build.json` is still missing, and `tsconfig.json:1-18` still contains the custom compiler block instead of the template chain. |
| C5 | Missing `.husky/pre-commit` | ❌ Not fixed | `.husky/pre-commit` is still absent. |
| C6 | `.gitignore` does not match template | ❌ Not fixed | `.gitignore:1-26` still contains custom comments/entries (`.idea/`, `.DS_Store`, `.env*`, `yarn-error.log`) and still misses required template entries such as `package-lock.json`, `/pkg`, `/*.tgz`, and `DEBUG-*`. |
| C7 | Missing `engines` field in `package.json` | ❌ Not fixed | `package.json:1-49` still has no `engines` block. |
| C8 | Missing `packageManager` field in `package.json` | ❌ Not fixed | `package.json:1-49` still has no `packageManager` field. |
| C9 | Wrong `prettier` field in `package.json` | ❌ Not fixed | `package.json:42-48` still uses an inline Prettier object instead of `@companion-module/tools/.prettierrc.json`. |
| C10 | Wrong `repository.url` in `package.json` | ❌ Not fixed | `package.json:12-15` still points at `eventsync/companion-module-eventsync` instead of the Bitfocus repo. |
| C11 | Wrong `repository` in `companion/manifest.json` | ❌ Not fixed | `companion/manifest.json:8` still points at `eventsync/companion-module-eventsync`. |
| C12 | Missing required `package.json` scripts | ❌ Not fixed | `package.json:6-10` still only defines `build`, `dev`, `lint`, and `format`; the template `postinstall`, `package`, `build:main`, and `lint:raw` scripts are still missing. |
| C13 | Missing template dev dependencies / lint-staged wiring | ❌ Not fixed | `package.json:33-40` still lacks `husky`, `lint-staged`, and `rimraf`, and there is still no `lint-staged` section anywhere in the file. |
| H1 | WebSocket listeners not removed on disconnect | ❌ Not fixed | `src/connection.ts:67-75` still does `this.ws?.close()` without removing listeners first. |
| H2 | Auth failure still triggers reconnect loop | ❌ Not fixed | `src/connection.ts:49-54` still always schedules reconnect on close, while `src/connection.ts:89-92` still handles `authFailed` via plain `this.disconnect()` with no permanent-stop guard. |
| H3 | `@companion-module/base` is still outdated for Node 22 workflow | ❌ Not fixed | `package.json:29-31` still pins `~1.10.0`; `yarn install` still fails with `The engine "node" is incompatible ... Expected "^18.12". Got "22.16.0"`. |
| H4 | `@companion-module/tools` is still outdated | ❌ Not fixed | `package.json:33-40` still pins `@companion-module/tools` to `^2.6.1`. |
| H5 | Missing `lint-staged` configuration | ❌ Not fixed | `package.json:1-49` still has no `lint-staged` block. |

**Result:** 0 of 18 still-valid blocking findings were fixed in the follow-up delta.

---

## Other carried-forward findings

| ID | Severity | Current status |
|----|----------|----------------|
| M1 | 🟡 Medium | ❌ Not fixed — `companion/manifest.json:6` still carries `0.9.6` instead of the build-managed `0.0.0` / a value matching `package.json:3`. |
| M2 | 🟡 Medium | ❌ Not fixed — `src/connection.ts:77-80` still drops sends silently when the socket is not open. |
| L1 | 🟢 Low | ❌ Not fixed — `src/connection.ts:116-120` still has no guard against duplicate ping timers. |
| L2 | 🟢 Low | ❌ Not fixed — `src/main.ts:68-72` still overwrites the server-reported `serverStatus` with a client-derived online/offline string. |
| L3 | 🟢 Low | ❌ Not fixed — stack dropdown defaults still fall back to `''` in `src/actions.ts:124,140,156,172,188,204,220,316,340` and `src/feedbacks.ts:116,138,161,184`. |
| L4 | 🟢 Low | ❌ Not fixed — `src/connection.ts:21-64` still has no connection-attempt timeout. |
| N1 | 💡 Nice to Have | ❌ Not fixed — reconnect logic is still the same fixed 5-second retry with no backoff or jitter. |

---

## New issues introduced in this follow-up delta

None. The delta after `v0.9.8` is limited to `.github` workflow/issue-template files and a transitive `picomatch` update in `yarn.lock`; it does not introduce any new module-facing review findings.

---

## 🧪 Validation

- ❌ `yarn install` — fails immediately because `@companion-module/base@1.10.0` still declares `engines.node: ^18.12`
- ℹ️ `yarn build` / `yarn package` were not re-run after that failure because the release delta contains no module-code changes and the install blocker is itself one of the carried-forward findings
- ℹ️ No `yarn test` script exists in `package.json`
- ✅ No `package-lock.json` is present

---

## ✅ Still Solid

- The follow-up did not introduce any new source regressions.
- The module still has the expected high-level Companion structure (`src/main.ts`, lifecycle methods, `runEntrypoint(...)`, no `package-lock.json`).
- The remaining problems are the same unresolved template and WebSocket lifecycle issues from the original `v0.9.8` review, not fresh breakage in this resubmission.

---

*Follow-up review constrained to the prior `v0.9.8` review delta only, per request.*
