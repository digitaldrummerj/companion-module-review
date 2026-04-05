# Review — companion-module-spacecommz-intercom v1.1.0

**Module:** companion-module-spacecommz-intercom  
**Version:** v1.1.0  
**Previous version:** v1.0.0  
**API:** `@companion-module/base` ^1.8.0 (v1.x rules)  
**Language:** TypeScript  
**Review date:** 2026-04-05  

---

## Verdict

**❌ CHANGES REQUIRED** — 10 blocking issues: 1 new Critical (missing upgrade script for breaking feedback change), 3 pre-existing Critical (server resource leak, missing template files, package.json violations), 1 High regression (talkState returns wrong value), 3 pre-existing High (no listen error handling, array out-of-bounds in actions and feedbacks), and 2 new Medium (disconnect status regression, no Socket.IO error handling).

---

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 1 | 3 | 4 |
| 🟠 High | 1 | 3 | 4 |
| 🟡 Medium | 2 | 5 | 7 |
| 🟢 Low | 0 | 7 | 7 |
| 💡 Nice to Have | 0 | 3 | 3 |
| **Total** | **4** | **21** | **25** |

**Blocking:** 10 issues (1 new critical, 3 pre-existing critical, 1 regression high, 3 pre-existing high, 2 new medium)  
**Fix complexity:** Complex — server lifecycle rewrite, template overhaul, upgrade script authoring, regression fix  
**Health delta:** 4 introduced · 6 pre-existing surfaced

---

## 📋 Table of Contents

### Blocking

