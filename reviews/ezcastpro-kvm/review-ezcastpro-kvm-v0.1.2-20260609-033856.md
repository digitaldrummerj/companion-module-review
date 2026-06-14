# Review — ezcastpro-kvm v0.1.2

| | |
|---|---|
| **Module** | ezcastpro-kvm (EZCast Pro AM8270 KVM) |
| **Review tag** | v0.1.2 |
| **Previous tag** | (none — first release) |
| **Scope** | `tag` |
| **Language / API** | TypeScript · @companion-module/base ~1.14.1 (v1.x) |
| **Protocols** | HTTP (JSON-RPC over `node:http`) |
| **Build / Lint** | ✅ `tsc` clean · ✅ `eslint` clean |

> **First release** — there is no `previousTag..reviewTag` diff, so `tag` scope falls back to a **full review** of the whole module. Every finding is NEW.

## 📊 Scorecard

| Severity | Count |
|---|---|
| 🔴 Critical | 15 |
| 🟠 High | 1 |
| 🟡 Medium | 1 |
| 🔎 Findings That Need Your Review | 7 |

All 15 Critical findings are deterministic template/manifest/packaging gaps (Step-4 validator). The 1 High finding is a correctness/robustness issue in the lifecycle code.

## Verdict

❌ **Changes Required** — 16 blocking (15 Critical + 1 High).

## 📋 Issues

**Blocking**

