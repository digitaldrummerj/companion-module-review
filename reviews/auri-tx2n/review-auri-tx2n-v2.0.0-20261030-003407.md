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

- [ ] [C1: ESLint config adds a typescript-eslint import and type-check override the template does not have](#c1-eslint-config-adds-a-typescript-eslint-import-and-type-check-override-the-template-does-not-have)

### Non-blocking

- [ ] [M1: CI workflow drifts from the template](#m1-ci-workflow-drifts-from-the-template)
- [ ] [M2: Release packages skip the shared Bitfocus module checks](#m2-release-packages-skip-the-shared-bitfocus-module-checks)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🔴 Critical

### C1: ESLint config adds a typescript-eslint import and type-check override the template does not have

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`eslint.config.mjs:1-22`](https://github.com/bitfocus/companion-module-auri-tx2n/blob/7332232c6f5c1ea199d182abd403b7b276e2b3b5/eslint.config.mjs#L1-L22)

**What goes wrong:** The module's lint setup no longer matches the official TypeScript template. Anyone troubleshooting lint or build problems later (Bitfocus maintainers, other contributors) has to work out why this module behaves differently from every other module on the same template.

**Why it happens:** This release imports `typescript-eslint` directly and adds a config block that spreads `tseslint.configs.disableTypeChecked` over `vitest.config.ts`, because that file is not covered by `tsconfig.json`. The template's ESLint config is only the shared `generateEslintConfig` call. A test-scoped override that only sets `files` and `rules` (like the second block here, which turns off `n/no-unpublished-import` for the tests) is an accepted deviation; the extra import and the `disableTypeChecked` block are not.

**Evidence:** found at `eslint.config.mjs` line 2 `import tseslint from 'typescript-eslint'`, where the template has nothing. The template expects:

```js
import { generateEslintConfig } from '@companion-module/tools/eslint/config.mjs'
export default generateEslintConfig({ enableTypescript: true })
```

**Confirm by:** open [`eslint.config.mjs:2`](https://github.com/bitfocus/companion-module-auri-tx2n/blob/7332232c6f5c1ea199d182abd403b7b276e2b3b5/eslint.config.mjs#L2) and [`eslint.config.mjs:10-14`](https://github.com/bitfocus/companion-module-auri-tx2n/blob/7332232c6f5c1ea199d182abd403b7b276e2b3b5/eslint.config.mjs#L10-L14).

**Fix:** remove the `typescript-eslint` import and the `disableTypeChecked` block. Keep only the test-scoped `files` / `rules` override. To lint `vitest.config.ts` with type information, add it to `tsconfig.json`'s `include` instead (widening `tsconfig.json` for tests is an accepted deviation).

```js
import { generateEslintConfig } from '@companion-module/tools/eslint/config.mjs'

const baseConfig = await generateEslintConfig({
	enableTypescript: true,
})

export default [
	...baseConfig,
	{
		files: ['src/__tests__/**/*.ts', 'vitest.config.ts'],
		rules: {
			'n/no-unpublished-import': 'off',
		},
	},
]
```

```json
{
	"extends": "./tsconfig.build.json",
	"include": ["src/**/*.ts", "vitest.config.ts"],
	"exclude": ["node_modules/**"],
	"compilerOptions": {
		"types": ["node"]
	}
}
```

## 🟡 Medium

### M1: CI workflow drifts from the template

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.github/workflows/node.yaml:11-80`](https://github.com/bitfocus/companion-module-auri-tx2n/blob/7332232c6f5c1ea199d182abd403b7b276e2b3b5/.github/workflows/node.yaml#L11-L80)

**What goes wrong:** The module's Node CI workflow no longer matches the template, so template updates can't be copied over cleanly and CI behaves differently from other modules.

**Why it happens:** Compared with the template, this release adds a top-level `permissions: contents: read`, drops `persist-credentials: false` from the checkout step, uses `actions/setup-node@v7` where the template pins `@v6`, removes the template-repository prepare step, and enables a test job that runs `yarn test:coverage` and uploads to `codecov/codecov-action@v7`. CI still runs on Node 26.x, which matches the `node26` runtime.

**Fix:** start from the template's `node.yaml`, keep `persist-credentials: false` and the template's action versions, and enable the template's commented-out `test` job if you want tests in CI.

### M2: Release packages skip the shared Bitfocus module checks

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.github/workflows/release.yaml:10-65`](https://github.com/bitfocus/companion-module-auri-tx2n/blob/7332232c6f5c1ea199d182abd403b7b276e2b3b5/.github/workflows/release.yaml#L10-L65)

**What goes wrong:** When a GitHub release is published, the package attached to it is built by the module's own steps instead of Bitfocus's shared module-checks workflow, so it skips the checks every other module's release goes through and is a `--dev` (unminified) build.

**Why it happens:** The template's `release.yaml` calls `bitfocus/actions/.github/workflows/module-checks.yaml@main` to build and check the package, then an `attach` job downloads that artifact and uploads it to the release. This release rewrites the workflow into one job that checks out the tag, runs `yarn package --dev` (or `--dev --prerelease`) itself and uploads `./*.tgz`.

**Fix:** replace `.github/workflows/release.yaml` with the template's version.

## 📝 Additional Notes

- [`tsconfig.build.json:5-8`](https://github.com/bitfocus/companion-module-auri-tx2n/blob/7332232c6f5c1ea199d182abd403b7b276e2b3b5/tsconfig.build.json#L5-L8) differs from the template: it drops `"verbatimModuleSyntax": true` from `compilerOptions`. The module builds and lints, so no change is required.
- The module is on API 2.2 (`@companion-module/base` 2.2.0), but the review's API compliance reference has no 2.2 checklist yet, so the module was reviewed against the API 2.0 and 2.1 rules only.
