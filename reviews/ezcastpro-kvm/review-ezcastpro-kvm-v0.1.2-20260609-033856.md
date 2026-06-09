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
| 🔴 Critical | 16 |
| 🟠 High | 3 |
| 🟡 Medium | 8 |
| 🟢 Low | 4 |
| 💡 Nice to Have | 4 |

All 16 Critical findings are deterministic template/manifest/packaging gaps (Step-4 validator). The 3 High findings are correctness/robustness issues in the protocol and lifecycle code.

## Verdict

❌ **Changes Required** — 19 blocking (16 Critical + 3 High).

## 📋 Issues

### Blocking

#### 🔴 Critical

The module does not match the official `companion-module-template-ts-v1` and is missing required packaging/tooling. Each item below blocks release.

**Missing required files**

1. **.yarnrc.yml missing** — required template file absent. Add the template's `.yarnrc.yml` (the module ships a `yarn.lock` but no yarn config).
2. **.husky/pre-commit missing** — required template file absent. Add the husky pre-commit hook from the template.

**.gitignore — missing template entries**

3. **.gitignore (`.gitignore:1`)** — missing template entries: `/pkg`, `/*.tgz`, `/dist`, `DEBUG-*`, `/.yarn`, `/.vscode`. Add them. (Note: `pkg/` and `ezcastpro-kvm-0.1.2.tgz` are currently committed in the repo — they should be ignored and removed from version control.)

**Config files differ from template**

4. **eslint.config.mjs (`eslint.config.mjs:3`)** — found `export default await generateEslintConfig({ enableTypescript: true })`; template is `export default generateEslintConfig({ ... })`. Align with the template's eslint config.
5. **tsconfig.json (`tsconfig.json:2`)** — `extends` points at `@companion-module/tools/tsconfig/node22/recommended-esm`; template extends `./tsconfig.build.json`. Restore the template's tsconfig layering.
6. **tsconfig.build.json (`tsconfig.build.json:2`)** — `extends` points at `./tsconfig.json`; template extends `@companion-module/tools/tsconfig/node22/recommended`. Restore the template's tsconfig layering.

**package.json — missing fields / scripts / devDeps**

7. **package.json — missing field `packageManager`** — add the `packageManager` field (present in template; pins the Yarn version).
8. **package.json — missing script `postinstall`** — add it from the template.
9. **package.json — missing script `build:main`** — add it from the template.
10. **package.json — missing script `lint:raw`** — add it from the template.
11. **package.json — missing devDependency `husky`** — add it (pairs with the `.husky/pre-commit` hook above).
12. **package.json — missing devDependency `lint-staged`** — add it.
13. **package.json — missing `lint-staged` section** — add the template's `lint-staged` config block.

**Manifest keywords**

14. **companion/manifest.json — banned/low-value keyword `EZCastPro`** — remove it from `keywords`.
15. **companion/manifest.json — banned/low-value keyword `ezcastpro-kvm`** — remove the module-id keyword.
16. **companion/manifest.json — banned/low-value keyword `kvm`** — remove it. Keywords should describe searchable capability, not repeat the module name/id.

#### 🟠 High

##### Multicast IP octet overflows for channels above 155

`src/protocol.ts:121-127` — `multicastForChannel` computes `group = 100 + channel` and embeds it as the final octet (`224.0.200.${group}`, `224.0.201.${group}`, `224.0.202.${group}`). Channel IDs are validated as 0–255 across the module (`main.ts`, `actions.ts`), so any channel ≥ 156 produces an invalid octet (channel 255 → `224.0.200.355`). The derived `stream_ip` / `kvm_control_ip` variables then expose nonsense addresses to the operator with no error. `streamPort = 12425 + channel` stays in range, but the IP octet is unbounded.
**Fix (maintainer):** confirm the device's real channel range; clamp/validate so `100 + channel ≤ 255` (i.e. channel ≤ 155) before deriving multicast fields, or return `undefined` for the multicast group when out of range so the variables stay blank rather than wrong. Tighten the 0–255 channel validation to the hardware's actual range.

##### Discovery scan is unbounded on large subnets

