# Review: companion-module-oncue-oncue v1.3.5

| Field | Value |
| --- | --- |
| **Module** | [`companion-module-oncue-oncue`](https://github.com/bitfocus/companion-module-oncue-oncue) |
| **Scope** | `tag` (v1.3.4..v1.3.5) |
| **Version** | v1.3.5 (`1157b26`) |
| **Release** | Update — last published v1.3.4 |
| **API** | 1 (base 1.14.1, yarn.lock) |
| **Template** | `companion-module-template-js-v1` @ `9e222b4` (2026-03-26, pinned) · `.yarnrc.yml` from `companion-module-template-js` @ `89da037` (2026-11-01) |
| **Review date** | 2026-11-06 |

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | For an API 1 module on base 1.13+ (here 1.14.1), Companion resolves `$(...)` variables in a `textinput` option that declares `useVariables` before the action callback runs, so adding the flag is enough and no `parseVariablesInString` call is needed | the companion-v1-api-compliance v1.13 notes (auto variable parsing in `textinput` fields) and the confirmed host behaviour recorded for API 2 modules; base 1.14.1 has no runtime code for `useVariables`, so any parsing happens in Companion itself. Companion's host code for API 1 modules was not checked | [N1](#n1-the-load-speaker-by-name-action-does-not-accept-companion-variables) (the fix only) |

## 📋 Issues

### Blocking

- [ ] [C1: Module code sits at the repository root instead of in `src/`](#c1-module-code-sits-at-the-repository-root-instead-of-in-src)
- [ ] [C2: The shared Companion code style is not configured in package.json](#c2-the-shared-companion-code-style-is-not-configured-in-packagejson)
- [ ] [C3: package.json does not pin the Yarn version used to build the module](#c3-packagejson-does-not-pin-the-yarn-version-used-to-build-the-module)
- [ ] [C4: There is no format script to apply the code style](#c4-there-is-no-format-script-to-apply-the-code-style)
- [ ] [C5: Prettier is missing from devDependencies](#c5-prettier-is-missing-from-devdependencies)

### Non-blocking

- [ ] [L1: Timer open, Teleprompter open and Player open variables keep showing yes after OnCue goes offline](#l1-timer-open-teleprompter-open-and-player-open-variables-keep-showing-yes-after-oncue-goes-offline)
- [ ] [N1: The Load Speaker by Name action does not accept Companion variables](#n1-the-load-speaker-by-name-action-does-not-accept-companion-variables)

## 🔴 Critical

The five template findings below were already present in v1.3.4; this release did not introduce them. Template checks cover the whole module whatever the review scope, so they block this release too.

### C1: Module code sits at the repository root instead of in `src/`

- **Source:** 🤖 validate-template (SRC-AT-ROOT)
- **Classification:** unchanged since v1.3.4 (whole-module template check)
- **File:** [`main.js`](https://github.com/bitfocus/companion-module-oncue-oncue/blob/1157b2697f93bfdad3a2c21d6dd1fa3f08b4a56f/main.js)
- **Validator:** "Source file at module root — all source must be under src/"

**What goes wrong:** The module builds and runs, but its layout doesn't match the JavaScript template every API 1 Companion module starts from. Anyone who helps troubleshoot it (Bitfocus reviewers, other module developers, future maintainers) looks for the code in `src/` and finds it at the repository root, mixed in with the config files.

**Why it happens:** The whole module (760 lines) is a single `main.js` at the repository root. The template keeps all source under `src/` (`src/main.js`, `src/actions.js`, `src/feedbacks.js`, `src/variables.js`, `src/upgrades.js`), and its `package.json` and `companion/manifest.json` point there.

**Expected vs found:**

```text
Expected: source under src/  (template: "main": "src/main.js", manifest "entrypoint": "../src/main.js")
Found:    main.js at the repository root  ("main": "main.js", manifest "entrypoint": "../main.js")
```

**Fix:** move `main.js` into `src/` and point `package.json` and the manifest at the new location. Splitting it into the template's `actions.js` / `feedbacks.js` / `variables.js` files is welcome but not required.

```jsonc
// package.json
"main": "src/main.js",
// companion/manifest.json → runtime
"entrypoint": "../src/main.js"
```

### C2: The shared Companion code style is not configured in package.json

- **Source:** 🤖 validate-template (PKG-FIELD)
- **Classification:** unchanged since v1.3.4 (whole-module template check)
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-oncue-oncue/blob/1157b2697f93bfdad3a2c21d6dd1fa3f08b4a56f/package.json)
- **Validator:** "Missing required field 'prettier' (present in template)"

**What goes wrong:** Every Companion module formats its code with the same Prettier settings, shipped in `@companion-module/tools`. Without the `prettier` field, an editor or a contributor running Prettier on this repository uses Prettier's defaults instead, so the formatting drifts from other modules and from the template.

**Why it happens:** The template's `package.json` has a top-level `"prettier"` field that points Prettier at the shared config. The module's `package.json` has no such field.

**Expected vs found:**

```text
Expected: "prettier": "@companion-module/tools/.prettierrc.json"
Found:    (no "prettier" field)
```

**Fix:** add the template's field to `package.json`.

```jsonc
"prettier": "@companion-module/tools/.prettierrc.json"
```

### C3: package.json does not pin the Yarn version used to build the module

- **Source:** 🤖 validate-template (PKG-FIELD)
- **Classification:** unchanged since v1.3.4 (whole-module template check)
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-oncue-oncue/blob/1157b2697f93bfdad3a2c21d6dd1fa3f08b4a56f/package.json)
- **Validator:** "Missing required field 'packageManager' (present in template)"

**What goes wrong:** Someone who clones the repository to build or fix the module gets whatever Yarn version their machine has (often Yarn 1). The committed `yarn.lock` and `.yarnrc.yml` are Yarn 4 files, so an older Yarn ignores the settings or rewrites the lockfile, and the build may not match the one Bitfocus produces.

**Why it happens:** The template's `package.json` names the exact Yarn version in a `packageManager` field, which Corepack (bundled with Node) reads to install and run that version. The module's `package.json` has no `packageManager` field.

**Expected vs found:**

```text
Expected: "packageManager": "yarn@4.12.0"
Found:    (no "packageManager" field)
```

**Fix:** add the template's field to `package.json`.

```jsonc
"packageManager": "yarn@4.12.0"
```

### C4: There is no format script to apply the code style

- **Source:** 🤖 validate-template (PKG-SCRIPT)
- **Classification:** unchanged since v1.3.4 (whole-module template check)
- **File:** [`package.json:18-20`](https://github.com/bitfocus/companion-module-oncue-oncue/blob/1157b2697f93bfdad3a2c21d6dd1fa3f08b4a56f/package.json#L18-L20)
- **Validator:** "Missing required script 'format'"

**What goes wrong:** A contributor can't run `yarn format` to format the code with the shared Companion style before opening a pull request, the way they can in every module built from the template.

**Why it happens:** The template's `scripts` block has a `format` script that runs Prettier over the repository. The module's `scripts` block only has `package`.

**Expected vs found:**

```text
Expected: "format": "prettier -w ."
Found:    "scripts": { "package": "companion-module-build" }
```

**Fix:** add the template's `format` script.

```jsonc
"scripts": {
	"format": "prettier -w .",
	"package": "companion-module-build"
}
```

### C5: Prettier is missing from devDependencies

- **Source:** 🤖 validate-template (PKG-DEVDEP)
- **Classification:** unchanged since v1.3.4 (whole-module template check)
- **File:** [`package.json:24-26`](https://github.com/bitfocus/companion-module-oncue-oncue/blob/1157b2697f93bfdad3a2c21d6dd1fa3f08b4a56f/package.json#L24-L26)
- **Validator:** "Missing devDependency 'prettier' (present in template)"

**What goes wrong:** Even with the `format` script from C4 in place, `yarn format` fails on a fresh clone, because Prettier is never installed.

**Why it happens:** The template lists `prettier` in `devDependencies`, so `yarn install` installs it. The module's `devDependencies` only lists `@companion-module/tools`.

**Expected vs found:**

```text
Expected: "prettier": "^3.7.4"  (in devDependencies)
Found:    "devDependencies": { "@companion-module/tools": "^2.0.0" }
```

**Fix:** add Prettier with `yarn add --dev prettier@^3.7.4`, and commit the updated `yarn.lock`.

## 🟢 Low

### L1: Timer open, Teleprompter open and Player open variables keep showing yes after OnCue goes offline

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`main.js:113-120`](https://github.com/bitfocus/companion-module-oncue-oncue/blob/1157b2697f93bfdad3a2c21d6dd1fa3f08b4a56f/main.js#L113-L120), [`main.js:737-740`](https://github.com/bitfocus/companion-module-oncue-oncue/blob/1157b2697f93bfdad3a2c21d6dd1fa3f08b4a56f/main.js#L737-L740)

**What goes wrong:** Say a user puts `$(oncue:timer_open)` on a button to show whether the OnCue Timer window is open. When OnCue is closed or its PC drops off the network, the connection turns red, `$(oncue:oncue_connection)` changes to "disconnected" and the new "OnCue: Module Open" feedback turns off, but the button text still says "yes". The same release gives two different answers to "is the Timer open?": the feedback says no, the variable says yes. The same goes for `tp_open` and `player_open`.

**Why it happens:** The three new "open" variables are only written when a poll of OnCue succeeds. When a poll fails, the module sets only the connection variable to "disconnected" and leaves the three "open" variables at their last value. The "OnCue: Module Open" feedback stays correct because it also checks whether the module is connected ([`main.js:571`](https://github.com/bitfocus/companion-module-oncue-oncue/blob/1157b2697f93bfdad3a2c21d6dd1fa3f08b4a56f/main.js#L571)).

**Fix:** clear the three "open" variables in the same place the connection variable is set to "disconnected" (use `''` instead of `'no'` if "unknown" is the better meaning).

```js
// main.js:117
this.setVariableValues({ oncue_connection: 'disconnected', timer_open: 'no', tp_open: 'no', player_open: 'no' });
```

## 💡 Nice to Have

### N1: The Load Speaker by Name action does not accept Companion variables

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`main.js:254-258`](https://github.com/bitfocus/companion-module-oncue-oncue/blob/1157b2697f93bfdad3a2c21d6dd1fa3f08b4a56f/main.js#L254-L258)

**What goes wrong:** An operator who wants one button to load the speaker named in a custom variable sets the "Speaker name (or part of it)" field of "Timer: Load Speaker by Name" to `$(internal:custom_next_speaker)`. OnCue receives that literal text instead of the speaker's name, finds no matching speaker, and loads nothing. Typing a plain name such as `Maria` works.

**Why it happens:** Companion only offers and fills in variables for a text field that declares it supports them (`useVariables: true`). The new "Speaker name" field doesn't declare it, and the action sends the field's text to OnCue exactly as typed. Nothing in `main.js` resolves variables.

**Fix:** declare variable support on the field. On base 1.13 and later, Companion then resolves the variables before the action runs (see [A1](#-assumptions-to-confirm)).

```js
options: [{ type: 'textinput', id: 'name', label: 'Speaker name (or part of it)', default: '', useVariables: true }],
```

If a live test shows the action still receives the raw `$(...)` text, resolve it in the callback as well: `callback: async (action, context) => { const name = await context.parseVariablesInString(action.options.name); await this.sendCommand('timer', 'loadspeaker', { name }); }`.
