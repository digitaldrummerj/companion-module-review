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
| A1 | When a connection is renamed, Companion passes the new label to the running module and calls `configUpdated()` instead of restarting it (a restart would run `init()` and rebuild the presets), and it does not ask the module for its presets again | the `@companion-module/base` 2.1.3 doc comment in `dist/module-api/base.js:17` ("can be changed just before `configUpdated` is called") and the `label` getter at `base.js:19-20`; Companion's host code not checked | [L2](#l2-after-renaming-the-connection-newly-dragged-presets-show-the-old-connection-name-instead-of-live-values) |
| A2 | Companion does not filter out unchanged values before they cost IPC and callback work: every `setVariableValues`, `checkFeedbacks` and `updateStatus` call is sent to and processed by the host | the base package forwards these calls straight to the host context (`base.js:82-84`, `167-169`); Companion's side not checked | [L1](#l1-the-module-resends-every-variable-rechecks-14-feedbacks-and-resets-the-status-twice-a-second-even-when-nothing-changed) |
| A3 | Companion 5.0 aborts an action's `context.signal` in real use (abort button, re-press, connection disable), so passing it on has a practical effect | the API 2.1 compliance reference (abort signals); host behaviour not observed | [M1](#m1-a-button-press-keeps-its-http-request-running-after-companion-cancels-the-action) |

## 📋 Issues

### Blocking

