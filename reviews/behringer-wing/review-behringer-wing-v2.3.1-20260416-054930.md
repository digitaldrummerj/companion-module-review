# Re-Review: behringer-wing @ v2.3.1

| Field | Value |
|-------|-------|
| **Module** | `companion-module-behringer-wing` |
| **Tag** | `v2.3.1` |
| **Commit** | `b83e828` |
| **Previous reviewed version** | `v2.3.0` |
| **Reviewed** | 2026-04-16 |
| **Reviewer** | Mal |
| **API version** | v1.x (`@companion-module/base ~1.13`) |
| **Module type** | TypeScript / ESM |
| **Build** | ✅ `yarn install --immutable && yarn lint && yarn package` |

---

## Verdict

### ✅ APPROVED — ready for release

This follow-up patch cleanly fixes every finding from the v2.3.0 review. No carried-forward findings remain from that review, and no new delta issues were introduced in v2.3.1.

---

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 0 | 0 | 0 |
| 🟠 High | 0 | 0 | 0 |
| 🟡 Medium | 0 | 0 | 0 |
| 🟢 Low | 0 | 0 | 0 |
| **Total** | **0** | **0** | **0** |

**Blocking:** 0 issues  
**Health delta:** 0 introduced · 0 pre-existing

---

## Fix Verification (v2.3.0 → v2.3.1)

| ID | v2.3.0 Finding | Severity | Resolution |
|----|---------------|----------|------------|
| C1 | Connection error no longer updated module status | 🔴 Critical | ✅ **Fixed** — `src/index.ts` now restores `updateStatus(InstanceStatus.ConnectionFailure, err.message)` in the socket error handler |
| C2 | `.gitattributes` file missing | 🔴 Critical | ✅ **Fixed** — `.gitattributes` added with `* text=auto eol=lf` |
| C3 | `.gitignore` content deviated from template | 🔴 Critical | ✅ **Fixed** — root tarball glob corrected to `/*.tgz`, `.DS_Store` removed, `/.vscode` added |
| C4 | `engines` field absent/empty in `package.json` | 🔴 Critical | ✅ **Fixed** — `engines.node` and `engines.yarn` now match template requirements |
| C5 | `repository.url` incorrect in `package.json` | 🔴 Critical | ✅ **Fixed** — URL now points to `git+https://github.com/bitfocus/companion-module-behringer-wing.git` |
| C6 | `manifest.json` `runtime.type` was `node18` | 🔴 Critical | ✅ **Fixed** — runtime target updated to `node22` |
| C7 | `tsconfig.build.json` extended `node18` config | 🔴 Critical | ✅ **Fixed** — build config now extends `@companion-module/tools/tsconfig/node22/recommended` |
| M1 | `package.json` `name` did not match module ID | 🟡 Medium | ✅ **Fixed** — package name is now `behringer-wing` |

**8 of 8 findings fixed.** No items from the previous submitted review remain open.

---

## ✅ What's Solid

- **Tightly scoped follow-up patch.** The maintainer touched exactly the files needed to close the prior review findings, without unrelated churn.
- **Regression is properly repaired.** Companion now returns to a visible `ConnectionFailure` state on socket errors instead of silently logging an opaque `JSON.stringify(err)` payload.
- **Release validation is clean.** `yarn install --immutable`, `yarn lint`, and `yarn package` all succeeded for `v2.3.1`.
- **Changelog matches the delta.** README documents the restored error-state behavior and the Node 22 runtime bump shipped in this patch.

---

*Follow-up review constrained to the v2.3.0 → v2.3.1 delta and the prior submitted findings.*
