# Review: companion-module-highpass-pptimer v1.1.1

| Field | Value |
| --- | --- |
| **Module** | `companion-module-highpass-pptimer` |
| **Scope** | `tag` |
| **Version** | v1.1.1 |
| **Release** | New module — never published |
| **API** | 2.0 (base 2.0.4, yarn.lock) — requires Companion 4.3+ |
| **Template** | `companion-module-template-js-v2.0.4` @ `e4caa76` (2026-08-28, pinned) · `.yarnrc.yml` from `companion-module-template-js` @ `76d25b2` (2026-10-11) |
| **Commit** | [`eb37ade`](https://github.com/bitfocus/companion-module-highpass-pptimer/tree/eb37adefff5f9fa3b42206e62ec286c4ce21300c) |
| **Reviewed** | 2026-10-30 |

This is the module's first release, so there is no previous tag to diff against. The tag scope therefore covers the whole module, and every finding is classified 🆕 NEW.

## Verdict: ✅ Approved

## 📋 Issues

### Non-blocking

- [ ] [L1: An unexpected message from PPTimer can crash the connection](#l1-an-unexpected-message-from-pptimer-can-crash-the-connection)
- [ ] [L2: Duration, Amount and threshold fields don't resolve variables typed directly in the field](#l2-duration-amount-and-threshold-fields-dont-resolve-variables-typed-directly-in-the-field)
- [ ] [L3: Connect attempt timer keeps running after the connection is closed](#l3-connect-attempt-timer-keeps-running-after-the-connection-is-closed)
- [ ] [L4: Fixed-choice dropdowns offer an expression toggle that has little use](#l4-fixed-choice-dropdowns-offer-an-expression-toggle-that-has-little-use)
- [ ] [N1: Every timer tick re-checks every feedback on every button](#n1-every-timer-tick-re-checks-every-feedback-on-every-button)
- [ ] [N2: Some preset names show raw variable text instead of a readable name](#n2-some-preset-names-show-raw-variable-text-instead-of-a-readable-name)
- [ ] [N3: Module appears as lower-case pptimer in the connection list](#n3-module-appears-as-lower-case-pptimer-in-the-connection-list)

## 🟢 Low

### L1: An unexpected message from PPTimer can crash the connection

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/connection.js:73-92`](https://github.com/bitfocus/companion-module-highpass-pptimer/blob/eb37adefff5f9fa3b42206e62ec286c4ce21300c/src/connection.js#L73-L92), [`src/main.js:110-111`](https://github.com/bitfocus/companion-module-highpass-pptimer/blob/eb37adefff5f9fa3b42206e62ec286c4ce21300c/src/main.js#L110-L111), [`src/main.js:144-146`](https://github.com/bitfocus/companion-module-highpass-pptimer/blob/eb37adefff5f9fa3b42206e62ec286c4ce21300c/src/main.js#L144-L146)

**What goes wrong:** If the PPTimer add-in ever sends a message the module doesn't expect, the module process crashes. Examples are a message that is just `null`, or a layouts list in the settings with an empty (`null`) entry. In the Connections list the pptimer connection shows a crash and restart; Companion restarts it, and the same message can crash it again. While it is down, buttons don't respond and variables such as `$(pptimer:remaining)` stop updating. Whether the add-in ever sends such a message depends on the add-in, so this may never happen in practice.

**Why it happens:** The module guards the JSON parsing with try/catch, but not the code that handles the parsed message. The message handler reads `msg.type`, and the layout code reads each layout's `name`, without checking that they are objects. Node's built-in WebSocket turns an error thrown inside its message listener into an uncaught exception, which ends the module process (the QA reviewer reproduced this with Node v22.21.1).

**Evidence:**

```js
// src/connection.js:91
this.onMessage(msg)
// src/main.js:110-111
handleMessage(msg) {
	switch (msg.type) {
// src/main.js:146
const names = Array.isArray(layouts) ? layouts.map((l) => String(l.name)) : []
```

**Fix:** ignore messages that are not objects, and catch and log any error from the handler instead of letting it escape.

```js
// src/connection.js, after JSON.parse
if (!msg || typeof msg !== 'object') return
// ...
try {
	this.onMessage(msg)
} catch (err) {
	this.log('error', `Failed to handle PPTimer message: ${err}`)
}

// src/main.js, updateLayouts()
layouts.filter((l) => l && typeof l === 'object').map((l) => String(l.name))
```

### L2: Duration, Amount and threshold fields don't resolve variables typed directly in the field

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.js:54`](https://github.com/bitfocus/companion-module-highpass-pptimer/blob/eb37adefff5f9fa3b42206e62ec286c4ce21300c/src/actions.js#L54), [`src/actions.js:93`](https://github.com/bitfocus/companion-module-highpass-pptimer/blob/eb37adefff5f9fa3b42206e62ec286c4ce21300c/src/actions.js#L93), [`src/actions.js:217-218`](https://github.com/bitfocus/companion-module-highpass-pptimer/blob/eb37adefff5f9fa3b42206e62ec286c4ce21300c/src/actions.js#L217-L218)

**What goes wrong:** A user adds the **Set duration** action and types a variable such as `$(internal:custom_talk_length)` into the **Duration** field, the way most Companion text fields work. The action receives the literal text, can't read it as a time, sends nothing, and the log shows "Invalid duration". The same happens with **Add / remove time** > **Amount** and **Colour thresholds** > **Amber from** / **Red from**. Variables do work if the user switches the field to expression mode, so the feature is reachable, just not discoverable.

**Why it happens:** In API 2.0 a plain text field only replaces `$(...)` variables when its definition sets `useVariables: true`. These fields don't set it, so variables only work through expression mode.

**Fix:** add `useVariables: true` to the `time` options of the Set duration and Add / remove time actions, and to the `warn` / `critical` options of Colour thresholds. The callbacks need no other change, because Companion resolves the variables before the callback runs.

```js
{ type: 'textinput', id: 'time', label: 'Duration', default: '5:00', tooltip: TIME_TOOLTIP, useVariables: true },
```

### L3: Connect attempt timer keeps running after the connection is closed

- **Source:** 🔎 protocol reviewer, QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/connection.js:51`](https://github.com/bitfocus/companion-module-highpass-pptimer/blob/eb37adefff5f9fa3b42206e62ec286c4ce21300c/src/connection.js#L51), [`src/connection.js:112-123`](https://github.com/bitfocus/companion-module-highpass-pptimer/blob/eb37adefff5f9fa3b42206e62ec286c4ce21300c/src/connection.js#L112-L123)

**What goes wrong:** Users won't see anything. If a user saves new connection settings or disables the connection while the module is still trying to reach PPTimer (for example when the configured host is unreachable), the old attempt's 5-second connect timer keeps running until it fires. When it fires it does nothing, because the module has already moved on to a different socket. This is a cleanup point, not a leak.

**Why it happens:** The connect timer is a local variable inside `open()`, so only the failure path and the "connected" handler can clear it. `close()` clears the reconnect timer and the heartbeat watchdog, but it can't reach the connect timer.

**Fix:** store the connect timer on the connection object and clear it in `close()` together with the other timers, so `destroy()` and `configUpdated()` stop every timer at once.

```js
// open()
this.connectTimer = setTimeout(() => fail('connect timeout'), 5000)
// close()
clearTimeout(this.connectTimer)
clearTimeout(this.retryTimer)
clearInterval(this.watchdog)
```

### L4: Fixed-choice dropdowns offer an expression toggle that has little use

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.js:55-65`](https://github.com/bitfocus/companion-module-highpass-pptimer/blob/eb37adefff5f9fa3b42206e62ec286c4ce21300c/src/actions.js#L55-L65), [`src/actions.js:83-92`](https://github.com/bitfocus/companion-module-highpass-pptimer/blob/eb37adefff5f9fa3b42206e62ec286c4ce21300c/src/actions.js#L83-L92), [`src/actions.js:115-124`](https://github.com/bitfocus/companion-module-highpass-pptimer/blob/eb37adefff5f9fa3b42206e62ec286c4ce21300c/src/actions.js#L115-L124), [`src/actions.js:143-153`](https://github.com/bitfocus/companion-module-highpass-pptimer/blob/eb37adefff5f9fa3b42206e62ec286c4ce21300c/src/actions.js#L143-L153), [`src/actions.js:178-188`](https://github.com/bitfocus/companion-module-highpass-pptimer/blob/eb37adefff5f9fa3b42206e62ec286c4ce21300c/src/actions.js#L178-L188), [`src/actions.js:235-245`](https://github.com/bitfocus/companion-module-highpass-pptimer/blob/eb37adefff5f9fa3b42206e62ec286c4ce21300c/src/actions.js#L235-L245)

**What goes wrong:** No functional defect. In the action editor, fields such as **Turn a feature on / off** > **Set to** (On / Off / Toggle), **Add / remove time** > **Direction**, **Set duration** > **Then** and **Overlay show / hide** > **Overlay** each show an expression-mode toggle. A user who switches one to expression mode and enters a value that isn't one of the choice ids (for example `"Toggle"` instead of `toggle`) gets the action silently skipped.

**Why it happens:** API 2.0 recommends setting `disableAutoExpression: true` on choice fields that make no sense as expressions. These dropdowns don't set it.

**Fix:** add `disableAutoExpression: true` to the fixed-choice dropdowns: `start` (Set duration), `direction` (Add / remove time, speed adjust, layout step) and `mode` (overlay, feature). Optionally do the same for the `mode` dropdown of the Speed changed feedback in [`src/feedbacks.js:85-95`](https://github.com/bitfocus/companion-module-highpass-pptimer/blob/eb37adefff5f9fa3b42206e62ec286c4ce21300c/src/feedbacks.js#L85-L95). Leave the feature and layout-name dropdowns as they are if expression use is wanted there.

## 💡 Nice to Have

### N1: Every timer tick re-checks every feedback on every button

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:154-162`](https://github.com/bitfocus/companion-module-highpass-pptimer/blob/eb37adefff5f9fa3b42206e62ec286c4ce21300c/src/main.js#L154-L162)

**What goes wrong:** Users see nothing. While the countdown runs, the add-in sends a state about once a second, plus a heartbeat every 5 seconds. Each one makes Companion re-evaluate every PPTimer feedback on every button (phase, running, feature, layout and so on), even when only the countdown text changed. With many PPTimer buttons this is avoidable work.

**Why it happens:** `setState()` always calls `checkAllFeedbacks()` and never compares the new state with the previous one.

**Fix:** compare the fields the feedbacks use (`phase`, `running`, `visible`, `presenterView`, `speedPercent`, `layout`, and whether the state is null) with the previous state, and call `checkFeedbacks(...)` only for the feedbacks whose inputs changed. The variable updates can stay as they are.

### N2: Some preset names show raw variable text instead of a readable name

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/presets.js:8-16`](https://github.com/bitfocus/companion-module-highpass-pptimer/blob/eb37adefff5f9fa3b42206e62ec286c4ce21300c/src/presets.js#L8-L16), [`src/presets.js:36`](https://github.com/bitfocus/companion-module-highpass-pptimer/blob/eb37adefff5f9fa3b42206e62ec286c4ce21300c/src/presets.js#L36), [`src/presets.js:45`](https://github.com/bitfocus/companion-module-highpass-pptimer/blob/eb37adefff5f9fa3b42206e62ec286c4ce21300c/src/presets.js#L45), [`src/presets.js:63`](https://github.com/bitfocus/companion-module-highpass-pptimer/blob/eb37adefff5f9fa3b42206e62ec286c4ce21300c/src/presets.js#L63), [`src/presets.js:81`](https://github.com/bitfocus/companion-module-highpass-pptimer/blob/eb37adefff5f9fa3b42206e62ec286c4ce21300c/src/presets.js#L81)

**What goes wrong:** In the Presets panel, the countdown display preset is named `$(pptimer:remaining)` instead of something readable such as "Countdown display (start / pause)". The reset, speed and layout presets have the same problem (`RESET $(pptimer:duration)`, `SPEED $(pptimer:speed)`, `LAYOUT $(pptimer:layout)`). Cosmetic only.

**Why it happens:** The `button()` helper builds each preset's name from its button text, and these buttons' text contains variable references.

**Fix:** let `button()` take an optional explicit name (for example `name: extra.name ?? text.replace(/\\n/g, ' ')`) and pass readable names for the display, reset, speed and layout presets.

### N3: Module appears as lower-case pptimer in the connection list

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`companion/manifest.json:5-6`](https://github.com/bitfocus/companion-module-highpass-pptimer/blob/eb37adefff5f9fa3b42206e62ec286c4ce21300c/companion/manifest.json#L5-L6)

**What goes wrong:** When a user adds a connection, the module is listed as "pptimer", while the product, the help text and the action descriptions all call it "PPTimer". Cosmetic only.

**Why it happens:** The manifest sets `"name": "pptimer"`.

**Fix:** set `"name": "PPTimer"` in `companion/manifest.json`. The `id` and `shortname` can stay lower-case.
