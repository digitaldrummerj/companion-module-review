# Review — companion-module-dashmaster-2k v1.0.0

| | |
|---|---|
| **Module** | dashmaster-2k |
| **Review tag** | v1.0.0 |
| **Previous tag** | (none — first release) |
| **Scope** | `tag` |
| **Language / API** | JavaScript (ESM) · @companion-module/base ~2.0.4 (v2) |
| **Protocols** | HTTP / REST (`got`) |
| **Reviewed** | 2026-06-06 |

> **Scope note:** Requested scope was `tag`, but this is the **first release** (no previous tag, no diff), so it falls back to a **full-module review**. Every finding is classified 🆕 NEW.
>
> **Methodology note (template selection):** The module is JavaScript-ESM (`"type": "module"`, all `.js`, no `tsconfig.json`/TypeScript deps). The deterministic validator's auto-detection initially matched the **TS** template (its `"type":"module" ⇒ TS` heuristic misfires on JS-ESM modules), which produced spurious findings (tsconfig/eslint/husky/`src/main.ts`/`dist/main.js`/build+lint scripts). Those were **discarded**; all template findings below were re-validated against the correct **`companion-module-template-js`**. TS-only requirements do **not** apply to this module.

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 5 | 0 | 5 |
| 🟠 High | 0 | 0 | 0 |
| 🟡 Medium | 2 | 0 | 2 |
| 🟢 Low | 2 | 0 | 2 |
| 💡 Nice to Have | 0 | 0 | 0 |
| **Total** | **9** | **0** | **9** |

## Verdict: ❌ Changes Required

## 📋 Issues

**Blocking**

