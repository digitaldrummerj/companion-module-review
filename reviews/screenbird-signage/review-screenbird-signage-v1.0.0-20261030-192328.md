# Review: screenbird-signage v1.0.0

| Field | Value |
| --- | --- |
| **Module** | `companion-module-screenbird-signage` |
| **Scope** | `tag` |
| **Version** | v1.0.0 |
| **Release** | New module — never published |
| **API** | 2.0 (base 2.0.4, yarn.lock) — requires Companion 4.3+ |
| **Template** | `companion-module-template-ts-v2.0.4` @ `d62230e` (2026-08-28, pinned) · `.yarnrc.yml` from `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Review commit** | [`07ed62f`](https://github.com/bitfocus/companion-module-screenbird-signage/tree/07ed62f76687cc08e78a8f2477ef8060e45a415d) |
| **Review date** | 2026-10-30 |

This is the module's first release, so there is no previous tag to diff against: the whole module was reviewed, and every finding is classified 🆕 NEW. `yarn install --immutable`, `yarn package` and `yarn lint` all passed.

## Verdict: ❌ Changes Required

## 📋 Issues

### Blocking

- [ ] [C1: Prettier ignores a different license file than the template](#c1-prettier-ignores-a-different-license-file-than-the-template)
- [ ] [C2: Yarn is missing the template's pre-approval for Companion packages](#c2-yarn-is-missing-the-templates-pre-approval-for-companion-packages)
- [ ] [C3: Yarn package age gate uses a different value than the template](#c3-yarn-package-age-gate-uses-a-different-value-than-the-template)
- [ ] [H1: CI builds on Node.js 26 instead of the Node.js 22 the module runs on](#h1-ci-builds-on-nodejs-26-instead-of-the-nodejs-22-the-module-runs-on)

### Non-blocking

- [ ] [L1: Scene go and Scene stop with no scene chosen fail with an unclear HTTP error](#l1-scene-go-and-scene-stop-with-no-scene-chosen-fail-with-an-unclear-http-error)
- [ ] [N1: Unused refresh method on the module instance](#n1-unused-refresh-method-on-the-module-instance)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🔴 Critical

### C1: Prettier ignores a different license file than the template

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.prettierignore:2`](https://github.com/bitfocus/companion-module-screenbird-signage/blob/07ed62f76687cc08e78a8f2477ef8060e45a415d/.prettierignore#L2)

**What goes wrong:** The module's `.prettierignore` no longer matches the official template, so anyone comparing the module with the template (or troubleshooting formatting later) sees an unexpected difference.

**Why it happens:** The second line was changed from the template's `/LICENSE.md` to `/LICENSE`. This is a changed template entry, not an extra entry for a generated file.

**Evidence:**

```text
.prettierignore:2   found:    /LICENSE
template:           expected: /LICENSE.md
```

**Confirm by:** `diff companion-module-template-ts-v2.0.4/.prettierignore .prettierignore` against [`.prettierignore`](https://github.com/bitfocus/companion-module-screenbird-signage/blob/07ed62f76687cc08e78a8f2477ef8060e45a415d/.prettierignore).

**Fix:** copy the template's `.prettierignore` into the module.

```text
package.json
/LICENSE.md
```

### C2: Yarn is missing the template's pre-approval for Companion packages

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.yarnrc.yml`](https://github.com/bitfocus/companion-module-screenbird-signage/blob/07ed62f76687cc08e78a8f2477ef8060e45a415d/.yarnrc.yml)

**What goes wrong:** Without the template's pre-approval list, a freshly released `@companion-module/*` package is held back by the package age gate like any other package, so the module can't pick up a new Companion base or tools release until the gate expires.

**Why it happens:** The template's `.yarnrc.yml` has an `npmPreapprovedPackages` key that exempts `@companion-module/*` from the age gate. The module's file has only `nodeLinker`, `enableScripts` and `npmMinimalAgeGate`.

**Evidence:**

```yaml
# .yarnrc.yml (module)
nodeLinker: node-modules
enableScripts: false
npmMinimalAgeGate: 10080
# template also has:
npmPreapprovedPackages:
  - "@companion-module/*"
```

**Confirm by:** compare [`.yarnrc.yml`](https://github.com/bitfocus/companion-module-screenbird-signage/blob/07ed62f76687cc08e78a8f2477ef8060e45a415d/.yarnrc.yml) with `companion-module-template-ts/.yarnrc.yml`.

**Fix:** copy the template's `.yarnrc.yml` into the module (this also fixes [C3](#c3-yarn-package-age-gate-uses-a-different-value-than-the-template)).

```yaml
enableScripts: false

nodeLinker: node-modules

npmMinimalAgeGate: 3d

npmPreapprovedPackages:
  - "@companion-module/*"
```

### C3: Yarn package age gate uses a different value than the template

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.yarnrc.yml:3`](https://github.com/bitfocus/companion-module-screenbird-signage/blob/07ed62f76687cc08e78a8f2477ef8060e45a415d/.yarnrc.yml#L3)

**What goes wrong:** The module waits a week (10080 minutes) before Yarn will install a newly published package, where the template waits 3 days. Dependency updates behave differently from every other module built on the template.

**Why it happens:** `npmMinimalAgeGate` was set to `10080` instead of the template's `3d`.

**Evidence:**

```text
.yarnrc.yml:3   found:    npmMinimalAgeGate: 10080
template:       expected: npmMinimalAgeGate: 3d
```

**Confirm by:** compare [`.yarnrc.yml:3`](https://github.com/bitfocus/companion-module-screenbird-signage/blob/07ed62f76687cc08e78a8f2477ef8060e45a415d/.yarnrc.yml#L3) with `companion-module-template-ts/.yarnrc.yml`.

**Fix:** set `npmMinimalAgeGate: 3d`; copying the template's `.yarnrc.yml` (see [C2](#c2-yarn-is-missing-the-templates-pre-approval-for-companion-packages)) does this too.

## 🟠 High

### H1: CI builds on Node.js 26 instead of the Node.js 22 the module runs on

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.github/workflows/node.yaml:18-25`](https://github.com/bitfocus/companion-module-screenbird-signage/blob/07ed62f76687cc08e78a8f2477ef8060e45a415d/.github/workflows/node.yaml#L18-L25)

**What goes wrong:** The GitHub CI check builds and lints the module on Node.js 26, but Companion runs it on Node.js 22 (the manifest's runtime is `node22`). A green CI run doesn't prove the module works on the Node.js version it actually ships on, and the workflow no longer matches the template.

**Why it happens:** The workflow was edited away from the API 2.0 template: the checkout step gained `with: persist-credentials: false`, the Node.js step was changed from `22.x` to `26.x`, and the commented-out test job was also changed to `26.x`.

**Evidence:**

```yaml
# .github/workflows/node.yaml:18-25 (module)
      - uses: actions/checkout@v7
        with:
          persist-credentials: false
      - name: Use Node.js 26.x
        # This should match the version of Node.js you have defined in the manifest.json runtime field
        uses: actions/setup-node@v6
        with:
          node-version: 26.x
# template (companion-module-template-ts-v2.0.4):
      - uses: actions/checkout@v7
      - name: Use Node.js 22.x
        ...
          node-version: 22.x
```

**Confirm by:** `diff companion-module-template-ts-v2.0.4/.github/workflows/node.yaml .github/workflows/node.yaml`, and see [`.github/workflows/node.yaml:62-65`](https://github.com/bitfocus/companion-module-screenbird-signage/blob/07ed62f76687cc08e78a8f2477ef8060e45a415d/.github/workflows/node.yaml#L62-L65) for the test job.

**Fix:** copy the template's `node.yaml` into the module, so CI uses Node.js 22.x to match the manifest.

## 🟢 Low

### L1: Scene go and Scene stop with no scene chosen fail with an unclear HTTP error

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:19-25`](https://github.com/bitfocus/companion-module-screenbird-signage/blob/07ed62f76687cc08e78a8f2477ef8060e45a415d/src/actions.ts#L19-L25), [`src/actions.ts:39`](https://github.com/bitfocus/companion-module-screenbird-signage/blob/07ed62f76687cc08e78a8f2477ef8060e45a415d/src/actions.ts#L39), [`src/actions.ts:45`](https://github.com/bitfocus/companion-module-screenbird-signage/blob/07ed62f76687cc08e78a8f2477ef8060e45a415d/src/actions.ts#L45)

**What goes wrong:** A user who adds a "Scene: go" or "Scene: stop" action while the scene list is still empty (for example right after creating the connection, before the token is entered) gets an empty Scene choice, and it stays empty after the scenes load. Pressing the button sends a request with no scene and the log shows something like "Scene go failed: Screenbird answered HTTP 404." The user is never told to pick a scene, while "Screen: push content" and "Screen: stop" already give clear messages for the same situation.

**Why it happens:** The Scene dropdown defaults to an empty value when there are no scenes, and the two scene actions pass the option straight into the request without checking it. The module already has a lookup (`sceneById()`) that could tell whether the chosen scene exists.

**Fix:** look up the scene first and throw a clear error when it isn't found.

```ts
const scene = self.sceneById(event.options.scene)
if (!scene) throw new Error('choose a scene (this scene no longer exists)')
return api.activate(scene.id)
```

## 💡 Nice to Have

### N1: Unused refresh method on the module instance

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:108-111`](https://github.com/bitfocus/companion-module-screenbird-signage/blob/07ed62f76687cc08e78a8f2477ef8060e45a415d/src/main.ts#L108-L111)

**What goes wrong:** No visible effect; this is code quality only. The public `refresh()` method on the module instance is never called.

**Why it happens:** Only the connection's own `refresh()` is used, from inside `connection.ts`; the actions use `runAction` and `ensureRecentContent` instead of the instance wrapper.

**Fix:** remove `ModuleInstance.refresh()`, or wire it to a "Reload scenes and screens" action if that is wanted.

## 📝 Additional Notes

- `tsconfig.build.json`: the `exclude` list differs from the template. The module has `["node_modules/**", "src/**/*.test.ts"]`; the template has `["node_modules/**", "src/**/*spec.ts", "src/**/__tests__/*", "src/**/__mocks__/*"]`. Fine as long as the module builds — no change required.
- `tsconfig.json`: the template's `compilerOptions` key is missing, and the `exclude` line has no trailing comma or following entries. Fine as long as the module builds — no change required.
