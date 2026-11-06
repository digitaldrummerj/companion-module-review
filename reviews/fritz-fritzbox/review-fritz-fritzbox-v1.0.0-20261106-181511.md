# Review: companion-module-fritz-fritzbox v1.0.0 (follow-up to the v1.0.0-beta.2 review)

| Field | Value |
| --- | --- |
| **Module** | `companion-module-fritz-fritzbox` |
| **Scope** | `tag` |
| **Version** | `v1.0.0` |
| **Release** | New module — never published |
| **API** | 2.0 (base 2.0.4, yarn.lock) — requires Companion 4.3+ |
| **Template** | `companion-module-template-ts-v2.0.4` @ `d62230e` (2026-08-28, pinned) · `.yarnrc.yml` from `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Commit** | [`b32c21d`](https://github.com/bitfocus/companion-module-fritz-fritzbox/tree/b32c21d9304a0059d13dccf6aac5ead2b6d74d82) |
| **Review date** | 2026-11-06 |
| **Diff** | First release: no version has been published, so there is no published diff and the whole module was reviewed |
| **Prior review** | [v1.0.0-beta.2 (2026-10-30)](review-fritz-fritzbox-v1.0.0-beta.2-20261030-090507.md). All of its findings are fixed (see [📝 Additional Notes](#-additional-notes)) |

## Verdict: ✅ Approved

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | A FRITZ!Box keeps a web session that was never logged out open until its idle timeout (about 20 minutes), and allows only a limited number of sessions at once. Only then do the leftover sessions crowd out other logins | The module's own comments ([`src/session.ts:95-97`](https://github.com/bitfocus/companion-module-fritz-fritzbox/blob/b32c21d9304a0059d13dccf6aac5ead2b6d74d82/src/session.ts#L95-L97), [`src/session.ts:135`](https://github.com/bitfocus/companion-module-fritz-fritzbox/blob/b32c21d9304a0059d13dccf6aac5ead2b6d74d82/src/session.ts#L135)). The leak itself was reproduced against the module's fake box, not on real hardware | [M1](#m1-a-fritzbox-user-without-the-smart-home-right-leaves-a-new-box-session-open-on-every-smart-home-read) |
| A2 | For a user without the "FRITZ!Box Settings" right, the box accepts the TR-064 login and refuses the link and connection status reads with UPnP error 606, instead of refusing the login itself (401) | The module's own mapping: `Tr064Fault.isMissingRight` is code 606 ([`src/tr064.ts:28-30`](https://github.com/bitfocus/companion-module-fritz-fritzbox/blob/b32c21d9304a0059d13dccf6aac5ead2b6d74d82/src/tr064.ts#L28-L30)), with the hint in [`src/main.ts:836-837`](https://github.com/bitfocus/companion-module-fritz-fritzbox/blob/b32c21d9304a0059d13dccf6aac5ead2b6d74d82/src/main.ts#L836-L837). Not confirmed on a real box | [L1](#l1-connection-shows-ok-with-empty-router-values-when-the-user-lacks-the-fritzbox-settings-right) |
| A3 | Companion's connection log hides `debug` lines by default, so a hint logged at debug level is effectively invisible to most users | General Companion log-view behaviour; the host source was not checked | [L1](#l1-connection-shows-ok-with-empty-router-values-when-the-user-lacks-the-fritzbox-settings-right) |
| A4 | FRITZ!Box models number their `WLANConfiguration` services differently, so a saved id such as `WLANConfiguration2` can point at a different radio on another model | The module's own comments ([`src/feedbacks.ts:79`](https://github.com/bitfocus/companion-module-fritz-fritzbox/blob/b32c21d9304a0059d13dccf6aac5ead2b6d74d82/src/feedbacks.ts#L79), [`src/variables.ts:164-168`](https://github.com/bitfocus/companion-module-fritz-fritzbox/blob/b32c21d9304a0059d13dccf6aac5ead2b6d74d82/src/variables.ts#L164-L168)). Not checked against several real boxes | [L4](#l4-wlan-options-store-the-boxs-instance-number-instead-of-the-band-so-expressions-and-box-swaps-miss-the-network) |
| A5 | The box rejects a template or routine name sent where its UID is expected (REST path `/overview/templates/<uid>`, AHA `ain=<uid>`), instead of resolving it | The module's client code sends the value as the UID. How the FRITZ! API treats a name in that place was not checked | [L5](#l5-typing-a-scenario-or-routine-name-into-its-field-does-nothing-although-the-field-accepts-typed-values) |
| A6 | When a module removes a variable definition, a button text that references the variable no longer shows a value | General Companion 4.x behaviour; the host source was not checked | [L6](#l6-mobile-enabled-and-wan-2-enabled-never-show-false-switching-the-mobile-connection-off-removes-the-variables-instead) |

## 📋 Issues

### Non-blocking

- [ ] [M1: A FRITZ!Box user without the Smart Home right leaves a new box session open on every smart home read](#m1-a-fritzbox-user-without-the-smart-home-right-leaves-a-new-box-session-open-on-every-smart-home-read)
- [ ] [L1: Connection shows OK with empty router values when the user lacks the FRITZ!Box Settings right](#l1-connection-shows-ok-with-empty-router-values-when-the-user-lacks-the-fritzbox-settings-right)
- [ ] [L2: Certificate checks are off for HTTPS over the internet (MyFRITZ!) too](#l2-certificate-checks-are-off-for-https-over-the-internet-myfritz-too)
- [ ] [L3: A variable typed into the new WLAN password or name is set on the box literally](#l3-a-variable-typed-into-the-new-wlan-password-or-name-is-set-on-the-box-literally)
- [ ] [L4: WLAN options store the box's instance number instead of the band, so expressions and box swaps miss the network](#l4-wlan-options-store-the-boxs-instance-number-instead-of-the-band-so-expressions-and-box-swaps-miss-the-network)
- [ ] [L5: Typing a scenario or routine name into its field does nothing, although the field accepts typed values](#l5-typing-a-scenario-or-routine-name-into-its-field-does-nothing-although-the-field-accepts-typed-values)
- [ ] [L6: Mobile enabled and WAN 2 enabled never show false; switching the mobile connection off removes the variables instead](#l6-mobile-enabled-and-wan-2-enabled-never-show-false-switching-the-mobile-connection-off-removes-the-variables-instead)
- [ ] [N1: The diagnostics report can show the previous box address after the address is changed](#n1-the-diagnostics-report-can-show-the-previous-box-address-after-the-address-is-changed)
- [ ] [N2: The first Connected to log line names the address instead of the box model](#n2-the-first-connected-to-log-line-names-the-address-instead-of-the-box-model)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟡 Medium

### M1: A FRITZ!Box user without the Smart Home right leaves a new box session open on every smart home read

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/smarthome.ts:253-261`](https://github.com/bitfocus/companion-module-fritz-fritzbox/blob/b32c21d9304a0059d13dccf6aac5ead2b6d74d82/src/smarthome.ts#L253-L261), [`src/session.ts:130-133`](https://github.com/bitfocus/companion-module-fritz-fritzbox/blob/b32c21d9304a0059d13dccf6aac5ead2b6d74d82/src/session.ts#L130-L133), [`src/aha.ts:521-529`](https://github.com/bitfocus/companion-module-fritz-fritzbox/blob/b32c21d9304a0059d13dccf6aac5ead2b6d74d82/src/aha.ts#L521-L529)

**What goes wrong:** A user wants router status only, so they create a FRITZ!Box user with just the "FRITZ!Box Settings" right. They leave "Smart home interval (s), 0 = off" at its default of 60. The connection correctly shows the yellow warning 'The FRITZ!Box user lacks the "Smart Home" right; set "Smart home interval" to 0 if smart home is not needed', the fix for the prior review's L2.

Behind that warning, every smart home read logs in to the box again: every 60 s, and again 1 s and 4 s after any smart home action. Each new login drops the previous session without logging it out, and disabling or deleting the connection logs out only the newest one. The QA reviewer reproduced this against the module's own fake box ([`tests/fakebox.mjs`](https://github.com/bitfocus/companion-module-fritz-fritzbox/blob/b32c21d9304a0059d13dccf6aac5ead2b6d74d82/tests/fakebox.mjs)) with the interval at 2 s:

- open sessions after 2, 4, 6, 8 and 10 s: 3, 4, 5, 6, 7
- login attempts: 3, 4, 5, 6, 7
- sessions still open after the connection was destroyed: 6

With the default 60 s that is about 20 open sessions after 20 minutes. The module's own comments say the box limits how many sessions can be open at once and holds each one for twenty minutes, so this works against the module's own one-session design. It can crowd out other logins to the box, such as the web interface or the FRITZ!App. Users whose FRITZ!Box user has the Smart Home right, and users who set the smart home interval to 0, are not affected.

**Why it happens:** When the box refuses a smart home request with HTTP 401 or 403, the module assumes the session id (SID) has expired. It forgets the SID, logs in again and retries once. For a user without the right, the box refuses a SID that is still valid, so the retry is refused too and the read fails. The next read finds the new SID refused again, and the cycle repeats. Forgetting a SID only clears it locally; the module never tells the box to close it. The older AHA-HTTP client has the same retry on 403, so boxes before FRITZ!OS 8.20 behave the same way.

**Evidence:**

```ts
// src/smarthome.ts:253-261
	async #json<T>(method: 'GET' | 'PUT' | 'POST', path: string, body?: unknown): Promise<T> {
		let sid = await this.#session.sid()
		let res = await this.#send(method, path, sid, body)

		if (res.status === 401 || res.status === 403) {
			this.#session.invalidate(sid)
			sid = await this.#session.sid()
			res = await this.#send(method, path, sid, body)
		}
// src/session.ts:130-133
	/** Drops a SID the box has refused, so the next request logs in again. */
	invalidate(rejected: string): void {
		if (this.#sid === rejected) this.#sid = NO_SID
	}
```

**Confirm by:** open [`src/smarthome.ts:257-261`](https://github.com/bitfocus/companion-module-fritz-fritzbox/blob/b32c21d9304a0059d13dccf6aac5ead2b6d74d82/src/smarthome.ts#L257-L261) and [`src/session.ts:131-133`](https://github.com/bitfocus/companion-module-fritz-fritzbox/blob/b32c21d9304a0059d13dccf6aac5ead2b6d74d82/src/session.ts#L131-L133): a refused SID is dropped locally and a new login follows, with no logout for the old SID. Or run the fake box with `smartHomeForbidden: true` and a 2 s smart home interval, and watch `box.state.sids.size` grow by one per read.

**Fix:** Don't throw away a session the box still accepts. Any one of these works:

- Before retrying, check the rights the login response already lists (`this.#session.rights`). If `HomeAuto` is missing, throw the permission error straight away, without calling `invalidate()`.
- Make `invalidate()` send a fire-and-forget `logout=1&sid=<rejected>`, so the box frees the slot. This is harmless if the SID had already expired.
- In `#smartHomeFailed`, treat a permission error like the "no smart home interface" case: stop the smart home interval until the settings change.

Apply the same change to the AHA client's `#command`.

## 🟢 Low

### L1: Connection shows OK with empty router values when the user lacks the FRITZ!Box Settings right

- **Source:** 🔎 protocol reviewer, QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:640-644`](https://github.com/bitfocus/companion-module-fritz-fritzbox/blob/b32c21d9304a0059d13dccf6aac5ead2b6d74d82/src/main.ts#L640-L644), [`src/main.ts:833-843`](https://github.com/bitfocus/companion-module-fritz-fritzbox/blob/b32c21d9304a0059d13dccf6aac5ead2b6d74d82/src/main.ts#L833-L843)

**What goes wrong:** A user creates a FRITZ!Box user with only the "Smart Home" right and enters it in the connection settings, expecting router status as well. The connection turns green and the log says "Connected to 192.168.178.1". But the "Internet connected" and "Internet line synchronised" feedbacks stay off, and `connection_wan1_status`, the throughput and the external IP variables stay empty. The only explanation, '(the user needs the "FRITZ!Box Settings" right)', goes to the debug log, which most users never see. Nothing on the Connections page says why the router values are missing.

This release fixed the opposite case (the prior review's L2): a user without the Smart Home right now gets a warning with a hint. The router side has no matching warning.

**Why it happens:** A router read only fails the connection when an essential area (the line, or the internet connection) fails with something other than a TR-064 fault. A UPnP 606 "missing right" answer is a TR-064 fault, so it doesn't count and the router part is set to OK. The module's own code knows what 606 means (`Tr064Fault.isMissingRight`), but it only logs that hint at debug level.

**Evidence:**

```ts
// src/main.ts:640-644
			const fatal = problems.find(
				(problem) =>
					problem.error instanceof Tr064AuthError ||
					(ESSENTIAL_AREAS.has(problem.area) && !(problem.error instanceof Tr064Fault)),
			)
// src/main.ts:836-841
				error instanceof Tr064Fault && error.isMissingRight
					? ' (the user needs the "FRITZ!Box Settings" right)'
					: error instanceof Tr064Fault && error.isUnknownAction
						? ' (not offered by this box)'
						: ''
			this.#logOnce(`area:${area}`, 'debug', `Router status, ${area}: ${describe(error)}${hint}`)
```

**Confirm by:** open [`src/main.ts:640-657`](https://github.com/bitfocus/companion-module-fritz-fritzbox/blob/b32c21d9304a0059d13dccf6aac5ead2b6d74d82/src/main.ts#L640-L657): a 606 fault on `link` is not fatal, so line 657 sets the router status to OK. Then [`src/main.ts:833-843`](https://github.com/bitfocus/companion-module-fritz-fritzbox/blob/b32c21d9304a0059d13dccf6aac5ead2b6d74d82/src/main.ts#L833-L843): the missing-right hint is logged at debug level only.

**Fix:** When `link` or `connection` fails with a missing-right fault, show a warning on the connection instead of OK, the same way [`src/main.ts:789-796`](https://github.com/bitfocus/companion-module-fritz-fritzbox/blob/b32c21d9304a0059d13dccf6aac5ead2b6d74d82/src/main.ts#L789-L796) handles the smart home right. Keep OK for areas a box simply doesn't offer (`isUnknownAction`). For example, in place of the plain `this.#setStatus('router', InstanceStatus.Ok)`:

```ts
const missingRight = problems.find(
	(problem) =>
		ESSENTIAL_AREAS.has(problem.area) && problem.error instanceof Tr064Fault && problem.error.isMissingRight,
)
if (missingRight) {
	const message = 'The FRITZ!Box user lacks the "FRITZ!Box Settings" right'
	this.#logProblem('router', 'permission', 'warn', message)
	this.#setStatus('router', InstanceStatus.UnknownWarning, message)
} else {
	this.#setStatus('router', InstanceStatus.Ok)
}
```

### L2: Certificate checks are off for HTTPS over the internet (MyFRITZ!) too

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/http.ts:92`](https://github.com/bitfocus/companion-module-fritz-fritzbox/blob/b32c21d9304a0059d13dccf6aac5ead2b6d74d82/src/http.ts#L92)

**What goes wrong:** Nothing visible in normal use. The connection settings tell users they can enter the box's internet address, e.g. `https://xxxxxxxxxxxx.myfritz.net:43167`. Every HTTPS request then accepts any certificate. On an untrusted network, such as venue or hotel Wi-Fi at an event, someone in the path can intercept the connection without the user getting a warning. They can read what the module receives (WLAN passwords, the host list, smart home data) and take over the session. Users who connect over plain HTTP on the home network (`192.168.178.1`, `fritz.box`) are not affected.

**Why it happens:** Every HTTPS request is sent with `rejectUnauthorized: false`, whatever the address. The comment above `httpCall()` explains why: the box serves HTTPS with a certificate it signed itself. That reasoning fits the home network, but the same setting also applies to addresses that the module's own `isHomeNetworkHost()` already recognises as internet addresses.

**Fix:** Keep accepting self-signed certificates on the home network (`address.homeNetwork`). For internet addresses, either check certificates by default and add a config checkbox such as "Accept a self-signed certificate", or remember the certificate fingerprint seen on first contact and refuse a changed one. Pass the choice through `WebEndpoint` / `Tr064Options` into `httpCall()`.

### L3: A variable typed into the new WLAN password or name is set on the box literally

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:594-600`](https://github.com/bitfocus/companion-module-fritz-fritzbox/blob/b32c21d9304a0059d13dccf6aac5ead2b6d74d82/src/actions.ts#L594-L600), [`src/actions.ts:644`](https://github.com/bitfocus/companion-module-fritz-fritzbox/blob/b32c21d9304a0059d13dccf6aac5ead2b6d74d82/src/actions.ts#L644)

**What goes wrong:** Before an event, a user sets "New name (up to 32 characters)" of "WLAN: change name (SSID)" to `$(custom:event_ssid)`, or "New password (8 to 63 characters)" of "WLAN: change password" to `$(custom:guest_pw)`, as most Companion text fields allow. The module receives the literal text. It passes the module's checks (printable ASCII, within length), so the guest WLAN is renamed to `$(custom:event_ssid)` or gets the password `$(custom:guest_pw)`, and guests can't find or join it. Users who switch the field to expression mode are not affected.

**Why it happens:** Both are text fields without `useVariables: true`. In base 2.0.4 that flag is what turns on variables in normal text ("Whether variables should be supported in the value mode text"); without it, only expression mode resolves them. The module already uses `useVariables: true` on other text fields ([`src/actions.ts:486`](https://github.com/bitfocus/companion-module-fritz-fritzbox/blob/b32c21d9304a0059d13dccf6aac5ead2b6d74d82/src/actions.ts#L486)).

**Fix:** Add `useVariables: true` to the `password` field and the `ssid` field. The existing `wlanPasswordProblem()` and `wlanSsidProblem()` checks then validate the resolved value.

### L4: WLAN options store the box's instance number instead of the band, so expressions and box swaps miss the network

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.ts:79-96`](https://github.com/bitfocus/companion-module-fritz-fritzbox/blob/b32c21d9304a0059d13dccf6aac5ead2b6d74d82/src/feedbacks.ts#L79-L96), [`src/actions.ts:112-115`](https://github.com/bitfocus/companion-module-fritz-fritzbox/blob/b32c21d9304a0059d13dccf6aac5ead2b6d74d82/src/actions.ts#L112-L115)

**What goes wrong:** A user switches the "WLAN" option of "WLAN: switch on, off or toggle" (or of the "WLAN enabled" feedback) to expression mode, to pick the band from a variable. The module's variables call the 5 GHz network `wlan_5ghz_...`, so the user writes `'5ghz'`. The option only matches the box's internal service id, here `WLANConfiguration2`, so the action logs `WLAN: "5ghz" is not known on this box` and does nothing, and the feedback stays off. Saved buttons hold the instance number too, and the module's own comments say these numbers differ between models: after the user swaps the FRITZ!Box for another model, a "WLAN 5 GHz" button may switch whichever radio has that number on the new box. Buttons using "Guest WLAN", "All WLAN" or "Any WLAN except guest" are not affected.

**Why it happens:** The WLAN dropdowns use each radio's service id (`WLANConfiguration1` to `WLANConfiguration4`) as the choice id, and the lookups match on it. The comment above `wlanChoices()` says the radios are keyed "by band, since instance numbers vary between models", but only the label is by band. The variables do use band keys, from `wlanKeys()` ([`src/variables.ts:169-183`](https://github.com/bitfocus/companion-module-fritz-fritzbox/blob/b32c21d9304a0059d13dccf6aac5ead2b6d74d82/src/variables.ts#L169-L183)). These dropdowns allow typed values and expression mode, which is where users meet the ids.

**Fix:** Use the band keys from `wlanKeys()` (`24ghz`, `5ghz`, `6ghz`, `5ghz_2`, ...) as the choice ids, next to `guest` / `all` / `any`. Resolve them in `findWlan()` and `wlanEnabled()` through the same `wlanKeys()` map, and keep accepting a raw service id as a fallback. The module has never been published, so no saved buttons exist yet and the change needs no upgrade script now; after 1.0.0 ships it would.

### L5: Typing a scenario or routine name into its field does nothing, although the field accepts typed values

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:402-458`](https://github.com/bitfocus/companion-module-fritz-fritzbox/blob/b32c21d9304a0059d13dccf6aac5ead2b6d74d82/src/actions.ts#L402-L458), [`src/feedbacks.ts:391-392`](https://github.com/bitfocus/companion-module-fritz-fritzbox/blob/b32c21d9304a0059d13dccf6aac5ead2b6d74d82/src/feedbacks.ts#L391-L392)

**What goes wrong:** The "Template or scenario" field of "Smart home: apply template or scenario", the "Routine" field of "Smart home: enable or disable a routine" and the "Smart home: routine enabled" feedback all accept typed values. A user types the name shown on the box, e.g. `Show start`, or uses an expression that returns it. Pressing the button sends `Show start` to the box as if it were the internal ID, so the log shows `Apply template Show start failed: ...`. The routine action with "Toggle" logs `Routine: the state of Show start is unknown`, and the feedback never lights. The "Smart home device" fields do accept a typed name (their tooltip says so), so users expect these fields to accept one too. Picking the template or routine from the list works.

**Why it happens:** Both actions pass the typed text straight to the box as the UID. The state lookups match only on the UID. The smart home device lookup (`findUnit()` in [`src/shstate.ts:102-110`](https://github.com/bitfocus/companion-module-fritz-fritzbox/blob/b32c21d9304a0059d13dccf6aac5ead2b6d74d82/src/shstate.ts#L102-L110)) falls back to a case-insensitive name match, but templates and routines have no such fallback.

**Fix:** Resolve templates and routines the way `findUnit()` resolves units: by UID first, then by case-insensitive name, and send the UID that was found. Use the same lookup in the "Smart home: routine enabled" feedback. If you keep UID-only matching, add a tooltip to these fields saying that only the box's UID works when typed.

### L6: Mobile enabled and WAN 2 enabled never show false; switching the mobile connection off removes the variables instead

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/router.ts:512-532`](https://github.com/bitfocus/companion-module-fritz-fritzbox/blob/b32c21d9304a0059d13dccf6aac5ead2b6d74d82/src/router.ts#L512-L532), [`src/router.ts:225-228`](https://github.com/bitfocus/companion-module-fritz-fritzbox/blob/b32c21d9304a0059d13dccf6aac5ead2b6d74d82/src/router.ts#L225-L228)

**What goes wrong:** Take a DSL or cable box with a mobile stick as backup. While the mobile connection is on, `$(fritz:connection_mobile_enabled)` and `$(fritz:connection_wan2_enabled)` read `true`. When the user switches the mobile connection off on the box, these variables never change to `false`. Instead the module removes the whole mobile and WAN 2 group (`connection_mobile_*`, `connection_wan2_*`) from its variables, so a button showing `$(fritz:connection_wan2_enabled)` loses its value. The two "enabled" variables can therefore only ever read `true`. Boxes without a mobile stick are not affected.

**Why it happens:** The detailed mobile read (GetInfoEx) only runs while the box reports the mobile connection as enabled; otherwise the module uses an empty answer. Since 1.0.0, the module counts a stick as present only when it reports a technology, cells or a signal, and all three come from that detailed read. So with the connection switched off, the stick never counts as present, the mobile state is cleared and the variable group goes away.

**Evidence:**

```ts
// src/router.ts:516-521
				const enabled = tr064Bool(info.NewEnable ?? info.NewEnabled)
				const ex: Record<string, string> = enabled
					? await this.#tr064
							.call('X_AVM-DE_WANMobileConnection1', 'GetInfoEx')
							.catch((): Record<string, string> => ({}))
					: {}
// src/router.ts:532
				state.mobile = hasMobileHardware(mobile) ? mobile : undefined
// src/router.ts:225-228
export function hasMobileHardware(mobile: MobileInfo): boolean {
	const technology = mobile.technology.trim().toLowerCase()
	return (technology !== '' && technology !== 'unknown') || mobile.cells > 0 || mobile.signalRsrp !== undefined
}
```

**Fix:** Keep the stick once it has been seen. When the box now reports the mobile connection as switched off and the previous read found the stick, keep the mobile state with `enabled: false` and an empty technology and uptime instead of clearing it, for example `if (!hasMobileHardware(mobile) && !enabled && state.mobile) state.mobile = { ...state.mobile, enabled, technology: '', uptime: undefined }`. Or drop the two `connection_*_enabled` variables, since they can only ever read `true`.

## 💡 Nice to Have

### N1: The diagnostics report can show the previous box address after the address is changed

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:116`](https://github.com/bitfocus/companion-module-fritz-fritzbox/blob/b32c21d9304a0059d13dccf6aac5ead2b6d74d82/src/main.ts#L116), [`src/main.ts:384-387`](https://github.com/bitfocus/companion-module-fritz-fritzbox/blob/b32c21d9304a0059d13dccf6aac5ead2b6d74d82/src/main.ts#L384-L387), [`src/main.ts:457-477`](https://github.com/bitfocus/companion-module-fritz-fritzbox/blob/b32c21d9304a0059d13dccf6aac5ead2b6d74d82/src/main.ts#L457-L477)

**What goes wrong:** A user first enters the MyFRITZ! address `https://abc123def456.myfritz.net:43167`, then changes "Address" to `192.168.178.1` and saves. A few minutes later they run "Diagnostics report: show the download address" and attach the report to a public GitHub issue, as HELP.md asks. The report's `recentRequests` still lists requests to `abc123def456.myfritz.net:43167/...` in plain text, although the report promises that addresses are replaced by placeholders.

**Why it happens:** The request log is created once per module process, and saving the settings doesn't clear it (it does clear the reported problems and the cached report). The report masks only the current address by name; it masks IP and MAC addresses by pattern, but not old host names.

**Fix:** Add a `clear()` method to `ExchangeLog` and call `this.#exchanges.clear()` in `#applyConfig()` next to `this.#diagnosticsReport = undefined`. Or remember the previous host names and pass them to the `Anonymizer` as extra `HOST` values.

### N2: The first Connected to log line names the address instead of the box model

- **Source:** 🔎 QA reviewer, compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:655`](https://github.com/bitfocus/companion-module-fritz-fritzbox/blob/b32c21d9304a0059d13dccf6aac5ead2b6d74d82/src/main.ts#L655)

**What goes wrong:** In 1.0.0-beta.2 the log said e.g. `Connected to FRITZ!Box 7490` when a connection was enabled or its settings were saved. It now says `Connected to 192.168.178.1` (or the MyFRITZ! address). Only the log text changes; nothing else is affected.

**Why it happens:** This release moved the status update and the "Connected to ..." line to right after the quick part of a read, so they show up sooner. The model is read in the slow part, which runs after that line, and saving the settings resets the router state, so the model is still empty on the first connect.

**Fix:** Keep showing the status and values early, but log "Connected to ..." after the slow part on the first poll. Or log the model once, when it first becomes known.

## 📝 Additional Notes

- First release: the module has never been published, so there is no published diff and this review covers the whole module at `v1.0.0`. Every finding is classified 🆕 NEW.
- This is a follow-up to the [v1.0.0-beta.2 review](review-fritz-fritzbox-v1.0.0-beta.2-20261030-090507.md). The fixes arrived in `v1.0.0-beta.3` ([`5bb3003`](https://github.com/bitfocus/companion-module-fritz-fritzbox/commit/5bb30033a6f0805216975212aa3ff4db815917de)), which was not reviewed separately; `v1.0.0` adds the changes from testing with FRITZ!OS 7.62. Both are covered here. Every finding from the prior review is fixed:
- **CI workflow (prior H1):** fixed. [`.github/workflows/node.yaml`](https://github.com/bitfocus/companion-module-fritz-fritzbox/blob/b32c21d9304a0059d13dccf6aac5ead2b6d74d82/.github/workflows/node.yaml) now matches the template, with only the template's own optional test job uncommented.
- **Wrong WAN connection on DSL boxes (prior M1):** fixed. The service pattern now matches digits and a literal dot ([`src/router.ts:278`](https://github.com/bitfocus/companion-module-fritz-fritzbox/blob/b32c21d9304a0059d13dccf6aac5ead2b6d74d82/src/router.ts#L278)), and a guess is re-checked on the next poll until a definite answer arrives ([`src/router.ts:660-698`](https://github.com/bitfocus/companion-module-fritz-fritzbox/blob/b32c21d9304a0059d13dccf6aac5ead2b6d74d82/src/router.ts#L660-L698)).
- **Smart home name variables after a settings save (prior M2):** fixed. Both fingerprints are reset in `#applyConfig()` ([`src/main.ts:472-475`](https://github.com/bitfocus/companion-module-fritz-fritzbox/blob/b32c21d9304a0059d13dccf6aac5ead2b6d74d82/src/main.ts#L472-L475)).
- **Device field of the network device actions (prior M3):** fixed. The field sets `allowCustom: true` with the feedbacks' tooltip ([`src/actions.ts:122-131`](https://github.com/bitfocus/companion-module-fritz-fritzbox/blob/b32c21d9304a0059d13dccf6aac5ead2b6d74d82/src/actions.ts#L122-L131)).
- **Button pressed recently stays on (prior L1):** fixed. A one-second check runs while a press is recent and is cleared in `#stop()` ([`src/main.ts:604-627`](https://github.com/bitfocus/companion-module-fritz-fritzbox/blob/b32c21d9304a0059d13dccf6aac5ead2b6d74d82/src/main.ts#L604-L627)).
- **Missing Smart Home right shown as Authentication failure (prior L2):** fixed. It is now a warning with a hint ([`src/main.ts:789-796`](https://github.com/bitfocus/companion-module-fritz-fritzbox/blob/b32c21d9304a0059d13dccf6aac5ead2b6d74d82/src/main.ts#L789-L796)).
- **Number from an expression breaks the lookups (prior L3):** fixed ([`src/shstate.ts:104`](https://github.com/bitfocus/companion-module-fritz-fritzbox/blob/b32c21d9304a0059d13dccf6aac5ead2b6d74d82/src/shstate.ts#L104), [`src/router.ts:293`](https://github.com/bitfocus/companion-module-fritz-fritzbox/blob/b32c21d9304a0059d13dccf6aac5ead2b6d74d82/src/router.ts#L293)).
- **Malformed character code stops the host list (prior N1):** fixed. Out-of-range codes stay as written ([`src/http.ts:142-145`](https://github.com/bitfocus/companion-module-fritz-fritzbox/blob/b32c21d9304a0059d13dccf6aac5ead2b6d74d82/src/http.ts#L142-L145)).
- **Empty smart home overview reply (prior N2):** fixed. It now raises a clear error ([`src/smarthome.ts:224-226`](https://github.com/bitfocus/companion-module-fritz-fritzbox/blob/b32c21d9304a0059d13dccf6aac5ead2b6d74d82/src/smarthome.ts#L224-L226)).
