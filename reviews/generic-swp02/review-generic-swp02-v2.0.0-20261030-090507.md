# Review: generic-swp02 v2.0.0

| Field | Value |
| --- | --- |
| **Module** | `companion-module-generic-swp02` |
| **Scope** | `tag` |
| **Version** | v2.0.0 |
| **Release** | Update — last published v1.2.3 |
| **API** | 2.2 (base 2.2.1, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Commit** | [`a7d3f68`](https://github.com/bitfocus/companion-module-generic-swp02/tree/a7d3f68a51c87f599168566aaf18a7aa98f2acd0) |
| **Date** | 2026-10-30 |

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | When a dropdown option is in expression mode, Companion compares the result to the choice ids strictly, so the text `"5"` (what a custom variable holds) does not match the numeric choice id `5`, and the action or feedback is skipped | base 2.2.1 `input.d.ts` says an invalid value without `allowInvalidValues` makes Companion skip the action/feedback, and the v2.0 rules say a dropdown result must match a choice; the comparison itself is Companion host code, which was not checked | [M1](#m1-buttons-that-picked-the-destination-or-source-from-a-custom-variable-may-stop-running-after-the-upgrade-to-200) |

## 📋 Issues

### Blocking

- [ ] [C1: Building the module approves git dependencies from any repository](#c1-building-the-module-approves-git-dependencies-from-any-repository)
- [ ] [H1: The CI workflow no longer matches the template](#h1-the-ci-workflow-no-longer-matches-the-template)
- [ ] [H2: GitHub releases get a dev build made outside the shared Bitfocus workflow](#h2-github-releases-get-a-dev-build-made-outside-the-shared-bitfocus-workflow)

### Non-blocking

- [ ] [M1: Buttons that picked the destination or source from a custom variable may stop running after the upgrade to 2.0.0](#m1-buttons-that-picked-the-destination-or-source-from-a-custom-variable-may-stop-running-after-the-upgrade-to-200)
- [ ] [L1: The Go action's Mode option needs 0 or 1 in expression mode](#l1-the-go-actions-mode-option-needs-0-or-1-in-expression-mode)
- [ ] [N1: A pending Learn keeps its 3-second timer running after the connection is disabled](#n1-a-pending-learn-keeps-its-3-second-timer-running-after-the-connection-is-disabled)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🔴 Critical

### C1: Building the module approves git dependencies from any repository

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.yarnrc.yml:1-2`](https://github.com/bitfocus/companion-module-generic-swp02/blob/a7d3f68a51c87f599168566aaf18a7aa98f2acd0/.yarnrc.yml#L1-L2)

**What goes wrong:** Anyone who installs the module's dependencies (the maintainer, CI, the Bitfocus build) runs Yarn with git-sourced packages approved from every repository. The template's install rules don't allow that, so the module builds under different, looser rules than every other module.

**Why it happens:** `.yarnrc.yml` adds an `approvedGitRepositories` key with the wildcard `"**"`. The template's `.yarnrc.yml` has only `enableScripts: false`, `nodeLinker: node-modules`, `npmMinimalAgeGate: 3d` and `npmPreapprovedPackages`. The module has all four of those, correctly. `yarn.lock` has no git-sourced dependencies, so the key isn't needed.

**Evidence:**

```yaml
# .yarnrc.yml:1-2
approvedGitRepositories:
  - "**"
```

Validator: `.yarnrc.yml` — Extra keys not in template: approvedGitRepositories.

**Confirm by:** `diff companion-module-template-ts/.yarnrc.yml .yarnrc.yml` shows the extra lines 1-3 in [`.yarnrc.yml:1-3`](https://github.com/bitfocus/companion-module-generic-swp02/blob/a7d3f68a51c87f599168566aaf18a7aa98f2acd0/.yarnrc.yml#L1-L3).

**Fix:** remove lines 1-3 so the file matches the template.

## 🟠 High

### H1: The CI workflow no longer matches the template

- **Source:** 🤖 validate-template (CONFIG-DIFF) — Medium by default, raised to High by the review maintainer's .github rule
- **Classification:** 🆕 NEW
- **File:** [`.github/workflows/node.yaml:11-81`](https://github.com/bitfocus/companion-module-generic-swp02/blob/a7d3f68a51c87f599168566aaf18a7aa98f2acd0/.github/workflows/node.yaml#L11-L81)

**What goes wrong:** The module's CI runs differently from the template every module is checked against. The checkout step keeps the GitHub token in the cloned repo, the workflow uses newer action versions than the template, and a test job uploads coverage to Codecov with a repository secret. Anyone troubleshooting a CI failure later can't compare against the template.

**Why it happens:** The workflow was edited away from the template in several places:

- [`.github/workflows/node.yaml:11-12`](https://github.com/bitfocus/companion-module-generic-swp02/blob/a7d3f68a51c87f599168566aaf18a7aa98f2acd0/.github/workflows/node.yaml#L11-L12) adds a top-level `permissions: contents: read` block.
- [`.github/workflows/node.yaml:21`](https://github.com/bitfocus/companion-module-generic-swp02/blob/a7d3f68a51c87f599168566aaf18a7aa98f2acd0/.github/workflows/node.yaml#L21) drops the template's `with: persist-credentials: false` from `actions/checkout@v7`.
- [`.github/workflows/node.yaml:24`](https://github.com/bitfocus/companion-module-generic-swp02/blob/a7d3f68a51c87f599168566aaf18a7aa98f2acd0/.github/workflows/node.yaml#L24) and [`:56`](https://github.com/bitfocus/companion-module-generic-swp02/blob/a7d3f68a51c87f599168566aaf18a7aa98f2acd0/.github/workflows/node.yaml#L56) use `actions/setup-node@v7` (template: `@v6`).
- [`.github/workflows/node.yaml:38`](https://github.com/bitfocus/companion-module-generic-swp02/blob/a7d3f68a51c87f599168566aaf18a7aa98f2acd0/.github/workflows/node.yaml#L38) adds `yarn test:types` to the build step.
- [`.github/workflows/node.yaml:47-81`](https://github.com/bitfocus/companion-module-generic-swp02/blob/a7d3f68a51c87f599168566aaf18a7aa98f2acd0/.github/workflows/node.yaml#L47-L81) enables the template's commented-out `test:` job but changes it: it runs `yarn test:coverage` (template `yarn test`), splits the install into its own step, and adds a `codecov/codecov-action@v7` step using `secrets.CODECOV_TOKEN`.

Removing the template's "Prepare Environment (For template repository)" step is expected; the template says modules may remove it.

**Evidence:**

```diff
+permissions:
+  contents: read
+
       - uses: actions/checkout@v7
-        with:
-          persist-credentials: false
-        uses: actions/setup-node@v6
+        uses: actions/setup-node@v7
           yarn build
+          yarn test:types
-  #         yarn test
+          yarn test:coverage
+      - name: Send coverage
+        uses: codecov/codecov-action@v7
+        with:
+          token: ${{ secrets.CODECOV_TOKEN }}
```

**Confirm by:** `diff companion-module-template-ts/.github/workflows/node.yaml .github/workflows/node.yaml` against [`.github/workflows/node.yaml`](https://github.com/bitfocus/companion-module-generic-swp02/blob/a7d3f68a51c87f599168566aaf18a7aa98f2acd0/.github/workflows/node.yaml) should show only the uncommented template `test:` job (and optionally the removed template-repo step).

**Fix:** copy the template's `node.yaml`. If you want tests in CI, uncomment the template's `test:` job as shipped, keeping `persist-credentials: false` and the template's action versions.

### H2: GitHub releases get a dev build made outside the shared Bitfocus workflow

- **Source:** 🤖 validate-template (CONFIG-DIFF) — Medium by default, raised to High by the review maintainer's .github rule
- **Classification:** 🆕 NEW
- **File:** [`.github/workflows/release.yaml:10-63`](https://github.com/bitfocus/companion-module-generic-swp02/blob/a7d3f68a51c87f599168566aaf18a7aa98f2acd0/.github/workflows/release.yaml#L10-L63)

**What goes wrong:** When the maintainer publishes a GitHub release, the package attached to it is an unminified `--dev` build, made by the module's own job instead of the shared Bitfocus `module-checks` workflow, and named with the tarball's default name instead of the template's `<name>-<version>.tgz`. Users who download it get a different build from the one every other module attaches.

**Why it happens:** The template's release workflow has two jobs: `package` calls `bitfocus/actions/.github/workflows/module-checks.yaml@main` (with `git-ref`, `prerelease` and `upload-artifact: true`), and `attach` downloads its `pkg` artifact, renames it and uploads it. The module replaces both with a single job that checks out the tag, sets up Node 26 with `actions/setup-node@v7`, runs `yarn install` and `yarn package --dev [--prerelease]`, then uploads `./*.tgz`. It also adds a comment block before `jobs:`, raises the timeout to 15 minutes (template 5) and drops the template's "cannot package the template" `if:` guard.

**Evidence:**

```yaml
# .github/workflows/release.yaml:49-54
run: |
  if [ "$IS_PRERELEASE" = 'true' ]; then
    yarn package --dev --prerelease
  else
    yarn package --dev
  fi
# .github/workflows/release.yaml:63
gh release upload "${{ github.event.release.tag_name }}" ./*.tgz --clobber
```

Template (`companion-module-template-ts` @ e0d42b7):

```yaml
uses: bitfocus/actions/.github/workflows/module-checks.yaml@main
with:
  git-ref: ${{ github.event.release.tag_name }}
  prerelease: ${{ github.event.release.prerelease }}
  upload-artifact: true
```

**Confirm by:** `diff companion-module-template-ts/.github/workflows/release.yaml .github/workflows/release.yaml` against [`.github/workflows/release.yaml`](https://github.com/bitfocus/companion-module-generic-swp02/blob/a7d3f68a51c87f599168566aaf18a7aa98f2acd0/.github/workflows/release.yaml) shows no output once fixed.

**Fix:** replace the file with the template's `release.yaml`.

## 🟡 Medium

### M1: Buttons that picked the destination or source from a custom variable may stop running after the upgrade to 2.0.0

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/upgrades.ts:34-46`](https://github.com/bitfocus/companion-module-generic-swp02/blob/a7d3f68a51c87f599168566aaf18a7aa98f2acd0/src/upgrades.ts#L34-L46), [`src/upgrades.ts:66-81`](https://github.com/bitfocus/companion-module-generic-swp02/blob/a7d3f68a51c87f599168566aaf18a7aa98f2acd0/src/upgrades.ts#L66-L81), [`src/options.ts:12-29`](https://github.com/bitfocus/companion-module-generic-swp02/blob/a7d3f68a51c87f599168566aaf18a7aa98f2acd0/src/options.ts#L12-L29)

**What goes wrong:** A user on v1.2.3 has a "Connect" action whose Destination is the custom variable `$(internal:custom_dst)`, which holds the text `"5"`. In v1 that worked: the old Destination dropdown accepted custom values and the module ran `parseInt` on them. After the upgrade, the option becomes the expression `$(internal:custom_dst)`, which still returns the text `"5"`. If Companion doesn't treat `"5"` as matching the choice "Destination 5" (id `5`), it skips the action, so the button does nothing and the "Crosspoint" feedback stops updating. The same applies to Source, and to any variable holding a number as text. Users who picked a destination and source from the dropdown are not affected (see [A1](#-assumptions-to-confirm)).

**Why it happens:** The first upgrade script passes each Destination/Source value through the base helper `FixupNumericOrVariablesValueToExpressions`, which turns a plain `$(...)` reference into a bare expression without converting it to a number (`node_modules/@companion-module/base/dist/module-api/upgrade.js:149-158`). The new Destination and Source options are dropdowns with numeric ids (1, 2, 3…) and no `allowCustom`, and in expression mode the result must match one of those ids.

**Fix:** first upgrade a v1.2.3 install with an action and a feedback whose Destination/Source is a custom variable holding a number as text, and check the button still fires. If it doesn't, either rewrite a bare `$(...)` result to `parseInt($(...))` in `fixupNumericOptions` (in a new upgrade script if v2.0.0 has already shipped), or make Destination/Source `type: 'number'` fields (min 1, max = count), which Companion converts to a number before validating.

## 🟢 Low

### L1: The Go action's Mode option needs 0 or 1 in expression mode

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/options.ts:41-53`](https://github.com/bitfocus/companion-module-generic-swp02/blob/a7d3f68a51c87f599168566aaf18a7aa98f2acd0/src/options.ts#L41-L53)

**What goes wrong:** A user who switches the "Go" action's Mode to expression mode must return `0` for Set and `1` for Clear (as the option's description and HELP.md say). Typing `set` or `clear` makes Companion skip the action. Normal use, picking Set or Clear from the dropdown, is unaffected.

**Why it happens:** The Mode choices use the protocol byte values (`GoMode.Set = 0x00`, `GoMode.Clear = 0x01`) as their ids. The v2.0 rules recommend readable string ids for dropdowns, because users type them in expression mode, and `disableAutoExpression: true` for options that rarely make sense as an expression, such as a two-state Set/Clear choice.

**Fix:** optional. Either add `disableAutoExpression: true` to `goModeOption`, or switch the ids to `'set'`/`'clear'`, map them to `GoMode` in the callback, and add an upgrade script that rewrites saved `0`/`1` values.

## 💡 Nice to Have

### N1: A pending Learn keeps its 3-second timer running after the connection is disabled

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/api/router.ts:205-229`](https://github.com/bitfocus/companion-module-generic-swp02/blob/a7d3f68a51c87f599168566aaf18a7aa98f2acd0/src/api/router.ts#L205-L229), [`src/api/router.ts:169-171`](https://github.com/bitfocus/companion-module-generic-swp02/blob/a7d3f68a51c87f599168566aaf18a7aa98f2acd0/src/api/router.ts#L169-L171)

**What goes wrong:** Nothing a user sees. If a user clicks Learn on a "Connect" action or a "Crosspoint" feedback and then disables or deletes the connection within 3 seconds, the wait timer keeps running for the rest of those 3 seconds and then ends the Learn with no result.

**Why it happens:** When the connection is removed, `RouterConnection.destroy()` calls `removeAllListeners()`, which drops the waiting crosspoint listener. The 3-second timer that `waitForCrosspoint` starts is local to that wait, so `destroy()` can't clear it; it only ends when it fires.

**Fix:** optional. Keep the pending Learn waits in a `Set` on `RouterConnection`, and in `destroy()` clear each one's timer and settle it (resolve `undefined`, or reject with "Router connection destroyed"), so nothing the module started outlives `destroy()`.

## 📝 Additional Notes

- `tsconfig.build.json` differs from the template: `exclude` uses `src/**/__tests__/**` and `src/**/__mocks__/**` where the template has `src/**/__tests__/*` and `src/**/__mocks__/*`. Fine as long as the module builds — no change required.
- The module is on API 2.2 (base 2.2.1). The review checked it against the API 2.0 and 2.1 rules only; changes introduced in API 2.2 were not checked.
