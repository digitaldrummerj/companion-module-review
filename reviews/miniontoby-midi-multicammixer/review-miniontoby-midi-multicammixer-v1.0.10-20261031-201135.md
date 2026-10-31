# Review: companion-module-miniontoby-midi-multicammixer v1.0.10

| | |
| --- | --- |
| **Module** | `companion-module-miniontoby-midi-multicammixer` |
| **Scope** | `tag` (v1.0.9..v1.0.10) |
| **Version** | v1.0.10 (commit `ffec0f9`) |
| **Release** | Update — last published v1.0.9 |
| **API** | 2.2 (base 2.2.2, yarn.lock) |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **API checks** | v2.0 + v2.1 rules (no v2.2 reference available yet) |
| **Reviewed** | 2026-10-31 |

## Verdict: ❌ Changes Required

## 📋 Issues

### Blocking

- [ ] [C1: Yarn runs every dependency's install scripts, which the template turns off](#c1-yarn-runs-every-dependencys-install-scripts-which-the-template-turns-off)

### Non-blocking

- [ ] [L1: A saved third or later duplicate MIDI Out port no longer opens after the upgrade](#l1-a-saved-third-or-later-duplicate-midi-out-port-no-longer-opens-after-the-upgrade)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🔴 Critical

### C1: Yarn runs every dependency's install scripts, which the template turns off

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW (the line itself is older than this release, but it does not match the current template)
- **File:** [`.yarnrc.yml:1`](https://github.com/bitfocus/companion-module-miniontoby-midi-multicammixer/blob/ffec0f9b64bc8d7f34085e2f43b0df8b2fa3b977/.yarnrc.yml#L1)

**What goes wrong:** Anyone who builds the module (Bitfocus's build pipeline, a contributor, you) lets every package in the dependency tree run its own install script during `yarn install`. The template switches that off as supply-chain protection: a compromised dependency could otherwise run code on the build machine.

**Why it happens:** `.yarnrc.yml` sets `enableScripts: true`. The template sets `enableScripts: false`. Every other key in the file already matches the template.

**Evidence:**

```yaml
# .yarnrc.yml:1 (module)
enableScripts: true
# .yarnrc.yml:1 (companion-module-template-ts)
enableScripts: false
```

**Confirm by:** compare [`.yarnrc.yml`](https://github.com/bitfocus/companion-module-miniontoby-midi-multicammixer/blob/ffec0f9b64bc8d7f34085e2f43b0df8b2fa3b977/.yarnrc.yml#L1) with the `companion-module-template-ts` `.yarnrc.yml`.

**Fix:** set `enableScripts` to `false`, as in the template. The native `@julusian/midi` package ships prebuilt binaries in its `prebuilds` folder (its install script only verifies them, with a `node-gyp` fallback), so it should still load with scripts off. Run `yarn install` and `yarn package` after the change to confirm.

```yaml
enableScripts: false
```

## 🟢 Low

### L1: A saved third or later duplicate MIDI Out port no longer opens after the upgrade

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer
- **Classification:** 🔙 REGRESSION
- **File:** [`src/midi/midi.ts:70-75`](https://github.com/bitfocus/companion-module-miniontoby-midi-multicammixer/blob/ffec0f9b64bc8d7f34085e2f43b0df8b2fa3b977/src/midi/midi.ts#L70-L75)

**What goes wrong:** This only affects users with three or more MIDI output ports that have exactly the same name, for example three loopMIDI ports all called "loopMIDI Port". In v1.0.9 the **MIDI Out** dropdown listed them as "loopMIDI Port", "loopMIDI Port 1" and "loopMIDI Port 1 2". In v1.0.10 they are "loopMIDI Port", "loopMIDI Port 1" and "loopMIDI Port 2". A user who had saved "loopMIDI Port 1 2" gets no open port after the upgrade: the connection shows Bad Config with "MIDI Out Port not open" until they open the connection settings and pick the port again. Users with one or two same-named ports are not affected, and the new naming is the correct one.

**Why it happens:** This release changed how duplicate port names are numbered. The old code appended each number to the previous name ("Name 1 2 3"); the new code uses the base name plus one number ("Name 2"). The saved port name is matched exactly against the new list when the port is opened ([`src/midi/midi.ts:12-18`](https://github.com/bitfocus/companion-module-miniontoby-midi-multicammixer/blob/ffec0f9b64bc8d7f34085e2f43b0df8b2fa3b977/src/midi/midi.ts#L12-L18)), and no upgrade script in [`src/upgrades.ts`](https://github.com/bitfocus/companion-module-miniontoby-midi-multicammixer/blob/ffec0f9b64bc8d7f34085e2f43b0df8b2fa3b977/src/upgrades.ts) maps an old name to the new one.

**Evidence:**

```diff
// src/midi/midi.ts:73 (v1.0.9 → v1.0.10)
-				numberedPortName += ` ${counter}`
+				numberedPortName = `${portName} ${counter}`
```

**Fix:** either say in the release notes that users with three or more ports of the same name must pick the **MIDI Out** port again, or add a config upgrade script that rewrites an old-style name ("loopMIDI Port 1 2", matching `^(.*?)( \d+)+$`) to the new form (the base name plus the last number, "loopMIDI Port 2").

## 📝 Additional Notes

- `tsconfig.build.json` differs from the template: it adds `compilerOptions.rootDir: "./src"` (line 6). The build passes, so no change is required.
