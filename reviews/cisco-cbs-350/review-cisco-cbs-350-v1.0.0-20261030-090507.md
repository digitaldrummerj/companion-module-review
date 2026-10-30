# Review: cisco-cbs-350 v1.0.0

| Field | Value |
| --- | --- |
| **Module** | [companion-module-cisco-cbs-350](https://github.com/bitfocus/companion-module-cisco-cbs-350) |
| **Version** | v1.0.0 |
| **Release** | New module — never published |
| **API** | 2.1 (base 2.1.3, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Scope** | `tag`. This is the module's first release, so there is no previous tag to diff against and the whole module was reviewed |
| **Commit** | [`7adab93`](https://github.com/bitfocus/companion-module-cisco-cbs-350/commit/7adab9364e8fe96d20d32f50c96a9036e187e792) |
| **Review date** | 2026-10-30 |

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Companion can call `destroy()` (connection disabled or deleted) or `configUpdated()` while an action callback is still running. It does not wait for pending action promises before it tears the instance down | General knowledge of Companion host behaviour. Nothing in `@companion-module/base` serialises action callbacks against `destroy()`/`configUpdated()`; Companion's host code was not checked | [M1](#m1-poe-reset-and-link-reset-can-leave-the-port-switched-off-if-the-connection-is-disabled-or-edited-during-the-reset) |

## 📋 Issues

### Blocking

- [ ] [C1: The module is set to run on Node 22 instead of the Node 26 runtime that API 2.1 modules use](#c1-the-module-is-set-to-run-on-node-22-instead-of-the-node-26-runtime-that-api-21-modules-use)
- [ ] [H1: The CI workflow builds and checks the module on Node 22 instead of Node 26](#h1-the-ci-workflow-builds-and-checks-the-module-on-node-22-instead-of-node-26)

### Non-blocking

- [ ] [M1: "PoE reset" and "Link reset" can leave the port switched off if the connection is disabled or edited during the reset](#m1-poe-reset-and-link-reset-can-leave-the-port-switched-off-if-the-connection-is-disabled-or-edited-during-the-reset)
- [ ] [M2: The Read-Write SNMP community is saved as plain config, not as a secret](#m2-the-read-write-snmp-community-is-saved-as-plain-config-not-as-a-secret)
- [ ] [L1: "Reset link" turns on a port that was deliberately shut down](#l1-reset-link-turns-on-a-port-that-was-deliberately-shut-down)
- [ ] [L2: Failed switch writes only go to the log, and the connection stays green](#l2-failed-switch-writes-only-go-to-the-log-and-the-connection-stays-green)
- [ ] [L3: Profile names in dropdowns don't update when they are saved together with a connection setting](#l3-profile-names-in-dropdowns-dont-update-when-they-are-saved-together-with-a-connection-setting)
- [ ] [N1: "Save config after applying" does nothing when the profile is already active](#n1-save-config-after-applying-does-nothing-when-the-profile-is-already-active)

## 🔴 Critical

### C1: The module is set to run on Node 22 instead of the Node 26 runtime that API 2.1 modules use

- **Source:** 🤖 validate-template (MAN-RUNTIME)
- **Classification:** 🆕 NEW
- **File:** [`companion/manifest.json:19`](https://github.com/bitfocus/companion-module-cisco-cbs-350/blob/7adab9364e8fe96d20d32f50c96a9036e187e792/companion/manifest.json#L19), [`tsconfig.build.json:2`](https://github.com/bitfocus/companion-module-cisco-cbs-350/blob/7adab9364e8fe96d20d32f50c96a9036e187e792/tsconfig.build.json#L2)

**What goes wrong:** The module is built on `@companion-module/base` 2.1, but its manifest tells Companion to run it on Node 22. The API 2.1 template runs modules on Node 26, and the build is compiled against the Node 22 preset too. A module that doesn't match its API level's template is harder to troubleshoot later, because it behaves differently from every other 2.1 module.

**Why it happens:** The manifest's `runtime.type` and the `tsconfig.build.json` preset were left at the Node 22 values, while the template for API 2.1 uses Node 26 for both.

**Evidence:**

```text
companion/manifest.json:19   found: "type": "node22",
                             template: "type": "node26"
tsconfig.build.json:2        found: "extends": "@companion-module/tools/tsconfig/node22/recommended-esm.json",
                             template: "extends": "@companion-module/tools/tsconfig/node26/recommended.json",
```

**Confirm by:** `grep -n '"type"' companion/manifest.json` shows `node26` at [`companion/manifest.json:19`](https://github.com/bitfocus/companion-module-cisco-cbs-350/blob/7adab9364e8fe96d20d32f50c96a9036e187e792/companion/manifest.json#L19), and `head -3 tsconfig.build.json` shows the node26 preset at [`tsconfig.build.json:2`](https://github.com/bitfocus/companion-module-cisco-cbs-350/blob/7adab9364e8fe96d20d32f50c96a9036e187e792/tsconfig.build.json#L2).

**Fix:** set the runtime to Node 26 and switch the build preset to the template's Node 26 preset.

```json
"runtime": {
	"type": "node26",
```

```json
{
	"extends": "@companion-module/tools/tsconfig/node26/recommended.json",
```

## 🟠 High

### H1: The CI workflow builds and checks the module on Node 22 instead of Node 26

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.github/workflows/node.yaml:21-25`](https://github.com/bitfocus/companion-module-cisco-cbs-350/blob/7adab9364e8fe96d20d32f50c96a9036e187e792/.github/workflows/node.yaml#L21-L25), [`.github/workflows/node.yaml:62-65`](https://github.com/bitfocus/companion-module-cisco-cbs-350/blob/7adab9364e8fe96d20d32f50c96a9036e187e792/.github/workflows/node.yaml#L62-L65)

**What goes wrong:** The GitHub Actions workflow tests the module on Node 22, while the API 2.1 template (and the runtime required by C1) is Node 26. CI then passes or fails on a different Node version than the one Companion runs the module on.

**Why it happens:** The module's `.github/workflows/node.yaml` differs from the template's copy in its Node version. The file's own comment says the version should match the manifest's runtime.

**Evidence:**

```yaml
# .github/workflows/node.yaml:21-25 (template: "Use Node.js 26.x" / "node-version: 26.x")
      - name: Use Node.js 22.x
        # This should match the version of Node.js you have defined in the manifest.json runtime field
        uses: actions/setup-node@v6
        with:
          node-version: 22.x
# .github/workflows/node.yaml:62-65 (commented-out block; template says 26.x)
  #     - name: Use Node.js 22.x
  #       uses: actions/setup-node@v6
  #       with:
  #         node-version: 22.x
```

**Confirm by:** `diff` [`.github/workflows/node.yaml`](https://github.com/bitfocus/companion-module-cisco-cbs-350/blob/7adab9364e8fe96d20d32f50c96a9036e187e792/.github/workflows/node.yaml) against the template's `.github/workflows/node.yaml` prints no output.

**Fix:** copy the template's `.github/workflows/node.yaml`; its CI Node version, 26.x, matches the Node 26 runtime required by C1.

## 🟡 Medium

### M1: "PoE reset" and "Link reset" can leave the port switched off if the connection is disabled or edited during the reset

- **Source:** 🔎 protocol reviewer, QA reviewer, compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:21`](https://github.com/bitfocus/companion-module-cisco-cbs-350/blob/7adab9364e8fe96d20d32f50c96a9036e187e792/src/main.ts#L21), [`src/main.ts:261-296`](https://github.com/bitfocus/companion-module-cisco-cbs-350/blob/7adab9364e8fe96d20d32f50c96a9036e187e792/src/main.ts#L261-L296), [`src/main.ts:52-54`](https://github.com/bitfocus/companion-module-cisco-cbs-350/blob/7adab9364e8fe96d20d32f50c96a9036e187e792/src/main.ts#L52-L54), [`src/main.ts:80-85`](https://github.com/bitfocus/companion-module-cisco-cbs-350/blob/7adab9364e8fe96d20d32f50c96a9036e187e792/src/main.ts#L80-L85)

**What goes wrong:** An operator presses a "Reset PoE of port (power cycle the device)" button for Port 6 with "Power off duration (s)" set to 30. The module turns PoE off and waits 30 seconds. If, during those 30 seconds, the operator disables the connection, or changes "Switch IP", "SNMP v2c community (Read-Write)" or "Polling interval (ms)" and saves, the "PoE on" command is sent through the SNMP session that was just closed. It never reaches the switch, the log shows at most "Port 6: PoE reset failed: ...", and the camera or access point on Port 6 stays unpowered until someone turns PoE back on by hand. "Reset link of port (shut / no shut)" has the same gap for its 3-second window, and can leave the port shut down.

**Why it happens:** The wait between "off" and "on" is a plain `setTimeout` that the module doesn't keep track of, so `destroy()` and the reconnect done by `configUpdated()` don't know a reset is in progress. Both reset functions grab the SNMP session before the wait and reuse it afterwards, even though the session has been closed in the meantime. net-snmp 3.29.1 reports the closed-socket error to the callback, so nothing crashes, but the restore command is never delivered. The long reset actions also don't react to Companion cancelling the action.

**Fix:** track in-progress resets, and finish or restore them before the session closes. For example, keep each pending wait (timer, port, restore command) in a Set; in `disconnect()`, clear the timers and send the restore command (PoE on / port enabled) on the old session before closing it. A simpler alternative for the reconnect case is to re-read `this.#client` after the wait and send the restore on the current session. At minimum, log a clear warning that "Port N was left off".

### M2: The Read-Write SNMP community is saved as plain config, not as a secret

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/config.ts:33-39`](https://github.com/bitfocus/companion-module-cisco-cbs-350/blob/7adab9364e8fe96d20d32f50c96a9036e187e792/src/config.ts#L33-L39), [`src/main.ts:13`](https://github.com/bitfocus/companion-module-cisco-cbs-350/blob/7adab9364e8fe96d20d32f50c96a9036e187e792/src/main.ts#L13)

**What goes wrong:** The value a user types in "SNMP v2c community (Read-Write)" is effectively a password that can change the switch's VLAN, PoE and port configuration. It is saved as a normal config value, so it is sent to the web UI and included in config exports. Nothing breaks in normal use; the risk is that the credential leaks wherever the config is shown or exported.

**Why it happens:** API 2.x has `secret-text` config fields and a separate typed secrets object that is kept out of the UI and exports. The module declares `community` as a `textinput` and sets `secrets: undefined` in its schema.

**Fix:** make the community a secret. Change the field to `type: 'secret-text'` (`id: 'community'`), add `type ModuleSecrets = { community: string }` and use it in `ModuleSchema` (`secrets: ModuleSecrets`). Accept `secrets` in `init(config, isFirstInit, secrets)` and `configUpdated(config, secrets)`, pass the secret to `SwitchClient`, and include it in the reconnect check. Change `this.saveConfig(this.config)` in `storeProfile`/`renameProfile` to `this.saveConfig(this.config, undefined)`. This is the first release, so no upgrade script is needed.

## 🟢 Low

### L1: "Reset link" turns on a port that was deliberately shut down

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:283-296`](https://github.com/bitfocus/companion-module-cisco-cbs-350/blob/7adab9364e8fe96d20d32f50c96a9036e187e792/src/main.ts#L283-L296)

**What goes wrong:** Port 4 was disabled with "Enable / disable port" (Disable). Later the operator presses "Reset link of port (shut / no shut)" for Port 4, or runs "Set access VLAN of port" with "Reset link after change" ticked. Port 4 comes back enabled, and the "Unsaved changes on the switch" feedback and the `unsaved_changes` variable don't show that the running-config changed. The code comment says the reset happens "without changing the configuration", but here it does.

**Why it happens:** The link reset always sends "disable", waits 3 seconds, then sends "enable". Unlike the PoE reset, which stops early when PoE is already off, it never checks whether the port was enabled to begin with, and it doesn't mark the config as changed.

**Fix:** skip the bounce when the port is already disabled, the same way the PoE reset handles PoE that is already off.

```ts
if (!port.enabled) {
	this.log('warn', `${port.label} is disabled, link not reset`)
	return
}
```

### L2: Failed switch writes only go to the log, and the connection stays green

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:178-190`](https://github.com/bitfocus/companion-module-cisco-cbs-350/blob/7adab9364e8fe96d20d32f50c96a9036e187e792/src/main.ts#L178-L190)

**What goes wrong:** A user enters a read-only community (for example `public`) in "SNMP v2c community (Read-Write)". Polling works, so the connection shows OK and every feedback and variable updates. But every action that changes the switch (Set access VLAN, Set PoE, Enable / disable port, Save running-config, Recall profile) fails with a noAccess/notWritable error that only appears in the module log. On the button nothing happens, and the connection status gives no hint why.

**Why it happens:** The write paths (`#change`, `saveSwitchConfig`, `resetPortPoe`, `resetPortLink`) catch the SNMP error, log it and return. None of them updates the connection status, so it stays at the OK set by the last successful poll.

**Fix:** when a write fails with an SNMP access error (noAccess / notWritable / authorizationError), set the status to `InstanceStatus.UnknownWarning` (or `BadConfig`) with a message such as "Write failed: community is read-only?". The next successful write or poll can clear it.

### L3: Profile names in dropdowns don't update when they are saved together with a connection setting

- **Source:** 🔎 QA reviewer, compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:56-72`](https://github.com/bitfocus/companion-module-cisco-cbs-350/blob/7adab9364e8fe96d20d32f50c96a9036e187e792/src/main.ts#L56-L72)

**What goes wrong:** In the connection settings the user renames "Profile 3 name" to "Show", also changes "Polling interval (ms)" from 10000 to 5000, and saves. The `profile_3_name` variable updates after the next poll, but the "Profile slot" dropdown in actions and feedbacks (Recall profile slot, Profile slot is active, ...) still says "3 - Profile 3" until the switch's port or VLAN list changes or the module restarts.

**Why it happens:** When the host, community or polling interval changes, `configUpdated()` only reconnects. After the next poll the definitions are rebuilt only if the switch's ports or VLANs changed, and that check doesn't include the profile names. The other branch of `configUpdated()` forces the rebuild, but the reconnect branch doesn't.

**Fix:** call `this.updateDefinitions(true)` in both branches of `configUpdated()`, or add the profile names to the signature in `updateDefinitions()`.

## 💡 Nice to Have

### N1: "Save config after applying" does nothing when the profile is already active

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:357-368`](https://github.com/bitfocus/companion-module-cisco-cbs-350/blob/7adab9364e8fe96d20d32f50c96a9036e187e792/src/main.ts#L357-L368)

**What goes wrong:** The operator recalls Profile 2 without saving, so "Unsaved changes on the switch" turns on. Later they press a "Recall profile slot" button for Profile 2 with "Save config after applying" ticked. Every port already matches, so nothing changes and no save happens: the unsaved-changes feedback stays on, and a switch reboot would lose the layout the operator expected to be saved.

**Why it happens:** The save is only run when at least one port changed, even when saving was requested and the switch has unsaved changes.

**Fix:** also save when saving was requested and there are unsaved changes.

```ts
if (changed > 0 || (save && this.unsavedChanges)) await this.#afterChange(save)
```
