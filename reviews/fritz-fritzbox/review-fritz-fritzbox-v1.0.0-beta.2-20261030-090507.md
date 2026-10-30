# Review: companion-module-fritz-fritzbox v1.0.0-beta.2

| Field | Value |
| --- | --- |
| **Module** | `companion-module-fritz-fritzbox` |
| **Scope** | `tag` |
| **Version** | `v1.0.0-beta.2` |
| **Release** | New module — never published |
| **API** | 2.0 (base 2.0.4, yarn.lock) — requires Companion 4.3+ |
| **Template** | `companion-module-template-ts-v2.0.4` @ `d62230e` (2026-08-28, pinned) · `.yarnrc.yml` from `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Commit** | [`12f7570`](https://github.com/bitfocus/companion-module-fritz-fritzbox/tree/12f75702495c9331fb3232fc070b6f7f66d05a51) |
| **Review date** | 2026-10-30 |
| **Diff** | First release: there is no previous tag, so the whole module was reviewed (no diff) |

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | A DSL (PPP) FRITZ!Box also lists `WANIPConnection1` next to `WANPPPConnection1`, and that service answers its status query without an error but does not report "Connected" while PPP carries the internet. Only then does the module settle on the wrong service | The module's own test fake box (`tests/fakebox.mjs:25-26`) lists both services, and `diagnostics.ts` queries both. Not confirmed on real hardware. The regex bug itself was confirmed by running it in node | [M1](#m1-internet-status-and-reconnect-can-follow-the-wrong-wan-connection-on-dsl-boxes) |
| A2 | When the user saves the connection settings, Companion calls `configUpdated()` on the running module instead of restarting its process, so in-memory fields such as the smart home fingerprint survive the save | The standard Companion v2 lifecycle; not reproduced against a running Companion | [M2](#m2-smart-home-name-variables-stop-updating-after-the-connection-settings-are-saved) |
| A3 | In API 2.0, a dropdown field with `allowCustom` and without `disableAutoExpression` can be switched to expression mode, and Companion passes the evaluated value to the callback without converting it to a string | Companion 4.x expression-option behaviour; not checked in the base package source | [L3](#l3-device-and-unit-lookups-fail-when-an-expression-returns-a-number) |
| A4 | Companion catches an exception thrown in an action or feedback callback and logs it, rather than crashing the module process | General `@companion-module/base` behaviour; the module's own callbacks do not catch it | [L3](#l3-device-and-unit-lookups-fail-when-an-expression-returns-a-number) |

## 📋 Issues

### Blocking

- [ ] [H1: The CI workflow differs from the template](#h1-the-ci-workflow-differs-from-the-template)

### Non-blocking

- [ ] [M1: Internet status and reconnect can follow the wrong WAN connection on DSL boxes](#m1-internet-status-and-reconnect-can-follow-the-wrong-wan-connection-on-dsl-boxes)
- [ ] [M2: Smart home name variables stop updating after the connection settings are saved](#m2-smart-home-name-variables-stop-updating-after-the-connection-settings-are-saved)
- [ ] [M3: Network device actions skip an IP address, name or expression in the Device field](#m3-network-device-actions-skip-an-ip-address-name-or-expression-in-the-device-field)
- [ ] [L1: Button pressed recently feedback stays on longer than the configured seconds](#l1-button-pressed-recently-feedback-stays-on-longer-than-the-configured-seconds)
- [ ] [L2: A user without the Smart Home right makes the whole connection show Authentication failure](#l2-a-user-without-the-smart-home-right-makes-the-whole-connection-show-authentication-failure)
- [ ] [L3: Device and unit lookups fail when an expression returns a number](#l3-device-and-unit-lookups-fail-when-an-expression-returns-a-number)
- [ ] [N1: One malformed character code in a device name stops the whole host list from updating](#n1-one-malformed-character-code-in-a-device-name-stops-the-whole-host-list-from-updating)
- [ ] [N2: An empty smart home overview reply shows a cryptic error](#n2-an-empty-smart-home-overview-reply-shows-a-cryptic-error)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟠 High

### H1: The CI workflow differs from the template

- **Source:** 🤖 validate-template (CONFIG-DIFF). The validator reports this as Medium; the review rule makes any `.github` file the module has that differs from the template High.
- **Classification:** 🆕 NEW
- **File:** [`.github/workflows/node.yaml:19-20`](https://github.com/bitfocus/companion-module-fritz-fritzbox/blob/12f75702495c9331fb3232fc070b6f7f66d05a51/.github/workflows/node.yaml#L19-L20), [`.github/workflows/node.yaml:54-82`](https://github.com/bitfocus/companion-module-fritz-fritzbox/blob/12f75702495c9331fb3232fc070b6f7f66d05a51/.github/workflows/node.yaml#L54-L82)

**What goes wrong:** The GitHub Actions workflow that checks every push is not the one the API 2.0 template ships. When Bitfocus updates the template's CI, or someone troubleshoots a failing build, the module's workflow behaves differently from every other module on the same API level.

**Why it happens:** The module changed the template's `node.yaml` in two places. The lint job's checkout step gained a `with: persist-credentials: false` block. The template's `test` job, which the template ships commented out, was turned on and extended: its checkout also gained `persist-credentials: false`, and an extra `Build` step (`yarn build`) was added that the template's commented job does not have.

**Evidence:**

The validator reports: "Differs from template (line 19: found '        with:', template '      - name: Use Node.js 22.x')".

```yaml
# .github/workflows/node.yaml:18-20 (module)
      - uses: actions/checkout@v7
        with:
          persist-credentials: false
