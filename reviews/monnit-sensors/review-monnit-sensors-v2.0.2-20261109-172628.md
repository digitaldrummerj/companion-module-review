# Review: monnit-sensors v2.0.2 (follow-up to the v2.0.0 review)

| Field | Value |
| --- | --- |
| **Module** | [`companion-module-monnit-sensors`](https://github.com/bitfocus/companion-module-monnit-sensors) |
| **Scope** | `tag` (v1.2.0..v2.0.2) |
| **Version** | v2.0.2 (`e1ee34a`) |
| **Release** | Update — last published v1.2.0 |
| **API** | 2.2 (base 2.2.2, yarn.lock) — requires Companion 5.1+ |
| **Template** | `companion-module-template-js` @ `89da037` (2026-11-01) |
| **Prior review** | [v2.0.0 (2026-11-06)](review-monnit-sensors-v2.0.0-20261106-181511.md) — Changes Required; every finding from it is fixed in v2.0.2 |
| **Reviewed** | 2026-11-09 |

## Verdict: ✅ Approved

## ❓ Assumptions

Some findings depend on assumptions the reviewers couldn't check. They're listed in [❓ Assumptions to Confirm](#-assumptions-to-confirm) at the end of this review.

## 📋 Issues

### Non-blocking

- [ ] [L1: Aborting a running Refresh All Sensors action turns the connection status red](#l1-aborting-a-running-refresh-all-sensors-action-turns-the-connection-status-red)
- [ ] [L2: ESLint and typescript-eslint are installed but never used](#l2-eslint-and-typescript-eslint-are-installed-but-never-used)
- [ ] [L3: manifest.json has no $schema, so editors cannot validate it](#l3-manifestjson-has-no-schema-so-editors-cannot-validate-it)
- [ ] [NR1: package.json engines does not require Yarn 4 as the template does](#nr1-packagejson-engines-does-not-require-yarn-4-as-the-template-does)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟢 Low

### L1: Aborting a running Refresh All Sensors action turns the connection status red

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW (a side effect of the abort-signal change made for the v2.0.0 review's N2)
- **File:** [`src/main.js:226-229`](https://github.com/bitfocus/companion-module-monnit-sensors/blob/e1ee34a04c583226f253360b0102a98e8b42b786/src/main.js#L226-L229), [`src/main.js:282-284`](https://github.com/bitfocus/companion-module-monnit-sensors/blob/e1ee34a04c583226f253360b0102a98e8b42b786/src/main.js#L282-L284), [`src/actions.js:8-10`](https://github.com/bitfocus/companion-module-monnit-sensors/blob/e1ee34a04c583226f253360b0102a98e8b42b786/src/actions.js#L8-L10), [`src/actions.js:24-26`](https://github.com/bitfocus/companion-module-monnit-sensors/blob/e1ee34a04c583226f253360b0102a98e8b42b786/src/actions.js#L24-L26)

**What goes wrong:** A user has a button that runs "Refresh All Sensors" and aborts that button's running actions while the request to imonnit.com is still in flight. The connection status turns to "Connection Failure" and the log shows `Request failed: AbortError: This operation was aborted`, although the Monnit cloud is reachable and the API keys are valid. The status stays red until the next scheduled poll succeeds: up to 5 minutes with the default "Refresh Interval (minutes)" of 5, and until the next manual refresh when the interval is 0. Aborting "Refresh Single Sensor" the same way doesn't change the status but logs the same error. The abort has to land while the HTTP request is running, so most users will never see it.

**Why it happens:** This release passes the action's abort signal (`context.signal`, which Companion fires when an action's result is no longer needed) to `fetch`, as the v2.0.0 review suggested. When the signal fires mid-request, `fetch` (or `res.text()`) throws an `AbortError`. The generic `catch` in `fetchSensorData` treats that like a network failure: it logs an error and sets the connection status to Connection Failure. The base 2.2.2 typing says an aborted action should just stop, and that Companion ignores the resulting error.

**Evidence:**

```js
// src/main.js:226-229
			} catch (e) {
				this.log('error', `Request failed: ${e}`)
				this.updateStatus(InstanceStatus.ConnectionFailure)
			}
```

```js
// src/actions.js:8-10
			callback: async (_event, context) => {
				await self.fetchSensorData(context?.signal)
			},
```

**Fix:** treat an abort as a normal stop, not an error. In both `catch` blocks ([`src/main.js:226`](https://github.com/bitfocus/companion-module-monnit-sensors/blob/e1ee34a04c583226f253360b0102a98e8b42b786/src/main.js#L226) and [`src/main.js:282`](https://github.com/bitfocus/companion-module-monnit-sensors/blob/e1ee34a04c583226f253360b0102a98e8b42b786/src/main.js#L282)), return quietly before logging or changing the status when the request was aborted. Polling calls pass no signal, so real network failures still report Connection Failure.

```js
} catch (e) {
	if (signal?.aborted || e?.name === 'AbortError') {
		if (this.config.verbose) this.log('debug', 'Refresh aborted')
		return
	}
	this.log('error', `Request failed: ${e}`)
	this.updateStatus(InstanceStatus.ConnectionFailure)
}
```

### L2: ESLint and typescript-eslint are installed but never used

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`package.json:23-28`](https://github.com/bitfocus/companion-module-monnit-sensors/blob/e1ee34a04c583226f253360b0102a98e8b42b786/package.json#L23-L28)

**What goes wrong:** Nothing changes for Companion users. Every `yarn install` downloads ESLint and typescript-eslint, which adds install time and supply-chain surface for no benefit: the module is plain JavaScript and has no `eslint.config.*` and no `lint` script. The JS template has neither dependency.

**Why it happens:** This release added them because `@companion-module/tools` 3.2.0 lists them as peer dependencies, but its `peerDependenciesMeta` marks `eslint`, `typescript-eslint` and `prettier` as optional, so a JS module without linting doesn't need them.

**Fix:** remove `eslint` and `typescript-eslint` from `devDependencies` and run `yarn install` to update `yarn.lock`, leaving `@companion-module/tools` and `prettier` as in the template. If you do want linting, add the template-style `eslint.config.mjs` and a `lint` script instead.

### L3: manifest.json has no $schema, so editors cannot validate it

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`companion/manifest.json:1-3`](https://github.com/bitfocus/companion-module-monnit-sensors/blob/e1ee34a04c583226f253360b0102a98e8b42b786/companion/manifest.json#L1-L3)

**What goes wrong:** Nothing changes for Companion users. Without `$schema`, editors such as VS Code can't check or autocomplete the manifest against the base 2.2.2 manifest schema, so a typo in a field is only caught at build time.

**Why it happens:** The API 2.x template's manifest starts with a `$schema` line pointing at the schema shipped in `@companion-module/base`. This release reworked the manifest for API 2.x (added `type`, moved to `node26` and `../src/main.js`) but didn't add that line. The validator doesn't check this key.

**Fix:** add the template's `$schema` line as the first key in `companion/manifest.json`.

```json
"$schema": "../node_modules/@companion-module/base/assets/manifest.schema.json",
```

## 🔮 Next Release

### NR1: package.json engines does not require Yarn 4 as the template does

- **Source:** 🔎 compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`package.json:17-19`](https://github.com/bitfocus/companion-module-monnit-sensors/blob/e1ee34a04c583226f253360b0102a98e8b42b786/package.json#L17-L19)

**What goes wrong:** Nothing changes for Companion users. A contributor or CI job that installs the module with another major version of Yarn (for example Yarn 1 classic) gets no engines warning or error, although the module now needs Yarn 4: it has a Yarn 4 lockfile, a `.yarnrc.yml` and `"packageManager": "yarn@4.18.1"`. Because package.json still differs from the template, people troubleshooting the module later can't rely on it matching every other module built from the template.

**Why it happens:** The `engines` block in package.json lists the Node and package-manager versions a project supports. The API 2.x JS template's block has both `node` and `yarn`. This release rewrote the module's block for API 2.x (from `"node": "^22"` to `"node": "^26.5"`) and, while fixing the v2.0.0 review, moved the module from Yarn 1 to Yarn 4, but did not add the template's `yarn` entry. The template validator checks `engines.node` but not `engines.yarn`, so it didn't report this, and at v2.0.0 the module wasn't on Yarn 4 yet.

**Evidence:**

```json
// package.json:5-6, 17-19 (module at v2.0.2)
	"type": "module",
	"packageManager": "yarn@4.18.1",
...
	"engines": {
		"node": "^26.5"
	},
```

```json
// companion-module-template-js/package.json:15-18
	"engines": {
		"node": "^26",
		"yarn": "^4"
	},
```

```diff
// git diff v1.2.0..v2.0.2 -- package.json (engines hunk)
 	"engines": {
-		"node": "^22"
+		"node": "^26.5"
 	},
```

**Confirm by:** open [`package.json:17-19`](https://github.com/bitfocus/companion-module-monnit-sensors/blob/e1ee34a04c583226f253360b0102a98e8b42b786/package.json#L17-L19): `engines` has only `"node"`. The template's `package.json:15-18` also has `"yarn": "^4"`.

**Fix:** add the template's Yarn entry to `engines`.

```json
"engines": {
	"node": "^26.5",
	"yarn": "^4"
},
```

## 📝 Additional Notes

- Follow-up to the [v2.0.0 review](review-monnit-sensors-v2.0.0-20261106-181511.md): every finding from it was re-checked against v2.0.2 and is fixed. No blocking finding from it is still open and none is carried forward; the findings above are new.
- Prior C1, C2 and C9: package.json now has the template's `format` and `package` scripts, and `yarn install --immutable` and `yarn package` both succeed (the package builds as `monnit-sensors-2.0.2.tgz`).
- Prior C3: the six source files moved to `src/`, and package.json [`main`](https://github.com/bitfocus/companion-module-monnit-sensors/blob/e1ee34a04c583226f253360b0102a98e8b42b786/package.json#L4) and the manifest's [`runtime.entrypoint`](https://github.com/bitfocus/companion-module-monnit-sensors/blob/e1ee34a04c583226f253360b0102a98e8b42b786/companion/manifest.json#L21) point at `src/main.js`.
- Prior C4 and C5: [`package.json:6`](https://github.com/bitfocus/companion-module-monnit-sensors/blob/e1ee34a04c583226f253360b0102a98e8b42b786/package.json#L6) pins `yarn@4.18.1`, `yarn.lock` is a Yarn 4 lockfile, `.yarnrc` is gone and [`.yarnrc.yml`](https://github.com/bitfocus/companion-module-monnit-sensors/blob/e1ee34a04c583226f253360b0102a98e8b42b786/.yarnrc.yml) matches the template.
- Prior C6, C7 and C8: [`.gitignore`](https://github.com/bitfocus/companion-module-monnit-sensors/blob/e1ee34a04c583226f253360b0102a98e8b42b786/.gitignore) has the template's four extra entries, and [`.gitattributes`](https://github.com/bitfocus/companion-module-monnit-sensors/blob/e1ee34a04c583226f253360b0102a98e8b42b786/.gitattributes) and [`.prettierignore`](https://github.com/bitfocus/companion-module-monnit-sensors/blob/e1ee34a04c583226f253360b0102a98e8b42b786/.prettierignore) were added with the template's content.
- Prior M1: [`src/upgrades.js:5-30`](https://github.com/bitfocus/companion-module-monnit-sensors/blob/e1ee34a04c583226f253360b0102a98e8b42b786/src/upgrades.js#L5-L30) puts the v1.1.0 upgrade script back at position 0, writing wrapped `{ isExpression: false, value }` options, and the threshold feedbacks fall back to the default colours (e.g. [`src/feedbacks.js:65-72`](https://github.com/bitfocus/companion-module-monnit-sensors/blob/e1ee34a04c583226f253360b0102a98e8b42b786/src/feedbacks.js#L65-L72)).
- Prior M2: [`.github/workflows/release.yaml`](https://github.com/bitfocus/companion-module-monnit-sensors/blob/e1ee34a04c583226f253360b0102a98e8b42b786/.github/workflows/release.yaml) was added; the validator reports no difference from the template.
- Prior N1: the two "Below %" fields are now 0 to 100 and "Older Than Minutes" starts at 0 ([`src/feedbacks.js:302`](https://github.com/bitfocus/companion-module-monnit-sensors/blob/e1ee34a04c583226f253360b0102a98e8b42b786/src/feedbacks.js#L302), [`src/feedbacks.js:318`](https://github.com/bitfocus/companion-module-monnit-sensors/blob/e1ee34a04c583226f253360b0102a98e8b42b786/src/feedbacks.js#L318), [`src/feedbacks.js:334`](https://github.com/bitfocus/companion-module-monnit-sensors/blob/e1ee34a04c583226f253360b0102a98e8b42b786/src/feedbacks.js#L334)).
- Prior N2: both refresh actions now pass `context.signal` through to `fetch` and skip queued work that was already aborted. The abort is reported as a connection failure, though, see [L1](#l1-aborting-a-running-refresh-all-sensors-action-turns-the-connection-status-red).
- The template validator reports no findings for v2.0.2.
- [NR1](#nr1-packagejson-engines-does-not-require-yarn-4-as-the-template-does) was raised as a High finding. It doesn't block this release, but it needs to be fixed in the next release.

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Companion fires an action's abort signal (`context.signal`) while the callback is still awaiting when the user aborts that button's running actions (for example with the internal "Abort actions" action), and only in such uncommon, user-started cases, so the window for an abort during an in-flight imonnit.com request is narrow | The doc comment on `CompanionActionCallbackContext.signal` in `@companion-module/base` 2.2.2 (`dist/module-api/action.d.ts`): "aborts when the result of this execution is no longer needed (eg the user aborted the running actions)". Which Companion UI operations trigger the abort was not checked | [L1](#l1-aborting-a-running-refresh-all-sensors-action-turns-the-connection-status-red) |
