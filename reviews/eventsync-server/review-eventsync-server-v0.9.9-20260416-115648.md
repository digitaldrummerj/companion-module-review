# Follow-up Review: eventsync-server @ v0.9.9

| Field | Value |
|-------|-------|
| **Module** | `companion-module-eventsync-server` |
| **Tag** | `v0.9.9` |
| **Commit** | `15171c7` |
| **Previous reviewed version** | `v0.9.8` |
| **Reviewed** | 2026-04-16 |
| **Reviewer** | Mal (Lead) |
| **API version** | v1.14 (`@companion-module/base ~1.14.1`) |
| **Module type** | TypeScript / ESM |
| **Release diff** | `git diff v0.9.8 v0.9.9 -- .` → template scaffolding, package/manifest metadata, WebSocket lifecycle fixes, action guards, `tsconfig*.json`, and `yarn.lock` |
| **Validation** | ⚠️ `yarn install --immutable` (passes; `YN0086` peer warning only) · ✅ `yarn lint` · ✅ `yarn build` · ✅ `yarn package` |

---

## Verdict

### ✅ APPROVED — the actual `v0.9.9` tag fixes the previously blocking follow-up items; only one pre-existing advisory remains

This corrected follow-up supersedes the mistaken same-tag `v0.9.8` re-review. The real `v0.9.9` delta is substantial and lands the expected template, dependency, and WebSocket lifecycle repairs. I did not find any new release-blocking regressions in `v0.9.9`.

---

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 0 | 0 | 0 |
| 🟠 High | 0 | 0 | 0 |
| 🟡 Medium | 0 | 0 | 0 |
| 🟢 Low | 0 | 0 | 0 |
| 💡 Nice to Have | 0 | 1 | 1 |
| **Total** | **0** | **1** | **1** |

**Blocking:** 0 issues  
**Fix complexity:** Done in tag  
**Health delta:** 0 introduced · 1 pre-existing advisory carried forward

---

## Fix Verification (v0.9.8 → v0.9.9)

**24 of 25 carried-forward findings from the mistaken `v0.9.8` follow-up are fixed in `v0.9.9`, and the one item that had already been closed on re-check stays closed.**

### Already closed before tag correction

| ID | Prior finding | Status | Notes |
|----|---------------|--------|-------|
| M3 | Remove banned keywords from `package.json` | ✅ Still closed | The prior re-check was correct: this was not a valid release blocker, and `v0.9.9` does not reintroduce it. |

### Fixed in `v0.9.9`

| IDs | Prior findings | Resolution |
|-----|----------------|------------|
| C1-C6 | Missing `.gitattributes`, `.prettierignore`, `.yarnrc.yml`, `.husky/pre-commit`, `tsconfig.build.json`, and template `.gitignore` alignment | ✅ Fixed — the tag now includes the required root files and template-aligned configs: `.gitattributes:1`, `.prettierignore:1-2`, `.yarnrc.yml:1`, `.husky/pre-commit:1`, `.gitignore:1-8`, `tsconfig.build.json:1-14`, `tsconfig.json:1-8`. |
| C7-C13 | Missing `engines`, missing `packageManager`, wrong `prettier`, wrong repo URLs, missing template scripts, and missing template dev dependencies | ✅ Fixed — `package.json:6-55` now matches the Yarn 4 / Companion template expectations, upgrades dependencies, restores `lint-staged`, and points both package + manifest metadata at `bitfocus/companion-module-eventsync-server`; see `package.json:6-55` and `companion/manifest.json:6-9`. |
| H1-H2 | WebSocket listeners not removed on disconnect; auth failure reconnect loop | ✅ Fixed — `src/connection.ts:89-101` now removes listeners before closing, and `src/connection.ts:118-142` uses `disconnect(true)` plus `shouldReconnect` to stop the permanent auth-failure retry loop. |
| H3-H5 | Outdated `@companion-module/base`, outdated `@companion-module/tools`, missing `lint-staged` configuration | ✅ Fixed — `package.json:26-55` now uses `@companion-module/base ~1.14.1`, `@companion-module/tools ^2.7.1`, and includes the required `lint-staged` block. |
| M1 | `manifest.json` version should be `0.0.0` | ✅ Fixed — `companion/manifest.json:6` is now `0.0.0`. |
| M2 | `send()` on a closed WebSocket silently fails | ✅ Fixed — `src/connection.ts:104-109` now logs a warning instead of failing silently. |
| L1 | Ping interval may accumulate | ✅ Fixed — `src/connection.ts:145-150` now returns early if a ping timer already exists. |
| L2 | `onStateUpdate()` overwrites `serverStatus` from the server | ✅ Fixed — `src/main.ts:56-61` and `src/main.ts:65-81` now preserve the server-reported status and expose connection state separately through `connection_status` in `src/variables.ts:28-88`. |
| L3 | Empty dropdown defaults can cause invalid action options | ✅ Fixed — `src/actions.ts:10-25` adds `resolveChoice(...)`, and the affected stack/module/cue actions now validate stale or empty dropdown values before sending. |
| L4 | No timeout on WebSocket connection attempt | ✅ Fixed — `src/connection.ts:8-42` adds a 10-second connection timeout and cleanup path. |

### Still carried forward

| ID | Prior finding | Severity | Current status |
|----|---------------|----------|----------------|
| N1 | Consider reconnect retry improvements (backoff/jitter) | 💡 Nice to Have | ⚠️ Pre-existing advisory only — `src/connection.ts:136-142` still uses a fixed 5-second retry interval. This is not blocking approval for `v0.9.9`. |

---

## New issues introduced in `v0.9.9`

None. The corrected tag builds, lints, and packages successfully in the reviewed tree, and I did not find any new module-facing regressions relative to `v0.9.8`.

---

## 🧪 Validation

- ⚠️ `yarn install --immutable` — succeeds on the `v0.9.9` tree; Yarn emits `YN0086` peer warnings, but install completes cleanly
- ✅ `yarn lint` — succeeds
- ✅ `yarn build` — succeeds
- ✅ `yarn package` — succeeds and writes `eventsync-server-0.9.9.tgz`
- ℹ️ No `yarn test` script is defined in `package.json`
- ✅ No `package-lock.json` present in the tag root

---

## ✅ Still Solid

- The actual `v0.9.9` submission is a real corrective delta, not the no-op same-tag state captured by the mistaken prior follow-up.
- The template scaffolding, package metadata, and Companion build wiring now match the expected Bitfocus TypeScript module shape.
- The WebSocket teardown, auth-failure handling, timeout handling, and stale-dropdown action validation all landed in the right places.

---

*Corrected follow-up review conducted by Mal only, constrained to the `v0.9.8` → `v0.9.9` release delta and the prior eventsync-server review context.*