# companion-module-template-ts-v2.0.4/.github/workflows/node.yaml:18-19 (template)
      - uses: actions/checkout@v7
      - name: Use Node.js 22.x
```

```yaml
# .github/workflows/node.yaml:61-62 and 73-77 (module, test job; commented out in the template at node.yaml:52-74)
        with:
          persist-credentials: false
      - name: Build
        run: |
          yarn build
        env:
          CI: true
```

**Confirm by:** `diff companion-module-template-ts-v2.0.4/.github/workflows/node.yaml .github/workflows/node.yaml` shows no output, except the template's own `test` block uncommented verbatim. Module file: [`.github/workflows/node.yaml`](https://github.com/bitfocus/companion-module-fritz-fritzbox/blob/12f75702495c9331fb3232fc070b6f7f66d05a51/.github/workflows/node.yaml).

**Fix:** Copy `.github/workflows/node.yaml` from the API 2.0 template (`companion-module-template-ts` @ `d62230e`). If you want unit tests in CI, uncomment the template's own `test` job exactly as written, with no extra steps or checkout options.

## 🟡 Medium

### M1: Internet status and reconnect can follow the wrong WAN connection on DSL boxes

- **Source:** 🔎 protocol reviewer, QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/router.ts:641-671`](https://github.com/bitfocus/companion-module-fritz-fritzbox/blob/12f75702495c9331fb3232fc070b6f7f66d05a51/src/router.ts#L641-L671)

**What goes wrong:** A DSL FRITZ!Box and Companion are powered on together at a venue, or the user runs the "Restart of the FRITZ!Box" action. The box's TR-064 interface answers before DSL has synced, so the module picks the wrong internet service (`WANIPConnection1` instead of the PPP one) and keeps it. When the line comes up, the "Internet connected" feedback stays off, `connection_wan1_status` / `connection_wan1_connected` and the uptime and external IP variables read the wrong service, and the "Internet: reconnect now" button sends its reconnect to the wrong service. A box reboot doesn't fix it; only re-saving the connection settings does. When the internet is already up at first contact, the module happens to pick the right service, which is why this rarely shows.

**Why it happens:** The module asks the box which connection carries the internet, and the box answers with a string like `1.WANPPPConnection.1`. The pattern used to read that answer has `(d+)` (one or more letters "d") where `(\d+)` (digits) was meant, so it never matches; running it in node returns `null`. The module then falls back to guessing: it tries `WANPPPConnection1` and then `WANIPConnection1`, stops early only on one that already reports "Connected", and otherwise keeps the last one that answered. The result is cached and never checked again.

**Evidence:**

```ts
// src/router.ts:648
			const match = /(WAN(?:PPP|IP)Connection).(d+)/.exec(result.NewDefaultConnectionService ?? '')
// src/router.ts:656-669
		if (!state.connectionService) {
			for (const candidate of ['WANPPPConnection1', 'WANIPConnection1']) {
				...
					state.connectionService = candidate
					if (status.NewConnectionStatus === 'Connected') break
				...
		this.#connectionServiceChecked = true
```

**Confirm by:** open [`src/router.ts:648`](https://github.com/bitfocus/companion-module-fritz-fritzbox/blob/12f75702495c9331fb3232fc070b6f7f66d05a51/src/router.ts#L648). `node -e "console.log(/(WAN(?:PPP|IP)Connection).(d+)/.exec('1.WANPPPConnection.1'))"` prints `null`.

**Fix:** Match digits and a literal dot. Also, when the fallback finds no connected service, leave the check open so the next poll asks again. Add a fake-box test where the default service is `WANIPConnection.1` while PPP is listed but not connected (the current fake box answers `1.WANPPPConnection.1`, which agrees with the first fallback candidate and hides the bug).

```ts
const match = /(WAN(?:PPP|IP)Connection)\.(\d+)/.exec(result.NewDefaultConnectionService ?? '')
```

### M2: Smart home name variables stop updating after the connection settings are saved

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:405-419`](https://github.com/bitfocus/companion-module-fritz-fritzbox/blob/12f75702495c9331fb3232fc070b6f7f66d05a51/src/main.ts#L405-L419), [`src/main.ts:639-645`](https://github.com/bitfocus/companion-module-fritz-fritzbox/blob/12f75702495c9331fb3232fc070b6f7f66d05a51/src/main.ts#L639-L645)

**What goes wrong:** A button shows `$(fritz:smarthome_kitchen_power)`, the variable named after the device, with the live wattage. The user opens the connection settings, changes anything (say "Router status interval (s)" from 15 to 10) and saves. From then on the button keeps showing the last reading from before the save, for example `42.5`, even when the socket draws 0 W. The same value under the device's UID (`$(fritz:smarthome_<uid>_power)`) and the feedbacks keep updating. The name variables only come back when a device on the box is added or renamed, or the connection is disabled and re-enabled.

**Why it happens:** Saving the settings resets the smart home state, including the table that maps device names to variable names, but not the "fingerprint" of the last device list the module saw. On the first poll afterwards the box's device list is unchanged, so the fingerprint matches and the module skips rebuilding the name table. With an empty table, the name variables are never written again, while their definitions stay in place, frozen at the old value.

**Evidence:**

```ts
// src/main.ts:418-419
		this.router = createRouterState()
		this.smartHome = createSmartHomeState()
// src/main.ts:639-645
			const fingerprint = overviewFingerprint(overview)
			if (fingerprint !== this.#smartHomeFingerprint) {
				this.#smartHomeFingerprint = fingerprint
				this.smartHome.namePrefixes = assignNamePrefixes(overview.units)
				this.#rebuildDefinitions()
			}
			this.setVariableValues(smartHomeVariableValues(this.smartHome))
```

**Fix:** Reset the smart home fingerprint (and the definitions fingerprint) in `#applyConfig()` together with the state, so the first poll after a settings change rebuilds the name table and definitions.

```ts
this.#smartHomeFingerprint = ''
this.#definitionsFingerprint = ''
```

### M3: Network device actions skip an IP address, name or expression in the Device field

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:122-129`](https://github.com/bitfocus/companion-module-fritz-fritzbox/blob/12f75702495c9331fb3232fc070b6f7f66d05a51/src/actions.ts#L122-L129)

**What goes wrong:** A user switches the "Device" option of "Network device: block or allow internet" (or "Network device: wake up (Wake on LAN)") to expression mode and enters `$(custom:show_pc)`, which holds `192.168.178.20` or `SHOW-PC`. Companion rejects the value with "Value is not in the list of choices" and skips the action, so the device's internet is never blocked. The matching feedbacks ("Network device online", "Network device: internet blocked") accept the same input, so it works on the feedback but not on the action.

**Why it happens:** Under API 2.0, Companion checks a dropdown value against its list of choices unless the field sets `allowCustom: true`. The actions' shared Device field lists only the known devices' MAC addresses and doesn't set `allowCustom`, even though the action code (`findHost`) would happily accept an IP address or a name. The feedbacks' device fields ([`src/feedbacks.ts:182-190`](https://github.com/bitfocus/companion-module-fritz-fritzbox/blob/12f75702495c9331fb3232fc070b6f7f66d05a51/src/feedbacks.ts#L182-L190)) do set it.

**Fix:** Add `allowCustom: true` to the actions' Device field, with the same tooltip the feedbacks use ("Pick a device, or type a MAC address, IP address or the name shown on the box").

## 🟢 Low

### L1: Button pressed recently feedback stays on longer than the configured seconds

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.ts:359-375`](https://github.com/bitfocus/companion-module-fritz-fritzbox/blob/12f75702495c9331fb3232fc070b6f7f66d05a51/src/feedbacks.ts#L359-L375)

**What goes wrong:** A user sets "Stay active for (s)" on "Smart home: button pressed recently" to 10. The button lights when a FRITZ!DECT button press is read, but doesn't go dark after 10 s: it stays lit until the next smart home read, which is 60 s with the default "Smart home interval (s)" and up to 300 s at the maximum. The description warns that a press can show up late, but not that the feedback turns off late.

**Why it happens:** The feedback compares the current time with the press time, but Companion only re-checks it after each smart home poll ([`src/main.ts:646-657`](https://github.com/bitfocus/companion-module-fritz-fritzbox/blob/12f75702495c9331fb3232fc070b6f7f66d05a51/src/main.ts#L646-L657)). Nothing re-checks it when the window runs out.

**Fix:** After a poll that finds a recent press, start one `setTimeout` for when the earliest active window ends and call `checkFeedbacks('sh_button_pressed')` from it; clear that timer in `#stop()`. Or say in the option tooltip that the feedback turns off at the next smart home read.

### L2: A user without the Smart Home right makes the whole connection show Authentication failure

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:698-703`](https://github.com/bitfocus/companion-module-fritz-fritzbox/blob/12f75702495c9331fb3232fc070b6f7f66d05a51/src/main.ts#L698-L703), [`src/main.ts:782-788`](https://github.com/bitfocus/companion-module-fritz-fritzbox/blob/12f75702495c9331fb3232fc070b6f7f66d05a51/src/main.ts#L782-L788)

**What goes wrong:** A user creates a FRITZ!Box user with only "FRITZ!Box Settings", because they want router status, WLAN and host actions only. Smart home reading is on by default ("Smart home interval (s)" = 60), so the connection shows a red "Authentication failure" on the Connections page, even though all router variables and feedbacks update correctly. The user may think the password is wrong. The real fix (set the smart home interval to 0) isn't mentioned.

**Why it happens:** The connection status shows the worse of the router part and the smart home part. A missing Smart Home right is reported as `AuthenticationFailure`, which outranks the router's `Ok`.

**Fix:** Report a missing Smart Home right as `UnknownWarning` with a message such as 'The user lacks the "Smart Home" right; set Smart home interval to 0 if not needed'. Keep `AuthenticationFailure` for a login the box actually refused.

### L3: Device and unit lookups fail when an expression returns a number

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/shstate.ts:102-109`](https://github.com/bitfocus/companion-module-fritz-fritzbox/blob/12f75702495c9331fb3232fc070b6f7f66d05a51/src/shstate.ts#L102-L109), [`src/router.ts:281-290`](https://github.com/bitfocus/companion-module-fritz-fritzbox/blob/12f75702495c9331fb3232fc070b6f7f66d05a51/src/router.ts#L281-L290)

**What goes wrong:** The smart home device and network device fields accept custom values and can be switched to an expression. If the expression evaluates to a number (for example a variable holding `1234`), the action does nothing and Companion logs a TypeError, instead of the module's own "unknown smart home device" warning. A feedback using that field errors on every check.

**Why it happens:** The lookups call `.trim()` on the value, which only exists on strings. The options are typed as strings in the module, but nothing at runtime makes sure the value is one.

**Fix:** Turn the value into a string before trimming, e.g. `const wanted = String(uid ?? '').trim()` in `findUnit` and `const wanted = String(query ?? '').trim()` in `findHost`.

## 💡 Nice to Have

### N1: One malformed character code in a device name stops the whole host list from updating

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/http.ts:131-140`](https://github.com/bitfocus/companion-module-fritz-fritzbox/blob/12f75702495c9331fb3232fc070b6f7f66d05a51/src/http.ts#L131-L140)

**What goes wrong:** If one device name in the box's host list contains an out-of-range character code such as `&#99999999;`, every host-list read fails. The "Network device online" and "internet blocked" feedbacks and the `lan_hosts_*` variables stop updating, and the log only shows a debug line.

**Why it happens:** `String.fromCodePoint` throws for codes above `0x10FFFF`, and that error fails the whole host-list read instead of just the one name.

**Fix:** Leave out-of-range codes as they are: `(_, c) => { const n = Number(c); return n <= 0x10ffff ? String.fromCodePoint(n) : _ }`, and the same for the hex branch.

### N2: An empty smart home overview reply shows a cryptic error

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/smarthome.ts:222-231`](https://github.com/bitfocus/companion-module-fritz-fritzbox/blob/12f75702495c9331fb3232fc070b6f7f66d05a51/src/smarthome.ts#L222-L231), [`src/smarthome.ts:269`](https://github.com/bitfocus/companion-module-fritz-fritzbox/blob/12f75702495c9331fb3232fc070b6f7f66d05a51/src/smarthome.ts#L269)

**What goes wrong:** If the box ever answers the smart home overview request with an empty body, the status reads "Cannot read properties of undefined (reading 'devices')" instead of a clear message.

**Why it happens:** The JSON helper returns `undefined` for an empty body, and the overview code reads `.devices` from it without checking.

**Fix:** Fall back to an empty object, `(await this.#json<Partial<ShOverview>>('GET', '/overview')) ?? {}`, or throw a `SmartHomeError` with a clear message when the body is empty.

## 📝 Additional Notes

- First release: the module has never been published and there is no previous tag, so this review covers the whole module rather than a diff. Every finding is classified 🆕 NEW.
