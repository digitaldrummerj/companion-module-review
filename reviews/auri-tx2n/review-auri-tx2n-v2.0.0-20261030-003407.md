# Review: companion-module-auri-tx2n v2.0.0

| | |
| --- | --- |
| **Module** | [companion-module-auri-tx2n](https://github.com/bitfocus/companion-module-auri-tx2n) |
| **Scope** | `tag` (v1.0.1..v2.0.0) |
| **Version** | v2.0.0 (`7332232`) |
| **Release** | Update — last published v1.0.1 |
| **API** | 2.2 (base 2.2.0, yarn.lock) |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Review date** | 2026-10-30 |

## Verdict: ❌ Changes Required

## 📋 Issues

### Blocking

- [ ] [H1: CI workflow drifts from the template](#h1-ci-workflow-drifts-from-the-template)
- [ ] [H2: Release packages skip the shared Bitfocus module checks](#h2-release-packages-skip-the-shared-bitfocus-module-checks)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟠 High

### H1: CI workflow drifts from the template

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.github/workflows/node.yaml:11-80`](https://github.com/bitfocus/companion-module-auri-tx2n/blob/7332232c6f5c1ea199d182abd403b7b276e2b3b5/.github/workflows/node.yaml#L11-L80)

**What goes wrong:** The module's Node CI workflow no longer matches the template, so template updates can't be copied over cleanly and CI behaves differently from other modules.

**Why it happens:** Compared with the template, this release adds a top-level `permissions: contents: read`, drops `persist-credentials: false` from the checkout step, uses `actions/setup-node@v7` where the template pins `@v6`, removes the template-repository prepare step, and enables a test job that runs `yarn test:coverage` and uploads to `codecov/codecov-action@v7`. CI still runs on Node 26.x, which matches the `node26` runtime.

**Evidence:** `.github/workflows/node.yaml` line 11 `permissions:` (not in the template), lines 24 and 55 `uses: actions/setup-node@v7` (template: `@v6`), line 68 `yarn test:coverage` and line 72 `uses: codecov/codecov-action@v7`.

**Confirm by:** compare [`.github/workflows/node.yaml`](https://github.com/bitfocus/companion-module-auri-tx2n/blob/7332232c6f5c1ea199d182abd403b7b276e2b3b5/.github/workflows/node.yaml) with the template's `.github/workflows/node.yaml`.

**Fix:** start from the template's `node.yaml`, keep `persist-credentials: false` and the template's action versions, and enable the template's commented-out `test` job if you want tests in CI.

### H2: Release packages skip the shared Bitfocus module checks

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.github/workflows/release.yaml:10-65`](https://github.com/bitfocus/companion-module-auri-tx2n/blob/7332232c6f5c1ea199d182abd403b7b276e2b3b5/.github/workflows/release.yaml#L10-L65)

**What goes wrong:** When a GitHub release is published, the package attached to it is built by the module's own steps instead of Bitfocus's shared module-checks workflow, so it skips the checks every other module's release goes through and is a `--dev` (unminified) build.

**Why it happens:** The template's `release.yaml` calls `bitfocus/actions/.github/workflows/module-checks.yaml@main` to build and check the package, then an `attach` job downloads that artifact and uploads it to the release. This release rewrites the workflow into one job that checks out the tag, runs `yarn package --dev` (or `--dev --prerelease`) itself and uploads `./*.tgz`.

**Evidence:** `.github/workflows/release.yaml` lines 51 and 53 run `yarn package --dev --prerelease` / `yarn package --dev`, and line 63 uploads `./*.tgz`. There is no call to `bitfocus/actions/.github/workflows/module-checks.yaml@main`.

**Confirm by:** open [`.github/workflows/release.yaml:51-63`](https://github.com/bitfocus/companion-module-auri-tx2n/blob/7332232c6f5c1ea199d182abd403b7b276e2b3b5/.github/workflows/release.yaml#L51-L63) and compare it with the template's `.github/workflows/release.yaml`.

**Fix:** replace `.github/workflows/release.yaml` with the template's version.

## 📝 Additional Notes

- [`tsconfig.build.json:5-8`](https://github.com/bitfocus/companion-module-auri-tx2n/blob/7332232c6f5c1ea199d182abd403b7b276e2b3b5/tsconfig.build.json#L5-L8) differs from the template: it drops `"verbatimModuleSyntax": true` from `compilerOptions`. The module builds and lints, so no change is required.
- The module is on API 2.2 (`@companion-module/base` 2.2.0), but the review's API compliance reference has no 2.2 checklist yet, so the module was reviewed against the API 2.0 and 2.1 rules only.
