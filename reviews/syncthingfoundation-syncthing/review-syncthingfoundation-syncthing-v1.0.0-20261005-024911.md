# Review: syncthingfoundation-syncthing v1.0.0

| | |
| --- | --- |
| **Module** | `companion-module-syncthingfoundation-syncthing` ([repo](https://github.com/bitfocus/companion-module-syncthingfoundation-syncthing)) |
| **Version** | v1.0.0 (`5e4eb0f`) |
| **Previous tag** | none (first release) |
| **Scope:** | tag (first release, so the whole module was reviewed) |
| **Language** | TypeScript |
| **Template** | [API 2.0 TypeScript template](https://github.com/bitfocus/companion-module-template-ts/tree/d62230e88bf8aec4ea6db407106bff2a96c0fdb9) (`companion-module-template-ts` @ `d62230e`, 2026-08-28, the last API 2.0 commit) |
| **API** | 2.0 (base 2.0.4, yarn.lock) — requires Companion 4.3+ |
| **Build** | `yarn install --immutable`, `yarn package` and `yarn lint` pass (`syncthingfoundation-syncthing-1.0.0.tgz`) |
| **Review date** | 2026-10-08 |

This is the module's first release, so there is no previous tag to compare against. The whole module was reviewed and every finding is new.

**About the template:** the official TypeScript template repository has moved to the module API 2.1 (Companion 5). This module uses API 2.0, so every template finding below links to the API 2.0 version of the template, at commit [`d62230e`](https://github.com/bitfocus/companion-module-template-ts/tree/d62230e88bf8aec4ea6db407106bff2a96c0fdb9). Earlier versions of the template are no longer maintained, but that commit preserves the API 2.0 files.

## Verdict: ❌ Changes Required

## 📋 Issues

### Blocking

- [ ] [C1: The lint config doesn't follow the template's layout](#c1-the-lint-config-doesnt-follow-the-templates-layout)
- [ ] [H1: The Companion Module Checks workflow differs from the template](#h1-the-companion-module-checks-workflow-differs-from-the-template)
- [ ] [H2: The upgrade-script type leaves out the secrets type](#h2-the-upgrade-script-type-leaves-out-the-secrets-type)

### Non-blocking

- [ ] [M1: Folder and device feedbacks can't use a typed-in or expression id, unlike the actions](#m1-folder-and-device-feedbacks-cant-use-a-typed-in-or-expression-id-unlike-the-actions)
- [ ] [L1: Two folders with similar ids can show each other's values](#l1-two-folders-with-similar-ids-can-show-each-others-values)
- [ ] [L2: The pause and resume mode dropdowns accept expressions and aren't type-checked](#l2-the-pause-and-resume-mode-dropdowns-accept-expressions-and-arent-type-checked)

---

## 🔴 Critical

### C1: The lint config doesn't follow the template's layout

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`eslint.config.mjs:3-16`](https://github.com/bitfocus/companion-module-syncthingfoundation-syncthing/blob/5e4eb0fb132e3708fef65101e7e49c13f5f4551a/eslint.config.mjs#L3-L16)
- **Template:** [API 2.0 TypeScript template](https://github.com/bitfocus/companion-module-template-ts/tree/d62230e88bf8aec4ea6db407106bff2a96c0fdb9): [`eslint.config.mjs`](https://github.com/bitfocus/companion-module-template-ts/blob/d62230e88bf8aec4ea6db407106bff2a96c0fdb9/eslint.config.mjs)

**What goes wrong:** No user-visible effect. The template check fails because `eslint.config.mjs` doesn't have the template's shape: line 3 is `export default [` where the template has `export default generateEslintConfig({`.

**Why it happens:** The content itself is fine. The imports and options match the template, the shared config comes first, and the extra block only turns off two rules for `tests/**` and `scripts/**`, so linting of `src/` is unchanged. The check accepts an extra test-only block like this one, but only when the shared config is first stored in a variable and then spread. Spreading `await generateEslintConfig(...)` inline is what it rejects.

**Expected vs found:**

```js
// template
export default generateEslintConfig({

// eslint.config.mjs:3-6
export default [
	...(await generateEslintConfig({
		enableTypescript: true,
	})),
```

**Fix:** store the shared config in a variable first, then spread it. The check then accepts the test-only block.

```js
const baseConfig = await generateEslintConfig({ enableTypescript: true })

export default [
	...baseConfig,
	{
		files: ['tests/**/*.mjs', 'scripts/**/*.mjs'],
		rules: { 'n/no-unpublished-import': 'off', 'n/no-process-exit': 'off' },
	},
]
```

---

## 🟠 High

### H1: The Companion Module Checks workflow differs from the template

- **Source:** 🤖 validate-template (CONFIG-DIFF; raised to High by the review maintainer)
- **Classification:** 🆕 NEW
- **File:** [`.github/workflows/companion-module-checks.yaml:10-23`](https://github.com/bitfocus/companion-module-syncthingfoundation-syncthing/blob/5e4eb0fb132e3708fef65101e7e49c13f5f4551a/.github/workflows/companion-module-checks.yaml#L10-L23)
- **Template:** [API 2.0 TypeScript template](https://github.com/bitfocus/companion-module-template-ts/tree/d62230e88bf8aec4ea6db407106bff2a96c0fdb9): [`.github/workflows/companion-module-checks.yaml`](https://github.com/bitfocus/companion-module-template-ts/blob/d62230e88bf8aec4ea6db407106bff2a96c0fdb9/.github/workflows/companion-module-checks.yaml)

**What goes wrong:** No user-visible effect. The module's checks workflow doesn't match the template's, so its CI behaves differently from every other module built from the template. That makes CI problems harder to troubleshoot against the template, and future template updates harder to apply.

**Why it happens:** compared with the template, the file:

- adds `&& !github.event.repository.private` to the job's `if:` (line 17), so the check is skipped while the repository is private, with a seven-line comment explaining why (lines 10-16);
- adds `contents: read` to the job's permissions (line 22), next to the template's `packages: read`, with a comment (lines 19-20).

**Evidence:**

```diff
-    if: ${{ !contains(github.repository, 'companion-module-template-') }}
+    # The Bitfocus check cannot run on a private repository. ...
+    if: ${{ !contains(github.repository, 'companion-module-template-') && !github.event.repository.private }}

+    # contents: read has no effect today, ...
     permissions:
+      contents: read
       packages: read
```

**Confirm by:** compare [`companion-module-checks.yaml`](https://github.com/bitfocus/companion-module-syncthingfoundation-syncthing/blob/5e4eb0fb132e3708fef65101e7e49c13f5f4551a/.github/workflows/companion-module-checks.yaml) with the [template's](https://github.com/bitfocus/companion-module-template-ts/blob/d62230e88bf8aec4ea6db407106bff2a96c0fdb9/.github/workflows/companion-module-checks.yaml).

**Fix:** replace the file with the [template's `companion-module-checks.yaml`](https://github.com/bitfocus/companion-module-template-ts/blob/d62230e88bf8aec4ea6db407106bff2a96c0fdb9/.github/workflows/companion-module-checks.yaml). The repository is public now, so the private-repository workaround is no longer needed. Uncommenting `with: upload-artifact: true` is the one accepted customisation.

### H2: The upgrade-script type leaves out the secrets type

- **Source:** 🔎 compliance reviewer (raised to High by the review maintainer)
- **Classification:** 🆕 NEW
- **File:** [`src/upgrades.ts:4`](https://github.com/bitfocus/companion-module-syncthingfoundation-syncthing/blob/5e4eb0fb132e3708fef65101e7e49c13f5f4551a/src/upgrades.ts#L4)

**What goes wrong:** No user-visible effect. A future upgrade script that touches the API key wouldn't be type-checked, because `CompanionStaticUpgradeScript<ModuleConfig>` defaults the secrets type to `undefined` although the module has secrets.

**Evidence:**

```ts
// src/upgrades.ts:4
export const UpgradeScripts: CompanionStaticUpgradeScript<ModuleConfig>[] = [
```

```ts
// src/main.ts:56 (the module does have secrets)
	secrets: ModuleSecrets
```

**Confirm by:** open [`src/upgrades.ts:4`](https://github.com/bitfocus/companion-module-syncthingfoundation-syncthing/blob/5e4eb0fb132e3708fef65101e7e49c13f5f4551a/src/upgrades.ts#L4) and compare it with `ModuleSecrets` in [`src/config.ts:15`](https://github.com/bitfocus/companion-module-syncthingfoundation-syncthing/blob/5e4eb0fb132e3708fef65101e7e49c13f5f4551a/src/config.ts#L15).

**Fix:** declare it as `CompanionStaticUpgradeScript<ModuleConfig, ModuleSecrets>[]`.

---

## 🟡 Medium

### M1: Folder and device feedbacks can't use a typed-in or expression id, unlike the actions

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.ts:149-204`](https://github.com/bitfocus/companion-module-syncthingfoundation-syncthing/blob/5e4eb0fb132e3708fef65101e7e49c13f5f4551a/src/feedbacks.ts#L149-L204) (compare [`src/actions.ts:48-66`](https://github.com/bitfocus/companion-module-syncthingfoundation-syncthing/blob/5e4eb0fb132e3708fef65101e7e49c13f5f4551a/src/actions.ts#L48-L66))

**What goes wrong:** In the actions, the **Folder** and **Device** dropdowns accept a custom value, so a user can type an id or use an expression. In the feedbacks they don't. A feedback whose folder or device id comes from an expression, or isn't in the list yet (the list holds only a placeholder until the first successful status check), does nothing.

**Why it happens:** The actions build their dropdowns with `allowCustom: true`. The feedbacks declare their own `folder` / `device` dropdowns without it, and in API 2.0 a value that doesn't match one of the choices is rejected unless `allowCustom` is set.

**Fix:** reuse the actions' `folderOption` / `deviceOption` definitions in the feedbacks, or add `allowCustom: true` and the same tooltip, so actions and feedbacks behave the same way.

---

## 🟢 Low

### L1: Two folders with similar ids can show each other's values

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/state.ts:122-151`](https://github.com/bitfocus/companion-module-syncthingfoundation-syncthing/blob/5e4eb0fb132e3708fef65101e7e49c13f5f4551a/src/state.ts#L122-L151), [`src/variables.ts:109-111`](https://github.com/bitfocus/companion-module-syncthingfoundation-syncthing/blob/5e4eb0fb132e3708fef65101e7e49c13f5f4551a/src/variables.ts#L109-L111), [`src/variables.ts:128-143`](https://github.com/bitfocus/companion-module-syncthingfoundation-syncthing/blob/5e4eb0fb132e3708fef65101e7e49c13f5f4551a/src/variables.ts#L128-L143), [`src/variables.ts:187-198`](https://github.com/bitfocus/companion-module-syncthingfoundation-syncthing/blob/5e4eb0fb132e3708fef65101e7e49c13f5f4551a/src/variables.ts#L187-L198)

**What goes wrong:** A folder `x` and a folder `x_pull` (or `x-pull`) both produce a variable named `folder_x_pull_errors`: one is "x" + "pull errors", the other is "x_pull" + "errors". Whichever is written last wins, so one folder's button shows the other folder's value.

**Why it happens:** `assignPrefixPairs` makes each folder's prefix unique, but not the full variable name, and some suffixes contain `_`.

**Fix:** fix this now, while there are no users yet, because renaming variables later needs an upgrade script. Either separate prefix and suffix with something the name cleaner can never produce (for example `__`), or check the full names for collisions when building the definitions.

### L2: The pause and resume mode dropdowns accept expressions and aren't type-checked

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:15-19`](https://github.com/bitfocus/companion-module-syncthingfoundation-syncthing/blob/5e4eb0fb132e3708fef65101e7e49c13f5f4551a/src/actions.ts#L15-L19), [`src/actions.ts:222-228`](https://github.com/bitfocus/companion-module-syncthingfoundation-syncthing/blob/5e4eb0fb132e3708fef65101e7e49c13f5f4551a/src/actions.ts#L222-L228)

**What goes wrong:** No direct user-visible effect. The **Action** dropdown (pause / resume / toggle) in **Folder: pause, resume or toggle**, **Device: pause, resume or toggle** and **All devices: pause or resume** offers an expression mode that isn't useful for a fixed choice, and a typo in the code wouldn't be caught at build time.

**Why it happens:** `ActionsSchema` types `mode` as `string` even though a `PauseMode` type exists.

**Fix:** type `mode: PauseMode` in `ActionsSchema` and add `disableAutoExpression: true` to the three `mode` dropdowns.
