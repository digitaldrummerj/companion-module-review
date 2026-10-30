# Review: companion-module-clearcom-freespeakii v0.1.0

| | |
| --- | --- |
| **Module** | [companion-module-clearcom-freespeakii](https://github.com/bitfocus/companion-module-clearcom-freespeakii) |
| **Scope** | `tag` |
| **Version** | v0.1.0 |
| **Release** | New module — never published |
| **API** | 2.0 (base 2.0.4, yarn.lock) — requires Companion 4.3+ |
| **Template** | `companion-module-template-ts-v2.0.4` @ `d62230e` (2026-08-28, pinned) · `.yarnrc.yml` from `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Commit** | [`8b822aa`](https://github.com/bitfocus/companion-module-clearcom-freespeakii/tree/8b822aa42269fafa7f5486bc20c6c85d781497d5) |
| **Diff** | First release: there is no previous tag, so the whole module was reviewed and every finding is 🆕 NEW |
| **Build** | `yarn install --immutable`, `yarn package` and `yarn lint` passed |
| **Reviewed** | 2026-10-30 |

## Verdict: ✅ Approved

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | In Companion 4.3+, when an option is switched to expression mode, a `$(options:<id>)` reference in another field's visibility rule sees the expression rather than its evaluated result, so the dependent field's visibility no longer follows the effective value | The `isVisibleExpression` note in the `@companion-module/base` 2.0.4 typings (`input.d.ts`), which says referencing such fields is unsupported; Companion's UI behaviour not observed | [M1](#m1-pulse-length-ms-can-be-hidden-or-shown-wrongly-once-mode-is-switched-to-an-expression) |
| A2 | Companion can hand the module a number config field as `null`, `undefined` or `0` when the user clears it, instead of refusing to save or substituting the field's default | The module's `{ ...DEFAULT_CONFIG, ...config }` merge only keeps a default when the key is absent; how the Companion web UI saves an emptied number field was not checked | [L2](#l2-a-blank-or-invalid-heartbeat-interval-ms-makes-the-module-poll-the-base-about-1000-times-a-second) |

## 📋 Issues

### Non-blocking

- [ ] [M1: "Pulse length (ms)" can be hidden or shown wrongly once Mode is switched to an expression](#m1-pulse-length-ms-can-be-hidden-or-shown-wrongly-once-mode-is-switched-to-an-expression)
- [ ] [M2: GitHub CI workflow differs from the template](#m2-github-ci-workflow-differs-from-the-template)
- [ ] [L1: Base answers HTTP but its live connection never opens: status stays "Connecting" with no log line](#l1-base-answers-http-but-its-live-connection-never-opens-status-stays-connecting-with-no-log-line)
- [ ] [L2: A blank or invalid "Heartbeat interval (ms)" makes the module poll the base about 1000 times a second](#l2-a-blank-or-invalid-heartbeat-interval-ms-makes-the-module-poll-the-base-about-1000-times-a-second)
- [ ] [L3: Talk tallies and variables can lag for as long as pack updates keep arriving less than 50 ms apart](#l3-talk-tallies-and-variables-can-lag-for-as-long-as-pack-updates-keep-arriving-less-than-50-ms-apart)
- [ ] [L4: A pack update with a crafted path can change every object in the module process](#l4-a-pack-update-with-a-crafted-path-can-change-every-object-in-the-module-process)
- [ ] [L5: Key and target choices are hard to type in expression mode](#l5-key-and-target-choices-are-hard-to-type-in-expression-mode)
- [ ] [N1: Channel and port call actions skip the checks the other actions make](#n1-channel-and-port-call-actions-skip-the-checks-the-other-actions-make)
- [ ] [N2: No presets: users must build every button by hand](#n2-no-presets-users-must-build-every-button-by-hand)

## 🟡 Medium

### M1: "Pulse length (ms)" can be hidden or shown wrongly once Mode is switched to an expression

- **Source:** 🔎 compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:39-47`](https://github.com/bitfocus/companion-module-clearcom-freespeakii/blob/8b822aa42269fafa7f5486bc20c6c85d781497d5/src/actions.ts#L39-L47), [`src/actions.ts:89-100`](https://github.com/bitfocus/companion-module-clearcom-freespeakii/blob/8b822aa42269fafa7f5486bc20c6c85d781497d5/src/actions.ts#L89-L100), [`src/actions.ts:169-179`](https://github.com/bitfocus/companion-module-clearcom-freespeakii/blob/8b822aa42269fafa7f5486bc20c6c85d781497d5/src/actions.ts#L169-L179), [`src/actions.ts:251-261`](https://github.com/bitfocus/companion-module-clearcom-freespeakii/blob/8b822aa42269fafa7f5486bc20c6c85d781497d5/src/actions.ts#L251-L261)

**What goes wrong:** A user adds "Call signal: role / pack", "Call signal: whole channel" or "Call signal: base port" to a button and switches the Mode dropdown to expression mode, for example to drive it from a variable that evaluates to `pulse`. The "Pulse length (ms)" field is shown only when Mode is `pulse`, and that test cannot see the value the expression computes. So the field's visibility no longer follows the mode the action will actually run, and the user may be unable to see or change the pulse length (for example 2000 ms) of a call that pulses. The action still runs with the saved or default pulse length; only the editor is affected. Users who leave Mode as a normal dropdown are not affected.

**Why it happens:** In API 2.0 every action option can be toggled to an expression unless it sets `disableAutoExpression: true`. The base typings say a field's visibility rule (`isVisibleExpression`) may only reference options that set `disableAutoExpression`, because other options can be expressions. The shared "Pulse length (ms)" option reads `$(options:mode)`, and none of the three Mode dropdowns disables expression mode.

**Evidence:**

```ts
// src/actions.ts:39-47
const PULSE_OPTION = {
	id: 'pulseMs',
	type: 'number',
	label: 'Pulse length (ms)',
	default: 2000,
	min: 100,
	max: 30000,
	isVisibleExpression: `$(options:mode) == 'pulse'`,
} as const
```

```ts
// src/actions.ts:89-102
				{
					id: 'mode',
					type: 'dropdown',
					label: 'Mode',
					default: 'pulse',
					choices: [
						{ id: 'pulse', label: 'Pulse' },
						{ id: 'on', label: 'On' },
						{ id: 'off', label: 'Off' },
						{ id: 'toggle', label: 'Toggle' },
					],
				},
				PULSE_OPTION,
				TEXT_OPTION,
```

```ts
// node_modules/@companion-module/base/dist/module-api/input.d.ts:31-43 (base 2.0.4)
     * You can access a value of the current options using `$(options:some_field_id)`.
     * Note: you can only reference fields which are set to `disableAutoExpression` here, as other fields can be expressions and frequently changing values
     */
    isVisibleExpression?: string;
```

**Confirm by:** open [`src/actions.ts:46`](https://github.com/bitfocus/companion-module-clearcom-freespeakii/blob/8b822aa42269fafa7f5486bc20c6c85d781497d5/src/actions.ts#L46) and the three `mode` dropdowns linked above. None sets `disableAutoExpression: true`, yet the pulse field's visibility reads `$(options:mode)`.

**Fix:** stop the three Mode dropdowns used with the pulse field from being switched to expressions. A pulse/on/off/toggle choice makes little sense as an expression, and this is a first release, so no saved expressions can break. Adding the same flag to the "Route base port to channel" and "Set base GPO" Mode dropdowns keeps them consistent. Alternatively, drop the visibility rule and always show "Pulse length (ms)".

```ts
{
	id: 'mode',
	type: 'dropdown',
	label: 'Mode',
	default: 'pulse',
	disableAutoExpression: true,
	choices: [ /* ... */ ],
},
```

### M2: GitHub CI workflow differs from the template

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.github/workflows/node.yaml:27`](https://github.com/bitfocus/companion-module-clearcom-freespeakii/blob/8b822aa42269fafa7f5486bc20c6c85d781497d5/.github/workflows/node.yaml#L27)

**What goes wrong:** The module's CI workflow is not a copy of the template's, which makes it harder to compare against the template when troubleshooting CI later. CI still runs the template's checks, and the Node.js version is unchanged.

**Why it happens:** The module removed the template-repo-only "Prepare Environment (For template repository)" step (the template itself says modules may remove it) and the commented-out `test:` job block. The validator reports the first difference: line 27 is `- name: Prepare module` where the template has `- name: Prepare Environment (For template repository)`.

**Fix:** copy `.github/workflows/node.yaml` from `companion-module-template-ts-v2.0.4` if you want exact parity with the template.

## 🟢 Low

### L1: Base answers HTTP but its live connection never opens: status stays "Connecting" with no log line

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/socket.ts:29-53`](https://github.com/bitfocus/companion-module-clearcom-freespeakii/blob/8b822aa42269fafa7f5486bc20c6c85d781497d5/src/socket.ts#L29-L53)

**What goes wrong:** Say the base at 10.0.0.50 answers the REST API, so the heartbeat succeeds, but the live-update connection (socket.io) never completes its handshake, for example because a proxy blocks WebSockets. The connection status then stays at "Connecting to 10.0.0.50" forever, and the log never says why. The user can't tell a slow connect from one that will never work. If the REST API fails too, the heartbeat already shows Connection Failure, so this only matters when HTTP works and the live connection doesn't.

**Why it happens:** The socket wrapper only listens for the `connect` and `disconnect` events. socket.io-client 2.5.0 reports handshake failures through `connect_error` and `connect_timeout`, and the module listens for neither. The status only turns OK once the socket connects, and only turns to Connection Failure when the REST call fails.

**Fix:** forward `connect_error` and `connect_timeout` from the socket wrapper as an error event. In `main.ts`, log it once per outage at warn level, and set `InstanceStatus.ConnectionFailure` with a message such as `Live updates unavailable: <reason>` after a few failed attempts, even while the heartbeat succeeds.

### L2: A blank or invalid "Heartbeat interval (ms)" makes the module poll the base about 1000 times a second

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:52`](https://github.com/bitfocus/companion-module-clearcom-freespeakii/blob/8b822aa42269fafa7f5486bc20c6c85d781497d5/src/main.ts#L52), [`src/main.ts:63`](https://github.com/bitfocus/companion-module-clearcom-freespeakii/blob/8b822aa42269fafa7f5486bc20c6c85d781497d5/src/main.ts#L63), [`src/main.ts:101`](https://github.com/bitfocus/companion-module-clearcom-freespeakii/blob/8b822aa42269fafa7f5486bc20c6c85d781497d5/src/main.ts#L101)

**What goes wrong:** If a user clears the "Heartbeat interval (ms)" field, or it is saved as empty or 0, the module stops polling every 10 seconds and polls the base's REST API back-to-back, roughly every millisecond. That puts a constant load on the base's web server and on Companion's CPU, while the connection still shows OK.

**Why it happens:** The config is merged over the defaults, so a key that is present but empty overrides the default of 10000. The heartbeat timer then runs with an empty or 0 delay, which Node.js treats as 1 ms. The field's minimum of 2000 only guides the UI; the code never enforces it.

**Fix:** clamp the value before starting the timer, and treat "Device ID" and the low-battery threshold the same way, falling back to their defaults when they aren't finite numbers.

```ts
const hb = Math.max(2000, Number(this.config.heartbeatMs) || DEFAULT_CONFIG.heartbeatMs)
this.#heartbeat = setInterval(() => void this.#pollDevice(), hb)
```

### L3: Talk tallies and variables can lag for as long as pack updates keep arriving less than 50 ms apart

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:273-291`](https://github.com/bitfocus/companion-module-clearcom-freespeakii/blob/8b822aa42269fafa7f5486bc20c6c85d781497d5/src/main.ts#L273-L291)

**What goes wrong:** On a busy system (many packs sending signal-strength, link-quality or key updates), the "Role / pack is talking" feedback and the `rN_talking` / `rN_battery` variables only refresh once the base has been quiet for 50 ms. Under a steady stream of updates, a talk tally on a button can visibly lag or freeze until there is a gap.

**Why it happens:** The redraw is debounced: each new update cancels the pending redraw and starts the 50 ms wait again, with no maximum wait. The same applies to the 250 ms live refetches and the 500 ms definitions rebuild.

**Fix:** throttle the redraw instead of debouncing it: if a redraw is already pending, leave it in place rather than restarting it. Alternatively, add a maximum wait so the redraw always runs within 50 ms of the first queued change.

### L4: A pack update with a crafted path can change every object in the module process

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/state.ts:32-40`](https://github.com/bitfocus/companion-module-clearcom-freespeakii/blob/8b822aa42269fafa7f5486bc20c6c85d781497d5/src/state.ts#L32-L40), [`src/state.ts:112-121`](https://github.com/bitfocus/companion-module-clearcom-freespeakii/blob/8b822aa42269fafa7f5486bc20c6c85d781497d5/src/state.ts#L112-L121)

**What goes wrong:** Nothing visible in normal use. But if anything answering on the base's address sent a pack update whose path starts with `__proto__.` (for example `__proto__.status`), the module would write that property onto the prototype every JavaScript object shares. Every pack could then suddenly appear online, or option lookups could behave strangely, until the module restarts.

**Why it happens:** The helper that applies a pack update walks the dotted path from the message without filtering keys, and `__proto__` resolves to the shared object prototype. The path comes straight from the network message.

**Fix:** reject the keys `__proto__`, `prototype` and `constructor` in `setByPath`.

```ts
if (parts.some((k) => k === '__proto__' || k === 'constructor' || k === 'prototype')) return
```

### L5: Key and target choices are hard to type in expression mode

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/choices.ts:10-17`](https://github.com/bitfocus/companion-module-clearcom-freespeakii/blob/8b822aa42269fafa7f5486bc20c6c85d781497d5/src/choices.ts#L10-L17), [`src/choices.ts:23-29`](https://github.com/bitfocus/companion-module-clearcom-freespeakii/blob/8b822aa42269fafa7f5486bc20c6c85d781497d5/src/choices.ts#L23-L29)

**What goes wrong:** A user who switches the "Key" option of "Role / pack is talking" to expression mode has to know that Key A is `0` and the Reply key is `4`. In "Roles / packs" they would have to type ids like `r:5` or `p:12`. Users who pick from the dropdown see the friendly labels and are not affected.

**Why it happens:** In API 2.x, users type a dropdown's internal id when the option is in expression mode, so the 2.0 guidance recommends readable string ids. The key choices use numeric ids 0-4, and the target choices encode ids as `r:<role id>` / `p:<pack id>`.

**Fix:** use readable ids for the key choices (for example `a`, `b`, `c`, `d`, `reply`) and map them to key numbers in the callback. Add an `expressionDescription` to "Key" and "Roles / packs" explaining the id format (for example `r:<role id> or p:<pack id>`). The free-text "Or by name" field already covers most expression use.

## 💡 Nice to Have

### N1: Channel and port call actions skip the checks the other actions make

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:191-201`](https://github.com/bitfocus/companion-module-clearcom-freespeakii/blob/8b822aa42269fafa7f5486bc20c6c85d781497d5/src/actions.ts#L191-L201), [`src/actions.ts:264-272`](https://github.com/bitfocus/companion-module-clearcom-freespeakii/blob/8b822aa42269fafa7f5486bc20c6c85d781497d5/src/actions.ts#L264-L272)

**What goes wrong:** While the live connection to the base is down, pressing a "Call signal: whole channel" button logs "Channel call: not connected to the base" for the packs, but still sends one HTTP call per 2W/4W member port and logs a failure for each. With "Call signal: base port", if no ports had loaded when the action was created, the Port dropdown defaults to 0 and the action calls port 0 instead of reporting that the port doesn't exist. "Route base port to channel" and "Change pack role" check both cases.

**Why it happens:** In the channel call, only the pack loop checks the connection; the port loop always runs. The port call doesn't check that the selected port exists, unlike the port route action.

**Fix:** in the channel call, return early when there is no API or the socket isn't connected, before both loops. In the port call, add the same "port not found" check the port route action uses.

```ts
if (!state.ports.has(options.port)) return self.log('warn', `Port call: port ${options.port} not found`)
```

### N2: No presets: users must build every button by hand

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:293-299`](https://github.com/bitfocus/companion-module-clearcom-freespeakii/blob/8b822aa42269fafa7f5486bc20c6c85d781497d5/src/main.ts#L293-L299)

**What goes wrong:** Nothing for this connection appears in the Presets tab. To get, say, a role tally button that turns red when that role talks, users must add the action and the "Role / pack is talking" feedback themselves. Everything still works; it is just less convenient. Presets are optional for a first release.

**Why it happens:** The module defines actions, feedbacks and variables, but never calls `setPresetDefinitions`.

**Fix:** consider adding presets in a later release with `setPresetDefinitions(structure, presets)`. Good candidates: a tally per role (the role's label variable as text, plus the "talking", "has a call signal active" and "online" feedbacks), a channel call pulse, and a base-connected status button. For per-role buttons, a `type: 'template'` group keeps the preset list short.
