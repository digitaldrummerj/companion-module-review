# Review: mutedeck-mutedeck v2.0.0

| Field | Value |
| --- | --- |
| **Module** | `companion-module-mutedeck-mutedeck` |
| **Scope** | `tag` (changes since v1.0.1) |
| **Version** | v2.0.0 (`af3a210`) |
| **Release** | Update — last published v1.0.1 |
| **API** | 2.0 (base 2.0.4, yarn.lock) — requires Companion 4.3+ |
| **Template** | `companion-module-template-js-v2.0.4` @ `e4caa76` (2026-08-28, pinned) · `.yarnrc.yml` from `companion-module-template-js` @ `76d25b2` (2026-10-11) |
| **Build** | `yarn install --immutable` + `yarn package` passed |
| **Reviewed** | 2026-10-30 |

## Verdict: ❌ Changes Required

## 📋 Issues

### Blocking

- [ ] [C1: Line-ending rules file `.gitattributes` is missing](#c1-line-ending-rules-file-gitattributes-is-missing)
- [ ] [C2: `.gitignore` does not ignore `package-lock.json`](#c2-gitignore-does-not-ignore-package-lockjson)
- [ ] [C3: `.prettierignore` replaces the template entries instead of keeping them](#c3-prettierignore-replaces-the-template-entries-instead-of-keeping-them)
- [ ] [C4: `.yarnrc.yml` pre-approves `@mutedeck/*` packages, skipping the 3-day age gate](#c4-yarnrcyml-pre-approves-mutedeck-packages-skipping-the-3-day-age-gate)

### Non-blocking

- [ ] [L1: The MuteDeck status button says Offline while MuteDeck waits for the user to click Allow](#l1-the-mutedeck-status-button-says-offline-while-mutedeck-waits-for-the-user-to-click-allow)
- [ ] [L2: Help page says screen share turns the button green, but it now turns it red](#l2-help-page-says-screen-share-turns-the-button-green-but-it-now-turns-it-red)
- [ ] [N1: Existing live-icon buttons change colour after the upgrade, with no option to keep the old look](#n1-existing-live-icon-buttons-change-colour-after-the-upgrade-with-no-option-to-keep-the-old-look)

## 🔴 Critical

### C1: Line-ending rules file `.gitattributes` is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.gitattributes` (missing)

**What goes wrong:** Without the template's `.gitattributes`, Git doesn't normalise line endings. A contributor on Windows can commit CRLF line endings, which shows up as whole-file diffs and can break formatting checks.

**Why it happens:** Every module built from the template is expected to ship the template's `.gitattributes`. This repository has none.

**Evidence:** template `companion-module-template-js-v2.0.4/.gitattributes` contains:

```text
* text=auto eol=lf
```

The module has no `.gitattributes` file.

**Fix:** copy the template's `.gitattributes` into the repository root.

### C2: `.gitignore` does not ignore `package-lock.json`

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.gitignore:1-10`](https://github.com/bitfocus/companion-module-mutedeck-mutedeck/blob/af3a2104a01fcb515a29131a7838fc9cf3533177/.gitignore#L1-L10)

**What goes wrong:** If someone runs `npm install` in this Yarn project, the generated `package-lock.json` can be committed by accident, leaving two lock files that disagree about dependency versions.

**Why it happens:** The template's `.gitignore` lists `package-lock.json`; this module's `.gitignore` is missing that line. The module's extra entries (`.DS_Store`, `*.log`, `streamdeck-plugin-nodejs/`) are fine. Only the missing line is the problem.

**Evidence:** template entries vs module:

```text
template: node_modules/  package-lock.json  /pkg  /*.tgz  DEBUG-*  /.yarn
module:   node_modules/  /pkg  /*.tgz  DEBUG-*  /.yarn  .DS_Store  *.log  streamdeck-plugin-nodejs/
```

**Fix:** add `package-lock.json` to `.gitignore`.

```text
package-lock.json
```

### C3: `.prettierignore` replaces the template entries instead of keeping them

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.prettierignore:1-4`](https://github.com/bitfocus/companion-module-mutedeck-mutedeck/blob/af3a2104a01fcb515a29131a7838fc9cf3533177/.prettierignore#L1-L4)

**What goes wrong:** Running the formatter rewrites `package.json` and `LICENSE.md`, which the template deliberately leaves alone, so formatting runs produce unrelated changes to those files.

**Why it happens:** The template's `.prettierignore` lists `package.json` and `/LICENSE.md`. The module's file has different entries (`node_modules/`, `pkg/`, `*.tgz`, `streamdeck-plugin-nodejs/`) and neither template entry. Adding extra entries for generated files is fine; dropping the template's entries is not.

**Evidence:** validator reports a difference at line 1 (found `node_modules/`, template `package.json`).

```text
template: package.json  /LICENSE.md
module:   node_modules/  pkg/  *.tgz  streamdeck-plugin-nodejs/
```

**Fix:** restore the two template entries; the module's extra entries can stay below them.

```text
package.json
/LICENSE.md
```

### C4: `.yarnrc.yml` pre-approves `@mutedeck/*` packages, skipping the 3-day age gate

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.yarnrc.yml:4-7`](https://github.com/bitfocus/companion-module-mutedeck-mutedeck/blob/af3a2104a01fcb515a29131a7838fc9cf3533177/.yarnrc.yml#L4-L7)

**What goes wrong:** The template makes Yarn refuse any package version published less than 3 days ago (`npmMinimalAgeGate: 3d`), which protects the build from a freshly compromised release. This release exempts every `@mutedeck/*` package, including the module's `@mutedeck/plugin-client` dependency, from that protection.

**Why it happens:** `npmPreapprovedPackages` lists the scopes that skip the age gate. The template allows only `@companion-module/*`; v2.0.0 adds `@mutedeck/*` with the comment "our own SDK, released together with this module".

**Evidence:** value mismatch: `npmPreapprovedPackages` = `[@companion-module/*, @mutedeck/*]` (template `[@companion-module/*]`).

```yaml
# .yarnrc.yml:4-7
npmPreapprovedPackages:
  - '@companion-module/*'
  # our own SDK, released together with this module
  - '@mutedeck/*'
```

**Fix:** remove the `@mutedeck/*` entry and its comment, so the file matches the template. Publish the SDK at least 3 days before tagging a module release that needs it.

```yaml
npmPreapprovedPackages:
  - "@companion-module/*"
```

## 🟢 Low

### L1: The MuteDeck status button says Offline while MuteDeck waits for the user to click Allow

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/variables.js:36`](https://github.com/bitfocus/companion-module-mutedeck-mutedeck/blob/af3a2104a01fcb515a29131a7838fc9cf3533177/src/variables.js#L36), [`src/presets.js:70-91`](https://github.com/bitfocus/companion-module-mutedeck-mutedeck/blob/af3a2104a01fcb515a29131a7838fc9cf3533177/src/presets.js#L70-L91)

**What goes wrong:** A user upgrades to v2.0.0 (or adds the connection for the first time) with a MuteDeck version that asks for approval. Until they click Allow in MuteDeck, the "MuteDeck status" preset button reads "MuteDeck Offline" on dark red, and `$(mutedeck:connected_label)` is "Offline". The same happens after they click Deny. The button suggests MuteDeck isn't running, when the real fix is to click Allow. The connection status on the Connections page is correct ("Waiting for approval: click Allow in MuteDeck"), but the button that the help page recommends as the at-a-glance indicator is not.

**Why it happens:** The module now treats itself as connected only once MuteDeck has approved it (or it talks to an older MuteDeck that doesn't ask), see `onConnectionChange(this.client.isReady, state)` in [`src/api.js:114`](https://github.com/bitfocus/companion-module-mutedeck-mutedeck/blob/af3a2104a01fcb515a29131a7838fc9cf3533177/src/api.js#L114). The "Connection label" variable still only knows "Connected" and "Offline", and the status preset was not updated for the new "waiting for approval" and "denied" states.

**Fix:** show the approval state on the status preset, e.g. use `$(mutedeck:auth_state_label)` (which already says "Waiting for approval" / "Denied" / "Approved") in the preset text, or have `connected_label` return `AUTH_STATE_LABELS[s.auth]` while `s.auth` is `pending` or `denied`. Optionally add the approval-state feedback (pending) to the preset so the button turns amber while approval is pending.

### L2: Help page says screen share turns the button green, but it now turns it red

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`companion/HELP.md:14`](https://github.com/bitfocus/companion-module-mutedeck-mutedeck/blob/af3a2104a01fcb515a29131a7838fc9cf3533177/companion/HELP.md#L14)

**What goes wrong:** The help page says the preset buttons are "red when muted or recording, green when your camera or screen share is on". In v2.0.0 the Screen share live icon is red while sharing and blue while not sharing; the Camera icon is red when the camera is off, the Microphone icon is green when unmuted, and the Recording icon is blue when not recording. A user who reads the help sees a red share button and may think something is wrong.

**Why it happens:** This release changed the live-icon colours in [`src/feedbacks.js:75-118`](https://github.com/bitfocus/companion-module-mutedeck-mutedeck/blob/af3a2104a01fcb515a29131a7838fc9cf3533177/src/feedbacks.js#L75-L118) (share-on from green to red, and new colours for the "off" states), but the sentence in the help page that describes the colours was not updated.

**Fix:** update the sentence to match the new colours, e.g. "red when muted, recording, sharing your screen or with the camera off; green when unmuted or the camera is on".

## 💡 Nice to Have

### N1: Existing live-icon buttons change colour after the upgrade, with no option to keep the old look

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.js:75-118`](https://github.com/bitfocus/companion-module-mutedeck-mutedeck/blob/af3a2104a01fcb515a29131a7838fc9cf3533177/src/feedbacks.js#L75-L118)

**What goes wrong:** Users with Microphone / Camera / Screen share / Recording live-icon buttons from v1.0.1 see new colours as soon as they upgrade: an unmuted mic goes from black to green, camera off from black to red, share on from green to red, and share off and recording off from black to blue. The live icons set the whole button style, so users can't override the colours on the button. Nothing is broken, but the change is visible on every existing page.

**Why it happens:** The live-icon feedbacks return fixed background colours, and v2.0.0 changed the "off" colours and the share-on colour.

**Fix:** mention the colour change in the release notes and the help page. Optionally, add colour options to the live-icon feedbacks so users can keep the v1 colours.