- [ ] [C1: The module is set to run on Node 22, but API 2.1 modules run on Node 26](#c1-the-module-is-set-to-run-on-node-22-but-api-21-modules-run-on-node-26)
- [ ] [C2: Old build output is never cleared before a build, so stale files can end up in the package](#c2-old-build-output-is-never-cleared-before-a-build-so-stale-files-can-end-up-in-the-package)
- [ ] [H1: The GitHub build check uses Node 22 and adds a test step the template does not have](#h1-the-github-build-check-uses-node-22-and-adds-a-test-step-the-template-does-not-have)

### Non-blocking

- [ ] [M1: A button press keeps its HTTP request running after Companion cancels the action](#m1-a-button-press-keeps-its-http-request-running-after-companion-cancels-the-action)
- [ ] [L1: The module resends every variable, rechecks 14 feedbacks and resets the status twice a second, even when nothing changed](#l1-the-module-resends-every-variable-rechecks-14-feedbacks-and-resets-the-status-twice-a-second-even-when-nothing-changed)
- [ ] [L2: After renaming the connection, newly dragged presets show the old connection name instead of live values](#l2-after-renaming-the-connection-newly-dragged-presets-show-the-old-connection-name-instead-of-live-values)
- [ ] [N1: Type casts and non-null assertions in preset building hide layout mistakes](#n1-type-casts-and-non-null-assertions-in-preset-building-hide-layout-mistakes)

## 🔴 Critical

### C1: The module is set to run on Node 22, but API 2.1 modules run on Node 26

- **Source:** 🤖 validate-template (MAN-RUNTIME)
- **Classification:** 🆕 NEW
- **File:** [`companion/manifest.json:18`](https://github.com/bitfocus/companion-module-c4-clock/blob/03329aca0c6d1b3257f48ce177d03627c77dc410/companion/manifest.json#L18), [`tsconfig.build.json:2`](https://github.com/bitfocus/companion-module-c4-clock/blob/03329aca0c6d1b3257f48ce177d03627c77dc410/tsconfig.build.json#L2)

**What goes wrong:** The module is built on API 2.1 (`@companion-module/base` 2.1.3), but its manifest asks Companion to run it on Node 22 and it is compiled with the Node 22 TypeScript preset. Every API 2.1 module is expected to match the API 2.1 template, which runs on Node 26. A module that differs from its template makes later troubleshooting harder.

**Why it happens:** The manifest's `runtime.type` tells Companion which Node.js version to start the module with. It was left at `node22`, and `tsconfig.build.json` extends the matching Node 22 preset, where the template extends the Node 26 one.

**Evidence:**

```json
// companion/manifest.json:18 (template: "node26")
"type": "node22",
```

```json
// tsconfig.build.json:2 (template: "@companion-module/tools/tsconfig/node26/recommended.json")
"extends": "@companion-module/tools/tsconfig/node22/recommended-esm.json",
```

**Confirm by:** open [`companion/manifest.json:18`](https://github.com/bitfocus/companion-module-c4-clock/blob/03329aca0c6d1b3257f48ce177d03627c77dc410/companion/manifest.json#L18) and compare with the template's `companion/manifest.json`.

**Fix:** switch the runtime and the TypeScript preset to Node 26, as the template does, then rebuild.

```json
// companion/manifest.json
"type": "node26",
```

```json
// tsconfig.build.json
"extends": "@companion-module/tools/tsconfig/node26/recommended.json",
```

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

### H1: The GitHub build check uses Node 22 and adds a test step the template does not have

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.github/workflows/node.yaml:21-25`](https://github.com/bitfocus/companion-module-c4-clock/blob/03329aca0c6d1b3257f48ce177d03627c77dc410/.github/workflows/node.yaml#L21-L25), [`.github/workflows/node.yaml:53-56`](https://github.com/bitfocus/companion-module-c4-clock/blob/03329aca0c6d1b3257f48ce177d03627c77dc410/.github/workflows/node.yaml#L53-L56)

**What goes wrong:** The GitHub Actions check that runs on every push builds and lints the module with Node 22, while the API 2.1 template uses Node 26. It also adds a "Run module tests" step to the lint job, which is not in the template.

**Why it happens:** The workflow file was not kept in line with the API 2.1 template. The template offers tests as a separate, commented-out `test` job instead of an extra step in the lint job. The commented-out lines 66 and 69 also say 22.x where the template says 26.x.

**Evidence:**

```yaml
# .github/workflows/node.yaml:21-25 (template: 26.x)
- name: Use Node.js 22.x
  ...
  node-version: 22.x
# .github/workflows/node.yaml:53-56 (not in the template)
- name: Run module tests
  run: yarn test
  env:
    CI: true
```

**Confirm by:** diff [`.github/workflows/node.yaml`](https://github.com/bitfocus/companion-module-c4-clock/blob/03329aca0c6d1b3257f48ce177d03627c77dc410/.github/workflows/node.yaml) against the template's copy.

**Fix:** copy the template's `node.yaml`. Node 26 goes with the C1 fix. To run tests in CI, uncomment the template's optional `test` job instead of adding a step to the lint job.

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

### L1: The module resends every variable, rechecks 14 feedbacks and resets the status twice a second, even when nothing changed

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:139-268`](https://github.com/bitfocus/companion-module-c4-clock/blob/03329aca0c6d1b3257f48ce177d03627c77dc410/src/main.ts#L139-L268)

**What goes wrong:** While a C4 Clock connection is enabled, the module asks the app for its state every 500 ms. Each reply pushes all 37 variables (for example `$(C4_Clock:timer)` and the six quick-preset labels), re-runs all 14 feedbacks and sets the connection status to OK again, even when nothing changed (for example a paused timer showing 05:00). When the C4 app is closed, every tick writes the OFFLINE values, re-runs the feedbacks and sets "Connection Failure" again. Users see nothing wrong, but each connection adds constant work to Companion, which adds up with several connections or on a Raspberry Pi.

**Why it happens:** The state handler (`applyState()`) and the offline handler (`markOffline()`) run on every poll result and never compare with what they sent last time.

**Fix:** remember the last variable values, status and online flag, and only send what changed: `setVariableValues()` with the changed keys, `checkFeedbacks()` when a field a feedback reads has changed, and `updateStatus()` / `markOffline()` only when the state actually changes.

### L2: After renaming the connection, newly dragged presets show the old connection name instead of live values

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

## 💡 Nice to Have

### N1: Type casts and non-null assertions in preset building hide layout mistakes

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/presets.ts:314`](https://github.com/bitfocus/companion-module-c4-clock/blob/03329aca0c6d1b3257f48ce177d03627c77dc410/src/presets.ts#L314), [`src/presets.ts:319`](https://github.com/bitfocus/companion-module-c4-clock/blob/03329aca0c6d1b3257f48ce177d03627c77dc410/src/presets.ts#L319), [`src/presets.ts:339-340`](https://github.com/bitfocus/companion-module-c4-clock/blob/03329aca0c6d1b3257f48ce177d03627c77dc410/src/presets.ts#L339-L340), [`src/presets.ts:412`](https://github.com/bitfocus/companion-module-c4-clock/blob/03329aca0c6d1b3257f48ce177d03627c77dc410/src/presets.ts#L412), [`src/presets.ts:467`](https://github.com/bitfocus/companion-module-c4-clock/blob/03329aca0c6d1b3257f48ce177d03627c77dc410/src/presets.ts#L467)

**What goes wrong:** Nothing is visible today: all 30 generated layered layouts have a box and a text element. But if `design-assets/preset-layout.json` is regenerated with a layout that lacks one of them, the "C4 OFFLINE" overlay is built from `undefined` without any build or test error, and Companion may reject the preset or draw it wrong.

**Why it happens:** `find(...)!` and casts such as `as unknown as Array<...>` tell TypeScript to skip its checks, so the generated layout's shape is never validated.

**Fix:** replace the `!` with an explicit check that throws a clear error (as line 258 already does for a missing preset), or validate every layout in `scripts/generate-layered-presets.mjs`, and use type guards instead of `as unknown as`.
