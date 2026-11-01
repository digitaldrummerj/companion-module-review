# Review — companion-module-vrchat-midi-multicammixer v1.0.7

| | |
|---|---|
| **Module** | vrchat-midi-multicammixer |
| **Review tag** | v1.0.7 |
| **Previous tag** | (none — first release) |
| **Scope** | `tag` |
| **Language / API** | TypeScript · @companion-module/base 2.0.4 (v2) |
| **Protocols** | MIDI out via the `@julusian/midi` native addon; inbound state is read by tailing the VRChat/Unity player log |
| **Reviewed** | 2026-08-03 |

## Verdict: ❌ Changes Required

## 📋 Issues

**Blocking**

- [ ] [C2: manifest keywords duplicate the module name](#c2-manifest-keywords-duplicate-the-module-name)
- [ ] [C4: tsconfig.build.json differs from the template](#c4-tsconfigbuildjson-differs-from-the-template)
- [ ] [C5: Untracked reset timer survives destroy and configUpdated](#c5-untracked-reset-timer-survives-destroy-and-configupdated)
- [ ] [C6: Unhandled native MIDI exceptions in timer callbacks crash the connection process](#c6-unhandled-native-midi-exceptions-in-timer-callbacks-crash-the-connection-process)
- [ ] [H1: Unguarded statSync in the log finder throws inside the reset timer](#h1-unguarded-statsync-in-the-log-finder-throws-inside-the-reset-timer)
- [ ] [H2: File descriptor leak in the log poll loop](#h2-file-descriptor-leak-in-the-log-poll-loop)
- [ ] [H3: Missing lower bound clamp lets an index forge reserved control codes](#h3-missing-lower-bound-clamp-lets-an-index-forge-reserved-control-codes)
- [ ] [H4: Connect handshake resets itself and the one second liveness window causes a reconnect loop](#h4-connect-handshake-resets-itself-and-the-one-second-liveness-window-causes-a-reconnect-loop)
- [ ] [H5: Cut and Auto swap using stale state](#h5-cut-and-auto-swap-using-stale-state)
- [ ] [H6: Native MIDI constructor is never guarded](#h6-native-midi-constructor-is-never-guarded)
- [ ] [H7: HELP.md documents developer installation instead of module usage](#h7-helpmd-documents-developer-installation-instead-of-module-usage)
- [ ] [H8: Log discovery is Windows only with no platform check](#h8-log-discovery-is-windows-only-with-no-platform-check)
- [ ] [H9: Port open failure is wwritten to console log and swallowed](#h9-port-open-failure-is-written-to-consolelog-and-swallowed)
- [ ] [H10: Synchronous file io ten times per second with an unbound read buffer](#h10-synchronous-file-io-ten-times-per-second-with-an-unbounded-read-buffer)

**Non-blocking**

- [ ] [M2: Status stays Ok for five seconds after the world disappears](#m2-status-stays-ok-for-five-seconds-after-the-world-disappears)
- [ ] [M8: Auto action is a copy of Cut with a shipped TODO](#m8-auto-action-is-a-copy-of-cut-with-a-shipped-todo)
- [ ] [M11: The log poll catch swallows every error silently](#m11-the-log-poll-catch-swallows-every-error-silently)
- [ ] [M12: Actions fail silently when the MIDI port is closed](#m12-actions-fail-silently-when-the-midi-port-is-closed)
- [ ] [L1: destroy does not guard the MIDI close call](#l1-destroy-does-not-guard-the-midi-close-call)
- [ ] [L2: Output constructor enumerates ports twice and does not break after opening](#l2-output-constructor-enumerates-ports-twice-and-does-not-break-after-opening)
- [ ] [L3: Unused virtual parameter on the Output constructor](#l3-unused-virtual-parameter-on-the-output-constructor)

---

## 🔴 Critical

### C2: manifest keywords duplicate the module name

**Classification:** 🆕 NEW · **Source:** deterministic template check (`MAN-KEYWORD`, 2 hits) · `companion/manifest.json:31`

`keywords` is `["vrchat", "midi", "switcher", "camera"]`. Both `"vrchat"` and `"midi"` are already segments of the module id/name and are matched by search on those fields, so they add no discovery value. Bitfocus rejects keywords that merely restate the name, manufacturer, or product.

**Fix for the maintainer:** drop `"vrchat"` and `"midi"`. Keep the additive terms and consider a couple more that describe capability rather than identity — e.g. `["switcher", "camera", "vision mixer", "loopmidi", "virtual production"]`.

### C4: tsconfig.build.json differs from the template

**Classification:** 🆕 NEW · **Source:** deterministic template check (`CONFIG-DIFF`) · `tsconfig.build.json:7`

`compilerOptions` drops the template's `baseUrl`, `paths`, `module` and `moduleResolution`, and adds `rootDir` and `verbatimModuleSyntax`:

```jsonc
// module
"compilerOptions": {
    "outDir": "./dist",
    "rootDir": "./src",
    "verbatimModuleSyntax": true
}

// template
"compilerOptions": {
    "outDir": "./dist",
    "baseUrl": "./",
    "paths": { "*": ["./node_modules/*"] },
    "module": "nodenext",
    "moduleResolution": "nodenext"
}
```

The build does succeed and emits correct ESM (verified — `dist/main.js` uses `import` with `.js` specifiers), so this is config drift rather than a broken build. It still matters: dropping `paths`/`moduleResolution` means the module now relies entirely on whatever the extended `@companion-module/tools` preset happens to set, so a future preset change can silently alter resolution behaviour.

**Fix for the maintainer:** restore the template's `compilerOptions` block and re-add only the options you actually need on top of it (`verbatimModuleSyntax` is a reasonable addition; `rootDir: "./src"` is already implied by `include`).

### C5: Untracked reset timer survives destroy and configUpdated

**Classification:** 🆕 NEW · `src/main.ts:173-178` (with `:57-62` and `:64-86`)

```ts
setTimeout(() => {
    this.updateStatus(InstanceStatus.Connecting)
    this._findVRCLog()
    this._midiKnock()
    this._midiWatchdog()
}, 5e3) // 5 seconds else it doesnt actually reset
```

The timer handle is never stored, so nothing can cancel it. Two concrete failure paths:

**Disable/delete → process crash.** `destroy()` clears `watchdogInterval` and calls `this.midiOutput.close()` (which is `closePort()` **and** `destroy()` on the native handle, `src/midi/midi.ts:28-31`), but it does not clear this pending timer and does not null `midiOutput`. `destroy()` sets `logStream = null`, but the timer's `_findVRCLog()` re-populates it, so the early return in `_midiWatchdog()` no longer protects anything. `_midiKnock()` → `_SendMidiControl()` → `this.midiOutput?.isPortOpen()` then runs against a destroyed native handle. Per the addon source, every method throws `"RtMidi not initialised"` after `destroy()` — and this throw happens inside a `setTimeout` callback, where `@companion-module/base` installs no handler, so it takes down the connection process. The window is up to 5 s after every disable or delete.

**Config save → state corruption.** If the user saves config while a reset is pending, the stale timer fires afterwards against the *new* connection: `updateStatus(Connecting)` clobbers the real status, `_findVRCLog()` re-seeds `logStream.bytesRead` to the current EOF underneath the freshly started tick loop (so a chunk of log — potentially the `MIXERREADY` / `CurrentProgram` lines — is skipped), and `_midiKnock()` knocks the newly opened port.

The user-facing `reset` action (`src/actions.ts:73-79`) lets an operator trigger this at will.

**Fix for the maintainer:** store the handle (`this.resetTimeout = setTimeout(...)`), `clearTimeout` it at the top of both `destroy()` and `configUpdated()`, set `this.midiOutput = null` / `this.watchdogInterval = null` / `this.resetTimeout = null` after teardown, and add a `destroyed` guard checked at the top of the timer callback and of `_Tick()`.

### C6: Unhandled native MIDI exceptions in timer callbacks crash the connection process

**Classification:** 🆕 NEW · `src/main.ts:186-190` (reached from the 100 ms interval at `:114`) and `src/midi/midi.ts:33-39`

```ts
_SendMidiControl(code: number): void {
    if (!this.midiOutput?.isPortOpen()) return
    this.midiOutput.sendMessage([0xb0 | (CONTROL_CHANNEL & 0xf), CONTROL_NOTE, code & 0x7f])
}
```

`RtMidiOut::sendMessage` throws `"Internal RtMidi error"` as a JS exception whenever the underlying send fails. The `isPortOpen()` guard is not sufficient: RtMidi can still report a port as open while the peer has gone away (loopMIDI restarted, USB interface unplugged, the virtual port's consumer closed). Neither `Output.sendMessage()` nor `Output.isPortOpen()` wraps the native call, and neither does `_SendMidiControl`, `_midiWatchdog`, or `_Tick`.

The chain `setInterval(() => this._Tick(), 100)` → `_Tick` → `_midiWatchdog` → `_SendMidiControl` therefore throws out of a timer callback ten times a second once the device disappears — an unhandled exception that terminates the module process instead of degrading to a status. The same throw reaches the `async` action callbacks (`src/actions.ts:39,55,62,69`) as an unhandled rejection.

**Fix for the maintainer:** wrap the native calls in `try/catch` inside `Output.sendMessage()` and `Output.isPortOpen()` and return a success boolean (or a typed error). In `_SendMidiControl`, on failure `this.log('error', ...)`, `updateStatus(InstanceStatus.ConnectionFailure, 'MIDI port lost')` and enter the reconnect path. As a backstop, wrap the whole `_Tick()` body in `try/catch` so no tick can ever escape into the event loop.

---

## 🟠 High

### H1: Unguarded statSync in the log finder throws inside the reset timer

**Classification:** 🆕 NEW · `src/main.ts:269-271`

```ts
const latest = logs[logs.length - 1]
const size = fs.statSync(latest).size   // not inside any try/catch
this.logStream = { path: latest, bytesRead: size > 0 ? size - 1 : 0 }
```

The `readdirSync` above it is protected (`:253-261`), but this `statSync` is not. VRChat rotates and deletes `output_log_*.txt` files; if the selected file disappears between the `readdir` and the `stat` — or the Editor.log disappears after the `existsSync` check at `:251` — this throws `ENOENT`. Because `_findVRCLog()` is called from the untracked reset timer (`:175`), that becomes an unhandled exception (see [C5](#c5-untracked-reset-timer-survives-destroy-and-configupdated)). It is also called from `start()` inside `configUpdated()`, where the throw rejects `init()`/`configUpdated()` with no `InstanceStatus` ever set, leaving the connection with no status at all.

**Fix for the maintainer:** move the `statSync` and the `logStream` assignment inside a `try/catch` (or use `fs.statSync(latest, { throwIfNoEntry: false })`); on failure leave `logStream = null` and `updateStatus(InstanceStatus.ConnectionFailure, 'Log file disappeared')`.

### H2: File descriptor leak in the log poll loop

**Classification:** 🆕 NEW · `src/main.ts:222-226`

```ts
const buf = Buffer.alloc(newBytes)
const fd = fs.openSync(this.logStream.path, 'r')
fs.readSync(fd, buf, 0, newBytes, this.logStream.bytesRead)
fs.closeSync(fd)   // never reached if readSync throws
```

`closeSync` is not in a `finally`, and the enclosing `catch` at `:239-241` swallows the error and returns `false`. If `readSync` fails repeatedly — a network/OneDrive-backed path, a locked file, a truncated log, `EBADF` — one descriptor leaks on every 100 ms tick. That is 600 fds/minute until the process hits `EMFILE` and dies, with nothing in the log to explain it.

**Fix for the maintainer:** `try { ... } finally { fs.closeSync(fd) }`, and log the caught error at `debug`/`warn` instead of discarding it.

### H3: Missing lower bound clamp lets an index forge reserved control codes

**Classification:** 🆕 NEW · `src/main.ts:117-127` and `:181-190`

```ts
const CurrentProgram = Math.min(index, 50)          // no lower bound, no rounding
...
const value = (Math.min(index, 50) << 1) | (isPreview & 0x1)
...
this.midiOutput.sendMessage([..., code & 0x7f])
```

The encoding is otherwise well designed: cameras 0–50 map to 0–101, safely below the reserved codes 102 (KnockStart), 108 (KnockFinish), 119 (KnockMiddle) and 127 (Watchdog). But only the *upper* bound is clamped, so negative values wrap through `& 0x7f` straight into that reserved band:

- `set_preview` with `value = -1` → `(-1 << 1) | 1 = -1` → `-1 & 0x7f = 127` = **Watchdog**
- `set_program` with `value = -13` → `-26 & 0x7f = 102` = **KnockStart**
- `NaN` (a corrupted or imported option) → `NaN << 1 = 0` → silently selects camera 0

The `min: 1` on the `number` option only constrains the editor UI; values from imported pages, older configs, or a future `useVariables` option are not validated at runtime.

**Fix for the maintainer:** sanitise once, at the entry point — `const idx = Math.max(0, Math.min(50, Math.round(Number(index) || 0)))` in `SetCurrentProgram`/`SetCurrentPreview` — and log a warning when the requested index was outside 1–50 rather than silently substituting a value.

### H4: Connect handshake resets itself and the one second liveness window causes a reconnect loop

**Classification:** 🆕 NEW · `src/main.ts:39`, `:108-115`, `:137-154`

`lastUpdate` is initialised to `0` in the constructor and never set in `start()`. The first tick, 100 ms after `start()`, finds `_isMidiReady() === false` (the log has at most the 1 byte the `size - 1` seed left available) and computes `elapsed = Date.now() / 1000 ≈ 1.7e9 > 1` — so it immediately calls `_Reset()` and discards the knock that `start()` just sent. **Every connect therefore pays a mandatory 5 s penalty before the first genuine attempt.**

The same pattern repeats after each reset: the timer runs `_findVRCLog(); _midiKnock()`, and the very next ticks require `MIXERREADY` to appear in the log within **1 second**. Unity and VRChat buffer their player log and flush periodically, so if the world's response takes longer than a second to reach disk, the module never connects — it loops knock → 1 s → reset → 5 s indefinitely, while the status shows only `Connecting`.

**Fix for the maintainer:** set `this.lastUpdate = Date.now()` in `start()` and again in the reset timer callback; raise the liveness window well above the observed log-flush interval (5–10 s, ideally a config field); and escalate to `InstanceStatus.ConnectionFailure` with a specific message after a few failed cycles so the operator can tell "waiting for the world" from "never going to work".

### H5: Cut and Auto swap using stale state

**Classification:** 🆕 NEW · `src/main.ts:129-135` (with `:117-127`)

```ts
Cut(): void {
    const oldProgram = this.CurrentProgram
    const oldPreview = this.CurrentPreview
    this.SetCurrentPreview(0)
    this.SetCurrentProgram(oldPreview)
    this.SetCurrentPreview(oldProgram)
}
```

`this.CurrentProgram` / `this.CurrentPreview` are updated **only** from the VRChat log tail (`_setCurrentProgramVariable`, called from `_isMidiReady`); the optimistic local update is deliberately commented out at `:120` and `:126`. The round trip is at least one 100 ms tick plus Unity's log-flush latency — realistically several hundred milliseconds.

Trace with program 1, preview 2: press Cut → sends preview 0, program 2, preview 1; the local fields still say 1/2. Press Cut again 100 ms later → `oldProgram=1, oldPreview=2` again → sends exactly the same sequence. The operator pressed Cut twice expecting to be back on camera 1 and stays on camera 2. Rapid Cut/Auto punching is precisely what these buttons are for, so this is a core-workflow bug.

`Cut()` is also a silent no-op whenever program equals preview — including the initial 0/0 state and the whole post-reset window

**Fix for the maintainer:** update `this.CurrentProgram`/`this.CurrentPreview` (and their variables and feedbacks) optimistically in `SetCurrentProgram`/`SetCurrentPreview`, and let the log callback reconcile. If the world must stay authoritative, at minimum have `Cut()` compute from a locally tracked *pending* state rather than the last-confirmed one, and log a warning when it is invoked with program == preview.

### H6: Native MIDI constructor is never guarded

**Classification:** 🆕 NEW · `src/midi/midi.ts:8` and `:43`, reached from `src/main.ts:75` and `src/config.ts:11`

`new node_midi.Output()` throws `"Failed to initialise RtMidi"` when the MIDI subsystem is unavailable — headless Linux without ALSA, no audio session, or a failed addon load. Neither call site catches it:

- In `getOutputs()` (`config.ts:11`) the throw escapes `GetConfigFields()`, so the **config panel fails to render at all** and the user cannot even see why.
- In `configUpdated()` (`main.ts:75`) it rejects `init()`/`configUpdated()` with no `updateStatus()` ever called.
- Worse, when the assignment on `main.ts:75` throws, `this.midiOutput` still points at the *previous, already-closed-and-destroyed* wrapper (closed on line 73), so the later `destroy()` → `close()` → `closePort()` throws as well.

**Fix for the maintainer:** wrap `new node_midi.Output()` in `try/catch` inside both `Output` and `getOutputs()` (return `[]` on failure so the config panel still renders). In `configUpdated()`, set `this.midiOutput = null` *before* constructing, wrap the construction, and on failure `updateStatus(InstanceStatus.ConnectionFailure, 'MIDI subsystem unavailable: ...')` and return.

### H7: HELP.md documents developer installation instead of module usage

**Classification:** 🆕 NEW · `companion/HELP.md` (file-level)

`companion/HELP.md` is **byte-identical to `README.md`** (verified with `diff`). Its entire "Usage" section is developer-module install instructions — "Clone the repository", "Enable Developer Modules", `/opt/companion-module-dev/`. For a user installing from the module store this is actively misleading: it tells them to clone a repo they will never touch.

It also documents none of what the module actually exposes: 5 actions, 3 feedbacks, 3 variables, 2 config fields. The loopMIDI prerequisite is documented well, which is the most valuable part and should be kept.

**Fix for the maintainer:** rewrite `companion/HELP.md` for end users — what the module does, which VRChat world/prefab it pairs with, the loopMIDI + `--midi=loopMIDIPort` launch-option prerequisite, the Windows-only requirement (see [H8](#h8-log-discovery-is-windows-only-with-no-platform-check)), then tables of the actions, feedbacks, variables and config fields. Keep the developer-install instructions in `README.md` only, under a "Development" heading.

### H8: Log discovery is Windows only with no platform check

**Classification:** 🆕 NEW · `src/main.ts:244-273` (paths at `:246` and `:250`)

```ts
const vrcPath = path.join(os.homedir(), 'AppData', 'LocalLow', 'VRChat', 'VRChat')
const vrcEditorPath = path.join(os.homedir(), 'AppData', 'Local', 'Unity', 'Editor', 'Editor.log')
```

Both paths are hardcoded Windows locations with no `process.platform` check. On macOS or Linux — including Companion Pi, which the README explicitly gives instructions for — `readdirSync` throws into the empty catch at `:259-261` and the operator gets the generic `Cannot find/read logs` with no hint that the platform is simply unsupported. The module will sit in that state forever.

**Fix for the maintainer:** branch on `process.platform`. For non-Windows either support the Proton path (`~/.steam/steam/steamapps/compatdata/438100/pfx/drive_c/users/steamuser/AppData/LocalLow/VRChat/VRChat`) or fail fast with an explicit `updateStatus(InstanceStatus.BadConfig, 'This module requires Windows (VRChat log location)')`. Either way, state the OS requirement in HELP.md. A config field for a custom log directory would cover both cases cheaply.

### H9: Port open failure is written to console.log and swallowed

**Classification:** 🆕 NEW · `src/midi/midi.ts:18-23`

```ts
try {
    this._output.openPort(i)
} catch (err) {
    console.log(`Error opening port ${name}.\nError: ${err}`)
}
```

The real RtMidi error goes to stdout instead of the Companion connection log, and the user only ever sees the generic `BadConfig: 'MIDI Out Port not open'` from `main.ts:81` — indistinguishable from "port busy", "port renamed", and "RtMidi failed to start".

**Fix for the maintainer:** record the error on the using the Companion log or rethrow it, so `configUpdated()` can surface it via `this.log('error', ...)` and a specific status. Use `ConnectionFailure` when the port exists but cannot be opened, reserving `BadConfig` for a configured name that is not in `getOutputs()` at all.

### H10: Synchronous file I/O ten times per second with an unbounded read buffer

**Classification:** 🆕 NEW · `src/main.ts:114` and `:215-242`

`_Tick` runs every 100 ms and performs `statSync` + `openSync` + `readSync` + `closeSync` synchronously on the module's only thread, plus two full `matchAll` regex scans and a watchdog CC send. That is ten blocking filesystem round-trips per second for the lifetime of the connection. `Buffer.alloc(newBytes)` is also unbounded — after a stall it allocates whatever the log grew by in one go.

**Fix for the maintainer:** 250–500 ms is ample for camera switching. Move to `fs.promises` with a non-overlapping poll (re-arm with `setTimeout` after each completed read) or a persistent `FileHandle`, and cap the per-tick read with `Math.min(newBytes, 1 << 20)`.

---

## 🟡 Medium

### M2: Status stays Ok for five seconds after the world disappears

**Classification:** 🆕 NEW · `src/main.ts:156-179`

`_Reset()` clears the `connected` variable and fires its feedback immediately, but `updateStatus(InstanceStatus.Connecting)` only happens **inside** the 5 s timer (`:174`). So the connection indicator stays green for a full five seconds after the world has gone away. `InstanceStatus.Disconnected` is never used anywhere in the module.

**Fix for the maintainer:** call `updateStatus(InstanceStatus.Disconnected, 'Lost VRChat world')` at the top of `_Reset()`, then `Connecting` when the retry actually fires.

### M8: Auto action is a copy of Cut with a shipped TODO

**Classification:** 🆕 NEW · `src/actions.ts:66-72` (preset at `src/presets.ts:89-119`)

```ts
auto: {
    name: 'Auto (swap Program and Preview)',
    options: [],
    callback: async () => {
        self.Cut() // TODO still need to implement Auto transitions, either Unity side, or this side
    },
},
```

`auto` and `cut` are presented as two distinct operator actions with two distinct preset buttons, and both carry the same "(swap Program and Preview)" suffix, but they do exactly the same thing. Nothing tells the user that Auto is unimplemented.

**Fix for the maintainer:** either drop the `auto` action and its preset until transitions exist, or rename it to say so explicitly (e.g. `Auto (currently identical to Cut — transitions not yet implemented)`) and move the TODO out of shipped code.

### M11: The log poll catch swallows every error silently

**Classification:** 🆕 NEW · `src/main.ts:239-241`

```ts
} catch {
    return false
}
```

A permissions error, a deleted log, or a throw from `setVariableValues`/`checkFeedbacks` (both called *inside* this `try`, at `:232` and `:236`) is indistinguishable from "no new data". The module simply cycles the reconnect loop forever with nothing in the log.

**Fix for the maintainer:** `catch (e) { this.log('warn', \`Log read failed: ${e}\`) }` and, after repeated failures, escalate to `InstanceStatus.ConnectionFailure`. Move the variable/feedback side effects out of the `try` so a rendering error cannot be misread as an I/O failure.

### M12: Actions fail silently when the MIDI port is closed

**Classification:** 🆕 NEW · `src/main.ts:187`

`if (!this.midiOutput?.isPortOpen()) return` — pressing Cut, Auto, or Set Program with a closed port does nothing, logs nothing, and leaves the status untouched. The operator gets no signal that the button did not work.

**Fix for the maintainer:** `this.log('warn', 'Dropping MIDI message: port not open')` and set `InstanceStatus.Disconnected` so the button and the connection list both reflect reality.

---

## 🟢 Low

### L1: destroy does not guard the MIDI close call

**Classification:** 🆕 NEW · `src/main.ts:57-62`

`destroy()` calls `this.midiOutput.close()` unguarded. A double `close()` throws from the native layer, which would reject `destroy()`.

**Fix for the maintainer:** wrap it in `try/catch` and null `this.midiOutput` afterwards so teardown can never reject.

### L2: Output constructor enumerates ports twice and does not break after opening

**Classification:** 🆕 NEW · `src/midi/midi.ts:10-25`

The constructor calls `getOutputs()` — which spins up a whole second `RtMidiOut` — purely to name-match, when `this._output.getPortName(i)` is already available. The `for` loop also keeps scanning after a successful `openPort`.

**Fix for the maintainer:** use `this._output.getPortName(i)` directly (or pass the already-computed list in from the caller), and `break` after a successful open. The addon's `openPortByName()` would replace the loop entirely.

### L3: Unused virtual parameter on the Output constructor

**Classification:** 🆕 NEW · `src/midi/midi.ts:7` and `:12-14`

The `virtual?: boolean` parameter and its `openVirtualPort` branch are never exercised — `main.ts:75` always constructs with a name only.

**Fix for the maintainer:** drop the parameter, or expose it as a config option if creating a virtual port is genuinely useful here.

---
