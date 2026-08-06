---
name: companion-template-compliance
description: Verify a Companion module matches the official JS/TS template — required files, config-file parity, package.json/manifest.json fields, LICENSE, HELP.md, husky. Run scripts/validate-template.ps1 for the deterministic checks, then use this skill to interpret findings and judge the non-deterministic items. Use at the start of every module review.
---

# Skill: companion-template-compliance

Template compliance is almost entirely **deterministic** — file presence, exact config-file
content, package.json/manifest.json fields, LICENSE text, banned keywords. Do **not** check
these by hand (that is where reviews drift and miss things). Run the script; it compares the
module against the correct template (selected by API version × language) and emits a findings
list. Then apply judgment to the handful of items the script can't decide.

## 1. Run the validator

```powershell
pwsh scripts/validate-template.ps1 -ModuleDir <module path> -ExpectedVersion <git tag> [-RunBuild]
```

- `-ExpectedVersion` (the submitted git tag, e.g. `v2.1.0`) enables the `package.json` version-match check. Pass it whenever you know the tag.
- `-RunBuild` additionally runs `yarn install --immutable`, `yarn package` (build) and, for TS, `yarn lint`, and gates on success. Use it to satisfy the "build runs / lint runs" review gates. It is slower and needs network.
- Add `-Json` for machine-readable output. Templates are auto-selected from `companion-module-templates/` inside the repo (override with `COMPANION_TEMPLATES_DIR`) or pass `-TemplateDir`.

**Every `Critical` finding blocks approval.** Each finding already states the file, expected value, and what was found — drop those straight into the review's side-by-side report.

## 2. What the script checks (all blocking; Critical unless the row says otherwise)

| Area | Finding ids |
|------|-------------|
| Required files present; no `package-lock.json` | `FILE-MISSING`, `NPM-LOCK` |
| Config-file parity vs template — exact match for `.gitattributes`, `.prettierignore`, and TS `eslint.config.mjs`/`tsconfig*.json`. `.gitignore` is a **subset** check: every template entry must be present, but **extra** module entries are allowed and not flagged. `.yarnrc.yml` is a **key-level** check (see below) | `CONFIG-DIFF` |
| Gitignored artifacts not committed (`node_modules`, `/pkg`, `*.tgz`, `/dist`, `/.yarn`, …) | `GITIGNORED-COMMITTED` |
| **(High)** `LICENSE` matches the template **exactly** — the copyright line included (see below) | `LICENSE-DIFF` |
| All source under `src/` (none at module root) | `SRC-AT-ROOT` |
| `package.json`: version-vs-tag, `main` (references an existing entry file; filename may differ from the template), `repository.url`, required fields, `packageManager` (yarn@4), required scripts, devDependencies, lint-staged | `PKG-VERSION`, `PKG-MAIN`, `PKG-REPO`, `PKG-FIELD`, `PKG-YARN`, `PKG-SCRIPT`, `PKG-DEVDEP`, `PKG-LINTSTAGED`, `PKG-DEP` |
| `manifest.json`: non-placeholder/non-empty maintainers, banned keywords, `type` (v2 `connection`), `runtime.type/api` (must match template), `runtime.entrypoint` (exists and resolves to the same file as `main`) | `MAN-PLACEHOLDER`, `MAN-MAINT`, `MAN-KEYWORD`, `MAN-TYPE`, `MAN-RUNTIME`, `ENTRY-MISMATCH` |
| `companion/HELP.md` not a stub | `HELP-STUB` |
| TS husky `pre-commit` runs `lint-staged` | `HUSKY` |
| Build / lint (with `-RunBuild`) | `BUILD-INSTALL`, `BUILD-PACKAGE`, `LINT` |

Expectations are derived from the matched template, so v1 modules are checked against the
v1 template and are not flagged for v2-only differences (e.g. v1 manifests correctly have
no `type` field).

**`LICENSE` must match the template byte-for-byte**, including `Copyright (c) 2022 Bitfocus AS - Open Source`. The template's LICENSE is the licence Bitfocus ships for every module, not a scaffold to personalise, so substituting the maintainer's own name or year is a `LICENSE-DIFF` — reported at **High**, not Critical. Line endings and trailing whitespace are normalized before comparing, so a CRLF checkout of the correct text is not a finding. A module that legitimately needs different terms should raise it with Bitfocus rather than editing the file.

**`.yarnrc.yml` is the one exception to that rule.** It is repo tooling rather than API
surface, and Bitfocus only updates it on `main` — so it is always compared against the
non-`-v1` template, for v1 and v2 modules alike. It is also compared **by parsed key**, not
raw text: key order, quote style (`'@companion-module/*'` vs `"…"`), blank lines, and
comments are **not** divergences and are never flagged. What *is* Critical:

