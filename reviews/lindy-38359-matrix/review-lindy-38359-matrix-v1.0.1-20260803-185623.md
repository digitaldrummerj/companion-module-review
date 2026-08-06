# Module Review — companion-module-lindy-38359-matrix v1.0.1

| | |
| --- | --- |
| **Module** | `lindy-38359-matrix` — Lindy 38359 16x16 HDMI 4K60 Matrix |
| **Review tag** | `v1.0.1` |
| **Previous tag** | *(none — first release)* |
| **Scope** | `tag` |
| **Language** | TypeScript |
| **API** | `@companion-module/base` 2.0.4 (v2) |
| **Protocols** | TCP (primary control) + HTTP (status poll) |
| **Source files** | 3 (`src/config.ts`, `src/main.ts` — 803 lines, `src/upgrades.ts`) |
| **Reviewed** | 2026-08-03 |

> **Scope note:** this is the module's **first release**, so there is no `previousTag..reviewTag` diff to review. Per review policy, `tag` scope falls back to a **full review of the current source**, and every finding is classified 🆕 NEW.

---

## Verdict: ❌ Changes Required

---

## 📋 Issues

**Blocking**

- Make sure that all comments and log statements are in English only
- Please split the main.ts in multiple files like the module template has for actions, feedback, variables, presets, and upgrade scripts.  This will make it easier to maintain and understand what is happening in the module. Template repo is: [https://github.com/bitfocus/companion-module-template-ts](https://github.com/bitfocus/companion-module-template-ts)

- [ ] [C1: UpgradeScripts is never exported from the module entry point](#c1-upgradescripts-is-never-exported-from-the-module-entry-point)
- [ ] [C2: Polling setInterval is never stored or cleared in destroy](#c2-polling-setinterval-is-never-stored-or-cleared-in-destroy)
- [ ] [C3: configUpdated never updates this.config so HTTP polling keeps hitting the old device](#c3-configupdated-never-updates-thisconfig-so-http-polling-keeps-hitting-the-old-device)
- [ ] [C5: package.json repository.url does not point at the bitfocus org](#c5-packagejson-repositoryurl-does-not-point-at-the-bitfocus-org)
- [ ] [C7: manifest.json contains banned low-value keywords](#c7-manifestjson-contains-banned-low-value-keywords)
- [ ] [C8: HELP.md is still the template stub](#c8-helpmd-is-still-the-template-stub)
- [ ] [C9: .yarnrc.yml is missing the template's supply-chain hardening keys](#c9-yarnrcyml-is-missing-the-templates-supply-chain-hardening-keys)
- [ ] [H2: power action sends the command twice and sends an invalid s power 2 on Toggle](#h2-power-action-sends-the-command-twice-and-sends-an-invalid-s-power-2-on-toggle)
- [ ] [H4: Disconnect is never surfaced and status stays Ok after the device drops the socket](#h4-disconnect-is-never-surfaced-and-status-stays-ok-after-the-device-drops-the-socket)
- [ ] [H6: All action and feedback definitions are re-registered every 6 seconds](#h6-all-action-and-feedback-definitions-are-re-registered-every-6-seconds)
-[ ] [H7: Manifest.json version should be 0.0.0](#h7-manifestjson-version-should-be-000)
- [ ] [H8: Lindytype should be typed with actual types](#h8-lindytypes-should-be-typed-with-actual-types)
- [ ] [Console.log debug output and leftover scratch code shipping in the release](#h9-consolelog-debug-output-and-leftover-scratch-code-shipped-in-the-release)
- [ ] [src/config.ts is dead code and duplicates the live config definitions](#h10-srcconfigts-is-dead-code-and-duplicates-the-live-config-definition)

**Non-blocking**

- None

---

## 🔴 Critical

### C1: UpgradeScripts is never exported from the module entry point

**Classification:** 🆕 NEW
**File:** `src/main.ts:802` (and `src/upgrades.ts`)

`src/upgrades.ts` defines and exports `UpgradeScripts`, but `src/main.ts` never imports or re-exports it — the only export in the file is `export default LindyMatrixInstance` at line 802. Verified in the build output: `dist/main.js` ends with `export default LindyMatrixInstance;` and contains no `UpgradeScripts` export.

Under the v2 API the entry point must export **both** the default instance class and `UpgradeScripts`. Without it Companion has no upgrade entry point for this connection. This matters most for a first release: upgrade scripts cannot be retro-added for versions already in the field, so shipping v1.0.1 without the export permanently forecloses migrating these users' configs later.

**Suggested fix:** add `export { UpgradeScripts } from './upgrades.js'` to `src/main.ts` alongside the default export, then confirm `dist/main.js` contains both after `yarn build`.

---

### C2: Polling setInterval is never stored or cleared in destroy

**Classification:** 🆕 NEW
**File:** `src/main.ts:80-82`, `src/main.ts:85-87`

```ts
setInterval(() => {
    void this.fetchVideoStatus()
}, 6000)
...
async destroy(): Promise<void> {
    this.tcp?.destroy()
}
```

The interval handle is discarded and `destroy()` only tears down the TCP helper. After the user disables or deletes the connection the timer keeps firing every 6 seconds forever: HTTP POSTs to the device, `setVariableValues()` / `checkFeedbacks()` / `setActionDefinitions()` calls on a torn-down instance, and a strong reference that prevents the instance from being garbage-collected. Re-enabling the connection runs `init()` again and stacks a **second** interval — N enable/disable cycles produce N concurrent pollers.

**Suggested fix:** store the handle (`private pollTimer: NodeJS.Timeout | null = null`), `clearInterval()` it in `destroy()` before `this.tcp?.destroy()`, and also clear any existing timer at the top of `init()` / `configUpdated()` before re-arming.

---

### C3: configUpdated never updates this.config so HTTP polling keeps hitting the old device

**Classification:** 🆕 NEW
**File:** `src/main.ts:93-96`

```ts
async configUpdated(config: LindyConfig, _secrets: unknown): Promise<void> {
    this.tcp?.destroy()
    this.connectTCP(config)
}
```

`this.config` is assigned only in `init()` (line 71). `fetchVideoStatus()` builds its URL from `this.config.host` (line 156-157), so after the operator changes the IP address the TCP side moves to the new device while the HTTP status poll keeps hitting the **previous** host every 6 seconds. Input/output name variables and the `route_active` routing state are then populated from a different matrix — and because the poll overwrites state unconditionally, correct data from the new device is repeatedly replaced with stale data from the old one. There is also no `updateStatus(InstanceStatus.Connecting)` on reconfigure, so the status pill stays green through the switch.

**Suggested fix:** set `this.config = config` as the first statement of `configUpdated()`, call `this.updateStatus(InstanceStatus.Connecting)`, clear cached state (`currentRouting`, `inputNames`, `outputNames`, `hdmiStreamState`), and restart the poll timer.

---

### C5: package.json repository.url does not point at the bitfocus org

**Classification:** 🆕 NEW
**File:** `package.json`
**Source:** deterministic template validator (`PKG-REPO`)

Current value:

```text
git+https://github.com/Stardust-group/companion-module-lindy-38359-matrix.git
```

Expected:

```text
git+https://github.com/bitfocus/companion-module-lindy-38359-matrix.git
```

Modules accepted into the Companion module library live under the `bitfocus` org; the metadata must reflect the canonical home so issue links and update tooling resolve correctly.

**Suggested fix:** update `repository.url` in `package.json`, and update the matching `repository` / `bugs` URLs in `companion/manifest.json` (currently also pointing at `Stardust-group`).

---

### C7: manifest.json contains banned low-value keywords

**Classification:** 🆕 NEW
**File:** `companion/manifest.json:26`
**Source:** deterministic template validator (`MAN-KEYWORD`)

```json
"keywords": ["hdmi", "matrix", "video", "lindy"]
```

`matrix` and `lindy` are both rejected: the manufacturer name (`lindy`) is already carried by the `manufacturer` field, and `matrix` duplicates what is in the product name. Keywords are for terms a user would search that are *not* already in the name/manufacturer/product fields.

**Suggested fix:** drop `matrix` and `lindy`; keep `hdmi` and `video` and consider adding genuinely distinct search terms (e.g. `switcher`, `4k60`, `router`).

---

### C8: HELP.md is still the template stub

**Classification:** 🆕 NEW
**File:** `companion/HELP.md`
**Source:** deterministic template validator (`HELP-STUB`)

The entire file is:

```markdown
## Your module

Write some help for your users here!
```

`HELP.md` is what a user sees in Companion's help panel; a stub means the module ships with no documentation at all.

**Suggested fix:** write real user documentation — how to find/set the matrix IP, which port the TCP control interface uses (and that the status poll uses HTTP on port 80), what each action does, what the feedbacks indicate, and any device-side setup (e.g. enabling the network control interface).

---

### C9: .yarnrc.yml is missing the template's supply-chain hardening keys

**Classification:** 🆕 NEW
**File:** `.yarnrc.yml`
**Source:** deterministic template validator (`CONFIG-DIFF`)

The module ships only `nodeLinker: node-modules`. The official `companion-module-template-ts` hardened this file, and three keys are missing:

```yaml
enableScripts: false
npmMinimalAgeGate: 3d
npmPreapprovedPackages:
  - "@companion-module/*"
```

These are supply-chain protections — `enableScripts: false` blocks dependency install scripts, and `npmMinimalAgeGate` refuses freshly published packages — so a module without them installs under weaker guarantees than the platform expects.

**Suggested fix:** copy `.yarnrc.yml` from the current `bitfocus/companion-module-template-ts` verbatim.

---

## 🟠 High

### H2: power action sends the command twice and sends an invalid s power 2 on Toggle

**Classification:** 🆕 NEW
**File:** `src/main.ts:366-374`

```ts
let state = action.options.state
this.sendCommand(`s power ${state}!`)      // fires before the toggle is resolved
if (state === '2') {
    state = this.isPoweredOn ? '0' : '1'
}
this.sendCommand(`s power ${state}!`)      // fires again
```

The first `sendCommand` is unconditional and runs *before* the toggle is resolved. "Power On" / "Power Off" therefore send the same command twice back-to-back; "Toggle" sends the literal `s power 2!` — not a valid state for this protocol — followed by the real command. Depending on firmware this is either rejected with an error, or flips the matrix twice / races the device's own power sequencing.

**Suggested fix:** delete the `sendCommand` at line 368, resolve the toggle first, then send once. The `lock_panel` action at lines 473-480 already does this correctly — mirror that pattern.

---

### H4: Disconnect is never surfaced and status stays Ok after the device drops the socket

**Classification:** 🆕 NEW
**File:** `src/main.ts:287-319`

The only status transitions are `InstanceStatus.Ok` on `'connect'` (line 291) and `InstanceStatus.ConnectionFailure` on `'error'` (line 308). `TCPHelper` emits `'end'` on a clean remote close and queues a reconnect **without** emitting `'error'`. So a matrix reboot, an idle-timeout close, or the module's own `s reboot!` action leaves Companion showing a green/Ok connection while nothing is actually connected — and `sendCommand()` then just logs a `warn` (line 326) while the button appears to succeed.

**Suggested fix:** subscribe to `TCPHelper`'s `'status_change'` event and forward it to `this.updateStatus(status, message)` — that covers Connecting / Disconnected / Ok in one place. Keep the `'error'` handler for logging.

---

### H6: All action and feedback definitions are re-registered every 6 seconds

**Classification:** 🆕 NEW
**File:** `src/main.ts:201`, `src/main.ts:221-224`

Refreshes the actions and feedbacks has a cost to it and most likely the routing is not changing every 6 seconds.  

I would suggest making polling an option along with a how often to poll.  As well for the hdmi matrix module that I own, I have an action to refresh the routing so that I can trigger it as needed instead of wasting resources refreshing something that I rarely am changing.

---

### H7: manifest.json version should be 0.0.0

**Classification:** 🆕 NEW
**File:** `companion/manifest.json:8`

`companion/manifest.json` declares `"version": "1.0.0"` while `package.json` and the git tag are `1.0.1`.

**Suggested fix:** keep the manifest `version` at 0.0.0 as the Companion release process will take the version in package.json and automatically update the manifest version as part of the release.

---

### H8: Lindytypes should be typed with actual types

**Classification:** 🆕 NEW
**File:** `src/main.ts:8-14` (root cause); casts at lines 138, 148, 193, 197, 232, 235, 239, 242, 249, 252, 256, 259, 269, 283, 331, 347, 505, 798

`LindyTypes` declares `actions`, `feedbacks` and `variables` as `Record<string, never>`, which makes every real definition a type error — so every API call is cast through `(this as any)`, and every action/feedback callback is typed `action: any` / `feedback: any`. `LindyConfig extends Record<string, any>` (line 3) similarly defeats config typing.

Net effect: this TypeScript module has effectively **no compile-time checking** of the Companion API surface. A typo in a variable id, action id, option id, or a `checkFeedbacks('route_activ')` compiles cleanly and fails silently at runtime.

**Suggested fix:** check out how the module template does it so that you get actual TypeScript types. [https://github.com/bitfocus/companion-module-template-ts/blob/main/src/main.ts#L9](https://github.com/bitfocus/companion-module-template-ts/blob/main/src/main.ts#L9).  As you also split the main.ts into the different files, it will be easier as well to define the schema properly

---

### H9: console.log debug output and leftover scratch code shipped in the release

**Classification:** 🆕 NEW
**File:** `src/main.ts:788-795`, `:803`, `:16-27`, `:317`

The console.log statements should be replaced with proper Companion logging.

```typescript
this.log('debug', `Structure = ${JSON.stringify(structure)}`)
this.log('debug', `Nombre de presets = ${Object.keys(presets).length}`)```
this.log('warn', `Preset undefined: ${id}`)
```

---

### H10: src/config.ts is dead code and duplicates the live config definition

**Classification:** 🆕 NEW
**File:** `src/config.ts:8-27`; live definition at `src/main.ts:98-117`

`GetConfigFields()` and `ModuleConfig` are never imported by `main.ts`, which defines its own `getConfigFields()` and `LindyConfig`. The two definitions disagree in exactly the way that matters: `config.ts:15` applies `regex: Regex.IP`, while the field actually used has no validation at all. Worse, `src/upgrades.ts:2` imports `ModuleConfig` from the dead file — so the upgrade scripts are typed against a config shape the module does not use.

**Suggested fix:** consolidate on `src/config.ts` — import `GetConfigFields` and `ModuleConfig` into `main.ts`, delete the inline duplicate, and make `LindyConfig`/`ModuleConfig` one exported type.

### H11: Replace French user-facing variable names and button text with English

**Classification:** 🆕 NEW
**File:** `src/main.ts:127`, `:134`, `:149-150`, `:233`, `:240`, `:250`, `:257`

Variable *names* shown in Companion's variable picker read `Nom Input 1` … `Nom Output 16`, and the `power_button_text` / `lock_button_text` variable *values* are `ETEINDRE` / `ALLUMER` / `DEVERROUILLER` / `VERROUILLER`. Companion has no localisation layer, so non-French users get untranslatable UI and button text. (Log messages are also mixed French/English across the module — lines 149-150, 175, 184, 194, 199 vs 292, 309, 326.)

**Suggested fix:** rename to `Input 1 Name` / `Output 1 Name`, emit `POWER OFF` / `POWER ON` / `UNLOCK` / `LOCK`, and standardise log messages on English.

---
