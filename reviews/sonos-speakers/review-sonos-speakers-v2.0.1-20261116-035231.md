# Review: sonos-speakers v2.0.1

| Field | Value |
| --- | --- |
| **Module** | [companion-module-sonos-speakers](https://github.com/bitfocus/companion-module-sonos-speakers) |
| **Version** | v2.0.1 |
| **Release** | Update — last published v1.1.0 |
| **API** | 2.1 (base 2.1.3, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11, main) |
| **Scope** | `tag` (v1.1.0..v2.0.1; the v2.0.0 tag was never published) |
| **Review commit** | [`36b899b`](https://github.com/bitfocus/companion-module-sonos-speakers/commit/36b899b3ae8eb827a616905374b2556311f6c619) |
| **Reviewed** | 2026-11-16 |

## Verdict: ❌ Changes Required

## ❓ Assumptions

Some findings depend on assumptions the reviewers couldn't check. They're listed in [❓ Assumptions to Confirm](#-assumptions-to-confirm) at the end of this review.

## 📋 Issues

### Blocking

- [ ] [C1: `.gitattributes` is missing](#c1-gitattributes-is-missing)
- [ ] [C2: `.gitignore` is missing six template entries](#c2-gitignore-is-missing-six-template-entries)
- [ ] [C3: `.husky/pre-commit` is missing](#c3-huskypre-commit-is-missing)
- [ ] [C4: `.prettierignore` is missing the template's `/LICENSE.md` entry](#c4-prettierignore-is-missing-the-templates-licensemd-entry)
- [ ] [C5: `.yarnrc.yml` is missing](#c5-yarnrcyml-is-missing)
- [ ] [C6: `tsconfig.build.json` is missing](#c6-tsconfigbuildjson-is-missing)
- [ ] [C7: package.json has no `packageManager` field, and yarn.lock is a Yarn 1 lockfile](#c7-packagejson-has-no-packagemanager-field-and-yarnlock-is-a-yarn-1-lockfile)
- [ ] [C8: package.json is missing the `postinstall` script](#c8-packagejson-is-missing-the-postinstall-script)
- [ ] [C9: package.json is missing the `lint:raw` script](#c9-packagejson-is-missing-the-lintraw-script)
- [ ] [C10: package.json is missing the `husky` devDependency](#c10-packagejson-is-missing-the-husky-devdependency)
- [ ] [C11: package.json is missing the `lint-staged` devDependency](#c11-packagejson-is-missing-the-lint-staged-devdependency)
- [ ] [H1: Every Save in the connection settings leaves the old speaker subscriptions and their renewal timers running](#h1-every-save-in-the-connection-settings-leaves-the-old-speaker-subscriptions-and-their-renewal-timers-running)
- [ ] [H2: package.json `lint`, `format`, `package` and lint-staged commands differ from the template](#h2-packagejson-lint-format-package-and-lint-staged-commands-differ-from-the-template)
- [ ] [H3: package.json `engines` has no `yarn` entry](#h3-packagejson-engines-has-no-yarn-entry)
- [ ] [H4: TypeScript is pinned with `^6` where the template uses `~6.0.3`](#h4-typescript-is-pinned-with-6-where-the-template-uses-603)
- [ ] [H5: Manifest has no `$schema` line, so editors can't validate it](#h5-manifest-has-no-schema-line-so-editors-cant-validate-it)
- [ ] [H6: Actions, feedbacks and variables aren't typed from a module schema](#h6-actions-feedbacks-and-variables-arent-typed-from-a-module-schema)

### Non-blocking

- [ ] [M1: Sleep timer: the Minutes field stays visible when Mode is Cancel](#m1-sleep-timer-the-minutes-field-stays-visible-when-mode-is-cancel)
- [ ] [M2: `.github/workflows/node.yaml` is missing](#m2-githubworkflowsnodeyaml-is-missing)
- [ ] [M3: `.github/workflows/release.yaml` is missing](#m3-githubworkflowsreleaseyaml-is-missing)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🔴 Critical

### C1: `.gitattributes` is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.gitattributes` (missing)

**What goes wrong:** Without the template's `.gitattributes`, Git doesn't normalise line endings, so a contributor on Windows can commit CRLF files and produce noisy diffs and Prettier failures.

**Why it happens:** The API 2.1 TypeScript template tracks this file, and this release didn't add it.

**Evidence:** validator: "Required file is missing (tracked by the template)". Template content:

```text
* text=auto eol=lf
```

**Fix:** copy `.gitattributes` from the template.

### C2: `.gitignore` is missing six template entries

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.gitignore:1-7`](https://github.com/bitfocus/companion-module-sonos-speakers/blob/36b899b3ae8eb827a616905374b2556311f6c619/.gitignore#L1-L7)

**What goes wrong:** Files the template keeps out of Git (`package-lock.json`, the Yarn 4 `.yarn` folder, `.vscode`) can be committed by accident.

**Why it happens:** The module's `.gitignore` predates the API 2.1 template and only partly overlaps it.

**Evidence:** validator: "Missing template .gitignore entries: node_modules/, package-lock.json, /\*.tgz, /dist, /.yarn, /.vscode".

```text
module:   **/node_modules, dist/, *.log, /pkg, /pkg.tgz, DEBUG-*, *.tgz
template: node_modules/, package-lock.json, /pkg, /*.tgz, /dist, DEBUG-*, /.yarn, /.vscode
```

**Fix:** add the six template entries. Your extra entries (`*.log`, `/pkg.tgz` and so on) may stay.

### C3: `.husky/pre-commit` is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.husky/pre-commit` (missing)

**What goes wrong:** The `lint-staged` block in package.json never runs, because there is no pre-commit hook to start it. Unformatted or unlinted code can be committed.

**Why it happens:** The template's Husky hook wasn't added in this release (see also [C8](#c8-packagejson-is-missing-the-postinstall-script) and [C10](#c10-packagejson-is-missing-the-husky-devdependency)).

**Evidence:** validator: "Required file is missing (tracked by the template)". Template content:

```text
lint-staged
```

**Fix:** copy `.husky/pre-commit` from the template.

### C4: `.prettierignore` is missing the template's `/LICENSE.md` entry

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.prettierignore:1-3`](https://github.com/bitfocus/companion-module-sonos-speakers/blob/36b899b3ae8eb827a616905374b2556311f6c619/.prettierignore#L1-L3)

**What goes wrong:** `yarn format` can reformat a `LICENSE.md`, which the template keeps untouched.

**Why it happens:** The module's `.prettierignore` has `package.json`, `dist` and `pkg`. The extra `dist` and `pkg` entries are generated output and fine, but the template's `/LICENSE.md` line is missing.

**Evidence:** validator: "Differs from template (line 2: found 'dist', template '/LICENSE.md')".

```text
module:   package.json, dist, pkg
template: package.json, /LICENSE.md
```

**Fix:** add `/LICENSE.md`. The `dist` and `pkg` lines may stay.

### C5: `.yarnrc.yml` is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.yarnrc.yml` (missing)

**What goes wrong:** Installs don't get the template's Yarn 4 safety settings: install scripts stay enabled, new package versions aren't held back for 3 days, and the `node_modules` layout isn't pinned.

**Why it happens:** The module still uses Yarn 1 (see [C7](#c7-packagejson-has-no-packagemanager-field-and-yarnlock-is-a-yarn-1-lockfile)), and the template's Yarn 4 config wasn't added.

**Evidence:** validator: "Required file is missing (tracked by the template)". Template content:

```yaml
enableScripts: false
nodeLinker: node-modules
npmMinimalAgeGate: 3d
npmPreapprovedPackages: ["@companion-module/*"]
```

**Fix:** copy `.yarnrc.yml` from the template.

### C6: `tsconfig.build.json` is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `tsconfig.build.json` (missing); [`package.json:8-9`](https://github.com/bitfocus/companion-module-sonos-speakers/blob/36b899b3ae8eb827a616905374b2556311f6c619/package.json#L8-L9)

**What goes wrong:** The build doesn't follow the template's split between the build config and the editor config, so `build:main` and `dev` compile with `tsconfig.json` instead.

**Why it happens:** The template's build settings live in `tsconfig.build.json`, which extends `@companion-module/tools/tsconfig/node26/recommended.json`. The module inlines them in `tsconfig.json` instead.

**Evidence:** validator: "Required file is missing (tracked by the template)".

```json
// package.json:8-9
"build:main": "tsc -p tsconfig.json",
"dev": "tsc -p tsconfig.json --watch",
```

**Fix:** add the template's `tsconfig.build.json`, make `tsconfig.json` extend it as the template does, and point `build:main` and `dev` at `tsconfig.build.json`.

### C7: package.json has no `packageManager` field, and yarn.lock is a Yarn 1 lockfile

- **Source:** 🤖 validate-template (PKG-FIELD)
- **Classification:** 🆕 NEW
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-sonos-speakers/blob/36b899b3ae8eb827a616905374b2556311f6c619/package.json); [`yarn.lock:1-2`](https://github.com/bitfocus/companion-module-sonos-speakers/blob/36b899b3ae8eb827a616905374b2556311f6c619/yarn.lock#L1-L2)

**What goes wrong:** Whoever builds the module gets whatever Yarn is installed globally, usually Yarn 1, instead of the Yarn 4 version every API 2.1 module pins.

**Why it happens:** The template sets `"packageManager": "yarn@4.18.1"`, so Corepack picks the right Yarn. Without it, the committed lockfile is still a Yarn 1 lockfile.

**Evidence:** validator: "Missing required field 'packageManager' (present in template)".

```text
template: "packageManager": "yarn@4.18.1"
yarn.lock:1-2: # THIS IS AN AUTOGENERATED FILE. DO NOT EDIT THIS FILE DIRECTLY.
               # yarn lockfile v1
```

**Fix:** add `"packageManager": "yarn@4.18.1"`, then run `yarn install` with Yarn 4 and commit the regenerated `yarn.lock`.

### C8: package.json is missing the `postinstall` script

- **Source:** 🤖 validate-template (PKG-SCRIPT)
- **Classification:** 🆕 NEW
- **File:** [`package.json:6-13`](https://github.com/bitfocus/companion-module-sonos-speakers/blob/36b899b3ae8eb827a616905374b2556311f6c619/package.json#L6-L13)

**What goes wrong:** Installing the dependencies doesn't set up the Git hooks, so the pre-commit lint never runs.

**Why it happens:** The template's `postinstall` script runs `husky`, which installs the hooks from `.husky/`.

**Evidence:** validator: "Missing required script 'postinstall'". Template: `"postinstall": "husky"`.

**Fix:** add `"postinstall": "husky"` to `scripts`.

### C9: package.json is missing the `lint:raw` script

- **Source:** 🤖 validate-template (PKG-SCRIPT)
- **Classification:** 🔙 REGRESSION
- **File:** [`package.json:6-13`](https://github.com/bitfocus/companion-module-sonos-speakers/blob/36b899b3ae8eb827a616905374b2556311f6c619/package.json#L6-L13)

**What goes wrong:** The template's lint entry point is gone, so `yarn lint` and the pre-commit hook don't call ESLint the way other modules do.

**Why it happens:** v1.1.0 had a `lint:raw` script. This release removed it and made `lint` call `eslint .` directly.

**Evidence:** validator: "Missing required script 'lint:raw'". Template: `"lint:raw": "eslint"` and `"lint": "run lint:raw ."`.

**Fix:** add `"lint:raw": "eslint"` and set `lint` to `run lint:raw .` (see also [H2](#h2-packagejson-lint-format-package-and-lint-staged-commands-differ-from-the-template)).

### C10: package.json is missing the `husky` devDependency

- **Source:** 🤖 validate-template (PKG-DEVDEP)
- **Classification:** 🆕 NEW
- **File:** [`package.json:31-39`](https://github.com/bitfocus/companion-module-sonos-speakers/blob/36b899b3ae8eb827a616905374b2556311f6c619/package.json#L31-L39)

**What goes wrong:** Husky isn't installed, so no Git hooks are set up.

**Why it happens:** The template lists Husky as a devDependency, and this release didn't add it.

**Evidence:** validator: "Missing devDependency 'husky' (present in template)". Template: `"husky": "^9.1.7"`.

**Fix:** add `"husky": "^9.1.7"` to `devDependencies`.

### C11: package.json is missing the `lint-staged` devDependency

- **Source:** 🤖 validate-template (PKG-DEVDEP)
- **Classification:** 🆕 NEW
- **File:** [`package.json:31-39`](https://github.com/bitfocus/companion-module-sonos-speakers/blob/36b899b3ae8eb827a616905374b2556311f6c619/package.json#L31-L39)

**What goes wrong:** The `lint-staged` block in package.json can't run, because the tool isn't installed.

**Why it happens:** The template lists `lint-staged` as a devDependency, and this release didn't add it.

**Evidence:** validator: "Missing devDependency 'lint-staged' (present in template)". Template: `"lint-staged": "^17.6.0"`.

**Fix:** add `"lint-staged": "^17.6.0"` to `devDependencies`.

## 🟠 High

### H1: Every Save in the connection settings leaves the old speaker subscriptions and their renewal timers running

- **Source:** 🔎 protocol reviewer, QA reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:62-68`](https://github.com/bitfocus/companion-module-sonos-speakers/blob/36b899b3ae8eb827a616905374b2556311f6c619/src/main.ts#L62-L68), [`src/main.ts:103`](https://github.com/bitfocus/companion-module-sonos-speakers/blob/36b899b3ae8eb827a616905374b2556311f6c619/src/main.ts#L103), [`src/main.ts:208-218`](https://github.com/bitfocus/companion-module-sonos-speakers/blob/36b899b3ae8eb827a616905374b2556311f6c619/src/main.ts#L208-L218)

**What goes wrong:** Take a user with a 6-room Sonos system. They open the Sonos connection, change "Status refresh interval" from 5 to 10 (or pick another "Network interface for speaker updates") and click Save. The module subscribes again to every speaker's transport and volume updates: 12 new subscriptions for 6 rooms. The 12 from before the Save are never cancelled, and each keeps its own 10-minute renewal timer, which keeps renewing it with the speaker for as long as the module runs. Every Save adds another full set: after three saves, 48 subscriptions are being renewed instead of 12. The old event handlers stay attached too, so while the speakers keep delivering to the old subscriptions, each volume or track change is processed once per set, recalculating the variables and checking the feedbacks several times. The user sees nothing directly, but the work, the timers and the subscriptions on the speakers pile up with each Save until Companion restarts the connection.

**Why it happens:** New in this release, every connect (on start-up and on every Save) creates a fresh Sonos manager with fresh speaker objects. The code comment says this is "so event handlers of the previous one cannot fire into the new state". But the clean-up step only calls the manager's `CancelSubscription()`, which in @svrooij/sonos 2.7.0 removes just the zone-group listener. Each speaker's update subscriptions are started by the module's `device.Events.on(...)` listeners, and the library only cancels them (sending UNSUBSCRIBE and clearing the renewal timer) when those listeners are removed, for example with `device.CancelEvents()`. The module never removes them. v1.1.0 reused one manager and the same speaker objects, so a Save didn't create new subscriptions.

**Evidence:**

```ts
// src/main.ts:62-68
		this.stopManager()
		this.state.clear()
		this.reportedSubscriptionErrors.clear()
		this.context = undefined
		// Use a fresh manager, so event handlers of the previous one cannot fire into the new state
		this.manager = new SonosManager()
		const manager = this.manager
```

```ts
// src/main.ts:103
		manager.Devices.forEach((d) => this.subscribeEvents(d))
```

```ts
// src/main.ts:208-218
	private stopManager(): void {
		if (this.pollTimer) {
			clearInterval(this.pollTimer)
			this.pollTimer = undefined
		}
		try {
			this.manager.CancelSubscription()
		} catch {
			// Ignore
		}
	}
```

```ts
// src/main.ts:220-229
	private subscribeEvents(device: SonosDevice): void {
		const refresh = (): void => updateVariables(this, this.manager, this.state)
		...
		device.Events.on(SonosEvents.CurrentTransportState, () => {
```

`grep -rnE "CancelEvents|removeAllListeners|removeListener|\.off\(" src` finds nothing.

```js
// @svrooij/sonos 2.7.0 lib/sonos-manager.js:139-142
    CancelSubscription() {
        if (this.zoneService !== undefined)
            this.zoneService.Events.removeListener(models_1.ServiceEvents.ServiceEvent, this.zoneEventSubscription);
    }
```

```js
// @svrooij/sonos 2.7.0 lib/services/base-service.js:343-353
        this.sid = sid;
        if (this.eventRenewInterval === undefined) {
            this.eventRenewInterval = setInterval(async () => {
                await this.renewEventSubscription()
                    ...
            }, 600 * 1000); // Renew events every 10 minutes.
        }
        sonos_event_listener_1.default.DefaultInstance.RegisterSubscription(sid, this);
```

```js
// @svrooij/sonos 2.7.0 lib/sonos-device.js:697-705
    CancelEvents() {
        if (this.events !== undefined) {
            const eventNames = this.events.eventNames().filter((e) => e !== 'removeListener' && e !== 'newListener' && e !== models_1.SonosEvents.SubscriptionError);
            eventNames.forEach((e) => {
                if (this.events !== undefined)
                    this.events.removeAllListeners(e);
            });
        }
    }
```

```ts
// git show v1.1.0:src/main.ts (previous release)
	private readonly manager = new SonosManager()
```

**Confirm by:** open [`src/main.ts:57-103`](https://github.com/bitfocus/companion-module-sonos-speakers/blob/36b899b3ae8eb827a616905374b2556311f6c619/src/main.ts#L57-L103) and [`src/main.ts:208-218`](https://github.com/bitfocus/companion-module-sonos-speakers/blob/36b899b3ae8eb827a616905374b2556311f6c619/src/main.ts#L208-L218). A new `SonosManager` is created on every connect and its speakers get `Events.on()` listeners, but `stopManager()` only calls `manager.CancelSubscription()`. There is no `device.CancelEvents()` call anywhere.

**Fix:** in `stopManager()`, cancel every speaker's events before the manager is replaced. The `Devices` getter throws when the list is empty, so guard it.

```ts
private stopManager(): void {
	if (this.pollTimer) {
		clearInterval(this.pollTimer)
		this.pollTimer = undefined
	}
	try {
		this.manager.CancelSubscription()
	} catch {
		// Ignore
	}
	try {
		for (const device of this.manager.Devices) device.CancelEvents()
	} catch {
		// No devices loaded yet
	}
}
```

`SonosDevice.CancelEvents()` removes the module's listeners, which makes the library send UNSUBSCRIBE and clear each service's 10-minute renewal timer.

### H2: package.json `lint`, `format`, `package` and lint-staged commands differ from the template

- **Source:** 🔎 compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`package.json:6-23`](https://github.com/bitfocus/companion-module-sonos-speakers/blob/36b899b3ae8eb827a616905374b2556311f6c619/package.json#L6-L23)

**What goes wrong:** Companion users see no effect. Maintainers and reviewers do: `yarn lint`, `yarn package`, `yarn format` and the pre-commit lint-staged step run different commands from every other API 2.1 module, which makes the module harder to maintain alongside them.

**Why it happens:** This release rewrote these scripts for API 2.1 but didn't copy the template's versions. The validator already reports the missing `postinstall` and `lint:raw` scripts ([C8](#c8-packagejson-is-missing-the-postinstall-script), [C9](#c9-packagejson-is-missing-the-lintraw-script)) and the `tsconfig.build.json` builds ([C6](#c6-tsconfigbuildjson-is-missing)). These four rewritten commands are not covered: `lint` (`eslint .` vs `run lint:raw .`), `package` (`yarn build && …` vs `run build && …`), `format` (`prettier --write .` vs `prettier -w .`, the same option spelled differently) and the lint-staged TypeScript step (`eslint --fix` vs `yarn lint:raw --fix`).

**Evidence:**

```json
// package.json:6-23 (v2.0.1)
	"scripts": {
		"build": "rimraf dist && yarn build:main",
		"build:main": "tsc -p tsconfig.json",
		"dev": "tsc -p tsconfig.json --watch",
		"lint": "eslint .",
		"format": "prettier --write .",
		"package": "yarn build && companion-module-build"
	},
	"license": "MIT",
	"prettier": "@companion-module/tools/.prettierrc.json",
	"lint-staged": {
		"*.{css,json,md,scss}": [
			"prettier --write"
		],
		"*.{ts,tsx,js,jsx}": [
			"eslint --fix"
		]
	},
```

```json
// companion-module-template-ts/package.json:6-15, 44-46 (template @ e0d42b7)
	"scripts": {
		"postinstall": "husky",
		"format": "prettier -w .",
		"package": "run build && companion-module-build",
		"build": "rimraf dist && run build:main",
		"build:main": "tsc -p tsconfig.build.json",
		"dev": "tsc -p tsconfig.build.json --watch",
		"lint:raw": "eslint",
		"lint": "run lint:raw ."
	},
	...
		"*.{ts,tsx,js,jsx}": [
			"yarn lint:raw --fix"
		]
```

```diff
// git diff v1.1.0..v2.0.1 -- package.json
-		"lint:raw": "eslint --ext .ts --ext .js --ignore-pattern dist --ignore-pattern pkg",
-		"lint": "yarn lint:raw .",
-		"dist": "yarn companion-module-build"
+		"lint": "eslint .",
+		"format": "prettier --write .",
+		"package": "yarn build && companion-module-build"
 ...
-			"yarn lint:raw --fix"
+			"eslint --fix"
```

**Confirm by:** open [`package.json:6-23`](https://github.com/bitfocus/companion-module-sonos-speakers/blob/36b899b3ae8eb827a616905374b2556311f6c619/package.json#L6-L23) next to the template's `package.json:6-15` and `:44-46`. `git diff v1.1.0..v2.0.1 -- package.json` shows this release added those lines.

**Fix:** copy the template's `scripts` block and its lint-staged `*.{ts,tsx,js,jsx}` entry as they are, together with the validator's `tsconfig.build.json`, `lint:raw`, `postinstall` and Yarn 4 fixes, which these commands depend on. Extra scripts of your own may stay.

### H3: package.json `engines` has no `yarn` entry

- **Source:** 🔎 compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`package.json:24-26`](https://github.com/bitfocus/companion-module-sonos-speakers/blob/36b899b3ae8eb827a616905374b2556311f6c619/package.json#L24-L26)

**What goes wrong:** Companion users see no effect. Nothing tells a contributor that the module expects Yarn 4, and the repository still installs with Yarn 1.

**Why it happens:** This release updated the `engines` block for API 2.1 (Node `^18` to `^26`) but didn't add the template's `"yarn": "^4"`. The key was also missing in v1.1.0, but the block was rewritten for the API 2.1 template in this release. It belongs with the Yarn 4 move in [C5](#c5-yarnrcyml-is-missing) and [C7](#c7-packagejson-has-no-packagemanager-field-and-yarnlock-is-a-yarn-1-lockfile).

**Evidence:**

```json
// package.json:24-26 (v2.0.1)
	"engines": {
		"node": "^26"
	},
```

```json
// companion-module-template-ts/package.json:21-24
	"engines": {
		"node": "^26",
		"yarn": "^4"
	},
```

```diff
// git diff v1.1.0..v2.0.1 -- package.json (engines hunk)
 	"engines": {
-		"node": "^18"
+		"node": "^26"
 	},
```

**Confirm by:** open [`package.json:24-26`](https://github.com/bitfocus/companion-module-sonos-speakers/blob/36b899b3ae8eb827a616905374b2556311f6c619/package.json#L24-L26): `engines` has only `"node": "^26"`, while the template's `package.json:21-24` also has `"yarn": "^4"`.

**Fix:** add `"yarn": "^4"` to `engines`, as part of the move to Yarn 4.

### H4: TypeScript is pinned with `^6` where the template uses `~6.0.3`

- **Source:** 🔎 compliance reviewer — verified
- **Classification:** 🔙 REGRESSION
- **File:** [`package.json:37`](https://github.com/bitfocus/companion-module-sonos-speakers/blob/36b899b3ae8eb827a616905374b2556311f6c619/package.json#L37)

**What goes wrong:** Companion users see no effect. For maintainers, a fresh install or lockfile refresh can pull a newer TypeScript 6.x minor release, whose stricter checks can suddenly break `yarn build`. The template avoids that by allowing only patch releases.

**Why it happens:** v1.1.0 used a tilde range (`~5.2`), like the template. This release changed it to a caret range.

**Evidence:**

```json
// package.json:37 (v2.0.1)
		"typescript": "^6",
```

```json
// companion-module-template-ts/package.json:36 (template @ e0d42b7)
		"typescript": "~6.0.3",
```

```diff
// git diff v1.1.0..v2.0.1 -- package.json
-		"typescript": "~5.2"
+		"typescript": "^6",
```

**Confirm by:** open [`package.json:37`](https://github.com/bitfocus/companion-module-sonos-speakers/blob/36b899b3ae8eb827a616905374b2556311f6c619/package.json#L37) and compare it with the template's `package.json:36`.

**Fix:** use `"typescript": "~6.0.3"` as the template does, and refresh the lockfile.

### H5: Manifest has no `$schema` line, so editors can't validate it

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`companion/manifest.json:1-2`](https://github.com/bitfocus/companion-module-sonos-speakers/blob/36b899b3ae8eb827a616905374b2556311f6c619/companion/manifest.json#L1-L2)

**What goes wrong:** No visible effect in Companion. Maintainers lose the editor validation and autocomplete for `companion/manifest.json` (for example `bonjourQueries` and `runtime.type`) that the template provides. The manifest must match the API 2.1 template, which starts with this line.

**Why it happens:** This release rewrote the manifest for API 2.1 but didn't add the template's `$schema` entry.

**Evidence:**

```jsonc
// companion/manifest.json:1-3 (module)
{
	"type": "connection",
	"id": "sonos-speakers",
// companion/manifest.json:1-3 (template companion-module-template-ts @ e0d42b7)
{
	"$schema": "../node_modules/@companion-module/base/assets/manifest.schema.json",
	"type": "connection",
```

**Confirm by:** open [`companion/manifest.json`](https://github.com/bitfocus/companion-module-sonos-speakers/blob/36b899b3ae8eb827a616905374b2556311f6c619/companion/manifest.json#L1-L3) and check the first key after `{`: it is `"type"`, and there is no `"$schema"` key anywhere in the file.

**Fix:** add `"$schema": "../node_modules/@companion-module/base/assets/manifest.schema.json",` as the first key, as in the template.

### H6: Actions, feedbacks and variables aren't typed from a module schema

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/types.ts:4-7`](https://github.com/bitfocus/companion-module-sonos-speakers/blob/36b899b3ae8eb827a616905374b2556311f6c619/src/types.ts#L4-L7)

**What goes wrong:** No visible effect for users. Options are read by string key (`getOptInt(action, 'volume')`, `action.options.mode`), so a typo in an option id compiles fine and only shows up as an action that silently does nothing.

**Why it happens:** `ModuleTypes` only sets `config` and `secrets`, so actions, feedbacks and variables fall back to the loose defaults. The API 2.1 template declares action, feedback and variable schemas so these are type-checked, and the module must match it.

**Evidence:**

```ts
// src/types.ts:4-7 (module)
export interface ModuleTypes extends InstanceTypes {
	config: DeviceConfig
	secrets: undefined
}
// src/actions-eq.ts:184, src/actions-library.ts:148 (module): options read by string key
						DesiredVolume: getOptInt(action, 'volume'),
				const duration = action.options.mode === 'cancel' ? '' : formatDuration(getOptInt(action, 'minutes') * 60)
// src/main.ts:9-15 (template companion-module-template-ts @ e0d42b7)
export type ModuleSchema = {
	config: ModuleConfig
	secrets: undefined
	actions: ActionsSchema
	feedbacks: FeedbacksSchema
	variables: VariablesSchema
}
```

**Confirm by:** open [`src/types.ts:4-7`](https://github.com/bitfocus/companion-module-sonos-speakers/blob/36b899b3ae8eb827a616905374b2556311f6c619/src/types.ts#L4-L7): `ModuleTypes` has no `actions`, `feedbacks` or `variables` key, while the template's `ModuleSchema` in `src/main.ts:9-15` has all three.

**Fix:** declare action, feedback and variable schemas and add them to `ModuleTypes`, as in the template's `ModuleSchema`, then read options as typed properties. See the companion-v2-actions and companion-v2-feedbacks skills.

## 🟡 Medium

### M1: Sleep timer: the Minutes field stays visible when Mode is Cancel

- **Source:** 🔎 compliance reviewer, QA reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/actions-library.ts:121-143`](https://github.com/bitfocus/companion-module-sonos-speakers/blob/36b899b3ae8eb827a616905374b2556311f6c619/src/actions-library.ts#L121-L143)

**What goes wrong:** A user adds the new "Sleep timer" action to a button and sets Mode to "Cancel". The "Minutes" field (30 by default) should hide, but it stays visible, so it looks as if the cancel action still sets a 30-minute timer. The action itself still works: Minutes is ignored when Mode is Cancel. Only the editor is confusing ([A1](#-assumptions-to-confirm)).

**Why it happens:** The Minutes field's visibility expression reads the Mode option. In API 2.x, a visibility expression may only read options that set `disableAutoExpression: true`, because any other option can be switched to an expression by the user. The Mode dropdown doesn't set it, so Companion refuses the read, can't work out the visibility, and shows the field.

**Evidence:**

```ts
// src/actions-library.ts:125-143
				{
					type: 'dropdown',
					label: 'Mode',
					id: 'mode',
					default: 'set',
					choices: [
						{ id: 'set', label: 'Set' },
						{ id: 'cancel', label: 'Cancel' },
					],
				},
				{
					type: 'number',
					label: 'Minutes',
					id: 'minutes',
					default: 30,
					min: 1,
					max: 1439,
					isVisibleExpression: `$(options:mode) == 'set'`,
				},
```

```ts
// @companion-module/base 2.1.3 dist/module-api/input.d.ts (isVisibleExpression)
     * Note: you can only reference fields which are set to `disableAutoExpression` here, as other fields can be expressions and frequently changing values
```

**Fix:** add `disableAutoExpression: true` to the Sleep timer's Mode dropdown. A Set/Cancel choice gains nothing from expression mode, and no saved button can use an expression on it yet because the action is new in this release.

### M2: `.github/workflows/node.yaml` is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.github/workflows/node.yaml` (missing)

**What goes wrong:** Pushes and pull requests don't get the template's lint and build check.

**Why it happens:** The template tracks this workflow, and the module only has `companion-module-checks.yaml`.

**Fix:** copy `.github/workflows/node.yaml` from the template.

### M3: `.github/workflows/release.yaml` is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.github/workflows/release.yaml` (missing)

**What goes wrong:** Tagged releases don't get the template's release workflow.

**Why it happens:** The template tracks this workflow, and the module doesn't have it.

**Fix:** copy `.github/workflows/release.yaml` from the template.

## 📝 Additional Notes

- `tsconfig.json` differs from the template: `extends` is `@companion-module/tools/tsconfig/node26/recommended.json` instead of `./tsconfig.build.json`, and the build settings (`outDir`, `rootDir`, the spec/tests excludes) are inlined because `tsconfig.build.json` is missing ([C6](#c6-tsconfigbuildjson-is-missing)). Not blocking.

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Companion 5.0.x evaluates an action option's visibility expression the same way as 5.1.1: reading an option without `disableAutoExpression` fails, and the field stays visible | the locally installed Companion 5.1.1 web UI bundle and the base 2.1.3 `input.d.ts` note on `isVisibleExpression`; other 5.x versions not checked | [M1](#m1-sleep-timer-the-minutes-field-stays-visible-when-mode-is-cancel) |
