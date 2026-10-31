# Review: companion-module-sonifex-avn-m8r v0.1.1

| | |
| --- | --- |
| **Module** | `companion-module-sonifex-avn-m8r` |
| **Scope** | `tag` (first release: there is no previous tag, so the whole module was reviewed) |
| **Version** | v0.1.1 |
| **Release** | New module — never published |
| **API** | 2.1 (base 2.1.3, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-js` @ `76d25b2` (2026-10-11) |
| **Commit** | [`5c2fa0d`](https://github.com/bitfocus/companion-module-sonifex-avn-m8r/tree/5c2fa0d52fa8a27130449dbedd07da7d609a9772) |
| **Date** | 2026-10-30 |

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | The AVN-M8R normally confirms Ember+ writes quickly, so an action that ignores an abort is rarely noticeable | Typical Ember+ provider behaviour; the device was not tested | [L3](#l3-aborting-a-button-does-not-stop-an-action-that-is-waiting-for-the-device-to-confirm-a-change) |

## 📋 Issues

### Blocking

- [ ] [C1: Yarn config differs from the template: extra approvedGitRepositories entry](#c1-yarn-config-differs-from-the-template-extra-approvedgitrepositories-entry)
- [ ] [C2: The module still targets Node 22, but the API 2.1 template runs on Node 26](#c2-the-module-still-targets-node-22-but-the-api-21-template-runs-on-node-26)

### Non-blocking

- [ ] [M1: The release workflow file is missing](#m1-the-release-workflow-file-is-missing)
- [ ] [M2: In expression mode, Input 1 has to be entered as 0, so a value of 1 controls Input 2](#m2-in-expression-mode-input-1-has-to-be-entered-as-0-so-a-value-of-1-controls-input-2)
- [ ] [L1: Ember+ Parameter feedback for Full Scale Level only matches the raw number, not the dBu text](#l1-ember-parameter-feedback-for-full-scale-level-only-matches-the-raw-number-not-the-dbu-text)
- [ ] [L2: On, Off and Toggle dropdowns offer an expression mode with no clear use](#l2-on-off-and-toggle-dropdowns-offer-an-expression-mode-with-no-clear-use)
- [ ] [L3: Aborting a button does not stop an action that is waiting for the device to confirm a change](#l3-aborting-a-button-does-not-stop-an-action-that-is-waiting-for-the-device-to-confirm-a-change)
- [ ] [L4: The manifest hard-codes the API version instead of the template's 0.0.0](#l4-the-manifest-hard-codes-the-api-version-instead-of-the-templates-000)
- [ ] [N1: The first press of the Mic or Line mode preset may change nothing](#n1-the-first-press-of-the-mic-or-line-mode-preset-may-change-nothing)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🔴 Critical

### C1: Yarn config differs from the template: extra approvedGitRepositories entry

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.yarnrc.yml:6-7`](https://github.com/bitfocus/companion-module-sonifex-avn-m8r/blob/5c2fa0d52fa8a27130449dbedd07da7d609a9772/.yarnrc.yml#L6-L7)

**What goes wrong:** The module's Yarn config allows Yarn to install a package straight from a GitHub repository. Every other module uses the template's Yarn config, which only installs packages from the npm registry. A config that differs from the template makes builds harder to reason about and to troubleshoot.

**Why it happens:** The Ember+ library the module uses, `emberplus-connection@^0.3.1` ([`package.json:20`](https://github.com/bitfocus/companion-module-sonifex-avn-m8r/blob/5c2fa0d52fa8a27130449dbedd07da7d609a9772/package.json#L20)), depends on `asn1` from the GitHub repository `evs-broadcast/node-asn1` rather than from npm (`yarn.lock:310-312`, `362`). Yarn 4 refuses to install a git dependency unless it is approved, so the maintainer added the `approvedGitRepositories` key.

**Evidence:**

```yaml
# .yarnrc.yml:6-7 (module)
approvedGitRepositories:
  - 'https://github.com/evs-broadcast/node-asn1.git'
```

```yaml
# companion-module-template-js/.yarnrc.yml (template)
enableScripts: false
nodeLinker: node-modules
npmMinimalAgeGate: 3d
npmPreapprovedPackages:
  - "@companion-module/*"
```

**Confirm by:** compare [`.yarnrc.yml`](https://github.com/bitfocus/companion-module-sonifex-avn-m8r/blob/5c2fa0d52fa8a27130449dbedd07da7d609a9772/.yarnrc.yml) with the template's `.yarnrc.yml`.

**Fix:** remove the dependency on the git package rather than just deleting the key, because deleting the key alone makes `yarn install` fail. Check whether a newer `emberplus-connection` release depends on an npm-published `asn1`, and upgrade to it if so. If no release does, please ask in the review thread how Bitfocus wants this git dependency handled.

### C2: The module still targets Node 22, but the API 2.1 template runs on Node 26

- **Source:** 🤖 validate-template (NODE-VERSION)
- **Classification:** 🆕 NEW
- **File:** [`companion/manifest.json:18`](https://github.com/bitfocus/companion-module-sonifex-avn-m8r/blob/5c2fa0d52fa8a27130449dbedd07da7d609a9772/companion/manifest.json#L18), [`package.json:15`](https://github.com/bitfocus/companion-module-sonifex-avn-m8r/blob/5c2fa0d52fa8a27130449dbedd07da7d609a9772/package.json#L15)

**What goes wrong:** Companion starts the module on Node 22, but API 2.1 modules are expected to match the API 2.1 template, which uses Node 26 in every place the Node version is named. The other places listed below still name another Node version too, so the module would run, type-check and build in CI on different Node versions even after the runtime is fixed. A module that does not match its template makes later troubleshooting harder: when something misbehaves, people look for the cause in the module instead of in the mismatched setup.

**Why it happens:** Moving a module to another Node version means changing every place the version is named: the manifest runtime, `engines.node`, `@types/node`, the TypeScript preset and the CI workflows. These places still name a different Node version than the API 2.1 template.

**Evidence:**

```text
companion/manifest.json runtime.type 'node22' -> 'node26'
package.json engines.node '^22.20' -> '^26'
```

**Confirm by:** open each file above and compare it with the template's copy.

**Fix:** update every place to Node 26, as the template does:

- [ ] [`companion/manifest.json:18`](https://github.com/bitfocus/companion-module-sonifex-avn-m8r/blob/5c2fa0d52fa8a27130449dbedd07da7d609a9772/companion/manifest.json#L18): `"type": "node26"` in `runtime`
- [ ] [`package.json:15`](https://github.com/bitfocus/companion-module-sonifex-avn-m8r/blob/5c2fa0d52fa8a27130449dbedd07da7d609a9772/package.json#L15): `"engines": { "node": "^26" }`

## 🟡 Medium

### M1: The release workflow file is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.github/workflows/release.yaml` (missing)

**What goes wrong:** The template ships a release workflow, `.github/workflows/release.yaml`, but the module's `.github/workflows/` folder only has `companion-module-checks.yaml`.

**Why it happens:** The file was not copied from the template.

**Fix:** copy `release.yaml` from `companion-module-template-js` into `.github/workflows/`.

### M2: In expression mode, Input 1 has to be entered as 0, so a value of 1 controls Input 2

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.js:3-12`](https://github.com/bitfocus/companion-module-sonifex-avn-m8r/blob/5c2fa0d52fa8a27130449dbedd07da7d609a9772/src/actions.js#L3-L12), [`src/actions.js:24-30`](https://github.com/bitfocus/companion-module-sonifex-avn-m8r/blob/5c2fa0d52fa8a27130449dbedd07da7d609a9772/src/actions.js#L24-L30), [`src/actions.js:183-189`](https://github.com/bitfocus/companion-module-sonifex-avn-m8r/blob/5c2fa0d52fa8a27130449dbedd07da7d609a9772/src/actions.js#L183-L189)

**What goes wrong:** Companion 5 lets a user switch any dropdown to expression mode, for example to pick the input from a variable. The **Input** dropdown on every action (Set Input Mute, Set Phantom Power, Set Preamp Gain and the rest) and every feedback (Input Mute, Ember+ Parameter, Input Meter Level) stores 0 to 7 for the entries labelled Input 1 to Input 8. A user who enters `1`, or a variable that holds 1, to mean "Input 1" changes Input 2 instead, with no warning. The same applies to **Set Full Scale Level**, where 0 to 4 stand for +15/+18/+20/+22/+24 dBu, and to the On/Off/Toggle choices (0/1/2). Users who only pick from the dropdown are not affected.

**Why it happens:** The dropdown choice ids are 0-based indexes instead of the values the labels show, and in expression mode Companion uses the raw id.

**Fix:** this is the first release, so the ids can still change without an upgrade script. Use ids that match the labels: inputs 1 to 8 (subtract 1 in the callbacks, and use 1 to 8 in [`src/feedbacks.js:3-12`](https://github.com/bitfocus/companion-module-sonifex-avn-m8r/blob/5c2fa0d52fa8a27130449dbedd07da7d609a9772/src/feedbacks.js#L3-L12), the meter choices and `src/presets.js`), strings such as `'mic'`/`'line'` and `'on'`/`'off'`/`'toggle'`, and full-scale ids such as 15/18/20/22/24. Optionally add an `expressionDescription` that lists the accepted values.

## 🟢 Low

### L1: Ember+ Parameter feedback for Full Scale Level only matches the raw number, not the dBu text

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.js:15-25`](https://github.com/bitfocus/companion-module-sonifex-avn-m8r/blob/5c2fa0d52fa8a27130449dbedd07da7d609a9772/src/feedbacks.js#L15-L25), [`src/feedbacks.js:86-99`](https://github.com/bitfocus/companion-module-sonifex-avn-m8r/blob/5c2fa0d52fa8a27130449dbedd07da7d609a9772/src/feedbacks.js#L86-L99)

**What goes wrong:** A user adds the **Ember+ Parameter** feedback, picks Parameter **Full Scale Level**, and types `+18 dBu` into **Value**, because the variable `$(sonifex-avn-m8r:input1_full_scale_level)` shows "+18 dBu". The feedback never turns on: it only matches the raw value `1`. **Signal Level** explains its numbers in its label (0 = Mic, 1 = Line), but Full Scale Level has no such hint. The **Learn** button fills in the right value, so there is a workaround.

**Why it happens:** The feedback compares the device's raw Ember+ value (an index) with the text the user typed. Only the variables translate the index into a dBu label.

**Fix:** offer a dropdown of the dBu labels (ids 0 to 4) for Full Scale Level, or add a separate Full Scale Level feedback. At minimum, change the parameter label to "Full Scale Level (0 = +15 dBu … 4 = +24 dBu)".

### L2: On, Off and Toggle dropdowns offer an expression mode with no clear use

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.js:14-18`](https://github.com/bitfocus/companion-module-sonifex-avn-m8r/blob/5c2fa0d52fa8a27130449dbedd07da7d609a9772/src/actions.js#L14-L18), [`src/actions.js:280-284`](https://github.com/bitfocus/companion-module-sonifex-avn-m8r/blob/5c2fa0d52fa8a27130449dbedd07da7d609a9772/src/actions.js#L280-L284), [`src/actions.js:300-305`](https://github.com/bitfocus/companion-module-sonifex-avn-m8r/blob/5c2fa0d52fa8a27130449dbedd07da7d609a9772/src/actions.js#L300-L305)

**What goes wrong:** The state dropdowns on Set Phantom Power, Set High-Pass Filter State, Set Input Mute and Set Status LEDs show the expression toggle. A user who uses it has to know that 0 = Off, 1 = On and 2 = Toggle. Users who leave the dropdown as it is are not affected; this is polish.

**Why it happens:** API 2.x makes every option expression-capable unless it sets `disableAutoExpression: true`.

**Fix:** add `disableAutoExpression: true` to these dropdowns, or, if expression use is wanted, use friendly string ids as described in [M2](#m2-in-expression-mode-input-1-has-to-be-entered-as-0-so-a-value-of-1-controls-input-2).

### L3: Aborting a button does not stop an action that is waiting for the device to confirm a change

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.js:32-38`](https://github.com/bitfocus/companion-module-sonifex-avn-m8r/blob/5c2fa0d52fa8a27130449dbedd07da7d609a9772/src/actions.js#L32-L38), [`src/ember.js:214-220`](https://github.com/bitfocus/companion-module-sonifex-avn-m8r/blob/5c2fa0d52fa8a27130449dbedd07da7d609a9772/src/ember.js#L214-L220)

**What goes wrong:** When a user aborts a running button (for example with Companion's abort action), an action that is still waiting for the device to confirm an Ember+ write keeps waiting. Ember+ writes are usually quick, so users are unlikely to notice.

**Why it happens:** On API 2.1, action callbacks receive an abort signal (`context.signal`). The write helper waits for the device's confirmation without checking it.

**Fix:** pass the callback's `context` through and stop once `context.signal.aborted` is true, for example by checking it before sending and racing the confirmation against the signal. This is optional.

### L4: The manifest hard-codes the API version instead of the template's 0.0.0

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`companion/manifest.json:20`](https://github.com/bitfocus/companion-module-sonifex-avn-m8r/blob/5c2fa0d52fa8a27130449dbedd07da7d609a9772/companion/manifest.json#L20)

**What goes wrong:** Users see no effect: the build writes the real version (2.1.3) into the packaged manifest anyway. But a hard-coded value goes stale and misleads anyone reading the source after `@companion-module/base` is upgraded.

**Why it happens:** The template ships `"apiVersion": "0.0.0"` and lets `companion-module-build` fill it in; the module sets `"2.1.3"` by hand.

**Fix:** set `runtime.apiVersion` back to `"0.0.0"`, as in the template.

## 💡 Nice to Have

### N1: The first press of the Mic or Line mode preset may change nothing

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/presets.js:77-94`](https://github.com/bitfocus/companion-module-sonifex-avn-m8r/blob/5c2fa0d52fa8a27130449dbedd07da7d609a9772/src/presets.js#L77-L94)

**What goes wrong:** The "Input 1 mic/line mode" preset always starts on its "Set Line" step. If Input 1 is already in Line mode, the first press sends Line again and nothing changes; only the second press switches to Mic. The step order also drifts from the device's state when the mode is changed elsewhere, for example on the unit's web page.

**Why it happens:** The preset uses two fixed steps instead of a toggle, because the Set Input Mode action has no Toggle choice (Set Phantom Power, Set High-Pass Filter State, Set Input Mute and Set Status LEDs all have one).

**Fix:** add a Toggle choice to Set Input Mode, using the existing `resolveBinaryState` with the input's current `line_mic` state, and give the preset a single toggle step.

## 📝 Additional Notes

- This is the module's first release, so there is no previous tag to diff against: the whole module was reviewed and every finding is classified 🆕 NEW.
