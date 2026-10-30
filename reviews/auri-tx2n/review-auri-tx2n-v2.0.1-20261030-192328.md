# Re-review: companion-module-auri-tx2n v2.0.1

| | |
| --- | --- |
| **Module** | [companion-module-auri-tx2n](https://github.com/bitfocus/companion-module-auri-tx2n) |
| **Scope** | `tag` (v2.0.0..v2.0.1) |
| **Version** | v2.0.1 (`cd0a3c4`) |
| **Release** | Update — last published v1.0.1 |
| **API** | 2.2 (base 2.2.2, yarn.lock) |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Prior review** | [v2.0.0 (2026-10-30)](review-auri-tx2n-v2.0.0-20261030-003407.md) |
| **Review date** | 2026-10-30 |

## Verdict: ✅ Approved

## 📋 Issues

### Notes

- [📝 Additional Notes](#-additional-notes)

## 📝 Additional Notes

- This is a follow-up to the [v2.0.0 review](review-auri-tx2n-v2.0.0-20261030-003407.md). Both of its blocking findings are fixed: prior H1 (CI workflow drifts from the template) — [`.github/workflows/node.yaml`](https://github.com/bitfocus/companion-module-auri-tx2n/blob/cd0a3c4498619431272bfa53a66b83b901222198/.github/workflows/node.yaml) is now identical to the template; prior H2 (release packages skip the shared Bitfocus module checks) — [`.github/workflows/release.yaml`](https://github.com/bitfocus/companion-module-auri-tx2n/blob/cd0a3c4498619431272bfa53a66b83b901222198/.github/workflows/release.yaml) is now identical to the template and calls the shared module-checks workflow again.
- The v2.0.0..v2.0.1 delta changes no module source code: it touches the two workflows above, adds a separate [`.github/workflows/test.yaml`](https://github.com/bitfocus/companion-module-auri-tx2n/blob/cd0a3c4498619431272bfa53a66b83b901222198/.github/workflows/test.yaml) for unit tests (so `node.yaml` can stay a straight copy of the template), and bumps dependencies in [`package.json`](https://github.com/bitfocus/companion-module-auri-tx2n/blob/cd0a3c4498619431272bfa53a66b83b901222198/package.json) and `yarn.lock` (`@companion-module/base` ~2.2.2, `p-queue` ^10.0.0). `yarn install --immutable`, `yarn package` and `yarn lint` all pass. No new issues were introduced.
- [`tsconfig.build.json:5-8`](https://github.com/bitfocus/companion-module-auri-tx2n/blob/cd0a3c4498619431272bfa53a66b83b901222198/tsconfig.build.json#L5-L8) still differs from the template: it drops `"verbatimModuleSyntax": true` from `compilerOptions`. The module builds and lints, so no change is required.
- The module is on API 2.2 (`@companion-module/base` 2.2.2), but the review's API compliance reference has no 2.2 checklist yet, so the module was reviewed against the API 2.0 and 2.1 rules only.
