# Review: autodirector-mirusuite v1.1.0

| | |
| --- | --- |
| **Module** | `companion-module-autodirector-mirusuite` ([repo](https://github.com/bitfocus/companion-module-autodirector-mirusuite)) |
| **Version** | v1.1.0 (`3c70bc0`, 2026-09-29) |
| **Previous tag** | v1.0.3 (`f43d1c4`, 2026-03-16) |
| **Scope:** | tag (`v1.0.3..v1.1.0`) |
| **Language** | TypeScript |
| **Template** | `companion-module-template-ts` @ `4373e07` (2026-10-08, main, API 2.1) |
| **API** | 2.1 (base 2.1.3, yarn.lock) — requires Companion 5.0+ |
| **Build** | `yarn install`, `yarn package` and lint pass |
| **Review date** | 2026-10-08 |
| **Prior review** | v1.0.3 (2026-04-02). Fixed in v1.1.0: H1 (`destroy()` left the EventSource open), H2 (`configUpdated()` did not close the old stream), H3 (status reset to `Ok` after a failed request) and N1 (unused import). Still open: L1 (`rimraf` missing, now part of C5) |

This release moves the module from the Companion 4 module API (v1, base `~1.11.3`) to the Companion 5 module API (2.1, base `2.1.3`), and rewrites the connection handling. The template findings (C3–C6, H1, H4) cover the whole module; every other finding is new in this release or a regression caused by it.

## Verdict: ❌ Changes Required

## 📋 Issues

### Blocking

- [ ] [C1: The installed module reports Connection Failure and has no presets](#c1-the-installed-module-reports-connection-failure-and-has-no-presets)
- [ ] [C2: Saved MiruSuite passwords are lost when upgrading from v1.0.3](#c2-saved-mirusuite-passwords-are-lost-when-upgrading-from-v103)
- [ ] [C3: Required template files are missing](#c3-required-template-files-are-missing)
- [ ] [C4: .gitignore is missing template entries and .vscode/settings.json is committed](#c4-gitignore-is-missing-template-entries-and-vscodesettingsjson-is-committed)
- [ ] [C5: package.json does not match the template](#c5-packagejson-does-not-match-the-template)
- [ ] [C6: The module runs on Node 22 instead of the 2.1 template's Node 26](#c6-the-module-runs-on-node-22-instead-of-the-21-templates-node-26)
- [ ] [H1: LICENSE differs from the template](#h1-license-differs-from-the-template)
- [ ] [H2: Learning and auto-preset actions, feedbacks and variables were removed without notice](#h2-learning-and-auto-preset-actions-feedbacks-and-variables-were-removed-without-notice)
- [ ] [H3: Definitions are typed as any, so the API 2.1 types check nothing](#h3-definitions-are-typed-as-any-so-the-api-21-types-check-nothing)
- [ ] [H4: The CI workflows differ from the template](#h4-the-ci-workflows-differ-from-the-template)

### Non-blocking

- [ ] [M1: Person and Orchestra value fields can show or hide wrongly when Mode or Setting is an expression](#m1-person-and-orchestra-value-fields-can-show-or-hide-wrongly-when-mode-or-setting-is-an-expression)
- [ ] [L1: A hung MiruSuite server can stall actions for minutes](#l1-a-hung-mirusuite-server-can-stall-actions-for-minutes)
- [ ] [L2: Every successful request rebuilds all variables](#l2-every-successful-request-rebuilds-all-variables)
- [ ] [L3: Variables are pushed twice for each event](#l3-variables-are-pushed-twice-for-each-event)
- [ ] [L4: The PTZ arrow images are about 1.5 MB in total](#l4-the-ptz-arrow-images-are-about-15-mb-in-total)

---

## 🔴 Critical

### C1: The installed module reports Connection Failure and has no presets

- **Source:** 🔎 QA reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/variables.ts:94-102`](https://github.com/bitfocus/companion-module-autodirector-mirusuite/blob/3c70bc00c93b6b36c3bd849b43311df80e35307e/src/variables.ts#L94-L102), [`package.json:9`](https://github.com/bitfocus/companion-module-autodirector-mirusuite/blob/3c70bc00c93b6b36c3bd849b43311df80e35307e/package.json#L9), [`package.json:18`](https://github.com/bitfocus/companion-module-autodirector-mirusuite/blob/3c70bc00c93b6b36c3bd849b43311df80e35307e/package.json#L18) (there is no `build-config.cjs`)

**What goes wrong:** A user installs v1.1.0 from the module package and points it at a working MiruSuite server. The connection goes red with **Connection Failure**, and the log shows "Error loading MiruSuite configuration: ENOENT…". No presets appear, and the variable values are never filled in. Reconnecting doesn't help: every load fails the same way. Developers running the module from the repo's `dist/` folder don't see the problem, which is why it slipped through.

**Why it happens:** This release added eight PTZ arrow images that the module reads from disk when it registers its variables. The repo's `yarn build` copies them into `dist/`, but the package that users install is built by `companion-module-build`, which bundles the code into a single `main.js` and only copies extra files listed in a `build-config.cjs`. The repo has no such file, so the images are not in the package, and reading them throws a "file not found" (ENOENT) error. The error happens after actions and feedbacks are registered but before presets are, and it ends the whole configuration load, so the module marks the connection as failed. A flag that should stop the images being read twice is only set after a successful read, so every later load fails again.

**Evidence:**

```ts
// src/variables.ts:94-102
	self.setVariableDefinitions(definitions)
	if (!self.ptzArrowImagesInitialized) {
		const arrowValues: Record<string, string> = {}
		for (const direction of ['n', 'ne', 'e', 'se', 's', 'sw', 'w', 'nw']) {
			const base64 = readFileSync(new URL(`./static/arrows/${direction}.png`, import.meta.url)).toString('base64')
			arrowValues[`ptz_arrow_${direction}`] = `data:image/png;base64,${base64}`
		}
		self.setVariableValues({ ...buildVariableValues(self), ...arrowValues })
		self.ptzArrowImagesInitialized = true

// package.json (scripts)
		"package": "yarn build && companion-module-build",
		"copyassets": "copyfiles -u 1 src/api/openapi.json src/static/icon.png src/static/arrows/*.png dist/"

// src/main.ts:110-114
	updateDefinitions(): void {
		UpdateActions(this)
		UpdateFeedbacks(this)
		UpdateVariableDefinitions(this)
		UpdatePresets(this)

// src/main.ts:54-59
		try {
			await this.updateConfiguration()
		} catch (error) {
			this.log('error', `Error loading MiruSuite configuration: ${String(error)}`)
			this.connectionState = 'Disconnected'
			this.updateStatus(InstanceStatus.ConnectionFailure)
```

```js
// node_modules/@companion-module/tools/dist/scripts/lib/build-util.js:69,132 (only build-config.cjs extraFiles are copied into pkg)
    if (fs.existsSync(path.join(moduleDir, 'build-config.cjs')))
    if (Array.isArray(buildConfig.extraFiles)) {
```

```text
// tar tzf autodirector-mirusuite-1.1.0.tgz
autodirector-mirusuite/LICENSE
autodirector-mirusuite/main.js
autodirector-mirusuite/package.json
autodirector-mirusuite/companion/HELP.md
autodirector-mirusuite/companion/manifest.json

// pkg/autodirector-mirusuite/main.js (esbuild bundle; the URL is left as-is)
let r=dy(new URL(`./static/arrows/${a}.png`,import.meta.url)).toString("base64")

// node -e readFileSync(new URL('./static/arrows/n.png', <pkg main.js>))
ENOENT .../pkg/autodirector-mirusuite/static/arrows/n.png
```

```diff
// git diff v1.0.3..v1.1.0
-		"copyassets": "copyfiles -u 1 src/api/openapi.json src/static/icon.png dist/"
+		"copyassets": "copyfiles -u 1 src/api/openapi.json src/static/icon.png src/static/arrows/*.png dist/"
+import { readFileSync } from 'node:fs'
+			const base64 = readFileSync(new URL(`./static/arrows/${direction}.png`, import.meta.url)).toString('base64')
```

**Confirm by:** run `tar tzf autodirector-mirusuite-1.1.0.tgz` and check there is no `static/arrows/*.png`. There is also no `build-config.cjs` in the repo root, while [`src/variables.ts:98`](https://github.com/bitfocus/companion-module-autodirector-mirusuite/blob/3c70bc00c93b6b36c3bd849b43311df80e35307e/src/variables.ts#L98) reads those PNGs at runtime.

**Fix:** ship the images inside the package (or inside the code), and make sure a missing image can never stop the module from loading.

- Either add a `build-config.cjs` with `extraFiles` so `static/arrows/*.png` lands next to the bundled `main.js`, or embed small versions of the images as base64 constants in a `.ts` file (see L4).
- Wrap the image read in `try/catch` so a missing graphic only logs a warning.
- Test the packaged `.tgz` (the output of `yarn package`) in Companion 5, not `dist/`.

### C2: Saved MiruSuite passwords are lost when upgrading from v1.0.3

- **Source:** 🔎 compliance reviewer — verified
- **Classification:** 🔙 REGRESSION
- **File:** [`src/upgrades.ts:24-39`](https://github.com/bitfocus/companion-module-autodirector-mirusuite/blob/3c70bc00c93b6b36c3bd849b43311df80e35307e/src/upgrades.ts#L24-L39)

**What goes wrong:** A user on v1.0.3 has a connection with a **Username** and **Password** set because their MiruSuite server requires login. After upgrading to v1.1.0, the module stops sending the login: it behaves as if no password was set. If the server requires authentication, every request is rejected and the connection fails, with nothing telling the user that their password is the problem. Re-entering the password fixes it. New connections, and connections that never used a password, are not affected.

**Why it happens:** v1.1.0 moved the password from the normal connection config into Companion's *secrets* storage (a separate, protected place for credentials), and added code to move existing passwords across. That code was added to the module's existing *upgrade script*, the one-time migration Companion runs on each connection when the module is updated. v1.0.3 already shipped that script, and Companion runs each upgrade script only once per connection, so connections that ran v1.0.3 never run the new code. Their password stays in the old config field, which v1.1.0 no longer reads. The module only sends the login header when both a username and a password are set, so it silently stops logging in.

**Evidence:**

```ts
// src/upgrades.ts at v1.0.3 (git show v1.0.3:src/upgrades.ts):9-29 — the only script in the shipped array
export const UpgradeScripts: CompanionStaticUpgradeScript<ModuleConfig>[] = [
	(
		_: CompanionUpgradeContext<ModuleConfig>,
		props: CompanionStaticUpgradeProps<ModuleConfig>,
	): CompanionStaticUpgradeResult<ModuleConfig> => {
		const updatedFeedbacks = props.feedbacks
			.filter((feedback) => feedback.feedbackId === 'enabledDirector')
		...
		return {
			updatedConfig: null,
			updatedActions: [],
			updatedFeedbacks,
		}
	},
]

// src/upgrades.ts:24-35 (v1.1.0), added to that same index-0 script (commit 3c70bc0)
		const legacyConfig = props.config as (ModuleConfig & { password?: string }) | null
		const hasLegacyPassword = legacyConfig !== null && Object.prototype.hasOwnProperty.call(legacyConfig, 'password')
		const updatedConfig: ModuleConfig | null = hasLegacyPassword
			? {
					host: legacyConfig?.host ?? '127.0.0.1',
					port: legacyConfig?.port ?? 8080,
					username: legacyConfig?.username ?? '',
				}
			: null
		const updatedSecrets: ModuleSecrets | null = hasLegacyPassword
			? { ...(props.secrets ?? {}), password: legacyConfig?.password ?? '' }
			: null

// src/config.ts at v1.0.3:3-8, 39-46 — password was a plain config field
	port: number
	username: string
	password: string
}
		{
			type: 'textinput',
			id: 'password',

// src/config.ts:9-11, 43-44 (v1.1.0) — password is now a secret
export type ModuleSecrets = {
	password?: string
}
			type: 'secret-text',
			id: 'password',

// src/main.ts:52 and 63-69 — the module reads only secrets.password; nothing in src/ falls back to config.password
		await this.backend.setup(this.config.host, this.config.port, this.config.username, this.secrets.password ?? '')
		this.eventHandler = new EventHandler(
			...
			this.config.username,
			this.secrets.password ?? '',
		)

// src/api/backend.ts:90-94
			if (username && password) {
				headers = {
					...
					Authorization: 'Basic ' + Buffer.from(username + ':' + password).toString('base64'),

// src/scripts/eventhandler.ts:24-25
		if (this.username && this.password) {
			headers.Authorization = `Basic ${Buffer.from(`${this.username}:${this.password}`).toString('base64')}`
```

**Confirm by:** compare `git show v1.0.3:src/upgrades.ts` with [`src/upgrades.ts:24-39`](https://github.com/bitfocus/companion-module-autodirector-mirusuite/blob/3c70bc00c93b6b36c3bd849b43311df80e35307e/src/upgrades.ts#L24-L39). The password migration sits inside the single script (index 0) that already shipped in v1.0.3, and no new script was added to the array.

**Fix:** put the existing upgrade script back as it was released, and add the password move as a new, second script.

- Restore script 0 to its v1.0.3 logic. Keeping the wrapped `{ isExpression: false, value: 'DIRECTOR' }` default is fine.
- Append a new script at index 1 that moves `config.password` into `updatedSecrets.password` and returns `updatedConfig` without `password`.
- Add a test that runs a v1.0.3-shaped config (with `password`) through `UpgradeScripts`.

### C3: Required template files are missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **File:** `.gitattributes`, `.husky/pre-commit`, `.yarnrc.yml`

**What goes wrong:** No user-visible effect. The template tracks all three files and the module has none of them (they were already missing before v1.1.0). The template's `.yarnrc.yml` carries `nodeLinker` and the supply-chain hardening keys `enableScripts: false`, `npmMinimalAgeGate` and `npmPreapprovedPackages`.

**Fix:** copy all three files from the template. `.yarnrc.yml` needs the Yarn 4 move in C5.

### C4: .gitignore is missing template entries and .vscode/settings.json is committed

- **Source:** 🤖 validate-template (CONFIG-DIFF, GITIGNORED-COMMITTED)
- **File:** [`.gitignore`](https://github.com/bitfocus/companion-module-autodirector-mirusuite/blob/3c70bc00c93b6b36c3bd849b43311df80e35307e/.gitignore), [`.vscode/settings.json`](https://github.com/bitfocus/companion-module-autodirector-mirusuite/blob/3c70bc00c93b6b36c3bd849b43311df80e35307e/.vscode/settings.json)

**What goes wrong:** No user-visible effect.

- `.gitignore` is missing the template entries `/*.tgz`, `/.yarn` and `/.vscode` (the existing `*.tgz` line already covers the first).
- `.vscode/settings.json` is committed even though the template's `.gitignore` excludes `/.vscode`. It was also modified in this release, and it holds a personal Windows `PATH` setting.

**Fix:** add the template's `.gitignore` lines, then remove the file from the repo with `git rm --cached .vscode/settings.json`.

### C5: package.json does not match the template

- **Source:** 🤖 validate-template (PKG-REPO, PKG-FIELD, PKG-YARN, PKG-DEVDEP)
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-autodirector-mirusuite/blob/3c70bc00c93b6b36c3bd849b43311df80e35307e/package.json)

**What goes wrong:** No user-visible effect. Five fields differ from the template (all present before v1.1.0):

| Check | Found | Expected |
| --- | --- | --- |
| `repository.url` | `git+https://github.com/bitfocus/companion-module-autodirector-mirusuite` | `git+https://github.com/bitfocus/companion-module-autodirector-mirusuite.git` |
| `engines` | missing | present, as in the template |
| `packageManager` | `yarn@1.22.22+sha1...` | `yarn@4...` |
| devDependency `@types/node` | missing | present |
| devDependency `rimraf` | missing | present (also the open L1 from the v1.0.3 review) |

**Fix:** align all five with the template. Move to Yarn 4 and regenerate `yarn.lock` with it.

### C6: The module runs on Node 22 instead of the 2.1 template's Node 26

- **Source:** 🤖 validate-template (MAN-RUNTIME)
- **File:** [`companion/manifest.json:24`](https://github.com/bitfocus/companion-module-autodirector-mirusuite/blob/3c70bc00c93b6b36c3bd849b43311df80e35307e/companion/manifest.json#L24), [`tsconfig.build.json:2`](https://github.com/bitfocus/companion-module-autodirector-mirusuite/blob/3c70bc00c93b6b36c3bd849b43311df80e35307e/tsconfig.build.json#L2)

**What goes wrong:** No user-visible effect today. This release moves the module to API 2.1, and the 2.1 template runs on Node 26, but the module still declares `"runtime": { "type": "node22" }` and builds with the Node 22 tsconfig preset. A module that doesn't match its template is harder to troubleshoot later, because a problem may come from the different runtime rather than from the module's own code.

**Fix:** match the 2.1 template:

- `companion/manifest.json`: `"type": "node26"` under `runtime`.
- `tsconfig.build.json`: extend `@companion-module/tools/tsconfig/node26/recommended.json`.
- `package.json`: `engines.node` `^26` and `@types/node` `^26`, as in the template (both are part of C5).

---

## 🟠 High

### H1: LICENSE differs from the template

- **Source:** 🤖 validate-template (LICENSE-DIFF)
- **File:** [`LICENSE:3`](https://github.com/bitfocus/companion-module-autodirector-mirusuite/blob/3c70bc00c93b6b36c3bd849b43311df80e35307e/LICENSE#L3)

**What goes wrong:** No user-visible effect. Line 3 reads `Copyright (c) 2025 Bitfocus AS - Open Source`; the template has `Copyright (c) 2022 Bitfocus AS - Open Source`. The file was not changed in this release.

**Fix:** use the template's `LICENSE` exactly.

### H2: Learning and auto-preset actions, feedbacks and variables were removed without notice

- **Source:** 🔎 compliance reviewer (raised to High by the review maintainer)
- **Classification:** 🆕 NEW
- **File:** `src/actions.ts`, `src/feedbacks.ts`, `src/variables.ts`, `src/scripts/autolearning.ts`, `src/scripts/metadata.ts` (removed or rewritten in this release)

**What goes wrong:** Buttons that used the actions `learnAutoButtons`, `playAutoPreset`, `overwriteAutoPreset` or `clearAllAutoButtons`, or the feedbacks `learnMode` or `autoPreset`, stop working after the upgrade, and references to the variables `learningMode`, `offlineMode` or `autoConfiguredButtons` show nothing. Users get no warning: `companion/HELP.md` doesn't mention the removal, and the version is only a minor bump (1.1.0).

**Why it happens:** This release deleted these features without an upgrade script or a note.

**Fix:** document the removal in HELP.md and the release notes, and consider a major version bump. Optionally keep stub actions that log a warning, or add an upgrade script that removes the dead entries.

### H3: Definitions are typed as any, so the API 2.1 types check nothing

- **Source:** 🔎 compliance reviewer (raised to High by the review maintainer)
- **Classification:** 🆕 NEW
- **File:** [`src/actions/camera.ts:14`](https://github.com/bitfocus/companion-module-autodirector-mirusuite/blob/3c70bc00c93b6b36c3bd849b43311df80e35307e/src/actions/camera.ts#L14) (and the same line in every `src/actions/*.ts`), [`src/scripts/helpers.ts:131`](https://github.com/bitfocus/companion-module-autodirector-mirusuite/blob/3c70bc00c93b6b36c3bd849b43311df80e35307e/src/scripts/helpers.ts#L131), [`src/scripts/helpers.ts:142-147`](https://github.com/bitfocus/companion-module-autodirector-mirusuite/blob/3c70bc00c93b6b36c3bd849b43311df80e35307e/src/scripts/helpers.ts#L142-L147), [`src/scripts/helpers.ts:160`](https://github.com/bitfocus/companion-module-autodirector-mirusuite/blob/3c70bc00c93b6b36c3bd849b43311df80e35307e/src/scripts/helpers.ts#L160), [`src/presets/helpers.ts:3-14`](https://github.com/bitfocus/companion-module-autodirector-mirusuite/blob/3c70bc00c93b6b36c3bd849b43311df80e35307e/src/presets/helpers.ts#L3-L14), [`src/presets/modern.ts:207`](https://github.com/bitfocus/companion-module-autodirector-mirusuite/blob/3c70bc00c93b6b36c3bd849b43311df80e35307e/src/presets/modern.ts#L207), [`src/instance-types.ts:4-7`](https://github.com/bitfocus/companion-module-autodirector-mirusuite/blob/3c70bc00c93b6b36c3bd849b43311df80e35307e/src/instance-types.ts#L4-L7)

**What goes wrong:** No direct user-visible effect. Mistakes in actions, feedbacks and presets that the library's types would catch at build time instead show up as runtime warnings and broken buttons. For example, the **Piece ID**, **Setlist ID** and **Entry ID** number options ([`src/feedbacks.ts:451-455`](https://github.com/bitfocus/companion-module-autodirector-mirusuite/blob/3c70bc00c93b6b36c3bd849b43311df80e35307e/src/feedbacks.ts#L451-L455), [`src/feedbacks.ts:471-472`](https://github.com/bitfocus/companion-module-autodirector-mirusuite/blob/3c70bc00c93b6b36c3bd849b43311df80e35307e/src/feedbacks.ts#L471-L472)) have no `min`/`max` and still compile.

**Why it happens:** The action maps, the option helpers, the preset builders and `createModernPreset()` are all typed as `any` ("anything goes"), and the instance types declare only `config` and `secrets`. The layered presets, which API 2.1 validates strictly at runtime, are produced by converting the old preset format with text parsing.

**Fix:** declare `actions` and `feedbacks` schemas in `MiruSuiteInstanceTypes`, build actions with `CompanionActionDefinitions<...>`, give the helpers real return types (for example `CompanionInputFieldDropdown`), and write presets directly as `CompanionPresetDefinitions<MiruSuiteInstanceTypes>` (`simple`/`layered`), dropping `convertLegacyPresets`.

### H4: The CI workflows differ from the template

- **Source:** 🤖 validate-template (CONFIG-DIFF, FILE-MISSING; raised to High by the review maintainer)
- **File:** [`.github/workflows/node.yaml:18-25`](https://github.com/bitfocus/companion-module-autodirector-mirusuite/blob/3c70bc00c93b6b36c3bd849b43311df80e35307e/.github/workflows/node.yaml#L18-L25), `.github/workflows/release.yaml` (missing)

**What goes wrong:** No user-visible effect. The module's CI doesn't match the 2.1 template's, so problems are harder to troubleshoot against it:

- `node.yaml` builds and tests on **Node 22.x**, while the module targets Node 26 (C6) and the template's CI uses Node 26.x. It also uses older action versions (`actions/checkout@v4` without `persist-credentials: false`, `actions/setup-node@v4`; the template has `@v7` and `@v6`).
- The template's `release.yaml` is missing. It packages the module and attaches it to each published GitHub release.

Enabling `upload-artifact: true` in `companion-module-checks.yaml` is fine: it's the template's documented customisation.

**Fix:** copy `node.yaml` and `release.yaml` from the 2.1 template.

---

## 🟡 Medium

### M1: Person and Orchestra value fields can show or hide wrongly when Mode or Setting is an expression

- **Source:** 🔎 compliance reviewer — verified (downgraded from High)
- **Classification:** 🆕 NEW
- **File:** [`src/scripts/helpers.ts:168`](https://github.com/bitfocus/companion-module-autodirector-mirusuite/blob/3c70bc00c93b6b36c3bd849b43311df80e35307e/src/scripts/helpers.ts#L168), [`src/actions/camera.ts:152-162`](https://github.com/bitfocus/companion-module-autodirector-mirusuite/blob/3c70bc00c93b6b36c3bd849b43311df80e35307e/src/actions/camera.ts#L152-L162), [`src/feedbacks.ts:130-140`](https://github.com/bitfocus/companion-module-autodirector-mirusuite/blob/3c70bc00c93b6b36c3bd849b43311df80e35307e/src/feedbacks.ts#L130-L140), [`src/actions/orchestra.ts:139-175`](https://github.com/bitfocus/companion-module-autodirector-mirusuite/blob/3c70bc00c93b6b36c3bd849b43311df80e35307e/src/actions/orchestra.ts#L139-L175)

**What goes wrong:** In **Set Tracking Mode** and the **Tracking Mode** feedback, the **Person** field is meant to appear only when **Mode** is SINGLE. In **Set Orchestra Setting**, the value fields depend on the chosen **Setting**. If a user switches **Mode** or **Setting** to expression mode, the dependent fields may be shown or hidden wrongly in the editor (A8). The actions themselves still work, and nothing changes for users who leave these dropdowns as normal dropdowns.

**Why it happens:** In API 2.x, a field's "show only when…" rule (`isVisibleExpression`) may only read fields marked `disableAutoExpression: true`, because a field that can hold an expression has no fixed value to compare. None of the dropdowns here have that flag. All four rules came in with this release's move to API 2.x; v1.0.3 used visibility functions instead.

**Fix:** add `disableAutoExpression: true` to both **Mode** dropdowns and to the **Setting** dropdown. v1.1.0 is the first API 2.x release, so no saved expressions exist yet and the change is safe.

---

## 🟢 Low

### L1: A hung MiruSuite server can stall actions for minutes

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/api/backend.ts:55`](https://github.com/bitfocus/companion-module-autodirector-mirusuite/blob/3c70bc00c93b6b36c3bd849b43311df80e35307e/src/api/backend.ts#L55)

**What goes wrong:** If MiruSuite accepts a connection but stops answering, button actions and the configuration load wait for minutes before failing, and the connection stays on "Connecting".

**Why it happens:** Requests use plain `fetch` with no timeout, so they rely on Node's defaults (about 300 seconds for the response headers).

**Fix:** pass `signal: AbortSignal.timeout(5000)`, combined with any caller signal through `AbortSignal.any`.

### L2: Every successful request rebuilds all variables

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/api/backend.ts:63-65`](https://github.com/bitfocus/companion-module-autodirector-mirusuite/blob/3c70bc00c93b6b36c3bd849b43311df80e35307e/src/api/backend.ts#L63-L65)

**What goes wrong:** No visible effect beyond extra work: one configuration load rebuilds every variable about 14 times, plus once per action. Each success also marks the connection as connected while the event stream may still be down, which skips the reload that should happen when the stream reopens ([`src/scripts/eventhandler.ts:53`](https://github.com/bitfocus/companion-module-autodirector-mirusuite/blob/3c70bc00c93b6b36c3bd849b43311df80e35307e/src/scripts/eventhandler.ts#L53)).

**Why it happens:** Every successful response sets the status to OK and pushes all variable values.

**Fix:** update the status and variables only when the connection state actually changes to connected.

### L3: Variables are pushed twice for each event

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/scripts/eventhandler.ts:140-142`](https://github.com/bitfocus/companion-module-autodirector-mirusuite/blob/3c70bc00c93b6b36c3bd849b43311df80e35307e/src/scripts/eventhandler.ts#L140-L142)

**What goes wrong:** No visible effect, just extra work: after every event from MiruSuite, including unknown ones, the module sets the status to OK and pushes all variables again, even though most event branches already did.

**Fix:** remove the duplicate call, or only run it for branches that didn't already update.

### L4: The PTZ arrow images are about 1.5 MB in total

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** `src/static/arrows/*.png` (read in [`src/variables.ts:95-102`](https://github.com/bitfocus/companion-module-autodirector-mirusuite/blob/3c70bc00c93b6b36c3bd849b43311df80e35307e/src/variables.ts#L95-L102))

**What goes wrong:** No visible effect beyond load: the eight PNGs are 572x574 px and 174–191 KB each. As base64 they add about 1.9 MB to the variable values, which are sent to Companion and decoded for every PTZ button.

**Fix:** shrink them to about 72–144 px (a few KB each). At that size they can be embedded as constants, or placed directly in the layered preset's image element, which also fixes C1.

---

## 🔮 Next Release

- On API 2.1 you can target `runtime.type: "node26"` (with the `node26/recommended` tsconfig, tools 3.1 or later).
- **Director Status** ([`src/feedbacks.ts:83`](https://github.com/bitfocus/companion-module-autodirector-mirusuite/blob/3c70bc00c93b6b36c3bd849b43311df80e35307e/src/feedbacks.ts#L83)) only sets colours, so it could become a value feedback or boolean feedbacks with layered presets; advanced feedbacks are discouraged in 2.1.
- `@types/jest` and the tsconfig `types: ["jest"]` entry are unused now that the tests run on `node:test`.

---

## 📝 Additional Notes

- `tsconfig.build.json` differs from the template: it overrides `"module"` and `"moduleResolution"` to `NodeNext`, drops `"verbatimModuleSyntax": true` and orders `rootDir`/`outDir` differently. The module builds, so no change is required.
