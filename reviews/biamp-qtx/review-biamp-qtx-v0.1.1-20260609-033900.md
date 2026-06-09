# Review: biamp-qtx v0.1.1

| | |
|---|---|
| **Module** | biamp-qtx (Qt X — Biamp sound masking) |
| **Review tag** | v0.1.1 |
| **Previous tag** | (none — first release) |
| **Scope** | tag |
| **Language** | TypeScript |
| **API** | @companion-module/base v1.x (`~1.14.1`) |
| **Transport** | HTTP/HTTPS REST (`/api/v1/Config`) |
| **Reviewed** | 2026-06-09 |

> **First release:** there is no `previousTag..reviewTag` diff, so the `tag` scope falls back to a **full review** of the whole `src/`. Every finding is NEW.

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 14 | 0 | 14 |
| 🟠 High | 3 | 0 | 3 |
| 🟡 Medium | 7 | 0 | 7 |
| 🟢 Low | 5 | 0 | 5 |
| 💡 Nice to Have | 5 | 0 | 5 |
| **Total** | **34** | **0** | **34** |

## Verdict: ❌ Changes Required

## 📋 Issues

**Blocking**
- [ ] [C1: LICENSE file missing](#c1-license-file-missing)
- [ ] [C2: .gitattributes file missing](#c2-gitattributes-file-missing)
- [ ] [C3: .husky/pre-commit hook missing](#c3-huskypre-commit-hook-missing)
- [ ] [C4: .gitignore missing required template entries](#c4-gitignore-missing-required-template-entries)
- [ ] [C5: .prettierignore differs from template](#c5-prettierignore-differs-from-template)
- [ ] [C6: eslint.config.mjs differs from template](#c6-eslintconfigmjs-differs-from-template)
- [ ] [C7: tsconfig.json differs from template](#c7-tsconfigjson-differs-from-template)
- [ ] [C8: tsconfig.build.json differs from template](#c8-tsconfigbuildjson-differs-from-template)
- [ ] [C9: package.json missing required script postinstall](#c9-packagejson-missing-required-script-postinstall)
- [ ] [C10: package.json missing required script lintraw](#c10-packagejson-missing-required-script-lintraw)
- [ ] [C11: package.json missing devDependency husky](#c11-packagejson-missing-devdependency-husky)
- [ ] [C12: package.json missing devDependency lint-staged](#c12-packagejson-missing-devdependency-lint-staged)
- [ ] [C13: package.json missing lint-staged section](#c13-packagejson-missing-lint-staged-section)
- [ ] [C14: manifest id does not match name](#c14-manifest-id-does-not-match-name)
- [ ] [H1: makeZoneUpdateBody corrupts masking state on mute/unmute](#h1-makezoneupdatebody-corrupts-masking-state-on-muteunmute)
- [ ] [H2: Unserialized read-modify-write causes lost updates on rapid actions](#h2-unserialized-read-modify-write-causes-lost-updates-on-rapid-actions)
- [ ] [H3: Feedbacks use self.parseVariablesInString and go stale](#h3-feedbacks-use-selfparsevariablesinstring-and-go-stale)

**Non-blocking**
- [ ] [M1: Write-action callbacks lack try/catch — failures leave status Ok](#m1-write-action-callbacks-lack-trycatch--failures-leave-status-ok)
- [ ] [M2: destroy() does not reset status or clear state](#m2-destroy-does-not-reset-status-or-clear-state)
- [ ] [M3: dB conversion is asymmetric and unclamped — out-of-range values sent](#m3-db-conversion-is-asymmetric-and-unclamped--out-of-range-values-sent)
- [ ] [M4: Shipped presets use a blank zoneId and flip the connection to failed](#m4-shipped-presets-use-a-blank-zoneid-and-flip-the-connection-to-failed)
- [ ] [M5: handleError reports operator/input errors as ConnectionFailure](#m5-handleerror-reports-operatorinput-errors-as-connectionfailure)
- [ ] [M6: Only the first 16 zones get per-zone variables](#m6-only-the-first-16-zones-get-per-zone-variables)
- [ ] [M7: Preset/feedback text uses a literal backslash-n instead of a newline](#m7-presetfeedback-text-uses-a-literal-backslash-n-instead-of-a-newline)
- [ ] [L1: No reconnect/poll — failed connection does not self-heal](#l1-no-reconnectpoll--failed-connection-does-not-self-heal)
- [ ] [L2: Per-request HTTPS Agent — no keepAlive or connection reuse](#l2-per-request-https-agent--no-keepalive-or-connection-reuse)
- [ ] [L3: configUpdated does not drop in-flight requests from the old config](#l3-configupdated-does-not-drop-in-flight-requests-from-the-old-config)
- [ ] [L4: configUpdated does not re-publish variable definitions](#l4-configupdated-does-not-re-publish-variable-definitions)
- [ ] [L5: putCustomZoneJson JSON-parse error path is inconsistent](#l5-putcustomzonejson-json-parse-error-path-is-inconsistent)
- [ ] [N1: resolveZoneId numeric-to-output mapping is undocumented](#n1-resolvezoneid-numeric-to-output-mapping-is-undocumented)
- [ ] [N2: getZone fabricates default fields from a malformed response](#n2-getzone-fabricates-default-fields-from-a-malformed-response)
- [ ] [N3: last_response / zones_json store large raw payloads](#n3-last_response--zones_json-store-large-raw-payloads)
- [ ] [N4: Device error body is surfaced into the last_error variable](#n4-device-error-body-is-surfaced-into-the-last_error-variable)
- [ ] [N5: buildUrl interpolates host into a URL template](#n5-buildurl-interpolates-host-into-a-url-template)

---

## 🔴 Critical

These are deterministic template/packaging checks against the official `companion-module-template-ts-v1`. A first release cannot ship until the module matches the template scaffold.

### C1: LICENSE file missing

**File:** `LICENSE`

The required top-level `LICENSE` file is absent. The manifest declares `"license": "MIT"`, so the matching MIT `LICENSE` file must be present.

**Fix:** add the MIT `LICENSE` file from the template (with the correct copyright holder/year).

### C2: .gitattributes file missing

**File:** `.gitattributes`

The template's `.gitattributes` is missing.

**Fix:** copy `.gitattributes` from `companion-module-template-ts-v1`.

### C3: .husky/pre-commit hook missing

**File:** `.husky/pre-commit`

The Husky `pre-commit` hook is missing. The template wires `husky` + `lint-staged` so commits are formatted/linted automatically (see C11–C13).

**Fix:** add `.husky/pre-commit` from the template.

### C4: .gitignore missing required template entries

**File:** `.gitignore`

Missing template entries: `node_modules/`, `package-lock.json`, `/pkg`, `/*.tgz`, `/dist`, `DEBUG-*`, `/.yarn`, `/.vscode`. The repo `.gitignore` must contain (at least) the template's entries.

**Fix:** merge the missing lines into `.gitignore`. Extra entries are fine; the template lines are required.

### C5: .prettierignore differs from template

**File:** `.prettierignore`

Differs from template (line 1: found `dist`, template `package.json`).

**Fix:** align `.prettierignore` with the template version.

### C6: eslint.config.mjs differs from template

**File:** `eslint.config.mjs`

Differs from template (line 5: found `ignores: ['dist/**', 'node_modules/**', '.pnp.*', '.yarn/**'],`, template `})`). The module has hand-edited the generated ESLint flat config.

**Fix:** restore `eslint.config.mjs` to the template version unless there is a documented reason to diverge.

### C7: tsconfig.json differs from template

**File:** `tsconfig.json`

Differs from template (line 2: found `"extends": "@companion-module/tools/tsconfig/node22/recommended"`, template `"extends": "./tsconfig.build.json"`). The module has swapped the `extends` targets between `tsconfig.json` and `tsconfig.build.json` relative to the template (see C8).

**Fix:** restore the template's two-file split — `tsconfig.json` extends `./tsconfig.build.json`, and `tsconfig.build.json` extends the `@companion-module/tools` recommended config.

### C8: tsconfig.build.json differs from template

**File:** `tsconfig.build.json`

Differs from template (line 2: found `"extends": "./tsconfig.json"`, template `"extends": "@companion-module/tools/tsconfig/node22/recommended"`). Mirror image of C7.

**Fix:** restore the template's `tsconfig.build.json` (extends the `@companion-module/tools` recommended config).

### C9: package.json missing required script postinstall

**File:** `package.json`

Missing required script `postinstall`. The template uses `postinstall` to install the Husky hooks.

**Fix:** add the template `postinstall` script.

### C10: package.json missing required script lint:raw

**File:** `package.json`

Missing required script `lint:raw`.

**Fix:** add the template `lint:raw` script.

### C11: package.json missing devDependency husky

**File:** `package.json`

Missing devDependency `husky` (present in template).

**Fix:** add `husky` to `devDependencies` (template version range).

### C12: package.json missing devDependency lint-staged

**File:** `package.json`

Missing devDependency `lint-staged` (present in template).

**Fix:** add `lint-staged` to `devDependencies` (template version range).

### C13: package.json missing lint-staged section

**File:** `package.json`

Missing `lint-staged` section (present in template). Tied to C3/C11/C12 — without the `lint-staged` config the pre-commit hook has nothing to run.

**Fix:** add the template's `lint-staged` block to `package.json`.

### C14: manifest id does not match name

**File:** `companion/manifest.json:3-4`

`id` is `biamp-qtx` but `name` is `Qt X`. In the official template, `id` and `name` are the same slug (`your-module-name`); the human-readable label is carried by `manufacturer` (`Biamp`), `products` (`Qt X`), and `shortname`. A display-style `name` here diverges from the template convention and the registry's expectation that `name` equals the module id.

**Fix:** set `"name": "biamp-qtx"` to match `"id"`. The display name is already covered by `shortname`/`manufacturer`/`products`.

---

## 🟠 High

### H1: makeZoneUpdateBody corrupts masking state on mute/unmute

**File:** `src/main.ts:116-124` (with `src/main.ts:186`, `getZone` at `:327-332`)

Every write action (mute, set/adjust level) does GET zone → mutate → PUT a **full** body built by `makeZoneUpdateBody`, which sends `BackgroundLevel`, `MaskingLevel`, `Muted`, `PagingLevel` using `getZoneValue(zone, 'MaskingLevel') ?? -100`. The code elsewhere explicitly supports devices that express masking via a `MaskingEnabled` boolean rather than a numeric `MaskingLevel` (`isMaskingEnabled`, `:186`). On such a device, a zone with no numeric `MaskingLevel` gets `MaskingLevel: -100` synthesized and written back on **every** mute/unmute, and `MaskingEnabled` is never carried through — so muting a zone silently changes its masking.

**Fix:** carry `MaskingEnabled` through when the source zone has it; include `MaskingLevel` only when the source zone actually reported a numeric value (don't synthesize `-100`). Better, send only the field(s) the action intends to change rather than fabricating a full body.

### H2: Unserialized read-modify-write causes lost updates on rapid actions

**File:** `src/main.ts:283-293` (`updateZone`), `:327-332` (`getZone`)

Write actions are not serialized. Two rapid presses on the same zone (e.g. an "adjust masking level" held button, or mute + set-level) both GET the same starting state and both PUT, so the second write overwrites the first with stale `BackgroundLevel`/`PagingLevel`/`Muted`. Combined with the full-body PUT (H1), an in-flight level change can revert a concurrent mute.

**Fix:** serialize writes per zone id (a per-zone request queue), or use a partial-update endpoint if the API offers one so unrelated fields aren't echoed back.

### H3: Feedbacks use self.parseVariablesInString and go stale

**File:** `src/feedbacks.ts:42, 63, 106, 151-153`

All four feedbacks (`zone_muted`, `masking_enabled`, `masking_level_compare`, `masking_level_text`) resolve `zoneId` (and `prefix`/`emptyText`) via `self.parseVariablesInString(...)`. Per the v1 compliance guidance, `InstanceBase.parseVariablesInString` does **not** record variable usage, so a feedback whose option references `$(...)` will not be re-evaluated when that variable changes — the feedback shows stale state until an unrelated `checkFeedbacks` fires. The SDK JSDoc explicitly says not to use this method inside feedbacks.

**Fix:** use the feedback callback's `context` argument: `callback: async (feedback, context) => { const zoneId = await context.parseVariablesInString(String(feedback.options.zoneId ?? '')); ... }`, for every variable-bearing option read in every feedback.

---

## 🟡 Medium

### M1: Write-action callbacks lack try/catch — failures leave status Ok

**File:** `src/actions.ts:47-54, 86-93, 135, 167, 190-198`

The write actions (`setMaskingLevel`, `adjustMaskingLevel`, `setMaskingEnabled`, `setZoneMuted`, `putCustomZoneJson`) `await` the request and let rejections bubble to Companion's runtime. The runtime logs them (no process crash), but unlike the refresh path — which funnels errors through `handleError()` to set `ConnectionFailure` + `last_error` — a failed device write leaves `InstanceStatus` falsely `Ok` and `last_error` unpopulated.

**Fix:** wrap each write-action body in try/catch that calls `this.handleError(error)`, or route all device-write helpers through a common wrapper that sets status on failure (mirroring the refresh path). See also M5 — distinguish connection failures from per-request/operator errors.

### M2: destroy() does not reset status or clear state

**File:** `src/main.ts:144-146`

`destroy()` only logs. It never calls `updateStatus(InstanceStatus.Disconnected)` and leaves `this.zones` populated. There are no long-lived sockets/timers/agents to leak (each `request()` ends its own request; the per-request HTTPS agent is GC'd), so this is not a leak — but the instance should signal teardown.

**Fix:** in `destroy()`, call `this.updateStatus(InstanceStatus.Disconnected)` and `this.zones.clear()`.

### M3: dB conversion is asymmetric and unclamped — out-of-range values sent

**File:** `src/main.ts:36-38`, `:197`; `src/actions.ts:31-33`

`uiDbToApiLevel(value) = Math.round((value - 10) * 10)` and `formatMaskingLevel` inverts as `level / 10 + 10`, but nothing clamps the result. The `set_masking_level` UI input allows `min:-200 max:200`, which in UI mode maps to API `(-200-10)*10 = -2100` — far outside the device's masking range (`offLevel` default `-400`; feedback range `-1000..200`). No clamp exists before the PUT.

**Fix:** clamp the computed API level to the device's valid masking range before sending, tighten the action input min/max to the real dB range, and document the 10× dB scale.

### M4: Shipped presets use a blank zoneId and flip the connection to failed

**File:** `src/main.ts:334-348` (`resolveZoneId`); `src/presets.ts:26, 56, 70`

Presets ship with `zoneId: ''`. `resolveZoneId('')` returns `''`, then `updateZone` throws `'Zone ID is required'`, which `handleError` turns into `ConnectionFailure`. So the shipped presets fail out of the box **and** mark the connection failed even though the device is reachable.

**Fix:** ship presets with a real/example zone id (or a clearly-labelled placeholder the operator must set), and treat a missing zone id as an operator warning (`log('warn', …)`) rather than a connection failure (see M5).

### M5: handleError reports operator/input errors as ConnectionFailure

**File:** `src/main.ts:450-458`

Any thrown error inside an action — bad JSON in `put_zone_json`, an empty zone id, an HTTP 4xx such as a 404 for a non-existent zone — routes through `handleError`, which sets `InstanceStatus.ConnectionFailure`. A single bad request marks the whole connection failed even though the device is reachable.

**Fix:** distinguish transport/connection errors (timeout, `ECONNREFUSED`) from per-request errors; set `ConnectionFailure` only for the former and log the latter without changing instance status.

### M6: Only the first 16 zones get per-zone variables

**File:** `src/main.ts:413-448`; `src/variables.ts:14`

`updateVariables` is hard-capped at 16 (`index < 16`) and the variable definitions are fixed at 16. A Qt X system with more than 16 zones silently loses per-zone variables (and index-keyed feedbacks) beyond the 16th. `zone_count`/`zones_json` remain correct, so it's not data loss, but per-zone surfaces are incomplete with no indication of truncation.

**Fix:** derive the variable count dynamically from the device, or document the 16-zone cap if 16 is a true hardware maximum (worth confirming against the Qt X spec).

### M7: Preset/feedback text uses a literal backslash-n instead of a newline

**File:** `src/presets.ts:13, 43`; `src/feedbacks.ts:139, 147, 157`

Defaults such as `'MASK\\n'` / `'MASK\\n--'` are, in a TS string literal, the characters `MASK\n` (a literal backslash followed by `n`), not a line break. Companion renders a newline only from a real `\n` character, so buttons show `MASK\n0` on one line instead of `MASK` over `0`.

**Fix:** use single-backslash escapes in source — `'MASK\n'`, `'MASK\n--'`, and `text: \`MASK\n${level}\`` — so the strings contain real newline characters. (If a literal backslash was intended, dismiss — but it almost certainly is not.)

---

## 🟢 Low

### L1: No reconnect/poll — failed connection does not self-heal

**File:** `src/main.ts:201-243`

State is refreshed only on `init`, `configUpdated`, and after each write. If the device is unreachable at init, status goes to `ConnectionFailure` and only recovers when the operator re-saves config or fires `refresh_zones`. For a REST module this is an acceptable pull-only design.

**Fix (optional):** add an opt-in background poll; store the handle and `clearInterval` it in `destroy()`.

### L2: Per-request HTTPS Agent — no keepAlive or connection reuse

**File:** `src/main.ts:358-411` (agent created at `:363-364`)

Every HTTPS request allocates a fresh `new https.Agent(...)`. These are GC'd (not a leak), but under frequent actions this forces a new TLS handshake each call with no connection reuse.

**Fix (optional):** create one `https.Agent({ keepAlive: true })` lazily, keyed on the `allowSelfSigned` setting, store it on the instance, and destroy it in `destroy()`/`configUpdated()`.

### L3: configUpdated does not drop in-flight requests from the old config

**File:** `src/main.ts:148-155`

`configUpdated` swaps `this.config` and immediately calls `refreshZones`. A request still in flight against the old host can resolve later, call `updateVariables`/`checkFeedbacks` with stale data, and overwrite the new connection's status via `handleError`. Low likelihood given short timeouts.

**Fix:** increment a generation token in `configUpdated` and ignore responses whose token is stale.

### L4: configUpdated does not re-publish variable definitions

**File:** `src/main.ts:148-155`

`init()` calls `updateVariableDefinitions()` (`:139`) but `configUpdated()` does not. The definition set is static today (fixed list + 16 zones), so this is harmless, but it is inconsistent and would silently drop new definitions if the set ever became config-dependent.

**Fix:** add `this.updateVariableDefinitions()` to `configUpdated()`, or leave a comment noting the definitions are intentionally static.

### L5: putCustomZoneJson JSON-parse error path is inconsistent

**File:** `src/main.ts:273-281`

Bad JSON in the `put_zone_json` action throws synchronously and propagates to the framework's generic rejection log — it does **not** go through `handleError` like other paths, so behavior is inconsistent.

**Fix:** validate/parse with a try/catch and `log('warn', 'invalid JSON: …')` giving a clear operator message, rather than relying on the framework's generic log.

---

## 💡 Nice to Have

### N1: resolveZoneId numeric-to-output mapping is undocumented

**File:** `src/main.ts:340`

`resolveZoneId` maps a bare `/^\d+$/` input (e.g. `3`) to output name `output3`. Convenient, but if a real zone *name* is literally `"3"` it is shadowed by the output mapping.

**Fix:** document the resolution order (exact id → name → output{n}).

### N2: getZone fabricates default fields from a malformed response

**File:** `src/main.ts:331`

`getZone` spreads `response.body` then overwrites `Id`. If the GET returns an array or non-object, the spread yields `{ Id: id }` with no other fields, and downstream `Number(... ?? -100)` fabricates defaults that can then be written back (tied to H1).

**Fix:** validate the GET response shape before building a PUT body.

### N3: last_response / zones_json store large raw payloads

**File:** `src/main.ts:238, 320, 445`

`last_response` holds the full raw body of `/api/v1/Config`, which can be sizeable on a multi-device system. Functional but heavy for the variable panel and exports.

**Fix:** truncate, or make the raw-response variable opt-in/debug-only.

### N4: Device error body is surfaced into the last_error variable

**File:** `src/main.ts:384-385`

Non-2xx responses reject with the raw device error body embedded in the message, which `handleError` surfaces into the `last_error` variable and the log. Fine for diagnostics; just be aware large/sensitive device bodies land in a Companion variable.

**Fix (optional):** trim the body length before storing it in `last_error`.

### N5: buildUrl interpolates host into a URL template

**File:** `src/main.ts:350-356`

`buildUrl()` interpolates the config `host` directly into a `new URL(...)` template. `host` is regex-validated as a hostname and `URL` throws on a malformed value (caught upstream), so this is safe — noted only to confirm it was checked.

**Fix:** none required.
