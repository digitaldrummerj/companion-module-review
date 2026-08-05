# Review: companion-module-malighting-grandma3 v1.4.0

| | |
| --- | --- |
| **Module** | `malighting-grandma3` |
| **Review tag** | `v1.4.0` |
| **Previous tag** | `v1.2.2` |
| **Scope** | `tag` — only the `v1.2.2..v1.4.0` diff |
| **Language / API** | TypeScript · `@companion-module/base` `~1.14.1` (v1.x) |
| **Protocol** | OSC (`node-osc` ^11.3.0) |
| **Build / Lint** | ✅ `yarn build` pass · ✅ `yarn lint` pass |
| **Reviewed** | 2026-08-03 |

**What changed in this release:** the module gained an OSC *receive* path (`node-osc` `Server`), a new `sequence_active` feedback (`src/feedbacks.ts`), a state cache (`src/cache.ts`), reworked config fields (`src/config.ts`), plus issue templates, a `configuration-examples/` folder and dependency bumps.

Template/build compliance checks are full-module by nature and are included regardless of scope, since a release that breaks the template or runtime target can't ship.

---

## Verdict: ❌ Changes Required

---

## 📋 Issues

**Blocking**

- [ ] [C1: Config key prefix renamed to inputPrefix with no upgrade script](#c1-config-key-prefix-renamed-to-inputprefix-with-no-upgrade-script)
- [ ] [C2: destroy() never closes the OSC server](#c2-destroy-never-closes-the-osc-server)
- [ ] [C4: manifest.json runtime.type is node18, must be node22](#c4-manifestjson-runtimetype-is-node18-must-be-node22)
- [ ] [C5: tsconfig.build.json extends the node18 preset, must be node22](#c5-tsconfigbuildjson-extends-the-node18-preset-must-be-node22)
- [ ] [C6: package.json is missing the required engines field](#c6-packagejson-is-missing-the-required-engines-field)
- [ ] [C7: .gitattributes is missing](#c7-gitattributes-is-missing)
- [ ] [C8: .gitignore is missing template entries](#c8-gitignore-is-missing-template-entries)
- [ ] [H1: configUpdated() never re-initialises the OSC server](#h1-configupdated-never-re-initialises-the-osc-server)

**Non-blocking**

- [ ] [M2: @ts-expect-error disables type checking of the whole feedback callback](#m2-ts-expect-error-disables-type-checking-of-the-whole-feedback-callback)
- [ ] [M6: Unguarded await oscServer.close() can reject out of init()](#m6-unguarded-await-oscserverclose-can-reject-out-of-init)
- [ ] [M7: InstanceStatus is set to Ok before the socket binds and never recovers from ConnectionFailure](#m7-instancestatus-is-set-to-ok-before-the-socket-binds-and-never-recovers-from-connectionfailure)
- [ ] [L4: seqCache is untyped and is never cleared on destroy or reconfigure](#l4-seqcache-is-untyped-and-is-never-cleared-on-destroy-or-reconfigure)
- [ ] [L8: Leftover German comments, stray braces in log strings and a config typo](#l8-leftover-german-comments-stray-braces-in-log-strings-and-a-config-typo)


---

## 🔴 Critical

### C1: Config key prefix renamed to inputPrefix with no upgrade script

**File:** `src/config.ts:6`, `src/actions.ts:9-11`, `src/upgrades.ts:33`
**Classification:** 🆕 NEW

v1.2.2 stored the OSC prefix under `prefix`; v1.4.0 reads `self.config.inputPrefix`. `UpgradeScripts` still contains only `updateExecButtonPageFromDropdownToInteger` — nothing migrates the old key.

`@companion-module/base` only applies config-field defaults when the connection is first created; an upgraded connection keeps its stored config object verbatim. So for every existing user who set a prefix, `inputPrefix` is `undefined`, the `if (self.config.inputPrefix)` branch in `sendOscMessage` is skipped, and **every action is sent to a bare `/cmd` path** that grandMA3 ignores. The module appears completely dead after the update, with no error shown.

**Suggested fix** — add an upgrade script to `UpgradeScripts`:

```ts
function migratePrefixAndPorts(
 _context: CompanionUpgradeContext<ModuleConfig>,
 props: CompanionStaticUpgradeProps<ModuleConfig>,
): CompanionStaticUpgradeResult<ModuleConfig> {
 const result: CompanionStaticUpgradeResult<ModuleConfig> = {
  updatedActions: [],
  updatedConfig: null,
  updatedFeedbacks: [],
 }
 const cfg = props.config as (ModuleConfig & { prefix?: string }) | null
 if (!cfg) return result

 let changed = false
 if (cfg.inputPrefix === undefined) {
  cfg.inputPrefix = cfg.prefix ?? ''
  delete cfg.prefix
  changed = true
 }
 if (cfg.outputPrefix === undefined) { cfg.outputPrefix = ''; changed = true }
 if (cfg.feedbackPort === undefined) { cfg.feedbackPort = '8082'; changed = true }

 if (changed) result.updatedConfig = cfg
 return result
}
```

---

### C2: destroy() never closes the OSC server

**File:** `src/main.ts:27-29`
**Classification:** 🆕 NEW

```ts
async destroy(): Promise<void> {
 this.log('debug', 'Module destroyed')
}
```

`initOSC()` binds a UDP socket on `feedbackPort` and attaches `'message'` / `'error'` listeners, and nothing tears them down. Companion supports `init()` after `destroy()` in the same process, so after a destroy the leaked socket keeps firing `handleOSCMessage` → `checkFeedbacks()` against a torn-down instance, and the port stays bound — so a subsequent re-init cannot get a clean bind on the same port.

**Suggested fix:**

```ts
async destroy(): Promise<void> {
 if (this.oscServer) {
  try {
   await this.oscServer.close()
  } catch (e) {
   this.log('debug', `OSC close failed: ${e instanceof Error ? e.message : String(e)}`)
  }
  this.oscServer = null
 }
 this.seqCache.clear()
 this.log('debug', 'Module destroyed')
}
```

---

### C4: manifest.json runtime.type is node18, must be node22

**File:** `companion/manifest.json`
**Classification:** 🆕 NEW · deterministic template check `MAN-RUNTIME`

```json
"runtime": { "type": "node18", ... }
```

The current template targets `node22`. Change `runtime.type` to `"node22"`.

---

### C5: tsconfig.build.json extends the node18 preset, must be node22

**File:** `tsconfig.build.json:2`
**Classification:** 🆕 NEW · deterministic template check `CONFIG-DIFF`

Found `"extends": "@companion-module/tools/tsconfig/node18/recommended"`; the template uses `"@companion-module/tools/tsconfig/node22/recommended"`. Update it together with [C4](#c4-manifestjson-runtimetype-is-node18-must-be-node22) and [C6](#c6-packagejson-is-missing-the-required-engines-field) so the compile target, the declared engine and the declared runtime all agree.

---

### C6: package.json is missing the required engines field

**File:** `package.json`
**Classification:** 🆕 NEW · deterministic template check `PKG-FIELD`

The template declares:

```json
"engines": {
 "node": "^22.20",
 "yarn": "^4"
},
```

Add it.

---

### C7: .gitattributes is missing

**File:** `.gitattributes`
**Classification:** 🆕 NEW · deterministic template check `FILE-MISSING`

Copy the file from the official TS v1 template — it is required and normalises line endings for contributors on Windows.

---

### C8: .gitignore is missing template entries

**File:** `.gitignore`
**Classification:** 🆕 NEW · deterministic template check `CONFIG-DIFF`

Missing entries: `/*.tgz` and `/.vscode`. The repo currently pins `/pkg.tgz`, which does not cover the versioned tarballs `companion-module-build` produces. Replace `/pkg.tgz` with `/*.tgz` and add `/.vscode`.

---

## 🟠 High

### H1: configUpdated() never re-initialises the OSC server

**File:** `src/main.ts:123-125`
**Classification:** 🆕 NEW

```ts
async configUpdated(config: ModuleConfig): Promise<void> {
 this.config = config
}
```

Companion calls `configUpdated()` without re-running `init()`. Changing **grandMA3 Output Port** therefore has no effect — the server stays bound to the old port, with no warning — until the user disables and re-enables the connection.

**Suggested fix:**

```ts
async configUpdated(config: ModuleConfig): Promise<void> {
 this.config = config
 await this.initOSC(config)
 this.updateActions()
 this.updateFeedbacks()
}
```

`initOSC()` already tears down a previous server, so it is safe to call. Optionally only rebind when `config.feedbackPort` actually changed, to avoid dropping packets on unrelated edits.

---

## 🟡 Medium

### M2: @ts-expect-error disables type checking of the whole feedback callback

**File:** `src/feedbacks.ts:7`, `src/feedbacks.ts:23-25`
**Classification:** 🆕 NEW

The suppressed diagnostic is `TS7006: Parameter 'feedback' implicitly has an 'any' type`, caused by `type: 'boolean' as const` on line 7 defeating discriminant-based contextual typing of the object literal. With the suppression in place, `feedback` is `any`, so `feedback.options.<anything>` and the callback's return type go entirely unchecked — which is how the bogus `as string` cast on a `number` option slip through.

Verified in a scratch copy: deleting `as const` on line 7 **and** both comment lines 23-24 compiles clean with no other changes.

**Suggested fix:** do exactly that, or annotate the definition as `CompanionBooleanFeedbackDefinition`.

---

### M6: Unguarded await oscServer.close() can reject out of init()

**File:** `src/main.ts:35`
**Classification:** 🆕 NEW

`node-osc` wraps `dgram.close()`, which throws `ERR_SOCKET_DGRAM_NOT_RUNNING` if the socket is already closed or errored. Because `initOSC()` is awaited from `init()` (and should be from `configUpdated()`)

**Suggested fix:** wrap in `try/catch`

---

### M7: InstanceStatus is set to Ok before the socket binds and never recovers from ConnectionFailure

**File:** `src/main.ts:21`, `src/main.ts:39-54`
**Classification:** 🆕 NEW

`updateStatus(InstanceStatus.Ok)` runs at line 21, before `await this.initOSC(config)` — so the connection reports Ok during (and regardless of) the bind. Conversely, once the `'error'` handler sets `ConnectionFailure`, nothing ever restores `Ok` when a later bind succeeds.

**Suggested fix:** `updateStatus(InstanceStatus.Connecting)` in `init()`, then `updateStatus(InstanceStatus.Ok)` inside the `listening` callback at line 39-41; keep the error handler as it is.

---

## 🟢 Low

### L4: seqCache is untyped and is never cleared on destroy or reconfigure

**File:** `src/main.ts:12`, `src/main.ts:92`, `src/feedbacks.ts:26`
**Classification:** 🆕 NEW

`seqCache = new SimpleCache()` instantiates `SimpleCache<unknown>`, which is why both call sites need `as SequenceActiveState[]` casts. It is also public and is never cleared in `destroy()`, `init()` or `configUpdated()`, so after pointing the connection at a different console, stale sequence states keep driving feedback colours until the new console happens to send an update for the same executor number.

**Suggested fix:** `private seqCache = new SimpleCache<SequenceActiveState[]>()`, and `clear()` it on destroy and re-init.

---

### L8: Leftover German comments, stray braces in log strings and a config typo

**File:** `src/main.ts:33`, `src/main.ts:44`, `src/main.ts:61`, `src/main.ts:113`, `src/config.ts:20`
**Classification:** 🆕 NEW

- German comments remain after the "updated all messages to englisch" pass: `// Alten Server zuerst schließen` (line 33), `// node-osc liefert: …` (line 44).
- Stray `}` at the end of two debug templates: `...${gma3ObjectNumber}}` (line 61) and `(Seq: ${seqNumber}})` (line 113).
- `src/config.ts:20`: "Here is an short explanaiton" → "Here is a short explanation".

---
