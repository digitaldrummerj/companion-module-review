# Companion Module Review: fora-mfr v2.0.0

| Field | Value |
| --- | --- |
| **Module** | `companion-module-fora-mfr` (For.A MFR routing switchers) |
| **Version** | v2.0.0 (previous tag v1.0.2) |
| **Release** | Update — last published v1.0.2 |
| **API** | 2.1 (base 2.1.3, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Scope** | `tag` (`v1.0.2..v2.0.0`) |
| **Commit** | [`3385ec7`](https://github.com/bitfocus/companion-module-fora-mfr/commit/3385ec7ca378f92e23d6f76fc4987af47b523491) |
| **Reviewed** | 2026-11-06 |

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Companion's connection editor lets a user save the "MFR Port" number field empty, or with a fractional value such as 23.5, so that value reaches the module's connect code | The field sets `min`/`max` but no `required` or `step` ([`src/config.ts:42-50`](https://github.com/bitfocus/companion-module-fora-mfr/blob/3385ec7ca378f92e23d6f76fc4987af47b523491/src/config.ts#L42-L50)). The Node socket errors were reproduced locally; how Companion validates number fields before saving was not checked | [L1](#l1-clearing-the-mfr-port-field-or-typing-235-crashes-the-module-instead-of-showing-a-configuration-error) |
| A2 | Companion does not catch an exception thrown from a module's `setImmediate` callback, so the module process dies and Companion restarts it | No `uncaughtException` handler exists in `node_modules/@companion-module/base/dist`; Companion's restart behaviour was not checked in its code | [L1](#l1-clearing-the-mfr-port-field-or-typing-235-crashes-the-module-instead-of-showing-a-configuration-error) |
| A3 | In expression mode Companion compares a dropdown's computed value to the choice ids exactly (case- and type-sensitive): `'11'` matches the hex id `11` (port 18), while `'0a'` or the number 10 match nothing and the action is skipped | The v2 API reference (a dropdown value must match a choice unless custom values are allowed) and the base 2.1.3 typing comment on `allowInvalidValues`; Companion's comparison code was not run | [M1](#m1-typing-a-port-number-into-a-port-option-in-expression-mode-can-route-to-the-wrong-port) |

## 📋 Issues

### Blocking

- [ ] [C1: Line endings are not pinned to LF, so a Windows checkout can produce CRLF files](#c1-line-endings-are-not-pinned-to-lf-so-a-windows-checkout-can-produce-crlf-files)
- [ ] [C2: Nothing formats or lints code before a commit, because the husky and lint-staged setup is missing](#c2-nothing-formats-or-lints-code-before-a-commit-because-the-husky-and-lint-staged-setup-is-missing)
- [ ] [C3: Prettier skips two GitHub files that the template formats](#c3-prettier-skips-two-github-files-that-the-template-formats)
- [ ] [C4: The module runs on Node 22, but API 2.1 modules run on Node 26](#c4-the-module-runs-on-node-22-but-api-21-modules-run-on-node-26)

### Non-blocking

- [ ] [M1: Typing a port number into a port option in expression mode can route to the wrong port](#m1-typing-a-port-number-into-a-port-option-in-expression-mode-can-route-to-the-wrong-port)
- [ ] [M2: The template's Node CI workflow is missing](#m2-the-templates-node-ci-workflow-is-missing)
- [ ] [M3: Published GitHub releases get no installable package, because the release workflow is missing](#m3-published-github-releases-get-no-installable-package-because-the-release-workflow-is-missing)
- [ ] [L1: Clearing the MFR Port field or typing 23.5 crashes the module instead of showing a configuration error](#l1-clearing-the-mfr-port-field-or-typing-235-crashes-the-module-instead-of-showing-a-configuration-error)
- [ ] [L2: The names page reports every name as sent even when some were dropped, leaving the router half renamed](#l2-the-names-page-reports-every-name-as-sent-even-when-some-were-dropped-leaving-the-router-half-renamed)
- [ ] [L3: A refresh interval that is not a multiple of 5 seconds runs at the next multiple of 5](#l3-a-refresh-interval-that-is-not-a-multiple-of-5-seconds-runs-at-the-next-multiple-of-5)
- [ ] [N1: The Lock/Unlock a destination action shows its Destination option even when it is set to use the selected destination](#n1-the-lockunlock-a-destination-action-shows-its-destination-option-even-when-it-is-set-to-use-the-selected-destination)
- [ ] [N2: Every route action queues another full re-read of the router, even when one is already waiting](#n2-every-route-action-queues-another-full-re-read-of-the-router-even-when-one-is-already-waiting)
- [ ] [N3: Each source name the router reports recomputes the routed-name variables for every destination](#n3-each-source-name-the-router-reports-recomputes-the-routed-name-variables-for-every-destination)

## 🔴 Critical

### C1: Line endings are not pinned to LF, so a Windows checkout can produce CRLF files

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.gitattributes` (missing)

**What goes wrong:** A contributor who clones the repository on Windows, where git converts line endings by default, gets every text file with CRLF endings. Prettier and ESLint then flag the files, or the CRLF endings get committed back into the repository.

**Why it happens:** The template ships a one-line `.gitattributes` that tells git to keep text files with LF endings on every platform. v2.0.0 does not include it.

**Expected (template):** `.gitattributes` containing `* text=auto eol=lf`. **Found:** no `.gitattributes` file.

**Fix:** add `.gitattributes` at the repository root with the template's rule.

```text
* text=auto eol=lf
```

### C2: Nothing formats or lints code before a commit, because the husky and lint-staged setup is missing

- **Source:** 🤖 validate-template (FILE-MISSING, PKG-SCRIPT, PKG-DEVDEP, PKG-LINTSTAGED)
- **Classification:** 🆕 NEW
- **File:** `.husky/pre-commit` (missing), [`package.json:6-17`](https://github.com/bitfocus/companion-module-fora-mfr/blob/3385ec7ca378f92e23d6f76fc4987af47b523491/package.json#L6-L17), [`package.json:30-40`](https://github.com/bitfocus/companion-module-fora-mfr/blob/3385ec7ca378f92e23d6f76fc4987af47b523491/package.json#L30-L40)

**What goes wrong:** In the template, every `git commit` first runs Prettier and ESLint on the staged files, so badly formatted or failing code never reaches the repository. In v2.0.0 nothing runs on commit: a contributor only finds out when the CI lint job fails, and formatting problems are never caught at all.

**Why it happens:** The template's pre-commit setup has five parts, and all five are missing. One fix covers them all:

- [ ] `.husky/pre-commit` containing `lint-staged`
- [ ] `package.json` script `"postinstall": "husky"`, which installs the hook on `yarn install`
- [ ] `package.json` devDependency `"husky": "^9.1.7"`
- [ ] `package.json` devDependency `"lint-staged": "^17.6.0"`
- [ ] `package.json` `lint-staged` section, which says what runs on which staged files

**Fix:** add `.husky/pre-commit` with the single line `lint-staged`, merge these keys into `package.json`, then run `yarn install` so `yarn.lock` picks up the two new packages.

```json
{
	"scripts": { "postinstall": "husky" },
	"devDependencies": { "husky": "^9.1.7", "lint-staged": "^17.6.0" },
	"lint-staged": {
		"*.{css,json,md,scss}": ["prettier --write"],
		"*.{ts,tsx,js,jsx}": ["yarn lint:raw --fix"]
	}
}
```

### C3: Prettier skips two GitHub files that the template formats

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.prettierignore:3-6`](https://github.com/bitfocus/companion-module-fora-mfr/blob/3385ec7ca378f92e23d6f76fc4987af47b523491/.prettierignore#L3-L6)

**What goes wrong:** `yarn format` (and, once C2 is fixed, the pre-commit hook) never touches `.github/ISSUE_TEMPLATE/config.yml` or `.github/workflows/companion-module-checks.yaml`, so this module formats a different set of files than the template it is built from.

**Why it happens:** `.prettierignore` adds two entries under the comment `# keep upstream's formatting of these GitHub files`. Both files are identical to the template's copies, and the template's `.prettierignore` (`package.json` and `/LICENSE.md` only) does not exclude them. Extra ignore entries are only accepted for generated files.

**Expected (template):** `package.json` and `/LICENSE.md`. **Found:** those two, plus `/.github/ISSUE_TEMPLATE/config.yml` and `/.github/workflows/companion-module-checks.yaml`.

**Fix:** remove lines 3-6 so `.prettierignore` matches the template.

```text
package.json
/LICENSE.md
```

### C4: The module runs on Node 22, but API 2.1 modules run on Node 26

- **Source:** 🤖 validate-template (NODE-VERSION)
- **Classification:** 🆕 NEW
- **File:** [`companion/manifest.json:19`](https://github.com/bitfocus/companion-module-fora-mfr/blob/3385ec7ca378f92e23d6f76fc4987af47b523491/companion/manifest.json#L19), [`package.json:24`](https://github.com/bitfocus/companion-module-fora-mfr/blob/3385ec7ca378f92e23d6f76fc4987af47b523491/package.json#L24), [`package.json:32`](https://github.com/bitfocus/companion-module-fora-mfr/blob/3385ec7ca378f92e23d6f76fc4987af47b523491/package.json#L32), [`tsconfig.build.json:2`](https://github.com/bitfocus/companion-module-fora-mfr/blob/3385ec7ca378f92e23d6f76fc4987af47b523491/tsconfig.build.json#L2), [`.github/workflows/ci.yaml:22-23`](https://github.com/bitfocus/companion-module-fora-mfr/blob/3385ec7ca378f92e23d6f76fc4987af47b523491/.github/workflows/ci.yaml#L22-L23)

**What goes wrong:** Companion 5 starts this module on its Node 22 runtime, while the API 2.1 template, and the modules built from it, run on Node 26. The module is then built, type-checked and tested against a different Node than the one its template targets, which makes problems reported by users harder to troubleshoot.

**Why it happens:** The API 2.1 template sets Node 26 in five places, and v2.0.0 names Node 22 in all of them.

**Expected (template) vs found:**

- [ ] [`companion/manifest.json:19`](https://github.com/bitfocus/companion-module-fora-mfr/blob/3385ec7ca378f92e23d6f76fc4987af47b523491/companion/manifest.json#L19): `runtime.type` is `node22`, should be `node26`
- [ ] [`package.json:24`](https://github.com/bitfocus/companion-module-fora-mfr/blob/3385ec7ca378f92e23d6f76fc4987af47b523491/package.json#L24): `engines.node` is `^22.20`, should be `^26`
- [ ] [`package.json:32`](https://github.com/bitfocus/companion-module-fora-mfr/blob/3385ec7ca378f92e23d6f76fc4987af47b523491/package.json#L32): devDependency `@types/node` is `^22.19.0`, should be `^26.6.4`
- [ ] [`tsconfig.build.json:2`](https://github.com/bitfocus/companion-module-fora-mfr/blob/3385ec7ca378f92e23d6f76fc4987af47b523491/tsconfig.build.json#L2): `extends` is `@companion-module/tools/tsconfig/node22/recommended-esm.json`, should be `@companion-module/tools/tsconfig/node26/recommended.json`
- [ ] [`.github/workflows/ci.yaml:23`](https://github.com/bitfocus/companion-module-fora-mfr/blob/3385ec7ca378f92e23d6f76fc4987af47b523491/.github/workflows/ci.yaml#L23): `node-version` is `22.x`, should be `26.x` (the comment on line 22 also refers to `^22.20`)

**Fix:** move every place to Node 26, then run `yarn install` to refresh `yarn.lock`.

```json
"runtime": { "type": "node26" }
"engines": { "node": "^26" }
"@types/node": "^26.6.4"
"extends": "@companion-module/tools/tsconfig/node26/recommended.json"
```

```yaml
          # satisfies "engines.node": "^26" in package.json
          node-version: 26.x
```

## 🟡 Medium

### M1: Typing a port number into a port option in expression mode can route to the wrong port

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/choices.ts:80-84`](https://github.com/bitfocus/companion-module-fora-mfr/blob/3385ec7ca378f92e23d6f76fc4987af47b523491/src/choices.ts#L80-L84)

**What goes wrong:** On a 64x64 MFR, an operator switches the "Destination :" option of "Cut a route: switch this source to this destination now" to expression mode and types the port number shown in the dropdown, e.g. `11` for "11: Main Mon". The module reads `11` as a zero-based hex id, so the cut goes to destination 18, with no warning. A value such as `40` or `0a` matches no choice and Companion skips the action. The same applies to every port option: "Set destination", "Set source", "Stage a route", "Rename a destination/source", "Lock/Unlock a destination", and the "Destination :" / "Source :" option of every feedback. Buttons that pick ports from the dropdown are not affected.

**Why it happens:** The dropdown labels count from 1 in decimal, but the ids behind them are zero-based, two-digit upper-case hex (`toHex(i)`), which keeps buttons saved with v1 working. In API 2.x any dropdown can be put into expression mode, and the typed value is checked against those ids. No port option has an `expressionDescription`, and [`companion/HELP.md`](https://github.com/bitfocus/companion-module-fora-mfr/blob/3385ec7ca378f92e23d6f76fc4987af47b523491/companion/HELP.md) only describes the variables as hex, so nothing tells the user which format to type.

**Evidence:**

```ts
// src/choices.ts:80-84
function portChoices(count: number, name: (index: number) => string): DropdownChoice<string>[] {
	// before the router has reported its size keep one entry, so the dropdowns are never empty
	const length = Math.max(count, 1)
	return Array.from({ length }, (_, i) => ({ id: toHex(i), label: `${i + 1}: ${name(i)}` }))
}
```

```ts
// src/actions.ts:73-79
		cutRoute: {
			name: 'Cut a route: switch this source to this destination now',
			options: [
				{ type: 'dropdown', id: 'dst', label: 'Destination :', default: '00', choices: dst },
				{ type: 'dropdown', id: 'src', label: 'Source :', default: '00', choices: src },
			],
			callback: (action) => self.routeExplicit('cut', action.options.dst, action.options.src),
```

**Confirm by:** open [`src/choices.ts:83`](https://github.com/bitfocus/companion-module-fora-mfr/blob/3385ec7ca378f92e23d6f76fc4987af47b523491/src/choices.ts#L83): labels are 1-based decimal, ids are 0-based hex. No port dropdown in [`src/actions.ts`](https://github.com/bitfocus/companion-module-fora-mfr/blob/3385ec7ca378f92e23d6f76fc4987af47b523491/src/actions.ts) or [`src/feedbacks.ts`](https://github.com/bitfocus/companion-module-fora-mfr/blob/3385ec7ca378f92e23d6f76fc4987af47b523491/src/feedbacks.ts) sets `expressionDescription` or `allowInvalidValues`.

**Fix:** keep the hex ids, since saved v1 buttons depend on them, and tell the user the format. Add an `expressionDescription` to every port dropdown ([`src/actions.ts`](https://github.com/bitfocus/companion-module-fora-mfr/blob/3385ec7ca378f92e23d6f76fc4987af47b523491/src/actions.ts) lines 41, 46, 68-69, 76-77, 152, 160, 168; [`src/feedbacks.ts`](https://github.com/bitfocus/companion-module-fora-mfr/blob/3385ec7ca378f92e23d6f76fc4987af47b523491/src/feedbacks.ts) lines 38, 50, 61, 72, 83, 94, 105) and one line to the ACTIONS section of `companion/HELP.md`. Optionally add `allowInvalidValues: true`: the module's own port parsing already validates the value and logs "Invalid port", so lower-case ids such as `0a` would then work too.

```ts
{
	type: 'dropdown',
	id: 'dst',
	label: 'Destination :',
	default: '00',
	choices: dst,
	expressionDescription:
		'Zero-based hex port id: 00 = port 1, 0A = port 11, 3F = port 64. $(fora-mfr:selected_dst_id) and $(fora-mfr:xpt01) already use this format.',
},
```

### M2: The template's Node CI workflow is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.github/workflows/node.yaml` (missing)

**What goes wrong:** The repository doesn't run the template's CI workflow, so its pushes and pull requests are checked differently from every other template-based module.

**Why it happens:** The module ships its own `ci.yaml` and `commit-messages.yaml` workflows instead of the template's `node.yaml`.

**Fix:** add the template's `.github/workflows/node.yaml` (on Node 26, see [C4](#c4-the-module-runs-on-node-22-but-api-21-modules-run-on-node-26)). The module's extra workflows can stay next to it.

### M3: Published GitHub releases get no installable package, because the release workflow is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.github/workflows/release.yaml` (missing)

**What goes wrong:** When the maintainer publishes a GitHub release, nothing builds the module package, so the release page has no `.tgz` that a user could import into Companion.

**Why it happens:** The template's `release.yaml` packages the module with the shared Bitfocus module-checks workflow when a release is published and attaches the package to the release. v2.0.0 does not include it.

**Fix:** copy `.github/workflows/release.yaml` from the template unchanged.

## 🟢 Low

### L1: Clearing the MFR Port field or typing 23.5 crashes the module instead of showing a configuration error

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:369-376`](https://github.com/bitfocus/companion-module-fora-mfr/blob/3385ec7ca378f92e23d6f76fc4987af47b523491/src/main.ts#L369-L376), [`src/config.ts:42-50`](https://github.com/bitfocus/companion-module-fora-mfr/blob/3385ec7ca378f92e23d6f76fc4987af47b523491/src/config.ts#L42-L50)

**What goes wrong:** A user clears the "MFR Port" field, or types 23.5, and saves. The module process crashes, Companion restarts it, and it crashes again on every restart until the port is fixed. The connection shows as crashed instead of "Bad configuration". An empty "MFR IP" is handled properly and shows "No host configured". The default port 23, and any whole number from 1 to 65535, work.

**Why it happens:** When the module connects it checks that an IP address is set, but hands the port to Companion's TCP helper unchecked. The helper opens the socket a moment later in a delayed callback with no error handling, and Node throws for a missing port (`ERR_MISSING_ARGS`) or for `''` and `23.5` (`ERR_SOCKET_BAD_PORT`). Nothing catches an error thrown there, so the process exits.

**Evidence:**

```ts
// src/main.ts:369-376
		const { host, port } = this.config
		if (!host) {
			this.updateStatus(InstanceStatus.BadConfig, 'No host configured')
			return
		}

		if (!retrying) this.updateStatus(InstanceStatus.Connecting)
		const socket = new TCPHelper(host, port)
```

**Fix:** check the port next to the host, and optionally add `step: 1` and `required: true` to the "MFR Port" field.

```ts
const { host } = this.config
const port = Number(this.config.port)
if (!host || !Number.isInteger(port) || port < 1 || port > 65535) {
	this.updateStatus(InstanceStatus.BadConfig, 'Set a host and a port from 1 to 65535')
	return
}
```

### L2: The names page reports every name as sent even when some were dropped, leaving the router half renamed

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/names-page.ts:67-69`](https://github.com/bitfocus/companion-module-fora-mfr/blob/3385ec7ca378f92e23d6f76fc4987af47b523491/src/names-page.ts#L67-L69), [`src/main.ts:478-479`](https://github.com/bitfocus/companion-module-fora-mfr/blob/3385ec7ca378f92e23d6f76fc4987af47b523491/src/main.ts#L478-L479), [`src/queue.ts:44`](https://github.com/bitfocus/companion-module-fora-mfr/blob/3385ec7ca378f92e23d6f76fc4987af47b523491/src/queue.ts#L44)

**What goes wrong:** On the port names page (`/instance/<connection label>/`) a user pastes more than about 500 names at once, for example every destination and source of a large router, and presses Apply. The page says "Sent N name(s)" for all of them, but the module only queues the first ~512 renames; the rest are dropped with a "Command queue full, dropped command" warning in the log. Later the dropped rows show "No reply: press Apply to retry". The router ends up half renamed, which the page's "one bad row sends nothing" design is meant to prevent. Renaming fewer names at a time is not affected.

**Why it happens:** The page checks every row first, then renames each one and reports the number of valid rows as sent. Each rename queues two commands (the rename and a read-back), and the command queue refuses new commands once it holds 1024. A refused command is only logged, so the page never learns that it was dropped.

**Evidence:**

```ts
// src/names-page.ts:67-69
	if (valid.length) host.log(`Names page: sending ${valid.length} name${valid.length === 1 ? '' : 's'}`)
	for (const { kind, index, name } of valid) host.rename(kind, toHex(index), name)
	return json(200, { sent: valid.length })
```

**Fix:** keep the all-or-nothing promise by refusing the whole request up front (for example with a 503 "Too many names at once, apply them in smaller batches") when `2 * valid.length` exceeds the free queue space. Alternatively, have `rename()` return whether both commands were queued and report the real count, or raise the queue limit for urgent commands.

### L3: A refresh interval that is not a multiple of 5 seconds runs at the next multiple of 5

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:535-552`](https://github.com/bitfocus/companion-module-fora-mfr/blob/3385ec7ca378f92e23d6f76fc4987af47b523491/src/main.ts#L535-L552)

**What goes wrong:** A user sets "Refresh router data every (seconds, 0 = never)" to 7. The module re-reads the crosspoints, staged routes and port names every 10 seconds, not every 7. Values of 6 or 9 also give 10 seconds, and 11 or 12 give 15 seconds, so a route changed on a router panel can show on the buttons up to 5 seconds later than the setting says. Values of 1 to 5, and multiples of 5, work as labelled.

**Why it happens:** The refresh runs on the same timer as the 5-second heartbeat, and that timer's tick is capped at 5 seconds. The time since the last refresh only grows in 5-second steps, so it first reaches 7 seconds at the 10-second tick.

**Evidence:**

```ts
// src/main.ts:537-541
		const refreshMs = Number(this.config.pollInterval ?? 5) * 1000
		const tickMs = refreshMs > 0 ? Math.min(refreshMs, HEARTBEAT_MS) : HEARTBEAT_MS
		let sinceRefreshMs = 0
		this.#pollTimer = setInterval(() => {
			sinceRefreshMs += tickMs
```

**Fix:** run the refresh on its own `setInterval(refresh, refreshMs)` next to the heartbeat interval, and clear both in `#stopPolling()`. Or, if the 5-second granularity is intended, say so in the field label and give the number field `step: 5`.

## 💡 Nice to Have

### N1: The Lock/Unlock a destination action shows its Destination option even when it is set to use the selected destination

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:165-179`](https://github.com/bitfocus/companion-module-fora-mfr/blob/3385ec7ca378f92e23d6f76fc4987af47b523491/src/actions.ts#L165-L179)

**What goes wrong:** The "Lock / unlock a destination" preset ticks "Use the selected destination (ignores the destination above)", but the "Destination :" dropdown still shows "1: DST-1" above it. A user editing the button may change the dropdown and expect it to matter. The action works correctly, so this is cosmetic.

**Why it happens:** In API 2.x an option can be hidden with `isVisibleExpression`, but that expression may only refer to options that set `disableAutoExpression: true`. The `useSelected` checkbox doesn't set it, so the dropdown can't be hidden based on it, and the checkbox can also be switched to expression mode, which makes no sense for this switch.

**Fix:** set `disableAutoExpression: true` on the `useSelected` checkbox, add `isVisibleExpression: '!$(options:useSelected)'` to the `dst` dropdown of `lockDst`, and shorten the checkbox label to "Use the selected destination". Buttons saved with the checkbox in value mode keep working. The same `disableAutoExpression` suits the `apply` checkbox of the video format action.

### N2: Every route action queues another full re-read of the router, even when one is already waiting

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:512-517`](https://github.com/bitfocus/companion-module-fora-mfr/blob/3385ec7ca378f92e23d6f76fc4987af47b523491/src/main.ts#L512-L517)

**What goes wrong:** There is no visible error. A button with 16 "Cut a route" actions, or quick presses in "Cut straight away" mode, queues 16 full crosspoint reads and 16 staged-route reads. Each one re-reads the whole table after the operator commands have gone through, and the regular refresh and heartbeat are skipped until they finish.

**Why it happens:** Every cut, stage, take and clear calls `#refreshRoutes()`, which always adds both reads to the queue without checking whether the same read is already waiting there.

**Fix:** skip the enqueue when an identical command is already waiting in the bulk queue, for example with a `CommandQueue.has(command)` check or an `enqueueOnce()`. One read sent after the last action is enough to show the router's state.

### N3: Each source name the router reports recomputes the routed-name variables for every destination

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:754-764`](https://github.com/bitfocus/companion-module-fora-mfr/blob/3385ec7ca378f92e23d6f76fc4987af47b523491/src/main.ts#L754-L764)

**What goes wrong:** There is no visible error. On the first read after connecting, every source name arrives as a change, and each one sends the routed-source name variables (`xpt##_name`, `xpt##_pending_name`) for all destinations to Companion. On a 64x64 router that is roughly 8,000 variable values during start-up, and it grows with the square of the router size. After start-up only real renames trigger it.

**Why it happens:** A source rename rebuilds the routed-name values for every destination, although only the destinations routed to (or staged with) that source change.

**Fix:** for a source rename, set only the `xpt##_name` / `xpt##_pending_name` variables of the destinations whose route or staged source is that source. Or leave the full update to the debounced definitions timer that already batches name changes.
