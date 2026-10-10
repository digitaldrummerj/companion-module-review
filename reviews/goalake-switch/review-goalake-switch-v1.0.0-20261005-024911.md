# Review: goalake-switch v1.0.0

| | |
| --- | --- |
| **Module** | `companion-module-goalake-switch` ([repo](https://github.com/bitfocus/companion-module-goalake-switch)) |
| **Version** | v1.0.0 (`f849052`) |
| **Previous tag** | none (first release) |
| **Scope:** | tag (first release, so the whole module was reviewed and every finding is 🆕 NEW) |
| **Language** | TypeScript |
| **Template** | [API 2.0 TypeScript template](https://github.com/bitfocus/companion-module-template-ts/tree/d62230e88bf8aec4ea6db407106bff2a96c0fdb9) (`companion-module-template-ts` @ `d62230e`, 2026-08-28, the last API 2.0 commit) |
| **API** | 2.0 (base 2.0.4, yarn.lock) — requires Companion 4.3+ |
| **Build** | `yarn install --immutable`, `yarn package` and `yarn lint` pass |
| **Review date** | 2026-10-08 |

**About the template:** the official TypeScript template repository has moved to the module API 2.1 (Companion 5). This module uses API 2.0, so every template finding below links to the API 2.0 version of the template, at commit [`d62230e`](https://github.com/bitfocus/companion-module-template-ts/tree/d62230e88bf8aec4ea6db407106bff2a96c0fdb9). Earlier versions of the template are no longer maintained, but that commit preserves the API 2.0 files.

## Verdict: ❌ Changes Required

## 📋 Issues

### Blocking

- [ ] [C1: The template's pre-commit lint and format checks are missing](#c1-the-templates-pre-commit-lint-and-format-checks-are-missing)
- [ ] [C2: The ESLint config does not follow the template's layout](#c2-the-eslint-config-does-not-follow-the-templates-layout)
- [ ] [H1: Set PoE power can switch off the wrong port while the switch state is unknown](#h1-set-poe-power-can-switch-off-the-wrong-port-while-the-switch-state-is-unknown)
- [ ] [H2: The LICENSE copyright line differs from the template](#h2-the-license-copyright-line-differs-from-the-template)
- [ ] [H3: companion-module-checks.yaml differs from the template](#h3-companion-module-checksyaml-differs-from-the-template)
- [ ] [H4: node.yaml differs from the template](#h4-nodeyaml-differs-from-the-template)

### Notes

- [📝 Additional Notes](#-additional-notes)

---

## 🔴 Critical

### C1: The template's pre-commit lint and format checks are missing

- **Source:** 🤖 validate-template (FILE-MISSING, PKG-SCRIPT, PKG-DEVDEP, PKG-LINTSTAGED)
- **Classification:** 🆕 NEW
- **Files:** `.husky/pre-commit` (missing), [`package.json`](https://github.com/bitfocus/companion-module-goalake-switch/blob/f8490522baaadbb9c159137f07dfe9f24c1f6dc7/package.json)
- **Template:** [API 2.0 TypeScript template](https://github.com/bitfocus/companion-module-template-ts/tree/d62230e88bf8aec4ea6db407106bff2a96c0fdb9): [`.husky/pre-commit`](https://github.com/bitfocus/companion-module-template-ts/blob/d62230e88bf8aec4ea6db407106bff2a96c0fdb9/.husky/pre-commit), [`package.json`](https://github.com/bitfocus/companion-module-template-ts/blob/d62230e88bf8aec4ea6db407106bff2a96c0fdb9/package.json)

**What goes wrong:** No user-visible effect. Contributors can commit code that hasn't been linted or formatted, because the template's pre-commit hook was removed.

**Why it happens:** The template runs lint and Prettier on staged files before every commit, using Husky (a git-hook installer) and lint-staged. This module dropped all of it:

- `.husky/pre-commit`: required file is missing (FILE-MISSING).
- `package.json`: missing required script `postinstall` (PKG-SCRIPT).
- `package.json`: missing devDependencies `husky` and `lint-staged` (PKG-DEVDEP).
- `package.json`: missing `lint-staged` section (PKG-LINTSTAGED).

**Fix:** restore the hook setup exactly as it appears in the [API 2.0 TypeScript template](https://github.com/bitfocus/companion-module-template-ts/tree/d62230e88bf8aec4ea6db407106bff2a96c0fdb9): the `.husky/pre-commit` file, the `postinstall` script, the `husky` and `lint-staged` devDependencies, and the `lint-staged` section.

### C2: The ESLint config does not follow the template's layout

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`eslint.config.mjs:3-12`](https://github.com/bitfocus/companion-module-goalake-switch/blob/f8490522baaadbb9c159137f07dfe9f24c1f6dc7/eslint.config.mjs#L3-L12)
- **Template:** [API 2.0 TypeScript template](https://github.com/bitfocus/companion-module-template-ts/tree/d62230e88bf8aec4ea6db407106bff2a96c0fdb9): [`eslint.config.mjs`](https://github.com/bitfocus/companion-module-template-ts/blob/d62230e88bf8aec4ea6db407106bff2a96c0fdb9/eslint.config.mjs)

**What goes wrong:** No user-visible effect. The lint configuration differs from the template in a way the accepted test-override form doesn't allow.

**Why it happens:** A test-only rule override is an accepted deviation, but only in the accepted form: assign the template's `generateEslintConfig(...)` result to a variable, then spread it and add the test override. This file puts a non-test `ignores` entry first and spreads the result inline. The validator found `export default [` on line 3, where the template has `export default generateEslintConfig({`.

**Evidence:**

```js
// eslint.config.mjs:3-12
export default [
	{ ignores: ['dist/', 'dist-test/'] },
	...(await generateEslintConfig({
		enableTypescript: true,
	})),
	{
		// describe()/it() from node:test return promises that are not meant to be awaited
		files: ['**/*.test.ts'],
		rules: { '@typescript-eslint/no-floating-promises': 'off' },
	},
]
```

**Fix:** use the accepted form, and drop the `dist-test/` ignore (or handle it through `.gitignore` / `.prettierignore`).

```js
const baseConfig = await generateEslintConfig({ enableTypescript: true })
export default [
	...baseConfig,
	{ files: ['**/*.test.ts'], rules: { '@typescript-eslint/no-floating-promises': 'off' } },
]
```

---

## 🟠 High

### H1: Set PoE power can switch off the wrong port while the switch state is unknown

- **Source:** 🔎 protocol reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:112-118`](https://github.com/bitfocus/companion-module-goalake-switch/blob/f8490522baaadbb9c159137f07dfe9f24c1f6dc7/src/main.ts#L112-L118), [`src/main.ts:124-125`](https://github.com/bitfocus/companion-module-goalake-switch/blob/f8490522baaadbb9c159137f07dfe9f24c1f6dc7/src/main.ts#L124-L125), [`src/main.ts:199-205`](https://github.com/bitfocus/companion-module-goalake-switch/blob/f8490522baaadbb9c159137f07dfe9f24c1f6dc7/src/main.ts#L199-L205)

**What goes wrong:** A user has a switch whose ports are numbered in reverse, such as the PS104GV3 this module was written for (serial starting `PS1`), or has set **Port order** to **Reversed**. They press a button with **Set PoE power**, **Port 1**, **Turn OFF**. If the module hasn't yet read the switch's state, it sends the command for physical **port 4** instead: the camera or access point on port 4 loses power, and port 1 stays on. **Set port speed / Extend mode** changes the wrong port the same way. That window is open:

- right after Companion starts or the connection settings are saved, until the first successful poll;
- after any failed poll or failed action, until the next successful poll. After repeated failures the next poll can be up to 5 minutes away, for example when someone had the switch's web admin page open and has just closed it;
- after a reboot.

Switches with normal port order are not affected. The **Toggle** choice is not affected either: it refuses to run when the state is unknown.

**Why it happens:** The module learns whether the ports are reversed from the switch's serial number on each successful poll, and keeps it with the rest of the switch state. That state is cleared at startup and on every failure. While it's cleared, the port-number lookup falls back to "not reversed". It doesn't use the connection's **Port order** setting, even when that is set to **Reversed** explicitly. The command path only checks that a connection object exists, not that the state is known, so it logs in and sends the command with the unreversed port index.

**Evidence:**

```ts
// src/main.ts:51-57
	get portCount(): number {
		return this.#state?.portCount ?? AssumedPortCount
	}

	get poePortCount(): number {
		return this.#state?.poePortCount ?? AssumedPoePortCount
	}

// src/main.ts:112-118
	async setPoe(port: number, on: boolean): Promise<void> {
		const index = portToIndex(port, this.poePortCount, this.portCount, this.#state?.reversedOrder ?? false)
		await this.#runCommand(async (client) => {
			await client.setPortConfig(buildOpcode(on ? PortConfigMode.PoeOn : PortConfigMode.PoeOff, index))
		})
		await this.pollNow()
	}

// src/main.ts:124-125
	async setPortMode(port: number, mode: PortConfigModeValue, fallback?: PortConfigModeValue): Promise<void> {
		const index = portToIndex(port, this.poePortCount, this.portCount, this.#state?.reversedOrder ?? false)

// src/main.ts:199-205  (no state guard: only checks that a client exists, then logs in and runs the command)
	async #runCommand<T>(fn: (client: SwitchClient) => Promise<T>): Promise<T> {
		const client = this.#client
		if (!client) throw new Error('Switch is not connected')

		try {
			await this.#ensureSession(client)
			return await fn(client)

// src/main.ts:154-156, 175  (state cleared on start; first poll not awaited)
	#start(): void {
		this.#destroyed = false
		this.#state = undefined
		...
		void this.#poll()

// src/main.ts:225-233  (a poll failure clears state but keeps #client, then schedules a backed-off retry, up to 300 s)
		try {
			await this.#ensureSession(client)
			const calldata = await client.getDetail()
			this.#applyDetail(calldata)
		} catch (e) {
			client.clearSession()
			this.#setDisconnected(this.#describeAndLogError(e))
		} finally {
			this.#scheduleNextPoll()

// src/main.ts:265-268
	#setDisconnected(message: string): void {
		const portCount = this.portCount
		const poePortCount = this.poePortCount
		this.#state = undefined

// src/device-state.ts:39-47  (config 'reversed' would be honoured even without a serial, but main.ts never calls this when state is unknown)
const ReversedSerialPrefixes = ['GS1', 'GPS1', 'GPS2', 'GFS2', 'GPS4', 'PS1']

export function isReversedOrder(order: PortOrder, serial: string | undefined): boolean {
	if (order === 'normal') return false
	if (order === 'reversed') return true

// src/device-state.ts:56-59
export function portToIndex(port: number, poePortCount: number, portCount: number, reversed: boolean): number {
	if (!reversed || port > poePortCount || port > portCount) return port - 1
	return poePortCount - port
}

// src/device-state.test.ts:45-46  (module's own expected wire value for "port 1 PoE OFF" on PS104GV3 = 50 = 0x032)
		assert.equal(buildOpcode(PortConfigMode.PoeOn, portToIndex(1, 4, 5, true)), 562)
		assert.equal(buildOpcode(PortConfigMode.PoeOff, portToIndex(1, 4, 5, true)), 50)
```

Running the module's built `dist/device-state.js` (v1.0.0, commit `f8490522`):

```text
unknown-state idx 0 opcode 2      <- what setPoe(1, false) sends while #state is undefined
reversed idx 3 opcode 32          <- what it sends once state is known (matches the test's 50 = 0x32)
config reversed no serial true    <- isReversedOrder('reversed', undefined) would give the right answer
```

**Confirm by:** open [`src/main.ts:113`](https://github.com/bitfocus/companion-module-goalake-switch/blob/f8490522baaadbb9c159137f07dfe9f24c1f6dc7/src/main.ts#L113) and [`src/main.ts:125`](https://github.com/bitfocus/companion-module-goalake-switch/blob/f8490522baaadbb9c159137f07dfe9f24c1f6dc7/src/main.ts#L125). Note `this.#state?.reversedOrder ?? false`, and that `#runCommand` ([`src/main.ts:199-205`](https://github.com/bitfocus/companion-module-goalake-switch/blob/f8490522baaadbb9c159137f07dfe9f24c1f6dc7/src/main.ts#L199-L205)) does not check `#state`. Then compare [`src/device-state.test.ts:46`](https://github.com/bitfocus/companion-module-goalake-switch/blob/f8490522baaadbb9c159137f07dfe9f24c1f6dc7/src/device-state.test.ts#L46), which expects opcode 50 (index 3) for "port 1 PoE OFF" on a reversed unit, while the unknown-state path sends opcode 2 (index 0).

**Fix:** make sure the port order is known before any port command is sent.

- In `#runCommand`, after `#ensureSession`, check whether `#state` is undefined. If it is, call `client.getDetail()` and then `#applyDetail()` so that `reversedOrder` and the port counts are known, and only then compute the index.
- If that isn't possible, refuse the command with a warning, as the Toggle path in [`src/actions.ts:63-68`](https://github.com/bitfocus/companion-module-goalake-switch/blob/f8490522baaadbb9c159137f07dfe9f24c1f6dc7/src/actions.ts#L63-L68) already does.
- At minimum, fall back to the configured order instead of `false`:

```ts
const reversed = this.#state?.reversedOrder ?? isReversedOrder(this.#config.portOrder, undefined)
```

### H2: The LICENSE copyright line differs from the template

- **Source:** 🤖 validate-template (LICENSE-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`LICENSE:3`](https://github.com/bitfocus/companion-module-goalake-switch/blob/f8490522baaadbb9c159137f07dfe9f24c1f6dc7/LICENSE#L3)
- **Template:** [API 2.0 TypeScript template](https://github.com/bitfocus/companion-module-template-ts/tree/d62230e88bf8aec4ea6db407106bff2a96c0fdb9): [`LICENSE`](https://github.com/bitfocus/companion-module-template-ts/blob/d62230e88bf8aec4ea6db407106bff2a96c0fdb9/LICENSE)

**What goes wrong:** No user-visible effect. The module's LICENSE doesn't match the one every Bitfocus module ships with.

**Why it happens:** Line 3 is `Copyright (c) 2026 Takashi Ito`; the template has `Copyright (c) 2022 Bitfocus AS - Open Source`.

**Fix:** use the [template's `LICENSE` file](https://github.com/bitfocus/companion-module-template-ts/blob/d62230e88bf8aec4ea6db407106bff2a96c0fdb9/LICENSE) unchanged.

### H3: companion-module-checks.yaml differs from the template

- **Source:** 🤖 validate-template (CONFIG-DIFF; raised to High by the review maintainer)
- **Classification:** 🆕 NEW
- **File:** [`.github/workflows/companion-module-checks.yaml`](https://github.com/bitfocus/companion-module-goalake-switch/blob/f8490522baaadbb9c159137f07dfe9f24c1f6dc7/.github/workflows/companion-module-checks.yaml)
- **Template:** [API 2.0 TypeScript template](https://github.com/bitfocus/companion-module-template-ts/tree/d62230e88bf8aec4ea6db407106bff2a96c0fdb9): [`.github/workflows/companion-module-checks.yaml`](https://github.com/bitfocus/companion-module-template-ts/blob/d62230e88bf8aec4ea6db407106bff2a96c0fdb9/.github/workflows/companion-module-checks.yaml)

**What goes wrong:** No user-visible effect. The module's checks workflow doesn't match the template's, so its CI behaves differently from every other module built from the template. That makes CI problems harder to troubleshoot against the template, and future template updates harder to apply.

**Why it happens:** compared with the template, the file:

- adds a `pull_request:` trigger (line 5), so the module checks also run on pull requests, not only on pushes;
- adds a top-level `permissions: contents: read` block (lines 7-8), and `contents: read` to the job's own permissions (line 14) next to the template's `packages: read`;
- removes the template's `if: ${{ !contains(github.repository, 'companion-module-template-') }}` guard.

It also uncomments `with: upload-artifact: true` (lines 17-18). That is the template's documented customisation and is fine to keep.

**Evidence:**

```diff
 on:
   push:
+  pull_request:
+
+permissions:
+  contents: read

 jobs:
   check:
     name: Check module
-
-    if: ${{ !contains(github.repository, 'companion-module-template-') }}
-
     permissions:
+      contents: read
       packages: read
-
     uses: bitfocus/actions/.github/workflows/module-checks.yaml@main
-    # with:
-    #   upload-artifact: true # uncomment this to upload the built package as an artifact ...
+    with:
+      upload-artifact: true
```

**Confirm by:** compare [`companion-module-checks.yaml`](https://github.com/bitfocus/companion-module-goalake-switch/blob/f8490522baaadbb9c159137f07dfe9f24c1f6dc7/.github/workflows/companion-module-checks.yaml) with the [template's](https://github.com/bitfocus/companion-module-template-ts/blob/d62230e88bf8aec4ea6db407106bff2a96c0fdb9/.github/workflows/companion-module-checks.yaml).

**Fix:** replace the file with the template's. Keeping `upload-artifact: true` uncommented is fine.

```yaml
name: Companion Module Checks

on:
  push:

jobs:
  check:
    name: Check module

    if: ${{ !contains(github.repository, 'companion-module-template-') }}

    permissions:
      packages: read

    uses: bitfocus/actions/.github/workflows/module-checks.yaml@main
    with:
      upload-artifact: true
```

### H4: node.yaml differs from the template

- **Source:** 🤖 validate-template (CONFIG-DIFF; raised to High by the review maintainer)
- **Classification:** 🆕 NEW
- **File:** [`.github/workflows/node.yaml`](https://github.com/bitfocus/companion-module-goalake-switch/blob/f8490522baaadbb9c159137f07dfe9f24c1f6dc7/.github/workflows/node.yaml)
- **Template:** [API 2.0 TypeScript template](https://github.com/bitfocus/companion-module-template-ts/tree/d62230e88bf8aec4ea6db407106bff2a96c0fdb9): [`.github/workflows/node.yaml`](https://github.com/bitfocus/companion-module-template-ts/blob/d62230e88bf8aec4ea6db407106bff2a96c0fdb9/.github/workflows/node.yaml)

**What goes wrong:** No user-visible effect. The module's Node CI workflow has been rewritten, so its CI behaves differently from every other module built from the template. That makes CI problems harder to troubleshoot against the template, and future template updates harder to apply.

**Why it happens:** compared with the template, the file:

- adds a top-level `permissions: contents: read` block (lines 11-12) (the triggers are the same as the template's);
- renames the job from `lint` ("Lint") to `check` ("Build, lint, and test", line 16);
- removes the template's "Prepare Environment (For template repository)" step;
- installs with `yarn install --immutable` (line 28) instead of the template's `yarn install` with `CI: true`, and drops `env: CI: true` from the build and lint steps;
- runs `yarn test` as a step in the same job (lines 33-34), where the template has tests as a separate, commented-out job;
- drops the template's comment that the Node.js version should match the manifest's runtime (the version itself, `22.x`, still matches).

**Evidence:**

```diff
   pull_request:

+permissions:
+  contents: read
+
 jobs:
-  lint:
-    name: Lint
+  check:
+    name: Build, lint, and test
     ...
-      - name: Prepare Environment (For template repository)
-        if: ${{ contains(github.repository, 'companion-module-template-') }}
-        run: |
-          yarn install
-        env:
-          CI: false
-      - name: Prepare module
-        run: |
-          yarn install
-        env:
-          CI: true
+      - name: Install dependencies
+        run: yarn install --immutable
       - name: Build and check types
-        run: |
-          yarn build
-        env:
-          CI: true
+        run: yarn build
       - name: Run lint
-        run: |
-          yarn lint
-        env:
-          CI: true
+        run: yarn lint
+      - name: Run tests
+        run: yarn test
```

**Confirm by:** compare [`node.yaml`](https://github.com/bitfocus/companion-module-goalake-switch/blob/f8490522baaadbb9c159137f07dfe9f24c1f6dc7/.github/workflows/node.yaml) with the [template's](https://github.com/bitfocus/companion-module-template-ts/blob/d62230e88bf8aec4ea6db407106bff2a96c0fdb9/.github/workflows/node.yaml).

**Fix:** replace the file with the [template's `node.yaml`](https://github.com/bitfocus/companion-module-template-ts/blob/d62230e88bf8aec4ea6db407106bff2a96c0fdb9/.github/workflows/node.yaml). To run the module's tests in CI, uncomment the template's `test` job rather than adding a step to the lint job.

---

## 📝 Additional Notes

- [`tsconfig.build.json`](https://github.com/bitfocus/companion-module-goalake-switch/blob/f8490522baaadbb9c159137f07dfe9f24c1f6dc7/tsconfig.build.json#L4-L10) differs from the [template's](https://github.com/bitfocus/companion-module-template-ts/blob/d62230e88bf8aec4ea6db407106bff2a96c0fdb9/tsconfig.build.json): it adds `"src/**/*.test.ts"` to `exclude` and spreads the list over several lines. The module builds, so no change is required.
