# Review: companion-module-panasonic-av-hsw10 v2.0.0

| Field | Value |
| --- | --- |
| **Module** | `companion-module-panasonic-av-hsw10` |
| **Scope** | `tag` (changes from v1.0.1 to v2.0.0) |
| **Version** | v2.0.0 |
| **Release** | Update — last published v1.0.1 |
| **API** | 2.2 (base 2.2.1, yarn.lock) |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Commit** | [`7bc31da`](https://github.com/bitfocus/companion-module-panasonic-av-hsw10/tree/7bc31dac3432447cf988ef41ade226a075891760) |
| **Date** | 2026-10-30 |

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | When a dropdown option is in expression mode and the expression returns a number that loosely equals a choice id (`113` and `'113'`), Companion passes the raw number to the action or feedback callback, rather than replacing it with the matching choice id string | The module's own comment in [`src/options.ts:194-197`](https://github.com/bitfocus/companion-module-panasonic-av-hsw10/blob/7bc31dac3432447cf988ef41ade226a075891760/src/options.ts#L194-L197) says the comparison is loose. The base 2.2 typings for `allowInvalidValues` describe validation, not coercion. Companion's host code was not checked; if Companion normalises the value to the choice id, M1 goes away | [M1](#m1-bus-source-action-and-feedback-reject-a-bus-or-source-that-an-expression-returns-as-a-number) |
| A2 | Companion's expression parser evaluates a bare `01` to the number `1` | Standard JS-style expression parsing; not checked against Companion's source | [M1](#m1-bus-source-action-and-feedback-reject-a-bus-or-source-that-an-expression-returns-as-a-number) |
| A3 | The Node 26 runtime Companion uses for this module (manifest runtime `node26`) keeps memory for each `AbortSignal.any()` the same way Node 22 does | Measured on Node v22.21.1 with the module's p-queue 10.0.0; Node 26 not tested | [L1](#l1-each-action-press-holds-a-little-memory-until-the-connection-reconnects) |

## 📋 Issues

### Blocking

- [ ] [C1: Yarn settings file has an extra setting the template does not have](#c1-yarn-settings-file-has-an-extra-setting-the-template-does-not-have)
- [ ] [H1: The CI workflow differs from the template](#h1-the-ci-workflow-differs-from-the-template)
- [ ] [H2: The release workflow builds the package itself instead of using the Bitfocus shared workflow](#h2-the-release-workflow-builds-the-package-itself-instead-of-using-the-bitfocus-shared-workflow)

### Non-blocking

- [ ] [M1: Bus Source action and feedback reject a bus or source that an expression returns as a number](#m1-bus-source-action-and-feedback-reject-a-bus-or-source-that-an-expression-returns-as-a-number)
- [ ] [L1: Each action press holds a little memory until the connection reconnects](#l1-each-action-press-holds-a-little-memory-until-the-connection-reconnects)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🔴 Critical

### C1: Yarn settings file has an extra setting the template does not have

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.yarnrc.yml:1-2`](https://github.com/bitfocus/companion-module-panasonic-av-hsw10/blob/7bc31dac3432447cf988ef41ade226a075891760/.yarnrc.yml#L1-L2)

**What goes wrong:** The module's Yarn settings file allows dependencies to be installed from any Git repository. That setting is not in the template, so the module's install behaviour differs from every other module built on the template, and anyone troubleshooting a build has to notice and account for it.

**Why it happens:** `.yarnrc.yml` should match the template's copy exactly. The template's file has only `enableScripts: false`, `nodeLinker: node-modules`, `npmMinimalAgeGate: 3d` and `npmPreapprovedPackages: ["@companion-module/*"]`. The module has all four, plus `approvedGitRepositories`.

**Evidence:**

Validator: `.yarnrc.yml`: Extra keys not in template: approvedGitRepositories

```yaml
# .yarnrc.yml:1-2
approvedGitRepositories:
  - "**"
```

**Confirm by:** open [`.yarnrc.yml:1-2`](https://github.com/bitfocus/companion-module-panasonic-av-hsw10/blob/7bc31dac3432447cf988ef41ade226a075891760/.yarnrc.yml#L1-L2). After the fix, the file contains no `approvedGitRepositories` key, and re-running validate-template reports no `.yarnrc.yml` CONFIG-DIFF.

**Fix:** remove the `approvedGitRepositories` key, so the file matches `companion-module-template-ts`'s `.yarnrc.yml` exactly.

## 🟠 High

### H1: The CI workflow differs from the template

- **Source:** 🤖 validate-template (CONFIG-DIFF), raised to High by the review maintainer (`.github` file differs from the template)
- **Classification:** 🆕 NEW
- **File:** [`.github/workflows/node.yaml`](https://github.com/bitfocus/companion-module-panasonic-av-hsw10/blob/7bc31dac3432447cf988ef41ade226a075891760/.github/workflows/node.yaml)

**What goes wrong:** The GitHub Actions workflow that lints and tests every push is a customised copy rather than the template's. When the template's workflow is updated, this module won't pick up the change cleanly, and anyone comparing its CI with other modules finds different steps, action versions and a third-party upload.

**Why it happens:** The module edited the template's `node.yaml` instead of using it as is. The template's own way to turn on unit tests is to uncomment its `test` job; the module wrote its own job instead.

**Evidence:**

Validator: Differs from template (line 11: found 'permissions:', template 'jobs:'). Compared with `companion-module-template-ts` @ `e0d42b7`:

- [`.github/workflows/node.yaml:11-12`](https://github.com/bitfocus/companion-module-panasonic-av-hsw10/blob/7bc31dac3432447cf988ef41ade226a075891760/.github/workflows/node.yaml#L11-L12) adds a top-level `permissions: contents: read` that the template does not have.
- The template's `actions/checkout` step has `with: persist-credentials: false`, which the module removed ([`:21`](https://github.com/bitfocus/companion-module-panasonic-av-hsw10/blob/7bc31dac3432447cf988ef41ade226a075891760/.github/workflows/node.yaml#L21)).
- [`:24`](https://github.com/bitfocus/companion-module-panasonic-av-hsw10/blob/7bc31dac3432447cf988ef41ade226a075891760/.github/workflows/node.yaml#L24) and [`:56`](https://github.com/bitfocus/companion-module-panasonic-av-hsw10/blob/7bc31dac3432447cf988ef41ade226a075891760/.github/workflows/node.yaml#L56) use `actions/setup-node@v7`; the template uses `actions/setup-node@v6`.
- The template's "Prepare Environment (For template repository)" step was removed.
- [`:38`](https://github.com/bitfocus/companion-module-panasonic-av-hsw10/blob/7bc31dac3432447cf988ef41ade226a075891760/.github/workflows/node.yaml#L38) adds `yarn test:types` to the lint job.
- [`:47-81`](https://github.com/bitfocus/companion-module-panasonic-av-hsw10/blob/7bc31dac3432447cf988ef41ade226a075891760/.github/workflows/node.yaml#L47-L81) turns the template's commented-out `test` job into a live job with a separate "Prepare module" step, runs `yarn test:coverage` instead of `yarn test`, and adds a `codecov/codecov-action@v7` upload step ([`:73`](https://github.com/bitfocus/companion-module-panasonic-av-hsw10/blob/7bc31dac3432447cf988ef41ade226a075891760/.github/workflows/node.yaml#L73)).

```diff
+permissions:
+  contents: read
+
-        with:
-          persist-credentials: false
-        uses: actions/setup-node@v6
+        uses: actions/setup-node@v7
+          yarn test:types
+      - name: Run tests
+        run: |
+          yarn test:coverage
+      - name: Send coverage
+        uses: codecov/codecov-action@v7
```

**Confirm by:** `diff companion-module-template-ts/.github/workflows/node.yaml .github/workflows/node.yaml` shows no differences other than the uncommented template `test` job, and validate-template reports no CONFIG-DIFF for [`.github/workflows/node.yaml`](https://github.com/bitfocus/companion-module-panasonic-av-hsw10/blob/7bc31dac3432447cf988ef41ade226a075891760/.github/workflows/node.yaml).

**Fix:** replace `.github/workflows/node.yaml` with the template's copy. To run unit tests in CI, uncomment the template's `test` job.

### H2: The release workflow builds the package itself instead of using the Bitfocus shared workflow

- **Source:** 🤖 validate-template (CONFIG-DIFF), raised to High by the review maintainer (`.github` file differs from the template)
- **Classification:** 🆕 NEW
- **File:** [`.github/workflows/release.yaml:10-65`](https://github.com/bitfocus/companion-module-panasonic-av-hsw10/blob/7bc31dac3432447cf988ef41ade226a075891760/.github/workflows/release.yaml#L10-L65)

**What goes wrong:** When a GitHub release is published, the package attached to it is built by a hand-written job, as a development (`--dev`) build, and attached under whatever file name `yarn package` produces. The template's workflow builds through Bitfocus's shared module-checks workflow and attaches it as `<name>-<version>.tgz`. The attached package can therefore differ from what the template would produce.

**Why it happens:** The module replaced the template's two jobs (`package`, which calls `bitfocus/actions/.github/workflows/module-checks.yaml@main`, and `attach`, which downloads the `pkg` artifact and uploads it) with a single job that checks out, installs and packages the code itself.

**Evidence:**

Validator: Differs from template (line 10: found '# Deliberately does not run lint or tests. This fires on release: published, by', template 'jobs:'). Compared with `companion-module-template-ts` @ `e0d42b7`:

- [`.github/workflows/release.yaml:10-13`](https://github.com/bitfocus/companion-module-panasonic-av-hsw10/blob/7bc31dac3432447cf988ef41ade226a075891760/.github/workflows/release.yaml#L10-L13) adds a comment block.
- [`:16`](https://github.com/bitfocus/companion-module-panasonic-av-hsw10/blob/7bc31dac3432447cf988ef41ade226a075891760/.github/workflows/release.yaml#L16) and [`:18`](https://github.com/bitfocus/companion-module-panasonic-av-hsw10/blob/7bc31dac3432447cf988ef41ade226a075891760/.github/workflows/release.yaml#L18): one job, `name: Package and attach to release`, `timeout-minutes: 15`, replaces the template's `package` job (with its template-repo `if:` guard, `permissions: packages: read`, `git-ref`, `prerelease` and `upload-artifact: true`) and its `attach` job.
- [`:24`](https://github.com/bitfocus/companion-module-panasonic-av-hsw10/blob/7bc31dac3432447cf988ef41ade226a075891760/.github/workflows/release.yaml#L24) checks out the code itself, then sets up Node 26.x and runs `yarn install`.
- [`:51`](https://github.com/bitfocus/companion-module-panasonic-av-hsw10/blob/7bc31dac3432447cf988ef41ade226a075891760/.github/workflows/release.yaml#L51) and [`:53`](https://github.com/bitfocus/companion-module-panasonic-av-hsw10/blob/7bc31dac3432447cf988ef41ade226a075891760/.github/workflows/release.yaml#L53) run `yarn package --dev [--prerelease]`.
- [`:63`](https://github.com/bitfocus/companion-module-panasonic-av-hsw10/blob/7bc31dac3432447cf988ef41ade226a075891760/.github/workflows/release.yaml#L63) uploads `./*.tgz` directly; the template renames the file to `<name>-<version>.tgz` and passes `--repo "$GITHUB_REPOSITORY"` and the `TAG` env.

```yaml
# .github/workflows/release.yaml:50-54, 63
if [ "$IS_PRERELEASE" = 'true' ]; then
  yarn package --dev --prerelease
else
  yarn package --dev
fi
gh release upload "${{ github.event.release.tag_name }}" ./*.tgz --clobber
```

**Confirm by:** `diff companion-module-template-ts/.github/workflows/release.yaml .github/workflows/release.yaml` shows no differences, and validate-template reports no CONFIG-DIFF for [`.github/workflows/release.yaml`](https://github.com/bitfocus/companion-module-panasonic-av-hsw10/blob/7bc31dac3432447cf988ef41ade226a075891760/.github/workflows/release.yaml).

**Fix:** replace `.github/workflows/release.yaml` with the template's copy, which builds the package through Bitfocus's shared module-checks workflow.

## 🟡 Medium

### M1: Bus Source action and feedback reject a bus or source that an expression returns as a number

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🔙 REGRESSION
- **File:** [`src/actions.ts:84-91`](https://github.com/bitfocus/companion-module-panasonic-av-hsw10/blob/7bc31dac3432447cf988ef41ade226a075891760/src/actions.ts#L84-L91), [`src/actions.ts:129-130`](https://github.com/bitfocus/companion-module-panasonic-av-hsw10/blob/7bc31dac3432447cf988ef41ade226a075891760/src/actions.ts#L129-L130), [`src/feedbacks.ts:49-56`](https://github.com/bitfocus/companion-module-panasonic-av-hsw10/blob/7bc31dac3432447cf988ef41ade226a075891760/src/feedbacks.ts#L49-L56), [`src/feedbacks.ts:70`](https://github.com/bitfocus/companion-module-panasonic-av-hsw10/blob/7bc31dac3432447cf988ef41ade226a075891760/src/feedbacks.ts#L70), [`src/upgrades.ts:46-49`](https://github.com/bitfocus/companion-module-panasonic-av-hsw10/blob/7bc31dac3432447cf988ef41ade226a075891760/src/upgrades.ts#L46-L49)

**What goes wrong:** A user switches the Bus or Source option of the "Bus Source" action to expression mode and types `113` (AUX 1) or `148` (BLACK), as the option's description suggests. The expression returns the number 113, not the text `'113'`, so pressing the button logs "Bus 113 is not valid" and nothing is switched. Existing v1.0.1 buttons whose bus was a custom value such as `$(internal:custom_bus)` holding 113 break the same way after the upgrade; in v1.0.1 they worked. The "Bus Source" feedback has the same gap: it never turns red when its bus or source comes from a numeric expression. Buttons that pick the bus and source from the dropdown are not affected.

**Why it happens:** The action checks each value with `choice()`, which only accepts strings, and the feedback compares the source with `===` against the string codes. The module's own comment in `src/options.ts` notes that Companion compares an expression's result with the choice ids loosely, so Companion lets the number through and the module then rejects it (see [A1](#-assumptions-to-confirm)). Upgrade script 0 turns a lone `$(var)` custom value into a bare expression, which keeps the variable's numeric type; v1.0.1 parsed variables into text, so it always produced `'113'`.

**Fix:** normalise dropdown values before checking them. In `choice()`, `watchBusSource()` and the Bus Source feedback, convert a number with `String(value)`, and for the two-digit codes (`01`-`10`) also try `String(value).padStart(2, '0')`. Compare `String(options.source)` the same way in the feedback, and add tests for numeric expression results (bus 113, source 148, source 5 to `'05'`).

## 🟢 Low

### L1: Each action press holds a little memory until the connection reconnects

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/connection.ts:117-133`](https://github.com/bitfocus/companion-module-panasonic-av-hsw10/blob/7bc31dac3432447cf988ef41ade226a075891760/src/connection.ts#L117-L133)

**What goes wrong:** No visible effect in normal use. Each button press that sends a message (for example Bus Source PGM to INPUT 3) keeps about 180 bytes in memory for as long as the TCP connection stays up: 10,000 presses add about 1.8 MB. A connection that stays up for weeks with heavy use grows slowly; the memory is freed only on reconnect or a config save.

**Why it happens:** Every send combines the connection's long-lived abort signal with the action's signal using `AbortSignal.any()`. Node keeps a record of each combined signal on the long-lived one until that signal goes away. p-queue's own source warns against this pattern. Measured with the module's p-queue 10.0.0 on Node 22 (see [A3](#-assumptions-to-confirm)); passing the session signal alone stayed flat.

**Fix:** don't combine signals per message. Pass only the action's signal (or none) to `queue.add`, and inside the job check `session.signal.aborted` or `this.#session !== session` before writing.

## 📝 Additional Notes

- `tsconfig.build.json`: `exclude` uses `src/**/__tests__/**` and `src/**/__mocks__/**`, where the template has `src/**/__tests__/*` and `src/**/__mocks__/*` (TSCONFIG-DIFF). Fine as long as the module builds; no change required.
- The module is on API 2.2 (base 2.2.1). The compliance checklist has no 2.2 rules yet, so the module was checked against the API 2.0 and 2.1 rules only; 2.2-specific rules were not checked.
