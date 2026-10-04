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

Exit codes: `0` clean · `1` Critical findings · `2` unusable `-ModuleDir` / no template · `3` the template clone is stale or unverifiable (see §1.5).

## 1.5 Template freshness — checked first, and it is an *environment* finding

Before anything is compared, the validator verifies the local template clone against its
upstream with a read-only `git ls-remote` (no fetch, no pull, nothing written). This matters
because a clone that is behind upstream produces **false findings against a correct module** —
that has actually happened here: a pre-2026-06-24 clone flagged a module's correct
`enableScripts: false` as an *extra* `.yarnrc.yml` key, and the review told the maintainer to
delete their supply-chain hardening.

| Finding | Meaning |
|---------|---------|
| `TEMPLATE-STALE` (Critical) | Local HEAD ≠ `origin/main`. **Any** commit behind counts. |
| `TEMPLATE-UNVERIFIED` (Critical) | The upstream couldn't be reached, or an auto-resolved template isn't a git clone. |

**These two are never carried into the review markdown.** They describe *your* workspace, not
the maintainer's module — the maintainer cannot act on them. When either appears, the review
**aborts**: refresh and start over, so no report is produced from untrustworthy expectations.

```powershell
pwsh scripts/update-templates.ps1     # the ONLY thing that ever moves a template
```

Templates are never refreshed automatically, and `setup.ps1` does not pull either. Several
review sessions share these clones, so an automatic pull would change the reference underneath
a review already in progress. Refresh **between** sessions, not during one.

The `-v1` clones sit in detached HEAD at the last v1.x commit by design and are exempt — but
their v2 parent, which supplies the `.yarnrc.yml` expectations for v1 modules, is still
checked. For a deliberate offline run, pass `-SkipTemplateFreshness` (or set
`COMPANION_SKIP_TEMPLATE_FRESHNESS=1`) and record `Template freshness: skipped` in the review's
meta table.

## 2. What the script checks (Critical = blocking, unless the row says otherwise)

