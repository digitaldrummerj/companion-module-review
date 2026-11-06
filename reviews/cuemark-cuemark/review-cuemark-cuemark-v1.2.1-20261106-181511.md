# Re-review: companion-module-cuemark-cuemark v1.2.1

| | |
| --- | --- |
| **Module** | `companion-module-cuemark-cuemark` |
| **Scope** | `tag` — the module has never been published, so there is no published tag to diff against: the whole module was reviewed again, every finding is 🆕 NEW, and each finding of the [v1.2.0 review](review-cuemark-cuemark-v1.2.0-20261031-201135.md) was re-checked against v1.2.1 (`v1.2.0..v1.2.1`: 10 files, +702/−469) |
| **Version** | `v1.2.1` ([`520480f`](https://github.com/bitfocus/companion-module-cuemark-cuemark/tree/520480f3b50d6ac26aff1916895323de9feb7895)) |
| **Release** | New module — never published |
| **API** | 1 (base 1.12.1, yarn.lock) |
| **Template** | `companion-module-template-js-v1` @ `9e222b4` (2026-03-26, pinned) · `.yarnrc.yml` from `companion-module-template-js` @ `89da037` (2026-11-01) |
| **Follow-up to** | [v1.2.0 review](review-cuemark-cuemark-v1.2.0-20261031-201135.md) (2026-10-31): all seven of its findings are fixed |
| **Build** | `yarn install --immutable` and `yarn package` pass |
| **Date** | 2026-11-06 |

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | When the address in "Cuemark is on" doesn't answer, Node's built-in `fetch` waits seconds before it gives up (about 3 s when nothing on the LAN answers for the address, up to about 10 s, its default connect timeout, otherwise), so a status request is pending most of the time and a Save is likely to land during one | undici's documented default connect timeout and OS defaults; not measured against a real unreachable host. The extra poll loop itself was reproduced with the module's own code and a stubbed `fetch` | [H1](#h1-saving-the-connection-settings-while-a-poll-is-waiting-leaves-an-extra-poll-loop-running-and-each-such-save-adds-another) |
| A2 | When the user clicks Save, Companion calls `configUpdated()` on the running module rather than restarting it, so the extra loops last until the connection is disabled or Companion restarts | base 1.12 calls `configUpdated()` for every `updateConfigAndLabel` message (`node_modules/@companion-module/base/dist/module-api/base.js:148-155`); when Companion sends that message (on Save, and possibly on a rename) was not checked in Companion's source | [H1](#h1-saving-the-connection-settings-while-a-poll-is-waiting-leaves-an-extra-poll-loop-running-and-each-such-save-adds-another) |

## 📋 Issues

### Blocking

- [ ] [C1: After a build, git offers to commit the pkg folder, the .yarn folder and the .tgz](#c1-after-a-build-git-offers-to-commit-the-pkg-folder-the-yarn-folder-and-the-tgz)
- [ ] [H1: Saving the connection settings while a poll is waiting leaves an extra poll loop running, and each such save adds another](#h1-saving-the-connection-settings-while-a-poll-is-waiting-leaves-an-extra-poll-loop-running-and-each-such-save-adds-another)

### Non-blocking

- [ ] [NR1: The Key is a plain text field, so anyone who sees the settings or an export can read it](#nr1-the-key-is-a-plain-text-field-so-anyone-who-sees-the-settings-or-an-export-can-read-it)

### Notes

- **v1.2.0 review:** all seven findings of the [v1.2.0 review](review-cuemark-cuemark-v1.2.0-20261031-201135.md) are fixed in v1.2.1 (details in Additional Notes). The two blocking findings above are new: both came in with the v1.2.1 changes.
- [📝 Additional Notes](#-additional-notes)

## 🔴 Critical

### C1: After a build, git offers to commit the pkg folder, the .yarn folder and the .tgz

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.gitignore:3-6`](https://github.com/bitfocus/companion-module-cuemark-cuemark/blob/520480f3b50d6ac26aff1916895323de9feb7895/.gitignore#L3-L6)

**What goes wrong:** After `yarn install` and `yarn package`, `git status` lists the `pkg/` folder, the `.yarn/` folder and `cuemark-cuemark-1.2.1.tgz` as new files. A `git add .`, or "commit all" in GitHub Desktop, would put the built package and Yarn's files into the repo. In v1.2.0 git ignored all three.

**Why it happens:** The four entries copied from the template (`/pkg`, `/*.tgz`, `DEBUG-*`, `/.yarn`) start with two spaces. Git treats leading spaces as part of the pattern (it only trims trailing ones), so none of the four lines matches anything. They came in with commit `63081e4` ("Modify .gitignore to add new ignore patterns"), the GitHub edit on top of v1.2.0 that replaced the working `pkg/`, `*.tgz` and `.yarn/` lines with the template's entries.

**Evidence:**

```text
// .gitignore:1-6 (v1.2.1)
node_modules/
package-lock.json
  /pkg
  /*.tgz
  DEBUG-*
  /.yarn

// template .gitignore:1-6 (companion-module-template-js-v1)
node_modules/
package-lock.json
/pkg
/*.tgz
DEBUG-*
/.yarn

// after yarn package, in the clone
$ git status --short
?? .yarn/
?? cuemark-cuemark-1.2.1.tgz
?? pkg/
$ git check-ignore -v pkg .yarn cuemark-cuemark-1.2.1.tgz
(no output, exit 1: nothing is ignored)
```

**Confirm by:** run `yarn package`, then `git status --short`. It should list no `pkg/`, `.yarn/` or `*.tgz` entries.

**Fix:** remove the leading spaces, so lines 3-6 match the template exactly.

```diff
 node_modules/
 package-lock.json
-  /pkg
-  /*.tgz
-  DEBUG-*
-  /.yarn
+/pkg
+/*.tgz
+DEBUG-*
+/.yarn
```

## 🟠 High

### H1: Saving the connection settings while a poll is waiting leaves an extra poll loop running, and each such save adds another

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/index.js:49-55`](https://github.com/bitfocus/companion-module-cuemark-cuemark/blob/520480f3b50d6ac26aff1916895323de9feb7895/src/index.js#L49-L55), [`src/index.js:272-296`](https://github.com/bitfocus/companion-module-cuemark-cuemark/blob/520480f3b50d6ac26aff1916895323de9feb7895/src/index.js#L272-L296)

**What goes wrong:** A stage manager adds the Cuemark connection and types the wrong address in "Cuemark is on" (192.168.1.5 instead of 192.168.1.50), or the Cuemark machine is still switched off. The Connections page shows "Cuemark is not answering — is it running?". They correct the address and click Save. If the Save lands while the module is still waiting for an answer to its last status request, the old poll loop keeps running next to the new one, and Cuemark is asked what it is showing 4 times a second instead of 2. That is likely when the address doesn't answer, because each request waits seconds before it gives up (see [A1](#-assumptions-to-confirm)). Every later Save that lands the same way can add another loop, until the connection is disabled or Companion restarts. Nothing in Companion shows it: the variables (`deck`, `deckNumber`, `taken`, …) and the feedbacks still look right, because every loop reads the new settings. The extra requests land on the machine that is calling the show, which the module's own comment says the twice-a-second rate was chosen to protect ("slow enough to be nothing on a machine that is also calling a show"). Running the module's own poll code against a stand-in Cuemark that answers in 200 ms, the module made 17 status requests per 12 s, then 34 after one Save, then 51 after the next.

**Why it happens:** The poll is a chain of one-shot timers: each tick asks Cuemark for `/state`, waits for the answer, then sets a timer for the next tick. Every chain shares one "stopped" flag and one timer slot. On Save, `configUpdated()` sets the flag and clears the timer, then starts a new chain at once, and starting a chain clears the flag again. A tick of the old chain that is still waiting for its answer has no timer to clear, so when the answer arrives it finds the flag cleared and sets its next timer: the old chain lives on. The new chain then takes over the timer slot, so later stops (including the one in `destroy()`) clear only the newest chain's timer. v1.2.0 polled with one `setInterval`, which `clearInterval` stopped completely, so this came in with v1.2.1.

**Evidence:**

```js
// src/index.js:45-55
	async destroy() {
		this.stopPolling()
	}

	async configUpdated(config) {
		this.config = config
		this.stopPolling()
		// A new host, port or key: say so until Cuemark has answered under it.
		this.setStatus(InstanceStatus.Connecting)
		this.poll()
	}
```

```js
// src/index.js:272-296
	poll() {
		const tick = async () => {
			let delay = POLL_MS
			try {
				const response = await fetch(url(this.config, '/state'))
				if (this.answered(response)) {
					this.setStatus(InstanceStatus.Ok)
					if (this.config?.poll !== false) this.take(await response.json())
				}
			} catch (error) {
				this.unreachable('state', error)
				delay = UNREACHABLE_MS
			}
			if (this.config?.poll === false || this.stopped) return
			this.timer = setTimeout(tick, delay)
		}
		this.stopped = false
		tick()
	}

	stopPolling() {
		this.stopped = true
		if (this.timer) clearTimeout(this.timer)
		this.timer = null
	}
```

```text
// the module's real CuemarkInstance methods with a stubbed fetch; configUpdated()
// called while a request was pending, after each 12 s window
stand-in answers OK in 200 ms:  window 0: 17   window 1: 34   window 2: 51   window 3: 51 requests
stand-in fails after 1 s:       window 0: 2    window 1: 4    window 2: 8    window 3: 6 requests
```

**Confirm by:** open [`src/index.js:49-55`](https://github.com/bitfocus/companion-module-cuemark-cuemark/blob/520480f3b50d6ac26aff1916895323de9feb7895/src/index.js#L49-L55) and [`src/index.js:285-288`](https://github.com/bitfocus/companion-module-cuemark-cuemark/blob/520480f3b50d6ac26aff1916895323de9feb7895/src/index.js#L285-L288). `configUpdated()` calls `stopPolling()` and then `poll()` at once, and `poll()` sets `this.stopped = false`. A tick still waiting on `fetch` at line 276 then passes the check at line 285 and sets its own timer next to the new chain's.

**Fix:** give each poll run its own token, so a tick from an earlier run can't schedule itself again.

```js
poll() {
	const run = Symbol('poll')
	this.run = run
	const tick = async () => {
		let delay = POLL_MS
		try {
			const response = await fetch(url(this.config, '/state'))
			if (this.run !== run) return // superseded by a newer poll() or destroy()
			if (this.answered(response)) {
				this.setStatus(InstanceStatus.Ok)
				if (this.config?.poll !== false) this.take(await response.json())
			}
		} catch (error) {
			if (this.run !== run) return
			this.unreachable('state', error)
			delay = UNREACHABLE_MS
		}
		if (this.run !== run || this.config?.poll === false) return
		this.timer = setTimeout(tick, delay)
	}
	tick()
}

stopPolling() {
	this.run = null
	if (this.timer) clearTimeout(this.timer)
	this.timer = null
}
```

The two early returns right after the `await` are optional, but they also stop a late answer from the old address from setting the status after the new settings are saved. An `AbortController` per run, aborted in `stopPolling()`, works just as well.

## 🔮 Next Release

### NR1: The Key is a plain text field, so anyone who sees the settings or an export can read it

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/index.js:108`](https://github.com/bitfocus/companion-module-cuemark-cuemark/blob/520480f3b50d6ac26aff1916895323de9feb7895/src/index.js#L108)

**What goes wrong:** The connection's Key field is a normal text box. Anyone who opens the connection's settings can read the Cuemark key, and when a user exports their Companion configuration (to share a page or back up a show), the key goes into the file as readable text. Nothing breaks today, and on base 1.12 there is no other option.

**Why it happens:** `@companion-module/base` 1.12, which the module is built on, has no `secret-text` config field (the field type meant for keys and passwords). It arrived in base 1.13, and the JS v1 template is now on `~1.14.1`. The module stays on 1.12 on purpose, so that it runs on Companion 4.0 ([`README.md:32-39`](https://github.com/bitfocus/companion-module-cuemark-cuemark/blob/520480f3b50d6ac26aff1916895323de9feb7895/README.md#L32-L39)).

**Fix:** when dropping Companion 4.0 support is acceptable, move `@companion-module/base` to `~1.14.1` (the v1 template's version) or to 2.x, and make the Key a `secret-text` field. Not needed for this release.

```js
{ type: 'secret-text', id: 'key', label: 'Key', width: 3, default: '' },
```

## 📝 Additional Notes

- **Fixed since the v1.2.0 review** — every finding of the [v1.2.0 review](review-cuemark-cuemark-v1.2.0-20261031-201135.md) is fixed in v1.2.1:
  - [v1.2.0 H1](review-cuemark-cuemark-v1.2.0-20261031-201135.md#h1-the-manifest-lists-a-legacy-id-although-the-module-has-never-been-published) (legacy id in the manifest): `legacyIds` is now `[]` ([`companion/manifest.json:20`](https://github.com/bitfocus/companion-module-cuemark-cuemark/blob/520480f3b50d6ac26aff1916895323de9feb7895/companion/manifest.json#L20)).
  - [v1.2.0 M1](review-cuemark-cuemark-v1.2.0-20261031-201135.md#m1-a-wrong-key-leaves-the-connection-on-connecting-with-no-error) (a wrong Key leaves Connecting): the poll now shares the button presses' answer check, so a refused key shows "Key refused — …" and any other error reply shows "Cuemark said …" ([`src/index.js:73-86`](https://github.com/bitfocus/companion-module-cuemark-cuemark/blob/520480f3b50d6ac26aff1916895323de9feb7895/src/index.js#L73-L86), [`src/index.js:276-280`](https://github.com/bitfocus/companion-module-cuemark-cuemark/blob/520480f3b50d6ac26aff1916895323de9feb7895/src/index.js#L276-L280)), and saving the settings resets the status to Connecting ([`src/index.js:49-55`](https://github.com/bitfocus/companion-module-cuemark-cuemark/blob/520480f3b50d6ac26aff1916895323de9feb7895/src/index.js#L49-L55)).
  - [v1.2.0 L1](review-cuemark-cuemark-v1.2.0-20261031-201135.md#l1-turning-off-read-what-is-on-deck-leaves-the-connection-on-connecting) (Read what is on deck off leaves Connecting): with the box unticked the module asks Cuemark once, sets the status from the answer and starts no timer, and the tooltip now says the variables and feedbacks don't update ([`src/index.js:109-118`](https://github.com/bitfocus/companion-module-cuemark-cuemark/blob/520480f3b50d6ac26aff1916895323de9feb7895/src/index.js#L109-L118), [`src/index.js:285`](https://github.com/bitfocus/companion-module-cuemark-cuemark/blob/520480f3b50d6ac26aff1916895323de9feb7895/src/index.js#L285)).
  - [v1.2.0 L2](review-cuemark-cuemark-v1.2.0-20261031-201135.md#l2-the-connection-log-fills-with-a-debug-line-twice-a-second-while-cuemark-is-closed) (a debug line twice a second while Cuemark is closed): the line is logged only when the status changes, and the poll slows to every 3 s while Cuemark doesn't answer ([`src/index.js:23-25`](https://github.com/bitfocus/companion-module-cuemark-cuemark/blob/520480f3b50d6ac26aff1916895323de9feb7895/src/index.js#L23-L25), [`src/index.js:88-93`](https://github.com/bitfocus/companion-module-cuemark-cuemark/blob/520480f3b50d6ac26aff1916895323de9feb7895/src/index.js#L88-L93)).
  - [v1.2.0 L3](review-cuemark-cuemark-v1.2.0-20261031-201135.md#l3-the-go-to-page-action-sends-a-fractional-page-number-as-typed) (fractional page number): the page is rounded to a whole page of at least 1, and the option has `step: 1` ([`src/index.js:28`](https://github.com/bitfocus/companion-module-cuemark-cuemark/blob/520480f3b50d6ac26aff1916895323de9feb7895/src/index.js#L28), [`src/index.js:149-154`](https://github.com/bitfocus/companion-module-cuemark-cuemark/blob/520480f3b50d6ac26aff1916895323de9feb7895/src/index.js#L149-L154)).
  - [v1.2.0 L4](review-cuemark-cuemark-v1.2.0-20261031-201135.md#l4-upgrade-scripts-are-declared-in-indexjs-rather-than-a-separate-upgradesjs) (upgrade scripts in index.js): they now live in [`src/upgrades.js`](https://github.com/bitfocus/companion-module-cuemark-cuemark/blob/520480f3b50d6ac26aff1916895323de9feb7895/src/upgrades.js#L7), which [`src/main.js:14-18`](https://github.com/bitfocus/companion-module-cuemark-cuemark/blob/520480f3b50d6ac26aff1916895323de9feb7895/src/main.js#L14-L18) passes to `runEntrypoint`.
  - [v1.2.0 N1](review-cuemark-cuemark-v1.2.0-20261031-201135.md#n1-every-poll-resends-all-variables-and-feedbacks-even-when-nothing-changed) (every poll resends everything): the status is sent only when it changes, and each poll sends only the variables that changed and re-checks only the feedbacks that flipped ([`src/index.js:57-66`](https://github.com/bitfocus/companion-module-cuemark-cuemark/blob/520480f3b50d6ac26aff1916895323de9feb7895/src/index.js#L57-L66), [`src/index.js:298-312`](https://github.com/bitfocus/companion-module-cuemark-cuemark/blob/520480f3b50d6ac26aff1916895323de9feb7895/src/index.js#L298-L312)).
