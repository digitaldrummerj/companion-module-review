# Review: dmxcontrolprojects-dmxcontrol3 v1.2.0

| | |
|---|---|
| **Module** | dmxcontrolprojects-dmxcontrol3 |
| **Review tag** | v1.2.0 |
| **Previous tag** | v1.0.0 |
| **Scope** | `tag` (only the `v1.0.0..v1.2.0` diff; every code finding is new/regression) |
| **Language / API** | TypeScript · @companion-module/base v1 (`~1.12.0`) |
| **Transport** | gRPC (`@grpc/grpc-js`) over TCP, with UDP multicast discovery |
| **Build** | ✅ passes (`build` ran clean) |
| **Reviewed** | 2026-06-06 |

## Verdict: ❌ Changes Required

## 📋 Issues

**Blocking**

- [ ] [C2: Missing required file .gitattributes](#c2-missing-required-file-gitattributes)
- [ ] [C3: Missing required file eslint.config.mjs](#c3-missing-required-file-eslintconfigmjs)
- [ ] [C4: Missing required file .husky/pre-commit](#c4-missing-required-file-huskypre-commit)
- [ ] [C5: .gitignore missing required template entries](#c5-gitignore-missing-required-template-entries)
- [ ] [C7: tsconfig.json differs from template](#c7-tsconfigjson-differs-from-template)
- [ ] [C9: .vscode/launch.json is committed but the template gitignores it](#c9-vscodelaunchjson-is-committed-but-the-template-gitignores-it)
- [ ] [C10: package.json missing required field engines](#c10-packagejson-missing-required-field-engines)
- [ ] [C11: package.json missing required field prettier](#c11-packagejson-missing-required-field-prettier)
- [ ] [C12: package.json missing required script postinstall](#c12-packagejson-missing-required-script-postinstall)
- [ ] [C13: package.json missing required script build:main](#c13-packagejson-missing-required-script-build-main)
- [ ] [C14: package.json missing required script dev](#c14-packagejson-missing-required-script-dev)
- [ ] [C15: package.json missing required script lint:raw](#c15-packagejson-missing-required-script-lint-raw)
- [ ] [C16: package.json missing devDependency @types/node](#c16-packagejson-missing-devdependency-typesnode)
- [ ] [C17: package.json missing devDependency husky](#c17-packagejson-missing-devdependency-husky)
- [ ] [C18: package.json missing devDependency lint-staged](#c18-packagejson-missing-devdependency-lint-staged)
- [ ] [C19: package.json missing devDependency rimraf](#c19-packagejson-missing-devdependency-rimraf)
- [ ] [C20: package.json missing devDependency typescript-eslint](#c20-packagejson-missing-devdependency-typescript-eslint)
- [ ] [C21: package.json missing the lint-staged section](#c21-packagejson-missing-the-lint-staged-section)
- [ ] [C22: manifest.json id does not match name](#c22-manifestjson-id-does-not-match-name)
- [ ] [H1: Set Macro Fader action reads a non-existent step option and never runs](#h1-set-macro-fader-action-reads-a-non-existent-step-option-and-never-runs)
- [ ] [H2: UserClientClient channel opened at login is never closed](#h2-userclientclient-channel-opened-at-login-is-never-closed)
- [ ] [H3: Cuelist progress stream has no error handler and can crash the instance](#h3-cuelist-progress-stream-has-no-error-handler-and-can-crash-the-instance)

**Non-blocking**

- [ ] [M1: No deadlines on any gRPC calls](#m1-no-deadlines-on-any-grpc-calls)
- [ ] [M2: Reconnect path leaks the UDP discovery socket](#m2-reconnect-path-leaks-the-udp-discovery-socket)
- [ ] [M3: gRPC failure paths swallow errors without updating InstanceStatus](#m3-grpc-failure-paths-swallow-errors-without-updating-instancestatus)
- [ ] [M7: Macro and executor ID fields do not resolve variables](#m7-macro-and-executor-id-fields-do-not-resolve-variables)
- [ ] [L3: UserClient is dead code with throwing stubs](#l3-userclient-is-dead-code-with-throwing-stubs)

---

## 🔴 Critical

### C2: Missing required file .gitattributes

`.gitattributes` — required template file is missing. **Fix:** copy `.gitattributes` from `companion-module-template-ts-v1`.

### C3: Missing required file eslint.config.mjs

`eslint.config.mjs` — required template file is missing (the repo still ships an `eslint.config.cjs`). **Fix:** adopt the template's `eslint.config.mjs` (and the `typescript-eslint` flat-config it expects, see C20).

Please sync up the eslint configuration to match the repository template.  You are using different eslint dependencies.  There is also a default eslint configuration for Companion. The v1 module template is at [https://github.com/bitfocus/companion-module-template-ts/tree/42609d8dab515a25ec2f3b3c7adafe57aa41b7be](https://github.com/bitfocus/companion-module-template-ts/tree/42609d8dab515a25ec2f3b3c7adafe57aa41b7be)

### C4: Missing required file .husky/pre-commit

`.husky/pre-commit` — required template file is missing. **Fix:** add the template's husky pre-commit hook (depends on the `husky` devDependency and `postinstall` script, C12/C17).

### C5: .gitignore missing required template entries

`.gitignore` — missing template entries: `package-lock.json`, `/pkg`, `/*.tgz`, `/dist`, `DEBUG-*`, `/.yarn`, `/.vscode`. **Fix:** add the missing lines so build artifacts, packaged output, and editor/yarn dirs are ignored.

### C7: tsconfig.json differs from template

The project's tsconfig does not follow the template's extend-from-build layout. **Fix:** adopt the template `tsconfig.json` structure.

### C9: .vscode/launch.json is committed but the template gitignores it

`.vscode/launch.json` — committed this release, but the template `.gitignore` excludes `/.vscode`. **Fix:** remove `.vscode/` from version control and add the ignore entry (C5).

### C10: package.json missing required field engines

`package.json` — required `engines` field (present in template) is missing. **Fix:** add the template's `engines` block (Node 22).

### C11: package.json missing required field prettier

`package.json` — required `prettier` field (present in template) is missing. **Fix:** add the template's `prettier` config key.

### C12: package.json missing required script postinstall

`package.json` — required `postinstall` script is missing (husky install). **Fix:** add the template `postinstall` script.

### C13: package.json missing required script build main

`package.json` — required `build:main` script is missing. **Fix:** add the template `build:main` script.

### C14: package.json missing required script dev

`package.json` — required `dev` script is missing. **Fix:** add the template `dev` script.

### C15: package.json missing required script lint raw

`package.json` — required `lint:raw` script is missing. **Fix:** add the template `lint:raw` script.

### C16: package.json missing devDependency @types/node

`package.json` — `@types/node` (present in template) is missing from devDependencies. **Fix:** add it.

### C17: package.json missing devDependency husky

`package.json` — `husky` (present in template) is missing from devDependencies. **Fix:** add it (pairs with C4/C12).

### C18: package.json missing devDependency lint-staged

`package.json` — `lint-staged` (present in template) is missing from devDependencies. **Fix:** add it (pairs with C21).

### C19: package.json missing devDependency rimraf

`package.json` — `rimraf` (present in template) is missing from devDependencies. **Fix:** add it.

### C20: package.json missing devDependency typescript-eslint

`package.json` — `typescript-eslint` (present in template) is missing from devDependencies. **Fix:** add it (required by the flat `eslint.config.mjs`, C3).

### C21: package.json missing the lint-staged section

`package.json` — the `lint-staged` config section (present in template) is missing. **Fix:** add the template `lint-staged` block.

### C22: manifest.json id does not match name

`companion/manifest.json` — `id` is `dmxcontrolprojects-dmxcontrol3` but `name` is `DMXControl Projects e.V. - DMXControl 3`. In the Companion manifest, `name` is expected to equal the short `id`; the human-readable label belongs in the `manufacturer` / `products` / `shortname` fields. **Fix:** set `name` to `dmxcontrolprojects-dmxcontrol3` and keep the display text in the appropriate fields.

---

## 🟠 High

### H1: Set Macro Fader action reads a non-existent step option and never runs

`src/grpc/macroclient.ts:343-401` (`MacroActions.SetFaderAbsolute`, "Set Macro Fader")

The action defines option ids `value`, `num`, `id`, but the callback guards on and reads a non-existent `step` option:

- `macroclient.ts:371` — `typeof event.options.step !== "number"` is always true (no `step` option exists), so the callback always returns early and the action does nothing.
- `macroclient.ts:386` — `request.absolut = event.options.step / 100;` would use the wrong option even if reached.

The "Set Macro Fader" action is non-functional as shipped.

**Fix (maintainer):** change the guard to `typeof event.options.value !== "number"` and set `request.absolut = event.options.value / 100;`.

### H2: UserClientClient channel opened at login is never closed

`src/grpc/grpcclient.ts:201`

`login()` does `new UserClientClient(this.endpoint, ...).bind(...)` inline. The client is never assigned to a field, never pushed into `this.clients`, and never `.close()`d. Every `init()` / discovery / reconnect cycle (including every `errorhandler()` retry) leaks a gRPC channel, accumulating for the life of the process.

**Fix (maintainer):** assign the `UserClientClient` to a field and `.close()` it in `GRPCClient.destroy()`, or wire up the existing `UserClient` wrapper (currently dead code, L3) and push it into `this.clients` so the existing `clients.forEach(c => c.close())` in `destroy()` cleans it up.

### H3: Cuelist progress stream has no error handler and can crash the instance

`src/grpc/cuelistclient.ts:347-367`

`receiveCuelistProgressChanges` registers only `'data'` and `'close'` handlers. A gRPC stream that emits `'error'` with no listener throws an unhandled `'error'` event — a process-level crash in Node. The sibling `changeStream` (line 318) and the ping stream in `grpcclient.ts:182` both have error handlers; this one was missed.

**Fix (maintainer):** add `this.progressStream.on("error", (err) => this.instance.log("error", "cuelist progress stream: " + err.message))`, and treat an error as a trigger for the same guarded reopen used in the `'close'` handler (with backoff, H4).

---

## 🟡 Medium

### M1: No deadlines on any gRPC calls

Throughout `src/grpc/*.ts` — `login`, `reportReadyToWork`, `getExecutors`/`getMacros`/`getCuelists`, `setCuelistValue`, `cuelistAction`, etc. are invoked with no `deadline` in their call options. A hung server leaves these calls (and the promises wrapping them in cuelistclient) pending indefinitely, and `InstanceStatus` never moves off `Ok`/`Connecting`. The discovery path (`src/utils.ts:83`) likewise never times out if no broadcast arrives.

**Fix (maintainer):** pass `{ deadline: Date.now() + N }` on unary RPCs and surface timeout as `InstanceStatus.ConnectionFailure`; add a discovery timeout that sets a status if no matching `netid` is found.

### M2: Reconnect path leaks the UDP discovery socket

`src/main.ts:69-87` (with `src/utils.ts:35-38`)

On error, `errorhandler` destroys the gRPC client and then calls `startDiscovery` again, reassigning `this.socket` without closing the previous discovery socket first. In `startDiscovery` the UDP socket only self-closes on its own `'error'` event, not when a new discovery is started. Repeated error/reconnect cycles can bind multiple sockets and leak prior ones. (The `init()` and success paths do close the socket via `client.close()` inside `startDiscovery`; the error-retry path bypasses that.)

**Fix (maintainer):** close `this.socket` before calling `startDiscovery` again, and guard against overlapping discovery restarts.

### M3: gRPC failure paths swallow errors without updating InstanceStatus

`grpcclient.ts:154,217,263-267`; `executorclient.ts:67,116`; `macroclient.ts:68,122`; `cuelistclient.ts:318-323`

Login error, user-bind error, the `receive*Changes` stream errors, the `getExecutors`/`getMacros` errors, and the client-construction `catch` all `log(...)` and return without ever calling `updateStatus(InstanceStatus.ConnectionFailure/Disconnected)`. (`reportReadyToWork`'s error at `grpcclient.ts:169` does call `onError()` — good — but the others do not.) The operator sees the instance as "OK"/"Connecting" while it is actually half-broken.

**Fix (maintainer):** call `this.instance.updateStatus(...)` in each failure path, mirroring the `onError()` pattern already used in `login`; ideally drive status from a single connection-health view so partial failures downgrade it.

### M7: Macro and executor ID fields do not resolve variables

`src/grpc/macroclient.ts` & `src/grpc/executorclient.ts` — the "ID or Name" textinput options (e.g. `macroclient.ts:139-143, 188-192, 245-249, 303-307, 362-366, 452-456, 483-487, 514-518, 537-541`; `executorclient.ts:133-137, 197-201`, etc.)

These textinputs have neither a `default` nor `useVariables`, and their callbacks call `this.repo.getSingle(event.options.id)` directly without `ctx.parseVariablesInString`. So a user typing a `$(...)` variable into the field won't have it resolved (it silently fails to match), and the missing `default` is a structural inconsistency. The newer cuelist client solves this correctly via `generateIdOption` + `checkAndGetIdOption` with `useVariables: { local: true }`.

**Fix (maintainer):** migrate macro/executor id selection to the cuelist client's `generateIdOption`/`checkAndGetIdOption` pattern, or at minimum add `default: ""` and parse with `ctx.parseVariablesInString`.

---

## 🟢 Low

### L3: UserClient is dead code with throwing stubs

`src/grpc/userclient.ts`

`UserClient` implements `IDMXCClient` but is never instantiated; `startClient`/`generate*` all `throw new Error("Method not implemented.")`. Harmless today, but if it's ever pushed into `this.clients`, the `clients.forEach(c => c.startClient(...))` loop (`grpcclient.ts:253`) and `generateActions()` etc. will throw. Its constructor also opens a `UserClientClient` channel — relevant if adopted to fix H2.

**Fix (maintainer):** either wire it up properly (and use it to own the leaked channel from H2) or delete the file.

---
