# Review: companion-module-evertz-symphony v2.0.0

| | |
| --- | --- |
| **Module** | `companion-module-evertz-symphony` |
| **Scope** | `tag` (`v1.0.4..v2.0.0`) |
| **Version** | v2.0.0 |
| **Release** | Update — last published v1.0.4 |
| **API** | 2.2 (base 2.2.1, yarn.lock) — requires Companion 5.0+ (2.1 floor; no v2.2 reference available to confirm a higher minimum) |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Commit** | [`722c552`](https://github.com/bitfocus/companion-module-evertz-symphony/tree/722c5524563a35ad15e1fb612f211d4c30b317eb) |
| **Review date** | 2026-10-30 |

## Verdict: ❌ Changes Required

## 📋 Issues

### Blocking

- [ ] [C1: Yarn is allowed to install dependencies from any Git repository](#c1-yarn-is-allowed-to-install-dependencies-from-any-git-repository)
- [ ] [C2: The module lists its maintainer without a contact email](#c2-the-module-lists-its-maintainer-without-a-contact-email)
- [ ] [H1: The CI workflow differs from the template](#h1-the-ci-workflow-differs-from-the-template)
- [ ] [H2: Releases are packaged by a custom workflow instead of the shared Bitfocus one](#h2-releases-are-packaged-by-a-custom-workflow-instead-of-the-shared-bitfocus-one)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🔴 Critical

### C1: Yarn is allowed to install dependencies from any Git repository

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.yarnrc.yml:1-2`](https://github.com/bitfocus/companion-module-evertz-symphony/blob/722c5524563a35ad15e1fb612f211d4c30b317eb/.yarnrc.yml#L1-L2)

**What goes wrong:** Anyone installing or building the module (the maintainer, CI, or the Bitfocus build) runs Yarn with a setting that approves dependencies pulled straight from any Git repository. The template keeps that list closed, so this module's install is less locked down than every other template-based module.

**Why it happens:** This release added an `approvedGitRepositories` key with the wildcard `'**'` to `.yarnrc.yml`. The template's `.yarnrc.yml` has only `enableScripts`, `nodeLinker`, `npmMinimalAgeGate` and `npmPreapprovedPackages`; the rest of the module's file now matches those.

**Evidence:** validator: "Extra keys not in template: approvedGitRepositories".

```yaml
# .yarnrc.yml:1-2
approvedGitRepositories:
  - '**'
```

**Confirm by:** open [`.yarnrc.yml:1-2`](https://github.com/bitfocus/companion-module-evertz-symphony/blob/722c5524563a35ad15e1fb612f211d4c30b317eb/.yarnrc.yml#L1-L2). The template's `.yarnrc.yml` has no `approvedGitRepositories` key.

**Fix:** delete the `approvedGitRepositories` block so the file holds only the template's four keys.

```yaml
enableScripts: false

nodeLinker: node-modules

npmMinimalAgeGate: 3d

npmPreapprovedPackages:
  - '@companion-module/*'
```

### C2: The module lists its maintainer without a contact email

- **Source:** 🤖 validate-template (MAN-PLACEHOLDER)
- **Classification:** 🆕 NEW (flagged by the template check; the maintainers block itself is unchanged since v1.0.4)
- **File:** [`companion/manifest.json:13-16`](https://github.com/bitfocus/companion-module-evertz-symphony/blob/722c5524563a35ad15e1fb612f211d4c30b317eb/companion/manifest.json#L13-L16)

**What goes wrong:** Users and the Bitfocus team who need to reach the maintainer about this module (a bug report, a device question) find a name but no email address in the module's details.

**Why it happens:** The manifest's `maintainers` entry has the maintainer's name, but its `email` field is an empty string, which the template check treats as an unfilled placeholder.

**Evidence:** validator: "Placeholder maintainer: name='Phillip Ivan Pietruschka' email=''".

```json
// companion/manifest.json:13-16
{
	"name": "Phillip Ivan Pietruschka",
	"email": ""
}
```

**Confirm by:** open [`companion/manifest.json:15`](https://github.com/bitfocus/companion-module-evertz-symphony/blob/722c5524563a35ad15e1fb612f211d4c30b317eb/companion/manifest.json#L15). `maintainers[0].email` is empty.

**Fix:** fill in a contact email for the maintainer.

```json
{
	"name": "Phillip Ivan Pietruschka",
	"email": "you@example.com"
}
```

## 🟠 High

### H1: The CI workflow differs from the template

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.github/workflows/node.yaml:11-12`](https://github.com/bitfocus/companion-module-evertz-symphony/blob/722c5524563a35ad15e1fb612f211d4c30b317eb/.github/workflows/node.yaml#L11-L12), [`.github/workflows/node.yaml:21-24`](https://github.com/bitfocus/companion-module-evertz-symphony/blob/722c5524563a35ad15e1fb612f211d4c30b317eb/.github/workflows/node.yaml#L21-L24), [`.github/workflows/node.yaml:38`](https://github.com/bitfocus/companion-module-evertz-symphony/blob/722c5524563a35ad15e1fb612f211d4c30b317eb/.github/workflows/node.yaml#L38), [`.github/workflows/node.yaml:47-81`](https://github.com/bitfocus/companion-module-evertz-symphony/blob/722c5524563a35ad15e1fb612f211d4c30b317eb/.github/workflows/node.yaml#L47-L81)

**What goes wrong:** The GitHub Actions check that runs on every push and pull request (added in this release) doesn't match the template's. Anyone troubleshooting a CI failure on this module, or comparing it with other modules, finds different steps, action versions and settings.

**Why it happens:** The workflow was written by hand rather than copied from the template. It adds a top-level `permissions` block, drops the template's `persist-credentials: false` on the checkout step, uses `actions/setup-node@v7` where the template uses `@v6`, adds a `yarn test:types` step, removes the template's "Prepare Environment (For template repository)" step, and replaces the template's commented-out `test` job with a live job that runs `yarn test:coverage` and uploads to Codecov.

**Evidence:** validator: "Differs from template (line 11: found 'permissions:', template 'jobs:')".

```yaml
# .github/workflows/node.yaml:11-12
permissions:
  contents: read
# .github/workflows/node.yaml:21-24
      - uses: actions/checkout@v7
      - name: Use Node.js 26.x
        # This should match the version of Node.js you have defined in the manifest.json runtime field
        uses: actions/setup-node@v7
# .github/workflows/node.yaml:38
          yarn test:types
# .github/workflows/node.yaml:67-73
      - name: Run tests
        run: |
          yarn test:coverage
        env:
          CI: true
      - name: Send coverage
        uses: codecov/codecov-action@v7
```

**Confirm by:** `diff` [`.github/workflows/node.yaml`](https://github.com/bitfocus/companion-module-evertz-symphony/blob/722c5524563a35ad15e1fb612f211d4c30b317eb/.github/workflows/node.yaml) against `companion-module-template-ts/.github/workflows/node.yaml`; after the fix it should show only the uncommented test job.

**Fix:** copy the template's `node.yaml`. Uncommenting the template's own `test` job is fine if you want tests to run in CI.

### H2: Releases are packaged by a custom workflow instead of the shared Bitfocus one

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.github/workflows/release.yaml:10-13`](https://github.com/bitfocus/companion-module-evertz-symphony/blob/722c5524563a35ad15e1fb612f211d4c30b317eb/.github/workflows/release.yaml#L10-L13), [`.github/workflows/release.yaml:14-65`](https://github.com/bitfocus/companion-module-evertz-symphony/blob/722c5524563a35ad15e1fb612f211d4c30b317eb/.github/workflows/release.yaml#L14-L65)

**What goes wrong:** When the maintainer publishes a GitHub release, the package attached to it is built by this module's own steps (a `--dev` build) rather than by the shared Bitfocus module-checks workflow every template-based module uses. The attached `.tgz` can differ from what other modules produce, and fixes Bitfocus makes to the shared workflow never reach this module.

**Why it happens:** This release added a `release.yaml` that replaces the template's two jobs (`package`, which calls `bitfocus/actions/.github/workflows/module-checks.yaml@main`, and `attach`, which renames the package to `<name>-<version>.tgz` and uploads it) with one self-built job. That job checks out and builds the module itself, runs `yarn package --dev`, and uploads with the release tag written straight into the shell command instead of through the template's `TAG` environment variable. It also drops the template's guard that skips packaging in the template repository.

**Evidence:** validator: "Differs from template (line 10: found '# Deliberately does not run lint or tests. This fires on release: published, by', template 'jobs:')".

```yaml
# .github/workflows/release.yaml:14-16
jobs:
  package:
    name: Package and attach to release
# .github/workflows/release.yaml:49-54
        run: |
          if [ "$IS_PRERELEASE" = 'true' ]; then
            yarn package --dev --prerelease
          else
            yarn package --dev
          fi
# .github/workflows/release.yaml:62-63
        run: |
          gh release upload "${{ github.event.release.tag_name }}" ./*.tgz --clobber
```

**Confirm by:** `diff` [`.github/workflows/release.yaml`](https://github.com/bitfocus/companion-module-evertz-symphony/blob/722c5524563a35ad15e1fb612f211d4c30b317eb/.github/workflows/release.yaml) against `companion-module-template-ts/.github/workflows/release.yaml`; after the fix it should be empty.

**Fix:** replace the file with the template's `release.yaml`, which packages through the shared Bitfocus workflow and attaches the result.

## 📝 Additional Notes

- `tsconfig.build.json` differs from the template: [`tsconfig.build.json:4`](https://github.com/bitfocus/companion-module-evertz-symphony/blob/722c5524563a35ad15e1fb612f211d4c30b317eb/tsconfig.build.json#L4) excludes `src/**/__tests__/**` and `src/**/__mocks__/**` where the template has `src/**/__tests__/*` and `src/**/__mocks__/*`. Fine as long as the module builds — no change required.
- The module is on API 2.2 (`@companion-module/base` 2.2.1). No API 2.2 reference exists in the review skills yet, so API compliance was checked against the 2.0 and 2.1 references only.
