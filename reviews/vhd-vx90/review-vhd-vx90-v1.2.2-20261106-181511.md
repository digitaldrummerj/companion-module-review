# Review: companion-module-vhd-vx90 v1.2.2 (follow-up to the v1.2.1 review)

| Field | Value |
| --- | --- |
| **Module** | [companion-module-vhd-vx90](https://github.com/bitfocus/companion-module-vhd-vx90) |
| **Scope** | `tag` (first release: the module has never been published, so there is no published tag to diff against and the whole module was reviewed) |
| **Version** | v1.2.2 |
| **Release** | New module — never published |
| **API** | 1 (base 1.14.1, yarn.lock) |
| **Template** | `companion-module-template-js-v1` @ `9e222b4` (2026-03-26, pinned) · `.yarnrc.yml` from `companion-module-template-js` @ `89da037` (2026-11-01) |
| **Commit** | [`bc72b18`](https://github.com/bitfocus/companion-module-vhd-vx90/tree/bc72b187c4fae17f78eea86f257237a6981a8f75) |
| **Follow-up to** | [v1.2.1 review (2026-10-30)](review-vhd-vx90-v1.2.1-20261030-090507.md) |
| **Reviewed** | 2026-11-06 |

## Verdict: ✅ Approved

## 📋 Issues

### Non-blocking

- [ ] [N1: A command the camera rejects looks like it did nothing, and the normal log doesn't say why](#n1-a-command-the-camera-rejects-looks-like-it-did-nothing-and-the-normal-log-doesnt-say-why)
- [ ] [N2: Action names carry developer notes, and option labels repeat the action name](#n2-action-names-carry-developer-notes-and-option-labels-repeat-the-action-name)
- [ ] [N3: The help page uses different field names from the settings and doesn't mention the firmware setting](#n3-the-help-page-uses-different-field-names-from-the-settings-and-doesnt-mention-the-firmware-setting)
- [ ] [N4: The README tells developers to run a `yarn build` script that doesn't exist](#n4-the-readme-tells-developers-to-run-a-yarn-build-script-that-doesnt-exist)
- [ ] [NR1: Plan the move to Companion module API 2](#nr1-plan-the-move-to-companion-module-api-2)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 💡 Nice to Have

### N1: A command the camera rejects looks like it did nothing, and the normal log doesn't say why

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:213-216`](https://github.com/bitfocus/companion-module-vhd-vx90/blob/bc72b187c4fae17f78eea86f257237a6981a8f75/src/main.js#L213-L216), [`src/main.js:239-249`](https://github.com/bitfocus/companion-module-vhd-vx90/blob/bc72b187c4fae17f78eea86f257237a6981a8f75/src/main.js#L239-L249)

**What goes wrong:** A user sets "Camera firmware" to "V8.1.97 and newer" for a camera that actually runs V8.1.92, then presses a button with "[V8.1.97+] Fan: set speed / auto". The same can happen with one of the [VHD-ext] actions that HELP asks users to spot-check, such as "Tracking: Mode". If the camera refuses the command, nothing visible happens: the connection stays green and the Companion log at its normal level is empty. The camera's reply only appears as a hex "RX: …" line with debug logging on, so the user can't tell a wrong firmware choice from an unsupported command or a camera problem.

**Why it happens:** The handler for data coming back from the camera logs every reply in hex at debug level and does nothing else. Its own comment says ACK, completion and error replies "could be parsed here if needed later", so an error reply looks the same as a normal acknowledgement.

**Fix:** remember the last command sent, and log VISCA error replies (second byte `0x6y`) at `warn` level together with that command. ACK and completion replies can stay at debug level.

```js
// in sendBuffer(), before writing
this.lastTx = buf.toString('hex')

// in initConnection()
socket.on('data', (data) => {
	this.log('debug', 'RX: ' + data.toString('hex'))
	// Each VISCA reply ends with 0xFF; an error reply has 0x6y as its second byte.
	let start = 0
	for (let i = 0; i < data.length; i++) {
		if (data[i] !== 0xff) continue
		const reply = data.subarray(start, i + 1)
		start = i + 1
		if (reply.length >= 3 && (reply[1] & 0xf0) === 0x60) {
			this.log('warn', `Camera rejected command ${this.lastTx}: ${reply.toString('hex')}`)
		}
	}
})
```

### N2: Action names carry developer notes, and option labels repeat the action name

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.js:29-70`](https://github.com/bitfocus/companion-module-vhd-vx90/blob/bc72b187c4fae17f78eea86f257237a6981a8f75/src/actions.js#L29-L70), [`src/actions.js:202`](https://github.com/bitfocus/companion-module-vhd-vx90/blob/bc72b187c4fae17f78eea86f257237a6981a8f75/src/actions.js#L202), [`src/actions.js:128`](https://github.com/bitfocus/companion-module-vhd-vx90/blob/bc72b187c4fae17f78eea86f257237a6981a8f75/src/actions.js#L128), [`src/actions.js:173`](https://github.com/bitfocus/companion-module-vhd-vx90/blob/bc72b187c4fae17f78eea86f257237a6981a8f75/src/actions.js#L173), [`src/actions.js:457`](https://github.com/bitfocus/companion-module-vhd-vx90/blob/bc72b187c4fae17f78eea86f257237a6981a8f75/src/actions.js#L457), [`src/actions.js:516`](https://github.com/bitfocus/companion-module-vhd-vx90/blob/bc72b187c4fae17f78eea86f257237a6981a8f75/src/actions.js#L516), [`src/actions.js:527-529`](https://github.com/bitfocus/companion-module-vhd-vx90/blob/bc72b187c4fae17f78eea86f257237a6981a8f75/src/actions.js#L527-L529), [`src/actions.js:706-708`](https://github.com/bitfocus/companion-module-vhd-vx90/blob/bc72b187c4fae17f78eea86f257237a6981a8f75/src/actions.js#L706-L708), [`src/actions.js:801`](https://github.com/bitfocus/companion-module-vhd-vx90/blob/bc72b187c4fae17f78eea86f257237a6981a8f75/src/actions.js#L801)

**What goes wrong:** In Companion's action picker, users see names full of notes meant for developers, for example "Audio Input (restart required) [VHD-ext, unusual category 0x2A]", "ND Filter Mode [VHD-ext, differs from Sony]", "Tally: Simple colour (shares Sony opcode)", "Shutter Position (0-17, table's 0x00-0x11)", "[V8.1.97+] Colour Matrix: set hue (absolute 0-64, verify axis order)" and "[V8.1.97+] Pan/Tilt: Ramp Curve (range per VHD doc, verify)". After adding an action, its option field repeats the full action name as its label: "Exposure: Mode" has a dropdown labelled "Exposure: Mode", and "RG Tuning (-10..10)" has a number field labelled "RG Tuning (-10..10)". The spelling also switches between "Color Temperature (2500K-8000K)" and "[V8.1.97+] Colour Temperature: direct Kelvin (2500-8000)". Everything works; the list is just harder to scan.

**Why it happens:** The shared helpers that build most actions (`choiceAction`, `numberAction`, `byteAction`, `onOff` and the tuning helper) use the action's name as the option's label (`label: name`). The protocol notes were written into the action names instead of the `description` fields, which `@companion-module/base` 1.14.1 provides on both actions and options.

**Fix:** keep the action names short and move the notes into descriptions. The short `[VHD-ext]` and `[V8.1.97+]` tags can stay, since HELP tells users to look for them. Give the helpers a short option label such as "Mode" or "Value", or pass it in as a parameter, and use one spelling (Color or Colour) throughout. Renaming is safe for existing buttons: saved buttons refer to the action id (`audio_input`) and the option id (`value`), not to the names or labels.

```js
const choiceAction = (name, prefixBytes, choices, defaultId, suffixBytes = [], label = 'Value') => ({
	name,
	options: [{ id: 'value', type: 'dropdown', label, default: defaultId, choices }],
	callback: (event) => {
		send([...prefixBytes, parseInt(event.options.value, 16), ...suffixBytes])
	},
})

actions.audio_input = {
	...choiceAction(
		'Audio Input [VHD-ext]',
		[0x2a, 0x01, 0x1b],
		[
			{ id: '2', label: 'Line In' },
			{ id: '3', label: 'Mic' },
			{ id: '4', label: 'XLR' },
		],
		'2',
		[],
		'Input',
	),
	description: 'The camera must restart before the new input is used.',
}
```

### N3: The help page uses different field names from the settings and doesn't mention the firmware setting

- **Source:** 🔎 QA reviewer, compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`companion/HELP.md:5-11`](https://github.com/bitfocus/companion-module-vhd-vx90/blob/bc72b187c4fae17f78eea86f257237a6981a8f75/companion/HELP.md#L5-L11), [`src/main.js:86-136`](https://github.com/bitfocus/companion-module-vhd-vx90/blob/bc72b187c4fae17f78eea86f257237a6981a8f75/src/main.js#L86-L136)

**What goes wrong:** A user opens the module's help from the connection page. It lists "IP address", "Port" and "VISCA address", but the settings page shows "Camera IP address", "VISCA TCP port" and "VISCA camera address". The help says nothing about the "Camera firmware" dropdown, which decides whether the [V8.1.97+] actions (fine zoom speed, Kelvin colour temperature, fan, colour matrix and so on) appear at all. A user who can't find the fan or colour matrix actions gets no hint from the help that they need to change the firmware setting. The settings page's own text and tooltip do explain it, so the impact is small.

**Why it happens:** The Connection section of HELP.md was written before the firmware selector was added, and it uses shortened field names. Only README.md, which Companion users don't see, describes the selector.

**Fix:** use the exact field labels from the settings page, and add a "Camera firmware" entry.

```markdown
## Connection

- **Camera firmware**: the firmware your camera runs. "V8.1.92 and older" offers the classic actions; "V8.1.97 and newer" adds the actions marked [V8.1.97+]. Buttons that use a [V8.1.97+] action show as unknown while "V8.1.92 and older" is selected.
- **Camera IP address**: the camera's LAN IP.
- **VISCA TCP port**: 5678 by default (the VX-90's own "PTZ port" setting).
- **VISCA camera address**: 1 by default (the camera's factory default).
```

### N4: The README tells developers to run a `yarn build` script that doesn't exist

- **Source:** 🔎 QA reviewer, compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`README.md:41-43`](https://github.com/bitfocus/companion-module-vhd-vx90/blob/bc72b187c4fae17f78eea86f257237a6981a8f75/README.md#L41-L43), [`README.md:13`](https://github.com/bitfocus/companion-module-vhd-vx90/blob/bc72b187c4fae17f78eea86f257237a6981a8f75/README.md#L13), [`README.md:35-37`](https://github.com/bitfocus/companion-module-vhd-vx90/blob/bc72b187c4fae17f78eea86f257237a6981a8f75/README.md#L35-L37)

**What goes wrong:** A developer follows the README's Installation section ("To test a local build, run `yarn build` and use Modules → Import module package"). Yarn stops with a missing-script error, so no `.tgz` is made to import. The Development section further down uses the correct `yarn package`. The README also calls the firmware selector "new in 1.1.0", but there was no 1.1.0 release (it arrived in 1.2.0). The Compatibility section says the module works on "any Companion version that accepts module API 1.0.0–1.14.x", which doesn't tell a reader which Companion version they actually need. Companion users are not affected; the README is not shown in Companion.

**Why it happens:** `package.json` only defines the `format` and `package` scripts, and these README lines weren't updated when the scripts were aligned with the template in v1.2.2.

**Fix:** change `yarn build` to `yarn package` (it produces the `.tgz` to import), change "new in 1.1.0" to "new in 1.2.0", and state the minimum Companion version that `@companion-module/base` 1.14 needs (Companion 4.2 or newer) instead of the API range.

## 🔮 Next Release

### NR1: Plan the move to Companion module API 2

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`package.json:10-12`](https://github.com/bitfocus/companion-module-vhd-vx90/blob/bc72b187c4fae17f78eea86f257237a6981a8f75/package.json#L10-L12)

**What goes wrong:** Nothing visible now. The module is on the last API 1 line (`@companion-module/base` `~1.14.1`). API 2.0 (Companion 4.3+) and 2.1 (Companion 5.0+) add expression support in options and drop the deprecated API 1 patterns, so future Companion features will only reach the module after it moves to API 2.

**Why it happens:** The module was built on the API 1 template.

**Fix:** in a future release, migrate to `@companion-module/base` v2 using the Companion v1-to-v2 migration guide (entrypoint and ESM, option expressions, presets), and check the result against the v2 compliance checklist.

## 📝 Additional Notes

- **First release:** the module has never been published, so this `tag`-scope review covers the whole module. N1–N4 were already present in v1.2.1 and weren't raised then; they are new findings for this release, not regressions.
- **Follow-up result:** every finding from the [v1.2.1 review](review-vhd-vx90-v1.2.1-20261030-090507.md) is fixed in v1.2.2. The template validator reports no findings, and nothing blocking is carried forward.
- **Prior C1–C4 (fixed):** `.gitattributes`, `.gitignore`, `.prettierignore` and `.yarnrc.yml` now match the template.
- **Prior C5–C10 (fixed):** the six source files are now in `src/`; `package.json` `main` is `src/main.js` and the manifest `entrypoint` is `../src/main.js`.
- **Prior C11–C16 (fixed):** [`package.json`](https://github.com/bitfocus/companion-module-vhd-vx90/blob/bc72b187c4fae17f78eea86f257237a6981a8f75/package.json) now has `engines`, `prettier`, `packageManager` (`yarn@4.12.0`), the `format` and `package` scripts and the `prettier` devDependency, and `yarn.lock` was regenerated with Yarn 4.
- **Prior C17 (fixed):** `yarn install --immutable` and `yarn package` pass and produce `vhd-vx90-1.2.2.tgz`.
- **Prior L1 (fixed):** clearing the camera IP now sets the connection status variable to "No camera IP configured" ([`src/main.js:164-170`](https://github.com/bitfocus/companion-module-vhd-vx90/blob/bc72b187c4fae17f78eea86f257237a6981a8f75/src/main.js#L164-L170)). The "Connection status" preset now uses the connection's own label ([`src/presets.js:58`](https://github.com/bitfocus/companion-module-vhd-vx90/blob/bc72b187c4fae17f78eea86f257237a6981a8f75/src/presets.js#L58)), so the prior assumption A1 about the default `vx90` label no longer matters.
- **Prior L2 (fixed):** `sendBuffer()` now reports whether the command was sent, and the colour matrix value and its variable only change after a successful send ([`src/main.js:239-249`](https://github.com/bitfocus/companion-module-vhd-vx90/blob/bc72b187c4fae17f78eea86f257237a6981a8f75/src/main.js#L239-L249), [`src/actions.js:695-703`](https://github.com/bitfocus/companion-module-vhd-vx90/blob/bc72b187c4fae17f78eea86f257237a6981a8f75/src/actions.js#L695-L703)).
- **Prior L3 (fixed):** the "Manual speed (% PWM)" field of the fan action now uses `isVisibleExpression` ([`src/actions.js:675`](https://github.com/bitfocus/companion-module-vhd-vx90/blob/bc72b187c4fae17f78eea86f257237a6981a8f75/src/actions.js#L675)).
- **Prior N1 (fixed):** the unused `speedChoices` helper is gone.
- **Prior F1 (partly done, now NR1):** the declared base range is now `~1.14.1` as suggested; the move to API 2 stays open as [NR1](#nr1-plan-the-move-to-companion-module-api-2).
- **Changes in this release:** commit `0dddc7f` (template conformity and the fixes above) and the Dependabot commit `bc72b18` (`fast-uri` 3.1.8 → 3.1.9 in `yarn.lock`). Neither introduces a new problem.