- [ ] [C1: yarn package build fails — .yarnrc.yml missing (Yarn PnP not supported)](#c1-yarn-package-build-fails--yarnrcyml-missing-yarn-pnp-not-supported)
- [ ] [C2: yarn install --immutable fails — no committed yarn.lock](#c2-yarn-install---immutable-fails--no-committed-yarnlock)
- [ ] [C4: isVisible callbacks removed in v2.x — must use isVisibleExpression](#c4-isvisible-callbacks-removed-in-v2x--must-use-isvisibleexpression)
- [ ] [C6: package.json missing required engines field](#c6-packagejson-missing-required-engines-field)
- [ ] [C7: Template dotfile parity — .gitignore, .gitattributes, .prettierignore](#c7-template-dotfile-parity--gitignore-gitattributes-prettierignore)

**Non-blocking**

- [ ] [M1: No request timeout on any got call](#m1-no-request-timeout-on-any-got-call)
- [ ] [M2: Polling concurrency — configUpdated does not restart polling and races with in-flight refresh](#m2-polling-concurrency--configupdated-does-not-restart-polling-and-races-with-in-flight-refresh)
- [ ] [L1: Error classification only special-cases 401](#l1-error-classification-only-special-cases-401)
- [ ] [L2: Poll errors swallowed with empty catch](#l2-poll-errors-swallowed-with-empty-catch)

---

## 🔴 Critical

### C1: yarn package build fails — .yarnrc.yml missing (Yarn PnP not supported)

**Classification:** 🆕 NEW · **File:** `.yarnrc.yml` (missing) → `package.json` `package` script

`yarn package` aborts with:

```
❌ Error: Yarn PnP (Plug'n'Play) is not supported.
   The companion module build process requires a traditional node_modules structure.
   Please add "nodeLinker: node-modules" to your .yarnrc.yml file and run "yarn install".
```

The repo has no `.yarnrc.yml`, so Yarn 4 defaults to PnP, which `companion-module-build` rejects. The release artifact cannot be built.

**Fix (maintainer):** Add a `.yarnrc.yml` matching the JS template:

```yaml
nodeLinker: node-modules
```

Then `yarn install` to regenerate the linker layout, and commit `.yarnrc.yml`.

### C2: yarn install --immutable fails — no committed yarn.lock

**Classification:** 🆕 NEW · **File:** `yarn.lock` (missing)

`yarn install --immutable` (the CI / packaging install mode) fails:

```
➤ YN0028: · The lockfile would have been created by this install, which is explicitly forbidden.
```

`yarn.lock` is not committed (the last commit removed `package-lock.json` but no `yarn.lock` replaced it). Without it, immutable installs — and therefore the Companion build pipeline — fail.

**Fix (maintainer):** Run `yarn install` (after adding the `.yarnrc.yml` from C1) and commit the generated `yarn.lock`.  Also, remove the .yarn folder from git.

### C4: isVisible callbacks removed in v2.x — must use isVisibleExpression

**Classification:** 🆕 NEW · **File:** `src/actions.js:163, 171`

The `generic_http` action's `contentType` and `body` options use the function form `isVisible: (opts) => opts.method !== 'GET'`. The `isVisible` function on option fields was **removed in v2.x** and no longer works; field visibility must be expressed with `isVisibleExpression`.

See [https://companion.free/for-developers/module-development/api-changes/v2.0#referencing-expressions-from-isvisibleexpression](https://companion.free/for-developers/module-development/api-changes/v2.0#referencing-expressions-from-isvisibleexpression)

**Fix (maintainer):** Replace both with an expression, e.g.:

```js
isVisibleExpression: '$(options:method) != "GET"',
```

### C6: package.json missing required engines field

**Classification:** 🆕 NEW · **File:** `package.json`

The `engines` field is absent. The JS template requires it:

```json
"engines": {
  "node": "^22.20",
  "yarn": "^4"
}
```

**Fix (maintainer):** Add the `engines` block (match the template's current values).

### C7: Template dotfile parity — .gitignore, .gitattributes, .prettierignore

**Classification:** 🆕 NEW · **Files:** `.gitignore`, `.gitattributes`, `.prettierignore`

Three repo dotfiles diverge from the official JS template:

- **`.gitignore`** — missing required entries: `node_modules/`, `package-lock.json`, `/pkg`, `/*.tgz`, `DEBUG-*`, `/.yarn`.
- **`.gitattributes`** — line 1 is `# Auto detect text files and perform LF normalization`; template is `* text=auto eol=lf`.
- **`.prettierignore`** — line 1 is `node_modules`; template is `package.json`.

**Fix (maintainer):** Align all three with `companion-module-template-js` (copy the template versions, then re-add any module-specific extra entries on top — extra entries are fine, missing template entries are not).

---

## 🟡 Medium

### M1: No request timeout on any got call

**Classification:** 🆕 NEW · **File:** `src/api.js:32, 114`

Both `request()` and `genericRequest()` set `retry: { limit: 0 }` but never set `timeout`. `got` has no default total timeout, so a server that accepts the connection but never responds leaves the promise pending forever — a hung poll or a hung operator-triggered Generic HTTP request never settles.

**Fix (maintainer):** Add an explicit timeout to both `got` option objects, e.g. `timeout: { request: 15000 }` (or `{ connect: 5000, response: 10000 }`).

### M2: Polling concurrency — configUpdated does not restart polling and races with in-flight refresh

**Classification:** 🆕 NEW · **File:** `src/index.js:49-52, 107-112`

`configUpdated()` calls `refreshLists()` but never `stopPolling()`/`startPolling()`, and there is no in-flight guard anywhere. Combined with the timer-based `setInterval` (which fires every 60s regardless of whether the previous run finished — especially with no timeout, see M1), multiple `refreshLists()` cycles can overlap. Each writes `this.dashboards`/`this.devices` and rebuilds definitions, so a slow/stale response can clobber a newer one after a config change.

**Fix (maintainer):** In `configUpdated()`, `stopPolling()` before refreshing and `startPolling()` after (mirroring `init`'s teardown→setup). Add an in-flight flag (or re-arm with `setTimeout` after each refresh settles instead of fixed-rate `setInterval`) and discard stale results via a generation counter. Optionally set `InstanceStatus.Connecting` at the top of `configUpdated()` for clearer UX.

---

## 🟢 Low

### L1: Error classification only special-cases 401

**Classification:** 🆕 NEW · **File:** `src/index.js:96`

`refreshLists()` maps `statusCode === 401` → "Invalid API token" and everything else → `ConnectionFailure` with the raw message. A 403 (valid token, insufficient scope) reads as a generic ConnectionFailure, and DNS/`ECONNREFUSED` errors surface raw `got` messages.

**Fix (maintainer):** Treat 401/403 as `BadConfig` ("Invalid or unauthorized API token") and network-level errors (`err.code` of `ENOTFOUND`/`ECONNREFUSED`/timeout) as `ConnectionFailure` with a friendlier message.

### L2: Poll errors swallowed with empty catch

**Classification:** 🆕 NEW · **File:** `src/index.js:110`

`this.refreshLists().catch(() => {})` discards rejections silently. `refreshLists` sets status/logs in its own `catch`, so this is mostly defensive, but anything thrown outside that inner `try` vanishes with no trace.

**Fix (maintainer):** Log in the handler: `.catch((e) => this.log('debug', \`poll failed: ${e?.message}\`))`.
