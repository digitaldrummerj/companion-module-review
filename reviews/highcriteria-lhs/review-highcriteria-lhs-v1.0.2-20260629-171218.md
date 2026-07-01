# Review — highcriteria-lhs v1.0.2

| | |
|---|---|
| **Module** | highcriteria-lhs (Liberty Helper Service) |
| **Review tag** | v1.0.2 |
| **Previous tag** | v1.0.1 |
| **Scope** | `tag` (only the `v1.0.1..v1.0.2` diff) |
| **Language / API** | TypeScript · @companion-module/base v2 (~2.0.4) |
| **Build** | ✅ `yarn install --immutable` + `yarn package` pass |
| **Lint** | ❌ `yarn lint` fails (2 errors) |

This release is a dependency/tooling/type-hygiene bump. The source diff touches only `src/actions.ts` and `src/feedbacks.ts` (type-only schema refactor) plus a `manifest.json` `type` addition; the transport layer (`src/lhs.ts`, `src/main.ts`) is unchanged. All blocking findings come from template-parity, keyword, and lint gates — none are runtime/behavioral regressions.

## Verdict: Approved

## 📋 Issues

**Blocking**

- [ ] [H1: yarn lint fails with 2 no-unnecessary-type-assertion errors](#h1-yarn-lint-fails-with-2-no-unnecessary-type-assertion-errors)

## 🟠 High

### H1: yarn lint fails with 2 no-unnecessary-type-assertion errors

**Classification:** 🆕 NEW (regression) · **File:** `src/lhs.ts:584`, `src/lhs.ts:744`

`yarn lint` (a required template script, also wired into the husky `pre-commit` via lint-staged) now fails:

```
src/lhs.ts
  584:21  error  This assertion is unnecessary since it does not change the type of the expression  @typescript-eslint/no-unnecessary-type-assertion
  744:17  error  This assertion is unnecessary since it does not change the type of the expression  @typescript-eslint/no-unnecessary-type-assertion
```

`src/lhs.ts` was not edited this release, but the eslint 9→10 / TypeScript ~5.9→~6.0 / typescript-eslint 8.58→8.61 bumps in this release newly flag two redundant assertions: `head.readUInt32BE(8) as BlockType` (line 584) and `payload[offset] as Cmd` (line 744). Both casts are runtime no-ops — `readUInt32BE` and the buffer index return `number`, and `BlockType`/`Cmd` are numeric enums — so removing them does not change the `switch` dispatch. A module that fails its own lint gate should not ship.

**Fix:** Delete the redundant `as BlockType` and `as Cmd` assertions at `src/lhs.ts:584` and `:744` (or run `yarn lint --fix`). Verify `yarn lint` then passes clean.