- [ ] [C1: .yarnrc.yml missing](#c1-yarnrcyml-missing)
- [ ] [C2: .husky/pre-commit missing](#c2-huskypre-commit-missing)
- [ ] [C3: .gitignore missing template entries](#c3-gitignore-missing-template-entries)
- [ ] [C4: eslint.config.mjs differs from template](#c4-eslintconfigmjs-differs-from-template)
- [ ] [C5: tsconfig.json differs from template](#c5-tsconfigjson-differs-from-template)
- [ ] [C6: tsconfig.build.json differs from template](#c6-tsconfigbuildjson-differs-from-template)
- [ ] [C7: package.json missing field packageManager](#c7-packagejson-missing-field-packagemanager)
- [ ] [C8: package.json missing script postinstall](#c8-packagejson-missing-script-postinstall)
- [ ] [C9: package.json missing script build:main](#c9-packagejson-missing-script-build-main)
- [ ] [C10: package.json missing script lint:raw](#c10-packagejson-missing-script-lint-raw)
- [ ] [C11: package.json missing devDependency husky](#c11-packagejson-missing-devdependency-husky)
- [ ] [C12: package.json missing devDependency lint-staged](#c12-packagejson-missing-devdependency-lint-staged)
- [ ] [C13: package.json missing lint-staged section](#c13-packagejson-missing-lint-staged-section)
- [ ] [C14: manifest.json keyword EZCastPro](#c14-manifestjson-keyword-ezcastpro)
- [ ] [C15: manifest.json keyword ezcastpro-kvm](#c15-manifestjson-keyword-ezcastpro-kvm)
- [ ] [H3: destroy() does not stop in-flight work or the pending settle timer](#h3-destroy-does-not-stop-in-flight-work-or-the-pending-settle-timer)

**Non-blocking**

- [ ] [M6: Redundant parseVariablesInString on auto-parsed textinput fields](#m6-redundant-parsevariablesinstring-on-auto-parsed-textinput-fields)

**Findings that need your review**

- [ ] [F1: setChannel relies on a fixed 300 ms settle before refresh](#f1-setchannel-relies-on-a-fixed-300-ms-settle-before-refresh)
- [ ] [F2: Discovery runs synchronously inside the connect path and re-scans on every config save](#f2-discovery-runs-synchronously-inside-the-connect-path-and-re-scans-on-every-config-save)
- [ ] [F3: Response body is buffered with no size cap](#f3-response-body-is-buffered-with-no-size-cap)
- [ ] [F4: Dead legacy rxHost config fallback](#f4-dead-legacy-rxhost-config-fallback)
- [ ] [F5: No in-flight guard on polling — requests can stack](#f5-no-in-flight-guard-on-polling--requests-can-stack)
- [ ] [F6: HTTP status code is never checked](#f6-http-status-code-is-never-checked)
- [ ] [F7: discover() swallows errors without updating status](#f7-discover-swallows-errors-without-updating-status)

---

## 🔴 Critical

The module does not match the official `companion-module-template-ts-v1` and is missing required packaging/tooling. Each item below blocks release.

### C1: .yarnrc.yml missing

Required template file absent. Add the template's `.yarnrc.yml` (the module ships a `yarn.lock` but no yarn config).

### C2: .husky/pre-commit missing

Required template file absent. Add the husky pre-commit hook from the template.

### C3: .gitignore missing template entries

`.gitignore:1` — missing template entries: `/pkg`, `/*.tgz`, `/dist`, `DEBUG-*`, `/.yarn`, `/.vscode`. Add them. (Note: `pkg/` and `ezcastpro-kvm-0.1.2.tgz` are currently committed in the repo — they should be ignored and removed from version control.)

### C4: eslint.config.mjs differs from template

`eslint.config.mjs:3` — found `export default await generateEslintConfig({ enableTypescript: true })`; template is `export default generateEslintConfig({ ... })`. Align with the template's eslint config.

### C5: tsconfig.json differs from template

`tsconfig.json:2` — `extends` points at `@companion-module/tools/tsconfig/node22/recommended-esm`; template extends `./tsconfig.build.json`. Restore the template's tsconfig layering.

### C6: tsconfig.build.json differs from template

`tsconfig.build.json:2` — `extends` points at `./tsconfig.json`; template extends `@companion-module/tools/tsconfig/node22/recommended`. Restore the template's tsconfig layering.

### C7: package.json missing field packageManager

Add the `packageManager` field (present in template; pins the Yarn version).

### C8: package.json missing script postinstall

Add it from the template.

### C9: package.json missing script build main

Add it from the template.

### C10: package.json missing script lint raw

Add it from the template.

### C11: package.json missing devDependency husky

Add it (pairs with the `.husky/pre-commit` hook above).

### C12: package.json missing devDependency lint-staged

Add it.

### C13: package.json missing lint-staged section

Add the template's `lint-staged` config block.

### C14: manifest.json keyword EZCastPro

`companion/manifest.json` — banned/low-value keyword `EZCastPro`. Remove it from `keywords`.

### C15: manifest.json keyword ezcastpro-kvm

`companion/manifest.json` — banned/low-value keyword `ezcastpro-kvm`. Remove the module-id keyword.

## 🟠 High

### H3: destroy() does not stop in-flight work or the pending settle timer

`src/main.ts:73-76` — `destroy()` only calls `stopPolling()`. The `setChannel` path schedules a bare `setTimeout` (`main.ts:298`) that is never tracked and cannot be cleared, and in-flight HTTP requests / `refreshStatus()` promises keep running after destroy, calling `updateStatus` / `setVariableValues` / `checkFeedbacks` on a torn-down instance. After `configUpdated` or `destroy` this produces "called after destroy" noise and stale status writes.
**Fix (maintainer):** set a `destroyed` flag in `destroy()` and guard `refreshStatus` / `updateVariables` / `checkFeedbacks` against it; store the settle `setTimeout` handle so it can be cleared. (The poll-timer handling itself is correct.)

## 🟡 Medium

### M6: Redundant parseVariablesInString on auto-parsed textinput fields

`src/actions.ts:46,76,107,109,150,152` (and the equivalent in `main.ts`) — under v1.13+ (this module is ~1.14.1), variables in `textinput` fields that declare `useVariables: true` are auto-parsed before the callback runs, so `action.options.*` already holds resolved values. The explicit `self.parseVariablesInString(...)` calls are no-ops on already-resolved strings — they work but are confusing.
**Fix (maintainer):** read the option directly (e.g. `String(action.options.channel ?? '')`) and drop the `await self.parseVariablesInString(...)` wrapper. None of these fields use `$(local:*)` / `$(this:*)`, so no `context.parseVariablesInString` is needed.

## 🔎 Findings That Need Your Review

These are findings that the AI found but need you to review to see if they are valid and worth implementing.

### F1: setChannel relies on a fixed 300 ms settle before refresh

`src/main.ts:289-298` — after `setReceiverChannel`, the code waits a hardcoded `setTimeout(resolve, 300)` then calls `refreshStatus`. If the device hasn't applied the change within 300 ms, `rxInfo.channelId` (and the `active_channel` feedback) reflects the stale channel until the next poll. The 300 ms is an undocumented guess.
**Fix (maintainer):** re-fetch in a short retry loop until `channelId` matches the requested value (with a timeout), or document that feedback settles on the next poll. Add a comment explaining the device-settle rationale if the delay stays.

### F2: Discovery runs synchronously inside the connect path and re-scans on every config save

`src/main.ts:219` — `start()` awaits `this.discover()` when `autoDiscover` or `rxSelectionMode === 'discovered'` is set, before status is reported. The 64-way subnet scan delays the instance becoming ready and re-runs on every `configUpdated()`.
**Fix (maintainer):** run startup discovery in the background (don't `await` it inside the connect path), and/or debounce discovery so a config save doesn't immediately re-scan.

### F3: Response body is buffered with no size cap

`src/protocol.ts:94-109` — `cmsCall` accumulates every `res.on('data')` chunk with no limit. Because discovery hits every host on the subnet, a misbehaving or hostile host could stream a large body and grow memory until the request timeout fires (the timeout fires on socket inactivity, not on a slow steady stream).
**Fix (maintainer):** track accumulated length and `req.destroy()` once it exceeds a sane cap (e.g. 256 KB–1 MB).

### F4: Dead legacy rxHost config fallback

`src/main.ts:138` / `src/config.ts:8` — `getEffectiveRxHost` reads `this.config.rxHost` and `rxHost` is typed in `ModuleConfig`, but it is never defined in `getConfigFields()` (only `manualRxHost` and `discoveredRxHost` are real fields), and `UpgradeScripts` is empty. `rxHost` is effectively always `undefined`.
**Fix (maintainer):** remove the dead `rxHost` fallback (and its type), or add a real config field / upgrade script if it was intended.

### F5: No in-flight guard on polling — requests can stack

`src/main.ts:237-238` — `startPolling` fires `void this.refreshStatus()` on a fixed `setInterval`. If a device is slow and a request approaches `requestTimeoutMs` while the poll interval is short, multiple `refreshStatus` calls overlap, each issuing its own HTTP request and racing to write `this.rxInfo` / status.
**Fix (maintainer):** track an in-flight flag, or use a self-rescheduling `setTimeout` that schedules the next poll only after the current one resolves, so at most one `refreshStatus` runs at a time.

### F6: HTTP status code is never checked

`src/protocol.ts:94-109` (`cmsCall`) — the body is parsed regardless of `res.statusCode`. A `401`/`403` (wrong/missing admin password on `set_*` calls) or a `404`/`500` HTML error page is treated as "not JSON" and surfaces as a generic `Invalid CMS response` parse error rather than an auth/HTTP failure.
**Fix (maintainer):** check `res.statusCode` in the `end` handler and reject with a status-specific message (especially distinguishing auth failures) before attempting `JSON.parse`.

### F7: discover() swallows errors without updating status

`src/main.ts:266-282` — the `catch` sets `lastError` but leaves `InstanceStatus` untouched, so a discovery failure (e.g. network unreachable) is invisible in the connection indicator. When discovery is the RX-selection source, a silent failure leads to an empty effective RX host and a later `BadConfig`, masking the real cause.
**Fix (maintainer):** on discovery failure set an appropriate `InstanceStatus` (or at least `this.log('warn', ...)`) so the failure is observable.
