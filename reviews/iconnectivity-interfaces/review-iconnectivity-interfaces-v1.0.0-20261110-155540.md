# Companion Module Review: iconnectivity-interfaces v1.0.0

| Field | Value |
| --- | --- |
| **Module** | [companion-module-iconnectivity-interfaces](https://github.com/bitfocus/companion-module-iconnectivity-interfaces) |
| **Version** | v1.0.0 (commit [`1531528`](https://github.com/bitfocus/companion-module-iconnectivity-interfaces/commit/15315280e28cde4542c7e7acd8076155dc5ffd35)) |
| **Release** | New module — never published |
| **API** | 2.0 (base 2.0.4, yarn.lock) — requires Companion 4.3+ |
| **Template** | `companion-module-template-ts-v2.0.4` @ `d62230e` (2026-08-28, pinned) · `.yarnrc.yml` from `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Scope** | `tag` — first release: no version has been published, so the whole module at v1.0.0 was reviewed |
| **Reviewed** | 2026-11-10 |

## Verdict: ❌ Changes Required

## ❓ Assumptions

Some findings depend on assumptions the reviewers couldn't check. They're listed in [❓ Assumptions to Confirm](#-assumptions-to-confirm) at the end of this review.

## 📋 Issues

### Blocking

- [ ] [C1: The .gitignore has its own versions of the template's entries instead of the template's](#c1-the-gitignore-has-its-own-versions-of-the-templates-entries-instead-of-the-templates)
- [ ] [C2: The .prettierignore leaves out the template's package.json and LICENSE.md entries](#c2-the-prettierignore-leaves-out-the-templates-packagejson-and-licensemd-entries)
- [ ] [H1: yarn package, yarn build and yarn lint run different commands from the template](#h1-yarn-package-yarn-build-and-yarn-lint-run-different-commands-from-the-template)
- [ ] [H2: The package.json name doesn't match the module id](#h2-the-packagejson-name-doesnt-match-the-module-id)
- [ ] [H3: The README sends users to personal GitHub builds instead of the module list](#h3-the-readme-sends-users-to-personal-github-builds-instead-of-the-module-list)

### Non-blocking

- [ ] [M1: Saving the settings leaves the connection failed when Companion uses a fixed RTP port](#m1-saving-the-settings-leaves-the-connection-failed-when-companion-uses-a-fixed-rtp-port)
- [ ] [M2: The preset name variable keeps the previous preset's name after Recall preset](#m2-the-preset-name-variable-keeps-the-previous-presets-name-after-recall-preset)
- [ ] [M3: Users who switch Type to an expression have to type protocol numbers](#m3-users-who-switch-type-to-an-expression-have-to-type-protocol-numbers)
- [ ] [L1: Two log lines every 3 seconds when live monitoring can't be registered](#l1-two-log-lines-every-3-seconds-when-live-monitoring-cant-be-registered)
- [ ] [L2: Every incoming RTP-MIDI packet republishes every variable](#l2-every-incoming-rtp-midi-packet-republishes-every-variable)
- [ ] [L3: On a PlayAUDIO12, Apply snapshot or scene with Type Scene and ID 1 or 2 fails with the default settings](#l3-on-a-playaudio12-apply-snapshot-or-scene-with-type-scene-and-id-1-or-2-fails-with-the-default-settings)
- [ ] [L4: On a Linux host without working ALSA MIDI, the module can't start even for RTP-MIDI](#l4-on-a-linux-host-without-working-alsa-midi-the-module-cant-start-even-for-rtp-midi)
- [ ] [L5: Over USB, Refresh device state never reads the current preset or Scene](#l5-over-usb-refresh-device-state-never-reads-the-current-preset-or-scene)
- [ ] [L6: The upgrade script resets a custom discovery port to 5002](#l6-the-upgrade-script-resets-a-custom-discovery-port-to-5002)
- [ ] [L7: Action and feedback definitions are passed to Companion with as never](#l7-action-and-feedback-definitions-are-passed-to-companion-with-as-never)

## 🔴 Critical

### C1: The .gitignore has its own versions of the template's entries instead of the template's

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.gitignore`](https://github.com/bitfocus/companion-module-iconnectivity-interfaces/blob/15315280e28cde4542c7e7acd8076155dc5ffd35/.gitignore)

**What goes wrong:** Users see no difference. The file was written by hand: it has `/node_modules/`, `/pkg/`, `/dist/`, `/.yarn/` and `/.vscode/` where the template has `node_modules/`, `/pkg`, `/dist`, `/.yarn` and `/.vscode`. Most behave the same, but `/node_modules/` only ignores the top-level folder, so a `node_modules` folder anywhere else can be committed by mistake, and anyone comparing the file with the template has to check every entry by hand.

**Why it happens:** The template's `.gitignore` entries weren't copied; the module wrote its own equivalents.

**Evidence:**

```text
CONFIG-DIFF .gitignore: Missing template .gitignore entries: node_modules/, /pkg, /dist, /.yarn, /.vscode
```

**Fix:** Add the template's entries as they are. The module's extra entries (credentials, captures, logs, editor files) can stay.

```text
node_modules/
package-lock.json
/pkg
/*.tgz
/dist
DEBUG-*
/.yarn
/.vscode
```

### C2: The .prettierignore leaves out the template's package.json and LICENSE.md entries

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.prettierignore`](https://github.com/bitfocus/companion-module-iconnectivity-interfaces/blob/15315280e28cde4542c7e7acd8076155dc5ffd35/.prettierignore)

**What goes wrong:** Users see no difference. `yarn format` reformats `package.json`, which the template keeps out of Prettier because Yarn writes that file in its own style, so formatting and installing keep undoing each other's changes.

**Why it happens:** The module's `.prettierignore` lists its generated folders (`dist/`, `pkg/`, `releases/`, `captures/`, `coverage/`, `*.tgz`) and `LICENSE`, but not the template's two entries.

**Evidence:**

```text
CONFIG-DIFF .prettierignore: Differs from template (line 1: found 'node_modules/', template 'package.json')
```

**Fix:** Start the file with the template's two entries. The generated-folder entries and `LICENSE` can stay.

```text
package.json
/LICENSE.md
```

## 🟠 High

### H1: yarn package, yarn build and yarn lint run different commands from the template

- **Source:** 🔎 compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`package.json:10-19`](https://github.com/bitfocus/companion-module-iconnectivity-interfaces/blob/15315280e28cde4542c7e7acd8076155dc5ffd35/package.json#L10-L19), [`scripts/check-runtime.mjs:1-16`](https://github.com/bitfocus/companion-module-iconnectivity-interfaces/blob/15315280e28cde4542c7e7acd8076155dc5ffd35/scripts/check-runtime.mjs#L1-L16)

**What goes wrong:** Users see no difference. Anyone who builds the module the way the template does sees three differences:

- `yarn package` writes the package to `pkg/iconnectivity-interfaces-1.0.0.tgz` instead of `iconnectivity-interfaces-1.0.0.tgz` in the repository root.
- `yarn build`, `yarn lint` and `yarn test` (which builds first) stop at once on any Node version other than 22.20 or a later 22.x, for example Node 24 or Node 22.14: "This project requires Node 22.20.x; found v24.13.0". They also stop when they aren't run by Yarn 4. The template builds wherever its `engines` field allows.
- The `prebuild` script never runs, because Yarn 4 doesn't run `pre*` hooks for scripts.

**Why it happens:** The scripts were adapted for the owner's own release workflow. `--output pkg/...` tells `companion-module-build` where to write the package instead of its default `<id>-<version>.tgz` in the root, and `build` and `lint` start with `yarn check:runtime`, a version gate the template doesn't have.

**Evidence:**

```json
// package.json:10 and 13-19 (module)
		"package": "yarn build && companion-module-build --output pkg/iconnectivity-interfaces-$npm_package_version",
		"prebuild": "yarn check:runtime",
		"build": "yarn check:runtime && rimraf dist && run build:main",
		"build:main": "tsc -p tsconfig.build.json",
		"dev": "tsc -p tsconfig.build.json --watch",
		"lint:raw": "eslint",
		"lint": "yarn check:runtime && run lint:raw .",
		"test": "yarn build && node --test tests/*.test.mjs"
```

```json
// companion-module-template-ts-v2.0.4/package.json:9-10 and 14
		"package": "run build && companion-module-build",
		"build": "rimraf dist && run build:main",
		"lint": "run lint:raw ."
```

```js
// scripts/check-runtime.mjs:1-16
const requiredMajor = 22
const requiredMinor = 20
const [major, minor] = process.versions.node.split('.').map(Number)

if (major !== requiredMajor || minor < requiredMinor) {
	throw new Error(
		`This project requires Node ${requiredMajor}.${requiredMinor}.x; found ${process.version}. ...`,
	)
}

const userAgent = process.env.npm_config_user_agent ?? ''
if (!userAgent.startsWith('yarn/4.')) {
	throw new Error(
		`This project requires Yarn 4; found ${userAgent || 'an unknown package manager'}. Run it with Corepack.`,
	)
}
```

**Confirm by:** compare lines 10, 14 and 18 of [`package.json`](https://github.com/bitfocus/companion-module-iconnectivity-interfaces/blob/15315280e28cde4542c7e7acd8076155dc5ffd35/package.json#L10-L18) with lines 9, 10 and 14 of the template's `package.json`: the module adds `--output pkg/...`, uses `yarn build` instead of `run build`, and adds `yarn check:runtime &&` to `build` and `lint`.

**Fix:** Use the template's commands and delete `prebuild`. Extra scripts are fine, so the release-specific steps can stay as their own scripts:

```json
"package": "run build && companion-module-build",
"build": "rimraf dist && run build:main",
"lint": "run lint:raw .",
"check:runtime": "node scripts/check-runtime.mjs",
"package:release": "run check:runtime && run build && companion-module-build --output pkg/iconnectivity-interfaces-$npm_package_version"
```

If you add `package:release`, point the release workflow ([`.github/workflows/release.yaml:83`](https://github.com/bitfocus/companion-module-iconnectivity-interfaces/blob/15315280e28cde4542c7e7acd8076155dc5ffd35/.github/workflows/release.yaml#L83)) and [`scripts/verify-package.mjs:8`](https://github.com/bitfocus/companion-module-iconnectivity-interfaces/blob/15315280e28cde4542c7e7acd8076155dc5ffd35/scripts/verify-package.mjs#L8) at it, since both expect the package in `pkg/`.

### H2: The package.json name doesn't match the module id

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`package.json:2`](https://github.com/bitfocus/companion-module-iconnectivity-interfaces/blob/15315280e28cde4542c7e7acd8076155dc5ffd35/package.json#L2)

**What goes wrong:** Users see no difference. The package is called `iconnectivity` while the module id is `iconnectivity-interfaces` ([`companion/manifest.json:4`](https://github.com/bitfocus/companion-module-iconnectivity-interfaces/blob/15315280e28cde4542c7e7acd8076155dc5ffd35/companion/manifest.json#L4)), which makes the module harder to match up across tools and logs.

**Why it happens:** The name is left over from before the repository was renamed; the template uses the module id as the package name.

**Evidence:**

```json
// package.json:2
	"name": "iconnectivity",
// companion/manifest.json:4
	"id": "iconnectivity-interfaces",
```

**Confirm by:** compare [`package.json:2`](https://github.com/bitfocus/companion-module-iconnectivity-interfaces/blob/15315280e28cde4542c7e7acd8076155dc5ffd35/package.json#L2) with [`companion/manifest.json:4`](https://github.com/bitfocus/companion-module-iconnectivity-interfaces/blob/15315280e28cde4542c7e7acd8076155dc5ffd35/companion/manifest.json#L4).

**Fix:** Set `"name": "iconnectivity-interfaces"`.

### H3: The README sends users to personal GitHub builds instead of the module list

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`README.md:5-9`](https://github.com/bitfocus/companion-module-iconnectivity-interfaces/blob/15315280e28cde4542c7e7acd8076155dc5ffd35/README.md#L5-L9)

**What goes wrong:** Once the module is in Companion's module list, the README still tells users to download a `.tgz` from the owner's personal repository and import it by hand. Those builds get their own version numbers, so a bug report quoting "1.0.3" may not match the released 1.0.3.

**Why it happens:** The section was written for the period before the module was submitted.

**Evidence:**

```markdown
<!-- README.md:5-9 -->
## ⬇️ Download the latest version

**[Get the latest version here](https://github.com/mikecreates86/companion-module-iconnectivity-interfaces/releases/latest)**: open the link, and under **Assets** click the file ending in **`.tgz`**. Then, in Companion, go to the **Modules** page and import that file.

It always holds the newest work, with a higher version number every time, so Companion will accept it. Each release says which version is trusted for live use (also recorded in `STATUS.md`).
```

**Confirm by:** open [`README.md:5-9`](https://github.com/bitfocus/companion-module-iconnectivity-interfaces/blob/15315280e28cde4542c7e7acd8076155dc5ffd35/README.md#L5-L9): the first section points at the `mikecreates86` releases page, not at Companion's module list.

**Fix:** Make Companion's module list the main install path, and label the GitHub builds as optional test builds.

## 🟡 Medium

### M1: Saving the settings leaves the connection failed when Companion uses a fixed RTP port

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/network/apple-midi.ts:274-287`](https://github.com/bitfocus/companion-module-iconnectivity-interfaces/blob/15315280e28cde4542c7e7acd8076155dc5ffd35/src/network/apple-midi.ts#L274-L287), [`src/network/apple-midi.ts:425-430`](https://github.com/bitfocus/companion-module-iconnectivity-interfaces/blob/15315280e28cde4542c7e7acd8076155dc5ffd35/src/network/apple-midi.ts#L425-L430), [`src/main.ts:417-431`](https://github.com/bitfocus/companion-module-iconnectivity-interfaces/blob/15315280e28cde4542c7e7acd8076155dc5ffd35/src/main.ts#L417-L431)

**What goes wrong:** A user sets **RTP Role** to "Responder (experimental)" with **Companion RTP Port** 5060. The connection is OK. They change something unrelated, for example **Preset recall Channel** from 1 to 2, and save. The connection turns to Connection Failure with "Error: bind EADDRINUSE 0.0.0.0:5060" and stays there: no MIDI goes in or out and **Recall preset** fails until they save again or disable and re-enable the connection. The same happens in the Initiator role when **Initiator local RTP-MIDI control port** is set. The default (local port 0) isn't affected. Reproduced on loopback with the module's own test peer.

**Why it happens:** When the session is connected, closing it sends an end-session packet and only closes each UDP socket once that send has finished. The new session binds the same port straight away, before the old sockets are closed, so the bind fails and nothing retries.

**Fix:** Make `AppleMidiSession.close()` return a promise that resolves when both sockets have emitted `'close'`, and await it in `connect()` before opening the new session.

### M2: The preset name variable keeps the previous preset's name after Recall preset

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:983-985`](https://github.com/bitfocus/companion-module-iconnectivity-interfaces/blob/15315280e28cde4542c7e7acd8076155dc5ffd35/src/main.ts#L983-L985)

**What goes wrong:** On a mioXL, `$(<label>:current_preset)` is 2 and `$(<label>:current_preset_name)` is "Verse". After **Recall preset** 3, a button showing both reads "3" and "Verse".

**Why it happens:** On a mioXL, in the Responder role, or with **Device status connection** set to "Configuration port (compatibility)", a recall updates the preset number but not its name; only the default RTP monitoring branch clears the name ([`src/main.ts:980`](https://github.com/bitfocus/companion-module-iconnectivity-interfaces/blob/15315280e28cde4542c7e7acd8076155dc5ffd35/src/main.ts#L980)).

**Fix:** In the `else` branch, set `this.state.currentPresetName = ''` so the name falls back to "Preset 3", and re-read the name when a configuration session is open.

### M3: Users who switch Type to an expression have to type protocol numbers

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:79-91`](https://github.com/bitfocus/companion-module-iconnectivity-interfaces/blob/15315280e28cde4542c7e7acd8076155dc5ffd35/src/actions.ts#L79-L91), [`src/actions.ts:99-111`](https://github.com/bitfocus/companion-module-iconnectivity-interfaces/blob/15315280e28cde4542c7e7acd8076155dc5ffd35/src/actions.ts#L99-L111)

**What goes wrong:** A PlayAUDIO12 user who switches **Type** to an expression in **Legacy/configuration: Apply snapshot or scene** (or **…list position**) has to enter `127` for Scene or `1` for MIDI patchbay, with nothing telling them which number means what.

**Why it happens:** The choice ids are the protocol numbers `1`, `2`, `3`, `4` and `127`. API 2.0 recommends readable string ids, because users type them in expression mode.

**Fix:** Use string ids (`'midi_patchbay'`, `'audio_patchbay'`, `'audio_control'`, `'mixer_control'`, `'scene'`) and map them to the numbers in the callback. As this is the first release, no upgrade script is needed.

## 🟢 Low

### L1: Two log lines every 3 seconds when live monitoring can't be registered

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:653-655`](https://github.com/bitfocus/companion-module-iconnectivity-interfaces/blob/15315280e28cde4542c7e7acd8076155dc5ffd35/src/main.ts#L653-L655), [`src/main.ts:1154-1162`](https://github.com/bitfocus/companion-module-iconnectivity-interfaces/blob/15315280e28cde4542c7e7acd8076155dc5ffd35/src/main.ts#L1154-L1162)

**What goes wrong:** In the default RTP monitoring mode, when the interface doesn't support, rejects or doesn't answer the live notification registration, the log gets "Regular RTP: status reads succeeded; live monitoring disabled" plus a warning every 3 seconds, about 57,000 lines a day.

**Why it happens:** The 3-second status re-read logs the outcome and retries the registration on every cycle.

**Fix:** Log only when the monitoring state changes, and stop retrying after a definite rejection.

### L2: Every incoming RTP-MIDI packet republishes every variable

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/network/apple-midi.ts:380-384`](https://github.com/bitfocus/companion-module-iconnectivity-interfaces/blob/15315280e28cde4542c7e7acd8076155dc5ffd35/src/network/apple-midi.ts#L380-L384), [`src/main.ts:405-406`](https://github.com/bitfocus/companion-module-iconnectivity-interfaces/blob/15315280e28cde4542c7e7acd8076155dc5ffd35/src/main.ts#L405-L406)

**What goes wrong:** With MIDI Clock at 120 BPM coming from the interface, the module sends Companion about 50 variable updates a second (about 1,800 values), whether **Receive/analyze MIDI Clock** is on or off. That defeats the module's own 250 ms clock throttle and the tooltip's advice to turn clock analysis off.

**Why it happens:** The RTP session reports its status after every data packet, and the handler republishes all 36 or more variables each time.

**Fix:** In the status handler, publish only the RTP diagnostic variables, or throttle the full publish (for example to once every 250 ms).

### L3: On a PlayAUDIO12, Apply snapshot or scene with Type Scene and ID 1 or 2 fails with the default settings

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:1204-1207`](https://github.com/bitfocus/companion-module-iconnectivity-interfaces/blob/15315280e28cde4542c7e7acd8076155dc5ffd35/src/main.ts#L1204-L1207)

**What goes wrong:** On a PlayAUDIO12, **Legacy/configuration: Apply snapshot or scene** with Type Scene and ID 1 or 2 fails with "Configure a PlayAUDIO Scene A/B MIDI channel in connection settings", because **PlayAUDIO Scene A/B channel (optional)** defaults to "Disabled / Not used". ID 3 works. With a channel set, ID 1 sends a Program Change instead of the configuration command.

**Why it happens:** The action turns Scene 1 and 2 into a Scene A/B recall, a workaround meant for TNG interfaces. But the action is only offered for legacy interfaces ([`src/actions.ts:74`](https://github.com/bitfocus/companion-module-iconnectivity-interfaces/blob/15315280e28cde4542c7e7acd8076155dc5ffd35/src/actions.ts#L74)), so the workaround only ever runs on the PlayAUDIO12, which doesn't need it.

**Fix:** Limit the translation to TNG interfaces (`&& this.state.profile.protocol === 'tng'`), or remove it.

### L4: On a Linux host without working ALSA MIDI, the module can't start even for RTP-MIDI

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/midi.ts:1-15`](https://github.com/bitfocus/companion-module-iconnectivity-interfaces/blob/15315280e28cde4542c7e7acd8076155dc5ffd35/src/midi.ts#L1-L15)

**What goes wrong:** On a Linux Companion host without the ALSA library, the module fails to start, and on one without an ALSA sequencer (for example a Docker container without `/dev/snd`) the connection's settings can't be opened ([A1](#-assumptions-to-confirm)). Both happen even when the user only wants RTP-MIDI over the network.

**Why it happens:** `@julusian/midi` is imported at the top of the module, and its main entry checks the native library when it loads. The USB port lists are built while the settings fields are created, and that throws when no sequencer is available.

**Fix:** Import from `@julusian/midi/lazy`, and wrap `listInputs()` and `listOutputs()` in `try`/`catch`, returning an empty list on failure.

### L5: Over USB, Refresh device state never reads the current preset or Scene

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:586-589`](https://github.com/bitfocus/companion-module-iconnectivity-interfaces/blob/15315280e28cde4542c7e7acd8076155dc5ffd35/src/main.ts#L586-L589)

**What goes wrong:** With **Connection type** "USB MIDI" and a mioXM, PlayAUDIO1U or mioXL, `current_preset` and `current_scene` stay "Unknown" at startup and after **Refresh device state**, although the action's description says it re-reads them.

**Why it happens:** The initial state read returns early when there is no configuration session and RTP monitoring is off, which is always the case over USB, although the same reads could be sent over USB.

**Fix:** Allow the reads when the USB transport is open.

### L6: The upgrade script resets a custom discovery port to 5002

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/upgrades.ts:31`](https://github.com/bitfocus/companion-module-iconnectivity-interfaces/blob/15315280e28cde4542c7e7acd8076155dc5ffd35/src/upgrades.ts#L31)

**What goes wrong:** Only connections made with the owner's earlier test builds are affected. If such a connection has **Device discovery/configuration port** set to, say, 6002 and lacks one of the newer fields, the upgrade sets the port back to 5002 and the module can no longer find the interface.

**Why it happens:** The upgrade writes `configRemotePort: 5002` instead of keeping the existing value.

**Fix:** Use `configRemotePort: config.configRemotePort || 5002`.

### L7: Action and feedback definitions are passed to Companion with as never

- **Source:** 🔎 compliance reviewer, QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:297`](https://github.com/bitfocus/companion-module-iconnectivity-interfaces/blob/15315280e28cde4542c7e7acd8076155dc5ffd35/src/actions.ts#L297), [`src/feedbacks.ts:146`](https://github.com/bitfocus/companion-module-iconnectivity-interfaces/blob/15315280e28cde4542c7e7acd8076155dc5ffd35/src/feedbacks.ts#L146)

**What goes wrong:** Users see no difference; this is code quality only. The `as never` cast turns off the compiler's check of the definitions against the module's schema, so a later mismatch would compile without an error.

**Why it happens:** The definitions are typed with `Partial<…>`, which needs a cast. Base 2.0.4 already accepts `undefined` for a definition that isn't offered.

**Fix:** Drop `Partial` and `as never`, and set unsupported keys to `undefined` (for example `failover_arm: supportsFailover ? {…} : undefined`).

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | RtMidi fails to initialise on a Linux host without libasound or an ALSA sequencer, and Companion shows a failing `getConfigFields()` as a settings panel that won't open | `@julusian/midi`'s own comments and RtMidi's driver-error path; not tested on such a host, and Companion's handling of the error not checked | [L4](#l4-on-a-linux-host-without-working-alsa-midi-the-module-cant-start-even-for-rtp-midi) |
