# Review: companion-module-astrastudio-onairscreen v1.1.0

| Field | Value |
| --- | --- |
| **Module** | `companion-module-astrastudio-onairscreen` |
| **Scope** | `tag` (v1.0.4..v1.1.0) |
| **Version** | v1.1.0 (`674d947`) |
| **Release** | Update — last published v1.0.4 |
| **API** | 2.0 (base 2.0.4, yarn.lock) — requires Companion 4.3+ |
| **Template** | `companion-module-template-ts-v2.0.4` @ `d62230e` (2026-08-28, pinned) · `.yarnrc.yml` from `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Review date** | 2026-10-30 |
| **Source links** | pinned to [`674d947`](https://github.com/bitfocus/companion-module-astrastudio-onairscreen/tree/674d947f19f878c794c3430127c75e753bc17efe) |

## Verdict: ❌ Changes Required

## 📋 Issues

### Blocking

- [ ] [H1: The LICENSE file doesn't match the template](#h1-the-license-file-doesnt-match-the-template)
- [ ] [H2: The CI workflow differs from the template by running a test job](#h2-the-ci-workflow-differs-from-the-template-by-running-a-test-job)

### Non-blocking

- [ ] [L1: The new Fullscreen action's State option can be switched to expression mode, which it doesn't need](#l1-the-new-fullscreen-actions-state-option-can-be-switched-to-expression-mode-which-it-doesnt-need)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟠 High

### H1: The LICENSE file doesn't match the template

- **Source:** 🤖 validate-template (LICENSE-DIFF)
- **Classification:** 🆕 NEW (template check; `LICENSE` is unchanged since v1.0.4)
- **File:** [`LICENSE:3`](https://github.com/bitfocus/companion-module-astrastudio-onairscreen/blob/674d947f19f878c794c3430127c75e753bc17efe/LICENSE#L3)

**What goes wrong:** The module ships a LICENSE whose copyright line names the module author instead of the one every Companion module carries. Modules published by Bitfocus are expected to carry the template's MIT license text unchanged.

**Why it happens:** The copyright line in `LICENSE` was edited after the file was copied from the template.

**Evidence:**

```text
LICENSE:3
  expected: Copyright (c) 2022 Bitfocus AS - Open Source
  found:    Copyright (c) 2026 Sascha Ludwig, astrastudio.de
```

**Confirm by:** `diff companion-module-template-ts-v2.0.4/LICENSE LICENSE`, or open [`LICENSE:3`](https://github.com/bitfocus/companion-module-astrastudio-onairscreen/blob/674d947f19f878c794c3430127c75e753bc17efe/LICENSE#L3).

**Fix:** replace `LICENSE` with the template's file, unchanged.

### H2: The CI workflow differs from the template by running a test job

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW (template check; `.github/workflows/node.yaml` is unchanged since v1.0.4)
- **File:** [`.github/workflows/node.yaml:52-73`](https://github.com/bitfocus/companion-module-astrastudio-onairscreen/blob/674d947f19f878c794c3430127c75e753bc17efe/.github/workflows/node.yaml#L52-L73)

**What goes wrong:** The module's GitHub Actions workflow is not the template's file. Workflow files are expected to match the template exactly, so that every module's CI behaves the same and differences don't have to be checked by hand later.

**Why it happens:** The template ships an optional `test` job, commented out under the line `# Uncomment this to enable running unit tests`. The module uncommented that job (it has `*.spec.ts` tests and a `yarn test` script) and removed the comment line above it.

**Evidence:**

```diff
# template .github/workflows/node.yaml:52-56 vs module .github/workflows/node.yaml:52-55
-  # Uncomment this to enable running unit tests
-  # test:
-  #   name: Test
-  #   runs-on: ubuntu-latest
-  #   timeout-minutes: 15
+  test:
+    name: Test
+    runs-on: ubuntu-latest
+    timeout-minutes: 15
# … template lines 58-74 (all commented out) vs module lines 57-73 (uncommented):
+    steps:
+      - uses: actions/checkout@v7
+      ...
+      - name: Run tests
+        run: |
+          yarn test
```

**Confirm by:** `diff companion-module-template-ts-v2.0.4/.github/workflows/node.yaml .github/workflows/node.yaml`, or open [`.github/workflows/node.yaml:52-73`](https://github.com/bitfocus/companion-module-astrastudio-onairscreen/blob/674d947f19f878c794c3430127c75e753bc17efe/.github/workflows/node.yaml#L52-L73).

**Fix:** replace `.github/workflows/node.yaml` with the template's file, unchanged.

## 🟢 Low

### L1: The new Fullscreen action's State option can be switched to expression mode, which it doesn't need

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:225-236`](https://github.com/bitfocus/companion-module-astrastudio-onairscreen/blob/674d947f19f878c794c3430127c75e753bc17efe/src/actions.ts#L225-L236)

**What goes wrong:** Nothing breaks. In the new **Fullscreen** action, a user can flip the **State** option (Toggle / On / Off) to expression mode. A value such as `on` (lowercase) or `maybe` then fails the dropdown's choice check, and Companion skips the action without running it. Users who leave **State** as a normal dropdown, which is how the Display > Fullscreen preset ships, see no difference.

**Why it happens:** The API 2.0 rules recommend `disableAutoExpression: true` on options that make no sense as an expression, such as an on/off/toggle choice. The new `state` dropdown leaves it out. It copies the existing LED, AIR and AIR3 top-of-hour toggle actions, which also leave it out, so this follows the module's current pattern.

**Fix:** add `disableAutoExpression: true` to the `state` dropdown of the `fullscreen` action, and consider adding it to the other `TOGGLE_CHOICES` dropdowns for consistency. This changes no saved data, so no upgrade script is needed.

```ts
{
	id: 'state',
	type: 'dropdown',
	label: 'State',
	default: 'TOGGLE',
	choices: TOGGLE_CHOICES,
	disableAutoExpression: true,
},
```

## 📝 Additional Notes

- `tsconfig.build.json` differs from the template: it adds `allowImportingTsExtensions: true` and `rewriteRelativeImportExtensions: true` after `verbatimModuleSyntax`. Fine as long as the module builds (it does) — no change required.
