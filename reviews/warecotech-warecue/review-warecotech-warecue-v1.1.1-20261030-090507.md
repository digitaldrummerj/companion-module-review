# Review: companion-module-warecotech-warecue v1.1.1

| Field | Value |
| --- | --- |
| **Module** | `companion-module-warecotech-warecue` |
| **Scope** | `tag` |
| **Version** | v1.1.1 |
| **Release** | New module — never published |
| **API** | 1 (base 1.13.6, yarn.lock) |
| **Template** | `companion-module-template-ts-v1` @ `42609d8` (2026-03-03, pinned) · `.yarnrc.yml` from `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Previous tag** | none — first release, so there is no diff and the whole module was reviewed |
| **Review commit** | [`f8dd45e`](https://github.com/bitfocus/companion-module-warecotech-warecue/commit/f8dd45e701ccb826f3b4b9c445d9332a809927e8) |
| **Reviewed** | 2026-10-30 |

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Companion does not rewrite a hard-coded connection label inside preset button text when a preset is dragged onto a button | recommended practice of building preset text from `self.label`; Companion's preset import code not checked | [M7](#m7-pgm-and-pvw-display-presets-show-the-wrong-connections-scene-when-the-connection-is-not-named-warecue) |

## 📋 Issues

### Blocking

- [ ] [C1: Missing `.gitattributes`](#c1-missing-gitattributes)
- [ ] [C2: `.gitignore` is missing template entries](#c2-gitignore-is-missing-template-entries)
- [ ] [C3: Missing `.husky/pre-commit`](#c3-missing-huskypre-commit)
- [ ] [C4: `.prettierignore` differs from the template](#c4-prettierignore-differs-from-the-template)
- [ ] [C5: Missing `eslint.config.mjs`](#c5-missing-eslintconfigmjs)
- [ ] [C6: Missing `tsconfig.build.json`](#c6-missing-tsconfigbuildjson)
- [ ] [C7: `package.json` is missing the `postinstall` script](#c7-packagejson-is-missing-the-postinstall-script)
- [ ] [C8: `package.json` is missing the `build:main` script](#c8-packagejson-is-missing-the-buildmain-script)
- [ ] [C9: `package.json` is missing the `lint:raw` script](#c9-packagejson-is-missing-the-lintraw-script)
- [ ] [C10: Missing devDependency `eslint`](#c10-missing-devdependency-eslint)
- [ ] [C11: Missing devDependency `husky`](#c11-missing-devdependency-husky)
- [ ] [C12: Missing devDependency `lint-staged`](#c12-missing-devdependency-lint-staged)
- [ ] [C13: Missing devDependency `rimraf`](#c13-missing-devdependency-rimraf)
- [ ] [C14: Missing devDependency `typescript-eslint`](#c14-missing-devdependency-typescript-eslint)
- [ ] [C15: `package.json` is missing the `lint-staged` section](#c15-packagejson-is-missing-the-lint-staged-section)
- [ ] [C16: Manifest uses the banned keyword "stream deck"](#c16-manifest-uses-the-banned-keyword-stream-deck)
- [ ] [C17: Manifest entrypoint and `package.json` `main` point at different files](#c17-manifest-entrypoint-and-packagejson-main-point-at-different-files)
- [ ] [H1: `.github/workflows/companion-module-checks.yaml` differs from the template](#h1-githubworkflowscompanion-module-checksyaml-differs-from-the-template)

### Non-blocking

- [ ] [M1: Missing `.github/ISSUE_TEMPLATE/bug_report.yml`](#m1-missing-githubissue_templatebug_reportyml)
- [ ] [M2: Missing `.github/ISSUE_TEMPLATE/config.yml`](#m2-missing-githubissue_templateconfigyml)
- [ ] [M3: Missing `.github/ISSUE_TEMPLATE/feature_request.yml`](#m3-missing-githubissue_templatefeature_requestyml)
- [ ] [M4: Missing `.github/workflows/node.yaml`](#m4-missing-githubworkflowsnodeyaml)
- [ ] [M5: Cue and Scene dropdowns pick the wrong cue or scene when two share a name](#m5-cue-and-scene-dropdowns-pick-the-wrong-cue-or-scene-when-two-share-a-name)
- [ ] [M6: Typing a variable into a feedback's Output, Scene, Cue or Timer field never lights the button](#m6-typing-a-variable-into-a-feedbacks-output-scene-cue-or-timer-field-never-lights-the-button)
- [ ] [M7: PGM and PVW display presets show the wrong connection's scene when the connection is not named warecue](#m7-pgm-and-pvw-display-presets-show-the-wrong-connections-scene-when-the-connection-is-not-named-warecue)
- [ ] [M8: Timer message text is parsed for variables twice](#m8-timer-message-text-is-parsed-for-variables-twice)
- [ ] [L1: A blank or invalid host shows Connecting forever instead of a config error](#l1-a-blank-or-invalid-host-shows-connecting-forever-instead-of-a-config-error)
- [ ] [L2: Button presses that fail because WareCue is offline or slow leave no trace in the log](#l2-button-presses-that-fail-because-warecue-is-offline-or-slow-leave-no-trace-in-the-log)
- [ ] [L3: After changing host or port, buttons and variables keep showing the old WareCue's state](#l3-after-changing-host-or-port-buttons-and-variables-keep-showing-the-old-warecues-state)
- [ ] [N1: Connection status is re-sent to Companion on every state update](#n1-connection-status-is-re-sent-to-companion-on-every-state-update)
- [ ] [N2: The auth token is stored as plain text and included in exports](#n2-the-auth-token-is-stored-as-plain-text-and-included-in-exports)
- [ ] [R1: Consider moving to a newer `@companion-module/base`](#r1-consider-moving-to-a-newer-companion-modulebase)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🔴 Critical

### C1: Missing `.gitattributes`

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.gitattributes`

