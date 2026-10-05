# Review: companion-module-generic-midi v2.1.1

| | |
| --- | --- |
| **Module** | `companion-module-generic-midi` |
| **Version** | v2.1.1 (previous tag: v1.4.0) |
| **Scope:** | tag (`v1.4.0..v2.1.1`) |
| **Template** | `companion-module-template-ts` @ `d62230e` (2026-08-28, main) |
| **API** | 2.0 (base 2.0.4, yarn.lock) — requires Companion 4.3+ |
| **Language** | TypeScript (ESM) |
| **Transport** | Local MIDI via `@julusian/midi` native addon (no network I/O) |
| **Review date** | 2026-10-05 |

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
| ---------- | -------- | ------------- | ------- |
| 🔴 Critical | 7 | 0 | 7 |
| 🟠 High | 3 | 0 | 3 |
| 🟡 Medium | 6 | 0 | 6 |
| 🟢 Low | 6 | 0 | 6 |
| 💡 Nice to Have | 3 | 0 | 3 |
| **Total** | **25** | **0** | **25** |

## Verdict: ❌ Changes Required

## 📋 Issues

**Blocking**

- [ ] [C1: Missing .gitattributes](#c1-missing-gitattributes)
- [ ] [C2: Missing .husky/pre-commit hook (.husky is gitignored)](#c2-missing-huskypre-commit-hook-husky-is-gitignored)
- [ ] [C3: .gitignore missing template entries (/*.tgz not ignored)](#c3-gitignore-missing-template-entries-tgz-not-ignored)
- [ ] [C4: tsconfig.build.json diverges from template](#c4-tsconfigbuildjson-diverges-from-template)
- [ ] [C5: tsconfig.json drops the template types setting](#c5-tsconfigjson-drops-the-template-types-setting)
- [ ] [C6: rimraf listed under dependencies instead of devDependencies](#c6-rimraf-listed-under-dependencies-instead-of-devdependencies)
- [ ] [C7: Manifest keyword MIDI duplicates the module id](#c7-manifest-keyword-midi-duplicates-the-module-id)
- [ ] [H1: ESLint crashes so lint cannot run](#h1-eslint-crashes-so-lint-cannot-run)
- [ ] [H2: Saved Use Variables actions and feedbacks lose their variables after upgrade](#h2-saved-use-variables-actions-and-feedbacks-lose-their-variables-after-upgrade)
- [ ] [H3: SysEx bytes no longer resolve variables](#h3-sysex-bytes-no-longer-resolve-variables)

**Non-blocking**

- [ ] [M1: Missing .github/workflows/node.yaml](#m1-missing-githubworkflowsnodeyaml)
- [ ] [M2: Upgrade script 1 writes the feedback id as object Object](#m2-upgrade-script-1-writes-the-feedback-id-as-object-object)
- [ ] [M3: SysEx Value feedback throws on every evaluation](#m3-sysex-value-feedback-throws-on-every-evaluation)
- [ ] [M4: Auto-created variables stop updating for existing users](#m4-auto-created-variables-stop-updating-for-existing-users)
- [ ] [M5: Feedback definitions not rebuilt when Auto-Created Variables setting changes](#m5-feedback-definitions-not-rebuilt-when-auto-created-variables-setting-changes)
- [ ] [M6: Recorded SysEx actions throw when run](#m6-recorded-sysex-actions-throw-when-run)
- [ ] [L1: Program Change Value feedback is off by one](#l1-program-change-value-feedback-is-off-by-one)
- [ ] [L2: Value feedbacks report 0 before any data is received](#l2-value-feedbacks-report-0-before-any-data-is-received)
- [ ] [L3: Relative offset defaults to the absolute default value](#l3-relative-offset-defaults-to-the-absolute-default-value)
- [ ] [L4: Upgrade script 2 marks every action changed and touches SysEx actions](#l4-upgrade-script-2-marks-every-action-changed-and-touches-sysex-actions)
- [ ] [L5: noteStates is mutated in place and pushed in full on every note](#l5-notestates-is-mutated-in-place-and-pushed-in-full-on-every-note)
- [ ] [L6: Base dependency uses a caret range](#l6-base-dependency-uses-a-caret-range)
- [ ] [N1: Module typing not tied to ModuleConfig](#n1-module-typing-not-tied-to-moduleconfig)
- [ ] [N2: Leftover await on plain values and unchecked non-null assertions](#n2-leftover-await-on-plain-values-and-unchecked-non-null-assertions)
- [ ] [N3: Value feedbacks inherit defaultStyle from the boolean feedback](#n3-value-feedbacks-inherit-defaultstyle-from-the-boolean-feedback)

---

## 🔴 Critical

### C1: Missing .gitattributes

**Classification:** 🆕 NEW · **File:** `.gitattributes`

The template tracks `.gitattributes`, and the module does not have it.

**Fix:** Add `.gitattributes` with the template content:

```text
* text=auto eol=lf
```

### C2: Missing .husky/pre-commit hook (.husky is gitignored)

**Classification:** 🆕 NEW · **File:** `.husky/pre-commit`, `.gitignore`

The template tracks `.husky/pre-commit`, which runs `lint-staged`. `package.json` already has `"postinstall": "husky"` and a `lint-staged` block, but the module's `.gitignore` lists `.husky`, so the hook can never be committed.

**Fix:** Remove `.husky` from `.gitignore` and commit the template's `.husky/pre-commit`.

### C3: .gitignore missing template entries (/*.tgz not ignored)

**Classification:** 🆕 NEW · **File:** `.gitignore`

The template entries `/*.tgz`, `/.yarn` and `/.vscode` are missing.

- `.yarn/` and `.vscode/` already ignore the same directories, so for those two you only need to match the template's spelling.
- `/*.tgz` really is missing. v1.4.0 committed `generic-midi-1.3.3.tgz`, which this release deletes. After `yarn package`, an untracked `generic-midi-2.1.1.tgz` sits at the repo root and is not ignored. The release's own last commit is "Delete generic-midi-2.1.1.tgz".

**Fix:** Align `.gitignore` with the template, including `/*.tgz`, `/.yarn` and `/.vscode`.

### C4: tsconfig.build.json diverges from template

**Classification:** 🔙 REGRESSION · **File:** `tsconfig.build.json:2`

This release changed the file, which used node18/Node16 settings before.

- **Base config:** it extends `@companion-module/tools/tsconfig/node22/recommended.json`. The template uses `recommended-esm.json`.
- **Extra options:** it adds `"module": "NodeNext"`, `"moduleResolution": "NodeNext"`, `"noUnusedLocals": false`, `"noUnusedParameters": false` and `"types": []`.
- **Missing option:** it does not have the template's `"verbatimModuleSyntax": true`.

**Fix:** Replace the file with the template's `tsconfig.build.json`. Then fix any unused locals or type-only imports that the stricter settings report.

### C5: tsconfig.json drops the template types setting

**Classification:** 🔙 REGRESSION · **File:** `tsconfig.json:6`

This release replaced `"types": ["node"]` with `"lib": ["es2023", "dom"]`. It is not one of the accepted deviations: neither the jest hint nor a test-scope widening.

**Fix:** Restore the template's `compilerOptions` (`"types": ["node"]`) and remove the `lib` override.

### C6: rimraf listed under dependencies instead of devDependencies

**Classification:** 🆕 NEW · **File:** `package.json`

`rimraf` (`^6.1.0`) is under `dependencies`. Only the `build` script uses it, but it ships as a runtime dependency. The template lists it under `devDependencies`.

**Fix:** Move `rimraf` to `devDependencies`.

### C7: Manifest keyword MIDI duplicates the module id

**Classification:** 🆕 NEW · **File:** `companion/manifest.json`

`keywords` is `["MIDI"]`, and `MIDI` matches the module id `generic-midi`. Keywords that repeat the id or name are banned because they add nothing to search.

**Fix:** Remove `MIDI`. Add meaningful search terms in its place, for example `note`, `control change`, `program change`, `sysex`, `timecode`.

---

## 🟠 High

### H1: ESLint crashes so lint cannot run

**Classification:** 🔙 REGRESSION · **File:** `package.json`

`yarn lint` crashes before it lints any file:

```text
TypeError: Key "rules": Key "no-unassigned-vars": Could not find "no-unassigned-vars" in plugin "@".
```

This release downgraded `eslint` from `~9.36.0` to `~9.14.0`. The shared config in `@companion-module/tools@3.1.0` enables the core rule `no-unassigned-vars`, and that rule only exists in newer ESLint 9.x. The lint gate fails, and the lint-staged pre-commit step (`yarn lint:raw --fix`) would fail too.

**Fix:** Use the template's `"eslint": "^9.39.4"`, then run `yarn lint` and fix what it reports.

### H2: Saved Use Variables actions and feedbacks lose their variables after upgrade

**Classification:** 🔙 REGRESSION · **Files:** `src/operations.ts:92-131`, `src/actions.ts:28-33`, `src/feedbacks.ts:32-37`, `src/upgrades.ts`

**What changed:** v1.4.0 had a `useVariables` checkbox plus the text inputs `chValue`, `noteValue`, `ccValue` and `varValue`. When the box was ticked, the callbacks used those text inputs instead of the number fields. This release removes the checkbox and the first three inputs, and turns `varValue` into a `number` field that only shows in Relative mode. No upgrade script moves the saved data. Upgrade script 2 only adds the over-time options.

**Effects:**

- **Actions:** non-relative actions saved with "Use Variables" on (for example a channel of `$(internal:x)`) now silently send whatever static `channel`, `note`, `controller` or value number was stored, usually the default. The user's `$(...)` references are dropped without any warning, so buttons send the wrong MIDI message.
- **Relative mode:** a saved `varValue` string such as `$(internal:x)` now lands in a `number` field, and `Number()` gives `NaN`.
- **NaN values:** `MidiMessage.constrain()` (`src/midi/msgtypes.ts:102-104`) lets `NaN` through, because both comparisons are false. `NaN` then ends up in the status and data bytes, which are used for the data-store lookup and then sent to the device.
- **Feedbacks:** feedbacks have no `relValue` option, so the `if (opts.relValue)` block in `feedbacks.ts:32-37` is dead code. Feedbacks that used variables now match against the static numbers and light up on the wrong condition.

**Fix:** Add a new upgrade script at the end of `UpgradeScripts`, and do not edit or reorder the existing ones. For each action and feedback where `options.useVariables?.value === true`:

- set `channel`, `note`, `controller` and `<valId>` from `chValue`, `noteValue`, `ccValue` and `varValue`, using `FixupNumericOrVariablesValueToExpressions` from `@companion-module/base`;
- for relative actions, run `varValue` through the same helper;
- delete `useVariables`, `chValue`, `noteValue` and `ccValue`, and push only the entries that changed.

Then delete the leftover `chValue` / `noteValue` / `ccValue` overrides in `src/actions.ts:30-32` and `src/feedbacks.ts:34-36`. Upgrade script 1 copies `channel`/`note`/`controller` into those keys on every saved action and feedback, so in Relative mode a stale hidden value the user can no longer see or edit currently overrides the visible Channel, Note or Controller. Remove the dead `relValue` block in `feedbacks.ts` too. Finally, make `constrain()` reject values that are not finite, for example `if (!Number.isFinite(num)) return 0`.

### H3: SysEx bytes no longer resolve variables

**Classification:** 🔙 REGRESSION · **Files:** `src/operations.ts:133-140`, `src/actions.ts:23-26`, `src/feedbacks.ts:27-30`

**What changed:** in v1.4.0 the `bytes` text input had `useVariables: true`, and the code called `context.parseVariablesInString`. The migration removed both and put `await opts[valId]` in their place, which does nothing. Under API 2.0, a value-mode text input is only parsed for variables when the field sets `useVariables: true`.

**Effects:**

- An existing SysEx string such as `F0 $(internal:x) F7` is now sent literally. `parseInt('$(internal:x)')` returns `NaN`, and the resulting byte array goes straight to `midiOutput.send()`.
- SysEx feedbacks that used variables stop matching.
- If the field is in expression mode and returns something other than a string, `.split` throws.
- The bytes are never checked. The code never enforces the leading `0xF0`, the trailing `0xF7` or the 0–255 range, even though the tooltip says they are required.

**Fix:**

- Restore `useVariables: true` on the `bytes` field.
- Use `String(opts.bytes ?? '')` before `.split`.
- After parsing, keep only integers from 0 to 255 and require `bytes[0] === 0xF0 && bytes.at(-1) === 0xF7`. If the check fails, log a warning and return without sending.

---

## 🟡 Medium

### M1: Missing .github/workflows/node.yaml

**Classification:** 🆕 NEW · **File:** `.github/workflows/node.yaml`

The template tracks the `node.yaml` CI workflow, and the module does not have it. The module only has `companion-module-checks.yaml`.

**Fix:** Add the template's `.github/workflows/node.yaml`.

### M2: Upgrade script 1 writes the feedback id as object Object

**Classification:** 🔙 REGRESSION · **File:** `src/upgrades.ts:43-44`

Under base 2.0, upgrade scripts receive each option wrapped as `{ isExpression, value }` (`CompanionMigrationOptionValues`). Upgrade script 2 in this same release writes options in that wrapped form. As a result, `f.feedbackId = String(f.options.msgType)` now produces `"[object Object]"`, the `switch` that follows never matches, and the feedback is orphaned with an invalid id.

Who is affected: anyone importing an older config that still has `receive_message` feedbacks. This release added `// eslint-disable-next-line @typescript-eslint/no-base-to-string` on this exact line, which silences the warning that points at the bug.

**Fix:** Change the logic in place and keep the script's position in the list:

- read the id with `const t = f.options.msgType; f.feedbackId = String(t && !t.isExpression ? t.value : '')`;
- skip the feedback when that value is empty;
- remove the eslint-disable.

### M3: SysEx Value feedback throws on every evaluation

**Classification:** 🆕 NEW · **File:** `src/feedbacks.ts:65-76`

**Why it throws:** the new `_value` feedback for `sysex` filters out `bytes` (the SysEx `valId`), so it has no options left. Its callback calls `MidiMessage.parseMessage(undefined, { id: 'sysex' })`, which builds `new Sysex(undefined)`. `getFromDataStore` then calls `getValFromMsg`, and `msg.bytes.length` (`src/main.ts:134`) throws a TypeError.

**Impact:** `checkAllFeedbacks()` runs on every incoming MIDI message (`src/main.ts:121`), so any button that uses this feedback throws on every message. The feedback could never return anything useful anyway, because SysEx is never stored (its key is always 0).

**Fix:** Skip the `_value` variant for `sysex` (`if (feedback.id !== 'sysex')`), and replace the `msg!` assertions with an `if (!msg) return undefined` guard.

### M4: Auto-created variables stop updating for existing users

**Classification:** 🔙 REGRESSION · **Files:** `src/feedbacks.ts:42,52`, `src/config.ts:95-101`, `src/upgrades.ts`

Variable auto-creation now also requires the new `autoCreateVars` config setting, which defaults to `false`. No upgrade script turns it on for existing installs. As a result:

- existing feedbacks with `createVar: true` silently stop creating and updating their `$(generic-midi:_...)` variables, and buttons that reference them go blank;
- the "Auto-Create Variable" checkbox disappears from those feedbacks.

**Fix:** In the new upgrade script (see H2), return `updatedConfig: { ...context.currentConfig, autoCreateVars: true }` when any feedback has `options.createVar?.value === true`.

### M5: Feedback definitions not rebuilt when Auto-Created Variables setting changes

**Classification:** 🆕 NEW · **Files:** `src/main.ts:45-74`, `src/feedbacks.ts:52`

Whether the `createVar` option exists depends on `self.config.autoCreateVars`, but `updateFeedbacks()` is only called in `init()`. Toggling the setting does not show or hide the option until the connection restarts.

**Fix:** In `configUpdated()`, call `this.updateFeedbacks()` when `autoCreateVars` changes.

### M6: Recorded SysEx actions throw when run

**Classification:** 🆕 NEW · **Files:** `src/main.ts:160-176`, `src/actions.ts:23-25`

The action recorder stores `msg.args`, so a recorded SysEx action has `bytes` as a `number[]`. The callback now calls `.split` directly on the option value, with no string conversion in between, so running a recorded SysEx action throws `TypeError: parsedSysex.split is not a function`.

**Fix:** When recording a SysEx message, store `bytes` as a string (for example `msg.bytes.map((b) => '0x' + b.toString(16)).join(' ')`). In the callback, convert with `String(...)` or guard with `typeof === 'string'` (see H3).

---

## 🟢 Low

### L1: Program Change Value feedback is off by one

**Classification:** 🆕 NEW · **Files:** `src/feedbacks.ts:74`, `src/main.ts:133-151`

The new "Program Change Value" feedback returns the raw stored data byte (0–127). The module shows program numbers to users as 1–128 (`src/midi/msgtypes.ts:273-279`), so the value is one lower than the number the user expects.

**Fix:** For `program`, return the stored value + 1.

### L2: Value feedbacks report 0 before any data is received

**Classification:** 🆕 NEW · **File:** `src/feedbacks.ts:74`

`return self.getFromDataStore(msg!) ?? 0` makes "nothing received yet" look the same as a real value of 0.

**Fix:** Return `undefined` when there is no stored value.

### L3: Relative offset defaults to the absolute default value

**Classification:** 🆕 NEW · **File:** `src/actions.ts:114-122`

The new `varValue` number field is only shown in Relative mode, where it is an offset, but its default is `action.valDefault` (for example 127 for Note On, 8192 for Pitch). Ticking "Relative" on a new action therefore jumps the value up by the maximum.

**Fix:** Use `default: 0`.

### L4: Upgrade script 2 marks every action changed and touches SysEx actions

**Classification:** 🆕 NEW · **File:** `src/upgrades.ts:71-96`

The new upgrade script:

- pushes every action into `updatedActions`, whether it changed or not;
- adds `sendOverTime`, `timeStartValue`, `time` and `curve` to `sysex` actions, which do not define those options;
- writes `time` as 0, while the field's default is 1 (`src/actions.ts:161`);
- logs every action before and after with `console.log` (script 1 does the same).

**Fix:** Skip `sysex`, use 1 for `time`, push only the actions that changed, and remove the per-action logging (or keep a single summary line).

### L5: noteStates is mutated in place and pushed in full on every note

**Classification:** 🆕 NEW · **File:** `src/variables.ts:49-54`

On every Note On or Note Off, the code reads the array from `getVariableValue('noteStates')`, changes it in place and sets the same reference back.

- **Change detection:** any reference-equality check sees no change.
- **Payload size:** the whole sparse array, indexed by channel 1–16 with unset entries serialised as `null`, crosses IPC on every note during dense playing.

**Fix:** Keep `noteStates` in a field on the module instance and send a copy (`structuredClone`). Index channels 0–15 (or use an object), and consider throttling the `setVariableValues` call (about 20–50 ms).

### L6: Base dependency uses a caret range

**Classification:** 🆕 NEW · **File:** `package.json:26`

`"@companion-module/base": "^2.0.0"` lets the API version the module targets change whenever the lockfile is refreshed. The template pins `2.0.4`.

**Fix:** Pin it to `~2.0.4` (or `2.0.4`) so API 2.0 is the explicit target.

---

## 💡 Nice to Have

### N1: Module typing not tied to ModuleConfig

**Classification:** 🆕 NEW · **Files:** `src/main.ts:16`, `src/config.ts:4`, `src/variables.ts:5-12`

`ModuleInstance extends InstanceBase<InstanceTypes>` uses the generic base shape, and `config!: ModuleConfig` is typed by hand. Because of this, config, actions, feedbacks and variables are not type-checked against the module, and the exported `midiVars` type is never used.

**Fix:** Declare a schema type `{ config: ModuleConfig; secrets: undefined; variables: midiVars; ... }` and extend `InstanceBase<ThatSchema>`.

### N2: Leftover await on plain values and unchecked non-null assertions

**Classification:** 🆕 NEW · **Files:** `src/actions.ts:24,29-32`, `src/feedbacks.ts:28,33-36`

`await opts[...]` was left behind when `parseVariablesInString` was removed; it awaits plain values and does nothing. The `msg!` and `options.at(-1)!` assertions skip null checks that should be there.

**Fix:** Remove the `await`s, convert values explicitly (`String(...)` / `Number(...)` with `Number.isFinite` checks), and add explicit guards.

### N3: Value feedbacks inherit defaultStyle from the boolean feedback

**Classification:** 🆕 NEW · **File:** `src/feedbacks.ts:65-66`

The `_value` feedback is built by spreading the boolean feedback, so it carries `defaultStyle`, which value feedbacks don't use.

**Fix:** Build the value-feedback object explicitly, without `defaultStyle`.

---

## 🔮 Next Release

- If the module moves to API 2.1 (Companion 5.0+), it can use `context.signal` to cancel the "Send Over Time" interval timer when the action is aborted or the connection is destroyed. Nothing in 2.1 is required for this release.
