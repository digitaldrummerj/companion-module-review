# Review: companion-module-nexo-nxamp v3.0.0

| Field | Value |
| --- | --- |
| **Module** | [`companion-module-nexo-nxamp`](https://github.com/bitfocus/companion-module-nexo-nxamp) |
| **Scope** | `tag` (`v2.1.1..v3.0.0`) |
| **Version** | v3.0.0 (`e32454e`) |
| **Release** | Update — last published v2.1.1 |
| **API** | 2.2 (base 2.2.2, yarn.lock) — requires Companion 5.1+ |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11, main) |
| **Reviewed** | 2026-11-06 |

## Verdict: ✅ Approved

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | The machine running Companion can have its wall clock stepped while it runs (for example NTP setting the time after boot on a device with no real-time clock). | General OS/NTP behaviour, not anything in the module or `@companion-module/base` | [N1](#n1-a-system-clock-change-can-trigger-one-needless-reconnect-to-the-amplifier) |
| A2 | Companion's connection settings mark a text field as invalid when its value fails the field's regex, so an IPv6 address typed into Device IP is flagged. | General Companion UI behaviour for regex-validated config fields; Companion's host code was not checked | [M1](#m1-device-ip-field-rejects-ipv6-addresses-and-uses-a-regex-that-base-222-deprecates) |
| A3 | The NXAMP accepts control connections over IPv6. If it doesn't, the IPv6 effect disappears and only the deprecation (and its log warning) remains. | No device documentation in the module; base 2.2.2's TCPHelper handles IPv6 hosts (its changelog mentions bracketing IPv6 hosts in log messages) | [M1](#m1-device-ip-field-rejects-ipv6-addresses-and-uses-a-regex-that-base-222-deprecates) |
| A4 | Companion calls the module's `getConfigFields()` at least when a user opens the connection's settings, so the one-time "Regex.HOSTNAME is deprecated" warning shows up in the connection log in normal use. | The Proxy getter in `@companion-module/base` 2.2.2 `enums.js` logs on first read, and the module only reads `Regex.HOSTNAME` inside `GetConfigFields()`; when Companion itself calls `getConfigFields()` was not checked in the host code | [M1](#m1-device-ip-field-rejects-ipv6-addresses-and-uses-a-regex-that-base-222-deprecates) (the log-warning sentence) |

## 📋 Issues

### Non-blocking

- [ ] [M1: Device IP field rejects IPv6 addresses and uses a regex that base 2.2.2 deprecates](#m1-device-ip-field-rejects-ipv6-addresses-and-uses-a-regex-that-base-222-deprecates)
- [ ] [N1: A system clock change can trigger one needless reconnect to the amplifier](#n1-a-system-clock-change-can-trigger-one-needless-reconnect-to-the-amplifier)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟡 Medium

### M1: Device IP field rejects IPv6 addresses and uses a regex that base 2.2.2 deprecates

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/config.ts:19-24`](https://github.com/bitfocus/companion-module-nexo-nxamp/blob/e32454e79d6cb01ff04d954bea049fcc89409cd5/src/config.ts#L19-L24)

**What goes wrong:** A user opens the connection settings and types an IPv6 address such as `fd00::10` into **Device IP**. Companion marks the field as invalid, because the pattern behind the field only matches dotted names and IPv4 addresses. IPv4 addresses (e.g. `192.168.1.50`) and plain hostnames (e.g. `nxamp-1.local`) still work, so if the amplifier is only ever reached over IPv4, nobody sees a difference there. Separately, once Companion asks the module for its connection settings (for example when a user opens them), a one-time warning appears in the connection log: "Regex.HOSTNAME is deprecated. Allow any text instead, as hostnames can take many forms". The module uses a pattern that its own base version deprecates, and base 2.2.2 says so in the log.

**Why it happens:** The Device IP field is validated with Companion's built-in hostname pattern (`Regex.HOSTNAME`). This release moves the module to `@companion-module/base` 2.2.2, which deprecates that pattern and asks modules to use a plain text field instead. The old `regex: Regex.HOSTNAME` line was carried into the new TypeScript config. The module already refuses an empty host itself ([`src/main.ts:73-76`](https://github.com/bitfocus/companion-module-nexo-nxamp/blob/e32454e79d6cb01ff04d954bea049fcc89409cd5/src/main.ts#L73-L76) sets the status to "No host"), so the regex adds nothing.

The API 2.2 rules (v2.2 Medium: deprecated `Regex` patterns) make this a 🟡 Medium: `Regex.HOSTNAME` is one of the patterns base 2.2.2 deprecates, and this release is the one that moves the module to base 2.2.2. It is still 🆕 NEW and still non-blocking. Besides the IPv6 effect above, there is now a visible log effect. Base 2.2.2's `Regex` is a Proxy (`node_modules/@companion-module/base/dist/module-api/enums.js:79-93`): reading `Regex.HOSTNAME` in `GetConfigFields()` ([`src/config.ts:23`](https://github.com/bitfocus/companion-module-nexo-nxamp/blob/e32454e79d6cb01ff04d954bea049fcc89409cd5/src/config.ts#L23), returned by `getConfigFields()` at [`src/main.ts:59-61`](https://github.com/bitfocus/companion-module-nexo-nxamp/blob/e32454e79d6cb01ff04d954bea049fcc89409cd5/src/main.ts#L59-L61)) writes a one-time warning to the connection log: "Regex.HOSTNAME is deprecated. Allow any text instead, as hostnames can take many forms".

**Evidence:**

```ts
// src/config.ts:19-24
type: 'textinput',
id: 'host',
label: 'Device IP',
width: 12,
regex: Regex.HOSTNAME,
},
```

```ts
// node_modules/@companion-module/base/dist/module-api/enums.d.ts:31-32
/** @deprecated Use a `textinput` field without a regex instead, with `minLength: 1` if a value is required */
readonly HOSTNAME: "/^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9])\\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9-]*[A-Za-z0-9])$/";
```

**Fix:** remove the regex from the Device IP field, and add `minLength: 1` if the field should be required in the UI. Then drop the unused `Regex` import. Since hostnames are accepted, consider renaming the label to "Device IP / Hostname". See companion-v2-config. The field stays a `textinput` and the stored `host` string doesn't change, so no upgrade script is needed.

```ts
{
	type: 'textinput',
	id: 'host',
	label: 'Device IP / Hostname',
	width: 12,
	minLength: 1,
},
```

## 💡 Nice to Have

### N1: A system clock change can trigger one needless reconnect to the amplifier

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/api/amplifier.ts:147`](https://github.com/bitfocus/companion-module-nexo-nxamp/blob/e32454e79d6cb01ff04d954bea049fcc89409cd5/src/api/amplifier.ts#L147), [`src/api/amplifier.ts:176`](https://github.com/bitfocus/companion-module-nexo-nxamp/blob/e32454e79d6cb01ff04d954bea049fcc89409cd5/src/api/amplifier.ts#L176), [`src/api/amplifier.ts:215-216`](https://github.com/bitfocus/companion-module-nexo-nxamp/blob/e32454e79d6cb01ff04d954bea049fcc89409cd5/src/api/amplifier.ts#L215-L216)

**What goes wrong:** Take a Companion Pi with no real-time clock. It boots, connects to the NXAMP, the amplifier answers the 30-second keepalive, and then NTP sets the clock forward by a few hours. At the next keepalive the module thinks the amplifier has been silent for hours. It logs a warning such as "Nothing received from amplifier for 10800000 ms, reconnecting", the connection status briefly shows Connecting, and the module reconnects even though the amplifier was answering the whole time. A backward clock step does the opposite: a dead amplifier is noticed late, by the size of the step. This is rare and harmless, and the next connection works normally.

**Why it happens:** The new watchdog reconnects when nothing has arrived for 1.5 keepalive intervals (45 seconds). It measures that silence with the wall clock (`Date.now()`), which jumps whenever the system time is changed, instead of a clock that only ever counts forward.

**Evidence:**

```ts
// src/api/amplifier.ts:147
this.#lastReceived = Date.now()
// src/api/amplifier.ts:176
this.#lastReceived = Date.now()
// src/api/amplifier.ts:215-216
const silence = Date.now() - this.#lastReceived
if (this.#answersKeepalive && silence > this.#timing.keepaliveInterval * WATCHDOG_INTERVALS) {
```

**Fix:** measure the watchdog's silence with a monotonic clock. Use `performance.now()` in all three places; the log message and the tests stay the same.

```ts
// #open() and #receive()
this.#lastReceived = performance.now()
// #keepalive()
const silence = performance.now() - this.#lastReceived
```

## 📝 Additional Notes

- `tsconfig.build.json` differs from the template: the `exclude` list at [`tsconfig.build.json:4`](https://github.com/bitfocus/companion-module-nexo-nxamp/blob/e32454e79d6cb01ff04d954bea049fcc89409cd5/tsconfig.build.json#L4) uses `"src/**/__tests__/**"` and `"src/**/__mocks__/**"` where the template has `"src/**/__tests__/*"` and `"src/**/__mocks__/*"`. This only widens the exclude so nested test files stay out of the build. The build passes, so no change is required.
- API compliance was re-checked on 2026-11-06 against the API 2.2 rules (companion-v2-api-compliance 1.2.0): the only match is the deprecated `Regex.HOSTNAME` on the Device IP field, already covered by [M1](#m1-device-ip-field-rejects-ipv6-addresses-and-uses-a-regex-that-base-222-deprecates) (moved from Low to Medium). Nothing else applies: all three feedbacks are boolean (no value feedbacks), there are no presets (so no `storeResult`) and no variable definitions, no misspelled `Regex` keys, and no UDP (only `TCPHelper`).
