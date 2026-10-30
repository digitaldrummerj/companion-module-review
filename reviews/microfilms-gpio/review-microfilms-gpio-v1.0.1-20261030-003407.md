# Review: microfilms-gpio v1.0.1

| | |
| --- | --- |
| **Module** | `companion-module-microfilms-gpio` |
| **Scope** | `tag` (first release: no previous tag, so the whole module was reviewed) |
| **Version** | v1.0.1 |
| **Release** | New module — never published |
| **API** | 2.1 (base 2.1.3, package.json range) — requires Companion 5.0+ |
| **Template** | `companion-module-template-js` @ `76d25b2` (2026-10-11) |
| **Commit** | [`4bf83a4`](https://github.com/bitfocus/companion-module-microfilms-gpio/tree/4bf83a4ac720760474f72c025907999f1e180331) |
| **Reviewed** | 2026-10-30 |

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Companion catches an action callback that throws (or rejects) and logs it as an action error in the connection log, rather than crashing the module process | The throw itself is verified (`byteToBinaryString` is not defined on the module instance or in `@companion-module/base` 2.1.3). The action wrapper lives in the Companion host, which was not checked. If the host does not catch it, every button press crashes the module and the severity goes up | [M1](#m1-every-set-raz-and-imp-button-press-logs-an-action-error) |
| A2 | Companion's variable picker and Variables tab list only declared variable ids, so values written to the undeclared ids `gpio` and `state1`..`state32` cannot be discovered by users | The id mismatch is verified in the code. How the Companion host treats undeclared ids was not checked. Either way, the declared variables stay empty | [H2](#h2-the-modules-gpio-variables-always-stay-empty) |
| A3 | When a user saves the connection settings, Companion calls `configUpdated()` on the running instance instead of `destroy()` followed by `init()` | Documented `InstanceBase` behaviour for API 2.x; the Companion host code was not checked | [H1](#h1-after-saving-the-connection-settings-status-variables-and-gpio-feedbacks-stop-updating) |

## 📋 Issues

### Blocking

- [ ] [C1: Source files sit at the module root instead of src](#c1-source-files-sit-at-the-module-root-instead-of-src)
- [ ] [C2: yarn.lock is not committed](#c2-yarnlock-is-not-committed)
- [ ] [C3: .yarnrc.yml is missing](#c3-yarnrcyml-is-missing)
- [ ] [C4: .gitattributes and .prettierignore are missing](#c4-gitattributes-and-prettierignore-are-missing)
- [ ] [C5: .gitignore lacks the template's build-output entries](#c5-gitignore-lacks-the-templates-build-output-entries)
- [ ] [C6: The template's Prettier setup is missing from package.json](#c6-the-templates-prettier-setup-is-missing-from-packagejson)
- [ ] [C7: package.json does not pin the package manager to Yarn 4](#c7-packagejson-does-not-pin-the-package-manager-to-yarn-4)
- [ ] [C8: The module targets Node 22 instead of the Node 26 runtime used by API 2.1](#c8-the-module-targets-node-22-instead-of-the-node-26-runtime-used-by-api-21)
- [ ] [H1: After saving the connection settings, status, variables and GPIO feedbacks stop updating](#h1-after-saving-the-connection-settings-status-variables-and-gpio-feedbacks-stop-updating)
- [ ] [H2: The module's GPIO variables always stay empty](#h2-the-modules-gpio-variables-always-stay-empty)
- [ ] [H3: LICENSE copyright line differs from the template](#h3-license-copyright-line-differs-from-the-template)

### Non-blocking

- [ ] [M1: Every Set, Raz and Imp button press logs an action error](#m1-every-set-raz-and-imp-button-press-logs-an-action-error)
- [ ] [M2: A short OUT reply from the device crashes the module](#m2-a-short-out-reply-from-the-device-crashes-the-module)
- [ ] [M3: The 100 ms Impulse release timer is not cleared when the connection is stopped](#m3-the-100-ms-impulse-release-timer-is-not-cleared-when-the-connection-is-stopped)
- [ ] [M4: The connection log fills with about six info lines per second from the 500 ms ping](#m4-the-connection-log-fills-with-about-six-info-lines-per-second-from-the-500-ms-ping)
- [ ] [M5: Users pick from 96 separate actions and 32 feedbacks instead of choosing a bit number](#m5-users-pick-from-96-separate-actions-and-32-feedbacks-instead-of-choosing-a-bit-number)
- [ ] [M6: The GPIO state feedback can only set the background colour](#m6-the-gpio-state-feedback-can-only-set-the-background-colour)
- [ ] [M7: The template's issue templates are missing](#m7-the-templates-issue-templates-are-missing)
- [ ] [M8: The template's CI workflow is missing](#m8-the-templates-ci-workflow-is-missing)
- [ ] [M9: The template's release workflow is missing](#m9-the-templates-release-workflow-is-missing)
- [ ] [L1: Target IP and Target Port show blank while the module silently uses default values](#l1-target-ip-and-target-port-show-blank-while-the-module-silently-uses-default-values)
- [ ] [L2: Each status reply sends 65 separate updates even when nothing changed](#l2-each-status-reply-sends-65-separate-updates-even-when-nothing-changed)
- [ ] [L3: Action, feedback and preset names are cryptic, partly in French, and contain typos](#l3-action-feedback-and-preset-names-are-cryptic-partly-in-french-and-contain-typos)
- [ ] [L4: nodemon is shipped as a runtime dependency](#l4-nodemon-is-shipped-as-a-runtime-dependency)
- [ ] [L5: The help page does not list the variables and is French-only](#l5-the-help-page-does-not-list-the-variables-and-is-french-only)
- [ ] [N1: Feedback and variable setup errors would surface as unhandled rejections](#n1-feedback-and-variable-setup-errors-would-surface-as-unhandled-rejections)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🔴 Critical

### C1: Source files sit at the module root instead of src

- **Source:** 🤖 validate-template (SRC-AT-ROOT)
- **Classification:** 🆕 NEW
- **File:** [`main.js`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/4bf83a4ac720760474f72c025907999f1e180331/main.js), [`actions.js`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/4bf83a4ac720760474f72c025907999f1e180331/actions.js), [`feedbacks.js`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/4bf83a4ac720760474f72c025907999f1e180331/feedbacks.js), [`network.js`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/4bf83a4ac720760474f72c025907999f1e180331/network.js), [`presets.js`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/4bf83a4ac720760474f72c025907999f1e180331/presets.js), [`protocol.js`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/4bf83a4ac720760474f72c025907999f1e180331/protocol.js), [`udp-server.js`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/4bf83a4ac720760474f72c025907999f1e180331/udp-server.js), [`upgrades.js`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/4bf83a4ac720760474f72c025907999f1e180331/upgrades.js), [`variables.js`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/4bf83a4ac720760474f72c025907999f1e180331/variables.js)

**What goes wrong:** The module's nine source files sit at the repository root. The template keeps all source under `src/`, and modules must follow that layout.

**Expected:** all source under `src/`, `package.json` `main` = `src/main.js`, manifest `runtime.entrypoint` = `../src/main.js`. **Found:** the nine files above at the root, `main` = `main.js`, `entrypoint` = `../main.js`.

**Fix:** move the files into `src/`, then set `package.json` `main` to `src/main.js` and `companion/manifest.json` `runtime.entrypoint` to `../src/main.js`. Update the test imports to match.

### C2: yarn.lock is not committed

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `yarn.lock` (missing)

**What goes wrong:** Without a committed lockfile, every build resolves dependencies afresh, so the published package can differ from what the maintainer tested.

**Fix:** run `yarn install` with Yarn 4 and commit the resulting `yarn.lock`.

### C3: .yarnrc.yml is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.yarnrc.yml` (missing)

**What goes wrong:** The template's Yarn settings (no install scripts, a 3-day minimum package age, `node_modules` linker) are not applied when the module is built.

**Fix:** copy `.yarnrc.yml` from `companion-module-template-js` main (`nodeLinker: node-modules`, `enableScripts: false`, `npmMinimalAgeGate: 3d`, `npmPreapprovedPackages`).

### C4: .gitattributes and .prettierignore are missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.gitattributes`, `.prettierignore` (both missing)

**What goes wrong:** The template tracks both files and the module has neither.

**Fix:** copy both files from `companion-module-template-js` main.

### C5: .gitignore lacks the template's build-output entries

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.gitignore`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/4bf83a4ac720760474f72c025907999f1e180331/.gitignore)

**What goes wrong:** Build output can be committed by accident: running `yarn package` leaves `pkg/` and a `.tgz` in the repo that git does not ignore.

**Expected:** the template entries `/pkg`, `/*.tgz`, `DEBUG-*` and `/.yarn`. **Found:** a generic Node/web `.gitignore` (Nginx vhost, seed users and other unrelated entries) without them.

**Fix:** add the four template entries. Extra entries may stay.

### C6: The template's Prettier setup is missing from package.json

- **Source:** 🤖 validate-template (PKG-FIELD, PKG-SCRIPT, PKG-DEVDEP)
- **Classification:** 🆕 NEW
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/4bf83a4ac720760474f72c025907999f1e180331/package.json)

**What goes wrong:** The module has no shared formatting setup, so contributors cannot format the code the way other Companion modules are formatted.

**Expected:** the `prettier` field, the `format` script and the `prettier` devDependency, as in the template. **Found:** none of the three.

**Fix:** copy the `prettier` field, the `format` script and the `prettier` devDependency from the template's `package.json`.

### C7: package.json does not pin the package manager to Yarn 4

- **Source:** 🤖 validate-template (PKG-FIELD)
- **Classification:** 🆕 NEW
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/4bf83a4ac720760474f72c025907999f1e180331/package.json)

**What goes wrong:** Without `packageManager`, Corepack does not select Yarn 4, so builds can run with a different package manager than the template expects.

**Fix:** add the template's `packageManager` field (`yarn@4…`).

### C8: The module targets Node 22 instead of the Node 26 runtime used by API 2.1

- **Source:** 🤖 validate-template (MAN-RUNTIME)
- **Classification:** 🆕 NEW
- **File:** [`companion/manifest.json:19`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/4bf83a4ac720760474f72c025907999f1e180331/companion/manifest.json#L19), [`package.json:12-14`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/4bf83a4ac720760474f72c025907999f1e180331/package.json#L12-L14), [`.node-version`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/4bf83a4ac720760474f72c025907999f1e180331/.node-version)

**What goes wrong:** The module asks Companion to run it on Node 22, while the API 2.1 template runs on Node 26. A mismatch with the template makes later troubleshooting harder.

**Expected:** manifest `runtime.type: "node26"`, `package.json` `engines` `"node": "^26", "yarn": "^4"`, `.node-version` `26`. **Found:** `node22`, `"node": "^22.20"`, `22`.

**Fix:** set `runtime.type` to `node26` and align `engines` and `.node-version` with the template.

## 🟠 High

### H1: After saving the connection settings, status, variables and GPIO feedbacks stop updating

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`main.js:131-139`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/4bf83a4ac720760474f72c025907999f1e180331/main.js#L131-L139)

**What goes wrong:** A user changes Target IP from 192.168.10.10 to 192.168.10.20 (or edits Target Port) and clicks Save. The module keeps pinging the new address, but nothing listens to the replies. The GPIO variables stay frozen at their old values, the Gpio01 to Gpio32 feedbacks keep their old red or green colour, and the connection status stays at whatever it was before the save (for example a green Ok). If the new IP is wrong or the device is unplugged, the status never turns to Disconnected or Connection Failure, so the user cannot tell the connection is down. Only disabling and re-enabling the connection recovers it.

**Why it happens:** The network layer reports replies, timeouts and send errors only as events. The handlers that turn those events into variable values, feedback updates and connection status are attached in `init()` only. When the settings are saved, `configUpdated()` throws away the old network layer and creates a new one without attaching any handlers, so every event it emits is lost. `configUpdated()` also skips the default host and port that `init()` applies.

**Evidence:**

```js
// main.js:67-104 (init — the only place listeners are attached)
    this.networkManager = new NetworkManager(
      this.config,
      this.log.bind(this),
      this.setGpioHeader,
      this.gpioBytes
    )

    // Écouter les événements émis par le NetworkManager
    this.networkManager.on('gpioStatus', (gpioBytes) => {
      this.gpioBytes = gpioBytes
      this.setVariableValues({ gpio: this.gpioBytes.readUInt32LE(0) })
      ...
      this.updateStatus(InstanceStatus.Ok)
    })

    this.networkManager.on('connectionFailure', (error) => {
      ...
      this.updateStatus(InstanceStatus.ConnectionFailure)
    })

    this.networkManager.on('noResponse', (message) => {
      ...
      this.updateStatus(InstanceStatus.Disconnected)
    })
```

```js
// main.js:131-139 (configUpdated — new manager, no listeners)
  async configUpdated (config) {
    this.config = config
    // Mettre à jour le NetworkManager avec la nouvelle configuration
    if (this.networkManager) {
      this.networkManager.destroy()
    }
    this.networkManager = new NetworkManager(this.config, this.log.bind(this))
    this.log('info', 'Config updated')
  }
```

```js
// network.js:41-42, 60-70, 80-85 (the new manager starts pinging immediately and only reports through emit)
    this.configureReception()
    this.sendGpioPing()
...
    this.udpClient.on('message', (msg, rinfo) => {
      const gpioBytes = parseOutFrame(msg)
      if (gpioBytes) {
        ...
        this.emit('gpioStatus', this.gpioBytes)
...
      } else {
        this.emit('connectionFailure', 'Incorrect header in "Status" response')
...
    this.receptionWatcherId = setTimeout(() => {
      if (this.waitingForStatusResponse) {
        ...
        this.emit('noResponse', ...)
```

**Confirm by:** open [`main.js:131-139`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/4bf83a4ac720760474f72c025907999f1e180331/main.js#L131-L139) and check that `configUpdated()` calls `new NetworkManager(...)` with no `.on(...)` handlers afterwards. Then open [`network.js:41-42`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/4bf83a4ac720760474f72c025907999f1e180331/network.js#L41-L42) and [`network.js:60-85`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/4bf83a4ac720760474f72c025907999f1e180331/network.js#L60-L85) and check that the constructor starts pinging and reports replies and timeouts only through `emit()`.

**Fix:** create the network layer and attach its four handlers in one helper, and call it from both `init()` and `configUpdated()`. In `configUpdated()`, apply the same host and port defaults as `init()` and set the status to Connecting before rebuilding.

```js
createNetworkManager () {
  this.networkManager = new NetworkManager(this.config, this.log.bind(this), this.setGpioHeader, this.gpioBytes)
  this.networkManager.on('gpioStatus', (gpioBytes) => { /* ... */ })
  this.networkManager.on('connectionFailure', (error) => { /* ... */ })
  this.networkManager.on('noResponse', (message) => { /* ... */ })
  this.networkManager.on('sendError', (error) => { /* ... */ })
}
```

### H2: The module's GPIO variables always stay empty

- **Source:** 🔎 QA reviewer + compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`variables.js:27-40`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/4bf83a4ac720760474f72c025907999f1e180331/variables.js#L27-L40)

**What goes wrong:** A user opens the Variables tab for this connection, or puts `$(microfilms-gpio:01)` or `$(microfilms-gpio:Full)` in a button text. The module lists 33 variables (Gpio01 to Gpio32 and GPIO Full), but none of them ever gets a value, so the button text shows nothing even while the device is reporting GPIO states.

**Why it happens:** The variable list declares the ids `01`..`32` and `Full`, but the code that handles each status reply writes the ids `gpio` and `state1`..`state32`. The two sets of ids never match, so the declared variables are never filled and the values that are written go to ids the variable picker does not offer. The test in `test/definitions.test.js` only checks the declared ids, so it does not catch the mismatch.

**Evidence:**

```js
// variables.js:20-30
  for (let i = 0; i < 32; i++) {
    ...
    variableDefinitions[`${String(i + 1).padStart(2, '0')}`] = {
      name: `Gpio${String(i + 1).padStart(2, '0')}` // Nommer chaque variable en fonction du bit
    }
  }
```

```js
// variables.js:38-40
  variableDefinitions.Full = {
    name: 'GPIO Full (Little Endian)'
  }
```

```js
// main.js:75-84
    this.networkManager.on('gpioStatus', (gpioBytes) => {
      this.gpioBytes = gpioBytes
      this.setVariableValues({ gpio: this.gpioBytes.readUInt32LE(0) })
      for (let i = 0; i < 32; i++) {
        ...
        // Mettre à jour la variable correspondante (state1, state2, ..., state32)
        this.setVariableValues({ [`state${i + 1}`]: bitValue })
```

A search for `setVariableValues` across the module returns only `main.js:77` and `main.js:84`. No other code writes `01`..`32` or `Full`.

**Confirm by:** open [`main.js:77`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/4bf83a4ac720760474f72c025907999f1e180331/main.js#L77) and [`main.js:84`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/4bf83a4ac720760474f72c025907999f1e180331/main.js#L84) (which write `gpio` and `state1`..`state32`) and compare them with [`variables.js:27`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/4bf83a4ac720760474f72c025907999f1e180331/variables.js#L27) and [`variables.js:38`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/4bf83a4ac720760474f72c025907999f1e180331/variables.js#L38) (which declare `01`..`32` and `Full`).

**Fix:** use one set of ids in both places, and pick it before the first release because users' buttons will reference these ids. For example, write the declared ids from the status handler:

```js
this.setVariableValues({ Full: this.gpioBytes.readUInt32LE(0) })
// inside the loop
this.setVariableValues({ [String(i + 1).padStart(2, '0')]: bitValue })
```

### H3: LICENSE copyright line differs from the template

- **Source:** 🤖 validate-template (LICENSE-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`LICENSE:3`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/4bf83a4ac720760474f72c025907999f1e180331/LICENSE#L3)

**What goes wrong:** The LICENSE does not match the template's text.

**Expected:** `Copyright (c) 2022 Bitfocus AS - Open Source`. **Found:** `Copyright (c) 2024-2026 Microfilms`.

**Fix:** use the template's LICENSE verbatim.

## 🟡 Medium

### M1: Every Set, Raz and Imp button press logs an action error

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`actions.js:43-46`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/4bf83a4ac720760474f72c025907999f1e180331/actions.js#L43-L46), [`actions.js:66-69`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/4bf83a4ac720760474f72c025907999f1e180331/actions.js#L66-L69), [`actions.js:89-92`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/4bf83a4ac720760474f72c025907999f1e180331/actions.js#L89-L92)

**What goes wrong:** A user presses a button running Set05, Raz05 or Imp05. The GPIO command is sent and the output changes, but an action error ("this.byteToBinaryString is not a function") appears in the connection log on every press, and the intended confirmation line ("Set GPIO bit 5 UP sent to …") never appears. For Imp, the release (DOWN) command is still sent.

**Why it happens:** The actions run on the module instance, but the helper they call to format the log line is defined only on the network layer ([`network.js:118`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/4bf83a4ac720760474f72c025907999f1e180331/network.js#L118)). The unit test in `test/actions.test.js` adds a fake `byteToBinaryString` to its stand-in instance, which hides the bug.

**Fix:** call the helper on the network layer, or move it into `protocol.js` as an exported function used by both files, and remove the stub from the test.

```js
`... (GPIO=${this.networkManager.byteToBinaryString(gpioBytesUp)})`
```

### M2: A short OUT reply from the device crashes the module

- **Source:** 🔎 protocol reviewer + QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`protocol.js:126-135`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/4bf83a4ac720760474f72c025907999f1e180331/protocol.js#L126-L135)

**What goes wrong:** If anything sends this connection's socket a datagram that starts with "OUT" but is shorter than 7 bytes, the module process crashes. Companion shows the connection as crashed or restarting, and all GPIO buttons stop working until it restarts.

**Why it happens:** The reply parser only checks that the message is at least 3 bytes long, then hands on bytes 3 to 7, which can be fewer than 4 bytes. The status handler then reads a 4-byte number from it ([`main.js:77`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/4bf83a4ac720760474f72c025907999f1e180331/main.js#L77)), which throws on a short buffer. The throw happens inside the socket's message event, so nothing catches it.

**Fix:** reject frames that are too short in the parser (do the same for the INP parser with 11 bytes), and optionally wrap the message handler in `try/catch`.

```js
if (!msg || msg.length < 7) {
  return null
}
```

### M3: The 100 ms Impulse release timer is not cleared when the connection is stopped

- **Source:** 🔎 protocol reviewer + QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`actions.js:40-42`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/4bf83a4ac720760474f72c025907999f1e180331/actions.js#L40-L42)

**What goes wrong:** If the connection is disabled, deleted or reconfigured within 100 ms of an Imp01 to Imp32 press, the pending release command still fires after the socket has been torn down and throws "Cannot read properties of undefined (reading 'send')". The window is very short, so the user sees at most an error in the log.

**Why it happens:** The impulse action schedules the release with a timer that nothing keeps track of. `destroy()` ([`main.js:119-124`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/4bf83a4ac720760474f72c025907999f1e180331/main.js#L119-L124)) stops the ping and watchdog timers, but not this one.

**Fix:** keep pending impulse timers in a `Set` on the instance and clear them in `destroy()` and before rebuilding in `configUpdated()`, or guard the send with `if (this.networkManager?.udpClient)`.

### M4: The connection log fills with about six info lines per second from the 500 ms ping

- **Source:** 🔎 protocol reviewer + QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`network.js:67`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/4bf83a4ac720760474f72c025907999f1e180331/network.js#L67), [`network.js:102`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/4bf83a4ac720760474f72c025907999f1e180331/network.js#L102), [`network.js:108`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/4bf83a4ac720760474f72c025907999f1e180331/network.js#L108)

**What goes wrong:** While the device is connected, the connection log gets "Sending ping", "Command "Set GPIO PING" sent successfully." and a "Status" response line at info level every 500 ms. That is about 21,600 lines per hour, which buries real errors and button-press messages.

**Why it happens:** The ping repeats every 500 ms, and every send and every reply is logged at info level.

**Fix:** log ping traffic at `debug` level (or not at all), and keep `info` for state changes, for example log the Status line only when the GPIO value changes.

### M5: Users pick from 96 separate actions and 32 feedbacks instead of choosing a bit number

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`actions.js:22-95`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/4bf83a4ac720760474f72c025907999f1e180331/actions.js#L22-L95), [`feedbacks.js:19-65`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/4bf83a4ac720760474f72c025907999f1e180331/feedbacks.js#L19-L65)

**What goes wrong:** The action picker shows 96 entries (Imp01..Imp32, Set01..Set32, Raz01..Raz32) and the feedback picker 32 (Gpio01..Gpio32). To move a button from bit 3 to bit 4, the user must delete the action and the feedback and add new ones instead of changing a number, and the bit cannot come from a variable such as `$(local:bit)`.

**Why it happens:** The module generates one definition per bit in a loop, each with no options, so the bit number is baked into the action id.

**Fix:** before the first release (afterwards it needs upgrade scripts), define three actions ("GPIO pulse", "GPIO set on", "GPIO set off") and one feedback ("GPIO bit state"), each with a `number` option "Bit" (min 1, max 32, `asInteger: true`). The presets can then use one template preset group with a local variable for the bit.

### M6: The GPIO state feedback can only set the background colour

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`feedbacks.js:31-63`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/4bf83a4ac720760474f72c025907999f1e180331/feedbacks.js#L31-L63)

**What goes wrong:** A user adds the Gpio01 feedback and gets two colour pickers labelled in French instead of Companion's normal "when true, apply this style" editor. They cannot use it to change text colour, text or image, or to invert it.

**Why it happens:** The feedback is an advanced feedback that returns a background colour chosen from its two options. In API 2.1 advanced feedbacks are discouraged, and an on/off state should be a boolean feedback.

**Fix:** make it a boolean feedback that returns whether the bit is on, with `defaultStyle: { bgcolor: combineRgb(0, 200, 0) }`, and drop the two colour options. Do this before the first release so no upgrade script is needed.

### M7: The template's issue templates are missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.github/ISSUE_TEMPLATE/bug_report.yml`, `.github/ISSUE_TEMPLATE/config.yml`, `.github/ISSUE_TEMPLATE/feature_request.yml` (all missing)

**What goes wrong:** Users who open an issue on GitHub get no bug-report or feature-request form.

**Fix:** copy the three files from the template.

### M8: The template's CI workflow is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.github/workflows/companion-module-checks.yaml` (missing)

**What goes wrong:** Pushes and pull requests are not run through the standard Companion module checks, so problems like the ones in this review are not caught automatically.

**Fix:** copy `.github/workflows/companion-module-checks.yaml` from the template.

### M9: The template's release workflow is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.github/workflows/release.yaml` (missing)

**What goes wrong:** Tagged releases are not built and published by the standard release workflow.

**Fix:** copy `.github/workflows/release.yaml` from the template.

## 🟢 Low

### L1: Target IP and Target Port show blank while the module silently uses default values

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`main.js:60-61`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/4bf83a4ac720760474f72c025907999f1e180331/main.js#L60-L61), [`main.js:145-161`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/4bf83a4ac720760474f72c025907999f1e180331/main.js#L145-L161)

**What goes wrong:** When a user adds the connection, the Target IP and Target Port fields are empty, yet the module is already pinging 192.168.10.10:7770 (the defaults HELP.md mentions). The form does not show what the module is talking to, and after a later Save the defaults are no longer applied.

**Why it happens:** The config fields have no `default`. The defaults are filled in silently in `init()` only, not in `configUpdated()`.

**Fix:** add `default: '192.168.10.10'` to Target IP and `default: '7770'` to Target Port, and remove the hidden fallbacks in `init()`.

### L2: Each status reply sends 65 separate updates even when nothing changed

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`main.js:75-89`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/4bf83a4ac720760474f72c025907999f1e180331/main.js#L75-L89)

**What goes wrong:** Nothing visible, but every 500 ms the module sends Companion 33 variable updates and 32 feedback re-checks, even when the GPIO state is unchanged. That is about 130 messages a second per connection.

**Why it happens:** The status handler updates each variable and re-checks each feedback one at a time inside the loop, without checking whether anything changed.

**Fix:** build one values object and one list of feedback ids, then call `setVariableValues(values)` and `checkFeedbacks(...ids)` once each, and skip both when the 4 GPIO bytes equal the previous ones.

### L3: Action, feedback and preset names are cryptic, partly in French, and contain typos

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`actions.js:33`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/4bf83a4ac720760474f72c025907999f1e180331/actions.js#L33), [`feedbacks.js:33-47`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/4bf83a4ac720760474f72c025907999f1e180331/feedbacks.js#L33-L47), [`presets.js:78`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/4bf83a4ac720760474f72c025907999f1e180331/presets.js#L78), [`presets.js:119`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/4bf83a4ac720760474f72c025907999f1e180331/presets.js#L119)

**What goes wrong:** Users see actions named Imp01, Set01 and Raz01 ("Raz" is French for reset) with no description, feedback options labelled "Couleur de fond rouge (désactivé)", presets named "Tow states 1 button" (typo for "Two"), and a preset section named "Divers" (French for "Misc"). English-speaking users have trouble finding or understanding them.

**Fix:** use descriptive English labels (for example "GPIO pulse (100 ms)", "GPIO set on", "GPIO set off", "Background colour when off"), add a `description` to each action, rename the presets to "Two states" and the section to "GPIO", and fix the same typo in `README.md`.

### L4: nodemon is shipped as a runtime dependency

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`package.json:22`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/4bf83a4ac720760474f72c025907999f1e180331/package.json#L22)

**What goes wrong:** Nothing visibly breaks, but a development file-watcher is declared as a runtime dependency, which adds install weight and audit noise.

**Fix:** remove `nodemon` (no script uses it) or move it to `devDependencies`.

### L5: The help page does not list the variables and is French-only

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`companion/HELP.md`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/4bf83a4ac720760474f72c025907999f1e180331/companion/HELP.md)

**What goes wrong:** A user opening the module help in Companion finds no list of variables, so they cannot tell what `$(microfilms-gpio:01)` or `$(microfilms-gpio:Full)` contain. The whole page is in French.

**Fix:** after fixing [H2](#h2-the-modules-gpio-variables-always-stay-empty), add a Variables section listing each id and its meaning, and consider providing the help text in English.

## 💡 Nice to Have

### N1: Feedback and variable setup errors would surface as unhandled rejections

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`main.js:106-109`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/4bf83a4ac720760474f72c025907999f1e180331/main.js#L106-L109)

**What goes wrong:** Nothing visible today. If registering the feedbacks or variables ever failed, the error would become an unhandled promise rejection instead of failing `init()` cleanly.

**Why it happens:** The feedback and variable setup functions are declared `async` but contain no `await`, and `init()` calls them without awaiting.

**Fix:** make both functions synchronous, or `await` them in `init()`.

## 📝 Additional Notes

- This is the module's first release (single tag `v1.0.1`), so there is no diff to compare against: the whole module was reviewed and every finding is 🆕 NEW.
