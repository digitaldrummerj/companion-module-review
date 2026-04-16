---
name: review-yarn4-lockfile-validation
description: Validate follow-up Companion module releases that add Yarn 4 metadata, ensuring the committed lockfile is actually immutable and the advertised lint/build scripts run in a clean checkout.
---

# Skill: Review Yarn 4 Lockfile Validation

## When to Use

- A Companion module follow-up release adds or changes:
  - `packageManager: "yarn@4.x"`
  - `yarn.lock`
  - `lint` / `build` scripts
  - `@companion-module/tools`
- A prior review flagged missing lockfiles, missing template tooling, or broken reproducible-build setup

## Why This Matters

Seeing `yarn.lock` in the tree is not enough. A follow-up patch can add the file but still fail reproducible installs if the lockfile was generated with the wrong Yarn version or would be rewritten immediately on first install.

## Validation Flow

1. Extract or check out the submitted tag in an isolated scratch copy.
2. Run:

   ```bash
   COREPACK_ENABLE_DOWNLOAD_PROMPT=0 corepack yarn install --immutable
   ```

3. If Yarn fails with `YN0028: The lockfile would have been modified`, treat the prior lockfile/reproducibility finding as **still open**.
4. If install succeeds, run the declared validation scripts from the tag:

   ```bash
   corepack yarn build
   corepack yarn lint
   ```

5. If `yarn lint` fails with `command not found: eslint`, surface a **new delta issue**: the follow-up added lint wiring without the actual lint runtime dependency.

## Review Guidance

- Do **not** mark a missing-`yarn.lock` finding fixed just because the file now exists.
- Tie the verdict to what a clean checkout can actually do:
  - immutable install
  - build
  - lint
- If the repository has a lockfile-fix commit **after** the submitted release tag, keep the review anchored to the tag. A later `main` fix does not rescue the published release; the tagged artifact is still broken until that corrected lockfile is retagged and resubmitted.
- If the lockfile finding was duplicated in the earlier review, you can carry both IDs forward as one technical blocker in the follow-up writeup.