`src/protocol.ts:192,208` (`hostsFromCidr` / `discoverDevices`) — the discovery subnet is a free-text config field (`config.ts:77`, default `192.168.96.0/24`) that accepts any CIDR. `hostsFromCidr` enumerates every host with no size cap and turns each into an HTTP request (64 concurrent). A misconfigured `/16` (≈65k hosts) or `/8` (≈16.7M) will hammer the network for a very long time and pin the module. There is also no overall wall-clock deadline, so each non-responsive host blocks for the full per-host timeout.
**Fix (maintainer):** cap the enumerated host count (reject prefixes shorter than e.g. `/22`, or hard-limit to a few thousand hosts) and surface `InstanceStatus.BadConfig` with a clear message when the subnet is too large. Add an overall discovery deadline so an empty/slow subnet can't stall.

##### destroy() does not stop in-flight work or the pending settle timer

`src/main.ts:73-76` — `destroy()` only calls `stopPolling()`. The `setChannel` path schedules a bare `setTimeout` (`main.ts:298`) that is never tracked and cannot be cleared, and in-flight HTTP requests / `refreshStatus()` promises keep running after destroy, calling `updateStatus` / `setVariableValues` / `checkFeedbacks` on a torn-down instance. After `configUpdated` or `destroy` this produces "called after destroy" noise and stale status writes.
**Fix (maintainer):** set a `destroyed` flag in `destroy()` and guard `refreshStatus` / `updateVariables` / `checkFeedbacks` against it; store the settle `setTimeout` handle so it can be cleared. (The poll-timer handling itself is correct.)

### Non-blocking

#### 🟡 Medium

##### HTTP status code is never checked

`src/protocol.ts:94-109` (`cmsCall`) — the body is parsed regardless of `res.statusCode`. A `401`/`403` (wrong/missing admin password on `set_*` calls) or a `404`/`500` HTML error page is treated as "not JSON" and surfaces as a generic `Invalid CMS response` parse error rather than an auth/HTTP failure.
**Fix (maintainer):** check `res.statusCode` in the `end` handler and reject with a status-specific message (especially distinguishing auth failures) before attempting `JSON.parse`.

##### No in-flight guard on polling — requests can stack

`src/main.ts:237-238` — `startPolling` fires `void this.refreshStatus()` on a fixed `setInterval`. If a device is slow and a request approaches `requestTimeoutMs` while the poll interval is short, multiple `refreshStatus` calls overlap, each issuing its own HTTP request and racing to write `this.rxInfo` / status.
**Fix (maintainer):** track an in-flight flag, or use a self-rescheduling `setTimeout` that schedules the next poll only after the current one resolves, so at most one `refreshStatus` runs at a time.

##### setChannel relies on a fixed 300 ms settle before refresh

`src/main.ts:289-298` — after `setReceiverChannel`, the code waits a hardcoded `setTimeout(resolve, 300)` then calls `refreshStatus`. If the device hasn't applied the change within 300 ms, `rxInfo.channelId` (and the `active_channel` feedback) reflects the stale channel until the next poll. The 300 ms is an undocumented guess.
**Fix (maintainer):** re-fetch in a short retry loop until `channelId` matches the requested value (with a timeout), or document that feedback settles on the next poll. Add a comment explaining the device-settle rationale if the delay stays.

##### discover() swallows errors without updating status

`src/main.ts:266-282` — the `catch` sets `lastError` but leaves `InstanceStatus` untouched, so a discovery failure (e.g. network unreachable) is invisible in the connection indicator. When discovery is the RX-selection source, a silent failure leads to an empty effective RX host and a later `BadConfig`, masking the real cause.
**Fix (maintainer):** on discovery failure set an appropriate `InstanceStatus` (or at least `this.log('warn', ...)`) so the failure is observable.

##### Device role detected by substring search over user-editable text

`src/protocol.ts:133` — `role` is derived from whether the lowercased `dev_name + product_name + model` *contains* `'rx'` or `'tx'`. RX selection, TX channel mapping, and the `active_tx_*` variables all depend on `role`, so a name that incidentally contains those letters can silently misclassify the device and break channel→TX mapping.
**Fix (maintainer):** detect role from a reliable field (e.g. `swsp_mode`, exact `product_name` match, or a dedicated capability flag) rather than a substring search over a user-editable name.

##### Redundant parseVariablesInString on auto-parsed textinput fields

