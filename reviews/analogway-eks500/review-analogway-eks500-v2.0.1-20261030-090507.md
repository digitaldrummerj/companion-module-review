# Review: analogway-eks500 v2.0.1 (follow-up to the v2.0.0 review)

| | |
| --- | --- |
| **Module** | `companion-module-analogway-eks500` ([repo](https://github.com/bitfocus/companion-module-analogway-eks500)) |
| **Scope** | `tag` (`v1.0.2..v2.0.1`) |
| **Version** | v2.0.1 (`5146f53`, 2026-10-20) |
| **Release** | Update — last published v1.0.2 |
| **API** | 2.0 (base 2.0.4, yarn.lock) — requires Companion 4.3+ |
| **Template** | `companion-module-template-ts-v2.0.4` @ `d62230e` (2026-08-28, pinned) · `.yarnrc.yml` from `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Previous tag** | v1.0.2 (2022-02-02) |
| **Prior review** | [v2.0.0 review](review-analogway-eks500-v2.0.0-20261005-024911.md) (changes required) |
| **Language** | TypeScript |
| **Build** | `yarn install --immutable`, `yarn package` and `yarn lint` pass |
| **Review date** | 2026-10-30 |

This is a follow-up to the v2.0.0 review. Every finding from that review is fixed in v2.0.1: the missing `.gitattributes`, `.gitignore`, `.husky/pre-commit` and `.prettierignore` (C1–C4) now match the template; the `.github/` folder was added (M1); a second upgrade script converts the v1.0.2 text values on legacy buttons to numbers (M2, with tests); a forced refresh now waits for a running poll instead of overlapping it (L1); the source variables label frame and logo layers correctly and show "Unknown" until the device reports (L2); and changing the connection settings refreshes variables and feedbacks straight away (L3). The findings below are new: two come from files added or checked for the first time in this round, and the rest are from the reviewers' pass over the whole v1.0.2..v2.0.1 change.

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Companion shows a module's `warn`-level log lines in the connection's log view, so dozens of warnings per poll are visible noise for the user | general Companion host behaviour for `this.log()`; not verifiable from the module code | [M1](#m1-companion-log-floods-with-about-55-warnings-every-poll-while-the-eikos-is-unreachable) |
| A2 | Companion calls static upgrade scripts with `props.config === null` in some paths (such as a page or button import into an existing connection), and may apply an `updatedConfig` returned in that case | the base 2.0.4 typing declares `config: TConfig \| null` ("The connection config to upgrade, if any"), and the module's own test passes `config: null`; Companion's host-side handling of the returned config was not checked | [L3](#l3-upgrade-script-can-clear-the-eikos-ip-address-when-companion-passes-no-config) |

## 📋 Issues

### Blocking

- [ ] [H1: CI workflow node.yaml differs from the template](#h1-ci-workflow-nodeyaml-differs-from-the-template)
- [ ] [H2: LICENSE differs from the template](#h2-license-differs-from-the-template)

### Non-blocking

- [ ] [M1: Companion log floods with about 55 warnings every poll while the Eikos is unreachable](#m1-companion-log-floods-with-about-55-warnings-every-poll-while-the-eikos-is-unreachable)
- [ ] [L1: A status poll can keep running briefly after the connection is disabled or its settings change](#l1-a-status-poll-can-keep-running-briefly-after-the-connection-is-disabled-or-its-settings-change)
- [ ] [L2: Two EKS500 connections over UDP on the same port cannot both start](#l2-two-eks500-connections-over-udp-on-the-same-port-cannot-both-start)
- [ ] [L3: Upgrade script can clear the Eikos IP address when Companion passes no config](#l3-upgrade-script-can-clear-the-eikos-ip-address-when-companion-passes-no-config)
- [ ] [L4: Typing an input or memory number in expression mode selects the wrong one](#l4-typing-an-input-or-memory-number-in-expression-mode-selects-the-wrong-one)

---

## 🟠 High

### H1: CI workflow node.yaml differs from the template

- **Source:** 🤖 validate-template (CONFIG-DIFF), raised to High by the review maintainer (.github rule)
- **Classification:** 🆕 NEW (the file was added in v2.0.1 to fix the prior M1)
- **File:** [`.github/workflows/node.yaml:19-20`](https://github.com/bitfocus/companion-module-analogway-eks500/blob/5146f532a259cdc7bcbc9a82d4fa089c9222fbcc/.github/workflows/node.yaml#L19-L20), [`.github/workflows/node.yaml:45-68`](https://github.com/bitfocus/companion-module-analogway-eks500/blob/5146f532a259cdc7bcbc9a82d4fa089c9222fbcc/.github/workflows/node.yaml#L45-L68)

**What goes wrong:** No user-visible effect. The module's CI workflow no longer matches the template's, so later template updates won't apply cleanly and anyone troubleshooting the build has to work out which differences are intentional.

**Why it happens:** The `.github/` folder was added in this release, but `node.yaml` was edited on top of the template. Two of the three changes are ones the template itself invites (removing the template-repository step and enabling the test job). The `persist-credentials: false` blocks under `actions/checkout@v7` are not in the template.

**Evidence:**

Validator message: `Differs from template (line 19: found '        with:', template '      - name: Use Node.js 22.x')`

- [`.github/workflows/node.yaml:19-20`](https://github.com/bitfocus/companion-module-analogway-eks500/blob/5146f532a259cdc7bcbc9a82d4fa089c9222fbcc/.github/workflows/node.yaml#L19-L20) and [`:52-53`](https://github.com/bitfocus/companion-module-analogway-eks500/blob/5146f532a259cdc7bcbc9a82d4fa089c9222fbcc/.github/workflows/node.yaml#L52-L53) add `with:` / `persist-credentials: false` under `actions/checkout@v7`. The template has no `with:` block there.
- The template's "Prepare Environment (For template repository)" step (template `node.yaml:27-35`) has been removed. The template's comment says modules may remove this step.
- [`.github/workflows/node.yaml:45-68`](https://github.com/bitfocus/companion-module-analogway-eks500/blob/5146f532a259cdc7bcbc9a82d4fa089c9222fbcc/.github/workflows/node.yaml#L45-L68) enables the template's commented-out `test` job (template `node.yaml:52-74`). The template's comment invites this, and the module has a working `yarn test` script.

```diff
       - uses: actions/checkout@v7
+        with:
+          persist-credentials: false
       - name: Use Node.js 22.x
```

**Confirm by:** `diff companion-module-templates/companion-module-template-ts-v2.0.4/.github/workflows/node.yaml .github/workflows/node.yaml` should show only template-sanctioned changes. The `persist-credentials: false` additions are the divergences the template does not invite.

**Fix:** copy the template's `node.yaml`, then apply only the changes the template invites: remove the template-repository step and uncomment the test job. Drop the extra `persist-credentials: false` blocks, or raise the change with Bitfocus upstream.

### H2: LICENSE differs from the template

- **Source:** 🤖 validate-template (LICENSE-DIFF)
- **Classification:** 🆕 NEW to this review (the `LICENSE` file itself is unchanged since 2019, commit `60da3d8`, and is not in the v1.0.2..v2.0.1 diff; it was not raised in the v2.0.0 review)
- **File:** [`LICENSE:1-3`](https://github.com/bitfocus/companion-module-analogway-eks500/blob/5146f532a259cdc7bcbc9a82d4fa089c9222fbcc/LICENSE#L1-L3)

**What goes wrong:** No user-visible effect. The module's license text doesn't match the standard Bitfocus MIT license the template ships, so it carries a different heading, copyright line and wrapping from every other module built on the template.

**Why it happens:** The module still has the original 2018 license file from before the template existed. The v2 rewrite updated the rest of the repo to the template but left `LICENSE` as it was.

**Evidence:**

Validator message: `Differs from template (line 1: found 'The MIT License', template 'MIT License')`

```text
Template:  MIT License
           Copyright (c) 2022 Bitfocus AS - Open Source
Module:    The MIT License
           Copyright (c) 2018 Bitfocus AS, William Viker & Håkon Nessjøen
```

The line wrapping of the remaining paragraphs also differs.

**Confirm by:** `diff companion-module-templates/companion-module-template-ts-v2.0.4/LICENSE LICENSE` should print nothing.

**Fix:** replace `LICENSE` with the template's LICENSE byte-for-byte.

---

## 🟡 Medium

### M1: Companion log floods with about 55 warnings every poll while the Eikos is unreachable

- **Source:** 🔎 protocol reviewer, QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:114-138`](https://github.com/bitfocus/companion-module-analogway-eks500/blob/5146f532a259cdc7bcbc9a82d4fa089c9222fbcc/src/main.ts#L114-L138), [`src/main.ts:156-167`](https://github.com/bitfocus/companion-module-analogway-eks500/blob/5146f532a259cdc7bcbc9a82d4fa089c9222fbcc/src/main.ts#L156-L167), [`src/main.ts:199-204`](https://github.com/bitfocus/companion-module-analogway-eks500/blob/5146f532a259cdc7bcbc9a82d4fa089c9222fbcc/src/main.ts#L199-L204), [`src/main.ts:253-263`](https://github.com/bitfocus/companion-module-analogway-eks500/blob/5146f532a259cdc7bcbc9a82d4fa089c9222fbcc/src/main.ts#L253-L263)

**What goes wrong:** A user's TCP connection to the Eikos has connected once, and then the switcher is powered off or unplugged. The connection status changes to Disconnected, but the status poll keeps running at the default **Feedback polling interval** of 2000 ms. Every poll tries all 55 read commands, and each one fails and writes its own warning, such as `Unable to send "0,3,sF": TCP socket is not connected`. That is roughly 27 warnings a second (about 1,600 a minute), which buries the real reconnect errors in the connection's log until the device comes back. Each failure also pushes every variable to Companion again. Pressing a **Refresh all monitored status** button while offline produces the same burst.

**Why it happens:** The poll timer starts when the TCP socket connects, but nothing stops it when the socket drops: the timer is only cleared in `destroy()`, in `configUpdated()` and before a restart. The poll sends its whole command list one by one and keeps going after a failure, and every failed send logs a warning and updates the variables.

**Evidence:**

```ts
// src/main.ts:123-129
			if (!this.tcp?.isConnected) throw new Error('TCP socket is not connected')
			await this.tcp.sendAsync(command)
		} catch (error) {
			const message = error instanceof Error ? error.message : String(error)
			this.lastError = message
			this.log('warn', `Unable to send “${command}”: ${message}`)
			UpdateVariableValues(this)
```

```ts
// src/main.ts:253-257
	private startPolling(): void {
		this.stopPolling()
		if (this.config.pollInterval > 0) {
			this.pollTimer = setInterval(() => void this.pollStatus(), Math.max(500, this.config.pollInterval))
		}
```

**Fix:** skip the poll while the socket is down, and stop a batch after its first failed send. For example, start `runPoll()` with `if (this.config.protocol === 'tcp' && !this.tcp?.isConnected) return`, or call `this.stopPolling()` from a `status_change` / `end` handler when the status is not Ok (the existing `connect` handler restarts it). Having `sendCommand()` return a boolean lets `sendCommands()` stop after the first failure, so one outage logs one warning instead of 55.

---

## 🟢 Low

### L1: A status poll can keep running briefly after the connection is disabled or its settings change

- **Source:** 🔎 protocol reviewer, QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:50-54`](https://github.com/bitfocus/companion-module-analogway-eks500/blob/5146f532a259cdc7bcbc9a82d4fa089c9222fbcc/src/main.ts#L50-L54), [`src/main.ts:133-138`](https://github.com/bitfocus/companion-module-analogway-eks500/blob/5146f532a259cdc7bcbc9a82d4fa089c9222fbcc/src/main.ts#L133-L138), [`src/main.ts:203`](https://github.com/bitfocus/companion-module-analogway-eks500/blob/5146f532a259cdc7bcbc9a82d4fa089c9222fbcc/src/main.ts#L203), [`src/main.ts:222`](https://github.com/bitfocus/companion-module-analogway-eks500/blob/5146f532a259cdc7bcbc9a82d4fa089c9222fbcc/src/main.ts#L222)

**What goes wrong:** If a user disables the connection, saves new settings, or Companion shuts down while a poll is running (or within 50 ms of the connection coming up), the poll carries on for up to about 0.7 s. The visible effect is a short burst of `Unable to send … TCP socket is not connected` warnings in the log, or a poll sent through the new socket after a settings change. Nothing keeps running after that.

**Why it happens:** When the connection comes up, the module schedules a one-off "initial poll" 50 ms later but doesn't keep the timer handle, so `destroy()` and `configUpdated()` can't cancel it. A poll that has already started has no way to be told to stop: it works through its command list with a 12 ms pause between commands, and `destroy()` only clears the repeating timer and closes the sockets.

**Evidence:**

```ts
// src/main.ts:199-204
		this.tcp.on('connect', () => {
			this.lastError = ''
			this.updateStatus(InstanceStatus.Ok)
			this.startPolling()
			setTimeout(() => void this.pollStatus(true), 50)
		})
```

**Fix:** store the 50 ms timeout handle and clear it in `stopPolling()` (or call `void this.pollStatus(true)` directly instead of deferring it). Add a `destroyed` flag or connection generation counter that `destroy()` and `closeConnection()` set, and check it in the `sendCommands()` loop so an in-flight poll stops right away.

### L2: Two EKS500 connections over UDP on the same port cannot both start

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:209`](https://github.com/bitfocus/companion-module-analogway-eks500/blob/5146f532a259cdc7bcbc9a82d4fa089c9222fbcc/src/main.ts#L209)

**What goes wrong:** A user with two Eikos units adds two EKS500 connections, both set to Protocol **UDP** and the default Port 10500. The second connection can't open local UDP port 10500 and shows an error status (for example `bind EADDRINUSE`), so its actions and feedbacks never work unless the user changes one device's port. The same happens if any other program on the Companion computer already uses port 10500. v1.0.2 did not bind a fixed local port.

**Why it happens:** The UDP socket listens on the same port number as the device's port. There is no separate setting for the local listening port.

**Evidence:**

```ts
// src/main.ts:209
			this.udp = new UDPHelper(this.config.host, this.config.port, { bind_port: this.config.port })
```

**Fix:** add a separate "Local UDP feedback port" config field (defaulting to 10500) and use it for `bind_port`. Update the static-text note so it tells users to point the Eikos Remote Port at that value.

### L3: Upgrade script can clear the Eikos IP address when Companion passes no config

- **Source:** 🔎 QA reviewer, compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/upgrades.ts:14-28`](https://github.com/bitfocus/companion-module-analogway-eks500/blob/5146f532a259cdc7bcbc9a82d4fa089c9222fbcc/src/upgrades.ts#L14-L28)

**What goes wrong:** Companion can run upgrade scripts without a connection config, for example when importing a page or buttons exported from v1.0.2 into a connection that already exists (see [A2](#-assumptions-to-confirm)). In that case the config upgrade script doesn't return "no change". It returns a made-up config: an empty **Eikos IP address**, port 10500, protocol TCP and polling 2000 ms. If Companion applies it, the connection's IP address is cleared and its status changes to Bad config ("Enter the Eikos IP address").

**Why it happens:** The script treats a missing config as an empty object. An empty object fails the "already migrated" check, so the script falls through and builds a new config from defaults instead of returning `null` (no change).

**Evidence:**

```ts
// src/upgrades.ts:14-17
	const oldConfig = (props.config ?? {}) as unknown as Record<string, unknown>
	if (!('prot' in oldConfig) && 'protocol' in oldConfig && 'port' in oldConfig && 'pollInterval' in oldConfig) {
		return { updatedConfig: null, updatedActions: [], updatedFeedbacks: [] }
	}
```

**Fix:** return "no change" straight away when there is no config, and optionally add a `config: null` case to `test/upgrades.test.mjs`.

```ts
if (!props.config) return { updatedConfig: null, updatedActions: [], updatedFeedbacks: [] }
```

### L4: Typing an input or memory number in expression mode selects the wrong one

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/choices.ts:26-43`](https://github.com/bitfocus/companion-module-analogway-eks500/blob/5146f532a259cdc7bcbc9a82d4fa089c9222fbcc/src/choices.ts#L26-L43)

**What goes wrong:** On the **Input: Set freeze** or **Input: Auto-set** action, or the **Input signal detected** or **Input is frozen** feedback, a user switches the Input option to expression mode and types `1` for Input 1. The button actually controls Input 2, because Input 1's value is 0. The Preset / Copy from / Copy to dropdowns work the same way: "Memory 1" is value 3, so typing `1` selects "Next (Preview)". In normal dropdown mode the labels are correct and nothing goes wrong.

**Why it happens:** In API 2.0 any dropdown can be switched to expression mode, and the user then has to type the raw choice value. These dropdowns use the device's zero-based or offset protocol indexes as their values, not the numbers shown in the labels.

**Fix:** changing the values would break saved buttons unless an upgrade script converts them too. The cheap fix is to add an `expressionDescription` to these options, for example "Zero-based index: Input 1 = 0, DVI 1 = 8" and "Memory 1 = 3 … Memory 8 = 10". Optionally set `disableAutoExpression: true` on the parameter-code dropdowns, where an expression makes little sense.