- [C1 — HTTP/Socket.IO server not closed in `destroy()`](#c1--httpsocketio-server-not-closed-in-destroy) ⚠️ Pre-existing
- [C2 — Missing required template files](#c2--missing-required-template-files) ⚠️ Pre-existing
- [C3 — `package.json` template violations](#c3--packagejson-template-violations) ⚠️ Pre-existing
- [C4 — Missing upgrade script for `listenState` feedback type change](#c4--missing-upgrade-script-for-listenstate-feedback-type-change) 🆕 New
- [H1 — `talkState` feedback returns `{}` instead of `false`](#h1--talkstate-feedback-returns--instead-of-false) 🔙 Regression
- [H2 — No error handling on HTTP server listen](#h2--no-error-handling-on-http-server-listen) ⚠️ Pre-existing
- [H3 — Array out-of-bounds in action callbacks](#h3--array-out-of-bounds-in-action-callbacks) ⚠️ Pre-existing
- [H4 — Array out-of-bounds in feedback callbacks](#h4--array-out-of-bounds-in-feedback-callbacks) ⚠️ Pre-existing
- [M1 — Disconnect handler no longer resets module status](#m1--disconnect-handler-no-longer-resets-module-status) 🆕 New
- [M2 — No error handling on Socket.IO event handlers](#m2--no-error-handling-on-socketio-event-handlers) 🆕 New

### Non-blocking

- [M3 — `configUpdated()` doesn't restart server when port changes](#m3--configupdated-doesnt-restart-server-when-port-changes)
- [M4 — `console.log` used instead of `this.log()`](#m4--consolelog-used-instead-of-thislog)
- [M5 — `.gitignore` deviates from template](#m5--gitignore-deviates-from-template)
- [M6 — `main` field has leading slash](#m6--main-field-has-leading-slash)
- [M7 — Missing `$schema` in `manifest.json`](#m7--missing-schema-in-manifestjson)
- [L1 — `@companion-module/base` and tools significantly outdated](#l1--companion-modulebase-and-tools-significantly-outdated)
- [L2 — `pls` typed as `any` with no interface](#l2--pls-typed-as-any-with-no-interface)
- [L3 — `checkFeedbacks()` references commented-out `soloState` feedback](#l3--checkfeedbacks-references-commented-out-solostate-feedback)
- [L4 — Manifest `runtime.type` is `node18`](#l4--manifest-runtimetype-is-node18)
- [L5 — `@ts-ignore` comments masking real type issues](#l5--ts-ignore-comments-masking-real-type-issues)
- [L6 — Commented-out code left in source](#l6--commented-out-code-left-in-source)
- [L7 — Mute preset overwritten on every loop iteration](#l7--mute-preset-overwritten-on-every-loop-iteration)
- [N1 — Manifest version should be `0.0.0`](#n1--manifest-version-should-be-000)
- [N2 — Unsafe CORS configuration](#n2--unsafe-cors-configuration)
- [N3 — Loose `tsconfig.json` strictness settings](#n3--loose-tsconfigjson-strictness-settings)
- [⚠️ Pre-existing Notes](#️-pre-existing-notes)
- [🧪 Tests](#-tests)
- [✅ What's Solid](#-whats-solid)
- [Fix Summary for Maintainer](#fix-summary-for-maintainer)

---

## 🔴 Critical

### C1 — HTTP/Socket.IO server not closed in `destroy()`

**Classification:** ⚠️ PRE-EXISTING  
**File:** `src/main.ts`, lines 108–114

The HTTP server (`this.http`) and Socket.IO server (`this.io`) are created in the constructor (lines 27–33) and started in `init()` (line 64), but `destroy()` only clears `barInterval`. Neither server is ever closed.

**Impact:** The port remains bound after the module is deleted or restarted. This prevents restarts on the same port, leaves active WebSocket connections open, and accumulates duplicate event handlers if `init()` is called more than once on the same instance.

**Current:**
```typescript
async destroy(): Promise<void> {
    if (this.barInterval) {
        clearInterval(this.barInterval)
        this.barInterval = null
    }
    this.log('debug', 'destroy')
    // ❌ Missing: this.io.close() and this.http.close()
}
```

**Required:**
```typescript
async destroy(): Promise<void> {
    if (this.barInterval) {
        clearInterval(this.barInterval)
        this.barInterval = null
    }
    if (this.io) {
        this.io.removeAllListeners()
        await new Promise<void>((resolve) => this.io.close(() => resolve()))
    }
    if (this.http) {
        await new Promise<void>((resolve, reject) =>
            this.http.close((err) => (err ? reject(err) : resolve()))
        )
    }
    this.log('debug', 'destroy')
}
```

---

### C2 — Missing required template files

**Classification:** ⚠️ PRE-EXISTING

The following files required by the TypeScript template are absent from the repository:

| Missing file | Purpose |
|---|---|
| `.gitattributes` | `* text=auto eol=lf` — enforces consistent line endings |
| `.yarnrc.yml` | `nodeLinker: node-modules` — required for Yarn 4 |
| `LICENSE` | MIT license (declared in `package.json` and `manifest.json`) |
| `eslint.config.mjs` | ESLint configuration (see template for exact content) |
| `.husky/pre-commit` | Git hook that runs `lint-staged` before commits |

**Action required:** Copy each of these from `companion-module-template-ts/` and commit them.

---

### C3 — `package.json` template violations

**Classification:** ⚠️ PRE-EXISTING  
**File:** `package.json`

Multiple required fields are missing or wrong:

| Field | Current | Required |
|---|---|---|
| `"type"` | *(missing)* | `"module"` |
| `"engines"` | *(missing)* | `{ "node": "^22.20", "yarn": "^4" }` |
| `"packageManager"` (line 35) | `yarn@1.22.22` | `yarn@4.12.0` |
| `"main"` (line 4) | `"/dist/main.js"` (leading `/`) | `"dist/main.js"` |
| `"scripts.package"` | `"npm run build && ..."` | `"run build && ..."` |
| `"scripts.postinstall"` | *(missing)* | `"husky"` |
| `"scripts.lint:raw"` | *(missing)* | `"eslint"` |
| `"scripts.lint"` | *(missing)* | `"run lint:raw ."` |
| `"lint-staged"` section | *(missing)* | See template |
| devDep: `eslint` | *(missing)* | `^9.39.2` |
| devDep: `husky` | *(missing)* | `^9.1.7` |
| devDep: `prettier` | *(missing)* | `^3.7.4` |
| devDep: `rimraf` | *(missing)* | `^6.1.2` |
| devDep: `typescript-eslint` | *(missing)* | `^8.51.0` |
| devDep: `@types/node` (line 30) | `^18.0.4` | `^22.19.3` |

**Action required:** Update `package.json` to match `companion-module-template-ts/package.json`. After updating `packageManager` to Yarn 4, delete `node_modules/` and re-run `yarn install`.

---

### C4 — Missing upgrade script for `listenState` feedback type change

**Classification:** 🆕 NEW  
**File:** `src/upgrades.ts` (line 4) / `src/feedbacks.ts`

Between v1.0.0 and v1.1.0, the `listenState` feedback changed from `type: 'boolean'` (with `defaultStyle`) to `type: 'advanced'` (returning a dynamic style object with audio bar visualization). This is a breaking change — existing saved buttons using `listenState` will lose their configured style after upgrading.

`UpgradeScripts` is currently an empty array (`[]`), which means no migration runs on upgrade.

**Action required:** Add a migration function in `src/upgrades.ts`:

```typescript
export const UpgradeScripts: CompanionStaticUpgradeScript<ModuleConfig>[] = [
    function v110_listenStateFeedbackTypeChange(_context, props) {
        const updatedFeedbacks = []
        for (const feedback of props.feedbacks ?? []) {
            if (feedback.feedbackId === 'listenState') {
                // Remove the old boolean-style options that no longer apply
                const { ...options } = feedback.options
                delete options['fg']
                delete options['bg']
                updatedFeedbacks.push({ ...feedback, options })
            } else {
                updatedFeedbacks.push(feedback)
            }
        }
        return { updatedConfig: null, updatedActions: [], updatedFeedbacks }
    },
]
```

Adjust the transform to match the actual option keys that changed. The key requirement is that an upgrade function exists so Companion runs the migration on first load after upgrade.

---

## 🟠 High

### H1 — `talkState` feedback returns `{}` instead of `false`

**Classification:** 🔙 REGRESSION (changed in v1.1.0)  
**File:** `src/feedbacks.ts`, line 38

The `talkState` feedback is declared as `type: 'boolean'` (line 26) but now returns `{}` (empty object) when the PL index doesn't exist. In v1.0.0 this correctly returned `false`. Because `{}` is truthy, the feedback incorrectly displays the "talk active" style when no PL exists at the requested index.

**v1.0.0 (correct):** `return false`  
**v1.1.0 (broken):** `return {}`

**Fix:** Change line 38 back to `return false`.

---

### H2 — No error handling on HTTP server listen

**Classification:** ⚠️ PRE-EXISTING  
**File:** `src/main.ts`, lines 64–66

`http.listen()` has no error handler. If the port is already in use (`EADDRINUSE`), the error is thrown unhandled, the module status stays `Connecting` indefinitely, and the user gets no diagnostic information.

**Required:**
```typescript
this.http.on('error', (err: NodeJS.ErrnoException) => {
    const msg = err.code === 'EADDRINUSE'
        ? `Port ${this.config.port} already in use`
        : `Server error: ${err.message}`
    this.updateStatus(InstanceStatus.ConnectionFailure, msg)
    this.log('error', `HTTP server error: ${err.message}`)
})
this.http.listen(this.config.port, () => {
    this.log('info', `Server listening on port ${this.config.port}`)
})
```

---

### H3 — Array out-of-bounds in action callbacks

**Classification:** ⚠️ PRE-EXISTING  
**File:** `src/actions.ts`, lines 19, 28

Both `listenPlByIndex` and `talkPlByIndex` access `self.pls[event.options.index - 1].id` without bounds checking. If an operator configures an index beyond the current PL list, this throws `TypeError: Cannot read property 'id' of undefined` and crashes the action.

**Fix:**
```typescript
const index = (event.options.index as number) - 1
if (index < 0 || index >= self.pls.length) {
    self.log('warn', `PL index ${event.options.index} out of range (1–${self.pls.length})`)
    return
}
self.io.emit('listenPL', self.pls[index].id)
```

Apply the same pattern to `talkPlByIndex`.

---

### H4 — Array out-of-bounds in feedback callbacks

**Classification:** ⚠️ PRE-EXISTING  
**File:** `src/feedbacks.ts`, lines 34–40, 47–50

Both `talkState` and `listenState` feedbacks access `self.pls[index]` but only check for the value being falsy (returning `{}` silently). There is no logging when the index is out of range, making it impossible to diagnose misconfigured buttons.

**Fix:** Add a log when the index is out of range before returning the fallback value:
```typescript
if (!self.pls[index]) {
    self.log('warn', `Feedback index ${feedback.options.index} out of range`)
    return false  // or {} for advanced feedbacks
}
```

---

## 🟡 Medium

### M1 — Disconnect handler no longer resets module status

**Classification:** 🆕 NEW (behavior removed in v1.1.0)  
**File:** `src/main.ts`, lines 40–42

In v1.0.0, when a socket disconnected, the module set status back to `InstanceStatus.Connecting`. In v1.1.0 this was removed — only a `console.log` remains. When the last connected client disconnects, module status stays `Ok` even though nothing is connected.

If the intent is to support multiple simultaneous clients, add connected-client tracking and reset status when the count reaches zero.

---

### M2 — No error handling on Socket.IO event handlers

**Classification:** 🆕 NEW  
**File:** `src/main.ts`, lines 38–63

The `updatePls`, `updateActivePls`, and `updateMute` event handlers have no `try/catch`. If any handler throws on malformed data (e.g., `null` or a string where an object is expected), the error propagates uncaught and may terminate the socket connection.

**Fix:** Wrap each handler body in `try/catch` and validate the incoming message shape before processing.

---

### M3 — `configUpdated()` doesn't restart server when port changes

**Classification:** ⚠️ PRE-EXISTING  
**File:** `src/main.ts`, lines 116–118

Changing the port in config has no effect until the module is fully restarted. `configUpdated()` only stores the new config without tearing down the old HTTP server and starting on the new port.

---

### M4 — `console.log` used instead of `this.log()`

**Classification:** ⚠️ PRE-EXISTING  
**Files:** `src/main.ts` lines 41, 44, 59, 65; `src/feedbacks.ts` line 35

These log calls bypass Companion's logging system and won't appear in the Companion UI or logs. Replace with `this.log('debug', ...)` / `self.log('debug', ...)`.

---

### M5 — `.gitignore` deviates from template

**Classification:** ⚠️ PRE-EXISTING  
**File:** `.gitignore`

`/pkg.tgz` should be `/*.tgz` (to ignore all tarballs). `ReleaseV1.zip` is an extra line not in the template. Missing `/.yarn` and `/.vscode` entries.

---

### M6 — `main` field has leading slash

**Classification:** ⚠️ PRE-EXISTING  
**File:** `package.json`, line 4

`"/dist/main.js"` resolves as an absolute filesystem path. Remove the leading slash: `"dist/main.js"`.

---

### M7 — Missing `$schema` in `manifest.json`

**Classification:** ⚠️ PRE-EXISTING  
**File:** `companion/manifest.json`

Template includes `"$schema": "../node_modules/@companion-module/base/assets/manifest.schema.json"` for IDE validation. Add it as the first field.

---

## 🟢 Low

### L1 — `@companion-module/base` and tools significantly outdated

**Classification:** ⚠️ PRE-EXISTING  
**File:** `package.json`, lines 18, 28

`@companion-module/base` is `^1.8.0` — template uses `~1.14.1`. `@companion-module/tools` was bumped from `^1.4.2` to `^1.5.2` in this release — template uses `^2.6.1`. The module misses 6+ versions of API improvements.

---

### L2 — `pls` typed as `any` with no interface

**Classification:** ⚠️ PRE-EXISTING  
**File:** `src/main.ts`, line 18

`pls: any = []` is untyped. All access to `.id`, `.name`, `.talk`, `.listen`, `.solo` is unguarded. Multiple `@ts-ignore` comments exist as a workaround.

---

### L3 — `checkFeedbacks()` references commented-out `soloState` feedback

**Classification:** ⚠️ PRE-EXISTING  
**File:** `src/main.ts`, line 49

`this.checkFeedbacks('soloState', 'talkState', 'listenState')` — `soloState` is commented out in `feedbacks.ts` (lines 8–24). The call is a no-op but is confusing.

---

### L4 — Manifest `runtime.type` is `node18`

**Classification:** ⚠️ PRE-EXISTING  
**File:** `companion/manifest.json`, line 14

Template uses `node22`. Update to `node22` for Node security patches. Also update `tsconfig.build.json` to extend `@companion-module/tools/tsconfig/node22/recommended` (currently extends `node18/recommended`).

---

### L5 — `@ts-ignore` comments masking real type issues

**Classification:** ⚠️ PRE-EXISTING  
**Files:** `src/actions.ts` lines 10, 18, 27, 34; `src/preset.ts` line 6; `src/variables.ts` lines 6–7

Suppressing type errors instead of fixing the underlying untyped `pls` array. Define a `PLItem` interface (see L2) and remove the suppressions.

---

### L6 — Commented-out code left in source

**Classification:** ⚠️ PRE-EXISTING  
**Files:** `src/actions.ts` lines 5–13; `src/feedbacks.ts` lines 8–24

`soloPlByIndex` action and `soloState` feedback are commented out. Remove or document why they are kept.

---

### L7 — Mute preset overwritten on every loop iteration

**Classification:** ⚠️ PRE-EXISTING  
**File:** `src/preset.ts`, lines 78–112

The `mute` preset is defined inside the `self.pls.forEach(...)` loop, so it is overwritten N times. Move it outside the loop — only one mute preset should exist.

---

## 💡 Nice to Have

### N1 — Manifest version should be `0.0.0`

**File:** `companion/manifest.json`, line 5  
Current value `"1.1.0"` matches `package.json` (so not a violation), but the convention is `"0.0.0"`.

---

### N2 — Unsafe CORS configuration

**File:** `src/main.ts`, lines 29–31  
`origin: '*'` is standard for local-only Companion modules. Add a comment confirming this is intentional.

---

### N3 — Loose `tsconfig.json` strictness settings

**File:** `tsconfig.json`  
Compare against `companion-module-template-ts/tsconfig.json` and tighten to match template strictness (`strict: true`, etc.).

---

## ⚠️ Pre-existing Notes

These were present in v1.0.0 and are surfaced for the maintainer's awareness. They do not affect this review's verdict.

| Finding | File:Line | Notes |
|---|---|---|
| `configUpdated()` doesn't restart server on port change | `src/main.ts:116–118` | Changing port has no effect until full restart |
| `console.log` bypasses Companion logs | Multiple | See M4 |
| Missing `.js` extension on import | `src/preset.ts:2` | `from './main'` should be `from './main.js'` — will break if `"type": "module"` is added |

---

## 🧪 Tests

No tests present — none required. The module contains 9 TypeScript source files with no Jest, Vitest, or test script configuration.

---

## ✅ What's Solid

- `runEntrypoint(ModuleInstance, UpgradeScripts)` correctly called at the bottom of `src/main.ts`
- All four lifecycle methods implemented: `init()`, `destroy()`, `configUpdated()`, `getConfigFields()`
- Source code properly in `src/` — not at repo root
- No `package-lock.json` — yarn-only ✅
- No `dist/` committed ✅
- `yarn build` succeeds when Node version constraints are worked around
- `.js` extensions on relative imports throughout (one exception in `preset.ts`)
- New `listenState` advanced feedback with animated audio bar visualization is a well-executed feature using `companion-module-utils` graphics
- New `barInterval` is properly cleaned up in `destroy()`
- Good `HELP.md` — real documentation, not placeholder content
- Valid maintainer info — not placeholder values
- Correct repository URL and module ID
- Clean keywords — no banned terms

---

## Fix Summary for Maintainer

The following changes are required before this release can be approved.

**New issues introduced in v1.1.0 (fix these first):**

1. **`src/upgrades.ts`** — Add a migration function for the `listenState` feedback type change (boolean → advanced). Existing saved buttons will break on upgrade without it. (C4)
2. **`src/feedbacks.ts`, line 38** — Change `return {}` back to `return false` in `talkState` feedback. (H1)
3. **`src/main.ts`, lines 40–42** — Restore `InstanceStatus.Connecting` when the last socket disconnects, or add client-count tracking if multiple simultaneous clients are intended. (M1)
4. **`src/main.ts`, lines 38–63** — Wrap Socket.IO event handlers (`updatePls`, `updateActivePls`, `updateMute`) in `try/catch` with input validation. (M2)

**Pre-existing issues that now block approval:**

5. **`src/main.ts`, lines 108–114** — Close both `this.io` and `this.http` in `destroy()`. (C1)
6. **Repo root** — Add `.gitattributes`, `.yarnrc.yml`, `LICENSE`, `eslint.config.mjs`, and `.husky/pre-commit`. (C2)
7. **`package.json`** — Add `"type": "module"`, `"engines"`, fix `"packageManager"` to Yarn 4, fix `"main"` (remove leading `/`), add missing scripts and devDependencies. (C3)
8. **`src/main.ts`, lines 64–66** — Add an error handler to `http.listen()` for `EADDRINUSE` and other failures. (H2)
9. **`src/actions.ts`, lines 19, 28** — Add bounds checking before accessing `self.pls[index]`. (H3)
10. **`src/feedbacks.ts`, lines 34–50** — Add bounds logging when PL index is out of range. (H4)
