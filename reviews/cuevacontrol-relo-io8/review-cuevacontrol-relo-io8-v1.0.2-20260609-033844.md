# Review — cuevacontrol-relo-io8 v1.0.2

| | |
|---|---|
| **Module** | cuevacontrol-relo-io8 |
| **Version** | v1.0.2 |
| **Scope** | tag (first release — no previous tag, so reviewed as a full module; all findings NEW) |
| **Language / API** | JS · @companion-module/base ^1.14.1 (v1.x) |
| **Protocol** | WebSocket (`ws` ^8.18.0) |
| **Reviewed** | 2026-06-09 |

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 3 | 0 | 3 |
| 🟠 High | 1 | 0 | 1 |
| 🟡 Medium | 6 | 0 | 6 |
| 🟢 Low | 6 | 0 | 6 |
| 💡 Nice to Have | 4 | 0 | 4 |
| **Total** | **20** | **0** | **20** |

## Verdict: ❌ Changes Required

## 📋 Issues

**Blocking**
- [ ] [C1: manifest name does not match id](#c1-manifest-name-does-not-match-id)
- [ ] [C2: low-value keyword relo duplicates the module-name slug](#c2-low-value-keyword-relo-duplicates-the-module-name-slug)
- [ ] [C3: set_relay Toggle sends a raw toggle command the device may not accept](#c3-set_relay-toggle-sends-a-raw-toggle-command-the-device-may-not-accept)
- [ ] [H1: Pulse action holds an untracked 60s timer that can strand a relay ON](#h1-pulse-action-holds-an-untracked-60s-timer-that-can-strand-a-relay-on)

**Non-blocking**
- [ ] [M1: AUTH_FAIL reconnects forever with a bad token and no backoff](#m1-auth_fail-reconnects-forever-with-a-bad-token-and-no-backoff)
- [ ] [M2: ping/uptime timers leak on a duplicate AUTH_OK](#m2-pinguptime-timers-leak-on-a-duplicate-auth_ok)
- [ ] [M3: state-dump applies relay/input state by array position, not by id](#m3-state-dump-applies-relayinput-state-by-array-position-not-by-id)
- [ ] [M4: token field has no format validation](#m4-token-field-has-no-format-validation)
- [ ] [M5: updateActions rebuilds the whole action set on every node/preset message](#m5-updateactions-rebuilds-the-whole-action-set-on-every-nodepreset-message)
- [ ] [M6: no post-open authentication watchdog timeout](#m6-no-post-open-authentication-watchdog-timeout)
- [ ] [L1: _send silently drops messages when the socket is not open](#l1-_send-silently-drops-messages-when-the-socket-is-not-open)
- [ ] [L2: malformed device messages are swallowed with only a warn log](#l2-malformed-device-messages-are-swallowed-with-only-a-warn-log)
- [ ] [L3: set_led_color does not validate the color option](#l3-set_led_color-does-not-validate-the-color-option)
- [ ] [L4: LED-effect presets omit the Locate effect](#l4-led-effect-presets-omit-the-locate-effect)
- [ ] [L5: auth token stored in a plain textinput instead of secret-text](#l5-auth-token-stored-in-a-plain-textinput-instead-of-secret-text)
- [ ] [L6: relay/input feedbacks reimplement Companion's built-in invert](#l6-relayinput-feedbacks-reimplement-companions-built-in-invert)
- [ ] [N1: option hints use label text instead of the v1.13 description field](#n1-option-hints-use-label-text-instead-of-the-v113-description-field)
- [ ] [N2: no Bonjour/mDNS discovery for an Ethernet device](#n2-no-bonjourmdns-discovery-for-an-ethernet-device)
- [ ] [N3: transient connect failures map to Disconnected rather than ConnectionFailure](#n3-transient-connect-failures-map-to-disconnected-rather-than-connectionfailure)
- [ ] [N4: relay/input changes are processed mid state-dump](#n4-relayinput-changes-are-processed-mid-state-dump)

## 🔴 Critical

### C1: manifest name does not match id
**File:** `companion/manifest.json`

`id` is `cuevacontrol-relo-io8` but `name` is `Cueva Control RELO IO8`. In the official manifest the `name` field is the module slug and must equal `id`; the human-readable label is carried by `manufacturer` + `products` + `shortname` (all already present and correct here). The template ships `id` == `name`.

**Fix (maintainer):** set `"name": "cuevacontrol-relo-io8"` to match `id`.

### C2: low-value keyword relo duplicates the module-name slug
**File:** `companion/manifest.json`

`keywords` includes `"relo"`, which is a token of the module's own slug (`cueva-control-relo-io8`). Keywords that merely repeat the module name add no search value and are rejected by the deterministic manifest check.

**Fix (maintainer):** remove `"relo"` from `keywords` (the descriptive keywords `relay`, `io`, `gpio`, `automation` are fine; `cueva` likewise duplicates a slug token and should be dropped if the check flags it on resubmission).

### C3: set_relay Toggle sends a raw toggle command the device may not accept
**File:** `src/actions.js:58` (option defined at `:32`; preset at `src/presets.js:35`)

The `set_relay` callback forwards `state: 'toggle'` straight to the device as `{ type: 'SET_RELAY', relay_id, state: 'toggle' }` with no client-side resolution. The sibling `set_led_enabled` action resolves toggle locally against module state (`enabled === 'toggle' ? !self.ledEnabled : ...`, `src/actions.js:221`) — so within the same module the two toggle paths are inconsistent. If the firmware does not understand `state: 'toggle'` for relays, every shipped **Toggle Relay** preset/button silently fails (only an `ACK {success:false}` warn is logged, no operator-visible error).

**Fix (maintainer):** confirm the device protocol accepts `state: 'toggle'` for `SET_RELAY`. If it does not, resolve toggle in the callback from `self.relayState[relay_id - 1]` (mirroring the LED logic) and send `on`/`off`. If it does, this can be closed on confirmation.

## 🟠 High

### H1: Pulse action holds an untracked 60s timer that can strand a relay ON
**File:** `src/actions.js:50-55`

The `pulse` branch sends `SET_RELAY on`, `await`s `setTimeout(duration_ms)` (up to 60000ms per the option `max`), then sends `SET_RELAY off`. The timer is not tracked, so it is not cancelled by `destroy()` or `configUpdated()`. If the instance is destroyed or the socket drops/reconnects during the window, the trailing `off` either no-ops against the torn-down socket (`_send` guard) — leaving the relay **latched ON** on the device — or fires against a freshly reconnected socket. Rapid presses also stack independent timers with no coalescing, and a manual relay change during the window is silently overridden by the trailing `off`.

**Fix (maintainer):** prefer a device-side pulse (a single `SET_RELAY` with a `duration_ms` field, if the firmware supports it — the device already emits `RELAY_PULSE_STARTED`, suggesting it does). If client-side timing must stay, track the pulse timer in a set, clear it in `destroy()`/`configUpdated()`, and re-check `authenticated`/`readyState` before sending the trailing `off`.

## 🟡 Medium

### M1: AUTH_FAIL reconnects forever with a bad token and no backoff
**File:** `src/main.js:218-223` (reconnect path `:152-170`)

On `AUTH_FAIL`/`AUTH_ERROR` the handler sets `ConnectionFailure` and calls `this.ws.terminate()`. Terminate fires `close` → `_onDisconnected()` → `_scheduleReconnect()`, which reconnects on a flat 5s interval and re-sends the same bad token indefinitely. The `ConnectionFailure` status is overwritten by `Disconnected` each cycle, so the operator never sees the real cause, and the device is hit every 5s forever.

**Fix (maintainer):** set an `_authFailed` flag on auth failure and skip `_scheduleReconnect()` while it is set (clear it in `configUpdated()`), leaving the status at `ConnectionFailure`/`BadConfig`. Consider exponential backoff (e.g. 1s→2s→5s→15s→30s cap, reset on `AUTH_OK`) for the general reconnect path.

### M2: ping/uptime timers leak on a duplicate AUTH_OK
**File:** `src/main.js:206-215`

`AUTH_OK` unconditionally assigns new `setInterval`s to `this.pingTimer` and `this.uptimeTimer` without clearing existing ones. A re-sent or duplicate `AUTH_OK` (no intervening disconnect) orphans the previous intervals — they keep running, double-incrementing uptime and double-sending pings.

**Fix (maintainer):** clear both timers before assigning them in the `AUTH_OK` branch.

### M3: state-dump applies relay/input state by array position, not by id
**File:** `src/main.js:360-377` (`_handleStateDumpSection`)

Relay/input state is applied by array index (`relayState[i] = !!r.state`), assuming the device always sends exactly 8 ordered entries. If the device sends a sparse or differently-ordered array, states map to the wrong relay/input. Elsewhere the code correctly keys off `relay_id`/`input_id` (`_onRelayChange`, `:448`), so this is an internal inconsistency.

**Fix (maintainer):** key off `r.relay_id`/`inp.input_id` when present (`const idx = (r.relay_id ?? i + 1) - 1`) with bounds checks, instead of trusting array position.

### M4: token field has no format validation
**File:** `src/main.js:95-105`

The config advertises a 64-char hex token but the `token` field has no `regex`, and the `host` regex `/^[\w.-]+$/` accepts many non-host strings. A malformed/empty token surfaces only as the runtime auth-fail reconnect loop (M1) with no actionable status.

**Fix (maintainer):** add a `regex` to the token field (e.g. `/^[0-9a-fA-F]{64}$/`) so bad input is caught before connecting and surfaces a clear `BadConfig`.

### M5: updateActions rebuilds the whole action set on every node/preset message
**File:** `src/main.js:240, 277, 285, 294, 302`

`updateActions(this)` (a full `setActionDefinitions` of every action) is called from `STATE_DUMP_COMPLETE` and from each individual `NODE_*`/`PRESET_*` create/update/delete handler, purely to refresh the `execute_node`/`apply_preset` dropdown choices. On a device with many nodes/presets this thrashes the action registry during a refresh burst and can reset in-progress edits in the UI.

**Fix (maintainer):** debounce/coalesce the refresh so a burst of per-item messages triggers a single `updateActions`, or rebuild only the choice-dependent actions.

### M6: no post-open authentication watchdog timeout
**File:** `src/main.js:122` (handshake) / AUTH send path

`handshakeTimeout: 5000` covers the WS handshake, but nothing covers the post-open AUTH step. If the handshake succeeds but the device never replies `AUTH_OK`/`AUTH_FAIL`, the instance sits in `Connecting` indefinitely with no reconnect (no `close` fires).

**Fix (maintainer):** after sending AUTH, start a one-shot 5–10s timer; if still unauthenticated when it fires, log, `terminate()`, and let reconnect run. Clear it on `AUTH_OK`/`AUTH_FAIL` and in the timer-cleanup path.

## 🟢 Low

### L1: _send silently drops messages when the socket is not open
**File:** `src/main.js:187-191`

`_send()` no-ops when `readyState !== OPEN`. Action callbacks invoked while disconnected (or during the pulse window) are silently discarded — the operator presses a button and nothing happens, with no log or feedback.

**Fix (maintainer):** log at `debug`/`warn` when dropping, and/or warn in the action callback when `!authenticated`.

### L2: malformed device messages are swallowed with only a warn log
**File:** `src/main.js:134-140`

Unparseable frames are caught and logged at `warn`, then the connection silently continues. Fine for a single bad frame, but a device emitting persistently malformed JSON log-spams with no operator-visible signal.

**Fix (maintainer):** optionally track a consecutive-parse-failure counter that degrades status after repeated failures.

### L3: set_led_color does not validate the color option
**File:** `src/actions.js:142-148`

If `action.options.hex_color` is `undefined`/corrupt, `rgb >> 16` coerces to `0` and the module silently sends `#000000` instead of erroring.

**Fix (maintainer):** guard/validate the color value before formatting.

### L4: LED-effect presets omit the Locate effect
**File:** `src/presets.js:279`

The effect presets list 5 of the 6 effects defined in the `set_led_effect` action (`src/actions.js:177-184`) and the variable description (`src/variables.js:29`) — `Locate` has no preset. Operators can still select it via the action; cosmetic.

**Fix (maintainer):** add a `Locate` preset for parity.

### L5: auth token stored in a plain textinput instead of secret-text
**File:** `src/main.js:99-103`

The token is a credential but uses `type: 'textinput'`. v1.13+ supports `secret-text`, which protects the value in config exports.

**Fix (maintainer):** change the `token` field `type` to `'secret-text'`.

### L6: relay/input feedbacks reimplement Companion's built-in invert
**File:** `src/feedbacks.js:73, 111`

The `relay_state` and `input_state` boolean feedbacks expose an `expected_state` (on/off, active/inactive) option whose "off/inactive" branch reproduces Companion's built-in boolean Invert.

**Fix (maintainer, optional):** rely on Companion's built-in invert and drop the inverse choice, or keep the explicit wording if preferred for end users.

## 💡 Nice to Have

### N1: option hints use label text instead of the v1.13 description field
**File:** `src/actions.js` (e.g. `:39`, `:158`)

Several option fields embed guidance in the `label` (e.g. "Pulse duration (ms) — only used when action is Pulse"). v1.13 adds a dedicated `description` field that renders a persistent hint below the input.

**Fix (maintainer):** move parenthetical guidance into `description` for cleaner labels.

### N2: no Bonjour/mDNS discovery for an Ethernet device
**File:** `companion/manifest.json` / config

If the RELO IO8 advertises an mDNS service, a `bonjour-device` config field would streamline setup.

**Fix (maintainer):** add a Bonjour query + `bonjour-device` config field if the hardware supports mDNS.

### N3: transient connect failures map to Disconnected rather than ConnectionFailure
**File:** `src/main.js:147-158`

Socket `'error'` only logs; all status transitions flow through `close` → `Disconnected`, so a wrong-host/refused-connection looks the same as a normal drop.

**Fix (maintainer):** optionally set `ConnectionFailure` after N consecutive failed connect attempts.

### N4: relay/input changes are processed mid state-dump
**File:** `src/main.js:243-249` (vs dump handling `:225-230`)

`_dumpInProgress` guards `NODE_*`/`PRESET_*` deltas, but `RELAY_CHANGE`/`INPUT_CHANGE` are applied during a dump. Combined with M3's positional overwrite, a change arriving mid-dump can be clobbered. Low likelihood.

**Fix (maintainer):** optionally buffer relay/input changes until the dump completes.