| Area | Finding ids |
|------|-------------|
| **(Checked first)** Template clone is not behind upstream — see §1.5 | `TEMPLATE-STALE`, `TEMPLATE-UNVERIFIED` |
| Required files present; no `package-lock.json` | `FILE-MISSING`, `NPM-LOCK` |
| Config-file parity vs template — exact match for `.gitattributes`, `.prettierignore`, TS `eslint.config.mjs`/`tsconfig*.json`, and `.husky/*`. `.gitignore` is a **subset** check: every template entry must be present, but **extra** module entries are allowed and not flagged. `.yarnrc.yml` is a **key-level** check (see below) | `CONFIG-DIFF` |
| **(Medium — visible, not blocking)** `.github/workflows/**` and `.github/ISSUE_TEMPLATE/**` parity. Usually GitHub Action pin churn (`actions/checkout@v4` vs the template's `@v7`), which the maintainer didn't cause and shouldn't be blocked on | `CONFIG-DIFF`, `FILE-MISSING` |
| **(Info — for you, not the maintainer)** The template tracks a file the validator has no rule for. It is still compared, as exact text; add a row to `$templateFileRules` in `scripts/validate-template.ps1` and a line to this table | `TEMPLATE-COVERAGE` |
| Gitignored artifacts not committed (`node_modules`, `/pkg`, `*.tgz`, `/dist`, `/.yarn`, …) | `GITIGNORED-COMMITTED` |
| **(High)** `LICENSE` matches the template **exactly** — the copyright line included (see below) | `LICENSE-DIFF` |
| All source under `src/` (none at module root). Tool config files named `<tool>.config.(js|ts)` (`vitest.config.ts`, `vite.config.js`, `jest.config.ts`, …) belong at the root and are exempt | `SRC-AT-ROOT` |
| `package.json`: version-vs-tag, `main` (references an existing entry file; filename may differ from the template), `repository.url`, required fields, `packageManager` (yarn@4), required scripts, devDependencies, lint-staged | `PKG-VERSION`, `PKG-MAIN`, `PKG-REPO`, `PKG-FIELD`, `PKG-YARN`, `PKG-SCRIPT`, `PKG-DEVDEP`, `PKG-LINTSTAGED`, `PKG-DEP` |
| `manifest.json`: non-placeholder/non-empty maintainers, banned keywords, `type` (v2 `connection`), `runtime.type/api` (must match template, except the API 2.1 `node26` allowance below), `runtime.entrypoint` (exists and resolves to the same file as `main`) | `MAN-PLACEHOLDER`, `MAN-MAINT`, `MAN-KEYWORD`, `MAN-TYPE`, `MAN-RUNTIME`, `ENTRY-MISMATCH` |
| `companion/HELP.md` not a stub | `HELP-STUB` |
| TS husky `pre-commit` runs `lint-staged` | `HUSKY` |
| Build / lint (with `-RunBuild`) | `BUILD-INSTALL`, `BUILD-PACKAGE`, `LINT` |

**API 2.1 allowances.** Both upstream v2 templates still pin base `2.0.x` with `runtime.type: "node22"`, but a module on base **≥ 2.1** (Companion 5.0+) may legitimately move to Node 26. The validator resolves the module's installed base version (the same `apiLevel` the fact sheet reports) and adjusts:

| Situation | Result |
|---|---|
| base ≥ 2.1, `runtime.type: "node26"` | accepted — no `MAN-RUNTIME` |
| base 2.0.x, `runtime.type: "node26"` | `MAN-RUNTIME` (Critical): "node26 requires @companion-module/base ≥ 2.1 (Companion 5.0+)" — the fix is to bump base to `~2.1.x` or go back to `node22` |
| base ≥ 2.1, `runtime.type: "node26"`, `tsconfig.build.json` extends `@companion-module/tools/tsconfig/node26/recommended(.json)` where the template has `node22/recommended-esm.json` | `TSCONFIG-NODE26` (Info, for you) instead of `CONFIG-DIFF` — any *other* tsconfig difference is still a Critical `CONFIG-DIFF` |

`TSCONFIG-NODE26` is an environment note like `TEMPLATE-COVERAGE`: it does not go into the review markdown.

**Accepted deviation: `tsconfig.json` widened to type-check tests.** `tsconfig.json` is the editor/typecheck config; the build uses `tsconfig.build.json`, which stays an exact match. A module that ships tests may widen `tsconfig.json` with:
- extra `include` / `exclude` entries (`tests/**/*.ts`, `scripts/**/*.ts`, `vitest.config.ts`, …)
- extra `compilerOptions.types` entries (`vitest/globals`, `jest`, …)
- `compilerOptions.rootDir` and `compilerOptions.noEmit`

Every value the template sets must still be present and unchanged. If that holds, the validator reports an Info `TSCONFIG-DEV-SCOPE` listing what was widened, instead of a `CONFIG-DIFF`. Anything else in `tsconfig.json` (a different `extends`, another compiler option, a removed template `include`) is still a Critical `CONFIG-DIFF`. `TSCONFIG-DEV-SCOPE` does not go into the review markdown either.

**Accepted deviation: `eslint.config.mjs` with test-only overrides.** Modules that ship tests usually relax a couple of rules for test files (e.g. `n/no-unpublished-import` for vitest imports, `@typescript-eslint/unbound-method` for `vi.fn()` assertions). That needs the template's `export default generateEslintConfig({…})` turned into `const baseConfig = await generateEslintConfig({…})` plus `export default [...baseConfig, { files: [...], rules: {...} }]`. The const + `export default <name>` form is accepted too.

The validator accepts it, reporting an Info `ESLINT-TEST-SCOPE` instead of a `CONFIG-DIFF`, only when all of these hold:
- The imports are exactly the template's.
- The `generateEslintConfig` options are identical.
- `...baseConfig` comes first.
- Every extra entry is an object using only `files` / `rules` / `languageOptions` / `name`.
- Every `files` glob is a test or tooling path: `tests/**`, `__tests__/**`, `__mocks__/**`, `scripts/**`, `*.test.*`, `*.spec.*`, or a root `*.config.*` file.

Anything that can change how `src/` is linted is still a Critical `CONFIG-DIFF`, and the message says why: an override on `src/**`, a rule block with no `files:`, changed options, extra imports or plugins, an entry placed before the base config. `ESLINT-TEST-SCOPE` does not go into the review markdown.

Expectations are derived from the matched template, so v1 modules are checked against the
v1 template and are not flagged for v2-only differences (e.g. v1 manifests correctly have
no `type` field).

**Which files get compared is derived too**, from the template's own tracked files
(`git ls-files`) rather than a list maintained inside the validator. A config file Bitfocus
adds upstream is therefore compared on the next review automatically. Excluded as
module-owned: `src/**`, `README.md`, `yarn.lock`. Excluded because a dedicated rule already
owns them: `LICENSE`, `package.json`, `companion/manifest.json`, `companion/HELP.md`. Binary
files are skipped. Everything else is compared — and a path matching no rule is *still*
compared, plus a `TEMPLATE-COVERAGE` note, so a new template file can never slip through
unjudged.

This is also why the JS/TS split needs no special-casing: `.husky/pre-commit`,
`eslint.config.mjs`, and `tsconfig*.json` are demanded of TS modules only because only the TS
template tracks them. One consequence: `yarn.lock` is required of every module even though the
v2 templates deliberately don't commit one — that requirement is hardcoded, not derived.

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
- **`.github/**` divergences.** Reported at **Medium**, so they appear in the review under Medium but do not block. Judge whether it is worth mentioning at all: an out-of-date `actions/checkout` pin is worth a one-line note; a workflow the maintainer deliberately extended (extra matrix entries, an added job) is not a defect. Do not tell a maintainer to blindly overwrite a workflow they customised.
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

Findings addressed to *you* rather than the maintainer — `TEMPLATE-STALE`,
`TEMPLATE-UNVERIFIED`, `TEMPLATE-COVERAGE`, `TSCONFIG-NODE26`, `TSCONFIG-DEV-SCOPE`, `ESLINT-TEST-SCOPE` — never appear in the review markdown.

If the script cannot run (templates unavailable), fall back to comparing the module directly
against the matching template repo in `companion-module-templates/` (run `setup.ps1` to clone
them, `pwsh scripts/update-templates.ps1` to refresh an existing clone) — but prefer fixing
the environment so the deterministic path runs every time. Never `git pull` a template by
hand, and never mid-review: other sessions are diffing against the same clone.
