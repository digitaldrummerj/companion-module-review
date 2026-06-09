# Review: 1stpass-1stpass v1.1.1

| | |
|---|---|
| **Module** | `1stpass-1stpass` |
| **Version** | v1.1.1 |
| **Scope** | `module` (whole-module review) |
| **Language** | TypeScript |
| **API** | @companion-module/base v1.x (`~1.14.1`) |
| **Protocol** | WebSocket (`ws`) |
| **Reviewed** | 2026-06-09 |

> **Note:** This is the module's first submission to review (no previously approved tag), so there is no `previousTag..reviewTag` diff. Per policy this falls back to a **full whole-module review** — every `src/` file was reviewed flat by severity.

## 📊 Scorecard

> Whole-module scope — new vs pre-existing not assessed.

| Severity | Count |
|----------|-------|
| 🔴 Critical | 22 |
| 🟠 High | 2 |
| 🟡 Medium | 7 |
| 🟢 Low | 8 |
| 💡 Nice to Have | 2 |
| **Total** | **41** |

## Verdict: ❌ Changes Required

## 📋 Issues

**Blocking**
- [ ] [C1: .gitattributes file missing](#c1-gitattributes-file-missing)
- [ ] [C2: .prettierignore file missing](#c2-prettierignore-file-missing)
- [ ] [C3: .yarnrc.yml file missing](#c3-yarnrcyml-file-missing)
- [ ] [C4: eslint.config.mjs file missing](#c4-eslintconfigmjs-file-missing)
- [ ] [C5: .husky/pre-commit hook missing](#c5-huskypre-commit-hook-missing)
- [ ] [C6: .gitignore missing required template entries](#c6-gitignore-missing-required-template-entries)
- [ ] [C7: package.json missing required field prettier](#c7-packagejson-missing-required-field-prettier)
- [ ] [C8: package.json missing required field packageManager](#c8-packagejson-missing-required-field-packagemanager)
- [ ] [C9: package.json missing required script postinstall](#c9-packagejson-missing-required-script-postinstall)
- [ ] [C10: package.json missing required script format](#c10-packagejson-missing-required-script-format)
- [ ] [C11: package.json missing required script package](#c11-packagejson-missing-required-script-package)
- [ ] [C12: package.json missing required script build:main](#c12-packagejson-missing-required-script-buildmain)
- [ ] [C13: package.json missing required script lint:raw](#c13-packagejson-missing-required-script-lintraw)
- [ ] [C14: package.json missing required script lint](#c14-packagejson-missing-required-script-lint)
- [ ] [C15: package.json missing devDependency eslint](#c15-packagejson-missing-devdependency-eslint)
- [ ] [C16: package.json missing devDependency husky](#c16-packagejson-missing-devdependency-husky)
- [ ] [C17: package.json missing devDependency lint-staged](#c17-packagejson-missing-devdependency-lint-staged)
- [ ] [C18: package.json missing devDependency prettier](#c18-packagejson-missing-devdependency-prettier)
- [ ] [C19: package.json missing devDependency typescript-eslint](#c19-packagejson-missing-devdependency-typescript-eslint)
- [ ] [C20: package.json missing lint-staged section](#c20-packagejson-missing-lint-staged-section)
- [ ] [C21: manifest id does not match name](#c21-manifest-id-does-not-match-name)
- [ ] [C22: yarn package build pipeline fails](#c22-yarn-package-build-pipeline-fails)
- [ ] [H1: Button-text marker path resolves local variables with self instead of context](#h1-button-text-marker-path-resolves-local-variables-with-self-instead-of-context)
- [ ] [H2: yarn lint fails (no eslint configured)](#h2-yarn-lint-fails-no-eslint-configured)

**Non-blocking**
- [ ] [M1: WebSocket error handler never sets ConnectionFailure status](#m1-websocket-error-handler-never-sets-connectionfailure-status)
- [ ] [M2: No connect timeout or pong-liveness detection — half-open sockets drop sends silently](#m2-no-connect-timeout-or-pong-liveness-detection-half-open-sockets-drop-sends-silently)
- [ ] [M3: Fixed 5s reconnect with no backoff or cap](#m3-fixed-5s-reconnect-with-no-backoff-or-cap)
- [ ] [M4: send drops commands while disconnected but the action reports success](#m4-send-drops-commands-while-disconnected-but-the-action-reports-success)
- [ ] [M5: processResponse writes nested response fields without validation](#m5-processresponse-writes-nested-response-fields-without-validation)
- [ ] [M6: configUpdated reconnect relies on a single intentionalClose flag](#m6-configupdated-reconnect-relies-on-a-single-intentionalclose-flag)
- [ ] [M7: Nested button-text variable uses a fragile two-stage expansion](#m7-nested-button-text-variable-uses-a-fragile-two-stage-expansion)
- [ ] [L1: Empty host produces an indefinite reconnect loop with no BadConfig status](#l1-empty-host-produces-an-indefinite-reconnect-loop-with-no-badconfig-status)
- [ ] [L2: Teardown uses graceful close instead of terminate and is not awaited](#l2-teardown-uses-graceful-close-instead-of-terminate-and-is-not-awaited)
- [ ] [L3: destroy does not guard a partially-initialized connection](#l3-destroy-does-not-guard-a-partially-initialized-connection)
- [ ] [L4: select_camera sends a camera number but reads camera_name back](#l4-select_camera-sends-a-camera-number-but-reads-camera_name-back)
- [ ] [L5: Binary or fragmented frames are swallowed as parse warnings](#l5-binary-or-fragmented-frames-are-swallowed-as-parse-warnings)
- [ ] [L6: colorToHex maps an invalid color to black silently](#l6-colortohex-maps-an-invalid-color-to-black-silently)
- [ ] [L7: Unhandled status ok responses have no diagnostic log](#l7-unhandled-status-ok-responses-have-no-diagnostic-log)
- [ ] [L8: Hidden button_text field has an empty label](#l8-hidden-button_text-field-has-an-empty-label)
- [ ] [N1: configUpdated reconnects even when host and port are unchanged](#n1-configupdated-reconnects-even-when-host-and-port-are-unchanged)
- [ ] [N2: type dropdown uses an empty-string default id](#n2-type-dropdown-uses-an-empty-string-default-id)

---

## 🔴 Critical

The module was not scaffolded from (or has drifted from) the current official **companion-module-template-ts-v1**. The items below are the deterministic template/build failures — each blocks release. The fastest path is to re-sync the project against the template's `package.json`, config files, and tooling rather than fixing them one by one.

### C1: .gitattributes file missing
**File:** `.gitattributes`

Required template file is absent. Copy it from `companion-module-template-ts-v1`.

### C2: .prettierignore file missing
**File:** `.prettierignore`

Required template file is absent. Copy it from the template.

### C3: .yarnrc.yml file missing
**File:** `.yarnrc.yml`

Required template file is absent. The official template uses Yarn 4 (Berry); this file pins the Yarn release and settings. Copy it from the template.

### C4: eslint.config.mjs file missing
**File:** `eslint.config.mjs`

Required ESLint flat-config file is absent. Copy it from the template. (Its absence is also why `yarn lint` fails — see H2.)

### C5: .husky/pre-commit hook missing
**File:** `.husky/pre-commit`

The Husky pre-commit hook is absent. Copy `.husky/pre-commit` from the template and add the `husky` devDependency + `postinstall` script (C9, C16).

### C6: .gitignore missing required template entries
**File:** `.gitignore`

Missing the template's entries: `package-lock.json`, `/.yarn`, `/.vscode`. Add them so build artifacts and the wrong package-manager lockfile aren't committed.

### C7: package.json missing required field prettier
**File:** `package.json`

The `prettier` config key (present in the template) is missing. Add the template's `prettier` field.

### C8: package.json missing required field packageManager
**File:** `package.json`

The `packageManager` field (e.g. `yarn@4.x`) is missing. The module currently builds with npm; the template standardizes on Yarn 4. Add the `packageManager` field matching the template.

### C9: package.json missing required script postinstall
**File:** `package.json`

Missing `postinstall` script (runs `husky`). Add it from the template.

### C10: package.json missing required script format
**File:** `package.json`

Missing `format` script (`prettier --write .`). Add it from the template.

### C11: package.json missing required script package
**File:** `package.json`

Missing `package` script — this is the command Companion uses to build the distributable (`companion-module-build`). Its absence is why C22 (build) fails. Add it from the template.

### C12: package.json missing required script build:main
**File:** `package.json`

Missing `build:main` script. Add it from the template.

### C13: package.json missing required script lint:raw
**File:** `package.json`

Missing `lint:raw` script. Add it from the template.

### C14: package.json missing required script lint
**File:** `package.json`

Missing `lint` script. Add it from the template (depends on eslint scaffolding C4/C15).

### C15: package.json missing devDependency eslint
**File:** `package.json`

`eslint` is not in `devDependencies`. Add it (and the rest of the lint toolchain) from the template.

### C16: package.json missing devDependency husky
**File:** `package.json`

`husky` is not in `devDependencies`. Add it from the template (pairs with C5 / C9).

### C17: package.json missing devDependency lint-staged
**File:** `package.json`

`lint-staged` is not in `devDependencies`. Add it from the template (pairs with C20).

### C18: package.json missing devDependency prettier
**File:** `package.json`

`prettier` is not in `devDependencies`. Add it from the template.

### C19: package.json missing devDependency typescript-eslint
**File:** `package.json`

`typescript-eslint` is not in `devDependencies`. Add it from the template.

### C20: package.json missing lint-staged section
**File:** `package.json`

The `lint-staged` configuration block (present in the template) is missing. Add it from the template.

### C21: manifest id does not match name
**File:** `companion/manifest.json`

`id` is `1stpass-1stpass` but `name` is `1stPass`. The manifest `id` and `name` must be consistent with the registered module identity. Reconcile them (the registry id is `1stpass-1stpass`; set `name` to match the intended display name and ensure the manifest `id` aligns with the package/registry id).

### C22: yarn package build pipeline fails
**File:** `package.json`

The deterministic validator ran the template's standard build command (`yarn package`) and it failed — there is no `package`/`build:main` script and no Yarn 4 setup, so the module cannot be packaged the standard Companion way.

> The module's **own** build does succeed: `npm run build` (`rimraf dist && tsc -p tsconfig.build.json`) compiles cleanly. So the TypeScript itself is fine — this Critical is specifically about the missing template build/package pipeline. Once C7–C20 are restored (Yarn 4 + `package`/`build:main` scripts + tooling), `yarn package` will run.

---

## 🟠 High

### H1: Button-text marker path resolves local variables with self instead of context
**File:** `src/actions.ts:88` (also `:91`)

The `create_marker` action's default marker source is **"Button Text String"**, whose hidden `button_text` field defaults to `BUTTON_TEXT_VARIABLE` (`actions.ts:5`) and declares `useVariables: { local: true }` (`:44`). That default embeds local `$(this:page)`, `$(this:row)`, `$(this:column)` tokens.

The callback resolves it with `self.parseVariablesInString(raw)` (`:88`). The instance-level `parseVariablesInString` has **no control context** (`controlId` is undefined), so `$(this:*)` / `$(local:*)` variables will **not** resolve. On the default marker path the resulting marker text will be wrong — an unresolved literal or empty — rather than the button's display text.

Per the v1.8 compliance rule, local variables resolve **only** through the action callback's second `context` argument.

**Suggested fix (maintainer):** change the callback signature to `async (event, context) => { ... }` and use `await context.parseVariablesInString(raw)` for both the button-text branch (`:88`) and the custom-text branch (`:91`). The `context` form also correctly tracks variable usage for global/custom variables.

### H2: yarn lint fails (no eslint configured)
**File:** `package.json`

The deterministic validator reports `yarn lint` failed. This is a direct consequence of the missing ESLint scaffolding — no `lint`/`lint:raw` scripts (C13/C14), no `eslint`/`typescript-eslint` devDependencies (C15/C19), and no `eslint.config.mjs` (C4). Restoring the template's lint toolchain resolves this; it is listed separately because lint is a required release gate.

---

## 🟡 Medium

### M1: WebSocket error handler never sets ConnectionFailure status
**File:** `src/connection.ts:79-82`

The `'error'` handler only logs and assumes the subsequent `'close'` event will drive status/reconnect. If `'close'` does not follow (e.g. certain handshake-phase errors), or status was `Connecting` when the error fired, the UI can sit on `Connecting` indefinitely.

**Suggested fix:** set `this.self.updateStatus(InstanceStatus.ConnectionFailure)` inside the `'error'` handler; the `'close'` handler's `onDisconnect()` still runs afterward.

### M2: No connect timeout or pong-liveness detection — half-open sockets drop sends silently
**File:** `src/connection.ts:51, 199-206`

`new WebSocket(url)` has no handshake timeout, and `startPing()` calls `ws.ping()` every 15s but never tracks whether a `'pong'` returns. A half-open TCP connection (peer hung, no FIN/RST) stays `readyState === OPEN`; `send()` then appears to succeed while messages are silently dropped, and the module keeps reporting `Ok`.

**Suggested fix:** record `'pong'` receipts and `this.ws.terminate()` + `scheduleReconnect()` if no pong arrives within ~2× `PING_INTERVAL`; optionally add a connect/handshake timeout that terminates and reconnects.

### M3: Fixed 5s reconnect with no backoff or cap
**File:** `src/connection.ts:191-197`

`scheduleReconnect()` retries every `RECONNECT_INTERVAL` (5s) indefinitely. When the server is down for an extended period this is constant churn.

**Suggested fix:** use exponential backoff (e.g. 1s → cap 30s), reset to the floor on a successful `'open'`.

### M4: send drops commands while disconnected but the action reports success
**File:** `src/connection.ts:90-96`

When `readyState !== OPEN`, `send()` logs a `warn` and discards the payload. The action callback has already resolved, so the operator sees the button "work" while nothing was sent — a meaningful silent failure for a live marker/camera-cut module.

**Suggested fix:** when not connected, surface the state (e.g. set a `last_error` variable and/or move status to `Disconnected`/`ConnectionFailure`), or queue critical commands. At minimum, document that commands are dropped while disconnected.

### M5: processResponse writes nested response fields without validation
**File:** `src/connection.ts:128-182`

The relay-format branches read `response.marker.timecode`, `response.marker.text`, `response.title.timecode`, etc. directly. A malformed payload (e.g. `marker: {}` with no `timecode`) sets variables to `undefined`, yielding blank values in Companion. (Note: a `null`/primitive top-level payload is harmless — `handleMessage`'s `try/catch` at `:103-125` catches it — so this is a data-quality issue, not a crash.)

**Suggested fix:** null-check nested fields before assignment, e.g. `response.marker?.timecode ?? ''`.

### M6: configUpdated reconnect relies on a single intentionalClose flag
**File:** `src/main.ts:37-41`, `src/connection.ts:33,40-88`

`configUpdated()` calls `disconnect()` then `connect()` synchronously. `cleanup()` correctly `removeAllListeners()` on the old socket, so stale callbacks won't fire — the common case is safe. However, `intentionalClose` is a single shared boolean with no per-socket association; during a rapid config-change or reconnect-timer-mid-execution burst the flag can transiently read the wrong value for a socket being torn down, opening a small duplicate-connection / spurious-reconnect window.

**Suggested fix:** tag each `WebSocket` with a generation/epoch counter and ignore events from non-current sockets, rather than relying on one `intentionalClose` flag.

### M7: Nested button-text variable uses a fragile two-stage expansion
**File:** `src/actions.ts:5`

`BUTTON_TEXT_VARIABLE = '$(internal:b_text_$(this:page)_$(this:row)_$(this:column))'` relies on Companion first resolving the inner `$(this:*)` tokens to build an `$(internal:b_text_<page>_<row>_<column>)` reference, then resolving that outer variable. `parseVariablesInString` performs a single resolution pass and does not generally re-parse its own output, so this two-stage form is fragile — and combined with H1 (using `self.`, so `$(this:*)` never resolves at all) this field is likely non-functional as written.

**Suggested fix:** resolve `$(this:page/row/column)` via `context` first, construct the `$(internal:b_text_...)` reference, then resolve it in a second explicit `context.parseVariablesInString()` call — and verify on a real button.

---

## 🟢 Low

### L1: Empty host produces an indefinite reconnect loop with no BadConfig status
**File:** `src/config.ts`, `src/connection.ts:44-56`

If the operator clears the host field, `connect()` builds `ws://:<port>`, the socket errors, and the module enters the 5s reconnect loop forever with only `error`-level logs — status never becomes `BadConfig`.

**Suggested fix:** validate `host`/`port` in `connect()`; when host is empty call `updateStatus(InstanceStatus.BadConfig)` and do **not** schedule a reconnect.

### L2: Teardown uses graceful close instead of terminate and is not awaited
**File:** `src/main.ts:32-35`, `src/connection.ts:223-229`

`destroy()` → `disconnect()` → `cleanup()` calls `ws.close()` (graceful close handshake), which can hang if the peer is unresponsive. `removeAllListeners()` + nulling prevents leaks/reconnect, so this is non-blocking, but on shutdown an immediate teardown is preferable.

**Suggested fix:** use `this.ws.terminate()` in `cleanup()`/`disconnect()` for immediate teardown.

### L3: destroy does not guard a partially-initialized connection
**File:** `src/main.ts:32-33`

`destroy()` calls `this.connection.disconnect()` unconditionally. `this.connection` is assigned early in `init()` (`:20`), so the window is small, but if `init()` ever threw before that line `destroy()` would throw `Cannot read properties of undefined`.

**Suggested fix:** `this.connection?.disconnect()`.

### L4: select_camera sends a camera number but reads camera_name back
**File:** `src/actions.ts` (select_camera), `src/connection.ts:152`

The action sends `{ command: 'select_camera', camera }` (a number) and the response handler updates `standby_camera` only from `response.camera_name` (a string). If the server omits `camera_name`, `standby_camera` is never updated even though the command was sent, so the operator sees a stale standby camera.

**Suggested fix:** confirm the server contract; optionally set `standby_camera` optimistically to the requested camera, or log when a `select_camera` response lacks `camera_name`.

### L5: Binary or fragmented frames are swallowed as parse warnings
**File:** `src/connection.ts:104`

`JSON.parse(data.toString())` is correctly try/caught, but `data` may be a `Buffer[]` (fragmented) whose `.toString()` yields comma-joined garbage that fails to parse and is logged as a generic parse warning. Low impact if the server is text-only.

**Suggested fix:** handle the array case (join buffers) or configure `ws` to deliver string frames.

### L6: colorToHex maps an invalid color to black silently
**File:** `src/actions.ts:102`

`colorToHex(Number(event.options.color) || 0)` turns an unset/NaN color into `#000000` with no warning, so an intended override could silently send black.

**Suggested fix:** fall back to the default blue (or log) when the color value is invalid.

### L7: Unhandled status ok responses have no diagnostic log
**File:** `src/connection.ts:119`

A native response with `status: 'ok'` but a `command` outside the handled set falls through `processResponse` doing nothing, with no `else`/debug log — making field troubleshooting harder if the server protocol drifts.

**Suggested fix:** add a `debug` log for unhandled `status: 'ok'` responses.

### L8: Hidden button_text field has an empty label
**File:** `src/actions.ts:42`

The hidden `button_text` field uses `label: ''`. It is hidden via `isVisibleExpression: 'false'`, so this is cosmetic, but a descriptive label (e.g. `'Button Text Source (hidden)'`) is preferable.

---

## 💡 Nice to Have

### N1: configUpdated reconnects even when host and port are unchanged
**File:** `src/main.ts:37-41`

`configUpdated()` always tears down and reconnects regardless of which field changed, causing an avoidable connection drop on any config edit.

**Suggested fix:** only reconnect when `host`/`port` actually changed.

### N2: type dropdown uses an empty-string default id
**File:** `src/actions.ts:56-66`

The marker `type` dropdown uses `default: ''` with a matching empty-string `'Default'` choice. Valid, but a sentinel id like `'default'` reads more clearly.

**Suggested fix:** optional — use an explicit sentinel id.

---

### Items checked and OK

- **Entry point / export shape** — `runEntrypoint(ModuleInstance, UpgradeScripts)` present (`main.ts:60`); `UpgradeScripts` exported as a typed empty array (`upgrades.ts`), correct for a first release with no migrations.
- **Variable consistency** — `setVariableDefinitions` runs before `setVariableValues`; every variable written in `connection.ts` (`connection_status`, `last_marker_timecode`, `last_marker_text`, `last_title_timecode`, `last_cut_timecode`, `last_fade_timecode`, `standby_camera`) is defined in `variables.ts`. IDs are valid snake_case.
- **Feedback consistency** — the single boolean feedback `connection_status` has a `defaultStyle`, no duplicate-invert option, is referenced via `checkFeedbacks('connection_status')`, and is defined.
- **Timers/listeners** — `reconnectTimer` and `pingTimer` are cleared in `cleanup()`/`stopPing()`; listeners removed via `removeAllListeners()`. No obvious leak.
- **JSON parsing** — inbound `JSON.parse` is wrapped in `try/catch` (`connection.ts:103-125`).
- **Expressions** — uses `isVisibleExpression` (v1.12+ idiom), not the deprecated `isVisible` function.
- **Manifest runtime** — `runtime.type` is `node22`; `permissions` empty and no privileged Node APIs used (`ws` only), so no permission declaration needed.
- **TypeScript build** — `npm run build` (tsc) compiles cleanly.

> No test framework, test files, or `test` script are present. Test coverage is **not required** for approval and is non-blocking — noted here for awareness only.
