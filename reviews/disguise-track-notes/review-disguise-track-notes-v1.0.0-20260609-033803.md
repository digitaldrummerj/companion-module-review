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
| 🔴 Critical | 3 | 0 | 3 |
| 🟠 High | 0 | 0 | 0 |
| 🟡 Medium | 0 | 0 | 0 |
| 🟢 Low | 0 | 0 | 0 |
| 💡 Nice to Have | 0 | 0 | 0 |
| **Total** | **3** | **0** | **3** |

## Verdict: ❌ Changes Required

## 📋 Issues

**Blocking**

- [ ] [C1: Source files live at the repo root instead of src](#c1-source-files-live-at-the-repo-root-instead-of-src)
- [ ] [C2: Manufacturer name Disguise used as a manifest keyword](#c2-manufacturer-name-disguise-used-as-a-manifest-keyword)
- [ ] [C3:](#c3-there-are-no-actions-in-the-module)

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

### C3: There are no actions in the module

It is unusual to have zero actions in a module.  Can you please explain the value this module is providing you with only writing cue names to button text and variables?


---
