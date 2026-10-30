# Review: companion-module-cedar-dns8d v2.0.0

| Field | Value |
| --- | --- |
| **Module** | `companion-module-cedar-dns8d` |
| **Scope** | `tag` (v1.0.7..v2.0.0) |
| **Version** | v2.0.0 |
| **Release** | Update — last published v1.0.7 |
| **API** | 2.2 (base 2.2.1, yarn.lock) |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Commit** | [`39e4193`](https://github.com/bitfocus/companion-module-cedar-dns8d/tree/39e4193abd64925846ae34f5522caba7d4948ba9) |
| **Review date** | 2026-10-30 |

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | When an action or feedback option in expression mode evaluates to a numeric string such as `"3"` (for example from a custom variable holding text), Companion passes that string to the module unchanged, or skips the action, instead of converting it to the number 3 for a dropdown whose choice ids are numbers | `@companion-module/base` `input.d.ts` documents `allowInvalidValues` and expression-mode validation, but not whether a dropdown value is converted to the choice id's type; Companion's host-side validation code was not checked | [L2](#l2-channel-or-band-set-from-a-text-variable-may-be-rejected-as-invalid-channel) |
| A2 | When an expression's result matches no dropdown choice (for example the string `'on'`, or the number `1` against the string id `'1'`), Companion skips the action as if it were disabled instead of coercing the value | the v2.0 compliance reference describes expression validation (a dropdown value must match a choice unless `allowCustom` is set); Companion's loose or strict id comparison was not checked in its source | [M1](#m1-on-and-learn-options-expect-0-1-or-2-when-switched-to-expression-mode) |

## 📋 Issues

### Blocking

- [ ] [C1: Template's .gitattributes file is missing](#c1-templates-gitattributes-file-is-missing)
- [ ] [C2: Packaged .tgz files and the .yarn and .vscode folders are not git-ignored](#c2-packaged-tgz-files-and-the-yarn-and-vscode-folders-are-not-git-ignored)
- [ ] [C3: Pre-commit hook runs yarn lint-staged instead of the template's lint-staged](#c3-pre-commit-hook-runs-yarn-lint-staged-instead-of-the-templates-lint-staged)
- [ ] [C4: Yarn config lets dependencies install from any git repository](#c4-yarn-config-lets-dependencies-install-from-any-git-repository)
- [ ] [C5: An unused Yarn patch for companion-module-utils 0.5.0 is committed](#c5-an-unused-yarn-patch-for-companion-module-utils-050-is-committed)
- [ ] [H1: Pull-request CI workflow differs from the template](#h1-pull-request-ci-workflow-differs-from-the-template)
- [ ] [H2: Release workflow no longer uses the shared Bitfocus module checks](#h2-release-workflow-no-longer-uses-the-shared-bitfocus-module-checks)

### Non-blocking

- [ ] [M1: On and Learn options expect 0, 1 or 2 when switched to expression mode](#m1-on-and-learn-options-expect-0-1-or-2-when-switched-to-expression-mode)
- [ ] [L1: Connection stays green while every device message fails to parse](#l1-connection-stays-green-while-every-device-message-fails-to-parse)
- [ ] [L2: Channel or band set from a text variable may be rejected as Invalid channel](#l2-channel-or-band-set-from-a-text-variable-may-be-rejected-as-invalid-channel)
- [ ] [N1: A bad attenuation or bias value is reported as Invalid channel](#n1-a-bad-attenuation-or-bias-value-is-reported-as-invalid-channel)
- [ ] [N2: Changing the Host during an outage logs nothing for the new address](#n2-changing-the-host-during-an-outage-logs-nothing-for-the-new-address)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🔴 Critical

### C1: Template's .gitattributes file is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.gitattributes` (missing)

**What goes wrong:** Without the template's `.gitattributes`, git does not force LF line endings. A contributor on Windows can commit CRLF files, which shows up as whole-file diffs and lint failures.

**Why it happens:** The template tracks a `.gitattributes` file and this repository has none.

**Evidence:** expected the template file `.gitattributes`, found nothing.

```text
* text=auto eol=lf
```

**Fix:** copy `.gitattributes` from `companion-module-template-ts` into the repository root.

### C2: Packaged .tgz files and the .yarn and .vscode folders are not git-ignored

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.gitignore`](https://github.com/bitfocus/companion-module-cedar-dns8d/blob/39e4193abd64925846ae34f5522caba7d4948ba9/.gitignore)

**What goes wrong:** A package built with `yarn package` under a name other than `cedar-dns8d-*.tgz`, Yarn's local `.yarn` folder and editor settings in `.vscode` can be committed by accident.

**Why it happens:** The `.gitignore` is missing three of the template's entries. It ignores `cedar-dns8d-*.tgz` and selected `.yarn/*` paths instead (and un-ignores `.yarn/patches`, see [C5](#c5-an-unused-yarn-patch-for-companion-module-utils-050-is-committed)).

**Evidence:** missing template `.gitignore` entries: `/*.tgz`, `/.yarn`, `/.vscode`.

**Fix:** use the template's `.gitignore`.

```text
node_modules/
package-lock.json
/pkg
/*.tgz
/dist
DEBUG-*
/.yarn
/.vscode
```

Keeping `/coverage` and `.DS_Store` on top of the template's entries is fine.

### C3: Pre-commit hook runs yarn lint-staged instead of the template's lint-staged

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.husky/pre-commit:1`](https://github.com/bitfocus/companion-module-cedar-dns8d/blob/39e4193abd64925846ae34f5522caba7d4948ba9/.husky/pre-commit#L1)

**What goes wrong:** The pre-commit hook differs from the one every other module ships, which makes hook problems harder to troubleshoot.

**Why it happens:** The hook calls `yarn lint-staged`; the template calls `lint-staged` directly.

**Evidence:** line 1: found `yarn lint-staged`, template `lint-staged`.

**Fix:** change the hook to the template's single line.

```bash
lint-staged
```

### C4: Yarn config lets dependencies install from any git repository

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.yarnrc.yml:1-2`](https://github.com/bitfocus/companion-module-cedar-dns8d/blob/39e4193abd64925846ae34f5522caba7d4948ba9/.yarnrc.yml#L1-L2)

**What goes wrong:** Yarn will accept a dependency pulled straight from any git repository. Git sources are not npm packages, so they sit outside the npm safeguards the template sets up (`npmMinimalAgeGate: 3d`, `npmPreapprovedPackages`).

**Why it happens:** `.yarnrc.yml` adds an `approvedGitRepositories` key, set to `'**'`, that the template does not have. No dependency in `package.json` uses a git source, so the key is not needed.

**Evidence:** extra keys not in template: `approvedGitRepositories`.

```yaml
# .yarnrc.yml:1-2
approvedGitRepositories:
  - '**'
```

**Fix:** delete the `approvedGitRepositories` key so `.yarnrc.yml` matches the template.

### C5: An unused Yarn patch for companion-module-utils 0.5.0 is committed

- **Source:** 🤖 validate-template (GITIGNORED-COMMITTED)
- **Classification:** 🆕 NEW
- **File:** [`.yarn/patches/companion-module-utils-npm-0.5.0-031725c535.patch`](https://github.com/bitfocus/companion-module-cedar-dns8d/blob/39e4193abd64925846ae34f5522caba7d4948ba9/.yarn/patches/companion-module-utils-npm-0.5.0-031725c535.patch)

**What goes wrong:** The repository carries a patch file that the template's `.gitignore` excludes, and nothing uses it.

**Why it happens:** The template ignores the whole `/.yarn` folder. The patch targets `companion-module-utils` 0.5.0, but `package.json` now asks for `^0.6.1`, and neither `package.json` nor `yarn.lock` references a `patch:` for it.

**Evidence:** committed, but the template `.gitignore` excludes it (pattern `/.yarn`).

**Fix:** delete the `.yarn/patches` folder from the repository (`git rm -r .yarn/patches`) and use the template `.gitignore` from [C2](#c2-packaged-tgz-files-and-the-yarn-and-vscode-folders-are-not-git-ignored).

## 🟠 High

### H1: Pull-request CI workflow differs from the template

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.github/workflows/node.yaml`](https://github.com/bitfocus/companion-module-cedar-dns8d/blob/39e4193abd64925846ae34f5522caba7d4948ba9/.github/workflows/node.yaml)

**What goes wrong:** The CI workflow no longer matches the template, so a template update can't be applied to it as-is.

**Why it happens:** The workflow adds `permissions: contents: read`, drops `persist-credentials: false` on checkout, moves `actions/setup-node` from `@v6` to `@v7`, and enables the test job (`yarn test:coverage` plus a Codecov upload). Node 26.x matches the module's node26 runtime.

**Evidence:** line 11: found `permissions:`, template `jobs:`.

**Confirm by:** compare [`.github/workflows/node.yaml`](https://github.com/bitfocus/companion-module-cedar-dns8d/blob/39e4193abd64925846ae34f5522caba7d4948ba9/.github/workflows/node.yaml) with the template's: line 11 `permissions:`, lines 24 and 55 `actions/setup-node@v7` (template `@v6`), line 68 `yarn test:coverage` and line 72 `codecov/codecov-action@v7`.

**Fix:** start from the template's `node.yaml` and keep only the additions you need (enabling the test job is fine); restore `persist-credentials: false` on the checkout step.

### H2: Release workflow no longer uses the shared Bitfocus module checks

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.github/workflows/release.yaml:10-40`](https://github.com/bitfocus/companion-module-cedar-dns8d/blob/39e4193abd64925846ae34f5522caba7d4948ba9/.github/workflows/release.yaml#L10-L40)

**What goes wrong:** A published release is packaged without the checks the rest of the Bitfocus modules run, so a release can carry a package that the shared checks would have rejected.

**Why it happens:** The template's `package` job calls `bitfocus/actions/.github/workflows/module-checks.yaml@main`, and an `attach` job downloads its `pkg` artifact. This module replaces both with one hand-written job that runs `yarn package --dev [--prerelease]` and uploads `./*.tgz`.

**Evidence:** line 10: found `# Deliberately does not run lint or tests. ...`, template `jobs:`.

**Confirm by:** open [`.github/workflows/release.yaml:51-63`](https://github.com/bitfocus/companion-module-cedar-dns8d/blob/39e4193abd64925846ae34f5522caba7d4948ba9/.github/workflows/release.yaml#L51-L63): lines 51 and 53 run `yarn package --dev --prerelease` / `yarn package --dev`, line 63 uploads `./*.tgz`, and nothing calls `bitfocus/actions/.github/workflows/module-checks.yaml@main`.

**Fix:** use the template's `release.yaml`, which calls the shared `module-checks.yaml` workflow and attaches its package.

## 🟡 Medium

### M1: On and Learn options expect 0, 1 or 2 when switched to expression mode

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/options.ts:10-41`](https://github.com/bitfocus/companion-module-cedar-dns8d/blob/39e4193abd64925846ae34f5522caba7d4948ba9/src/options.ts#L10-L41)

**What goes wrong:** This release moves the module to API 2.x, which lets users switch any action option to expression mode. The On option of **Channel On** and **Global On**, and the Learn option of **Channel Learn** and **Global Learn**, only accept the device's protocol strings `'1'` (On), `'0'` (Off) and `'2'` (Toggle). A user who switches On to an expression and writes `'on'`, `'toggle'` or the number `1` gets a value that matches no choice, and pressing the button doesn't switch DNS on, with no message. Existing buttons keep working; only users who switch the field to expression mode are affected.

**Why it happens:** The shared On/Off/Toggle dropdown keeps the v1 ids `'0' | '1' | '2'`, and sets neither `disableAutoExpression: true` (which hides expression mode for the field) nor an `expressionDescription` (which tells the user what to return). The v2.0 rules recommend readable dropdown ids, because users type them in expression mode, and `disableAutoExpression` on on/off/toggle choices.

**Evidence:**

```ts
// src/options.ts:15-19
const TOGGLE_CHOICES = [
	{ id: '1', label: 'On' },
	{ id: '0', label: 'Off' },
	{ id: '2', label: 'Toggle' },
] as const satisfies DropdownChoice<ToggleValue>[]
// src/options.ts:35-41
const onOffToggle: CompanionInputFieldDropdown<'value', ToggleValue> = {
	id: 'value',
	type: 'dropdown',
	label: '',
	choices: TOGGLE_CHOICES,
	default: TOGGLE_CHOICES[2].id,
}
```

**Confirm by:** open [`src/options.ts:35-41`](https://github.com/bitfocus/companion-module-cedar-dns8d/blob/39e4193abd64925846ae34f5522caba7d4948ba9/src/options.ts#L35-L41). The dropdown has neither `disableAutoExpression` nor `expressionDescription`, and its ids are `'0'`/`'1'`/`'2'`.

**Fix:** the simplest change is to turn expression mode off for this field.

```ts
const onOffToggle: CompanionInputFieldDropdown<'value', ToggleValue> = {
	id: 'value',
	type: 'dropdown',
	label: '',
	choices: TOGGLE_CHOICES,
	default: TOGGLE_CHOICES[2].id,
	disableAutoExpression: true,
}
```

Alternatively keep expression mode and add `expressionDescription: "Return '1' (on), '0' (off) or '2' (toggle)"`. If you prefer readable ids (`'on'` / `'off'` / `'toggle'`), add a new upgrade script (`UpgradeScripts[1]`) that maps saved `'0'`/`'1'`/`'2'` values to the new ids, keeping the wrapped `{ isExpression, value }` shape, and update `calcBooleanVal`, the learn callbacks and `actionRecorder.ts`, which write these ids.

## 🟢 Low

### L1: Connection stays green while every device message fails to parse

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:290-296`](https://github.com/bitfocus/companion-module-cedar-dns8d/blob/39e4193abd64925846ae34f5522caba7d4948ba9/src/main.ts#L290-L296), [`src/main.ts:375-387`](https://github.com/bitfocus/companion-module-cedar-dns8d/blob/39e4193abd64925846ae34f5522caba7d4948ba9/src/main.ts#L375-L387)

**What goes wrong:** If the DNS8D sends replies the module can't read (for example a reply without a `<global>` element), variables such as `$(cedar-dns8d:channel1_Attenuation)` and the Channel On / Channel Learn feedbacks stop updating, but the connection stays green (OK). Only one "Could not read message from device" warning reaches the log, so the operator has no visible sign that the values on their buttons are stale. This is still better than v1.0.7, where the same error ended the module's process.

**Why it happens:** The message listener resets the silence watchdog before it parses the message, so the watchdog never fires while unreadable messages keep arriving. The new error handler in `setVarValues()` logs the first error of a run and suppresses the rest, but never changes the connection status. Parsing can throw on partial replies, because `data?.dns8d?.global[...]` and `data?.dns8d?.group?.band[i - 1]` don't guard the index access.

**Fix:** set a status in the error handler and set it back to OK on the next good message.

```ts
} catch (err) {
	this.updateStatus(InstanceStatus.UnknownError, 'Unreadable reply from device')
	// ...existing log-once code
}
```

Call `this.updateStatus(InstanceStatus.Ok)` where `messageErrorLogged` is reset. Optionally move `resetWatchdog()` after a successful parse, so a device that only sends unreadable data counts as silent.

### L2: Channel or band set from a text variable may be rejected as Invalid channel

- **Source:** 🔎 QA reviewer
- **Classification:** 🔙 REGRESSION
- **File:** [`src/utils.ts:31-37`](https://github.com/bitfocus/companion-module-cedar-dns8d/blob/39e4193abd64925846ae34f5522caba7d4948ba9/src/utils.ts#L31-L37)

**What goes wrong:** In v1.0.7 a user could type a custom value such as `$(internal:custom_dns_ch)` into the Channel dropdown of **Channel On**, **Channel Attenuation** and the other channel actions. When the custom variable held the text `"3"`, the action worked. The upgrade script turns that saved value into an expression. If the expression still yields the string `"3"`, pressing the button logs "Invalid channel: 3 - Channel On aborted" and sends nothing, and the Channel Learn / Channel On / Channel DSP feedbacks stay off. The Band option of **Detail Attenuation** and **Detail Bias** is affected the same way. Whether Companion delivers a string here is unconfirmed (see [A1](#-assumptions-to-confirm)).

**Why it happens:** `isChannel` and `isBand` check the value with a strict comparison against the numeric channel and band lists, so the string `"3"` never matches 3. v1.0.7 converted the value with `Number.parseInt` first. Upgraded buttons now depend on Companion delivering a real number.

**Fix:** convert the option to a number before checking it.

```ts
const id = Number(action.options.channel)
```

Do the same for `band`, in the action and feedback callbacks, or let `isChannel`/`isBand` accept `unknown` and test `Number(id)`. Add a test in `actions.spec.ts` where the channel option is the string `'3'`. If Companion's dropdown validation rejects string results, also set `allowInvalidValues: true` on the channel and band options so the module's own conversion handles them.

## 💡 Nice to Have

### N1: A bad attenuation or bias value is reported as Invalid channel

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:90-91`](https://github.com/bitfocus/companion-module-cedar-dns8d/blob/39e4193abd64925846ae34f5522caba7d4948ba9/src/actions.ts#L90-L91), [`src/actions.ts:106-107`](https://github.com/bitfocus/companion-module-cedar-dns8d/blob/39e4193abd64925846ae34f5522caba7d4948ba9/src/actions.ts#L106-L107), [`src/actions.ts:173-174`](https://github.com/bitfocus/companion-module-cedar-dns8d/blob/39e4193abd64925846ae34f5522caba7d4948ba9/src/actions.ts#L173-L174), [`src/actions.ts:189-190`](https://github.com/bitfocus/companion-module-cedar-dns8d/blob/39e4193abd64925846ae34f5522caba7d4948ba9/src/actions.ts#L189-L190)

**What goes wrong:** When a **Channel Attenuation** button's Atten field is an expression that evaluates to something that isn't a number (an empty variable, for example), the log reads "Invalid channel: 2 - Channel Attenuation aborted" even though channel 2 is fine. **Detail Attenuation** and **Detail Bias** also say "Invalid channel" when the problem is the band. The user is sent to the wrong field.

**Why it happens:** Each callback checks the channel (or band) and the value in one condition and throws the same channel message for both.

**Fix:** split the checks: throw `Invalid channel: ${id}` or `Invalid band: ${id}` for the id, and a separate `Invalid value: ${action.options.value}` when the value is not a finite number.

### N2: Changing the Host during an outage logs nothing for the new address

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:254-260`](https://github.com/bitfocus/companion-module-cedar-dns8d/blob/39e4193abd64925846ae34f5522caba7d4948ba9/src/main.ts#L254-L260), [`src/main.ts:331-340`](https://github.com/bitfocus/companion-module-cedar-dns8d/blob/39e4193abd64925846ae34f5522caba7d4948ba9/src/main.ts#L331-L340)

**What goes wrong:** The device at 192.168.1.50 is unreachable, so the log shows one "Could not connect to ws://192.168.1.50:80/info.ws". The user corrects the Host to 192.168.1.51, and that address fails too (a typo, for example). The status shows "Could not connect", but the log never mentions ws://192.168.1.51, so the user can't confirm which address the module is trying.

**Why it happens:** The "already logged this outage" flag is cleared only when a socket opens. Saving the connection settings reconnects without clearing it, so the first failure against the new address is not logged.

**Fix:** reset `this.outageLogged = false` (and `this.messageErrorLogged = false`) at the start of `configUpdated()`.

## 📝 Additional Notes

- `tsconfig.build.json` differs from the template only in a trailing comma after `"rootDir": "./src"`. No change required.
- `tsconfig.json` differs from the template (extra `compilerOptions.allowJs`; trailing comma after `"types": ["node"]`). Fine as long as the module builds — no change required.
