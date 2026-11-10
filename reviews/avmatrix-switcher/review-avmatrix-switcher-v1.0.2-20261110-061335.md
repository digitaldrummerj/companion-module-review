# Review: avmatrix-switcher v1.0.2 (follow-up to the v1.0.1 review)

| Field | Value |
| --- | --- |
| **Module** | [`companion-module-avmatrix-switcher`](https://github.com/bitfocus/companion-module-avmatrix-switcher) |
| **Scope** | `tag` (follow-up: changes `v1.0.1..v1.0.2`, plus a re-check of every v1.0.1 finding) |
| **Version** | v1.0.2 ([`c8a0b8b`](https://github.com/bitfocus/companion-module-avmatrix-switcher/commit/c8a0b8b66f8ef2eeff78d76227766c14b62a9857)) |
| **Release** | New module — never published |
| **API** | 1 (base 1.14.1, yarn.lock) |
| **Template** | `companion-module-template-ts-v1` @ `42609d8` (2026-03-03, pinned) · `.yarnrc.yml` from `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Previous review** | [v1.0.1 (2026-11-06)](review-avmatrix-switcher-v1.0.1-20261106-181511.md), Changes Required; what happened to each of its findings is in [📝 Additional Notes](#-additional-notes) |
| **Reviewed** | 2026-11-09 |

## Verdict: ✅ Approved

## ❓ Assumptions

Some findings depend on assumptions the reviewers couldn't check. They're listed in [❓ Assumptions to Confirm](#-assumptions-to-confirm) at the end of this review.

## 📋 Issues

### Non-blocking

- [ ] [M1: A switcher picked from a manual scan, or swapped at the same IP, keeps the old model's protocol after a restart](#m1-a-switcher-picked-from-a-manual-scan-or-swapped-at-the-same-ip-keeps-the-old-models-protocol-after-a-restart)
- [ ] [L1: The Last Action (Flash) example key no longer matches, so a button built from it never flashes](#l1-the-last-action-flash-example-key-no-longer-matches-so-a-button-built-from-it-never-flashes)
- [ ] [L2: Every switcher report still writes an info line to the log](#l2-every-switcher-report-still-writes-an-info-line-to-the-log)
- [ ] [L3: Source options of the PIP, LUMA, CHROMA and DSK actions still store raw input numbers](#l3-source-options-of-the-pip-luma-chroma-and-dsk-actions-still-store-raw-input-numbers)
- [ ] [L4: The new Device Model setting uses the deprecated isVisible function](#l4-the-new-device-model-setting-uses-the-deprecated-isvisible-function)
- [ ] [N1: The help page's Usage and Troubleshooting steps don't mention Manual Device Model](#n1-the-help-pages-usage-and-troubleshooting-steps-dont-mention-manual-device-model)
- [ ] [N2: Two descriptions still show internal protocol codes](#n2-two-descriptions-still-show-internal-protocol-codes)
- [ ] [N3: Unused reply-callback code is left in the connection class](#n3-unused-reply-callback-code-is-left-in-the-connection-class)
- [ ] [NR1: Plan the move to @companion-module/base v2.x](#nr1-plan-the-move-to-companion-modulebase-v2x)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟡 Medium

### M1: A switcher picked from a manual scan, or swapped at the same IP, keeps the old model's protocol after a restart

- **Source:** 🔎 QA reviewer
- **Classification:** 🔙 REGRESSION
- **File:** [`src/main.ts:158`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/c8a0b8b66f8ef2eeff78d76227766c14b62a9857/src/main.ts#L158), [`src/main.ts:121-126`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/c8a0b8b66f8ef2eeff78d76227766c14b62a9857/src/main.ts#L121-L126), [`src/main.ts:535-542`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/c8a0b8b66f8ef2eeff78d76227766c14b62a9857/src/main.ts#L535-L542), [`src/main.ts:581-585`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/c8a0b8b66f8ef2eeff78d76227766c14b62a9857/src/main.ts#L581-L585)

**What goes wrong:** A SHARK H4K gets a new DHCP address (.10 → .20). The user runs **Scan Network for Devices**, picks `SHARK H4K (192.168.1.20)` from the Device dropdown and saves. It works until Companion restarts: then .20 isn't in the saved device list, so the connection falls back to the default SHARK S6 PLUS profile, and every button sends S6 PLUS packets, which the module's own changelog says fail silently on an H4K. The same happens when a switcher is replaced by another model at the same IP: the saved entry keeps the old model, and a manual scan doesn't correct it. The only ways out are **Manual Device Model** or re-adding the connection.

**Why it happens:** v1.0.2 runs the start-up scan only on the very first init or when no device list is saved (in v1.0.1 it ran every time). The **Scan Network for Devices** action only updates the in-memory list: it never saves `config.devices` and never re-applies the current device's profile; only the start-up scan does that. On the next start, `init()` rebuilds the list from `config.devices`, and `setupConnection()` uses the default profile when the Target IP isn't in it.

**Fix:** make the manual scan use the same refresh path as the start-up scan: save the merged device list with `saveConfig`, and when the current Target IP is in the results, call `applyDeviceProfile(...)` and `comm.setTargetDevice(...)`. Match the target on `config.host` too, so a typed IP is refreshed.

## 🟢 Low

### L1: The Last Action (Flash) example key no longer matches, so a button built from it never flashes

- **Source:** 🔎 QA reviewer, compliance reviewer
- **Classification:** 🔙 REGRESSION (the M2 fix changed the stored values; the label wasn't updated)
- **File:** [`src/feedbacks.ts:288`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/c8a0b8b66f8ef2eeff78d76227766c14b62a9857/src/feedbacks.ts#L288)

**What goes wrong:** A user builds a button with **Source (PGM / PVW)** = PGM5, adds the **Last Action (Flash)** feedback and types `set_source|source=5`, as the option label suggests. The button never flashes orange. The bundled presets are unaffected because they build their keys in code.

**Why it happens:** Since v1.0.2 the source dropdown stores ids like `pgm5` instead of numbers, so the real key is `set_source|source=pgm5` ([`src/commandHandler.ts:265-271`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/c8a0b8b66f8ef2eeff78d76227766c14b62a9857/src/commandHandler.ts#L265-L271)). The comment at line 279 still describes older key formats as well.

**Fix:** change the label example to `set_source|source=pgm5` (the `key:19` / `key:20` / `key:33` examples are still right) and update the comment to the `actionId|option=value` format.

### L2: Every switcher report still writes an info line to the log

- **Source:** 🔎 protocol reviewer, QA reviewer
- **Classification:** v1.0.1 L6, partly fixed
- **File:** [`src/main.ts:1014-1017`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/c8a0b8b66f8ef2eeff78d76227766c14b62a9857/src/main.ts#L1014-L1017)

**What goes wrong:** On a SHARK H4K, about 8–10 info lines like `[Report] luma (0x0131, GET) Status=1 …` appear every time the connection comes online, and one LUMA/CHROMA Adjust press adds more. Real warnings are harder to find in the connection log. The v1.0.2 changelog says `[Report]` moved to debug.

**Why it happens:** The other hot-path lines (`[Report 0x0110]`, `[Switch]`, `[Set]`, `[Query Reply]`, "Unhandled cmd") were moved to debug, and the H4K double handling is fixed, but the per-report line in `applyGetReport()` still logs at `info`.

**Fix:** change `this.log('info', …)` at line 1017 to `this.log('debug', …)`.

### L3: Source options of the PIP, LUMA, CHROMA and DSK actions still store raw input numbers

- **Source:** 🔎 QA reviewer
- **Classification:** v1.0.1 M2, partly fixed
- **File:** [`src/actions.ts:243-272`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/c8a0b8b66f8ef2eeff78d76227766c14b62a9857/src/actions.ts#L243-L272), [`src/actions.ts:419-431`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/c8a0b8b66f8ef2eeff78d76227766c14b62a9857/src/actions.ts#L419-L431), [`src/actions.ts:608-637`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/c8a0b8b66f8ef2eeff78d76227766c14b62a9857/src/actions.ts#L608-L637)

**What goes wrong:** The source, transition and key-module dropdowns now store device-independent ids, so most buttons survive a model change. The PIP Adjust "Source", LUMA/DSK "Fill Source" and LUMA/CHROMA/DSK "Key Source" options still store the protocol's raw number (IN1 is 1 on an S6 PLUS and 0 on an H4K). After an S6 PLUS is replaced by an H4K, a saved "LUMA Key Source = IN1" button selects IN2.

**Why it happens:** These options send `Number(event.options.value)` straight to the device, so the stored value only means the same input on the protocol it was saved under.

**Fix:** store ids like `in1` for these options too and translate them with the active profile when sending, as the source actions now do. Doing it before the first publish avoids an upgrade script later.

### L4: The new Device Model setting uses the deprecated isVisible function

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/config.ts:110`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/c8a0b8b66f8ef2eeff78d76227766c14b62a9857/src/config.ts#L110)

**What goes wrong:** Nothing visible today: turning on **Manual Device Model** shows the **Device Model** dropdown. But base 1.14.1 marks `isVisible` "deprecated … will be removed in 2.0.0 of this api", so the planned move to v2 (NR1) has one more thing to change.

**Why it happens:** The new field uses `isVisible: (options) => !!options.manualModel`.

**Fix:** use `isVisibleExpression: '$(options:manualModel)'` instead.

## 💡 Nice to Have

### N1: The help page's Usage and Troubleshooting steps don't mention Manual Device Model

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`companion/HELP.md:36`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/c8a0b8b66f8ef2eeff78d76227766c14b62a9857/companion/HELP.md#L36), [`companion/HELP.md:43`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/c8a0b8b66f8ef2eeff78d76227766c14b62a9857/companion/HELP.md#L43)

**What goes wrong:** An H4K owner on another subnet sees an empty Device list, follows Troubleshooting ("Enter the IP manually instead") and leaves **Manual Device Model** off. The module then uses the default S6 PLUS protocol. The Configuration section explains the setting, but the two step-by-step places don't.

**Fix:** add "and turn on **Manual Device Model**, then pick the model" to Usage step 1 and to the "Device list is empty" line.

### N2: Two descriptions still show internal protocol codes

- **Source:** 🔎 compliance reviewer
- **Classification:** v1.0.1 N3, partly fixed
- **File:** [`src/feedbacks.ts:256`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/c8a0b8b66f8ef2eeff78d76227766c14b62a9857/src/feedbacks.ts#L256), [`src/actions.ts:515`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/c8a0b8b66f8ef2eeff78d76227766c14b62a9857/src/actions.ts#L515)

**What goes wrong:** The feedback dropdowns now follow the active protocol, but the **Key Module Selected** description says "read back from 0x0130" and the **CHROMA Adjust** description shows "(0617: Similarity/Smooth/Spill/Opacity)".

**Fix:** use plain wording, e.g. "Active key module (H4K only)" and "(SHARK S6 PLUS / S5 / H5: Similarity/…)".

### N3: Unused reply-callback code is left in the connection class

- **Source:** 🔎 protocol reviewer, QA reviewer
- **Classification:** v1.0.1 N4, partly fixed
- **File:** [`src/communication.ts:240-244`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/c8a0b8b66f8ef2eeff78d76227766c14b62a9857/src/communication.ts#L240-L244), [`src/communication.ts:880-885`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/c8a0b8b66f8ef2eeff78d76227766c14b62a9857/src/communication.ts#L880-L885)

**What goes wrong:** Nothing visible. Removing `sendCommandWithCallback()` left the `callbacks` array, the `DeviceCallback` type and the lookup on every received packet with nothing that adds to them, and the `timeout` option is declared and defaulted but never read.

**Fix:** delete the `callbacks` field, its lookup, `DeviceCallback` and the `timeout` option.

## 🔮 Next Release

### NR1: Plan the move to @companion-module/base v2.x

- **Source:** 🔎 compliance reviewer
- **Classification:** v1.0.1 NR1, still open (planned)
- **File:** [`package.json:26`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/c8a0b8b66f8ef2eeff78d76227766c14b62a9857/package.json#L26)

**What goes wrong:** Nothing today. The module is on base `~1.14.1`; the changelog already plans the move to v2, and the `isVisible` in L4 is one more item for it.

**Fix:** move to the API 2.x template in a later release.

## 📝 Additional Notes

- What happened to the findings of the [v1.0.1 review](review-avmatrix-switcher-v1.0.1-20261106-181511.md) (IDs below are that review's):

| v1.0.1 finding | Status in v1.0.2 |
| --- | --- |
| H1 Chinese text | Fixed: no non-English text left; `.idea/` and `md/` removed |
| H2 buttons fail after 65,535 commands | Fixed: the packet index wraps to 1–65535 and the session counter wraps too |
| M1 heartbeat not restarted after a dropout | Fixed: `markDeviceAlive()` restarts the heartbeat |
| M2 buttons press different keys after a profile change | Partly: source, transition, stream and key-module options are now device-independent; some source options aren't ([L3](#l3-source-options-of-the-pip-luma-chroma-and-dsk-actions-still-store-raw-input-numbers)) |
| L1 scan sockets keep broadcasting after disable | Fixed: `destroy()` aborts the scan, clears its timers and closes its sockets |
| L2 follow-up timers run after disable | Fixed: all one-shot timers go through `schedule()` and are cleared in `destroy()` |
| L3 H4K PIP/LUMA presets send wrong values | Fixed |
| L4 identical Device dropdown entries | Fixed: entries include the IP |
| L5 help page missing models | Fixed: all six models listed, plus an H4K differences section |
| L6 log flood and double H4K handling | Partly: double handling fixed, one info line left ([L2](#l2-every-switcher-report-still-writes-an-info-line-to-the-log)) |
| L7 Last Action (Flash) lights the wrong button | Fixed: each action keeps its own flash key |
| N1 action ids and names | Fixed |
| N2 flash key doesn't resolve variables | Fixed |
| N3 S6 PLUS ranges and raw codes on an H4K | Partly: two descriptions left ([N2](#n2-two-descriptions-still-show-internal-protocol-codes)) |
| N4 leftover code | Partly: the reply-callback plumbing is now unused ([N3](#n3-unused-reply-callback-code-is-left-in-the-connection-class)) |
| NR1 move to base v2 | Still planned ([NR1](#nr1-plan-the-move-to-companion-modulebase-v2x)) |

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Companion passes `isFirstInit = true` only when a connection is first added or imported, not on every enable or restart | base 1.14.1 `dist/module-api/base.js:98-117` only uses it to create the default config; when the host sets it was not checked | [M1](#m1-a-switcher-picked-from-a-manual-scan-or-swapped-at-the-same-ip-keeps-the-old-models-protocol-after-a-restart) |
| A2 | Companion keeps config keys that have no field in the config UI (such as `devices`) when the user saves the connection's settings | how the module relies on `config.devices`; Companion's config editor was not checked | [M1](#m1-a-switcher-picked-from-a-manual-scan-or-swapped-at-the-same-ip-keeps-the-old-models-protocol-after-a-restart) |
