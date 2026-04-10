# Review: companion-module-rode-rcv v1.8.0

**Module:** companion-module-rode-rcv  
**Version reviewed:** v1.8.0  
**Previous tag:** v1.7.2  
**Review date:** 2026-04-09  
**Reviewers:** Mal 🏗️ · Wash 🔧 · Kaylee ⚛️ · Zoe 🧪 · Simon 🧪  
**API:** v1.x (`@companion-module/base 1.13.6`)  
**Language:** TypeScript ESM  

---

## Fix Summary

Seven blocking issues must be resolved before this release can be approved. Two are critical regressions introduced in v1.8.0 itself: both `manifest.version` and `manifest.apiVersion` were reset to `"0.0.0"` placeholder values (were correctly set to `"1.7.2"` and `"1.13.6"` in v1.7.2). Four new High issues cover build-only tools wrongly placed in `dependencies`, an unvoided async `SetPresets` call, missing SVG source assets that make the image generator unauditable, and a `yarn package` failure caused by the generated file not being excluded from prettier. One pre-existing Critical — a buffer stall on any OSC parse error that can permanently freeze all inbound message processing — is carried forward as blocking per policy.

**Must fix before merge:**
1. `companion/manifest.json` → restore `version` to `"1.8.0"` and `runtime.apiVersion` to `"1.13.6"`
2. `package.json` → move `jimp` and `@resvg/resvg-wasm` from `dependencies` to `devDependencies`
3. `src/helpers/connectionHelpers.ts:78` → add `void` (or `await`) to `SetPresets(instance)` call
4. Commit `imgs/` SVG sources or clearly document that the generated file is the authoritative artifact and sources are managed externally
5. Add `src/generated/` to `.prettierignore` so `yarn package` passes
6. `src/modules/oscController.ts` (parse error handler) → advance buffer past malformed packet before `break` to prevent silent message-processing freeze

---

## 📊 Scorecard

| Area | Status |
|------|--------|
| `yarn test` | ✅ 69/69 passing |
| `yarn build` | ✅ Clean |
| `yarn package` | ❌ FAIL — prettier rejects `src/generated/imagePng64Map.ts` and `package.json` indent |
| Manifest compliance | ❌ version/apiVersion regressed to `"0.0.0"` |
| Dependency hygiene | ❌ Build tools in `dependencies` |
| Protocol correctness | ⚠️ Pre-existing buffer-stall Critical carried forward |
| Image generation | ❌ Source SVGs not tracked; generator unauditable |

| Severity | NEW | PRE-EXISTING |
|----------|-----|--------------|
| 🔴 Critical | 2 | 1 |
| 🟠 High | 4 | 0 |
| 🟡 Medium | 5 | 1 |
| 🟢 Low | 6 | 2 |
| 💡 NTH | 0 | — |
| **Blocking total** | **6** | **1** |

---

## ✋ Verdict

**❌ CHANGES REQUIRED — 7 blocking issues (2 Critical NEW · 1 Critical PRE-EXISTING · 4 High NEW)**

v1.8.0 introduces a meaningful new feature (icon image generation for preset buttons) along with a significant refactor of the UDP discovery path and several quality-of-life improvements to the connection lifecycle. However, the release ships with two show-stopping manifest regressions (both version fields reset to `"0.0.0"`), a packaging pipeline that cannot complete (`yarn package` fails), build-only WASM and image-processing libraries bundled into production, missing source assets for the new image generator, and an unawaited async call that silently discards preset-generation errors on reconnect. The pre-existing OSC buffer-stall Critical is also carried forward per policy.

Fix the seven blocking items, re-run `yarn test` and `yarn package` to confirm both pass, and resubmit.

---

## 📋 Issues TOC

