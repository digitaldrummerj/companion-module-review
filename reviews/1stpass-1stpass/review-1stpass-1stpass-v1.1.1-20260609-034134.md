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
| 🔴 Critical | 21 |
| 🟠 High | 0 |
| 🟡 Medium | 0 |
| 🟢 Low | 2 |
| 💡 Nice to Have | 1 |
| 🔎 Findings That Need Your Review | 5 |
| **Total** | **29** |

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
- [ ] [C12: package.json missing required script build main](#c12-packagejson-missing-required-script-build-main)
- [ ] [C13: package.json missing required script lint: raw](#c13-packagejson-missing-required-script-lint-raw)
- [ ] [C14: package.json missing required script lint](#c14-packagejson-missing-required-script-lint)
- [ ] [C15: package.json missing devDependency eslint](#c15-packagejson-missing-devdependency-eslint)
- [ ] [C16: package.json missing devDependency husky](#c16-packagejson-missing-devdependency-husky)
- [ ] [C17: package.json missing devDependency lint-staged](#c17-packagejson-missing-devdependency-lint-staged)
- [ ] [C18: package.json missing devDependency prettier](#c18-packagejson-missing-devdependency-prettier)
- [ ] [C19: package.json missing devDependency typescript-eslint](#c19-packagejson-missing-devdependency-typescript-eslint)
- [ ] [C20: package.json missing lint-staged section](#c20-packagejson-missing-lint-staged-section)
- [ ] [C21: manifest id does not match name](#c21-manifest-id-does-not-match-name)

**Non-blocking**

- [ ] [L6: colorToHex maps an invalid color to black silently](#l6-colortohex-maps-an-invalid-color-to-black-silently)
- [ ] [L8: Hidden button_text field has an empty label](#l8-hidden-button_text-field-has-an-empty-label)
- [ ] [N2: type dropdown uses an empty-string default id](#n2-type-dropdown-uses-an-empty-string-default-id)

**Findings That Need Your Review**

- [ ] [F1: Button-text marker path resolves local variables with self instead of context](#f1-button-text-marker-path-resolves-local-variables-with-self-instead-of-context)
- [ ] [F2: No connect timeout or pong-liveness detection — half-open sockets drop sends silently](#f2-no-connect-timeout-or-pong-liveness-detection--half-open-sockets-drop-sends-silently)
- [ ] [F3: send drops commands while disconnected but the action reports success](#f3-send-drops-commands-while-disconnected-but-the-action-reports-success)
- [ ] [F4: Empty host produces an indefinite reconnect loop with no BadConfig status](#f4-empty-host-produces-an-indefinite-reconnect-loop-with-no-badconfig-status)
- [ ] [F5: select_camera sends a camera number but reads camera_name back](#f5-select_camera-sends-a-camera-number-but-reads-camera_name-back)

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

Required ESLint flat-config file is absent. Copy it from the template.

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

Missing `package` script — this is the command Companion uses to build the distributable (`companion-module-build`). Add it from the template.

### C12: package.json missing required script build main

**File:** `package.json`

Missing `build:main` script. Add it from the template.

### C13: package.json missing required script lint raw

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

---

## 🟢 Low

### L6: colorToHex maps an invalid color to black silently

**File:** `src/actions.ts:102`

`colorToHex(Number(event.options.color) || 0)` turns an unset/NaN color into `#000000` with no warning, so an intended override could silently send black.

**Suggested fix:** fall back to the default blue (or log) when the color value is invalid.

### L8: Hidden button_text field has an empty label

**File:** `src/actions.ts:42`

The hidden `button_text` field uses `label: ''`. It is hidden via `isVisibleExpression: 'false'`, so this is cosmetic, but a descriptive label (e.g. `'Button Text Source (hidden)'`) is preferable.

---

## 💡 Nice to Have

### N2: type dropdown uses an empty-string default id

**File:** `src/actions.ts:56-66`

The marker `type` dropdown uses `default: ''` with a matching empty-string `'Default'` choice. Valid, but a sentinel id like `'default'` reads more clearly.

**Suggested fix:** optional — use an explicit sentinel id.

---

## 🔎 Findings That Need Your Review

These are findings that the AI found but need you to review to see if they are valid and worth implementing.

### F1: Button-text marker path resolves local variables with self instead of context

**File:** `src/actions.ts:88` (also `:91`)

The `create_marker` action's default marker source is **"Button Text String"**, whose hidden `button_text` field defaults to `BUTTON_TEXT_VARIABLE` (`actions.ts:5`) and declares `useVariables: { local: true }` (`:44`). That default embeds local `$(this:page)`, `$(this:row)`, `$(this:column)` tokens.

The callback resolves it with `self.parseVariablesInString(raw)` (`:88`). The instance-level `parseVariablesInString` has **no control context** (`controlId` is undefined), so `$(this:*)` / `$(local:*)` variables will **not** resolve. On the default marker path the resulting marker text will be wrong — an unresolved literal or empty — rather than the button's display text.

Per the v1.8 compliance rule, local variables resolve **only** through the action callback's second `context` argument.

**Suggested fix (maintainer):** change the callback signature to `async (event, context) => { ... }` and use `await context.parseVariablesInString(raw)` for both the button-text branch (`:88`) and the custom-text branch (`:91`). The `context` form also correctly tracks variable usage for global/custom variables.

### F2: No connect timeout or pong-liveness detection — half-open sockets drop sends silently

**File:** `src/connection.ts:51, 199-206`

`new WebSocket(url)` has no handshake timeout, and `startPing()` calls `ws.ping()` every 15s but never tracks whether a `'pong'` returns. A half-open TCP connection (peer hung, no FIN/RST) stays `readyState === OPEN`; `send()` then appears to succeed while messages are silently dropped, and the module keeps reporting `Ok`.

**Suggested fix:** record `'pong'` receipts and `this.ws.terminate()` + `scheduleReconnect()` if no pong arrives within ~2× `PING_INTERVAL`; optionally add a connect/handshake timeout that terminates and reconnects.

### F3: send drops commands while disconnected but the action reports success

**File:** `src/connection.ts:90-96`

When `readyState !== OPEN`, `send()` logs a `warn` and discards the payload. The action callback has already resolved, so the operator sees the button "work" while nothing was sent — a meaningful silent failure for a live marker/camera-cut module.

**Suggested fix:** when not connected, surface the state (e.g. set a `last_error` variable and/or move status to `Disconnected`/`ConnectionFailure`), or queue critical commands. At minimum, document that commands are dropped while disconnected.

### F4: Empty host produces an indefinite reconnect loop with no BadConfig status

**File:** `src/config.ts`, `src/connection.ts:44-56`

If the operator clears the host field, `connect()` builds `ws://:<port>`, the socket errors, and the module enters the 5s reconnect loop forever with only `error`-level logs — status never becomes `BadConfig`.

**Suggested fix:** validate `host`/`port` in `connect()`; when host is empty call `updateStatus(InstanceStatus.BadConfig)` and do **not** schedule a reconnect.

### F5: select_camera sends a camera number but reads camera_name back

**File:** `src/actions.ts` (select_camera), `src/connection.ts:152`

The action sends `{ command: 'select_camera', camera }` (a number) and the response handler updates `standby_camera` only from `response.camera_name` (a string). If the server omits `camera_name`, `standby_camera` is never updated even though the command was sent, so the operator sees a stale standby camera.

**Suggested fix:** confirm the server contract; optionally set `standby_camera` optimistically to the requested camera, or log when a `select_camera` response lacks `camera_name`.

---
