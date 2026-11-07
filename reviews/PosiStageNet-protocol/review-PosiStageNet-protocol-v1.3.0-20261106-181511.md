# Module Review: companion-module-PosiStageNet-protocol v1.3.0

| Field | Value |
| --- | --- |
| **Module** | [`companion-module-PosiStageNet-protocol`](https://github.com/bitfocus/companion-module-PosiStageNet-protocol) |
| **Scope** | `tag` (v1.2.0..v1.3.0) |
| **Version** | v1.3.0 ([`df89164`](https://github.com/bitfocus/companion-module-PosiStageNet-protocol/commit/df89164a0f3e1a6bb42fddf312bb14efcae5d80d)) |
| **Release** | Update — last published v1.2.0 |
| **API** | 1 (base 1.11.3, yarn.lock) |
| **Template** | `companion-module-template-ts-v1` @ `42609d8` (2026-03-03, pinned) · `.yarnrc.yml` from `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Reviewed** | 2026-11-06 |

## Verdict: ❌ Changes Required

## ❓ Assumptions

Some findings depend on assumptions the reviewers couldn't check. They're listed in [❓ Assumptions to Confirm](#-assumptions-to-confirm) at the end of this review.

## 📋 Issues

### Blocking

- [ ] [C1: Required `.gitattributes` file is missing](#c1-required-gitattributes-file-is-missing)
- [ ] [C2: `.gitignore` is missing the template's `/.vscode` entry](#c2-gitignore-is-missing-the-templates-vscode-entry)
- [ ] [H1: `tsconfig.build.json` still compiles for Node 18 while the module runs on Node 22](#h1-tsconfigbuildjson-still-compiles-for-node-18-while-the-module-runs-on-node-22)

### Non-blocking

- [ ] [M1: Clear Validity when tracker data is stale sometimes leaves the old value showing](#m1-clear-validity-when-tracker-data-is-stale-sometimes-leaves-the-old-value-showing)
- [ ] [L1: Bind to specific IP now accepts names that make the multicast join fail](#l1-bind-to-specific-ip-now-accepts-names-that-make-the-multicast-join-fail)
- [ ] [L2: Connection log says the socket is bound to the chosen interface IP when it listens on all interfaces](#l2-connection-log-says-the-socket-is-bound-to-the-chosen-interface-ip-when-it-listens-on-all-interfaces)
- [ ] [N1: Interface dropdown has no any-interface entry and misses adapters added after start](#n1-interface-dropdown-has-no-any-interface-entry-and-misses-adapters-added-after-start)
- [ ] [N2: Tracker Active feedback has an empty description](#n2-tracker-active-feedback-has-an-empty-description)
- [ ] [N3: Help page does not explain the new stale-validity option or the interface dropdown](#n3-help-page-does-not-explain-the-new-stale-validity-option-or-the-interface-dropdown)

## 🔴 Critical

### C1: Required `.gitattributes` file is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** template check, applies to every release (the file was already missing at v1.2.0)
- **File:** `.gitattributes` (missing)

**What goes wrong:** Without this file, git uses each contributor's own line-ending setting. A checkout on Windows can turn every file into CRLF line endings, so prettier and lint report changes on every line and commits can mix line endings across the module.

**Why it happens:** The template ships a one-line `.gitattributes` that forces LF line endings for every text file. The module never added it.

**Evidence:**

```text
Template: .gitattributes
  * text=auto eol=lf
Module:   .gitattributes not present (at v1.2.0 or v1.3.0)
```

**Confirm by:** the repo root at [`df89164`](https://github.com/bitfocus/companion-module-PosiStageNet-protocol/tree/df89164a0f3e1a6bb42fddf312bb14efcae5d80d) has no `.gitattributes`.

**Fix:** add `.gitattributes` at the repo root with the template's single line.

```text
* text=auto eol=lf
```

### C2: `.gitignore` is missing the template's `/.vscode` entry

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** template check, applies to every release (the file has not changed since the initial commit)
- **File:** [`.gitignore:1-7`](https://github.com/bitfocus/companion-module-PosiStageNet-protocol/blob/df89164a0f3e1a6bb42fddf312bb14efcae5d80d/.gitignore#L1-L7)

**What goes wrong:** A contributor's VS Code workspace settings (the `.vscode/` folder) are not ignored, so they can end up committed to the module by accident.

**Why it happens:** The module's `.gitignore` matches the template's first seven entries, but the template adds `/.vscode` as line 8 and the module stops before it.

**Evidence:**

```diff
 node_modules/
 package-lock.json
 /pkg
 /*.tgz
 /dist
 DEBUG-*
 /.yarn
+/.vscode
```

**Confirm by:** open [`.gitignore:1-7`](https://github.com/bitfocus/companion-module-PosiStageNet-protocol/blob/df89164a0f3e1a6bb42fddf312bb14efcae5d80d/.gitignore#L1-L7). The file ends at `/.yarn`.

**Fix:** add `/.vscode` as the last line of `.gitignore`.

## 🟠 High

### H1: `tsconfig.build.json` still compiles for Node 18 while the module runs on Node 22

- **Source:** 🤖 validate-template (NODE-VERSION)
- **Classification:** template check, applies to every release (the file was not touched in v1.2.0..v1.3.0)
- **File:** [`tsconfig.build.json:2`](https://github.com/bitfocus/companion-module-PosiStageNet-protocol/blob/df89164a0f3e1a6bb42fddf312bb14efcae5d80d/tsconfig.build.json#L2)

**What goes wrong:** Companion runs the module on Node 22, but TypeScript builds it with the settings for Node 18. The module's build no longer matches the API 1 template, which uses the Node 22 preset, and that mismatch makes later build and runtime problems harder to troubleshoot.

**Why it happens:** Every other place already names Node 22: the manifest runtime is `node22`, `engines` is `^22.14` and `@types/node` is `^22.14.1`. Only the build config still extends the Node 18 preset from `@companion-module/tools`.

**Evidence:**

```text
tsconfig.build.json:2
  Found:    "extends": "@companion-module/tools/tsconfig/node18/recommended"
  Expected: "extends": "@companion-module/tools/tsconfig/node22/recommended"
```

**Confirm by:** open [`tsconfig.build.json:2`](https://github.com/bitfocus/companion-module-PosiStageNet-protocol/blob/df89164a0f3e1a6bb42fddf312bb14efcae5d80d/tsconfig.build.json#L2).

**Fix:** switch the build config to the Node 22 preset. This is the only place left to change:

- [ ] `tsconfig.build.json`: `"extends": "@companion-module/tools/tsconfig/node22/recommended"`

## 🟡 Medium

### M1: Clear Validity when tracker data is stale sometimes leaves the old value showing

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:469-482`](https://github.com/bitfocus/companion-module-PosiStageNet-protocol/blob/df89164a0f3e1a6bb42fddf312bb14efcae5d80d/src/main.ts#L469-L482), [`src/main.ts:529-535`](https://github.com/bitfocus/companion-module-PosiStageNet-protocol/blob/df89164a0f3e1a6bb42fddf312bb14efcae5d80d/src/main.ts#L529-L535)

**What goes wrong:** A user turns on Advanced Options, ticks "Clear Validity when tracker data is stale" and sets "Tracker data timeout (ms)" to 3000, so a button showing `$(psn:tracker_1_validity)` goes blank when tracking stops. When the PSN server stops sending, the variable is sometimes not cleared after the 3 seconds (about 1 timer firing in 10 in the reviewers' test runs, ranging from 1 in 20 to 1 in 4). The button keeps showing the last value (for example `1.00`) until data comes back, because nothing else refreshes the variables once the stream has stopped. With timeouts under 1.5 s (including the default of 10 ms), a miss means the value only clears at the module's 1.5 s connection-lost refresh, later than the configured time. When other trackers keep sending, their next packet clears it, so users mostly see this when the whole PSN stream stops.

**Why it happens:** When the per-tracker timer fires, it doesn't mark the tracker as stale. It asks the variable update to decide again from the clock, with "more than the timeout since the last packet" (a strict `>`). Node's timers and `Date.now()` don't tick exactly together, so the timer often fires when exactly the timeout (sometimes 1 ms less) has passed by `Date.now()`. "More than" is then false, the old value is pushed again, and the timer has already removed itself, so no later check runs. The reviewers reproduced this on Node 22.21.1 with a UDP listener that copies the module's flow: 45 of 400 firings missed at 10 ms, 3 of 20 at 200 ms and 2 of 20 at 1000 ms. The commit that added the option (`3f10583`) says the timer "fires at exactly the configured deadline and triggers a variable update", which is exactly the case the strict comparison misses.

**Evidence:**

```ts
// src/main.ts:469-482
tracker.lastSeen = Date.now()

if (this.config.useTrackerTimeout) {
	const existing = this.trackerTimeoutTimers.get(tracker.id)
	if (existing) clearTimeout(existing)
	const deadline = this.config.trackerTimeout ?? 10
	this.trackerTimeoutTimers.set(
		tracker.id,
		setTimeout(() => {
			this.trackerTimeoutTimers.delete(tracker.id)
			this.updateTrackerVariables()
		}, deadline),
	)
}
// src/main.ts:529-534
if (tracker.validity !== undefined && this.config.useValidity) {
	const timeout = this.config.trackerTimeout ?? 10
	const isStale =
		this.config.useTrackerTimeout === true &&
		(tracker.lastSeen === undefined || Date.now() - tracker.lastSeen > timeout)
	variableValues[`${prefix}validity`] = isStale ? '' : this.format(tracker.validity)
```

**Fix:** treat the timer firing as proof that the deadline has passed. Set a `stale` flag on the tracker in the timer callback, clear it when a data packet arrives, and read the flag in `updateTrackerVariables()`. Changing `>` to `>=` alone is not enough, because the timer can also fire 1 ms early by `Date.now()`.

```ts
// interface TrackerData
stale?: boolean

// processTrackerData()
tracker.lastSeen = Date.now()
tracker.stale = false
// ...
setTimeout(() => {
	this.trackerTimeoutTimers.delete(tracker.id)
	tracker.stale = true
	this.updateTrackerVariables()
}, deadline)

// updateTrackerVariables()
const isStale = this.config.useTrackerTimeout === true && tracker.stale === true
```

## 🟢 Low

### L1: Bind to specific IP now accepts names that make the multicast join fail

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer
- **Classification:** 🔙 REGRESSION
- **File:** [`src/config.ts:59-70`](https://github.com/bitfocus/companion-module-PosiStageNet-protocol/blob/df89164a0f3e1a6bb42fddf312bb14efcae5d80d/src/config.ts#L59-L70), [`src/main.ts:185`](https://github.com/bitfocus/companion-module-PosiStageNet-protocol/blob/df89164a0f3e1a6bb42fddf312bb14efcae5d80d/src/main.ts#L185)

**What goes wrong:** With Advanced Options on, a user types a custom value such as `eth0`, `localhost` or `studio-pc` into "Bind to specific IP". In v1.2.0 the field flagged that as invalid before it was saved. In v1.3.0 it is accepted, and after saving, the connection shows Connection Failure with "Multicast join failed: Error: addMembership EINVAL" and no tracker variables update. Picking an entry from the dropdown (for example "en0: 192.168.1.20") or typing an IP address still works; only typed names are affected.

**Why it happens:** When the field became a dropdown that allows custom values, its check changed from Companion's IP-address pattern (`Regex.IP`) to its hostname pattern (`Regex.HOSTNAME`), which matches plain names like `eth0`. The saved value is passed as the interface for Node's multicast join (`addMembership`), and that argument must be an IPv4 address. The reviewers confirmed on Node 22 that `eth0` and `localhost` throw EINVAL there while `0.0.0.0` works. In base 1.11.3, a dropdown's `regex` is used to "Check custom value against regex".

**Fix:** put back the IP check on the dropdown. It only applies to custom values, so the listed interfaces and the `0.0.0.0` default still pass.

```ts
// src/config.ts:67
regex: Regex.IP,
```

### L2: Connection log says the socket is bound to the chosen interface IP when it listens on all interfaces

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer
- **Classification:** 🔙 REGRESSION
- **File:** [`src/main.ts:179`](https://github.com/bitfocus/companion-module-PosiStageNet-protocol/blob/df89164a0f3e1a6bb42fddf312bb14efcae5d80d/src/main.ts#L179), [`src/main.ts:205`](https://github.com/bitfocus/companion-module-PosiStageNet-protocol/blob/df89164a0f3e1a6bb42fddf312bb14efcae5d80d/src/main.ts#L205)

**What goes wrong:** A user troubleshooting which network card receives PSN picks 192.168.10.5 in "Bind to specific IP". The connection log then says "Successfully bound to 192.168.10.5:56565", but the module still listens on every interface (0.0.0.0). The chosen IP is only used to pick the interface that joins the multicast group, and only while Advanced Options is on; with Advanced Options off, the log still prints the saved value even though it isn't used at all. v1.2.0 printed the real bound address. The only visible effect is the misleading log line.

**Why it happens:** The log line was changed to print the saved setting instead of the socket's real address, while the bind call still passes only the port.

**Fix:** log the socket's real address again, and name the interface on the multicast-join line instead.

```ts
this.log('info', `🎧 Successfully bound to ${address.address}:${address.port}`)
// ...
this.log('info', `✅ Joined multicast group ${this.config.host} on interface ${this.config.advancedOptions ? this.config.bind : 'OS default'}`)
```

## 💡 Nice to Have

### N1: Interface dropdown has no any-interface entry and misses adapters added after start

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:62-79`](https://github.com/bitfocus/companion-module-PosiStageNet-protocol/blob/df89164a0f3e1a6bb42fddf312bb14efcae5d80d/src/main.ts#L62-L79), [`src/config.ts:64`](https://github.com/bitfocus/companion-module-PosiStageNet-protocol/blob/df89164a0f3e1a6bb42fddf312bb14efcae5d80d/src/config.ts#L64)

**What goes wrong:** "Bind to specific IP" lists the network interfaces that existed when the connection started. A USB network adapter plugged in, or a new DHCP address received, after that doesn't appear until the connection is disabled and re-enabled or Companion restarts, so the user has to type the IP by hand. The list also has no "any interface" entry: the default is `0.0.0.0`, but once a user has picked an adapter, the only way back to the OS default is to know to type `0.0.0.0` as a custom value.

**Why it happens:** The interface list is read from `os.networkInterfaces()` once, in the module's constructor, and the settings page reuses that saved list each time it opens. The choices never include `0.0.0.0`.

**Fix:** build the list each time the settings are opened (inside `getConfigFields()`, or a helper it calls) and drop the constructor code. Add an "any interface" choice first.

```ts
{ id: '0.0.0.0', label: 'Any interface (OS default)' },
```

### N2: Tracker Active feedback has an empty description

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.ts:18`](https://github.com/bitfocus/companion-module-PosiStageNet-protocol/blob/df89164a0f3e1a6bb42fddf312bb14efcae5d80d/src/feedbacks.ts#L18)

**What goes wrong:** In the feedback picker, "Tracker Active" shows no help text, while "Tracker Moving" now has one, so users don't learn that the feedback turns on once the tracker has reported a name. No functional effect.

**Why it happens:** This release added `description: ''` to the Tracker Active feedback.

**Fix:** write a real description, for example "Changes the button style when the tracker with this ID is present in the PSN stream", or remove the empty key.

### N3: Help page does not explain the new stale-validity option or the interface dropdown

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`companion/HELP.md`](https://github.com/bitfocus/companion-module-PosiStageNet-protocol/blob/df89164a0f3e1a6bb42fddf312bb14efcae5d80d/companion/HELP.md)

**What goes wrong:** Users who open the module's help in Companion find nothing about "Clear Validity when tracker data is stale", "Tracker data timeout (ms)" or picking a network interface for "Bind to specific IP", so they have to guess what a sensible timeout is.

**Why it happens:** [`src/config.ts`](https://github.com/bitfocus/companion-module-PosiStageNet-protocol/blob/df89164a0f3e1a6bb42fddf312bb14efcae5d80d/src/config.ts) and [`src/main.ts`](https://github.com/bitfocus/companion-module-PosiStageNet-protocol/blob/df89164a0f3e1a6bb42fddf312bb14efcae5d80d/src/main.ts) changed in this release, but `companion/HELP.md` did not.

**Fix:** add a short section to `companion/HELP.md` on the new options: what the timeout does, a recommended value relative to your PSN source's packet rate, and that the validity variable becomes empty when the tracker is stale. Also explain that the bind interface selects which network card joins the multicast group.

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | The missed clear also happens on Windows, Linux and Raspberry Pi Companion hosts, not only on macOS where it was measured (from 1 in 20 to 1 in 4 timer firings, depending on the run). It may happen less often on Windows, whose coarser timers usually fire late | Local Node 22.21.1 runs on macOS that copy the module's `lastSeen` and `setTimeout` flow; other operating systems not tested. The strict comparison that causes the miss is the same everywhere | [M1](#m1-clear-validity-when-tracker-data-is-stale-sometimes-leaves-the-old-value-showing) |
| A2 | Companion's connection settings show a saved dropdown value that is not in the list (the default `0.0.0.0`) as a custom value when custom values are allowed | Companion host UI behaviour; not checked in a live Companion | [N1](#n1-interface-dropdown-has-no-any-interface-entry-and-misses-adapters-added-after-start) |
| A3 | Companion calls the module's `getConfigFields()` each time the user opens the connection's settings, so building the interface list there would refresh it | Usual Companion host behaviour; not visible in the module or in the base 1.11.3 typings | [N1](#n1-interface-dropdown-has-no-any-interface-entry-and-misses-adapters-added-after-start) |
