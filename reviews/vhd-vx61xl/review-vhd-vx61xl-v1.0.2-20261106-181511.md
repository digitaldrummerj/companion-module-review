# Review: companion-module-vhd-vx61xl v1.0.2 (follow-up to the v1.0.1 review)

| Field | Value |
| --- | --- |
| **Module** | [companion-module-vhd-vx61xl](https://github.com/bitfocus/companion-module-vhd-vx61xl) |
| **Scope** | `tag` |
| **Version** | `v1.0.2` (commit [`777eecb`](https://github.com/bitfocus/companion-module-vhd-vx61xl/commit/777eecb2976b4ddd66cbeaeed9fed2dfbc6baced)) |
| **Release** | New module — never published |
| **API** | 1 (base 1.14.1, yarn.lock) |
| **Template** | `companion-module-template-js-v1` @ `9e222b4` (2026-03-26, pinned) · `.yarnrc.yml` from `companion-module-template-js` @ `89da037` (2026-11-01) |
| **Review basis** | First release: no version has been published, so there is no published diff and the whole module was reviewed. This review also checks the fixes for the [v1.0.1 review](review-vhd-vx61xl-v1.0.1-20261030-090507.md) |
| **Date** | 2026-11-06 |

## Verdict: ✅ Approved

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | When the camera rejects a command it sends a standard VISCA error reply (`y0 6z … FF`), so a parser that checks for a second byte of `0x60`–`0x6F` would catch it | The standard VISCA protocol and the module's own comment that mentions error packets. The module parses no replies, so the VHD reply format could not be checked in code | [N1](#n1-commands-the-camera-rejects-look-successful) |
| A2 | Companion versions older than 4.2 do not load a module built on `@companion-module/base` 1.14.x, so "Requires Companion 4.2 or later" is the accurate compatibility statement | The version table in the companion-v1-api-compliance skill (base `~1.14` needs Companion 4.2+). Companion's own version gate was not checked | [L1](#l1-following-the-readmes-test-build-step-fails-with-an-unknown-script-error) (only its optional compatibility-sentence suggestion) |

## 📋 Issues

### Non-blocking

- [ ] [L1: Following the README's test-build step fails with an unknown-script error](#l1-following-the-readmes-test-build-step-fails-with-an-unknown-script-error)
- [ ] [N1: Commands the camera rejects look successful](#n1-commands-the-camera-rejects-look-successful)
- [ ] [N2: Buttons can only show whether the camera is connected, not any camera state](#n2-buttons-can-only-show-whether-the-camera-is-connected-not-any-camera-state)
- [ ] [NR1: Plan the move to the v2 Companion module API](#nr1-plan-the-move-to-the-v2-companion-module-api)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟢 Low

### L1: Following the README's test-build step fails with an unknown-script error

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`README.md:46-48`](https://github.com/bitfocus/companion-module-vhd-vx61xl/blob/777eecb2976b4ddd66cbeaeed9fed2dfbc6baced/README.md#L46-L48), [`README.md:40-42`](https://github.com/bitfocus/companion-module-vhd-vx61xl/blob/777eecb2976b4ddd66cbeaeed9fed2dfbc6baced/README.md#L40-L42)

**What goes wrong:** A tester or contributor follows the README's Installation section ("To test a local build, run `yarn build` and use **Modules → Import module package**"). Yarn stops with "Couldn't find a script named build", so no `.tgz` is produced to import into Companion. The Development section a few lines further down shows the command that works, `yarn package`. Nobody using the module in Companion is affected.

**Why it happens:** v1.0.2 replaced the `package.json` scripts with the template's two scripts, `format` and `package`. The Development block was updated to `yarn package`, but the Installation paragraph still names `yarn build`, which does not exist.

**Evidence:**

```json
// package.json:7-10
"scripts": {
	"format": "prettier -w .",
	"package": "companion-module-build"
},
```

**Fix:** change the command on line 47 to `yarn package`, which writes `vhd-vx61xl-<version>.tgz` to the repository root.

```markdown
(search for "VHD VX61XL"). To test a local build, run `yarn package` and use
```

Optionally, also make the compatibility sentence on lines 40-42 ("any Companion version that accepts module API 1.0.0–1.14.x") concrete, for example "Requires Companion 4.2 or later (module API 1.14)". That wording depends on [A2](#-assumptions-to-confirm).

## 💡 Nice to Have

### N1: Commands the camera rejects look successful

- **Source:** 🔎 protocol reviewer + QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:157-160`](https://github.com/bitfocus/companion-module-vhd-vx61xl/blob/777eecb2976b4ddd66cbeaeed9fed2dfbc6baced/src/main.js#L157-L160)

**What goes wrong:** A user presses a button with, for example, "Tracking: Mode" or "Gain" on a camera model or firmware that does not support that command. The camera answers with a VISCA error reply, but at the default log level Companion shows nothing: the connection stays green (OK), the "Camera connected" feedback stays on, and the button looks like it worked. The user only finds the reason by switching the connection log to debug and decoding the `RX:` hex by hand ([`companion/HELP.md:44-47`](https://github.com/bitfocus/companion-module-vhd-vx61xl/blob/777eecb2976b4ddd66cbeaeed9fed2dfbc6baced/companion/HELP.md#L44-L47) does point there). This matters most for the direct-value actions (Gain, Bright, Brightness, Contrast, Sharpness/Aperture, Color Temperature), which HELP.md says should be spot-checked. Nothing breaks. Depends on [A1](#-assumptions-to-confirm).

**Why it happens:** The socket's data handler only logs each reply as hex at debug level and never reads it. The code comment there says ACK, completion and error replies could be parsed later. This is unchanged since the v1.0.1 review (N1 there).

**Evidence:**

```js
// src/main.js:157-160
socket.on('data', (data) => {
	// VISCA ACK/completion/error packets could be parsed here if needed later.
	this.log('debug', 'RX: ' + data.toString('hex'))
})
```

**Fix:** split the incoming data into VISCA packets on the `0xFF` terminator, and log every error reply at `warn` with a readable reason. A reply is an error when its second byte is `0x60`–`0x6F`; the third byte gives the reason: `02` syntax error, `03` command buffer full, `04` command cancelled, `05` no socket, `41` command not executable. Keep ACK (`0x4y`) and completion (`0x5y`) replies at debug. Keep any partial packet left after the last `0xFF` and prepend it to the next read, so a reply split across two TCP reads is still decoded.

### N2: Buttons can only show whether the camera is connected, not any camera state

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.js:3-16`](https://github.com/bitfocus/companion-module-vhd-vx61xl/blob/777eecb2976b4ddd66cbeaeed9fed2dfbc6baced/src/feedbacks.js#L3-L16)

**What goes wrong:** A user who adds the VX61XL connection and opens a button's Feedbacks list finds one entry, "Camera connected". They cannot make a button light up for the camera's state: red while the Tally colour is Red, green while preset 5 is the last one recalled, or lit while Human Tracking is on. Only the connection state can be shown, which Companion's Connections page already shows. The module talks to a single camera over one TCP socket, so the existing "Camera connected" feedback is accepted for this first release and this stays Nice to Have, as in the v1.0.1 review (N2 there). README and HELP.md list it as a known limitation ([`companion/HELP.md:36-40`](https://github.com/bitfocus/companion-module-vhd-vx61xl/blob/777eecb2976b4ddd66cbeaeed9fed2dfbc6baced/companion/HELP.md#L36-L40)).

**Why it happens:** The feedback definitions hold only `connected`. The module sends no VISCA inquiries, its data handler only logs replies as hex ([`src/main.js:157-160`](https://github.com/bitfocus/companion-module-vhd-vx61xl/blob/777eecb2976b4ddd66cbeaeed9fed2dfbc6baced/src/main.js#L157-L160)), and it keeps no record of what it last sent, such as the last recalled preset, tally colour, power or tracking state.

**Fix:** in a future release, keep track of the camera state the module sets itself, and add boolean feedbacks with matching variables for it. Good candidates are the last recalled preset ("Preset: Recall"), tally colour ("Tally: Colour"), power on/off ("Power") and human tracking on/off ("Tracking: Enable Human Tracking"). Where the V60 command table documents inquiries (for example the standard power inquiry `8x 09 04 00 FF`), parse the replies in the data handler so the feedbacks show the camera's real state. Another connection-status feedback would not help here: it does not show device state.

## 🔮 Next Release

### NR1: Plan the move to the v2 Companion module API

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`package.json:11-13`](https://github.com/bitfocus/companion-module-vhd-vx61xl/blob/777eecb2976b4ddd66cbeaeed9fed2dfbc6baced/package.json#L11-L13)

**What goes wrong:** Nothing breaks today. The module is on `@companion-module/base` `~1.14.1`, the last v1 line, which runs on Companion 4.2 and later. New API features, such as expressions in options, action results and layered presets, only come with base v2 (API 2.0 for Companion 4.3+, API 2.1 for Companion 5.0+). Users of this module won't get them until it moves.

**Why it happens:** `package.json` declares `"@companion-module/base": "~1.14.1"`. That now matches the v1 template's range, as the v1.0.1 review suggested (R1 there).

**Fix:** in a future release, migrate to `@companion-module/base` v2 using the companion-v1-to-v2-migration guide. That covers ESM, the entry point and manifest changes, and Node 22, which the module already targets. Then check the result against the v2 API compliance checklist.

## 📝 Additional Notes

- **v1.0.1 blocking findings — all fixed:** C1–C17 are resolved. The sources are under `src/`, `package.json` has the template's scripts, fields and `prettier` dev dependency, and `.yarnrc.yml`, `.gitattributes`, `.prettierignore` and the template `.gitignore` are in place. The template check reports nothing, and `yarn install --immutable` and `yarn package` succeed (`vhd-vx61xl-1.0.2.tgz`).
- **v1.0.1 M1 — fixed:** the "Connection status" preset now builds its text from the connection's label and the presets are sent again on every settings save ([`src/presets.js:58`](https://github.com/bitfocus/companion-module-vhd-vx61xl/blob/777eecb2976b4ddd66cbeaeed9fed2dfbc6baced/src/presets.js#L58), [`src/main.js:31-37`](https://github.com/bitfocus/companion-module-vhd-vx61xl/blob/777eecb2976b4ddd66cbeaeed9fed2dfbc6baced/src/main.js#L31-L37)).
- **v1.0.1 L1 — fixed:** clearing the camera IP now sets the "Connection status" variable to "No camera IP configured" ([`src/main.js:109-115`](https://github.com/bitfocus/companion-module-vhd-vx61xl/blob/777eecb2976b4ddd66cbeaeed9fed2dfbc6baced/src/main.js#L109-L115)).
- **v1.0.1 L2 — fixed:** action names are short ("Gain", "Color Temperature", "Address Set (broadcast)"), and number options are labelled "Value" with the range and encoding notes in the option description ([`src/actions.js:36-50`](https://github.com/bitfocus/companion-module-vhd-vx61xl/blob/777eecb2976b4ddd66cbeaeed9fed2dfbc6baced/src/actions.js#L36-L50)).
- **v1.0.1 L3 — fixed:** HELP.md now gives the variable as `$(<connection label>:connection_status)` and names the default label `vx61xl` ([`companion/HELP.md:14-16`](https://github.com/bitfocus/companion-module-vhd-vx61xl/blob/777eecb2976b4ddd66cbeaeed9fed2dfbc6baced/companion/HELP.md#L14-L16)).
- **v1.0.1 N1, N2 and R1 — carried forward:** unchanged and still non-blocking; they are [N1](#n1-commands-the-camera-rejects-look-successful), [N2](#n2-buttons-can-only-show-whether-the-camera-is-connected-not-any-camera-state) and [NR1](#nr1-plan-the-move-to-the-v2-companion-module-api) here. R1's interim suggestion (the `~1.14.1` range) was applied.
- The `v1.0.2` tag points at the Dependabot commit `777eecb` (`fast-uri` 3.1.8 → 3.1.9 in `yarn.lock`) on top of the maintainer's `bdf55dc`. It changes only the lockfile, and the immutable install passes with it.
