# Review — waves-lv1 v1.0.0

| | |
|---|---|
| **Module** | waves-lv1 |
| **Tag** | v1.0.0 |
| **Scope** | tag (first release → no diff; full-module review) |
| **Language / API** | TypeScript · `@companion-module/base` ~1.12.1 (v1) |
| **Protocols** | OSC, TCP, UDP, Bonjour/zDNS |
| **Reviewed** | 2026-06-08 |

> First release — `previousTag` is "(none — first release)", so there is no `previousTag..reviewTag` diff. Per the `tag`-scope first-release rule, the whole module was reviewed and **every finding is NEW**.

## Verdict

❌ Changes Required

## 📋 Issues

### 🔴 Critical (Blocking)

#### C1 — Required file .husky/pre-commit is missing

`.husky/pre-commit` — `FILE-MISSING`
The husky pre-commit hook required by the official template is absent. Restore `.husky/pre-commit` (runs `lint-staged`), and add the `husky`/`lint-staged` devDeps and `postinstall` script noted below.

#### C2 — .gitignore is missing required template entries

`.gitignore` — `CONFIG-DIFF`
Missing entries: `package-lock.json`, `/pkg`, `/*.tgz`, `/dist`, `DEBUG-*`, `/.yarn`, `/.vscode`. Add the template's entries so build output, packed tarballs and local artifacts aren't committed.

#### C4 — eslint.config.mjs does not use the official Companion config

`eslint.config.mjs:1` — `CONFIG-DIFF`
The config hand-rolls `import eslint from '@eslint/js'` instead of `import { generateEslintConfig } from '@companion-module/tools/eslint/config.mjs'`. This is the **root cause of the 450 lint errors** (H1): without `generateEslintConfig`, the Node environment/globals aren't declared (`'module'`, `'setInterval'`, `'clearInterval'` "is not defined") and the build/bundled output isn't ignored, so eslint lints a dist artifact. Replace the config with the template's `generateEslintConfig(...)` form.

#### C6 — tsconfig.build.json targets node18 instead of node22

`tsconfig.build.json:2` — `CONFIG-DIFF`
Extends `@companion-module/tools/tsconfig/node18/recommended`; template uses `node22`. The manifest already declares `runtime.type: node22`, so the build config must match. Switch to the node22 recommended config.

#### C7 — package.json repository.url points at a personal fork

`package.json` — `PKG-REPO`
`repository.url` is `git+https://github.com/miglourenco/companion-module-waves-lv1.git`; it must be `git+https://github.com/bitfocus/companion-module-waves-lv1.git`.

#### C8 — package.json missing required `postinstall` script

`package.json` — `PKG-SCRIPT`
The template's `postinstall` script (husky install) is missing. Add it.

#### C9 — package.json missing devDependency `husky`

`package.json` — `PKG-DEVDEP`
Add `husky` (present in template) to devDependencies.

#### C10 — package.json missing devDependency `lint-staged`

`package.json` — `PKG-DEVDEP`
Add `lint-staged` (present in template) to devDependencies.

#### C11 — package.json missing `lint-staged` section

`package.json` — `PKG-LINTSTAGED`
Add the template's `lint-staged` configuration block.

#### C12 - package.json has extra sections that are not needed

`package.json` does not need description, author, bugs, and homepage.  It is safe to remove all of those sections.  

### 🟠 High

#### H1 — yarn lint fails with 450 errors

`package.json` (lint) / `eslint.config.mjs`
`yarn lint` reports 450 errors — `no-unused-expressions` across a single huge "line 1" plus `'module'/'setInterval'/'clearInterval' is not defined` (`no-undef`). These are not real source defects: eslint is running against a bundled/dist file with no Node environment configured. Fixing **C4** (use `generateEslintConfig`, which sets the Node env and ignores build output) should clear them. Re-run `yarn lint` until clean before resubmission.

#### H2 — In-flight discovery UDP socket is not cancelled on destroy()

`src/zdns-discover.ts:107-185`, `src/main.ts:115-122`
`discover()` creates a `dgram` socket and only closes it when its own 5–6 s timeout fires; it returns a bare Promise with no cancel handle (the declared `DiscoverHandle`/`stop` interface at `zdns-discover.ts:103` is unused). `connectIfReady()` awaits `discover()` from `init()`/`configUpdated()`. If Companion calls `destroy()` while a scan is mid-flight, `destroy()` only tears down `this.osc` — the dgram socket keeps its multicast membership and timer alive for several seconds after the instance is gone, and a late `resolve()` runs against a dead instance. Rapid config edits or delete/recreate cycles stack multiple sockets on the fixed port 13337.
**Fix:** give `discover()` a cancel path (return/track a handle or accept an `AbortSignal`), keep the in-flight discovery on the instance, and abort/close it in `destroy()`. _(Both the protocol and compliance reviewers flagged this; the normal timeout/error path does close the socket — only the in-flight case leaks.)_

#### H4 — meterLevel feedback never updates (checkFeedbacks targets a non-existent id)

