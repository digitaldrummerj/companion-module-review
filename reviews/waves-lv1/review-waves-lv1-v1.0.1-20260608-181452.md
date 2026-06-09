# Re-review — waves-lv1 v1.0.1 (follow-up)

| | |
|---|---|
| **Module** | waves-lv1 |
| **Tag** | v1.0.1 |
| **Scope** | tag — follow-up of the `v1.0.0..v1.0.1` delta + verification of prior findings |
| **Prior review** | [review-waves-lv1-v1.0.0-20260608-171818.md](review-waves-lv1-v1.0.0-20260608-171818.md) |
| **Language / API** | TypeScript · `@companion-module/base` ~1.12.1 (v1) |
| **Protocols** | OSC, TCP, UDP, Bonjour/zDNS |
| **Reviewed** | 2026-06-08 |

## Verdict: ❌ Changes Required

## 📋 Issues

**Blocking**

- [ ] [C1: Required file .husky/pre-commit is missing](#c1-required-file-huskypre-commit-is-missing)
- [ ] [C2: .gitignore is missing required template entries](#c2-gitignore-is-missing-required-template-entries)
- [ ] [C4: eslint.config.mjs does not use the official Companion config](#c4-eslintconfigmjs-does-not-use-the-official-companion-config)
- [ ] [C6: tsconfig.build.json targets node18 instead of node22](#c6-tsconfigbuildjson-targets-node18-instead-of-node22)
- [ ] [C7: package.json repository.url points at a personal fork](#c7-packagejson-repositoryurl-points-at-a-personal-fork)
- [ ] [C8: package.json missing required postinstall script](#c8-packagejson-missing-required-postinstall-script)
- [ ] [C9: package.json missing devDependency husky](#c9-packagejson-missing-devdependency-husky)
- [ ] [C10: package.json missing devDependency lint-staged](#c10-packagejson-missing-devdependency-lint-staged)
- [ ] [C11: package.json missing lint-staged section](#c11-packagejson-missing-lint-staged-section)
- [ ] [C12: package.json has extra sections that are not needed](#c12---packagejson-has-extra-sections-that-are-not-needed)
- [ ] [H1: yarn lint fails](#h1-yarn-lint-fails)
- [ ] [H2: In-flight discovery UDP socket is not cancelled on destroy](#h2-in-flight-discovery-udp-socket-is-not-cancelled-on-destroy)
- [ ] [H4: several checkFeedback calls target non-existent feedback ids](#h4--several-checkfeedbacks-calls-target-non-existent-feedback-ids)
- [ ] [H6:Host field is not validated as an IP address](#h6--manual-host-field-has-no-ip-validation)

**Non-blocking**

- [ ] [M1: Discovery socket/bind errors are swallowed](#m1-discovery-socketbind-errors-are-swallowed)
- [ ] [M2: register emits registered even when the handshake ACK never arrives](#m2-register-emits-registered-even-when-the-handshake-ack-never-arrives)
- [ ] [M4: No connect timeout on the TCP socket](#m4-no-connect-timeout-on-the-tcp-socket)
- [ ] [M7: configUpdated/discovery is not cancellable](#m7-configupdateddiscovery-is-not-cancellable)
- [ ] [L3: configUpdated restart leaves stale state maps and failure count](#l3-configupdated-restart-leaves-stale-state-maps-and-failure-count)
- [ ] [NTH2: Status is not set to Connecting between reconnect attempts](#nth2-status-is-not-set-to-connecting-between-reconnect-attempts)

## 🔴 Critical

> All 13 are deterministic template/config/manifest findings, unchanged from v1.0.0. A release that fails the template parity / build tooling checks cannot ship regardless of scope.

### C1: Required file .husky/pre-commit is missing

**Classification:** ⚠️ Existing (still open) · `.husky/pre-commit` — `FILE-MISSING`
The husky pre-commit hook required by the official template is absent. Restore `.husky/pre-commit` (runs `lint-staged`), and add the `husky`/`lint-staged` devDeps and `postinstall` script noted below (C8–C11).

### C2: .gitignore is missing required template entries

**Classification:** ⚠️ Existing (still open) · `.gitignore` — `CONFIG-DIFF`
Missing entries: `package-lock.json`, `/pkg`, `/*.tgz`, `/dist`, `DEBUG-*`, `/.yarn`, `/.vscode`. Add the template's entries so build output, packed tarballs and local artifacts aren't committed.

### C4: eslint.config.mjs does not use the official Companion config

**Classification:** ⚠️ Existing (still open) · `eslint.config.mjs:1` — `CONFIG-DIFF`
The config hand-rolls `import eslint from '@eslint/js'` instead of `import { generateEslintConfig } from '@companion-module/tools/eslint/config.mjs'`. This is the **root cause of the lint failure (H1)**: without `generateEslintConfig`, the Node environment/globals aren't declared and the bundled output isn't ignored, so eslint lints a dist artifact. Replace the config with the template's `generateEslintConfig(...)` form.

### C6: tsconfig.build.json targets node18 instead of node22

**Classification:** ⚠️ Existing (still open) · `tsconfig.build.json:2` — `CONFIG-DIFF`
Extends `@companion-module/tools/tsconfig/node18/recommended`; template uses `node22`. The manifest already declares `runtime.type: node22`, so the build config must match. Switch to the node22 recommended config.

### C7: package.json repository.url points at a personal fork

**Classification:** ⚠️ Existing (still open) · `package.json` — `PKG-REPO`
`repository.url` is `git+https://github.com/miglourenco/companion-module-waves-lv1.git`; it must be `git+https://github.com/bitfocus/companion-module-waves-lv1.git`.

### C8: package.json missing required postinstall script

**Classification:** ⚠️ Existing (still open) · `package.json` — `PKG-SCRIPT`
The template's `postinstall` script (husky install) is missing. Add it.

### C9: package.json missing devDependency husky

**Classification:** ⚠️ Existing (still open) · `package.json` — `PKG-DEVDEP`
Add `husky` (present in template) to devDependencies.

### C10: package.json missing devDependency lint-staged

**Classification:** ⚠️ Existing (still open) · `package.json` — `PKG-DEVDEP`
Add `lint-staged` (present in template) to devDependencies.

### C11: package.json missing lint-staged section

**Classification:** ⚠️ Existing (still open) · `package.json` — `PKG-LINTSTAGED`
Add the template's `lint-staged` configuration block.

#### C12 - package.json has extra sections that are not needed

`package.json` does not need description, author, bugs, and homepage.  It is safe to remove all of those sections.  

## 🟠 High

### H1: yarn lint fails

**Classification:** ⚠️ Existing (still open) · `package.json` (lint) / `eslint.config.mjs`
`yarn lint` still reports problems — `no-unused-expressions` across a bundled "line 1" plus `'module'/'setInterval'/'clearInterval' is not defined` (`no-undef`). These are not real source defects: eslint is running against a bundled/dist file with no Node environment configured. Fixing **C4** (use `generateEslintConfig`, which sets the Node env and ignores build output) should clear them. Re-run `yarn lint` until clean before resubmission.

### H2: In-flight discovery UDP socket is not cancelled on destroy

**Classification:** ⚠️ Existing (still open) · `src/zdns-discover.ts:107-185`, `src/main.ts:120-127,200-203,240-251`
`discover()` still returns only `Promise<DiscoveryEntry[]>` — the `DiscoverHandle`/`stop()` type is declared (`zdns-discover.ts:103-105`) but unused, and the dgram socket is only closed by its own ~6 s `finish()` timeout or a socket error. `destroy()` holds no reference to an in-flight scan and tears down only `this.osc`, so if Companion destroys the instance mid-discovery (init, `connectIfReady`, or `rediscoverPort` via `refreshDiscovery`) the bound socket keeps its multicast membership and timer alive after teardown, and a late resolve runs against a dead instance. Rapid config edits / delete-recreate cycles stack sockets on the fixed port 13337.
**Fix:** give `discover()` a cancel path (return/track a handle or accept an `AbortSignal`), keep the in-flight discovery on the instance, and abort/close it in `destroy()`.

#### H4 — Several checkFeedbacks calls target non-existent feedback ids

**Classification:** ⚠️ Existing (still open) · `src/main.ts:339,461,483,527,544`
`channelGain`, `sendGain`, `channelName`, `tempo`, `currentLayer` are passed to `checkFeedbacks` but no such feedbacks exist — silent no-ops. Separately, the registered `currentSceneByName` feedback (`feedbacks.ts:179`) is **never** targeted by any `checkFeedbacks` call (scene handlers at `main.ts:557,572` only refresh `currentScene`), so "current scene matches (by name)" buttons don't refresh on scene change. (`meter` at `main.ts:622` is tracked separately as H4.)

`src/main.ts:612` vs `src/feedbacks.ts:128`
The feedback is registered as `meterLevel`, but the meter handler calls `checkFeedbacks('meter')`. Companion silently ignores unknown ids, so the "meter above threshold" feedback never re-evaluates on incoming meter data — the feature ships inert.

**Fix:** remove/correct the dead calls to registered ids.  One way you can ensure that your actions and feedbacks existing when you reference them is to use enums instead of strings. This way you would get compile time errors.  Check out these 2 files for examples of using enum for [actions](https://github.com/bitfocus/companion-module-zoom-osc-iso/blob/main/src/actions/action-gallery.ts) and [feedback](https://github.com/bitfocus/companion-module-zoom-osc-iso/blob/main/src/feedback.ts).  Then you can use them like [this](https://github.com/bitfocus/companion-module-zoom-osc-iso/blob/454dc46d2595ba3507782d04845da8d95adbb153/src/osc/feedbacks.ts#L21) in the checkFeedbacks call.

#### H6 — Manual host field has no IP validation

`src/config.ts:60-65` — the `host` `textinput` accepts any text. If it does expect an IP then use `regex: Regex.IP`

## 🟡 Medium

### M1: Discovery socket/bind errors are swallowed

**Classification:** ⚠️ Existing (still open) · `src/zdns-discover.ts:128,152-181`
`socket.on('error', () => finish())` discards the error, and `bind`/`addMembership`/`setBroadcast` failures are caught and ignored, so `discover()` resolves `[]` after the full timeout. A port-13337 conflict or a host with no multicast-capable NIC is indistinguishable from a genuinely empty LAN, leaving the user at `BadConfig` "No LV1 found" with no diagnostic.
**Fix:** distinguish socket/bind errors from "no devices found" and surface them (distinct status/log); handle `EADDRINUSE` explicitly.

### M2: register emits registered even when the handshake ACK never arrives

**Classification:** ⚠️ Existing (still open) · `src/osc-tcp.ts:201-209,223-235`, `src/main.ts:258-260`
On a missing ACK the code emits an `error` but then falls through and unconditionally `emit('registered', …)`, which drives `InstanceStatus.Ok`. A half-open / un-acked link reports green "Ok", and the auto-pong keeps the socket alive even though registration never completed.
**Fix:** `return` after the no-ACK `emit('error')` (don't emit `registered`), or emit a distinct event and only set `Ok` on a confirmed ACK.

### M4: No connect timeout on the TCP socket

**Classification:** ⚠️ Existing (still open) · `src/osc-tcp.ts:67-98`
`sock.connect(port, host)` has no `setTimeout`/connection deadline. Against a firewalled or silently-dropping host the connect hangs at the OS default (tens of seconds to minutes) with status stuck at `Connecting`; the 3 s handshake `waitFor` only starts after `'connect'` fires.
**Fix:** `sock.setTimeout(5000)` with a `'timeout'` handler that destroys the socket so a dead host falls into the reconnect/rediscover path promptly.

### M7: configUpdated/discovery is not cancellable

**Classification:** ⚠️ Existing (still open) · `src/main.ts:103-143,164-230,271`, `src/zdns-discover.ts`
`refreshDiscovery()`/`rediscoverPort()` are fired with `void` and no `.catch`. `discover()` resolves rather than rejects today, but `dgram.createSocket` is constructed outside the Promise executor's try, so a throw on a constrained host would surface as an unhandled rejection. Combined with H2, rapid config edits can stack background discovery runs with no way to cancel the older one.
**Fix:** wrap the `void`-fired call sites in `.catch(...)` logging, ensure `discover()` never rejects, and cancel an in-flight discovery before starting a new one on `configUpdated`.

## 🟢 Low

### L3: configUpdated restart leaves stale state maps and failure count

**Classification:** ⚠️ Existing (still open) · `src/main.ts:124-143`
On a host/port change the `channels`/`sends`/`meters`/`scenes`/`muteGroups`/`tbDestEnabled` maps and `consecutiveFailures` aren't reset, so feedbacks/variables briefly render the previous mixer's state and a carried-over failure count can trigger a spurious early `rediscoverPort()`. (The v1.0.1 `tbDestEnabled` map is subject to the same gap.)
**Fix:** reset `consecutiveFailures = 0`, clear the state maps and `detected` before `connectIfReady()` in the restart branch.

### L8: UserKeyInfo accepts k up to 31 but UI exposes only 16 user keys

**Classification:** ⚠️ Existing (still open) · `src/main.ts:357`
`if (k < 0 || k > 31) return` admits indices 16–31, but the `userKey` action, presets and variables cover only 1–16, so keys 17–32 update state with no surface. Cap at `k > 15`, or extend the UI surfaces.

## 💡 Nice to Have

### NTH2: Status is not set to Connecting between reconnect attempts

⚠️ Existing · `src/osc-tcp.ts:92-93`, `src/main.ts:261-273` — on auto-reconnect status goes `Disconnected` → `Ok` and never re-enters `Connecting`. Minor UX nit.
