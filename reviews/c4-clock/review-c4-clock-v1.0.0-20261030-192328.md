# Review: companion-module-c4-clock v1.0.0

| Field | Value |
| --- | --- |
| **Module** | `companion-module-c4-clock` |
| **Scope** | `tag` |
| **Version** | v1.0.0 |
| **Release** | New module — never published |
| **API** | 2.1 (base 2.1.3, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Review commit** | [`03329ac`](https://github.com/bitfocus/companion-module-c4-clock/tree/03329aca0c6d1b3257f48ce177d03627c77dc410) |
| **Date** | 2026-10-30 |

This is the module's first release, so there is no previous tag to diff against. The whole module was reviewed, and every finding is classified 🆕 NEW. `yarn install --immutable`, `yarn package` and `yarn lint` all pass.

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | When a connection is renamed, Companion passes the new label to the running module and calls `configUpdated()` instead of restarting it (a restart would run `init()` and rebuild the presets), and it does not ask the module for its presets again | the `@companion-module/base` 2.1.3 doc comment in `dist/module-api/base.js:17` ("can be changed just before `configUpdated` is called") and the `label` getter at `base.js:19-20`; Companion's host code not checked | [L1](#l1-after-renaming-the-connection-newly-dragged-presets-show-the-old-connection-name-instead-of-live-values) |
| A2 | Companion 5.0 aborts an action's `context.signal` in real use (abort button, re-press, connection disable), so passing it on has a practical effect | the API 2.1 compliance reference (abort signals); host behaviour not observed | [M1](#m1-a-button-press-keeps-its-http-request-running-after-companion-cancels-the-action) |

## 📋 Issues

### Blocking

- [ ] [C1: The module still targets Node 22, but the API 2.1 template runs on Node 26](#c1-the-module-still-targets-node-22-but-the-api-21-template-runs-on-node-26)
- [ ] [C2: Old build output is never cleared before a build, so stale files can end up in the package](#c2-old-build-output-is-never-cleared-before-a-build-so-stale-files-can-end-up-in-the-package)
- [ ] [H1: The GitHub build check adds a test step the template does not have](#h1-the-github-build-check-adds-a-test-step-the-template-does-not-have)

### Non-blocking

- [ ] [M1: A button press keeps its HTTP request running after Companion cancels the action](#m1-a-button-press-keeps-its-http-request-running-after-companion-cancels-the-action)
- [ ] [L1: After renaming the connection, newly dragged presets show the old connection name instead of live values](#l1-after-renaming-the-connection-newly-dragged-presets-show-the-old-connection-name-instead-of-live-values)

## 🔴 Critical

### C1: The module still targets Node 22, but the API 2.1 template runs on Node 26

- **Source:** 🤖 validate-template (NODE-VERSION)
- **Classification:** 🆕 NEW
- **File:** [`companion/manifest.json:18`](https://github.com/bitfocus/companion-module-c4-clock/blob/03329aca0c6d1b3257f48ce177d03627c77dc410/companion/manifest.json#L18), [`package.json:26`](https://github.com/bitfocus/companion-module-c4-clock/blob/03329aca0c6d1b3257f48ce177d03627c77dc410/package.json#L26), [`package.json:34`](https://github.com/bitfocus/companion-module-c4-clock/blob/03329aca0c6d1b3257f48ce177d03627c77dc410/package.json#L34), [`tsconfig.build.json:2`](https://github.com/bitfocus/companion-module-c4-clock/blob/03329aca0c6d1b3257f48ce177d03627c77dc410/tsconfig.build.json#L2), [`.github/workflows/node.yaml:21-69`](https://github.com/bitfocus/companion-module-c4-clock/blob/03329aca0c6d1b3257f48ce177d03627c77dc410/.github/workflows/node.yaml#L21-L69)

**What goes wrong:** Companion starts the module on Node 22, but API 2.1 modules are expected to match the API 2.1 template, which uses Node 26 in every place the Node version is named. The other places listed below still name another Node version too, so the module would run, type-check and build in CI on different Node versions even after the runtime is fixed. A module that does not match its template makes later troubleshooting harder: when something misbehaves, people look for the cause in the module instead of in the mismatched setup.

**Why it happens:** Moving a module to another Node version means changing every place the version is named: the manifest runtime, `engines.node`, `@types/node`, the TypeScript preset and the CI workflows. These places still name a different Node version than the API 2.1 template.

**Evidence:**

```text
companion/manifest.json runtime.type 'node22' -> 'node26'
package.json engines.node '^22.20' -> '^26'
package.json devDependencies @types/node '^22.19.17' -> '^26.6.4'
tsconfig.build.json extends "@companion-module/tools/tsconfig/node22/recommended-esm.json" -> "@companion-module/tools/tsconfig/node26/recommended.json"
.github/workflows/node.yaml line 21 step name 'Use Node.js 22.x' -> 'Use Node.js 26.x'
.github/workflows/node.yaml line 25 node-version 22.x -> 26.x
.github/workflows/node.yaml line 66 step name 'Use Node.js 22.x' -> 'Use Node.js 26.x' (commented out)
.github/workflows/node.yaml line 69 node-version 22.x -> 26.x (commented out)
```

**Confirm by:** open each file above and compare it with the template's copy.

**Fix:** update every place to Node 26, as the template does:

- [ ] [`companion/manifest.json:18`](https://github.com/bitfocus/companion-module-c4-clock/blob/03329aca0c6d1b3257f48ce177d03627c77dc410/companion/manifest.json#L18): `"type": "node26"` in `runtime`
- [ ] [`package.json:26`](https://github.com/bitfocus/companion-module-c4-clock/blob/03329aca0c6d1b3257f48ce177d03627c77dc410/package.json#L26): `"engines": { "node": "^26" }`
- [ ] [`package.json:34`](https://github.com/bitfocus/companion-module-c4-clock/blob/03329aca0c6d1b3257f48ce177d03627c77dc410/package.json#L34): `"@types/node": "^26.6.4"` in `devDependencies`
- [ ] [`tsconfig.build.json:2`](https://github.com/bitfocus/companion-module-c4-clock/blob/03329aca0c6d1b3257f48ce177d03627c77dc410/tsconfig.build.json#L2): `"extends": "@companion-module/tools/tsconfig/node26/recommended.json"`
- [ ] [`.github/workflows/node.yaml`](https://github.com/bitfocus/companion-module-c4-clock/blob/03329aca0c6d1b3257f48ce177d03627c77dc410/.github/workflows/node.yaml): `- name: Use Node.js 26.x` (line 21), `node-version: 26.x` (line 25), `- name: Use Node.js 26.x` (line 66, commented out), `node-version: 26.x` (line 69, commented out)

### C2: Old build output is never cleared before a build, so stale files can end up in the package

- **Source:** 🤖 validate-template (PKG-DEVDEP)
- **Classification:** 🆕 NEW
- **File:** [`package.json:12`](https://github.com/bitfocus/companion-module-c4-clock/blob/03329aca0c6d1b3257f48ce177d03627c77dc410/package.json#L12)

**What goes wrong:** When a source file is renamed or deleted, its old compiled copy stays in `dist/` and can be shipped with the next build. The template avoids this by deleting `dist/` before every build.

**Why it happens:** The template lists `rimraf` as a devDependency and its build script runs `rimraf dist` first. The module has no `rimraf`, and its build script goes straight to generating presets and compiling.

**Evidence:**

```json
// package.json:12 (module)
"build": "yarn generate:presets && yarn build:main",
```

```json
// template package.json
"build": "rimraf dist && run build:main",
"rimraf": "^6.1.3"
```

**Confirm by:** open [`package.json`](https://github.com/bitfocus/companion-module-c4-clock/blob/03329aca0c6d1b3257f48ce177d03627c77dc410/package.json#L12). There is no `rimraf` in devDependencies and the build script does not clean `dist`.

**Fix:** add `rimraf` as a devDependency and clear `dist` at the start of the build.

```json
"build": "rimraf dist && yarn generate:presets && yarn build:main",
```

## 🟠 High

### H1: The GitHub build check adds a test step the template does not have

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.github/workflows/node.yaml:53-56`](https://github.com/bitfocus/companion-module-c4-clock/blob/03329aca0c6d1b3257f48ce177d03627c77dc410/.github/workflows/node.yaml#L53-L56)

**What goes wrong:** The GitHub Actions check that runs on every push adds a "Run module tests" step to the lint job, which is not in the API 2.1 template. The workflow no longer matches what other modules run, which makes later troubleshooting harder. (Its Node 22 settings are listed in [C1](#c1-the-module-still-targets-node-22-but-the-api-21-template-runs-on-node-26).)

**Why it happens:** The template offers tests as a separate, commented-out `test` job, not as an extra step in the lint job.

**Evidence:**

```yaml
# .github/workflows/node.yaml:53-56 (not in the template)
- name: Run module tests
  run: yarn test
  env:
    CI: true
```

**Confirm by:** diff [`.github/workflows/node.yaml`](https://github.com/bitfocus/companion-module-c4-clock/blob/03329aca0c6d1b3257f48ce177d03627c77dc410/.github/workflows/node.yaml) against the template's copy.

**Fix:** copy the template's `node.yaml` (with Node 26, as in [C1](#c1-the-module-still-targets-node-22-but-the-api-21-template-runs-on-node-26)). To run tests in CI, uncomment the template's optional `test` job instead of adding a step to the lint job.

## 🟡 Medium

### M1: A button press keeps its HTTP request running after Companion cancels the action

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:20-104`](https://github.com/bitfocus/companion-module-c4-clock/blob/03329aca0c6d1b3257f48ce177d03627c77dc410/src/actions.ts#L20-L104), [`src/main.ts:96-108`](https://github.com/bitfocus/companion-module-c4-clock/blob/03329aca0c6d1b3257f48ce177d03627c77dc410/src/main.ts#L96-L108), [`src/main.ts:284-327`](https://github.com/bitfocus/companion-module-c4-clock/blob/03329aca0c6d1b3257f48ce177d03627c77dc410/src/main.ts#L284-L327)

**What goes wrong:** An operator presses a button such as "Play / Pause countdown" or "Select output" while the C4 Clock PC is slow to answer. Companion 5.0 can cancel that action (for example with an abort button), but the module keeps the request to `/api/control` open for up to 2.5 seconds and can still log "C4 Clock control failed" afterwards. Usually nothing is visible, because the request times out after 2.5 seconds anyway.

**Why it happens:** In API 2.1, every action callback receives a cancel signal (`context.signal`), and network actions are expected to pass it on to their requests. Every callback here calls `self.sendControl(...)`, which sends the request through Node's `http.request()` without a signal, so a cancel has no effect.

**Fix:** pass the action's cancel signal through to the HTTP request, and skip the error status when the request was cancelled.

```ts
callback: async (_event, context) => self.sendControl({ action: 'start' }, context.signal),
// sendControl / requestJson: add `signal?: AbortSignal` and pass it on
httpRequest(url, { method, headers, signal })
```

## 🟢 Low

### L1: After renaming the connection, newly dragged presets show the old connection name instead of live values

- **Source:** 🔎 QA reviewer, compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:87-90`](https://github.com/bitfocus/companion-module-c4-clock/blob/03329aca0c6d1b3257f48ce177d03627c77dc410/src/main.ts#L87-L90), [`src/presets.ts:263-264`](https://github.com/bitfocus/companion-module-c4-clock/blob/03329aca0c6d1b3257f48ce177d03627c77dc410/src/presets.ts#L263-L264), [`src/presets.ts:326`](https://github.com/bitfocus/companion-module-c4-clock/blob/03329aca0c6d1b3257f48ce177d03627c77dc410/src/presets.ts#L326), [`src/presets.ts:343`](https://github.com/bitfocus/companion-module-c4-clock/blob/03329aca0c6d1b3257f48ce177d03627c77dc410/src/presets.ts#L343)

**What goes wrong:** A user adds the connection as "C4_Clock" and later renames it to "stage_clock". Until Companion restarts or the connection is disabled and enabled again, dragging "Countdown display", "Quick preset 1" or "PowerPoint 1" from the Presets panel gives a button with `$(C4_Clock:timer)`-style text, which no longer resolves, so it shows a blank or raw value instead of the time left. The Countdown display's live colour stops working too, because its colour expression also uses the old name.

**Why it happens:** The preset builder writes the connection's current name into every variable reference when it builds the presets, but presets are only built in `init()`. When the connection is renamed, Companion updates the name and calls `configUpdated()`, which only restarts polling and never rebuilds the presets.

**Fix:** rebuild the presets in `configUpdated()`, so they use the current connection name.

```ts
async configUpdated(config: ModuleConfig): Promise<void> {
	this.config = this.normalizedConfig(config)
	this.updatePresets()
	this.startPolling()
}
```