`src/main.ts:612` vs `src/feedbacks.ts:128`
The feedback is registered as `meterLevel`, but the meter handler calls `checkFeedbacks('meter')`. Companion silently ignores unknown ids, so the "meter above threshold" feedback never re-evaluates on incoming meter data — the feature ships inert.
**Fix:** change `main.ts:612` to `this.checkFeedbacks('meterLevel')`.  You can also create enums for actions and feedbacks so that you can ensure they exists instead of using strings.  The enums would ensure compile time errors.  Check out these 2 files for examples of using enum [actions](https://github.com/bitfocus/companion-module-zoom-osc-iso/blob/main/src/actions/action-gallery.ts) and [feedback](https://github.com/bitfocus/companion-module-zoom-osc-iso/blob/main/src/feedback.ts).  Then you can use this like [this](https://github.com/bitfocus/companion-module-zoom-osc-iso/blob/454dc46d2595ba3507782d04845da8d95adbb153/src/osc/feedbacks.ts#L21)

### Non-blocking

### 🟡 Medium

#### M1 — Discovery socket/bind errors are swallowed → misleading "No LV1 found"

`src/zdns-discover.ts:128,152-181`
`socket.on('error', () => finish())` discards the error, and `bind`/`addMembership`/`setBroadcast` failures are caught and ignored, so `discover()` resolves `[]` after the full timeout. A port-13337 conflict or a host with no multicast-capable NIC is indistinguishable from a genuinely empty LAN, leaving the user at `BadConfig` with no diagnostic.
**Fix:** distinguish socket/bind errors from "no devices found" and surface them (distinct status/log); handle `EADDRINUSE` explicitly.

#### M2 — register() emits 'registered' (status → Ok) even when the handshake ACK never arrives

`src/osc-tcp.ts:201-209,223-235`, `src/main.ts:255`
On a missing ACK the code emits an `error` but then falls through and unconditionally `emit('registered', …)`, which drives `InstanceStatus.Ok`. A half-open / un-acked link reports green "Ok", and the auto-pong keeps the socket alive even though registration never completed.
**Fix:** `return` after the no-ACK `emit('error')` (don't emit `registered`), or emit a distinct event and only set `Ok` on a confirmed ACK.

#### M4 — No connect timeout on the TCP socket

`src/osc-tcp.ts:67-98`
`sock.connect(port, host)` has no `setTimeout`/connection deadline. Against a firewalled or silently-dropping host the connect hangs at the OS default (tens of seconds to minutes) with status stuck at `Connecting`; the 3 s handshake `waitFor` only starts after `'connect'` fires.
**Fix:** `sock.setTimeout(5000)` with a `'timeout'` handler that destroys the socket so a dead host falls into the reconnect/rediscover path promptly.

#### M5 — Several checkFeedbacks() calls target non-existent feedback ids (dead refreshes)

`src/main.ts:334,449,473,517,534`
`channelGain`, `sendGain`, `channelName`, `tempo`, `currentLayer` are all passed to `checkFeedbacks` but no such feedbacks exist — silent no-ops. Separately, `currentSceneByName` (defined in `feedbacks.ts`) is **never** targeted by any `checkFeedbacks` call, so "current scene matches (by name)" buttons don't refresh on `/Notify/CurSceneIndex`.
**Fix:** remove the dead calls; add `'currentSceneByName'` to the scene-change handlers (`/Notify/CurSceneIndex`, `/Notify/Scene/Name`).

#### M6 — TalkBack toggle infers on/off from a magic gain threshold, ignoring the authoritative On flag

`src/actions.ts:346-352`, `src/feedbacks.ts:70-74`
`talkBackToOutput` treats `curGain > -100` as "active" to compute the toggle, but on/off is tracked independently in `SendState.on`. If a prior session left the send gain high while On=false, the toggle reads "active" from gain alone and cuts it, contradicting the real state.
**Fix:** base the toggle on `self.sends.get('8.0.'+aux)?.on` (or AND the two conditions) rather than inferring from gain.

#### M7 — configUpdated()/discovery is not cancellable; potential unhandled rejection

`src/main.ts:103-143,164-230,271`, `src/zdns-discover.ts`
`refreshDiscovery()`/`rediscoverPort()` are fired with `void` and no `.catch`. `discover()` resolves rather than rejects today, but `dgram.createSocket` is constructed outside the Promise executor's try, so a throw on a constrained host would surface as an unhandled rejection. Combined with H2, a rapid sequence of config edits can stack background discovery runs with no way to cancel the older one.
**Fix:** wrap the `void`-fired call sites in `.catch(...)` logging, ensure `discover()` never rejects, and cancel an in-flight discovery before starting a new one on `configUpdated`.

### 🟢 Low

#### L3 — configUpdated() restart leaves stale state maps and failure count

`src/main.ts:124-143`
On a host/port change the `channels`/`sends`/`meters`/`scenes`/`muteGroups` maps and `consecutiveFailures` aren't reset, so feedbacks/variables briefly render the previous mixer's state and a carried-over failure count can trigger a spurious early `rediscoverPort()`.
**Fix:** reset `consecutiveFailures = 0`, clear the state maps and `detected` before `connectIfReady()` in the restart branch.

#### L8 — /Notify/UserKeyInfo accepts k up to 31 but the UI exposes only 16 user keys

`src/main.ts:357`
`if (k < 0 || k > 31) return` admits indices 16–31, but the `userKey` action (`actions.ts:411`), presets (`presets.ts:87`) and variables (`variables.ts:49`) cover only 1–16, so keys 17–32 update state with no surface.
**Fix:** cap at `k > 15`, or extend the UI surfaces to the full reported key count.

### 💡 Nice to Have

#### NTH2 — Status is not set to Connecting between reconnect attempts

`src/osc-tcp.ts:92-93`, `src/main.ts:261-273` — on auto-reconnect status goes `Disconnected` → `Ok` and never re-enters `Connecting`. Minor UX nit.
