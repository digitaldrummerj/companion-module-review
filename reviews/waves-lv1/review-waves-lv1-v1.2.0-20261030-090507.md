# Review — waves-lv1 v1.2.0 (follow-up)

| | |
| --- | --- |
| **Module** | [companion-module-waves-lv1](https://github.com/bitfocus/companion-module-waves-lv1) |
| **Scope** | `tag` — changes in `v1.1.0..v1.2.0`, plus a check of the prior review's findings |
| **Version** | v1.2.0 (`7711f3a`) |
| **Release** | Update — last published v1.1.0 |
| **API** | 1 (base 1.12.1, yarn.lock) |
| **Template** | `companion-module-template-ts-v1` @ `42609d8` (2026-03-03, pinned) · `.yarnrc.yml` from `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Prior review** | [review-waves-lv1-v1.0.3-20260614-220418.md](review-waves-lv1-v1.0.3-20260614-220418.md) |
| **Reviewed** | 2026-10-30 |

This is a follow-up to the v1.0.3 review. v1.2.0 adds eMotion LV1 v17 support: Monitor buses, internal routing, stereo balance, and an experimental second "Companion I/O" connection that reads the I/O patch. `yarn install`, `yarn package` and `yarn lint` all pass. The four findings from the v1.0.3 review are still open; they are listed under [📝 Additional Notes](#-additional-notes).

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Companion does not redraw a connection's feedbacks when the module clears its internal state; only `checkFeedbacks()` (or possibly a later `setFeedbackDefinitions`) re-runs the feedback callbacks | How v1 feedback re-evaluation is generally triggered; not confirmed from the base package whether the host rechecks feedbacks after `setFeedbackDefinitions` | [L1](#l1-phantom-polarity-route-and-io-patch-buttons-can-keep-showing-the-previous-desks-state-after-switching-lv1) |
| A2 | When the LV1 restarts on a new TCP port after a mixer-configuration change, the old port stops accepting connections | The module's own comment on `rediscoverPort()` ("the LV1 restarts and gets a fresh port") | [L2](#l2-io-patch-variables-freeze-after-the-lv1-comes-back-on-a-new-port) |

## 📋 Issues

### Blocking

- [ ] [C1: `.prettierignore` differs from the template (`/LICENSE` instead of `/LICENSE.md`)](#c1-prettierignore-differs-from-the-template-license-instead-of-licensemd)
- [ ] [H1: `.github/workflows/companion-module-checks.yaml` differs from the template](#h1-githubworkflowscompanion-module-checksyaml-differs-from-the-template)
- [ ] [H2: `.github/workflows/node.yaml` differs from the template](#h2-githubworkflowsnodeyaml-differs-from-the-template)

### Non-blocking

- [ ] [L1: Phantom, polarity, route and I/O-patch buttons can keep showing the previous desk's state after switching LV1](#l1-phantom-polarity-route-and-io-patch-buttons-can-keep-showing-the-previous-desks-state-after-switching-lv1)
- [ ] [L2: I/O patch variables freeze after the LV1 comes back on a new port](#l2-io-patch-variables-freeze-after-the-lv1-comes-back-on-a-new-port)
- [ ] [L3: Console version from the previous LV1 is kept after pointing the connection at a different desk](#l3-console-version-from-the-previous-lv1-is-kept-after-pointing-the-connection-at-a-different-desk)
- [ ] [L4: Stereo balance variable shows 0.00 before the desk has reported a balance](#l4-stereo-balance-variable-shows-000-before-the-desk-has-reported-a-balance)
- [ ] [L5: New Internal route fields use the deprecated isVisible function](#l5-new-internal-route-fields-use-the-deprecated-isvisible-function)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🔴 Critical

### C1: `.prettierignore` differs from the template (`/LICENSE` instead of `/LICENSE.md`)

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW to this review — the file is unchanged since v1.0.0; the prior reviews did not check it
- **File:** [`.prettierignore:2`](https://github.com/bitfocus/companion-module-waves-lv1/blob/7711f3a5dec1971ecadd0e87c44b05d8a17f7274/.prettierignore#L2)

**What goes wrong:** The module's `.prettierignore` does not match the API 1 TypeScript template. Template files must match byte-for-byte so every module behaves the same in CI and when someone else troubleshoots it later.

**Why it happens:** Line 2 was changed from the template's `/LICENSE.md` to `/LICENSE`.

**Evidence:**

```diff
# diff companion-module-template-ts-v1/.prettierignore .prettierignore
2c2
< /LICENSE.md
---
> /LICENSE
```

**Confirm by:** `diff companion-module-template-ts-v1/.prettierignore .prettierignore`

**Fix:** copy the template's `.prettierignore` exactly.

## 🟠 High

### H1: `.github/workflows/companion-module-checks.yaml` differs from the template

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW to this review — the file is unchanged since v1.0.0; the prior reviews did not check it
- **File:** [`.github/workflows/companion-module-checks.yaml:9-10`](https://github.com/bitfocus/companion-module-waves-lv1/blob/7711f3a5dec1971ecadd0e87c44b05d8a17f7274/.github/workflows/companion-module-checks.yaml#L9-L10)

**What goes wrong:** The module's copy of the Companion module-check workflow does not match the template. Template files must match exactly, so CI behaves the same in every module repo.

**Why it happens:** The template's repository guard (template line 10) is removed, so the `check` job goes straight from `name: Check module` to `permissions:`.

**Evidence:**

```diff
# diff companion-module-template-ts-v1/.github/workflows/companion-module-checks.yaml .github/workflows/companion-module-checks.yaml
10,11d9
<     if: ${{ !contains(github.repository, 'companion-module-template-') }}
<
```

**Confirm by:** `diff companion-module-template-ts-v1/.github/workflows/companion-module-checks.yaml .github/workflows/companion-module-checks.yaml`

**Fix:** copy the template file exactly.

### H2: `.github/workflows/node.yaml` differs from the template

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW to this review — the file is unchanged since v1.0.0; the prior reviews did not check it
- **File:** [`.github/workflows/node.yaml:20-27`](https://github.com/bitfocus/companion-module-waves-lv1/blob/7711f3a5dec1971ecadd0e87c44b05d8a17f7274/.github/workflows/node.yaml#L20-L27)

**What goes wrong:** The module's Node CI workflow does not match the template, so its CI runs different steps than every other module built from the API 1 template.

**Why it happens:** Three parts were changed:

- Line 20 has a reworded comment ("This should match the version in the manifest.json runtime field").
- Lines 24-27 drop the template's "Prepare Environment (For template repository)" step (with `CI: false`) and rename its "Prepare module" step to a single `Install dependencies: yarn install` step; the `run: |` blocks are also collapsed to one-line `run:` commands.
- The template's commented-out `test:` job (template lines 52-76) is removed.

**Evidence:**

```text
.github/workflows/node.yaml:20  found:    # This should match the version in the manifest.json runtime field
                                template: # This should match the version of Node.js you have defined in the manifest.json runtime field
.github/workflows/node.yaml:24-27  "Install dependencies: yarn install" in place of the template's
                                   "Prepare Environment (For template repository)" and "Prepare module" steps
template lines 52-76               commented-out test: job, missing from the module
```

**Confirm by:** `diff companion-module-template-ts-v1/.github/workflows/node.yaml .github/workflows/node.yaml`

**Fix:** copy the template file exactly.

## 🟢 Low

### L1: Phantom, polarity, route and I/O-patch buttons can keep showing the previous desk's state after switching LV1

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:189-232`](https://github.com/bitfocus/companion-module-waves-lv1/blob/7711f3a5dec1971ecadd0e87c44b05d8a17f7274/src/main.ts#L189-L232)

**What goes wrong:** A button uses "Channel +48 V phantom ON" for Ch 3 and is lit while connected to LV1 A. The user edits the connection and picks LV1 B from the dropdown. The button can stay lit as "+48 V ON" for B's Ch 3, and "Channel +48 V state unknown" stays off. Phantom is only reported when it changes, so nothing from desk B corrects it. "Channel has an I/O patch (experimental)" can also stay lit if desk B never sends its I/O patch, and "Channel internally routed to destination" is not redrawn either (though desk B's channel list may correct it on connect). The module's own rule that unknown phantom "must render blank, never as off" is not kept across a host change.

