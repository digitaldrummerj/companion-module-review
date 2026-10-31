# Review: companion-module-cuemark-cuemark v1.2.0

| | |
| --- | --- |
| **Module** | `companion-module-cuemark-cuemark` |
| **Scope** | `tag` — first release, so there is no previous tag to diff against: the whole module was reviewed and every finding is 🆕 NEW |
| **Version** | `v1.2.0` ([`f22be15`](https://github.com/bitfocus/companion-module-cuemark-cuemark/tree/f22be15beba189d369b0fe2e458c0a7cb481d434)) |
| **Release** | New module — never published |
| **API** | 1 (base 1.12.1, yarn.lock) |
| **Template** | `companion-module-template-js-v1` @ `9e222b4` (2026-03-26, pinned) · `.yarnrc.yml` from `companion-module-template-js` @ `76d25b2` (2026-10-11) |
| **Build** | `yarn install --immutable` and `yarn package` pass |
| **Date** | 2026-10-31 |

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Companion does not quietly drop repeated identical status updates, so a module that reports the same status twice a second costs real work on the host | base 1.12 `updateStatus` sends one IPC message per call with no dedupe (`node_modules/@companion-module/base/dist/module-api/base.js:474-479`); Companion's host handling not checked | [L2](#l2-the-connection-log-fills-with-a-debug-line-twice-a-second-while-cuemark-is-closed), [N1](#n1-every-poll-resends-all-variables-and-feedbacks-even-when-nothing-changed) |
| A2 | Companion shows a connection's `debug` level log lines in that connection's log view, so the per-poll debug lines reach the user | general Companion behaviour; not checked in the module or base | [L2](#l2-the-connection-log-fills-with-a-debug-line-twice-a-second-while-cuemark-is-closed) |

## 📋 Issues

### Blocking

- [ ] [C1: .gitignore is missing five of the template's entries](#c1-gitignore-is-missing-five-of-the-templates-entries)

### Non-blocking

- [ ] [M1: A wrong Key leaves the connection on Connecting with no error](#m1-a-wrong-key-leaves-the-connection-on-connecting-with-no-error)
- [ ] [L1: Turning off Read what is on deck leaves the connection on Connecting](#l1-turning-off-read-what-is-on-deck-leaves-the-connection-on-connecting)
- [ ] [L2: The connection log fills with a debug line twice a second while Cuemark is closed](#l2-the-connection-log-fills-with-a-debug-line-twice-a-second-while-cuemark-is-closed)
- [ ] [L3: The Go to page action sends a fractional page number as typed](#l3-the-go-to-page-action-sends-a-fractional-page-number-as-typed)
- [ ] [L4: Upgrade scripts are declared in index.js rather than a separate upgrades.js](#l4-upgrade-scripts-are-declared-in-indexjs-rather-than-a-separate-upgradesjs)
- [ ] [N1: Every poll resends all variables and feedbacks even when nothing changed](#n1-every-poll-resends-all-variables-and-feedbacks-even-when-nothing-changed)

## 🔴 Critical

### C1: .gitignore is missing five of the template's entries

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.gitignore`](https://github.com/bitfocus/companion-module-cuemark-cuemark/blob/f22be15beba189d369b0fe2e458c0a7cb481d434/.gitignore)

**What goes wrong:** The module's `.gitignore` doesn't match the one every Companion module starts from. Anyone who builds or debugs the module from this repo can end up committing files the template keeps out, such as an npm `package-lock.json` next to `yarn.lock`, or `DEBUG-*` files other than `DEBUG-PACKAGED`. It also makes the repo look different from every other module when someone later troubleshoots a build.

**Why it happens:** The file was written by hand. It covers similar ground (`pkg/`, `*.tgz`, `.yarn/`), but not with the template's entries, and two of the template's entries are missing altogether.

**Evidence:**

```text
Template expects (companion-module-template-js-v1 @ 9e222b4):
  node_modules/
  package-lock.json
  /pkg
  /*.tgz
  DEBUG-*
  /.yarn

Found:
  node_modules/
  pkg/
  *.tgz
  DEBUG-PACKAGED
  # Yarn, as Bitfocus builds modules with it.
  .yarn/
  .pnp.*

Missing: package-lock.json, /pkg, /*.tgz, DEBUG-*, /.yarn
```

**Confirm by:** open [`.gitignore`](https://github.com/bitfocus/companion-module-cuemark-cuemark/blob/f22be15beba189d369b0fe2e458c0a7cb481d434/.gitignore) and compare it with the template's list above.

**Fix:** add the template's entries exactly as written. Extra entries of your own, such as `.pnp.*`, can stay.

```text
node_modules/
package-lock.json
/pkg
/*.tgz
DEBUG-*
/.yarn
.pnp.*
```

## 🟡 Medium

### M1: A wrong Key leaves the connection on Connecting with no error

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/index.js:220-229`](https://github.com/bitfocus/companion-module-cuemark-cuemark/blob/f22be15beba189d369b0fe2e458c0a7cb481d434/src/index.js#L220-L229), [`src/index.js:39-43`](https://github.com/bitfocus/companion-module-cuemark-cuemark/blob/f22be15beba189d369b0fe2e458c0a7cb481d434/src/index.js#L39-L43)

**What goes wrong:** A user adds the Cuemark connection and types the Key wrong (say `K3Y` instead of `K3X`), or leaves it empty. The Connections page shows the yellow "Connecting" status forever with no message, the variables (`deck`, `deckNumber`, `taken`, …) stay empty and the feedbacks never light. The user only sees "Key refused — check it in Cuemark ▸ Settings ▸ Show control ▸ Companion" after pressing a button such as GO, and that press doesn't reach Cuemark. The same happens on a connection that was working when the key is regenerated in Cuemark: the status stays green "OK" while the variables silently stop updating. Any other error reply from Cuemark (a 500, for example) behaves the same way.

**Why it happens:** The "Read what is on deck" poll asks Cuemark for `/state` twice a second. When Cuemark refuses (the module's own stand-in Cuemark in [`scripts/host-test.mjs:42-54`](https://github.com/bitfocus/companion-module-cuemark-cuemark/blob/f22be15beba189d369b0fe2e458c0a7cb481d434/scripts/host-test.mjs#L42-L54) answers 401 for a wrong key), the poll just returns without updating the status. Only a good reply (OK) or a network failure changes the status. The button path (`send()`) already turns 401/403 into a "Key refused" error and other error replies into "Cuemark said …", but the poll doesn't share that logic, and `configUpdated()` never puts the status back to Connecting when the settings change.

**Evidence:**

```js
// src/index.js:223-224
const response = await fetch(url(this.config, '/state'));
if (!response.ok) return;
// src/index.js:74-81 (send(), for comparison)
if (response.status === 401 || response.status === 403) {
  this.updateStatus(InstanceStatus.BadConfig, 'Key refused — check it in Cuemark ▸ Settings ▸ Show control ▸ Companion');
  return;
}
if (!response.ok) {
  this.updateStatus(InstanceStatus.UnknownError, `Cuemark said ${response.status}`);
  return;
}
```

**Fix:** give the poll the same status handling as `send()`, ideally through one shared helper, and reset the status when the settings change.

```js
// in tick()
if (response.status === 401 || response.status === 403) {
  this.updateStatus(InstanceStatus.BadConfig, 'Key refused — check it in Cuemark ▸ Settings ▸ Show control ▸ Companion');
  return;
}
if (!response.ok) {
  this.updateStatus(InstanceStatus.UnknownError, `Cuemark said ${response.status}`);
  return;
}

// in configUpdated(), before this.poll()
this.updateStatus(InstanceStatus.Connecting);
```

## 🟢 Low

### L1: Turning off Read what is on deck leaves the connection on Connecting

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/index.js:24-33`](https://github.com/bitfocus/companion-module-cuemark-cuemark/blob/f22be15beba189d369b0fe2e458c0a7cb481d434/src/index.js#L24-L33), [`src/index.js:219-236`](https://github.com/bitfocus/companion-module-cuemark-cuemark/blob/f22be15beba189d369b0fe2e458c0a7cb481d434/src/index.js#L219-L236)

**What goes wrong:** A user unticks "Read what is on deck" (for example on a busy booth machine) and saves. The connection shows yellow "Connecting" until a button such as GO is pressed, so nothing tells them whether the host, port and key are right. The feedbacks (Show mode is running, Booth dim is on, The main has gone quiet, …) and the variables freeze or stay empty, so presets such as SHOW MODE, Booth dim and TAKE OVER never light. The checkbox tooltip only says the poll lets buttons show the next cue; it doesn't say every feedback stops too. A 500 ms timer also keeps running and does nothing.

**Why it happens:** `init()` sets the status to Connecting, and each poll tick returns at once when the box is unticked, so nothing ever confirms the connection. `poll()` still starts the 500 ms interval either way.

**Fix:** when polling is off, don't start the interval. Either make one `/state` request so the status reflects whether Cuemark answers, or set a neutral status such as `this.updateStatus(InstanceStatus.Ok, 'Not reading state')`, and say in the tooltip that feedbacks and variables won't update while it is off. `configUpdated()` already clears the old timer and calls `poll()` again, so the checkbox will start or skip the interval as expected.

### L2: The connection log fills with a debug line twice a second while Cuemark is closed

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/index.js:230-236`](https://github.com/bitfocus/companion-module-cuemark-cuemark/blob/f22be15beba189d369b0fe2e458c0a7cb481d434/src/index.js#L230-L236)

**What goes wrong:** When Cuemark isn't running (between shows, or with the machine off), the connection log gets a debug line such as `state: http://127.0.0.1:53000/state?key=… ECONNREFUSED` twice a second, about 7,200 lines an hour, which buries anything useful. Each failed poll also re-sends the same "Cuemark is not answering" status to Companion.

**Why it happens:** The poll runs every 500 ms, and its error handler logs and updates the status on every failure without checking whether the previous poll already failed the same way.

**Fix:** remember the last poll result (for example `this.lastPollError`) and only log and call `updateStatus` when it changes. Optionally poll more slowly (every 2–5 s) while Cuemark is unreachable, and go back to 500 ms once it answers.

### L3: The Go to page action sends a fractional page number as typed

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/index.js:108-109`](https://github.com/bitfocus/companion-module-cuemark-cuemark/blob/f22be15beba189d369b0fe2e458c0a7cb481d434/src/index.js#L108-L109)

**What goes wrong:** In the "Go to page…" action, a user types 12.5 into "Printed page number" by mistake. The module sends `/page/12.5` to Cuemark instead of page 12 or 13, so the button may do nothing or land somewhere unexpected. The line count of "Jump down several lines" is rounded, but the page number isn't.

**Why it happens:** The action converts the option with `Number(event.options.page) || 1` and never rounds it, and the number option has no whole-number step.

**Fix:** round and clamp the value, the same way the line count is handled, and optionally add `step: 1` to the option.

```js
callback: async (event) => this.send(GOTO_PAGE.route(Math.max(1, Math.round(Number(event.options.page) || 1)))),
```

### L4: Upgrade scripts are declared in index.js rather than a separate upgrades.js

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/index.js:240-246`](https://github.com/bitfocus/companion-module-cuemark-cuemark/blob/f22be15beba189d369b0fe2e458c0a7cb481d434/src/index.js#L240-L246)

**What goes wrong:** Users see no difference today, because the list is empty. But the JS v1 template keeps upgrade scripts in their own `src/upgrades.js`, and once an action or option ID is renamed, that is where the next maintainer will look for them.

**Why it happens:** `export const UpgradeScripts = [];` sits at the bottom of the instance class file.

**Fix:** create `src/upgrades.js` that exports `UpgradeScripts` (an empty array for now), import it in [`src/main.js`](https://github.com/bitfocus/companion-module-cuemark-cuemark/blob/f22be15beba189d369b0fe2e458c0a7cb481d434/src/main.js#L14) and pass it to `runEntrypoint(CuemarkInstance, UpgradeScripts)`. Remove the export from `src/index.js` and update [`src/selftest.js:21-23`](https://github.com/bitfocus/companion-module-cuemark-cuemark/blob/f22be15beba189d369b0fe2e458c0a7cb481d434/src/selftest.js#L21-L23) to match.

## 💡 Nice to Have

### N1: Every poll resends all variables and feedbacks even when nothing changed

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/index.js:226-229`](https://github.com/bitfocus/companion-module-cuemark-cuemark/blob/f22be15beba189d369b0fe2e458c0a7cb481d434/src/index.js#L226-L229)

**What goes wrong:** Users see no change. But twice a second the module sends all 13 variable values, re-checks all 7 feedbacks and re-sends the OK status to Companion, even while the show is paused and nothing in Cuemark has changed. On a busy Companion with many buttons showing `$(cuemark:…)` variables, that is needless redraw work.

**Why it happens:** Each poll pushes the whole state to Companion without comparing it with the previous one.

**Fix:** compare the new state with `this.state` (per key, or with `JSON.stringify`). Send only the variables whose values changed, call `checkFeedbacks` only for the feedbacks whose inputs changed, and call `updateStatus(InstanceStatus.Ok)` only when the status wasn't already OK.
