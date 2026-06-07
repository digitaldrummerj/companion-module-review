# Review — klang-app v2.1.2 and v2.2.1

| | |
|---|---|
| **Module** | klang-app (`KLANG:app`) |
| **Review tag** | v2.1.2, v2.2.1 | 
| **Previous tag** | v1.0.2 |
| **Scope** | `tag` (only the `v1.0.2..v2.1.2` diff — a full v1→v2 rewrite, so effectively the whole `src/` is new) |
| **Language / API** | TypeScript · @companion-module/base v2.x (`~2.0.3`) |
| **Protocol** | OSC (UDP) |
| **Template** | companion-module-template-ts |
| **Build / Lint** | ✅ `yarn install --immutable`, `yarn package`, `yarn lint` all pass |
| **Reviewed** | 2026-06-06 |

> **Note on the checkout.** The clone's default branch (`main`) is at `v2.2.1`; this review was run against the submitted tag **`v2.1.2`**. Running the deterministic checks against `main` produced a spurious `PKG-VERSION` mismatch (`2.2.1` ≠ `2.1.2`) that disappears at the correct tag — it is **not** a finding.

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 2| 0 | 2 |
| 🟠 High | 1 | 0 | 1 |
| 🟡 Medium | 3 | 0 | 3 |
| 🟢 Low | 0 | 0 | 0 |
| 💡 Nice to Have | 0 | 0 | 0 |
| **Total** | **6** | **0** | **6** |

## Verdict: ❌ Changes Required

## 📋 Issues

**Blocking**

- [ ] [C3: LICENSE differs from template](#c3-license-differs-from-template)
- [ ] [C5: tsconfig.build.json differs from template](#c5-tsconfigbuildjson-differs-from-template)
- [ ] [H1: Connection status reports Ok regardless of socket state](#h1-connection-status-reports-ok-regardless-of-socket-state)

**Non-blocking**

- [ ] [M2: module-level action arrays can be moved to the `UpdateActions()`](#m2-module-level-action-arrays-can-be-moved-to-the-updateactions)
- [ ] [M3: sendCommand has no readiness guard or error handling](#m3-sendcommand-has-no-readiness-guard-or-error-handling)
- [ ] [M4: presets are typed as Record string any](#m4-presets-are-typed-as-record-string-any)

## 🔴 Critical

### C3: LICENSE differs from template

**File:** `LICENSE:1` · **Source:** deterministic template check (`LICENSE-DIFF`)

```
Template expects:  MIT License
Found:             The MIT License
```

Only the copyright line may differ from the template's MIT text; the title line must match.

**Fix:** Replace `LICENSE` with the template's exact MIT text, changing only the copyright holder/year line.

### C5: tsconfig.build.json differs from template

**File:** `tsconfig.build.json:7` · **Source:** deterministic template check (`CONFIG-DIFF`)

```
Template:  "rootDir": "./src",
Found:     "baseUrl": "./",
```

The template pins `rootDir` so emitted output lands flat in `dist/` (matching the `../dist/main.js` entrypoint). The module dropped `rootDir` and added `baseUrl` instead. The build still produces a correct `dist/main.js` (TypeScript infers `rootDir` from the common input path under `src/`, and packaging passed), so this is **not currently broken** — but it diverges from the template gate and `baseUrl` here serves no purpose.

**Fix:** Restore `"rootDir": "./src"` and remove the unneeded `"baseUrl"` to match the template.

## 🟠 High

### H1: Connection status reports Ok regardless of socket state

**Files:** `src/main.ts:27`, `src/main.ts:47`, `src/osc.ts:50-54`, `src/osc.ts:60-63`

The instance status does not reflect the real socket state:

- `init()` (main.ts:27) and `configUpdated()` (main.ts:47) call `this.updateStatus(InstanceStatus.Ok)` **synchronously**, right after `new OSC(this)` — before the UDP port has bound. This overwrites the `Connecting` status that `OSC.Connect()` just set (osc.ts:35).
- The socket `'error'` handler (osc.ts:50-54) only **logs** on `EADDRINUSE` and silently drops every other error. It never calls `updateStatus(InstanceStatus.ConnectionFailure / UnknownError)`.

Net effect: if the receive port fails to bind (e.g. port 8000 already in use — see H2) or any socket error occurs, the module still shows green **Ok**. Operators get no signal that inbound OSC is dead.

**Fix:** Let `OSC` own all status transitions — remove the eager `updateStatus(Ok)` from `init()`/`configUpdated()`; keep `Ok` only in the `'ready'` handler; and in the `'error'` handler call `this.instance.updateStatus(InstanceStatus.ConnectionFailure, err.message)` (use `UnknownError` for unexpected codes) and log every error, not just `EADDRINUSE`.


## 🟡 Medium

### M2: module-level action arrays can be moved to the UpdateActions

**File:** `src/actions.ts:3-4`, `src/actions.ts:17-18`

`MIX_CHOICES` and `CHANNEL_CHOICES` are module-level `let` arrays, reassigned inside `UpdateActions()`.

**Fix:** Build the choice arrays as **locals** inside `UpdateActions()` (they are already rebuilt there each call — just remove the module-level aliases and reference the locals in the option definitions).

### M3: sendCommand has no readiness guard or error handling

**File:** `src/osc.ts:72-82`

`sendCommand()` calls `this.udpPort.send(...)` with no check that the port is open and no `try/catch`. The `osc` library guards a *missing* socket (it fires a closed-port error rather than throwing — `osc-node.js:112`), so a send before `'ready'` is tolerated, but a send **after `destroy()`** hits a closed dgram socket and throws synchronously inside the action callback. Combined with H1, send failures also never reflect in status.

**Fix:** Track a `ready` flag (set on `'ready'`, cleared on `'close'`/`'error'`/`destroy`), guard `sendCommand` on it, wrap the `send()` in `try/catch`, and surface failures via `updateStatus`.

### M4: presets are typed as Record string any

**File:** `src/presets.ts:14`

`const presets: Record<string, any> = {}` (and an untyped `structure`) means a typo in a preset `actionId` or `style` would not be caught at compile time — and several `actionId`s must exactly match keys in `actions.ts`. (The v2 two-argument `setPresetDefinitions(structure, presets)` form at `presets.ts:371` is correct.)

**Fix:** Type `presets` as `CompanionPresetDefinitions` and import the preset-structure type so the definitions are validated.
