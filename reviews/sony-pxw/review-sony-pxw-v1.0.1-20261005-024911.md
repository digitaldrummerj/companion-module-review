# Review: sony-pxw v1.0.1

| | |
| --- | --- |
| **Module** | `companion-module-sony-pxw` ([repo](https://github.com/bitfocus/companion-module-sony-pxw)) |
| **Version** | v1.0.1 (`5c94780`, 2026-09-29) |
| **Previous tag** | none (first release) |
| **Scope:** | tag (first release, so all of `src/` was reviewed) |
| **Language** | JavaScript (CommonJS) |
| **Template** | `companion-module-template-js-v2.0.4` @ `e4caa76` (2026-08-28, pinned for API 2.0) |
| **API** | 2.0 (base 2.0.4, yarn.lock) — requires Companion 4.3+ |
| **Transport** | ssh2 1.17.0: Sony PTP-IP tunnelled over two SSH `direct-tcpip` channels to `localhost:15740` |
| **Build** | `yarn install --immutable` and `yarn package` pass; `validate-template.ps1 -RunBuild` reports no findings |
| **Review date** | 2026-10-08 |

This is the module's first release, so the whole module was reviewed and every finding below is new.

## Verdict: ✅ Approved

## 📋 Issues

### Non-blocking

- [ ] [M1: Buttons pressed while the camera is disconnected queue up and fail slowly](#m1-buttons-pressed-while-the-camera-is-disconnected-queue-up-and-fail-slowly)
- [ ] [M2: One slow camera reply can make later commands fail or read the wrong reply](#m2-one-slow-camera-reply-can-make-later-commands-fail-or-read-the-wrong-reply)
- [ ] [M3: A dropped network link takes 15 seconds to notice and unread camera events pile up in memory](#m3-a-dropped-network-link-takes-15-seconds-to-notice-and-unread-camera-events-pile-up-in-memory)
- [ ] [M4: The iris fader can stop responding when moved back to an earlier f-stop](#m4-the-iris-fader-can-stop-responding-when-moved-back-to-an-earlier-f-stop)
- [ ] [M5: The camera password is stored and shown as plain text](#m5-the-camera-password-is-stored-and-shown-as-plain-text)
- [ ] [M6: Dropdown options are hard to use in expression mode](#m6-dropdown-options-are-hard-to-use-in-expression-mode)
- [ ] [M7: A new connection with no camera address has no actions or feedbacks](#m7-a-new-connection-with-no-camera-address-has-no-actions-or-feedbacks)
- [ ] [L1: A running zoom and pending timers are not stopped when the settings change or the connection is disabled](#l1-a-running-zoom-and-pending-timers-are-not-stopped-when-the-settings-change-or-the-connection-is-disabled)
- [ ] [L2: The connection can show OK even when the camera rejected the setup steps](#l2-the-connection-can-show-ok-even-when-the-camera-rejected-the-setup-steps)
- [ ] [L3: A malformed packet from the camera can confuse or stall the connection](#l3-a-malformed-packet-from-the-camera-can-confuse-or-stall-the-connection)
- [ ] [L4: One unrecognised camera setting can put the connection in an endless reconnect loop](#l4-one-unrecognised-camera-setting-can-put-the-connection-in-an-endless-reconnect-loop)
- [ ] [L5: A wrong password is retried every 5 seconds forever and shown as a generic connection failure](#l5-a-wrong-password-is-retried-every-5-seconds-forever-and-shown-as-a-generic-connection-failure)
- [ ] [L6: After saving new settings the old status stays until the camera answers and a missing password is not flagged](#l6-after-saving-new-settings-the-old-status-stays-until-the-camera-answers-and-a-missing-password-is-not-flagged)
- [ ] [L7: Variables and feedbacks keep showing the last values while the camera is disconnected](#l7-variables-and-feedbacks-keep-showing-the-last-values-while-the-camera-is-disconnected)
- [ ] [L8: Slow poll intervals cause false camera-ignored warnings and jumpy nudges](#l8-slow-poll-intervals-cause-false-camera-ignored-warnings-and-jumpy-nudges)
- [ ] [L9: The advanced code fields accept anything including the card-format command the module meant to block](#l9-the-advanced-code-fields-accept-anything-including-the-card-format-command-the-module-meant-to-block)
- [ ] [L10: Iris step buttons and iris presets can land on values that are not real f-stops](#l10-iris-step-buttons-and-iris-presets-can-land-on-values-that-are-not-real-f-stops)
- [ ] [L11: The Offset White nudge label promises a wider range than the action accepts](#l11-the-offset-white-nudge-label-promises-a-wider-range-than-the-action-accepts)
- [ ] [L12: Feedbacks added by hand do not change the button style](#l12-feedbacks-added-by-hand-do-not-change-the-button-style)
- [ ] [L13: Every feedback is re-checked on every poll](#l13-every-feedback-is-re-checked-on-every-poll)
- [ ] [N1: The module does not check the camera identity before sending the password](#n1-the-module-does-not-check-the-camera-identity-before-sending-the-password)
- [ ] [N2: Two code comments disagree on whether Record works](#n2-two-code-comments-disagree-on-whether-record-works)
- [ ] [N3: The module is listed as sony-pxw instead of a readable name](#n3-the-module-is-listed-as-sony-pxw-instead-of-a-readable-name)

---

## 🟡 Medium

### M1: Buttons pressed while the camera is disconnected queue up and fail slowly

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/camera.js:86-95`](https://github.com/bitfocus/companion-module-sony-pxw/blob/5c94780d4c12de65d0a9922f2947712578073b17/src/camera.js#L86-L95), [`src/instance.js:220-590`](https://github.com/bitfocus/companion-module-sony-pxw/blob/5c94780d4c12de65d0a9922f2947712578073b17/src/instance.js#L220-L590)

**What goes wrong:** If the camera drops off the network, pressing a button (Record, an iris step, a zoom) during the next few seconds sends the command into a closed connection, and the press waits the full 15-second timeout before it fails. Commands run one at a time, so five presses take about 75 seconds to clear. While the module is reconnecting, a press can instead fail at once with a JavaScript error, or be sent while the camera is still in the middle of its setup sequence.

**Why it happens:** The actions call the camera's set, control and step functions without checking whether the camera is connected. After a failed poll, the old, closed session stays in place for the 5-second retry window; during a reconnect the new session may not have its command channel yet.

**Fix:** refuse commands straight away when the camera isn't connected. In `Camera.setProp`, `control` and `step`, throw when `this.stopped || !this.connected`, or check `this.cam?.connected` at the top of each action callback and log a short message.

### M2: One slow camera reply can make later commands fail or read the wrong reply

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/sony-ptp.js:39-51`](https://github.com/bitfocus/companion-module-sony-pxw/blob/5c94780d4c12de65d0a9922f2947712578073b17/src/sony-ptp.js#L39-L51), [`src/sony-ptp.js:159-168`](https://github.com/bitfocus/companion-module-sony-pxw/blob/5c94780d4c12de65d0a9922f2947712578073b17/src/sony-ptp.js#L159-L168)

**What goes wrong:** If the camera takes longer than 15 seconds to answer one command from a button, later commands on the same connection can time out or act on a reply that belonged to a different command, for example a setting change reporting the wrong result. A timeout during a poll reconnects and clears this; a timeout during a button press does not, so it lasts until something else forces a reconnect.

**Why it happens:** Each request waits in a queue for the next packet from the camera. When a request times out it gives up, but its place in the queue isn't removed, so the next packet that arrives is handed to the request that already gave up and is lost. The module also never compares the transaction number in the camera's reply with the one it sent, so nothing notices the mismatch.

**Fix:** remove a request from the queue when it times out, treat a timeout as fatal for the session (close it and let `Camera` reconnect), and check the reply's transaction ID (`body.readUInt32LE(2)`) against `tx` in `_op`.

### M3: A dropped network link takes 15 seconds to notice and unread camera events pile up in memory

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/sony-ptp.js:12-21`](https://github.com/bitfocus/companion-module-sony-pxw/blob/5c94780d4c12de65d0a9922f2947712578073b17/src/sony-ptp.js#L12-L21), [`src/sony-ptp.js:68-87`](https://github.com/bitfocus/companion-module-sony-pxw/blob/5c94780d4c12de65d0a9922f2947712578073b17/src/sony-ptp.js#L68-L87), [`src/sony-ptp.js:115-121`](https://github.com/bitfocus/companion-module-sony-pxw/blob/5c94780d4c12de65d0a9922f2947712578073b17/src/sony-ptp.js#L115-L121)

**What goes wrong:** When the network cable is pulled or the camera powers off, the connection keeps showing OK for up to 15 seconds, and button presses in that window hang. Separately, anything the camera sends on its event channel is kept in memory forever, and the copy cost grows with every message. If the camera sends PTP "are you still there?" probes on that channel, they are never answered, and the camera may drop the session.

**Why it happens:** After the setup handshake, nothing reads the event channel again, but its incoming data is still appended to a buffer. The module also doesn't listen for the SSH connection or its channels closing, and doesn't enable SSH keepalives, so a dead link is only noticed when the next request times out.

**Fix:** keep draining the event channel, and react to a closed link at once.

- Answer PTP Probe Requests (type 13) with a Probe Response (type 14) and throw away everything else, or at least clear the buffer when nothing is waiting.
- Add `'close'`/`'end'` handlers on the streams and clients that reject every pending request, mark the channel dead (so `send()` throws), and report the camera down.
- Pass `keepaliveInterval: 5000, keepaliveCountMax: 3` to the SSH `connect()`.

### M4: The iris fader can stop responding when moved back to an earlier f-stop

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/instance.js:290-299`](https://github.com/bitfocus/companion-module-sony-pxw/blob/5c94780d4c12de65d0a9922f2947712578073b17/src/instance.js#L290-L299)

**What goes wrong:** A user sets f/4 with **Iris: set from percent (fader)**, then changes the iris some other way: an **Iris: step** button, an iris preset, the lens ring, auto iris, or a reconnect. Moving the fader back to any position that maps to f/4 then does nothing. Many fader positions map to the same stop, so this is easy to hit.

**Why it happens:** The fader remembers the last f-stop it sent (`this._faderSent`) for the life of the connection and only sends when the new target differs from it, without checking whether the camera's iris has since moved.

**Fix:** track the last sent value only for the duration of one burst: use a local `let sent` inside the busy block, as `nudgeProp` and `_zoomPump` already do, or reset `this._faderSent = undefined` in `finally`.

### M5: The camera password is stored and shown as plain text

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/instance.js:647`](https://github.com/bitfocus/companion-module-sony-pxw/blob/5c94780d4c12de65d0a9922f2947712578073b17/src/instance.js#L647) (read at [`src/instance.js:53`](https://github.com/bitfocus/companion-module-sony-pxw/blob/5c94780d4c12de65d0a9922f2947712578073b17/src/instance.js#L53))

**What goes wrong:** The **Password** field is an ordinary text field, so the camera password is visible on screen and saved with the rest of the connection config.

**Why it happens:** The field is a `textinput`. The base library's typings warn that the whole config object is reported to the web UI (`node_modules/@companion-module/base/dist/module-api/base.d.ts:71`). API 2.0 provides a `secret-text` field type whose value is kept in a separate secrets store and passed to the module on its own.

**Fix:** declare the field as `{ type: 'secret-text', id: 'pass', … }` and read it from the third `init(config, isFirstInit, secrets)` argument and the second `configUpdated(config, secrets)` argument. Doing it in this first release avoids needing an upgrade script later to move existing passwords into secrets.

### M6: Dropdown options are hard to use in expression mode

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/instance.js:314-318`](https://github.com/bitfocus/companion-module-sony-pxw/blob/5c94780d4c12de65d0a9922f2947712578073b17/src/instance.js#L314-L318), [`src/instance.js:347-351`](https://github.com/bitfocus/companion-module-sony-pxw/blob/5c94780d4c12de65d0a9922f2947712578073b17/src/instance.js#L347-L351), [`src/instance.js:373-377`](https://github.com/bitfocus/companion-module-sony-pxw/blob/5c94780d4c12de65d0a9922f2947712578073b17/src/instance.js#L373-L377), [`src/instance.js:422-426`](https://github.com/bitfocus/companion-module-sony-pxw/blob/5c94780d4c12de65d0a9922f2947712578073b17/src/instance.js#L422-L426), [`src/instance.js:433`](https://github.com/bitfocus/companion-module-sony-pxw/blob/5c94780d4c12de65d0a9922f2947712578073b17/src/instance.js#L433), [`src/instance.js:475-479`](https://github.com/bitfocus/companion-module-sony-pxw/blob/5c94780d4c12de65d0a9922f2947712578073b17/src/instance.js#L475-L479), [`src/instance.js:503-508`](https://github.com/bitfocus/companion-module-sony-pxw/blob/5c94780d4c12de65d0a9922f2947712578073b17/src/instance.js#L503-L508), [`src/instance.js:531-535`](https://github.com/bitfocus/companion-module-sony-pxw/blob/5c94780d4c12de65d0a9922f2947712578073b17/src/instance.js#L531-L535), [`src/instance.js:548-552`](https://github.com/bitfocus/companion-module-sony-pxw/blob/5c94780d4c12de65d0a9922f2947712578073b17/src/instance.js#L548-L552)

**What goes wrong:** In Companion 4.3+, a user can switch an action option to expression mode and type the value. For this module they would have to know that `2` means "Manual" or "On", `-1` means "Wide (out)", and `3` means "Memory B". **Auto Framing: tracking start mode** has no labels at all, just a number 1–3.

**Why it happens:** The dropdown choice ids are the camera's raw protocol numbers, and the conversion to the protocol happens nowhere else.

**Fix:** use readable string ids (`'auto'`/`'manual'`, `'on'`/`'off'`, `'tele'`/`'wide'`, `'preset'`/`'mem_a'`/`'mem_b'`) and map them to protocol values in the callback. Add `disableAutoExpression: true` to the two-choice dropdowns, use a labelled dropdown for tracking mode, and update the matching preset options in [`src/presets.js`](https://github.com/bitfocus/companion-module-sony-pxw/blob/5c94780d4c12de65d0a9922f2947712578073b17/src/presets.js). This is the first release, so no upgrade script is needed if it changes now.

### M7: A new connection with no camera address has no actions or feedbacks

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/instance.js:49`](https://github.com/bitfocus/companion-module-sony-pxw/blob/5c94780d4c12de65d0a9922f2947712578073b17/src/instance.js#L49), [`src/instance.js:77-78`](https://github.com/bitfocus/companion-module-sony-pxw/blob/5c94780d4c12de65d0a9922f2947712578073b17/src/instance.js#L77-L78)

**What goes wrong:** A user adds the connection and starts building buttons before entering the camera address. The action and feedback lists are empty, and buttons imported from another system show their actions as unknown until a host is saved.

**Why it happens:** `connect()` returns with Bad Config when no host is set, before it reaches the lines that register the actions and feedbacks.

**Fix:** register the action and feedback definitions in `init()`, before the host check, and keep `connect()` for the camera connection only.

---

## 🟢 Low

### L1: A running zoom and pending timers are not stopped when the settings change or the connection is disabled

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/instance.js:155-159`](https://github.com/bitfocus/companion-module-sony-pxw/blob/5c94780d4c12de65d0a9922f2947712578073b17/src/instance.js#L155-L159), [`src/instance.js:210-217`](https://github.com/bitfocus/companion-module-sony-pxw/blob/5c94780d4c12de65d0a9922f2947712578073b17/src/instance.js#L210-L217), [`src/instance.js:441-447`](https://github.com/bitfocus/companion-module-sony-pxw/blob/5c94780d4c12de65d0a9922f2947712578073b17/src/instance.js#L441-L447), [`src/instance.js:700-702`](https://github.com/bitfocus/companion-module-sony-pxw/blob/5c94780d4c12de65d0a9922f2947712578073b17/src/instance.js#L700-L702)

**What goes wrong:** If a **Zoom (runs until stopped)** is in progress when the user saves new settings or disables the connection, the module never sends the stop command. The review could not confirm whether the camera stops zooming on its own when the session closes; if it doesn't, the lens keeps zooming to its end. Three short timers (the zoom auto-stop, the 1.5-second "camera ignored the change" check, and the 300 ms AI-focus button release) also keep running after a settings change and then act on the new camera.

**Why it happens:** `destroy()` and `connect()` only stop the camera object. The timers live on the instance and are never cleared, and nothing sends the zoom stop (`ZOOM_OP 0`).

**Fix:** keep the timer handles and clear them in `destroy()` and `connect()`, and send a best-effort zoom stop before `cam.stop()` when a zoom is running.

### L2: The connection can show OK even when the camera rejected the setup steps

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/sony-ptp.js:171-177`](https://github.com/bitfocus/companion-module-sony-pxw/blob/5c94780d4c12de65d0a9922f2947712578073b17/src/sony-ptp.js#L171-L177)

**What goes wrong:** If the camera refuses one of the five setup commands (for example the protocol version), the connection still goes to OK. The failure only shows later as a polling error and a reconnect loop, which is harder to diagnose.

**Why it happens:** `handshake()` sends the five commands but never checks the response code the camera returns for each.

**Fix:** throw when a handshake command's response code isn't `0x2001` (OK).

### L3: A malformed packet from the camera can confuse or stall the connection

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/sony-ptp.js:22-31`](https://github.com/bitfocus/companion-module-sony-pxw/blob/5c94780d4c12de65d0a9922f2947712578073b17/src/sony-ptp.js#L22-L31)

**What goes wrong:** A packet that claims a length below 8 bytes is handed out again and again to every waiting request. A packet that claims a huge length makes every request wait for data that never arrives until it times out.

**Why it happens:** The packet reader trusts the length field in each packet's header without checking it.

**Fix:** if `len < 8 || len > MAX_PKT` (for example 16 MB), fail the channel so that the session reconnects.

### L4: One unrecognised camera setting can put the connection in an endless reconnect loop

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/sony-ptp.js:241-242`](https://github.com/bitfocus/companion-module-sony-pxw/blob/5c94780d4c12de65d0a9922f2947712578073b17/src/sony-ptp.js#L241-L242), [`src/sony-ptp.js:248-290`](https://github.com/bitfocus/companion-module-sony-pxw/blob/5c94780d4c12de65d0a9922f2947712578073b17/src/sony-ptp.js#L248-L290), [`src/camera.js:64-71`](https://github.com/bitfocus/companion-module-sony-pxw/blob/5c94780d4c12de65d0a9922f2947712578073b17/src/camera.js#L64-L71)

**What goes wrong:** If a firmware update, or a Z200/NX800 body, reports a single property in a data type the module doesn't know (for example a 128-bit integer), every poll fails. The connection shows "connection lost" and tears down and rebuilds both SSH logins every 5 seconds, forever.

**Why it happens:** The property parser throws on any unknown data type and has no bounds checks, and a failed poll is treated as a lost connection.

**Fix:** stop parsing cleanly at the first unknown type, keep the properties parsed so far, and log a debug message. Report parse errors separately from connection loss.

### L5: A wrong password is retried every 5 seconds forever and shown as a generic connection failure

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/camera.js:43-56`](https://github.com/bitfocus/companion-module-sony-pxw/blob/5c94780d4c12de65d0a9922f2947712578073b17/src/camera.js#L43-L56), [`src/instance.js:61-63`](https://github.com/bitfocus/companion-module-sony-pxw/blob/5c94780d4c12de65d0a9922f2947712578073b17/src/instance.js#L61-L63)

**What goes wrong:** With a wrong password the connection shows Connection Failure rather than an authentication error, retries every 5 seconds, and logs a warning each time. That fills the log, and could trip a login lockout on the camera if it has one.

**Why it happens:** Every failure, whatever the cause, goes through the same fixed 5-second retry and the same warning.

**Fix:** back off exponentially (for example from 5 s up to 60 s). Map ssh2 errors with `err.level === 'client-authentication'` to `InstanceStatus.AuthenticationFailure` with a longer back-off, and log only when the state changes.

### L6: After saving new settings the old status stays until the camera answers and a missing password is not flagged

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/instance.js:47-49`](https://github.com/bitfocus/companion-module-sony-pxw/blob/5c94780d4c12de65d0a9922f2947712578073b17/src/instance.js#L47-L49), [`src/instance.js:695-699`](https://github.com/bitfocus/companion-module-sony-pxw/blob/5c94780d4c12de65d0a9922f2947712578073b17/src/instance.js#L695-L699)

**What goes wrong:** After the user saves new settings, the connection keeps showing its previous OK or failure status until the new camera reports in. An empty **Password** isn't reported as a configuration problem; the module just tries to log in and fails.

**Why it happens:** `init()` sets the status to Connecting, but `configUpdated()` → `connect()` doesn't, and there is no check for an empty password.

**Fix:** call `updateStatus(InstanceStatus.Connecting)` in `connect()` before `cam.start()`, and return Bad Config when `!this.config.pass`.

### L7: Variables and feedbacks keep showing the last values while the camera is disconnected

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/camera.js:64-70`](https://github.com/bitfocus/companion-module-sony-pxw/blob/5c94780d4c12de65d0a9922f2947712578073b17/src/camera.js#L64-L70), [`src/instance.js:61-65`](https://github.com/bitfocus/companion-module-sony-pxw/blob/5c94780d4c12de65d0a9922f2947712578073b17/src/instance.js#L61-L65)

**What goes wrong:** When the camera disconnects, the **Camera is recording** feedback stays red if it was recording, and the iris, battery, card and other variables keep their last values as if they were live.

**Why it happens:** On disconnect, the camera's last polled property table is kept and the variables aren't refreshed.

**Fix:** on disconnect, clear `this.props` and call `updateVariables()`.

### L8: Slow poll intervals cause false camera-ignored warnings and jumpy nudges

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/instance.js:125-129`](https://github.com/bitfocus/companion-module-sony-pxw/blob/5c94780d4c12de65d0a9922f2947712578073b17/src/instance.js#L125-L129), [`src/instance.js:210-217`](https://github.com/bitfocus/companion-module-sony-pxw/blob/5c94780d4c12de65d0a9922f2947712578073b17/src/instance.js#L210-L217)

**What goes wrong:** With **Poll interval (ms)** set above about 1500 (it allows up to 10000), every setting change logs a false "camera ignored the change" warning. The nudge actions (colour temperature, tint, gains) can also jump back and lose ticks, because the next nudge starts from an old polled value.

**Why it happens:** Both the "ignored" check and the nudge hold window use a fixed 1500 ms and assume a fresh poll has arrived by then.

**Fix:** base both windows on the configured poll interval (for example `pollInterval + 500`), or run the check on the next `'props'` event.

### L9: The advanced code fields accept anything including the card-format command the module meant to block

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/instance.js:571-590`](https://github.com/bitfocus/companion-module-sony-pxw/blob/5c94780d4c12de65d0a9922f2947712578073b17/src/instance.js#L571-L590), [`src/instance.js:513-522`](https://github.com/bitfocus/companion-module-sony-pxw/blob/5c94780d4c12de65d0a9922f2947712578073b17/src/instance.js#L513-L522), [`src/instance.js:616`](https://github.com/bitfocus/companion-module-sony-pxw/blob/5c94780d4c12de65d0a9922f2947712578073b17/src/instance.js#L616), [`src/instance.js:625`](https://github.com/bitfocus/companion-module-sony-pxw/blob/5c94780d4c12de65d0a9922f2947712578073b17/src/instance.js#L625), [`src/props.js:79-80`](https://github.com/bitfocus/companion-module-sony-pxw/blob/5c94780d4c12de65d0a9922f2947712578073b17/src/props.js#L79-L80)

**What goes wrong:** The code comments say the card-format command is left out because "this module must never be able to wipe a card", but **Send raw control opcode (advanced)** sends whatever number is typed, so entering 53986 (`0xD2E2`, FormatMediaCard) sends it. An unconfigured **Send raw control opcode** button sends control code 0, and a typo is sent as 0 too.

**Why it happens:** The code fields are free text converted with `Number()`. An empty field becomes `0`, a typo becomes "not a number", which the encoder also writes as `0`, and nothing checks the result. **Set any property**, **Toggle a two-state property**, **Property has value** and **Camera reports control not Active** take their property codes the same way; they don't send bad codes to the camera, but they fail with unclear errors or never match.

**Fix:** validate with `Number.isInteger(code) && code > 0`, refuse `0xD2E2` explicitly, and log invalid input instead of sending it. Consider `type: 'number'` for the code fields.

### L10: Iris step buttons and iris presets can land on values that are not real f-stops

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/camera.js:98-107`](https://github.com/bitfocus/companion-module-sony-pxw/blob/5c94780d4c12de65d0a9922f2947712578073b17/src/camera.js#L98-L107), [`src/presets.js:62-64`](https://github.com/bitfocus/companion-module-sony-pxw/blob/5c94780d4c12de65d0a9922f2947712578073b17/src/presets.js#L62-L64), [`src/instance.js:288`](https://github.com/bitfocus/companion-module-sony-pxw/blob/5c94780d4c12de65d0a9922f2947712578073b17/src/instance.js#L288)

**What goes wrong:** If the camera's list of iris values includes special marker values or is out of order, **Iris: step** can step the wrong way or land on a marker, and the iris presets can include "—" buttons whose value is above the **Iris: set f-stop** option's maximum of 3200.

**Why it happens:** The fader action filters the camera's iris list (`v < 4000`) and sorts it, which suggests the list can contain such values. The step action and the iris preset loop use the raw list.

**Fix:** apply the same filter and sort in `step()` for iris and before building the iris presets.

### L11: The Offset White nudge label promises a wider range than the action accepts

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/instance.js:384`](https://github.com/bitfocus/companion-module-sony-pxw/blob/5c94780d4c12de65d0a9922f2947712578073b17/src/instance.js#L384)

**What goes wrong:** The **Offset White: nudge amount** option is labelled `Change (-99..99)`, but only accepts -20 to 20. A value or expression outside that range is rejected as invalid, so the action does nothing.

**Why it happens:** The option declares `min: -20, max: 20`, and the base library rejects out-of-range values unless `clampValues` is set (`node_modules/@companion-module/base/dist/module-api/input.d.ts:320-321`).

**Fix:** make the label match the range, widen the range to -99..99, or add `clampValues: true`.

### L12: Feedbacks added by hand do not change the button style

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/instance.js:600`](https://github.com/bitfocus/companion-module-sony-pxw/blob/5c94780d4c12de65d0a9922f2947712578073b17/src/instance.js#L600), [`src/instance.js:607`](https://github.com/bitfocus/companion-module-sony-pxw/blob/5c94780d4c12de65d0a9922f2947712578073b17/src/instance.js#L607), [`src/instance.js:614`](https://github.com/bitfocus/companion-module-sony-pxw/blob/5c94780d4c12de65d0a9922f2947712578073b17/src/instance.js#L614), [`src/instance.js:623`](https://github.com/bitfocus/companion-module-sony-pxw/blob/5c94780d4c12de65d0a9922f2947712578073b17/src/instance.js#L623)

**What goes wrong:** A user adds **Camera connected** or **Camera is recording** to a button by hand (not from a preset), and the button doesn't change when the condition is true, so the feedback looks broken until they pick a style.

**Why it happens:** All four on/off feedbacks declare an empty `defaultStyle`.

**Fix:** give each one a sensible default, for example green for connected, red for recording, a highlight for **Property has value** and amber for **Camera reports control not Active**.

### L13: Every feedback is re-checked on every poll

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/instance.js:68`](https://github.com/bitfocus/companion-module-sony-pxw/blob/5c94780d4c12de65d0a9922f2947712578073b17/src/instance.js#L68)

**What goes wrong:** No visible effect, just wasted work: every feedback is re-evaluated on every poll (every second by default), including **Camera connected**, which only changes when the connection goes up or down.

**Fix:** on `'props'`, call `checkFeedbacks('recording', 'propertyIs', 'propertyLocked')`, and check `connected` only in the up/down handlers.

---

## 💡 Nice to Have

### N1: The module does not check the camera identity before sending the password

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/sony-ptp.js:73-85`](https://github.com/bitfocus/companion-module-sony-pxw/blob/5c94780d4c12de65d0a9922f2947712578073b17/src/sony-ptp.js#L73-L85)

**What goes wrong:** The password is sent to whatever answers on port 22 at the configured address, and every login prompt is answered with it. This is acceptable on a closed production network.

**Fix:** consider pinning the camera's SSH host key on first connect (a `hostVerifier`) and warning when it changes.

### N2: Two code comments disagree on whether Record works

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/props.js:82`](https://github.com/bitfocus/companion-module-sony-pxw/blob/5c94780d4c12de65d0a9922f2947712578073b17/src/props.js#L82), [`src/instance.js:238`](https://github.com/bitfocus/companion-module-sony-pxw/blob/5c94780d4c12de65d0a9922f2947712578073b17/src/instance.js#L238)

**What goes wrong:** No user-visible effect. The record command's definition says "accepted but not yet observed to record", while the **Record** action says "CONFIRMED on a Z300".

**Fix:** correct whichever comment is out of date so the next maintainer isn't misled.

### N3: The module is listed as sony-pxw instead of a readable name

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`companion/manifest.json:5`](https://github.com/bitfocus/companion-module-sony-pxw/blob/5c94780d4c12de65d0a9922f2947712578073b17/companion/manifest.json#L5), [`companion/manifest.json:27`](https://github.com/bitfocus/companion-module-sony-pxw/blob/5c94780d4c12de65d0a9922f2947712578073b17/companion/manifest.json#L27)

**What goes wrong:** The manifest `name` is `"sony-pxw"`, the same as the id, so that is the name users see. The keyword `"xdcam"` is a Sony product-line name and adds little next to `manufacturer` and `products`.

**Fix:** use a readable name such as `"Sony PXW"`, and consider a functional search term in place of `"xdcam"`.