**🔴 Critical**
- [C1 — manifest version regressed to "0.0.0"](#c1--manifest-version-regressed-to-000)
- [C2 — manifest apiVersion regressed to "0.0.0"](#c2--manifest-apiversion-regressed-to-000)
- [C3 — OSC parse-error buffer stall: inbound messages freeze permanently ⚠️ PRE-EXISTING](#c3--osc-parse-error-buffer-stall-inbound-messages-freeze-permanently)

**🟠 High**
- [H1 — `jimp` and `@resvg/resvg-wasm` in `dependencies` (build-only tools)](#h1--jimp-and-resvgresvg-wasm-in-dependencies-build-only-tools)
- [H2 — `SetPresets(instance)` called without `await` or `void`](#h2--setpresetinstance-called-without-await-or-void)
- [H3 — `imgs/` SVG sources not committed; image generator is unauditable](#h3--imgs-svg-sources-not-committed-image-generator-is-unauditable)
- [H4 — `yarn package` fails: generated file not excluded from prettier](#h4--yarn-package-fails-generated-file-not-excluded-from-prettier)

**🟡 Medium**
- [M1 — `rxjs` runtime dependency added for dead `cacheUpdated$` export](#m1--rxjs-runtime-dependency-added-for-dead-cacheupdated-export)
- [M2 — 451 KB auto-generated file committed to `src/generated/`](#m2--451-kb-auto-generated-file-committed-to-srcgenerated)
- [M3 — Module status set `Ok` before init commands complete](#m3--module-status-set-ok-before-init-commands-complete)
- [M4 — `parseError` catch silently breaks loop with no log output](#m4--parseerror-catch-silently-breaks-loop-with-no-log-output)
- [M5 — Dead imports: `DEFAULT_BLACK_PNG64` and `buttonPressInputsType`](#m5--dead-imports-default_black_png64-and-buttonpressinputstype)

**🟢 Low**
- [L1 — Typo "seleected" in `transitions` feedback description](#l1--typo-seleected-in-transitions-feedback-description)
- [L2 — `networkInterfaces` import unused after UDP refactor](#l2--networkinterfaces-import-unused-after-udp-refactor)
- [L3 — `sendUdpPacket` never rejects; surrounding `try/catch` is dead code](#l3--sendudppacket-never-rejects-surrounding-trycatch-is-dead-code)
- [L4 — Untyped `err.message` access in outer `catch` block](#l4--untyped-errmessage-access-in-outer-catch-block)
- [L5 — `mirror` variable name is semantically inverted relative to its use](#l5--mirror-variable-name-is-semantically-inverted-relative-to-its-use)
- [L6 — `generate:images` script uses mixed tab/space indentation in `package.json`](#l6--generateimages-script-uses-mixed-tabspace-indentation-in-packagejson)

**⚠️ Pre-existing Notes**
- [PE1 — `parseOSCBlob` returns `null` with non-nullable return type](#pe1--parseoscblob-returns-null-with-non-nullable-return-type)
- [PE2 — `setInterval` refresh handle discarded; never cleared in `destroy()`](#pe2--setinterval-refresh-handle-discarded-never-cleared-in-destroy)
- [PE3 — Manifest: missing `$schema`, non-human-readable `name`, wrong `package.json` name](#pe3--manifest-missing-schema-non-human-readable-name-wrong-packagejson-name)
- [PE4 — Dev tools in `dependencies`; no `packageManager` field](#pe4--dev-tools-in-dependencies-no-packagemanager-field)
- [PE5 — `strict: false` in `tsconfig.json`](#pe5--strict-false-in-tsconfigjson)
- [PE6 — Two OSC packages (`osc` + `osc-js`) for receive vs send](#pe6--two-osc-packages-osc--osc-js-for-receive-vs-send)
- [PE7 — `isVisible` deprecated API used throughout feedbacks](#pe7--isvisible-deprecated-api-used-throughout-feedbacks)
- [PE8 — `any`-typed class members and `constructor(internal: any)` in `RCVInstance`](#pe8--any-typed-class-members-and-constructorinternal-any-in-rcvinstance)
- [PE9 — Jest in `devDependencies` but Mocha is the test runner](#pe9--jest-in-devdependencies-but-mocha-is-the-test-runner)

---

## 🔴 Critical

### C1 — manifest version regressed to "0.0.0"

🆕 **NEW in v1.8.0** · **BLOCKING**

`companion/manifest.json` had `"version": "1.7.2"` in v1.7.2. The v1.8.0 reformatting of `manifest.json` (compact JSON → pretty-printed) reset it to the template placeholder `"0.0.0"`. Companion's module registry and auto-update logic use this field to identify the installed version. Shipping `"0.0.0"` will cause the registry to misidentify this release and may break update resolution permanently for users who install it.

```diff
- "version":"1.7.2"
+ "version": "0.0.0"
```

**File:** `companion/manifest.json`  
**Fix:** Set `"version"` to `"1.8.0"`.

---

### C2 — manifest apiVersion regressed to "0.0.0"

🆕 **NEW in v1.8.0** · **BLOCKING**

`companion/manifest.json` had `"apiVersion": "1.13.6"` (matching the installed `@companion-module/base`) in v1.7.2. The same reformatting pass reset it to `"0.0.0"`. Companion validates this field at module load time against the running IPC API version; an incorrect value can prevent the module from loading at all, or trigger unexpected compatibility shims.

Note: `isPrerelease` was also removed from the manifest in v1.8.0 (was `false` in v1.7.2). Confirm whether this field is still required by the current manifest schema; re-add if needed.

```diff
- "apiVersion":"1.13.6"
+ "apiVersion": "0.0.0"
```

**File:** `companion/manifest.json`  
**Fix:** Set `"runtime.apiVersion"` to `"1.13.6"`. Re-add `"isPrerelease": false` if still required.

---

### C3 — OSC parse-error buffer stall: inbound messages freeze permanently

⚠️ **PRE-EXISTING** (present in v1.7.2) · **BLOCKING per policy**

When `osc.readPacket()` throws, the inner `catch` block executes `break` but **never advances the buffer pointer past the malformed message**. On the next TCP `data` event, the same 4-byte length prefix is read again, the same payload is extracted, and parsing throws again — silently, forever. The TCP connection stays open and `oscConnected = true`, but no subsequent OSC message is ever processed. The misleading comment acknowledges the "not processed" case but conflates it with the "received but unparseable" case, which must be discarded:

```typescript
} catch (parseError) {
    // Log parsing errors but do not remove data that has not been processed
    break;  // ← buffer NOT advanced; same malformed payload replayed on next data event
}
```

**Impact:** A single malformed packet from the RØDECaster Video permanently freezes all inbound message processing. The module appears healthy (status `Ok`) but receives no further state updates.

**File:** `src/modules/oscController.ts` — `onDataHandler`  
**Fix direction:** After the `catch (parseError)`, advance the buffer past the known-length message: `buffer = buffer.subarray(4 + messageLength)`. Optionally log the parse error at `LogLevel.WARN`.

---

## 🟠 High

### H1 — `jimp` and `@resvg/resvg-wasm` in `dependencies` (build-only tools)

🆕 **NEW in v1.8.0** · **BLOCKING**

Both packages were added to `dependencies` in v1.8.0, but neither is imported by any `src/` TypeScript file. They are used exclusively by `tools/generate-image-map.mjs`, a developer codegen script that runs at build time to populate `src/generated/imagePng64Map.ts`. At runtime the module reads from the pre-generated map only; it has no need for image processing or WASM binaries.

Placing them in `dependencies` ships them to every Companion user who installs the module:
- `@resvg/resvg-wasm` includes a ~5 MB WASM binary.
- `jimp` is a large image-processing library.

**File:** `package.json`  
**Fix:** Move `@resvg/resvg-wasm` and `jimp` from `dependencies` to `devDependencies`.

---

### H2 — `SetPresets(instance)` called without `await` or `void`

🆕 **NEW in v1.8.0** · **BLOCKING**

`SetPresets` is declared `async function SetPresets(instance: RCVInstance): Promise<void>`. It was wired into `connectionHelpers.ts` in this release without `await` or the explicit `void` operator:

```typescript
// src/helpers/connectionHelpers.ts:78
UpdateActions(instance);
UpdateFeedbacks(instance);
SetPresets(instance);   // ← async, promise silently discarded
```

Discarding the promise means:
- Any internal errors from preset generation (e.g. failed `svgPathToCachedPng64` lookups, missing image keys) are swallowed without any log entry.
- Preset rendering completes out-of-order relative to `UpdateActions` / `UpdateFeedbacks` on reconnect.

**File:** `src/helpers/connectionHelpers.ts:78`  
**Fix:** Change to `void SetPresets(instance)` for fire-and-forget with explicit intent, or `await SetPresets(instance)` if ordering with the preceding calls matters.

---

### H3 — `imgs/` SVG sources not committed; image generator is unauditable

🆕 **NEW in v1.8.0** · **BLOCKING**

`tools/generate-image-map.mjs` reads SVG files from `./imgs/` and writes base64 PNG data to `src/generated/imagePng64Map.ts`. The `imgs/` directory is **not tracked by git** — `git ls-files | grep imgs` returns nothing. As a result:

- Running `yarn generate:images` on a clean checkout silently produces an **empty map** (no `imgs/` directory = no SVGs found). The committed generated file cannot be reproduced.
- The 451 KB of base64-encoded icon data in the repo has **no traceable source**. Reviewers and contributors cannot audit what images are being included or verify that they are appropriately licensed.
- Future contributors who need to add or modify an icon have no path forward.

**Fix:** Either commit the `imgs/` SVG source directory alongside the generated file, or clearly document (in `README.md` and a comment in `generate-image-map.mjs`) that the source SVGs are managed externally, where they live, and how to obtain them before running the generator. If sources are proprietary/externally licensed, that must be explicitly stated.

---

### H4 — `yarn package` fails: generated file not excluded from prettier

🆕 **NEW in v1.8.0** · **BLOCKING**

`yarn package` runs `prettier --check "src/**/*.ts"`, which now catches `src/generated/imagePng64Map.ts` — a 601-line auto-generated file that does not conform to the project's prettier config (and should not need to). This causes the `check-format` step to fail and the package script to exit with an error. The module **cannot be packaged for distribution** in its current state.

Additionally, Mal found a secondary cause: the `generate:images` entry in `package.json`'s `scripts` block uses a tab character followed by spaces (`\t  `) instead of the 4-space indentation used by all other entries, causing prettier to also reject `package.json` itself.

```
yarn run v1.22.x
error Command failed with exit code 1.
prettier --check: src/generated/imagePng64Map.ts (24 files fail)
```

**Files:** `.prettierignore`, `package.json`  
**Fix:** Add `src/generated/` to `.prettierignore` so generated files are excluded from format checks. Also re-indent the `generate:images` script entry in `package.json` to use 4 spaces (run `yarn format` to normalise). Verify `yarn package` completes successfully after both changes.

---

## 🟡 Medium

### M1 — `rxjs` runtime dependency added for dead `cacheUpdated$` export

🆕 **NEW in v1.8.0**

`rxjs` (~400 KB) was added to `dependencies` in v1.8.0. It is used exclusively in `imageHelpers.ts` to build a `cacheUpdated$` observable intended to notify consumers when a new PNG is cached:

```typescript
const _cacheUpdated$ = new Subject<string>();
export const cacheUpdated$ = _cacheUpdated$.asObservable().pipe(share());
// emitted inside setCachedPng64 on every new cache entry
_cacheUpdated$.next(cacheKey);
```

A full-tree search confirms **`cacheUpdated$` is never imported or subscribed to anywhere in `src/`**. The reactive notification path is entirely dead. Additionally, `destroy()` never calls `_cacheUpdated$.complete()`, leaving the Subject open after module teardown.

If the intent was to trigger `checkFeedbacks(FeedbackId.transitions)` when an async PNG load completes, the subscriber was never wired up. A plain `EventEmitter` or direct `instance.checkFeedbacks()` call in `setCachedPng64` would accomplish this without a 400 KB reactive library.

**Files:** `src/helpers/imageHelpers.ts`, `package.json`  
**Options:** Wire the subscription in the module lifecycle (subscribe in `init`/`UpdateFeedbacks`, call `_cacheUpdated$.complete()` in `destroy()`), or remove `cacheUpdated$`, the RxJS imports, and `rxjs` from `dependencies` entirely.

---

### M2 — 451 KB auto-generated file committed to `src/generated/`

🆕 **NEW in v1.8.0**

`src/generated/imagePng64Map.ts` is a 451 KB auto-generated TypeScript file containing base64-encoded PNG data. It is tracked in git and not listed in `.gitignore`. Every change to any icon asset will require regenerating and re-committing this file, producing large binary-as-text diffs that pollute the git history and make code review difficult.

The file is typed as `Record<string, string>` (an open map), meaning callers get no compile-time key validation — a typo in a key lookup produces a silent `undefined` at runtime, not a build error.

**Options:** Move generation to a `prebuild` npm script so the file is produced into `dist/` and never committed to `src/`. If committing is the intentional choice, document the workflow clearly and add a generator comment header to the file.

---

### M3 — Module status set `Ok` before init commands complete

🆕 **NEW in v1.8.0**

In `oscController.ts`, `updateStatus(InstanceStatus.Ok)` is called synchronously after firing a `void` async IIFE that performs `getRCVInfo` (2-second UDP wait) and sends `/show` + `/remote` subscribe commands. Status is set to `Ok` while the IIFE is still executing:

```typescript
void (async () => {
    await getRCVInfo(instance, ipAddress);     // 2s UDP wait
    await sendOSCCommand(...SHOW[0]);           // TCP write
    await sendOSCCommand(...REMOTE[0]);         // TCP write
})();
// ↓ runs immediately — IIFE still in-flight
instance.updateStatus(InstanceStatus.Ok, `Connected to ${ipAddress}`);
```

If `/show` or `/remote` fail (socket closed between them, write error), the errors are silently logged but status remains `Ok`. Companion users will see a healthy connection while the module may not have subscribed to show state or remote control. This is an improvement over v1.7.2's completely unhandled rejections, but the status signal remains misleading on init failure.

**File:** `src/modules/oscController.ts`  
**Recommendation:** Move `updateStatus(Ok)` inside the IIFE, after all init commands succeed. Update status to a warning or error state in the IIFE's outer catch.

---

### M4 — `parseError` catch silently breaks loop with no log output

🆕 **NEW in v1.8.0**

The inner `catch` block in the OSC data handler has a comment claiming it logs parse errors, but contains no `ConsoleLog` call:

```typescript
} catch (parseError) {
    // Log parsing errors but do not remove data that has not been processed
    break;   // ← comment says "log" but nothing is logged
}
```

When a parse error occurs — including the null-dereference scenario from C3/PE1 — the loop silently breaks. Operators have no visibility into why inbound message processing stopped, what address was being parsed, or what the raw packet looked like.

**File:** `src/modules/oscController.ts`  
**Fix:** Add `ConsoleLog(instance, \`OSC parse error: ${parseError}\`, LogLevel.ERROR, false)` inside the catch block.

---

### M5 — Dead imports: `DEFAULT_BLACK_PNG64` and `buttonPressInputsType`

🆕 **NEW in v1.8.0**

Both `src/feedbacks/feedbacks.ts` (line 20) and `src/presets/presets.ts` (lines 20, 25) import `DEFAULT_BLACK_PNG64` from `constants.ts` without ever referencing it in the file body. `presets.ts` also imports `buttonPressInputsType` without using it. These symbols were presumably intended as fallback values or type guards for the new icon rendering logic but were never wired up.

TypeScript does not catch these because `"strict": false` and `noUnusedLocals` is not set in `tsconfig.json`.

**Files:** `src/feedbacks/feedbacks.ts:20`, `src/presets/presets.ts:20,25`  
**Fix:** Either use `DEFAULT_BLACK_PNG64` as the fallback PNG (instead of returning `{}` on empty string), or remove the unused imports.

---

## 🟢 Low

### L1 — Typo "seleected" in `transitions` feedback description

🆕 **NEW in v1.8.0**

```typescript
// src/feedbacks/feedbacks.ts:1675
description: 'Set the icon to the currently seleected transition',
//                                               ^^^^^^^^ double 'e'
```

This string is visible to end-users in the Companion UI feedback picker.

**Fix:** `"seleected"` → `"selected"`.

---

### L2 — `networkInterfaces` import unused after UDP refactor

🆕 **NEW in v1.8.0**

The old `sendUdpPacket` iterated all network interfaces via `networkInterfaces()` to send per-interface broadcast packets. The v1.8.0 rewrite binds to `0.0.0.0` and routes to the known device IP directly. The `networkInterfaces` import from `'os'` was not removed.

```typescript
// src/modules/oscController.ts:13
import { networkInterfaces } from 'os';  // ← no longer used
```

**Fix:** Remove the unused import.

---

### L3 — `sendUdpPacket` never rejects; surrounding `try/catch` is dead code

🆕 **NEW in v1.8.0**

`sendUdpPacket` was refactored in v1.8.0 to always resolve (never reject) — returning an empty array on all error paths. This is a deliberate, reasonable design choice. However, both call sites continue to wrap calls in `try/catch` blocks that can never be reached:

```typescript
// connectionHelpers.ts
try {
    const rxDevices = await sendUdpPacket(...);  // never throws
} catch (err: any) {
    ConsoleLog(...);   // ← dead catch
}
```

The dead catch blocks add noise and may mislead future maintainers into thinking these code paths are exercisable.

**Fix:** Remove the `try/catch` wrappers around `sendUdpPacket` calls, or add a comment clarifying that the function always resolves.

---

### L4 — Untyped `err.message` access in outer `catch` block

🆕 **NEW in v1.8.0**

```typescript
// src/modules/oscController.ts:152-153
} catch (err) {
    ConsoleLog(instance, `Error handling incoming data: ${err.message}`, LogLevel.ERROR, false);
}
```

TypeScript `catch` binds `err` as `unknown`. Accessing `err.message` directly without a type guard is a runtime risk if a non-`Error` value is thrown, and is inconsistent with other error handlers in the file that use `err?.message ?? String(err)` or `(err as Error).message`.

**Fix:** Replace with `` `Error handling incoming data: ${(err as Error)?.message ?? String(err)}` ``.

---

### L5 — `mirror` variable name is semantically inverted relative to its use

🆕 **NEW in v1.8.0**

```typescript
// src/feedbacks/feedbacks.ts — FeedbackId.transitions callback
const mirror = !controllerVariables.transitionInvert;
const png64 = await svgPathToCachedPng64(instance, `${mirror ? transition.icon : transition.mirror_icon}`);
```

When `mirror = true` (i.e. `transitionInvert = false`), the code selects `transition.icon` — the non-mirrored icon. The variable name implies the opposite of its actual meaning. The logic is functionally correct but actively misleads readers.

**Suggestion:**
```typescript
const png64 = await svgPathToCachedPng64(
    instance,
    controllerVariables.transitionInvert ? transition.mirror_icon : transition.icon
);
```

---

### L6 — `generate:images` script uses mixed tab/space indentation in `package.json`

🆕 **NEW in v1.8.0**

The `scripts` block in `package.json` uses 4-space indentation throughout except the newly added `generate:images` entry, which begins with a tab character followed by spaces (`\t  `). This causes `prettier --check` to reject `package.json` (contributing to the H4 `yarn package` failure).

**File:** `package.json:14`  
**Fix:** Re-indent `generate:images` to use 4 spaces. Run `yarn format` to normalise.

---

## ⚠️ Pre-existing Notes

These issues were present in v1.7.2 and are not introduced by v1.8.0. They are non-blocking for this review but are documented for the maintainer's awareness.

---

### PE1 — `parseOSCBlob` returns `null` with non-nullable return type

⚠️ **PRE-EXISTING** (present in v1.7.2)

`parseOSCBlob` is declared `→ { blobSize: number; blobReturn: Uint8Array }` but its else-branch returns `null`. The caller accesses `result.blobReturn` without a null guard. If a blob-routed OSC message arrives where the type-tag byte is not `'b'`, this produces a `TypeError` that is silently swallowed by the inner `parseError` catch, dropping all remaining messages in that buffer read.

This is a notable latent crash path. Recommend adding a null return type (`| null`) to the signature and guarding at the call site.

**File:** `src/modules/oscController.ts` — `parseOSCBlob` (~line 343), caller (~line 121)

---

### PE2 — `setInterval` refresh handle discarded; never cleared in `destroy()`

⚠️ **PRE-EXISTING** (present in v1.7.2)

The 10-second state-refresh interval created in `init()` is not stored, so `destroy()` cannot clear it. After `oscClientClose` sets `_Client = null`, `sendRefresh()` logs an error every 10 seconds for the remaining lifetime of the process. Additionally, `moduleInit` is never reset in `destroy()` or `configUpdated`, so a reconnect after a config change cannot re-arm the interval.

**File:** `src/index.ts:72-76, 162-168`  
**Recommend:** Store the handle (`this.refreshInterval = setInterval(...)`) and call `clearInterval(this.refreshInterval)` + reset `this.moduleInit = false` in `destroy()`.

---

### PE3 — Manifest: missing `$schema`, non-human-readable `name`, wrong `package.json` name

⚠️ **PRE-EXISTING**

- `companion/manifest.json` is missing the `$schema` field (template recommends it for validation tooling)
- `manifest.name` is `"rode-rcv"` — should be a human-readable display name such as `"RØDECaster Video"` or `"RØDE RCV"`
- `package.json` `name` is `"rode-rcv"` — convention for Companion modules is `"companion-module-rode-rcv"`

---

### PE4 — Dev tools in `dependencies`; no `packageManager` field

⚠️ **PRE-EXISTING**

`prettier`, `typescript`, `@types/node`, and `@tsconfig/node22` are listed in `dependencies` rather than `devDependencies`. These are build tools that should not be installed in production environments. Additionally, the `packageManager` field (recommended for Yarn lockfile-aware workflows) is absent from `package.json`.

---

### PE5 — `strict: false` in `tsconfig.json`

⚠️ **PRE-EXISTING**

TypeScript strict mode is disabled, which suppresses null checks, strict function types, and `noImplicitAny`. This is what allows issues like the `parseOSCBlob` null return type mismatch (PE1) and the dead `DEFAULT_BLACK_PNG64` imports (M5) to pass the compiler silently. Consider enabling `"strict": true` incrementally.

---

### PE6 — Two OSC packages (`osc` + `osc-js`) for receive vs send

⚠️ **PRE-EXISTING**

Both `osc` (used for `osc.readPacket()` on inbound packets) and `osc-js` (used for `OSCSend.Message` on outbound packets) are present. The split is intentional — no single OSC library satisfied both use cases — but adds two dependencies where one might suffice in the future.

---

### PE7 — `isVisible` deprecated API used throughout feedbacks

⚠️ **PRE-EXISTING**

`isVisible` (deprecated in v1.x in favour of `isVisibleExpression`) is used alongside `isVisibleExpression` in `feedbacks.ts`. Under v1.x API this is Low/non-blocking (deprecated but functional). Would become Critical/blocking under v2.x (removed).

---

### PE8 — `any`-typed class members and `constructor(internal: any)` in `RCVInstance`

⚠️ **PRE-EXISTING**

`globalSettings!: any`, `states!: any`, and `actions!: any` in `src/index.ts` remove type safety for the module's core state bags. `constructor(internal: any)` should be typed via `InstanceBase`'s generic parameter.

---

### PE9 — Jest in `devDependencies` but Mocha is the test runner

⚠️ **PRE-EXISTING**

Jest 30.2.0 is present in `devDependencies` but is not used — Mocha is the actual test runner (per the `test` script in `package.json`). The unused Jest devDep may cause confusion. Consider removing it or adding a comment explaining its presence.

---

## 🧪 Tests

**Framework:** Mocha 11.7.5 + Chai 6.2.2 + Sinon 21.0.1 + esmock 2.7.3  
**Result:** ✅ **69/69 passing** (~969ms)  
**Coverage:** `tests/helpers/` (5 files) + `tests/modules/oscController.test.ts` + `tests/events/recievedDataHandler.test.ts`

**Changes v1.7.2 → v1.8.0:**
- `connectionHelpers.test.ts`: Fixed mutation test assertion (now correctly validates immutability), updated log message to match renamed discovery log.
- `oscController.test.ts`: Major infrastructure upgrade — `FakeDgramSocket` now accurately mimics `dgram.Socket` API (added `sentPackets` tracking, `address()`, proper `bind()` signature). Removed stale `networkInterfaces` mock. Deleted multi-interface broadcast discovery test (superseded by unicast refactor). Added **2 new error handling tests** for UDP send failures and socket error events.

No test regressions. Test infrastructure is healthy and well-maintained.

---

## ✅ What's Solid

- **69/69 tests passing** with a mature Mocha + Chai + Sinon stack and meaningful ESM mocking
- **UDP unicast refactor** is a genuine improvement: simpler than the old per-interface broadcast approach, properly typed, and the `settled`/`finish()` cleanup pattern handles all error paths robustly
- **Post-disconnect guard** in `getRCVInfo` correctly prevents stale device info from being applied after a mid-discovery disconnect
- **Reconnect state machine** (`intentionalDisconnect` + `reconnecting` + timer guard) is sound and unchanged — double-connect races handled correctly
- **`rejectUnauthorized`-aware connection** logic and explicit error/close handler separation are clean
- **New error coverage in tests** — the 2 new UDP error tests (send failure, socket error) improve confidence in the refactored path
- **Image preset infrastructure** concept is solid: pre-generating PNG base64 at build time is the right approach to avoid runtime SVG rendering costs; just needs the blocking issues resolved to ship cleanly
