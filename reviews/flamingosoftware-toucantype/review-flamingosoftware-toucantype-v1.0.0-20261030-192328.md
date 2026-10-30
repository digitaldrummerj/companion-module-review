# Review: flamingosoftware-toucantype v1.0.0

| | |
| --- | --- |
| **Module** | [companion-module-flamingosoftware-toucantype](https://github.com/bitfocus/companion-module-flamingosoftware-toucantype) |
| **Scope** | `tag` |
| **Version** | `v1.0.0` (commit `b593e26`) |
| **Release** | New module — never published |
| **API** | 2.0 (base 2.0.4, yarn.lock) — requires Companion 4.3+ |
| **Template** | `companion-module-template-js-v2.0.4` @ `e4caa76` (2026-08-28, pinned) · `.yarnrc.yml` from `companion-module-template-js` @ `76d25b2` (2026-10-11) |
| **Previous tag** | none — first release, so there is no diff: the whole module was reviewed |
| **Language** | JavaScript (ESM) |
| **Build** | `yarn install --immutable` and `yarn package` succeed |
| **Reviewed** | 2026-10-30 |

## Verdict: ✅ Approved

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | With Node's `reuseAddr: true`, a second UDP socket can bind the same port (libuv sets SO_REUSEADDR, and SO_REUSEPORT on macOS), and each unicast datagram then reaches only one of the bound sockets | General Node, libuv and OS socket behaviour; not reproduced in this review | [M1](#m1-a-second-connection-on-the-same-status-listen-port-shows-ok-but-never-receives-status) |
| A2 | Companion's config editor lets a user save an empty "Trigger Port" text field (it has a regex but is not required), and Companion logs an error thrown by an action callback instead of crashing the module | Companion host behaviour for `textinput` fields; host code not checked | [L2](#l2-an-empty-trigger-port-makes-every-trigger-button-fail-with-an-error) |
| A3 | Companion does not rewrite a hard-coded `$(ToucanType:...)` prefix in preset text to the connection's real label when the preset is placed, and a second connection of the module gets a different default label (e.g. `ToucanType_2`) | General knowledge of Companion's preset handling and default labelling; not visible in the module or in `@companion-module/base` 2.0.4 | [L3](#l3-preset-buttons-show-nothing-or-another-connections-values-unless-the-connection-is-labelled-toucantype) |
| A4 | Companion 4.3/4.x uses a preset's numeric `size` as-is; only Companion 5 applies the 1/0.6 legacy-style conversion the module's comment describes | The module's own comment citing Companion 5's `ConvertLegacyStyleToElements.ts`, and the base 2.0.4 `CompanionTextSize` typing; the Companion 4.x renderer was not inspected | [L4](#l4-preset-text-comes-out-smaller-than-intended-on-companion-43-and-4x) |

## 📋 Issues

### Non-blocking

- [ ] [M1: A second connection on the same Status Listen Port shows OK but never receives status](#m1-a-second-connection-on-the-same-status-listen-port-shows-ok-but-never-receives-status)
- [ ] [M2: Connection shows OK with no ToucanType IP set, and trigger buttons silently do nothing](#m2-connection-shows-ok-with-no-toucantype-ip-set-and-trigger-buttons-silently-do-nothing)
- [ ] [L1: Trigger buttons do nothing while the Status Listen Port is busy](#l1-trigger-buttons-do-nothing-while-the-status-listen-port-is-busy)
- [ ] [L2: An empty Trigger Port makes every trigger button fail with an error](#l2-an-empty-trigger-port-makes-every-trigger-button-fail-with-an-error)
- [ ] [L3: Preset buttons show nothing or another connection's values unless the connection is labelled ToucanType](#l3-preset-buttons-show-nothing-or-another-connections-values-unless-the-connection-is-labelled-toucantype)
- [ ] [L4: Preset text comes out smaller than intended on Companion 4.3 and 4.x](#l4-preset-text-comes-out-smaller-than-intended-on-companion-43-and-4x)
- [ ] [L5: Feedback dropdowns can be switched to expression mode for no benefit](#l5-feedback-dropdowns-can-be-switched-to-expression-mode-for-no-benefit)
- [ ] [L6: Port settings are free-text boxes instead of number fields](#l6-port-settings-are-free-text-boxes-instead-of-number-fields)
- [ ] [L7: The help page documents only one of the three feedbacks and misses three variables](#l7-the-help-page-documents-only-one-of-the-three-feedbacks-and-misses-three-variables)
- [ ] [N1: Make plus update comparison lights up before ToucanType has sent any counts](#n1-make-plus-update-comparison-lights-up-before-toucantype-has-sent-any-counts)
- [ ] [N2: Manifest apiVersion is set by hand instead of the template's 0.0.0](#n2-manifest-apiversion-is-set-by-hand-instead-of-the-templates-000)

## 🟡 Medium

### M1: A second connection on the same Status Listen Port shows OK but never receives status

- **Source:** 🔎 protocol reviewer + QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/link.js:35`](https://github.com/bitfocus/companion-module-flamingosoftware-toucantype/blob/b593e268b0fa8a1963ac61e5075ec94cb066c919/src/link.js#L35)

**What goes wrong:** A user adds a second ToucanType connection (or duplicates the first, or leaves an old copy enabled) and keeps the Status Listen Port at 5051 on both. Both connections go green with "Waiting for first status from ToucanType". ToucanType's status packets reach only one of them, so on the other connection the variables (`cues_to_make`, `state`, `show_progress`, …) and the "Cue count comparison", "ToucanType is working" and "Connection state" feedbacks never update. The module's own helpful message, "UDP 5051 is already in use… (OSCRouter, or an old copy of this module)", never appears in this case.

**Why it happens:** The status socket is created with `reuseAddr: true`. With that option the operating system lets a second socket bind the same UDP port instead of refusing it with `EADDRINUSE`, and each incoming unicast packet is then handed to only one of the sockets. The module's `EADDRINUSE` handling in `onLinkError()` ([`src/main.js:133-137`](https://github.com/bitfocus/companion-module-flamingosoftware-toucantype/blob/b593e268b0fa8a1963ac61e5075ec94cb066c919/src/main.js#L133-L137)) only works when port sharing is off.

**Evidence:**

```js
// src/link.js:35
const socket = dgram.createSocket({ type: 'udp4', reuseAddr: true })
```

**Fix:** Create the socket without port sharing, so a busy port fails with `EADDRINUSE` and the existing clear error message and 10-second retry take over. The module only receives unicast OSC, so it doesn't need to share the port, and `stop()` already closes the old socket before `#openLink()` rebinds.

```js
const socket = dgram.createSocket('udp4')
```

### M2: Connection shows OK with no ToucanType IP set, and trigger buttons silently do nothing

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:76-81`](https://github.com/bitfocus/companion-module-flamingosoftware-toucantype/blob/b593e268b0fa8a1963ac61e5075ec94cb066c919/src/main.js#L76-L81), [`src/main.js:101-128`](https://github.com/bitfocus/companion-module-flamingosoftware-toucantype/blob/b593e268b0fa8a1963ac61e5075ec94cb066c919/src/main.js#L101-L128)

**What goes wrong:** On a new connection the "ToucanType IP" field is empty (it has no default), yet the connection still goes green: "OK - Waiting for first status from ToucanType". Status variables can even fill in, because ToucanType pushes to Companion's IP. But pressing the "Make / Update Cues (Live)" preset does nothing, and the only trace is a warning in the connection log: "Not sending /toucantype/make: no ToucanType IP configured".

**Why it happens:** `#openLink()` checks only the Status Listen Port before reporting the connection as OK. The IP is checked only inside `ToucanTypeLink.send()` ([`src/link.js:79-82`](https://github.com/bitfocus/companion-module-flamingosoftware-toucantype/blob/b593e268b0fa8a1963ac61e5075ec94cb066c919/src/link.js#L79-L82)), which logs a warning and returns, so the connection status never mentions the missing IP.

**Fix:** When the IP is empty, report it in the connection status (the status socket can still be bound so the status feed keeps working). For example, in `onLinkReady()`:

```js
if (!this.config?.host) {
	this.updateStatus(InstanceStatus.BadConfig, 'Set the ToucanType IP')
	return
}
```

## 🟢 Low

### L1: Trigger buttons do nothing while the Status Listen Port is busy

- **Source:** 🔎 protocol reviewer + QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/link.js:38-43`](https://github.com/bitfocus/companion-module-flamingosoftware-toucantype/blob/b593e268b0fa8a1963ac61e5075ec94cb066c919/src/link.js#L38-L43), [`src/link.js:74-78`](https://github.com/bitfocus/companion-module-flamingosoftware-toucantype/blob/b593e268b0fa8a1963ac61e5075ec94cb066c919/src/link.js#L74-L78)

**What goes wrong:** If another app (for example OSCRouter) already holds UDP 5051 on the Companion machine, the connection goes red with "UDP 5051 is already in use…". While it stays red, every trigger action ("Make / Update Cues (Live)", "Make / Update Cues (Blind)", "Refresh Disguise", "Delete Unmatched Console Cues") is skipped, and the only sign is a log warning: "Not sending /toucantype/make: socket is not open". A user who only wants the trigger buttons, and doesn't use the status feed, loses the triggers too. The red status does explain why, so the impact is low.

**Why it happens:** The module sends and receives on one UDP socket (deliberately, to give triggers a fixed source port for firewalls). When binding the listen port fails, the socket's error handler calls `stop()`, which clears the socket, and `send()` then returns early until the 10-second retry manages to bind.

**Fix:** Either fall back to a separate, unbound UDP socket for triggers while the status socket isn't bound (and close it in `destroy()` and `#openLink()`), or keep the design and say in the config text and help page that triggers are not sent while the Status Listen Port is unavailable.

### L2: An empty Trigger Port makes every trigger button fail with an error

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:205-207`](https://github.com/bitfocus/companion-module-flamingosoftware-toucantype/blob/b593e268b0fa8a1963ac61e5075ec94cb066c919/src/main.js#L205-L207), [`src/link.js:92`](https://github.com/bitfocus/companion-module-flamingosoftware-toucantype/blob/b593e268b0fa8a1963ac61e5075ec94cb066c919/src/link.js#L92)

**What goes wrong:** If a user clears the "Trigger Port" field in the connection settings, pressing any trigger button sends nothing. Instead of the module's own friendly warning, the log shows an error thrown from inside the action (`ERR_SOCKET_BAD_PORT`, port 0).

**Why it happens:** `this.config?.triggerPort ?? 5050` falls back to 5050 only when the value is missing, not when it is an empty string. `Number('')` is 0, and `socket.send(..., 0, host, cb)` throws straight away instead of reporting through its callback.

**Fix:** Parse and check the port before sending, and fall back to the default (or log a warning) when it isn't a valid port.

```js
const port = Number(this.config?.triggerPort) || 5050
```

### L3: Preset buttons show nothing or another connection's values unless the connection is labelled ToucanType

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/presets.js:105`](https://github.com/bitfocus/companion-module-flamingosoftware-toucantype/blob/b593e268b0fa8a1963ac61e5075ec94cb066c919/src/presets.js#L105), [`src/presets.js:115`](https://github.com/bitfocus/companion-module-flamingosoftware-toucantype/blob/b593e268b0fa8a1963ac61e5075ec94cb066c919/src/presets.js#L115), [`src/presets.js:126`](https://github.com/bitfocus/companion-module-flamingosoftware-toucantype/blob/b593e268b0fa8a1963ac61e5075ec94cb066c919/src/presets.js#L126), [`src/presets.js:130-152`](https://github.com/bitfocus/companion-module-flamingosoftware-toucantype/blob/b593e268b0fa8a1963ac61e5075ec94cb066c919/src/presets.js#L130-L152)

**What goes wrong:** The status presets ("EOS connection", "Show progress", "Cues to make", "Make + Update", …) show values such as `$(ToucanType:console)` and `$(ToucanType:cues_to_make)`. If the user renames the connection, or adds a second one (labelled `ToucanType_2`), the presets dragged from that connection show the first connection's values, or nothing at all.

**Why it happens:** The variable references in the preset text use the literal label `ToucanType` instead of the connection's actual label.

**Fix:** Build the preset text from the connection's label, and rebuild the presets in `configUpdated()` since the label can change.

```js
'EOS\n$(' + self.label + ':console)'
```

### L4: Preset text comes out smaller than intended on Companion 4.3 and 4.x

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/presets.js:35-41`](https://github.com/bitfocus/companion-module-flamingosoftware-toucantype/blob/b593e268b0fa8a1963ac61e5075ec94cb066c919/src/presets.js#L35-L41)

**What goes wrong:** The module targets API 2.0, so it also runs on Companion 4.3 and 4.x. On those versions a user who drags in "Make Live" or "Show progress" gets text at size 12 or 10.8 instead of the intended 20 or 18, and 10.8 isn't one of the Style tab's size choices.

**Why it happens:** The preset sizes are pre-scaled by 0.6 to undo Companion 5's legacy-style conversion on import (the code comment cites `ConvertLegacyStyleToElements.ts`). Companion 4.x has no such conversion, so it uses the scaled-down number as-is.

**Fix:** Use standard sizes that read well on both hosts (for example `'18'` or `'auto'`). If the Companion 5 look is what you want, move to base `~2.1.x` so the module requires Companion 5, rather than scaling by 0.6 on a module that also runs on 4.x.

### L5: Feedback dropdowns can be switched to expression mode for no benefit

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.js:30-36`](https://github.com/bitfocus/companion-module-flamingosoftware-toucantype/blob/b593e268b0fa8a1963ac61e5075ec94cb066c919/src/feedbacks.js#L30-L36), [`src/feedbacks.js:57-71`](https://github.com/bitfocus/companion-module-flamingosoftware-toucantype/blob/b593e268b0fa8a1963ac61e5075ec94cb066c919/src/feedbacks.js#L57-L71), [`src/feedbacks.js:108-126`](https://github.com/bitfocus/companion-module-flamingosoftware-toucantype/blob/b593e268b0fa8a1963ac61e5075ec94cb066c919/src/feedbacks.js#L108-L126)

**What goes wrong:** In the "ToucanType is working", "Connection state" and "Cue count comparison" feedbacks, the "Doing", "When", "Count" and "Is" dropdowns can be flipped to expression mode in the button editor. An expression that returns something other than a choice id (e.g. "Making" instead of "making") makes the button simply stop changing colour. Normal (non-expression) use is unaffected.

**Why it happens:** In API 2.0 every option field supports expression mode unless it sets `disableAutoExpression: true`. These dropdowns are fixed selectors that gain nothing from expressions.

**Fix:** Add `disableAutoExpression: true` to the `activity`, `which`, `counter` and `comparison` dropdowns, and leave the numeric "Value" field expression-capable.

### L6: Port settings are free-text boxes instead of number fields

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:82-97`](https://github.com/bitfocus/companion-module-flamingosoftware-toucantype/blob/b593e268b0fa8a1963ac61e5075ec94cb066c919/src/main.js#L82-L97)

**What goes wrong:** In the connection settings, "Trigger Port (ToucanType listens here)" and "Status Listen Port (this computer)" are text boxes holding strings like "5051". A number field would give users a spinner limited to 1-65535 and store a real number. Today it works because the code converts the value with `Number(...)`, so users see no problem (except the empty-field case in [L2](#l2-an-empty-trigger-port-makes-every-trigger-button-fail-with-an-error)).

**Why it happens:** Both fields are `type: 'textinput'` with string defaults `'5050'` and `'5051'`, checked only by `Regex.PORT`.

**Fix:** Optionally switch both to number fields. This is the first release, so there is no saved config to migrate.

```js
{ type: 'number', id: 'listenPort', label: 'Status Listen Port (this computer)', width: 4, min: 1, max: 65535, default: 5051 }
```

### L7: The help page documents only one of the three feedbacks and misses three variables

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`companion/HELP.md:36-55`](https://github.com/bitfocus/companion-module-flamingosoftware-toucantype/blob/b593e268b0fa8a1963ac61e5075ec94cb066c919/companion/HELP.md#L36-L55)

**What goes wrong:** A user reading the module help sees only "Cue count comparison" under Feedbacks. It doesn't mention "ToucanType is working" or "Connection state", which the module's own presets use. The Variables table also leaves out `state` (What ToucanType is doing), `disguise` and `console`, even though the "EOS + Disguise connections" preset shows `$(ToucanType:disguise)` and `$(ToucanType:console)`.

**Why it happens:** [`src/feedbacks.js`](https://github.com/bitfocus/companion-module-flamingosoftware-toucantype/blob/b593e268b0fa8a1963ac61e5075ec94cb066c919/src/feedbacks.js) defines three feedbacks and [`src/variables.js`](https://github.com/bitfocus/companion-module-flamingosoftware-toucantype/blob/b593e268b0fa8a1963ac61e5075ec94cb066c919/src/variables.js) defines nine variables, but the help page lists one feedback and six variables.

**Fix:** Add the "ToucanType is working" and "Connection state" feedbacks (with their dropdown choices) and the `state`, `disguise` and `console` variables (values `OK` / `Offline`) to `companion/HELP.md`.

## 💡 Nice to Have

### N1: Make plus update comparison lights up before ToucanType has sent any counts

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.js:138-144`](https://github.com/bitfocus/companion-module-flamingosoftware-toucantype/blob/b593e268b0fa8a1963ac61e5075ec94cb066c919/src/feedbacks.js#L138-L144)

**What goes wrong:** Before ToucanType has sent any counts, a "Cue count comparison" feedback set to "Cues to make + update" "equal to" 0 (or "less than" 1) lights up as if there were no work outstanding. The single-counter choices correctly stay off until data arrives, as the code comment intends.

**Why it happens:** For "Cues to make + update" the code adds the two counts with `?? 0`, so the sum is never undefined and the "Nothing heard yet" guard never applies to it.

**Fix:** Return `false` when both `counts.cues_to_make` and `counts.cues_to_update` are still undefined, before adding them.

### N2: Manifest apiVersion is set by hand instead of the template's 0.0.0

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`companion/manifest.json:21`](https://github.com/bitfocus/companion-module-flamingosoftware-toucantype/blob/b593e268b0fa8a1963ac61e5075ec94cb066c919/companion/manifest.json#L21)

**What goes wrong:** Users see no effect. `runtime.apiVersion` is `"2.0.4"` where the template has `"0.0.0"`; `companion-module-build` writes the real value into the packaged manifest anyway, so this only matters for consistency with the template.

**Why it happens:** The value was filled in by hand. The v2.0.4 template's manifest leaves it at `"0.0.0"` for the build to fill in.

**Fix:** Set `"apiVersion": "0.0.0"` to match the template.