Required file is missing (tracked by the template). The template's file is one line: `* text=auto eol=lf`.

**Fix:** copy `.gitattributes` from the template.

### C2: `.gitignore` is missing template entries

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.gitignore`](https://github.com/bitfocus/companion-module-warecotech-warecue/blob/f8dd45e701ccb826f3b4b9c445d9332a809927e8/.gitignore)

Missing template `.gitignore` entries: `package-lock.json`, `/pkg`, `/*.tgz`, `/dist`, `DEBUG-*`, `/.vscode`.

**Fix:** replace `.gitignore` with the template's copy.

### C3: Missing `.husky/pre-commit`

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.husky/pre-commit`

Required file is missing (tracked by the template).

**Fix:** copy `.husky/pre-commit` from the template (it goes with C7, C11, C12 and C15).

### C4: `.prettierignore` differs from the template

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.prettierignore:1`](https://github.com/bitfocus/companion-module-warecotech-warecue/blob/f8dd45e701ccb826f3b4b9c445d9332a809927e8/.prettierignore#L1)

Differs from template (line 1: found `pkg/`, template `package.json`). The template file is `package.json` and `/LICENSE.md`.

**Fix:** replace `.prettierignore` with the template's copy.

### C5: Missing `eslint.config.mjs`

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `eslint.config.mjs`

Required file is missing (tracked by the template). The module's `lint` script is only `prettier --check . && tsc --noEmit`, so ESLint never runs.

**Fix:** copy `eslint.config.mjs` from the template and fix anything `yarn lint` then reports.

### C6: Missing `tsconfig.build.json`

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `tsconfig.build.json`

Required file is missing (tracked by the template).

**Fix:** copy `tsconfig.build.json` from the template, and make `tsconfig.json` extend it the way the template does.

### C7: `package.json` is missing the `postinstall` script

- **Source:** 🤖 validate-template (PKG-SCRIPT)
- **Classification:** 🆕 NEW
- **File:** [`package.json:6-13`](https://github.com/bitfocus/companion-module-warecotech-warecue/blob/f8dd45e701ccb826f3b4b9c445d9332a809927e8/package.json#L6-L13)

Missing required script `postinstall` (template: `"postinstall": "husky"`).

**Fix:** use the template's `scripts` block.

### C8: `package.json` is missing the `build:main` script

- **Source:** 🤖 validate-template (PKG-SCRIPT)
- **Classification:** 🆕 NEW
- **File:** [`package.json:6-13`](https://github.com/bitfocus/companion-module-warecotech-warecue/blob/f8dd45e701ccb826f3b4b9c445d9332a809927e8/package.json#L6-L13)

Missing required script `build:main` (template: `"build:main": "tsc -p tsconfig.build.json"`, called by `"build": "rimraf dist && run build:main"`). The module's `build` is `tsc --noEmit`, which emits nothing.

**Fix:** use the template's `scripts` block.

### C9: `package.json` is missing the `lint:raw` script

- **Source:** 🤖 validate-template (PKG-SCRIPT)
- **Classification:** 🆕 NEW
- **File:** [`package.json:10`](https://github.com/bitfocus/companion-module-warecotech-warecue/blob/f8dd45e701ccb826f3b4b9c445d9332a809927e8/package.json#L10)

Missing required script `lint:raw` (template: `"lint:raw": "eslint"` and `"lint": "run lint:raw ."`).

**Fix:** use the template's `scripts` block.

### C10: Missing devDependency `eslint`

- **Source:** 🤖 validate-template (PKG-DEVDEP)
- **Classification:** 🆕 NEW
- **File:** [`package.json:30-36`](https://github.com/bitfocus/companion-module-warecotech-warecue/blob/f8dd45e701ccb826f3b4b9c445d9332a809927e8/package.json#L30-L36)

Missing devDependency `eslint` (present in template).

**Fix:** add the template's `eslint` devDependency.

### C11: Missing devDependency `husky`

- **Source:** 🤖 validate-template (PKG-DEVDEP)
- **Classification:** 🆕 NEW
- **File:** [`package.json:30-36`](https://github.com/bitfocus/companion-module-warecotech-warecue/blob/f8dd45e701ccb826f3b4b9c445d9332a809927e8/package.json#L30-L36)

Missing devDependency `husky` (present in template).

**Fix:** add the template's `husky` devDependency.

### C12: Missing devDependency `lint-staged`

- **Source:** 🤖 validate-template (PKG-DEVDEP)
- **Classification:** 🆕 NEW
- **File:** [`package.json:30-36`](https://github.com/bitfocus/companion-module-warecotech-warecue/blob/f8dd45e701ccb826f3b4b9c445d9332a809927e8/package.json#L30-L36)

Missing devDependency `lint-staged` (present in template).

**Fix:** add the template's `lint-staged` devDependency.

### C13: Missing devDependency `rimraf`

- **Source:** 🤖 validate-template (PKG-DEVDEP)
- **Classification:** 🆕 NEW
- **File:** [`package.json:30-36`](https://github.com/bitfocus/companion-module-warecotech-warecue/blob/f8dd45e701ccb826f3b4b9c445d9332a809927e8/package.json#L30-L36)

Missing devDependency `rimraf` (present in template).

**Fix:** add the template's `rimraf` devDependency.

### C14: Missing devDependency `typescript-eslint`

- **Source:** 🤖 validate-template (PKG-DEVDEP)
- **Classification:** 🆕 NEW
- **File:** [`package.json:30-36`](https://github.com/bitfocus/companion-module-warecotech-warecue/blob/f8dd45e701ccb826f3b4b9c445d9332a809927e8/package.json#L30-L36)

Missing devDependency `typescript-eslint` (present in template).

**Fix:** add the template's `typescript-eslint` devDependency.

### C15: `package.json` is missing the `lint-staged` section

- **Source:** 🤖 validate-template (PKG-LINTSTAGED)
- **Classification:** 🆕 NEW
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-warecotech-warecue/blob/f8dd45e701ccb826f3b4b9c445d9332a809927e8/package.json)

Missing `lint-staged` section (present in template).

**Fix:** copy the template's `lint-staged` section into `package.json`.

### C16: Manifest uses the banned keyword "stream deck"

- **Source:** 🤖 validate-template (MAN-KEYWORD)
- **Classification:** 🆕 NEW
- **File:** [`companion/manifest.json:26`](https://github.com/bitfocus/companion-module-warecotech-warecue/blob/f8dd45e701ccb826f3b4b9c445d9332a809927e8/companion/manifest.json#L26)

Banned/low-value keyword `stream deck` (keywords: `["playout", "video", "show control", "stream deck"]`). Every Companion module works with a Stream Deck, so the keyword doesn't help anyone find this one.

**Fix:** remove `"stream deck"` from `keywords`.

### C17: Manifest entrypoint and `package.json` `main` point at different files

- **Source:** 🤖 validate-template (ENTRY-MISMATCH)
- **Classification:** 🆕 NEW
- **File:** [`companion/manifest.json:21`](https://github.com/bitfocus/companion-module-warecotech-warecue/blob/f8dd45e701ccb826f3b4b9c445d9332a809927e8/companion/manifest.json#L21), [`package.json:4`](https://github.com/bitfocus/companion-module-warecotech-warecue/blob/f8dd45e701ccb826f3b4b9c445d9332a809927e8/package.json#L4)

`runtime.entrypoint` `../dist/main.js` and `package.json` `main` `src/main.ts` resolve to different files. The template has `"main": "dist/main.js"`.

**Fix:** set `"main": "dist/main.js"` and build to `dist/` with the template's `build` scripts (C6, C8).

## 🟠 High

### H1: `.github/workflows/companion-module-checks.yaml` differs from the template

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.github/workflows/companion-module-checks.yaml:10-12`](https://github.com/bitfocus/companion-module-warecotech-warecue/blob/f8dd45e701ccb826f3b4b9c445d9332a809927e8/.github/workflows/companion-module-checks.yaml#L10-L12)

The job's `if:` condition is changed: it adds `github.repository_owner == 'bitfocus' &&`, so the check no longer runs on forks or private mirrors. That changes when the template's job runs, so it is High under the review's `.github` rule. The two comment lines above it are fine on their own.

**Evidence:**

```yaml
# module .github/workflows/companion-module-checks.yaml:10-12
    # Bitfocus's shared workflow pins its job to `packages: read`, so it can only
    # check out a public repo: run it in the bitfocus copy, not private mirrors.
    if: ${{ github.repository_owner == 'bitfocus' && !contains(github.repository, 'companion-module-template-') }}
```

```yaml
# template .github/workflows/companion-module-checks.yaml:10
    if: ${{ !contains(github.repository, 'companion-module-template-') }}
```

**Confirm by:** `diff companion-module-templates/companion-module-template-ts-v1/.github/workflows/companion-module-checks.yaml .github/workflows/companion-module-checks.yaml`

**Fix:** replace the file with the template's copy.

## 🟡 Medium

### M1: Missing `.github/ISSUE_TEMPLATE/bug_report.yml`

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.github/ISSUE_TEMPLATE/bug_report.yml`

Required file is missing (tracked by the template).

**Fix:** copy the file from the template.

### M2: Missing `.github/ISSUE_TEMPLATE/config.yml`

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.github/ISSUE_TEMPLATE/config.yml`

Required file is missing (tracked by the template).

**Fix:** copy the file from the template.

### M3: Missing `.github/ISSUE_TEMPLATE/feature_request.yml`

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.github/ISSUE_TEMPLATE/feature_request.yml`

Required file is missing (tracked by the template).

**Fix:** copy the file from the template.

### M4: Missing `.github/workflows/node.yaml`

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.github/workflows/node.yaml`

Required file is missing (tracked by the template).

**Fix:** copy the file from the template.

### M5: Cue and Scene dropdowns pick the wrong cue or scene when two share a name

- **Source:** 🔎 QA reviewer, compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/choices.ts:12-23`](https://github.com/bitfocus/companion-module-warecotech-warecue/blob/f8dd45e701ccb826f3b4b9c445d9332a809927e8/src/choices.ts#L12-L23)

**What goes wrong:** A show has cue 2 "Blackout" and cue 5 "Blackout". The user adds "Cue: fire" (or "Cue: arm (set standby)", or the "Cue: is on air (playhead)" feedback) and picks "5 — Blackout". Pressing the button fires cue 2, and the feedback lights for cue 2. Two scenes named "Walk-in" collapse into one choice the same way. A cue with an empty name gets the same value as the "(connect to WareCue)" placeholder and sends an empty cue reference.

**Why it happens:** The dropdowns store the cue or scene **name** as the selected value (`id: c.name`, `id: s.name`), so duplicate names give duplicate values, and the lookup returns the first match. The cue lookup also tries the cue number first, so a cue named "3" resolves to cue number 3.

**Fix:** store a unique, stable value for each choice: the cue number (falling back to the cue's id when it has no number) and the scene id or index. Since this is the first release, no upgrade script is needed if the change ships before publication.

### M6: Typing a variable into a feedback's Output, Scene, Cue or Timer field never lights the button

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.ts:48-51`](https://github.com/bitfocus/companion-module-warecotech-warecue/blob/f8dd45e701ccb826f3b4b9c445d9332a809927e8/src/feedbacks.ts#L48-L51), [`src/feedbacks.ts:60-63`](https://github.com/bitfocus/companion-module-warecotech-warecue/blob/f8dd45e701ccb826f3b4b9c445d9332a809927e8/src/feedbacks.ts#L60-L63), [`src/feedbacks.ts:72-75`](https://github.com/bitfocus/companion-module-warecotech-warecue/blob/f8dd45e701ccb826f3b4b9c445d9332a809927e8/src/feedbacks.ts#L72-L75), [`src/feedbacks.ts:82-96`](https://github.com/bitfocus/companion-module-warecotech-warecue/blob/f8dd45e701ccb826f3b4b9c445d9332a809927e8/src/feedbacks.ts#L82-L96), [`src/feedbacks.ts:113-116`](https://github.com/bitfocus/companion-module-warecotech-warecue/blob/f8dd45e701ccb826f3b4b9c445d9332a809927e8/src/feedbacks.ts#L113-L116), [`src/feedbacks.ts:133-136`](https://github.com/bitfocus/companion-module-warecotech-warecue/blob/f8dd45e701ccb826f3b4b9c445d9332a809927e8/src/feedbacks.ts#L133-L136), [`src/feedbacks.ts:159-163`](https://github.com/bitfocus/companion-module-warecotech-warecue/blob/f8dd45e701ccb826f3b4b9c445d9332a809927e8/src/feedbacks.ts#L159-L163)

**What goes wrong:** [`companion/HELP.md:15`](https://github.com/bitfocus/companion-module-warecotech-warecue/blob/f8dd45e701ccb826f3b4b9c445d9332a809927e8/companion/HELP.md#L15) says an Output, Scene, Cue or Timer field can be typed "including a `$(variable)`". That works in actions. But a user who types `$(internal:custom_cue)` into "Cue: is armed", or `$(internal:custom_next_scene)` into the Scene field of "Output: scene is on air", gets a button that never lights and never updates when the variable changes.

**Why it happens:** The feedback callbacks read the typed text as-is and compare the literal `$(internal:custom_cue)` with the cue list. They never expand variables through the feedback's `context.parseVariablesInString()`, which is also what tells Companion to re-check the feedback when the variable changes.

**Fix:** make the callbacks async, take the second `context` argument, and expand each custom value with `await context.parseVariablesInString(String(fb.options.scene ?? ''))` before the lookup. Don't use `self.parseVariablesInString` here: it doesn't track which variables the feedback uses.

### M7: PGM and PVW display presets show the wrong connection's scene when the connection is not named warecue

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/presets.ts:177`](https://github.com/bitfocus/companion-module-warecotech-warecue/blob/f8dd45e701ccb826f3b4b9c445d9332a809927e8/src/presets.ts#L177), [`src/presets.ts:185`](https://github.com/bitfocus/companion-module-warecotech-warecue/blob/f8dd45e701ccb826f3b4b9c445d9332a809927e8/src/presets.ts#L185)

**What goes wrong:** A user adds a second WareCue connection (label `warecue_2`), or names theirs `WareCue-FOH`, and drags the "Output 1: program scene (display)" preset onto a button. The button still reads `$(warecue:output_1_scene)`, so it shows the first connection's scene, or `$NA`, instead of this connection's program and preview scene names.

**Why it happens:** The preset text is built with the literal connection name `warecue` (`PGM ${n}\n$(warecue:output_${n}_scene)`) instead of the connection's actual label.

**Fix:** build the text from the connection's label, for example `` `PGM ${n}\n$(${self.label}:output_${n}_scene)` ``. Presets are rebuilt with the definitions, so a renamed label is picked up.

### M8: Timer message text is parsed for variables twice

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:19-20`](https://github.com/bitfocus/companion-module-warecotech-warecue/blob/f8dd45e701ccb826f3b4b9c445d9332a809927e8/src/actions.ts#L19-L20), [`src/actions.ts:267-271`](https://github.com/bitfocus/companion-module-warecotech-warecue/blob/f8dd45e701ccb826f3b4b9c445d9332a809927e8/src/actions.ts#L267-L271)

**What goes wrong:** No visible effect in normal use. If a variable's value itself contains `$(...)` text and is used in the Message of "Timer: set message", that text is expanded a second time.

**Why it happens:** The Message field is declared with `useVariables: true`, so Companion already replaces variables before the action runs. The callback then passes the result through the module's `str()` helper, which calls `self.parseVariablesInString()` again. The dropdown fields that also use `str()` are not affected and still need it.

**Fix:** read the message directly with `String(ev.options.message ?? '')` and keep `str()` for the dropdown fields.

## 🟢 Low

### L1: A blank or invalid host shows Connecting forever instead of a config error

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/connection.ts:46-58`](https://github.com/bitfocus/companion-module-warecotech-warecue/blob/f8dd45e701ccb826f3b4b9c445d9332a809927e8/src/connection.ts#L46-L58)

**What goes wrong:** If the user clears the "WareCue host / IP" field and saves, the connection status stays Connecting indefinitely, and every 3 seconds the log gets `WebSocket construction failed: SyntaxError: Invalid URL: ws://:8090`. Nothing tells the user the setting is wrong.

**Why it happens:** The module sets the status to Connecting and then fails to build the WebSocket from the empty address. The error path only logs and schedules another retry; it never reports a failure status.

**Fix:** check for an empty host before connecting and set `InstanceStatus.BadConfig` ("Host is not set"); in the construction error path, report a failure status instead of retrying silently.

### L2: Button presses that fail because WareCue is offline or slow leave no trace in the log

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:59-271`](https://github.com/bitfocus/companion-module-warecotech-warecue/blob/f8dd45e701ccb826f3b4b9c445d9332a809927e8/src/actions.ts#L59-L271)

**What goes wrong:** While WareCue is unreachable, or when a command gets no reply within 5 seconds, an operator pressing "GO" or "TAKE SCN 3" sees nothing happen, and nothing in the Companion log says why. Only refusals that WareCue itself sends back are logged.

**Why it happens:** Every action discards the result of the send (`void self.send(...)`). The send returns "not connected" or "timed out" failures, but nothing checks or logs them.

**Fix:** send through a helper that awaits the result and logs a warning such as `` `${command} failed: ${result.error}` `` when it fails.

### L3: After changing host or port, buttons and variables keep showing the old WareCue's state

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:36-39`](https://github.com/bitfocus/companion-module-warecotech-warecue/blob/f8dd45e701ccb826f3b4b9c445d9332a809927e8/src/main.ts#L36-L39), [`src/main.ts:58-69`](https://github.com/bitfocus/companion-module-warecotech-warecue/blob/f8dd45e701ccb826f3b4b9c445d9332a809927e8/src/main.ts#L58-L69)

**What goes wrong:** A user switches the connection from 192.168.1.50 to 192.168.1.60, which is offline. The status shows Connecting or Disconnected, but cue buttons stay lit and `$(warecue:cue_active_name)` / `$(warecue:output_1_scene)` still show the old machine's values, so the operator may think the new target is live.

**Why it happens:** On reconnect the module clears its stored show state but doesn't push the cleared values to Companion's variables or re-check feedbacks. They only refresh when the first state message arrives from the new host.

**Fix:** after the reset in `#connect()`, call `setVariableValues(this)` and `this.checkFeedbacks()` (and optionally rebuild the definitions so the dropdowns drop the old show's names).

## 💡 Nice to Have

### N1: Connection status is re-sent to Companion on every state update

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/connection.ts:101-104`](https://github.com/bitfocus/companion-module-warecotech-warecue/blob/f8dd45e701ccb826f3b4b9c445d9332a809927e8/src/connection.ts#L101-L104)

**What goes wrong:** Nothing visible. Every state update from WareCue (for example each timer tick) re-sends the "OK" status and the `connection` variable to Companion even when nothing changed, adding a little needless traffic.

**Why it happens:** Each state message calls the status handler with "ok", and `updateStatus()` in base 1.13.6 sends the status every time it is called.

**Fix:** remember the last reported status and only forward it, and set the `connection` variable, when it changes.

### N2: The auth token is stored as plain text and included in exports

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/config.ts:36-43`](https://github.com/bitfocus/companion-module-warecotech-warecue/blob/f8dd45e701ccb826f3b4b9c445d9332a809927e8/src/config.ts#L36-L43)

**What goes wrong:** The "Auth token (optional)" field is a normal text field, so the token shows in clear text in the connection settings and is included when the user exports their Companion configuration to share it.

**Fix:** declare the token as a `secret-text` field (supported from API 1.13) and read it from the connection's secrets instead of the plain config. As a first release, no migration is needed.

## 🔮 Next Release

### R1: Consider moving to a newer `@companion-module/base`

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-warecotech-warecue/blob/f8dd45e701ccb826f3b4b9c445d9332a809927e8/package.json)

**What goes wrong:** No visible effect today. The module targets API 1.13 (Companion 4.1+). Base 1.14 adds the automatic config layout; base 2.0/2.1 (Companion 4.3+/5.0+) adds expression support in options and the current module API.

**Fix:** in a later release, bump to `~1.14.x`, or follow the v1-to-v2 migration guide and its compliance checklist.

## 📝 Additional Notes

- This is the module's first release: there is no previous tag, so there is no diff and the whole module was reviewed. Every finding is classified 🆕 NEW.
- `tsconfig.json` differs from the template: it has no `"extends": "./tsconfig.build.json"` (line 2 is `"compilerOptions": {`). Not blocking, since the module builds; the missing `tsconfig.build.json` itself is [C6](#c6-missing-tsconfigbuildjson).