- **Missing template keys** — the template hardened this file on 2026-06-24, adding
  `enableScripts: false`, `npmMinimalAgeGate: 3d`, and `npmPreapprovedPackages`. A module
  still shipping only `nodeLinker: node-modules` is missing that supply-chain hardening.
- **Conflicting value** — e.g. `enableScripts: true`, `npmMinimalAgeGate: 5`.
- **Extra keys** — e.g. `yarnPath`, `enableGlobalCache`, `approvedGitRepositories`; these
  change install behaviour for everyone building the module.

Note `enableScripts: false` combined with a `"postinstall": "husky"` script means git hooks
stop installing after a fresh clone — the current template ships both, so raise that with
Bitfocus rather than the maintainer.

## 3. Judgment items the script can't fully decide

- **HELP.md quality.** The script only catches stubs (placeholder string, `## Your module`, <5 meaningful lines). You still judge whether the content is *useful*: what the module does, how to configure it (host/port/auth), available actions/feedbacks/variables, troubleshooting. Thin-but-real docs are acceptable; empty scaffolding is not.
- **`tsconfig` deviations.** A `CONFIG-DIFF` on `tsconfig*.json` is reported as Critical, but a deliberate, justified deviation (e.g. `nodenext` resolution) may be acceptable — confirm the maintainer's rationale before insisting. **Exception (do not flag):** removing the template's commented-out jest hint in `compilerOptions.types` — i.e. `"types": ["node"]` instead of the template's `"types": ["node" /* , "jest" ] // uncomment this if using jest */]` — is an accepted divergence, not a defect. The validator already strips that dead comment before comparing, so it will not raise `CONFIG-DIFF` for it; if you still see it raised elsewhere, treat it as a non-issue.
- **Entry-point filename.** `package.json main` and `manifest runtime.entrypoint` do **not** have to match the template's `src/main.js` / `../src/main.js`. A non-template name (e.g. `src/index.js`) is fine as long as both fields are present, reference a file that **exists**, and resolve to the **same** file. The validator already checks this: `PKG-MAIN`/`MAN-RUNTIME` fire only when the referenced file is missing, and `ENTRY-MISMATCH` fires only when `main` and `entrypoint` point to different files. Do **not** ask the maintainer to rename their entry to `main.js` when it loads correctly.
- **Manifest `name` vs `id`.** These are **not** required to match, and the validator no longer checks it. `id` is the slug (the repository/module identifier); `name` is the human-facing module name and is *expected* to differ — e.g. `id: fblab-bpm2osc` / `name: BPM2OSC`, `id: lindy-38359-matrix` / `name: Lindy 38359 HDMI Matrix`. Do **not** raise this by hand or tell a maintainer to set `name` to the slug.
- **Manifest version normalization.** `companion/manifest.json` `version` of `"0.0.0"` is acceptable/preferred in source control. If a real version string is committed instead, it must exactly match `package.json`. Treat `package.json` (vs the git tag) and the manifest as **separate** checks.
- **`runtime.apiVersion` placeholder.** `companion/manifest.json` `runtime.apiVersion` of `"0.0.0"` is **not** a defect — like top-level `version`, it is the expected source-control placeholder that the BitFocus **publish pipeline fills in** at submission time. All four official templates (js, ts, js-v1, ts-v1) ship `runtime.apiVersion: "0.0.0"`. This holds for **both v1 and v2** modules. Do **not** flag `"0.0.0"` here or tell the maintainer to set a "real" value (e.g. `"1.0.0"`).
- **Banned keywords nuance.** The script flags the static-banned terms (`companion`, `module`, `stream deck`, `bitfocus`) and keywords matching the module id. Also flag the **manufacturer or product name** (e.g. `easyworship`, `tallyccupro`) — these add no search value.

## 4. Reporting

Use the script's expected-vs-found for side-by-side guidance the maintainer can act on:

```
Template expects:  "repository.url": "git+https://github.com/bitfocus/companion-module-{name}.git"
Found:             "repository.url": "git+https://github.com/personal-user/companion-module-name.git"
```
```
manifest.json maintainers[0].name = "Your name"  ← placeholder, must be replaced
```

If the script cannot run (templates unavailable), fall back to comparing the module directly
against the matching template repo in `companion-module-templates/` (run `setup.ps1` to clone
them) — but prefer fixing the environment so the deterministic path runs every time.