`src/actions.ts:46,76,107,109,150,152` (and the equivalent in `main.ts`) — under v1.13+ (this module is ~1.14.1), variables in `textinput` fields that declare `useVariables: true` are auto-parsed before the callback runs, so `action.options.*` already holds resolved values. The explicit `self.parseVariablesInString(...)` calls are no-ops on already-resolved strings — they work but are confusing.
**Fix (maintainer):** read the option directly (e.g. `String(action.options.channel ?? '')`) and drop the `await self.parseVariablesInString(...)` wrapper. None of these fields use `$(local:*)` / `$(this:*)`, so no `context.parseVariablesInString` is needed.

##### Discovery runs synchronously inside the connect path and re-scans on every config save

`src/main.ts:219` — `start()` awaits `this.discover()` when `autoDiscover` or `rxSelectionMode === 'discovered'` is set, before status is reported. The 64-way subnet scan delays the instance becoming ready and re-runs on every `configUpdated()`.
**Fix (maintainer):** run startup discovery in the background (don't `await` it inside the connect path), and/or debounce discovery so a config save doesn't immediately re-scan. (Pairs with the High discovery-bound finding.)

##### Response body is buffered with no size cap

`src/protocol.ts:94-109` — `cmsCall` accumulates every `res.on('data')` chunk with no limit. Because discovery hits every host on the subnet, a misbehaving or hostile host could stream a large body and grow memory until the request timeout fires (the timeout fires on socket inactivity, not on a slow steady stream).
**Fix (maintainer):** track accumulated length and `req.destroy()` once it exceeds a sane cap (e.g. 256 KB–1 MB).

#### 🟢 Low

##### No backoff after a failed refreshStatus

`src/main.ts:216-238` — on a persistently-down host, `refreshStatus` is retried at the full poll rate (min 500 ms) forever, with no backoff, hammering the device the moment it returns.
**Fix (maintainer):** optional exponential backoff on consecutive failures, capped at the poll interval.

##### Admin password stored as plain textinput

`src/config.ts:51-52` — the `password` field uses `type: 'textinput'`; v1.13+ provides `type: 'secret-text'` so credentials are protected in connection exports.
**Fix (maintainer):** change the `password` field to `type: 'secret-text'`.

##### Dead legacy rxHost config fallback

`src/main.ts:138` / `src/config.ts:8` — `getEffectiveRxHost` reads `this.config.rxHost` and `rxHost` is typed in `ModuleConfig`, but it is never defined in `getConfigFields()` (only `manualRxHost` and `discoveredRxHost` are real fields), and `UpgradeScripts` is empty. `rxHost` is effectively always `undefined`.
**Fix (maintainer):** remove the dead `rxHost` fallback (and its type), or add a real config field / upgrade script if it was intended.

##### 99 channel presets generated unconditionally

`src/presets.ts:18-19` / `src/main.ts:109` — `getPresetChannels()` always returns channels 1–99, so every install gets 99 channel buttons plus 2 control presets regardless of how many channels the user actually labels.
**Fix (maintainer):** consider generating presets only for configured channels (with a fallback), or document that the full 01–99 grid is intentional. UX only.

#### 💡 Nice to Have

- **`set_*` calls ignore the JSON-RPC `result`** (`src/protocol.ts:163,172,181`) — `setReceiverChannel` / `setAssignedName` / `setDeviceChannel` reject on `parsed.error` (good) but discard `result`. If the firmware ever signals failure in `result` without an `error`, it would be treated as success. Inspect the `result` payload if that pattern applies.
- **Feedbacks could expose a `description`** (`src/feedbacks.ts`) — v1.13+ supports `description` for a persistent hint; `active_channel` in particular would benefit from clarifying it matches the receiver's current channel ID.
- **Use mDNS/Bonjour for discovery** — if EZCast Pro devices advertise an mDNS service, a `bonjour-device` config field (v1.7+) plus a manifest Bonjour query would be far more reliable and cheaper than a 254-host HTTP scan. Only applies if the devices actually advertise.
- **Hard-coded port/path** (`src/protocol.ts:84`) — `port: 80` and `/cgi-bin/proav.cgi` are fine for this fixed-firmware device; only worth exposing if other models differ.
