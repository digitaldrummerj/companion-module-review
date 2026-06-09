# Review — telycam-ptz-ip-camera v1.0.0

| | |
|---|---|
| **Module** | telycam-ptz-ip-camera |
| **Review tag** | v1.0.0 |
| **Previous tag** | (none — first release) |
| **Scope** | tag |
| **Language / API** | TypeScript · @companion-module/base v2.0.4 (v2 API) |
| **Protocols** | UDP (VISCA), HTTP |
| **Reviewed** | 2026-06-09 |

> **First release under `tag` scope:** there is no `previousTag..reviewTag` diff, so this was run as a **full review of the whole `src/`**. Every finding is classified 🆕 NEW.

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 4 | 0 | 4 |
| 🟠 High | 4 | 0 | 4 |
| 🟡 Medium | 8 | 0 | 8 |
| 🟢 Low | 7 | 0 | 7 |
| 💡 Nice to Have | 2 | 0 | 2 |
| **Total** | **25** | **0** | **25** |

## Verdict: ❌ Changes Required

## 📋 Issues

**Blocking**
- [ ] [C1: manifest name must equal id](#c1-manifest-name-must-equal-id)
- [ ] [C2: redundant low-value keywords camera and ptz](#c2-redundant-low-value-keywords-camera-and-ptz)
- [ ] [C3: package.json missing packageManager field](#c3-packagejson-missing-packagemanager-field)
- [ ] [C4: tsconfig.build.json diverges from template](#c4-tsconfigbuildjson-diverges-from-template)
- [ ] [H1: Gain Limit action emits a malformed VISCA packet that is silently dropped](#h1-gain-limit-action-emits-a-malformed-visca-packet-that-is-silently-dropped)
- [ ] [H2: zoom_focus_direct sends the wrong VISCA opcode with a double-length payload](#h2-zoom_focus_direct-sends-the-wrong-visca-opcode-with-a-double-length-payload)
- [ ] [H3: Mode feedbacks are never re-checked after the poll updates state](#h3-mode-feedbacks-are-never-re-checked-after-the-poll-updates-state)
- [ ] [H4: Custom-CGI Basic auth reads config fields that are never defined](#h4-custom-cgi-basic-auth-reads-config-fields-that-are-never-defined)

**Non-blocking**
- [ ] [M1: configUpdated leaves a stale UDP error listener that can flap status](#m1-configupdated-leaves-a-stale-udp-error-listener-that-can-flap-status)
- [ ] [M2: HTTP and poll errors are swallowed; status never moves to ConnectionFailure](#m2-http-and-poll-errors-are-swallowed-status-never-moves-to-connectionfailure)
- [ ] [M3: HTTP fetch calls have no timeout or AbortController](#m3-http-fetch-calls-have-no-timeout-or-abortcontroller)
- [ ] [M4: stream.ts actions are never registered (dead code)](#m4-streamts-actions-are-never-registered-dead-code)
- [ ] [M5: color_temp_direct sends raw Kelvin and the nibble helper does not mask](#m5-color_temp_direct-sends-raw-kelvin-and-the-nibble-helper-does-not-mask)
- [ ] [M6: gamma and wdr_level direct branches are not clamped](#m6-gamma-and-wdr_level-direct-branches-are-not-clamped)
- [ ] [M7: viscaPort and httpPort modeled as textinput instead of number](#m7-viscaport-and-httpport-modeled-as-textinput-instead-of-number)
- [ ] [M8: device_name variable is hardcoded to Camera](#m8-device_name-variable-is-hardcoded-to-camera)
- [ ] [L1: initUdp sets status Ok before any reachability is confirmed](#l1-initudp-sets-status-ok-before-any-reachability-is-confirmed)
- [ ] [L2: parsed viscaPort is not clamped to a valid range](#l2-parsed-viscaport-is-not-clamped-to-a-valid-range)
- [ ] [L3: comment says every 5 seconds but the poll interval is 4000 ms](#l3-comment-says-every-5-seconds-but-the-poll-interval-is-4000-ms)
- [ ] [L4: Buffer.from hex silently truncates on non-hex characters](#l4-bufferfrom-hex-silently-truncates-on-non-hex-characters)
- [ ] [L5: mojibake in source comments and user-visible log strings](#l5-mojibake-in-source-comments-and-user-visible-log-strings)
- [ ] [L6: manifest runtime apiVersion left at 0.0.0](#l6-manifest-runtime-apiversion-left-at-000)
- [ ] [L7: preset_high nibble encoding unverified against the protocol doc](#l7-preset_high-nibble-encoding-unverified-against-the-protocol-doc)
- [ ] [N1: as any casts hide type contracts](#n1-as-any-casts-hide-type-contracts)
- [ ] [N2: sendHttpJson appears to be unused](#n2-sendhttpjson-appears-to-be-unused)

## 🔴 Critical

### C1: manifest name must equal id
**Classification:** 🆕 NEW · **File:** `companion/manifest.json:5`

In a Companion manifest the `name` field is the module's unique **slug identifier**, not a display name — it must equal `id`. The official template ships `id` and `name` both set to the slug. This module has `id: "telycam-ptz-ip-camera"` but `name: "Telycam PTZ IP Camera"`. The human-readable form already lives in `shortname`, `products`, `manufacturer`, and `description`.

**Fix (maintainer):** set `"name": "telycam-ptz-ip-camera"` to match `id`.

### C2: redundant low-value keywords camera and ptz
**Classification:** 🆕 NEW · **File:** `companion/manifest.json:12`

`keywords` includes `"camera"` and `"ptz"`, both of which are already words in the module slug (`telycam-ptz-ip-camera`). Keywords that duplicate the module name add no search value and are rejected by the template keyword rules.

**Fix (maintainer):** drop `"camera"` and `"ptz"`; keep distinguishing terms (e.g. `"visca"`, plus a manufacturer/model term not already in the slug).

### C3: package.json missing packageManager field
**Classification:** 🆕 NEW · **File:** `package.json`

The template pins `"packageManager": "yarn@4.12.0"`; this module omits it entirely and still declares `engines.yarn ">=1.22.0"` with a `husky` postinstall. Without the `packageManager` pin, Corepack cannot resolve the expected Yarn 4 toolchain, and the project is internally inconsistent (Yarn 1 engines vs. a Yarn 4 template).

**Fix (maintainer):** add `"packageManager": "yarn@4.x"` (matching the template's major) and align the `engines`/lockfile to Yarn 4.

### C4: tsconfig.build.json diverges from template
**Classification:** 🆕 NEW · **File:** `tsconfig.build.json:7`

`compilerOptions` replaces the template's `"baseUrl": "./"` with `"rootDir": "./src"`. Build-config divergence from the official template is a template-compliance failure for release.

**Fix (maintainer):** restore the template's `tsconfig.build.json` `compilerOptions` (use the template `baseUrl` form). If `rootDir` is genuinely required, raise it with the template maintainers rather than diverging silently.

## 🟠 High

### H1: Gain Limit action emits a malformed VISCA packet that is silently dropped
**Classification:** 🆕 NEW · **File:** `src/actions/image.ts:293`

The Gain Limit command is built as `` `8101042C0${toHex(val)}FF` ``. `toHex()` already pads to **two** hex chars, so the leading `0` plus a 2-char value yields a 3-nibble payload — e.g. `val=15` → `8101042C00fFF`, which is **13 hex chars (odd length)**. `sendViscaCommand` rejects odd-length hex (`src/main.ts:120`) and returns without sending. The Gain Limit action therefore **never works for any value**, and the operator gets no visible error.

**Fix (maintainer):** the field is a single nibble — use `` `8101042C0${val.toString(16)}FF` `` (matching the `gamma`/`wdr_level` pattern) and clamp `val` to 0–15.

### H2: zoom_focus_direct sends the wrong VISCA opcode with a double-length payload
**Classification:** 🆕 NEW · **File:** `src/actions/focus.ts:83-93`

`zoom_focus_direct` emits the **Zoom** Direct opcode `81010447` followed by **both** a 4-nibble zoom block and a 4-nibble focus block (`81010447 + 0z0z0z0z + 0f0f0f0f + FF`). VISCA `8101 0447` expects only the 4-nibble zoom position; appending a second 4-nibble block sends 8 data nibbles to a 4-nibble command, so the camera will reject it or misread the focus value as trailing garbage. (Focus Direct is opcode `48`.)

**Fix (maintainer):** confirm the camera's actual combined zoom+focus opcode from the protocol doc. If none exists, split into two sends — `81010447…FF` (zoom) and `81010448…FF` (focus) — or remove the action.

### H3: Mode feedbacks are never re-checked after the poll updates state
**Classification:** 🆕 NEW · **File:** `src/main.ts:216` (feedbacks at `src/feedbacks.ts:51,79,103`)

The boolean feedbacks `wb_mode_feedback`, `exposure_mode_feedback`, and `focus_mode_feedback` read state via `getVariableValue('wb_mode'|'exposure_mode'|'focus_mode')`. Those variables are refreshed by `pollCameraStatus()` through `setVariableValues(...)`, but the module never calls `checkFeedbacks(...)`/`checkAllFeedbacks()` afterward. Companion does not re-run a feedback just because a variable it reads changed, so the mode indicators stay frozen at their initial state and never reflect the camera's actual mode.

**Fix (maintainer):** after the `setVariableValues({...})` call in `pollCameraStatus()`, call `this.checkFeedbacks('wb_mode_feedback', 'exposure_mode_feedback', 'focus_mode_feedback')` (ideally only when a value actually changed, to avoid re-rendering every poll).

### H4: Custom-CGI Basic auth reads config fields that are never defined
**Classification:** 🆕 NEW · **Files:** `src/actions/http.ts:28-30`, `src/config.ts:14-47`

`http.ts` reads `self.config.authType`, `self.config.username`, and `self.config.password`, but `GetConfigFields()` defines only `host`, `viscaPort`, and `httpPort`, and `CameraConfig` declares none of those auth members. The `[key: string]: any` index signature (`src/config.ts:10`) hides this at compile time, so the values are always `undefined` at runtime — the Basic-auth branch is dead code and the custom-CGI action can never authenticate against a camera that requires it.

**Fix (maintainer):** either add the fields — `authType` (dropdown none/basic), `username` (textinput), `password` (a `secrets` field) — to both `GetConfigFields()` and the `CameraConfig` interface, or remove the auth branch. Also consider dropping the `[key: string]: any` index signature so missing-field references fail at build (see N1).

## 🟡 Medium

### M1: configUpdated leaves a stale UDP error listener that can flap status
**Classification:** 🆕 NEW · **Files:** `src/main.ts:51-61`, `src/main.ts:90-99`

`configUpdated()` calls `closeUdp()` then `initUdp()`. `closeUdp()` calls `udpSocket.close()` but never removes the `'error'` listener attached in `initUdp()` (`src/main.ts:78`), and `dgram` `close()` is asynchronous. A late `'error'` from the old socket can still fire after the new socket is in place and call `updateStatus(ConnectionFailure)` on a now-healthy instance, flapping the status.

**Fix (maintainer):** in `closeUdp()` call `this.udpSocket.removeAllListeners()` before `close()`, and capture the socket in a local so a late old-socket error can't overwrite the new status.

### M2: HTTP and poll errors are swallowed; status never moves to ConnectionFailure
**Classification:** 🆕 NEW · **Files:** `src/main.ts:226,236-238`, `src/actions/utils.ts:75-77`

`pollCameraStatus()` only ever moves status toward `Ok` (`src/main.ts:226`) and catches network exceptions at `debug` level without changing status. `sendHttpJson`'s catch logs at `error` but leaves status untouched. Once the module reaches `Ok`, a camera that goes offline (HTTP unreachable) stays showing `Ok` indefinitely — operators get no indication the link is down.

**Fix (maintainer):** on a poll exception or non-`ok` response, set `InstanceStatus.ConnectionFailure` (or `Disconnected`); restore `Ok` on the next successful poll (the success path already does this).

### M3: HTTP fetch calls have no timeout or AbortController
**Classification:** 🆕 NEW · **Files:** `src/actions/utils.ts:57-78`, `src/actions/http.ts:33`

`sendHttpJson` and the `custom_http_cgi` action both call `fetch(...)` with no timeout. If the camera is unreachable or hangs the socket, the promise can hang indefinitely and pile up pending requests on rapid button presses. The poll path (`src/main.ts:177-184`) already does this correctly with an `AbortController` + 3 s timeout.

**Fix (maintainer):** wrap these `fetch` calls in an `AbortController` with a timeout cleared in a `finally`, mirroring `pollCameraStatus`.

### M4: stream.ts actions are never registered (dead code)
**Classification:** 🆕 NEW · **Files:** `src/actions/stream.ts`, `src/actions/index.ts`

`createStreamActions` defines six Stream actions (encode mode, framerate, bitrate for main/sub) but is never imported into the action aggregator, so none of them appear in Companion.

**Fix (maintainer):** if these should ship, add `...createStreamActions(self)` to the aggregator (and the corresponding `ActionsSchema` entries); otherwise delete `stream.ts`.

### M5: color_temp_direct sends raw Kelvin and the nibble helper does not mask
**Classification:** 🆕 NEW · **Files:** `src/actions/image.ts:659`, `src/actions/utils.ts:32`

`color_temp_direct` passes a Kelvin value (1800–10000) straight through `uint16ToViscaNibbles`, so 5600 → `15E0` → nibbles `01 05 0E 00`. Cameras typically take a color-temp **index**, not raw Kelvin, so this is very likely the wrong encoding. The shared helper also `padStart`s rather than masking, so any value >65535 would truncate rather than wrap predictably.

**Fix (maintainer):** verify the color-temp command's expected encoding (index vs. Kelvin/100) against the protocol doc; add `& 0xffff` inside the helper as defense-in-depth.

### M6: gamma and wdr_level direct branches are not clamped
**Classification:** 🆕 NEW · **File:** `src/actions/image.ts:481,530`

The `up`/`down` branches clamp with `Math.min/Math.max`, but the `direct` branches use `Number(event.options.value ?? …)` and format a single nibble `0${val.toString(16)}`. A value above the UI max (settable programmatically or by an older config) produces a 2-char nibble and thus an odd-length (dropped) or wrong packet — the same failure mode as H1.

**Fix (maintainer):** clamp before formatting — `Math.max(0, Math.min(15, val))` for gamma, `Math.min(6, …)` for wdr_level.

### M7: viscaPort and httpPort modeled as textinput instead of number
**Classification:** 🆕 NEW · **File:** `src/config.ts:32-46`

Both ports are `textinput` with `Regex.PORT`, then `parseInt`-ed and used (`src/main.ts:111`, `src/actions/utils.ts:59`). In v2 a `number` field carries `min`/`max` validation directly and avoids the parse-and-revalidate dance. Works today, but the `number` field is the more correct v2 model.

**Fix (maintainer):** convert to `type: 'number'` with `min: 1, max: 65535`; add an upgrade script if existing saved configs need migration.

### M8: device_name variable is hardcoded to Camera
**Classification:** 🆕 NEW · **Files:** `src/main.ts:220`, `src/variables.ts:21`

`device_name` is always set to the constant `'Camera'`; the poll never reads a real device name, so the variable conveys no information.

**Fix (maintainer):** populate `device_name` from an actual camera field, or remove the variable definition and the write.

## 🟢 Low

### L1: initUdp sets status Ok before any reachability is confirmed
**Classification:** 🆕 NEW · **File:** `src/main.ts:83`

`initUdp()` sets `InstanceStatus.Ok` immediately after `createSocket()`, before any datagram is sent. VISCA-over-UDP is connectionless, so "Ok" here only means "socket allocated," masking a dead/wrong-IP camera until the first HTTP poll runs.

**Fix (maintainer):** set `Connecting` in `initUdp()` and let the HTTP poll own the real reachability status.

### L2: parsed viscaPort is not clamped to a valid range
**Classification:** 🆕 NEW · **File:** `src/main.ts:111`

`parseInt(this.config.viscaPort || '52381', 10)` is `isNaN`-guarded (good), but an out-of-range numeric string would still be handed to `dgram.send` and throw asynchronously into the send callback. The `Regex.PORT` field mitigates most cases.

**Fix (maintainer):** clamp the parsed port to 1–65535 before `send`.

### L3: comment says every 5 seconds but the poll interval is 4000 ms
**Classification:** 🆕 NEW · **File:** `src/main.ts:151-157`

A comment states the poll runs "每 5 秒" (every 5 seconds) but the interval is `4000` ms. Harmless but misleading; combined with the 3 s HTTP timeout it leaves little idle margin.

**Fix (maintainer):** align the comment with the actual interval (or make the interval configurable).

### L4: Buffer.from hex silently truncates on non-hex characters
**Classification:** 🆕 NEW · **Files:** `src/main.ts:118-125`, `src/actions/utils.ts:23-45`

`Buffer.from(cleanHex, 'hex')` stops at the first non-hex character rather than erroring, so a malformed command could send a short/garbage datagram without warning. The odd-length guard catches some cases but not all.

**Fix (maintainer):** validate `/^[0-9a-fA-F]*$/` before constructing the buffer.

### L5: mojibake in source comments and user-visible log strings
**Classification:** 🆕 NEW · **Files:** `src/actions/utils.ts:3-52,65,70,73,76`, `src/actions/http.ts`, `src/main.ts:65`

Several comments and `self.log` strings are corrupted (garbled GBK/UTF-8). The corrupted text is shipped to operators in the debug log (e.g. `[HTTP] 发送指令` and the `sendHttpJson` log lines).

**Fix (maintainer):** re-save the affected files as clean UTF-8 and restore the comment/log text.

### L6: manifest runtime apiVersion left at 0.0.0
**Classification:** 🆕 NEW · **File:** `companion/manifest.json:25`

`runtime.apiVersion` is the template placeholder `"0.0.0"`. This is normally populated by the build tooling; flagging in case it should reflect a real value before submission.

**Fix (maintainer):** confirm whether the packaging step sets this; if not, populate it.

### L7: preset_high nibble encoding unverified against the protocol doc
**Classification:** 🆕 NEW · **File:** `src/actions/preset.ts:50-54`

`preset_high` (labelled "Extended 0–255") splits the value into `0H 0L` nibbles. The encoding is internally consistent with the standard `preset` action, but whether the camera accepts the `0H 0L` split for values 128–255 should be confirmed. No confirmed defect — verification item only.

**Fix (maintainer):** confirm the 0–255 preset encoding against the camera's protocol doc.

## 💡 Nice to Have

### N1: as any casts hide type contracts
**Classification:** 🆕 NEW · **Files:** `src/actions.ts:11`, `src/presets.ts:1018`

`createAllActions(self) as any` and `presets as any` defeat the `ActionsSchema`/preset typing the module otherwise maintains. These casts (together with the config `[key: string]: any` index signature) are what allowed the H4 dead-auth code to compile.

**Fix (maintainer):** remove the casts and reconcile the real types where the compiler complains.

### N2: sendHttpJson appears to be unused
**Classification:** 🆕 NEW · **File:** `src/actions/utils.ts:57-78`

`sendHttpJson` is exported but does not appear to be called from any action path.

**Fix (maintainer):** remove it if dead, or wire it in where intended (and give it the timeout from M3 if kept).

---

*No test framework is present (no `test` script, no Jest/Vitest dependency, no `*.test.*` files). Per review policy this is non-blocking and is noted for completeness only.*
