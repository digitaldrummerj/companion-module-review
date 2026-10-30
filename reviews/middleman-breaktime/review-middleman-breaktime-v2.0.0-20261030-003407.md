# Review: companion-module-middleman-breaktime v2.0.0

| Field | Value |
| --- | --- |
| **Module** | `companion-module-middleman-breaktime` |
| **Scope** | `tag` (v1.0.3..v2.0.0) |
| **Version** | v2.0.0 ([`3e58c9f`](https://github.com/bitfocus/companion-module-middleman-breaktime/tree/3e58c9f80ba33b507d2067fa52ae9713852fe019)) |
| **Release** | Update — last published v1.0.3 |
| **API** | 1 (base 1.13.6, yarn.lock) |
| **Template** | `companion-module-template-js-v1` @ `9e222b4` (2026-03-26, pinned) · `.yarnrc.yml` from `companion-module-template-js` @ `76d25b2` (2026-10-11) |
| **Review date** | 2026-10-30 |

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | For a module on API 1 (`@companion-module/base` 1.x), Companion does **not** resolve `$(...)` variables in `textinput` options marked `useVariables: true` before calling the action or feedback callback. The module must call `context.parseVariablesInString()` itself; automatic parsing arrived with API 2.0 | The base 1.13.6 typings describe `useVariables` only as "Whether to suggest variables to the user", and the base passes options through unchanged. The base CHANGELOG has no auto-parse entry for 1.x. The Companion host source was not checked, and the compliance reviewer assumed the opposite for 1.13 | [H2](#h2-variables-typed-into-the-seconds-and-slot-fields-are-never-resolved-so-those-buttons-and-feedbacks-stop-working) |

## 📋 Issues

### Blocking

- [ ] [C1: Debug logs and the Yarn cache folder are not ignored by git](#c1-debug-logs-and-the-yarn-cache-folder-are-not-ignored-by-git)
- [ ] [C2: Prettier ignore list names LICENSE instead of the template's LICENSE.md](#c2-prettier-ignore-list-names-license-instead-of-the-templates-licensemd)
- [ ] [C3: Yarn settings file is missing, so installs can use a different Yarn setup than the template](#c3-yarn-settings-file-is-missing-so-installs-can-use-a-different-yarn-setup-than-the-template)
- [ ] [C4: Module entry file sits at the repository root instead of under src](#c4-module-entry-file-sits-at-the-repository-root-instead-of-under-src)
- [ ] [C5: package.json does not pin the Yarn version](#c5-packagejson-does-not-pin-the-yarn-version)
- [ ] [H1: LICENSE file does not match the template](#h1-license-file-does-not-match-the-template)
- [ ] [H2: Variables typed into the Seconds and Slot fields are never resolved, so those buttons and feedbacks stop working](#h2-variables-typed-into-the-seconds-and-slot-fields-are-never-resolved-so-those-buttons-and-feedbacks-stop-working)
- [ ] [H3: GitHub checks workflow is indented differently from the template](#h3-github-checks-workflow-is-indented-differently-from-the-template)

### Non-blocking

- [ ] [NR1: Module stays on Companion API 1.13; consider 1.14 or v2 next](#nr1-module-stays-on-companion-api-113-consider-114-or-v2-next)

## 🔴 Critical

### C1: Debug logs and the Yarn cache folder are not ignored by git

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.gitignore`](https://github.com/bitfocus/companion-module-middleman-breaktime/blob/3e58c9f80ba33b507d2067fa52ae9713852fe019/.gitignore)

**What goes wrong:** Companion's `DEBUG-*` log files and the local `/.yarn` folder can be committed to the repository by accident, because git does not ignore them.

**Why it happens:** The template's `.gitignore` lists `DEBUG-*` and `/.yarn`. The module's `.gitignore` (changed in this release) has neither entry.

**Evidence:**

```text
Expected (template): DEBUG-*, /.yarn
Found: neither entry in .gitignore
```

**Fix:** add the two missing lines to `.gitignore`.

```text
DEBUG-*
/.yarn
```

### C2: Prettier ignore list names LICENSE instead of the template's LICENSE.md

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🔙 REGRESSION
- **File:** [`.prettierignore:2`](https://github.com/bitfocus/companion-module-middleman-breaktime/blob/3e58c9f80ba33b507d2067fa52ae9713852fe019/.prettierignore#L2)

**What goes wrong:** The formatting setup no longer matches the template. v1.0.3 matched it on this line; v2.0.0 changed it.

**Why it happens:** Line 2 of `.prettierignore` was changed from the template's `/LICENSE.md` to `/LICENSE`.

**Evidence:**

```text
line 2: found '/LICENSE', template '/LICENSE.md'
```

**Fix:** restore `.prettierignore` to the template's contents (`package.json` and `/LICENSE.md`).

### C3: Yarn settings file is missing, so installs can use a different Yarn setup than the template

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.yarnrc.yml` (missing)

**What goes wrong:** Without the template's Yarn settings file, Yarn 4 can fall back to its default Plug'n'Play install mode instead of a normal `node_modules` folder, so the module installs and builds differently from every other module built from the template.

**Why it happens:** The template tracks a `.yarnrc.yml` that sets `nodeLinker: node-modules`. The module has no `.yarnrc.yml`.

**Evidence:**

```text
Required file .yarnrc.yml is missing (tracked by the template)
```

**Fix:** add `.yarnrc.yml` with the template's contents.

```yaml
nodeLinker: node-modules
```

### C4: Module entry file sits at the repository root instead of under src

- **Source:** 🤖 validate-template (SRC-AT-ROOT)
- **Classification:** 🆕 NEW
- **File:** [`index.js`](https://github.com/bitfocus/companion-module-middleman-breaktime/blob/3e58c9f80ba33b507d2067fa52ae9713852fe019/index.js)

**What goes wrong:** The module's main code (the instance class and `runEntrypoint`, 631 lines, most of them added in this release) lives at the repository root, where the template expects only config files.

**Why it happens:** All source must be under `src/`. The template's entry point is `src/main.js` (`"main": "src/main.js"`). The module uses a root `index.js` (`"main": "index.js"`).

**Evidence:**

```text
index.js: source file at module root (template entry: src/main.js)
package.json: "main": "index.js"
```

**Fix:** move `index.js` to `src/main.js`, update its relative `require` paths, and set `"main": "src/main.js"` in `package.json`.

### C5: package.json does not pin the Yarn version

- **Source:** 🤖 validate-template (PKG-FIELD)
- **Classification:** 🆕 NEW
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-middleman-breaktime/blob/3e58c9f80ba33b507d2067fa52ae9713852fe019/package.json)

**What goes wrong:** Anyone building the module (including the Bitfocus build) may use a different Yarn version from the one the lockfile was made with.

**Why it happens:** The template's `package.json` has a `packageManager` field that pins Yarn; the module's `package.json` has none.

**Evidence:**

```text
Missing required field 'packageManager' (template: "packageManager": "yarn@4.12.0")
```

**Fix:** add the field to `package.json`.

```json
"packageManager": "yarn@4.12.0"
```

## 🟠 High

### H1: LICENSE file does not match the template

- **Source:** 🤖 validate-template (LICENSE-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`LICENSE:3`](https://github.com/bitfocus/companion-module-middleman-breaktime/blob/3e58c9f80ba33b507d2067fa52ae9713852fe019/LICENSE#L3)

**What goes wrong:** The copyright line differs from the template's licence, which every Companion module is expected to carry unchanged.

**Why it happens:** This release replaced the copyright line with `Copyright (c) 2026 Middleman Software, Inc.`.

**Evidence:**

```text
line 3: found 'Copyright (c) 2026 Middleman Software, Inc.', template 'Copyright (c) 2022 Bitfocus AS - Open Source'
```

**Fix:** use the template's `LICENSE` file as-is.

### H2: Variables typed into the Seconds and Slot fields are never resolved, so those buttons and feedbacks stop working

- **Source:** 🔎 QA reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/actions.js:128-177`](https://github.com/bitfocus/companion-module-middleman-breaktime/blob/3e58c9f80ba33b507d2067fa52ae9713852fe019/src/actions.js#L128-L177), [`src/feedbacks.js:152-235`](https://github.com/bitfocus/companion-module-middleman-breaktime/blob/3e58c9f80ba33b507d2067fa52ae9713852fe019/src/feedbacks.js#L152-L235), [`src/api.js:2464-2466`](https://github.com/bitfocus/companion-module-middleman-breaktime/blob/3e58c9f80ba33b507d2067fa52ae9713852fe019/src/api.js#L2464-L2466)

**What goes wrong:** The help page says the Seconds field of **Armed Duration +**, **Armed Duration -** and **Set Armed Duration** "accepts variables". Say a user sets **Set Armed Duration** > Seconds to `$(internal:custom_break_len)` (value 90) and presses the button. Nothing is sent to BreakTime. The Temporary Warning feedback shows "Duration must be a whole number of seconds" (or "Seconds must be a whole number from 1 to 65535" for +/-), and the log shows `outcome=NotSent`. The feedbacks fail the same way: **Armed Duration Is** with a variable in Seconds is always false, and **Running Slot Time Remaining Below** with a variable Slot or Seconds is always false, so the red "time almost up" highlight never lights. Buttons with plain numbers, like the preset defaults (`5`, `60`, `10`), still work; only users who follow the documented variable feature are affected.

**Why it happens:** The module is on API 1 (`@companion-module/base` 1.13.6). On API 1, `useVariables: true` on a text field only makes the editor suggest variables. Companion hands the callback the raw text, `$(internal:custom_break_len)`, and the module has to resolve it by calling `context.parseVariablesInString()`. Nothing in the module calls it, so the raw text goes to `Number()`, which gives `NaN`. The code comments assume Companion already parsed the value, which is only true from API 2.0. v1.0.3 used number fields that did not take variables, so this is new in v2.0.0.

**Evidence:**

```js
// src/actions.js:162-177
		actions.setArmedDuration = {
			name: 'Set Armed Duration',
			options: [
				{
					type: 'textinput',
					label: 'Seconds',
					id: 'seconds',
					default: '60',
					useVariables: true,
					...
				},
			],
			callback: async function (action) {
				await self.setArmedDuration(action.options)
			},
		}
```

```js
// src/api.js:2464-2466 (changeDuration, used by Armed Duration +/-)
		const seconds = typeof amount === 'string' && amount.trim() === '' ? NaN : Number(amount)

		if (!Number.isInteger(seconds) || seconds < 1 || seconds > DURATION_STEP_MAX_S) {
```

```js
// src/feedbacks.js:46-56
 * Converts a variable-enabled option (already parsed by Companion) to an integer
 ...
function toInteger(value) {
	const number = typeof value === 'string' && value.trim() === '' ? NaN : Number(value)

	return Number.isInteger(number) ? number : null
}
```

```js
// src/feedbacks.js:161-162 and 232-234
			callback: async function (feedback) {
				const seconds = toInteger(feedback.options.seconds ?? '60')
...
			callback: async function (feedback) {
				const slot = toInteger(feedback.options.slot ?? '1')
				const seconds = toInteger(feedback.options.seconds ?? '10')
```

```text
$ grep -rn parseVariables index.js src/   -> (no hits)
node_modules/@companion-module/base/package.json: "version": "1.13.6"
companion/HELP.md:122: The seconds field accepts variables, so a button can be retargeted without editing code.
```

**Confirm by:** run `grep -rn parseVariables index.js src/` (no hits) and check that `node_modules/@companion-module/base` is 1.13.6. Then open [`src/actions.js:128-177`](https://github.com/bitfocus/companion-module-middleman-breaktime/blob/3e58c9f80ba33b507d2067fa52ae9713852fe019/src/actions.js#L128-L177) and [`src/feedbacks.js:152-235`](https://github.com/bitfocus/companion-module-middleman-breaktime/blob/3e58c9f80ba33b507d2067fa52ae9713852fe019/src/feedbacks.js#L152-L235): the options have `useVariables: true`, and `action.options` / `feedback.options` go straight to `Number()` / `toInteger()` with no `parseVariablesInString` call.

**Fix:** resolve the variables before turning the text into a number. In each action callback, take `context` as the second argument and pass the parsed value on:

```js
callback: async (action, context) => {
	const duration = await context.parseVariablesInString(String(action.options.duration ?? '5'))
	await self.increaseDuration({ ...action.options, duration })
},
```

Do the same for **Armed Duration -** (`duration`) and **Set Armed Duration** (`seconds`). In the feedbacks **Armed Duration Is** (`seconds`) and **Running Slot Time Remaining Below** (`slot`, `seconds`):

```js
callback: async (feedback, context) => {
	const seconds = toInteger(await context.parseVariablesInString(String(feedback.options.seconds ?? '60')))
	// ...
},
```

Companion then also re-checks those feedbacks when a referenced variable changes. Update the JSDoc comments that say the values are already parsed. The alternative is to move to API 2.x, where Companion parses them for you.

### H3: GitHub checks workflow is indented differently from the template

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.github/workflows/companion-module-checks.yaml:4`](https://github.com/bitfocus/companion-module-middleman-breaktime/blob/3e58c9f80ba33b507d2067fa52ae9713852fe019/.github/workflows/companion-module-checks.yaml#L4)

**What goes wrong:** The workflow file no longer matches the template byte for byte, which makes it harder to spot real changes when the template's workflow is updated.

**Why it happens:** The file indents `push:` (line 4) and the rest of the YAML with 4 spaces where the template uses 2. The content is otherwise the same.

**Confirm by:** compare [`.github/workflows/companion-module-checks.yaml`](https://github.com/bitfocus/companion-module-middleman-breaktime/blob/3e58c9f80ba33b507d2067fa52ae9713852fe019/.github/workflows/companion-module-checks.yaml) with the template's file: line 4 `push:` is indented 4 spaces, the template uses 2.

**Fix:** copy the template's `.github/workflows/companion-module-checks.yaml` over the module's file (and exclude `.github` from the formatter if it re-indents it).

## 🔮 Next Release

### NR1: Module stays on Companion API 1.13; consider 1.14 or v2 next

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`package.json:17`](https://github.com/bitfocus/companion-module-middleman-breaktime/blob/3e58c9f80ba33b507d2067fa52ae9713852fe019/package.json#L17)

**What goes wrong:** Nothing visible today. v2.0.0 moved the base from `^1.11.2` to `~1.13.5`, so the module now needs Companion 4.1 or later, but it doesn't get the 1.14 automatic config layout or the v2 features (expressions in options, and abort signals and action results on 2.1).

**Why it happens:** `"@companion-module/base": "~1.13.5"` pins the 1.13 line. This is a forward-looking suggestion, not a compliance defect.

**Fix:** in a later release, consider `~1.14.x` or a move to `@companion-module/base` 2.x. On v2, check the hand-written config grid layout and the `isVisibleExpression` usages against that version's rules.
