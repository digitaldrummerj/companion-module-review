# Re-Review: adder-ccs-pro @ v0.1.2

| Field | Value |
|-------|-------|
| **Module** | `companion-module-adder-ccs-pro` |
| **Tag** | `v0.1.2` |
| **Commit** | `f9fb6f7` |
| **Previous reviewed version** | `v0.1.2` (review dated 2026-04-10) |
| **Reviewed** | 2026-04-16 |
| **Reviewer** | Mal (Lead) |
| **API version** | v1.x (`@companion-module/base ~1.14.1`) |
| **Module type** | JavaScript / CommonJS |
| **Validation** | ✅ `yarn install --immutable` · ✅ `yarn package` |

---

## Verdict

### ❌ CHANGES REQUIRED — no release-code fixes landed for the prior blocking findings

This is a same-tag follow-up. `git diff v0.1.2 HEAD -- .` shows no module-code delta at all; the only post-tag changes are new `.github/ISSUE_TEMPLATE/*` files, which are outside the shipped module payload. The three critical template findings from the prior review remain, three medium findings are still carried forward, and no new release-delta issues were introduced. One prior finding closes on re-check: the `LICENSE` file already matches the JS template aside from the allowed copyright line.

---

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 0 | 3 | 3 |
| 🟠 High | 0 | 0 | 0 |
| 🟡 Medium | 0 | 3 | 3 |
| 🟢 Low | 0 | 0 | 0 |
| **Total** | **0** | **6** | **6** |

**Blocking:** 3 issues (3 carried-forward critical)  
**Fix complexity:** Quick — the remaining blockers are still small template/manifest edits  
**Health delta:** 0 introduced · 6 pre-existing carried forward  

---

## Fix Verification (prior v0.1.2 review → current submission)

### Closed on re-check

| ID | Prior finding | Severity | Current status |
|----|---------------|----------|----------------|
| M3 | `LICENSE` file does not match template | 🟡 Medium | ✅ **Closed** — `LICENSE:1-21` matches the JS template MIT text. The only difference is the copyright line, which the template policy allows. |

### Carried-forward findings

| ID | Prior finding | Severity | Current status |
|----|---------------|----------|----------------|
| C1 | Missing `.prettierignore` file | 🔴 Critical | ❌ **Not fixed** — `.prettierignore` exists, but it still contains only `node_modules/` instead of the required `package.json` and `/LICENSE.md` lines (`.prettierignore:1`). |
| C2 | `.gitignore` contains non-template content | 🔴 Critical | ❌ **Not fixed** — extra `.claude/` and markdown-blocking rules remain, and the template paths are still written as `*.tgz` / `pkg/` instead of `/*.tgz` / `/pkg` (`.gitignore:1-12`). |
| C3 | Banned keywords in `manifest.json` | 🔴 Critical | ❌ **Not fixed** — `keywords` still includes `adder`, `ccs-pro`, and `ccs-pro8` (`companion/manifest.json:26`). |
| M1 | `manifest.json` version should be `0.0.0` | 🟡 Medium | ❌ **Not fixed** — `version` is still `0.1.2` (`companion/manifest.json:7`). |
| M2 | Module `name` does not match `id` in `manifest.json` | 🟡 Medium | ❌ **Not fixed** — `id` is `adder-ccs-pro`, but `name` is still `Adder CCS-PRO` (`companion/manifest.json:3-4`). |
| M4 | Concurrent polls possible when poll duration exceeds interval | 🟡 Medium | ❌ **Not fixed** — polling still does an immediate `pollDevice()` and then schedules repeated `setInterval(() => this.pollDevice(), ms)`, so a slow request can overlap the next tick (`src/main.js:103-108`, `src/main.js:123-160`). |

---

## New issues introduced in this follow-up delta

None. There is no shipped module-file delta between the previously reviewed `v0.1.2` tag and this follow-up submission to classify as 🆕 NEW or 🔙 REGRESSION.

---

## 🧪 Validation

- ✅ `yarn install --immutable`
- ✅ `yarn package` — produced `adder-ccs-pro-0.1.2.tgz`
- ⚠️ Install still emits the existing Yarn peer warning that `@companion-module/tools` requests `eslint`; this JS module does not define lint or test scripts

---

## ✅ Still Solid

- The module still uses the v1.x Companion SDK correctly: `InstanceBase`, `init`, `destroy`, `configUpdated`, `runEntrypoint`, and `UpgradeScripts` are all still wired properly.
- `package-lock.json` is still absent.
- The module still packages successfully, and the previously noted HELP/preset/action structure remains untouched.

---

*Follow-up review conducted by Mal only, constrained to the prior `v0.1.2` review delta.*