**Why it happens:** When the host changes, the module wipes its stored channel, route and I/O-patch state, but it never asks Companion to re-check the feedbacks afterwards. The feedback definitions are refreshed earlier in `configUpdated()`, before the state is cleared.

**Fix:** after clearing state in the restart branch, redraw the feedbacks and blank the per-channel variables.

```ts
this.checkFeedbacks('routeAssigned', 'channelHasPatch', 'channelPolarity', 'channelPhantom', 'channelPhantomUnknown')
// or simply this.checkFeedbacks()
```

### L2: I/O patch variables freeze after the LV1 comes back on a new port

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:409-419`](https://github.com/bitfocus/companion-module-waves-lv1/blob/7711f3a5dec1971ecadd0e87c44b05d8a17f7274/src/main.ts#L409-L419)

**What goes wrong:** With "Read I/O patch" ticked, the user switches the LV1 mixer configuration (for example 64ch to 80ch), and the desk restarts on a new TCP port. The main connection finds the new port (the log shows "Rediscovered … on port … — reconnecting") and goes back to OK. The second "Companion I/O" connection keeps retrying the old port every 3 s, and its errors only go to the debug log. `$(waves-lv1:in1_patch)`, `$(waves-lv1:io_patch_connections)` and the "Channel has an I/O patch (experimental)" feedback keep their old values, and the connection status gives no sign of it, until the user saves the connection settings again.

**Why it happens:** The port re-discovery only moves the main connection to the new port. The I/O-patch connection was started with the original port and is never told about the new one.

**Fix:** move the I/O-patch connection along with the main one, and log its repeated failures at `warn`.

```ts
this.osc.updateTarget(this.lastHost, match.port)
this.ioOsc?.updateTarget(this.lastHost, match.port)
```

### L3: Console version from the previous LV1 is kept after pointing the connection at a different desk

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:201-233`](https://github.com/bitfocus/companion-module-waves-lv1/blob/7711f3a5dec1971ecadd0e87c44b05d8a17f7274/src/main.ts#L201-L233)

**What goes wrong:** A user connects to an eMotion LV1 v17 desk, then changes "LV1 IP (override)" to a v16 desk. Until the new desk reports its version, the module still treats it as v17, and `$(waves-lv1:console_version)` still shows the old version. Channel data from the v16 desk is decoded with the v17 layout in that window, so channel mute feedback, `*_pan` / `*_balance` / `*_stereo` and "Channel internally routed to destination" can show values the module only trusts on v17.

**Why it happens:** The restart branch of `configUpdated()` resets channels, routes and the detected mixer config, but not the stored console major version (`consoleMajor`), which gates the v17 decoding at [`src/main.ts:825`](https://github.com/bitfocus/companion-module-waves-lv1/blob/7711f3a5dec1971ecadd0e87c44b05d8a17f7274/src/main.ts#L825).

**Fix:** reset the console version with the rest of the state.

```ts
this.consoleMajor = null
this.setVariableValues({ console_version: '' })
```

### L4: Stereo balance variable shows 0.00 before the desk has reported a balance

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/variables.ts:95`](https://github.com/bitfocus/companion-module-waves-lv1/blob/7711f3a5dec1971ecadd0e87c44b05d8a17f7274/src/variables.ts#L95), [`src/variables.ts:172`](https://github.com/bitfocus/companion-module-waves-lv1/blob/7711f3a5dec1971ecadd0e87c44b05d8a17f7274/src/variables.ts#L172), [`src/main.ts:1177`](https://github.com/bitfocus/companion-module-waves-lv1/blob/7711f3a5dec1971ecadd0e87c44b05d8a17f7274/src/main.ts#L1177)

**What goes wrong:** After connecting, the new `$(waves-lv1:in1_balance)` variable shows "0.00" (centred) for every strip: mono strips, strips on a v16 console (which never sends balance), and strips before the desk reports a balance. A trigger or button text can't tell "centred" apart from "not known". The same release already shows blank for unknown phantom. `*_stereo` similarly reads "off" on v16 consoles, where the module never reads the stereo flag.

**Why it happens:** A new channel starts with `balance: 0`, and the variable code formats that number without checking whether the desk has reported it.

**Fix:** start `balance` as `null` (type `number | null`) and write `s.balance != null ? s.balance.toFixed(2) : ''`; consider `stereo: boolean | null` for the same reason.

### L5: New Internal route fields use the deprecated isVisible function

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/tracks.ts:471-492`](https://github.com/bitfocus/companion-module-waves-lv1/blob/7711f3a5dec1971ecadd0e87c44b05d8a17f7274/src/tracks.ts#L471-L492)

**What goes wrong:** Nothing visible today: the "Destination number (1-based)", "Aux (FX / Monitor)" and "Aux (expression)" fields of the new "Channel: Internal route (Patch > Internal)" action and "Channel internally routed to destination" feedback show and hide correctly. They use the `isVisible` function form, which `@companion-module/base` 1.12.1 marks deprecated ("will be removed in 2.0.0 … Use isVisibleExpression instead"), so a later move to API 2 has three more fields to rewrite. Code quality only.

**Why it happens:** The new `buildRouteDestOptions()` hides the fields with `isVisible` functions plus `isVisibleData`.

**Fix:** use `isVisibleExpression`, which 1.12 already supports, and drop `isVisibleData`.

```ts
// destAux
isVisibleExpression: "$(options:destKind) == 'aux'",
// destAux_expr
isVisibleExpression: "$(options:destKind) == 'aux' && $(options:destAux) == '__custom'",
```

## 📝 Additional Notes

- `tsconfig.build.json`: `exclude` is `["node_modules/**"]`; the template also excludes `src/**/*spec.ts`, `src/**/__tests__/*` and `src/**/__mocks__/*`. Fine as long as the module builds — no change required.
- `tsconfig.json`: adds `compilerOptions.allowImportingTsExtensions` and widens `include` to `["src/**/*.ts", "tests/**/*.ts"]` (template `["src/**/*.ts"]`). Fine as long as the module builds — no change required.
- Prior review (v1.0.3) H1 is still open: when the LV1 accepts the TCP connection but never answers the handshake, the socket is left open and the status stays on Connecting with no reconnect ([`src/osc-tcp.ts:223-226`](https://github.com/bitfocus/companion-module-waves-lv1/blob/7711f3a5dec1971ecadd0e87c44b05d8a17f7274/src/osc-tcp.ts#L223-L226), [`src/osc-tcp.ts:247-250`](https://github.com/bitfocus/companion-module-waves-lv1/blob/7711f3a5dec1971ecadd0e87c44b05d8a17f7274/src/osc-tcp.ts#L247-L250); the main connection's error handler only logs). That review approved the release with it open.
- Prior review (v1.0.3) M1 is still open: the one-shot discovery started in `connectIfReady()` ([`src/main.ts:286`](https://github.com/bitfocus/companion-module-waves-lv1/blob/7711f3a5dec1971ecadd0e87c44b05d8a17f7274/src/main.ts#L286)) is not registered with `cancelDiscovery()`, so deleting or reconfiguring the connection during that scan leaves the discovery socket open for up to 6 s.
- Prior review (v1.0.3) L1 is still open: `DiscoverHandle` is still declared twice ([`src/zdns-discover.ts:123-125`](https://github.com/bitfocus/companion-module-waves-lv1/blob/7711f3a5dec1971ecadd0e87c44b05d8a17f7274/src/zdns-discover.ts#L123-L125)).
- Prior review (v1.0.3) L2 is still open: the handshake `catch` still emits the raw `unknown` value as the error ([`src/osc-tcp.ts:259`](https://github.com/bitfocus/companion-module-waves-lv1/blob/7711f3a5dec1971ecadd0e87c44b05d8a17f7274/src/osc-tcp.ts#L259)).
