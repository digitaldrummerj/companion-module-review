# Follow-up Review: companion-module-stagetec-xci v2.0.1

| Field | Value |
| --- | --- |
| **Module** | `companion-module-stagetec-xci` |
| **Scope** | `tag` (`v1.3.1..v2.0.1`) |
| **Version** | v2.0.1 |
| **Release** | Update — last published v1.3.1 |
| **API** | 2.2 (base 2.2.2, yarn.lock) — requires Companion 5.1+ |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Commit** | [`b2fdf4c`](https://github.com/bitfocus/companion-module-stagetec-xci/tree/b2fdf4c4b04b683855529815155e289e3da844e0) |
| **Follow-up to** | [v2.0.0 review](review-stagetec-xci-v2.0.0-20261106-181511.md) (Changes Required) |
| **Reviewed** | 2026-11-09 |

## Verdict: ✅ Approved

## ❓ Assumptions

Some findings depend on assumptions the reviewers couldn't check. They're listed in [❓ Assumptions to Confirm](#-assumptions-to-confirm) at the end of this review.

## 📋 Issues

### Non-blocking

- [ ] [M1: An unreadable SNMP reply crashes the connection and wipes every latch and count](#m1-an-unreadable-snmp-reply-crashes-the-connection-and-wipes-every-latch-and-count)
- [ ] [L1: Refresh turns back on latches the operator just reset while the logic cell is still true](#l1-refresh-turns-back-on-latches-the-operator-just-reset-while-the-logic-cell-is-still-true)
- [ ] [N1: Typos in the first sentence of the module's Help page](#n1-typos-in-the-first-sentence-of-the-modules-help-page)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟡 Medium

### M1: An unreadable SNMP reply crashes the connection and wipes every latch and count

- **Source:** 🔎 protocol reviewer + QA reviewer
- **Classification:** 🆕 NEW (present since v2.0.0; the v2.0.0 review missed it)
- **File:** [`src/client.ts:34-41`](https://github.com/bitfocus/companion-module-stagetec-xci/blob/b2fdf4c4b04b683855529815155e289e3da844e0/src/client.ts#L34-L41)

**What goes wrong:** This affects anyone running an XCI connection. The module reads the XCI's status every 10 seconds by default, and reads the logic cells at start and when someone presses Refresh. If a packet that isn't valid SNMP reaches the UDP port those reads use, the module's process crashes. That could be a truncated or corrupted reply, or a stray packet from a network scanner. Companion then restarts the connection (see [A1](#-assumptions-to-confirm), [A2](#-assumptions-to-confirm)). Latches and counts are kept only in memory, so after the restart every logic cell's Latch and Count variables start again: for example `cellCount_12` goes from 37 to 0 and `cellLatch_12` from true to false. Most Recent Trigger goes back to 0, and the XCI SNMP Trap - Latched feedbacks turn off on the buttons. The connection log gives no clear reason. If the module handled the error, the bad packet would just be dropped: the read would time out, and the connection would show the usual yellow "Reading the Nexus status failed" warning instead.

**Why it happens:** The SNMP client (`XciClient`) opens a net-snmp session but never listens for its `'error'` event. net-snmp parses every packet that arrives on the session's socket, from any sender, and when parsing fails it emits `'error'`. In Node, an `'error'` event with no listener is thrown as an exception. Here it's thrown inside the socket's message handler, where nothing catches it, and `@companion-module/base` 2.2.2 installs no `uncaughtException` handler, so the process exits. The reviewer reproduced this with the module's net-snmp 3.29.2: a fake agent answered a session created with the same options as `XciClient` with 5 bytes of garbage, and the script exited with code 1 and "Unhandled 'error' event ... at Session.onMsg". The net-snmp README documents `session.on("error", callback)` as the way to handle this. v1.3.1 had no SNMP client session, so this arrived with the 2.0 rewrite.

**Evidence:**

```ts
// src/client.ts:34-41
	constructor(host: string, community: string, options: XciClientOptions) {
		this.#session = snmp.createSession(host, community, {
			version: options.version === 'v1' ? snmp.Version1 : snmp.Version2c,
			port: options.port,
			timeout: options.timeout ?? DEFAULT_TIMEOUT,
			retries: options.retries ?? DEFAULT_RETRIES,
		})
	}
```

```js
// node_modules/net-snmp/index.js:2458-2464  (net-snmp 3.29.2)
Session.prototype.onMsg = function (buffer) {
	try {
		var message = Message.createFromBuffer (buffer);
	} catch (error) {
		this.emit("error", error);
		return;
	}
```

**Confirm by:** open [`src/client.ts:34-41`](https://github.com/bitfocus/companion-module-stagetec-xci/blob/b2fdf4c4b04b683855529815155e289e3da844e0/src/client.ts#L34-L41). There is no `.on('error', …)` on the session, and nothing else in `src/` adds one (`grep -rn "'error'" src`).

**Fix:** listen for the session's `'error'` event when it's created, and log the error instead of letting it be thrown. Pass a log callback into `XciClient`, for example:

```ts
this.#session = snmp.createSession(host, community, { ... })
// net-snmp emits 'error' for a reply it can't parse; with no listener it crashes the module
;(this.#session as unknown as EventEmitter).on('error', (err: Error) => onError?.(err))
```

To skip the cast, declare `on(event: 'error', listener: (error: Error) => void): this` on `Session` in `src/net-snmp.d.ts` (`@types/net-snmp` leaves it out). In `#startPolling`, pass something like ``(err) => this.log('warn', `SNMP session error: ${err.message}`)``. The request whose reply was bad then times out as normal, and the status poll's existing warning covers it.

## 🟢 Low

### L1: Refresh turns back on latches the operator just reset while the logic cell is still true

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW (Refresh path since v2.0.0; the re-read after a failed cell read is new in v2.0.1)
- **File:** [`src/main.ts:143-149`](https://github.com/bitfocus/companion-module-stagetec-xci/blob/b2fdf4c4b04b683855529815155e289e3da844e0/src/main.ts#L143-L149), [`src/main.ts:253-262`](https://github.com/bitfocus/companion-module-stagetec-xci/blob/b2fdf4c4b04b683855529815155e289e3da844e0/src/main.ts#L253-L262), [`src/main.ts:300-301`](https://github.com/bitfocus/companion-module-stagetec-xci/blob/b2fdf4c4b04b683855529815155e289e3da844e0/src/main.ts#L300-L301), [`src/xci.ts:136-143`](https://github.com/bitfocus/companion-module-stagetec-xci/blob/b2fdf4c4b04b683855529815155e289e3da844e0/src/xci.ts#L136-L143)

**What goes wrong:** Logic cell 12 goes true, and its trap turns on the "Logic Cell Latch 12" variable and the XCI SNMP Trap - Latched feedback. The operator acknowledges it with Reset Latch (cell 12), and the latch goes false, while cell 12 is still true on the Nexus. Later someone presses Refresh to update the health values. Latch 12 comes back on, and so does every other latch that was reset while its cell is still true, although no new trap arrived. The automatic cell re-read added in v2.0.1 (after a status read succeeds following a failed cell read) does the same. The Help says a latch "Goes true when an SNMP trap is received" and "Stays true until reset", and it mentions cell reads setting latches only at start and on a config change, not on Refresh.

**Why it happens:** The Refresh action reads every logic cell again, and the module applies each reading the same way it does at start: a cell found true sets its latch if the latch is clear (`LogicCells.setValue`). Nothing records that the operator cleared that latch on purpose. The comment on `setValue` says a cell found true sets its latch "as it has been true since the last reset", so this may be intended. If so, the Help should say so.

**Fix:** choose one of these:

- Let only the first cell read after start or a config change set latches. Pass a flag into `#pollLogicCells` from `#startPolling`, and have `refresh()` and the status-triggered re-read call it with latching off.
- If re-latching is intended, document it in HELP.md under the Refresh action and the Logic Cell Latch variable, so operators know Refresh turns acknowledged latches back on while the cell is still true.

## 💡 Nice to Have

### N1: Typos in the first sentence of the module's Help page

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`companion/HELP.md:5`](https://github.com/bitfocus/companion-module-stagetec-xci/blob/b2fdf4c4b04b683855529815155e289e3da844e0/companion/HELP.md#L5)

**What goes wrong:** A user who opens the module's Help in Companion reads "This module is an system monitor amd SNMP trap receiver …" as the first sentence. It should read "a system monitor and SNMP trap receiver". The same sentence says the module "allows boolean feedbacks to be created", which is out of date now that the release adds the Base Device Health, System Health and Active Errors value feedbacks. Nothing functional is affected.

**Why it happens:** Commit `ada8159` ("typos in HELP.md") rewrote the sentence. It fixed "reciever" but added "an system" and "amd". In v1.3.1 the sentence read "This module is a SNMP trap reciever …".

**Fix:** change [`companion/HELP.md:5`](https://github.com/bitfocus/companion-module-stagetec-xci/blob/b2fdf4c4b04b683855529815155e289e3da844e0/companion/HELP.md#L5) to something like: "This module is a system monitor and SNMP trap receiver for the Stagetec Nexus XCI. It reads the Nexus status and the logic-configurable traps, so boolean and value feedbacks can show it and trigger events in Companion based on logic configured in Nexus Service." While editing, you could also fix the older "reciever" in the [`companion/manifest.json`](https://github.com/bitfocus/companion-module-stagetec-xci/blob/b2fdf4c4b04b683855529815155e289e3da844e0/companion/manifest.json#L7) description, which this release didn't touch.

## 📝 Additional Notes

- This follows up the [v2.0.0 review](review-stagetec-xci-v2.0.0-20261106-181511.md). v2.0.0 was never published, so the tag scope is still `v1.3.1..v2.0.1`; the v2.0.0..v2.0.1 delta (`93f905f`..`b2fdf4c`) fixes all five of its findings and adds no new problem apart from the Help typos in [N1](#n1-typos-in-the-first-sentence-of-the-modules-help-page).
- v2.0.0 C1 (Yarn config approved installs from any git repository): fixed in `93f905f`. [`.yarnrc.yml`](https://github.com/bitfocus/companion-module-stagetec-xci/blob/b2fdf4c4b04b683855529815155e289e3da844e0/.yarnrc.yml) no longer has `approvedGitRepositories`, and the validator no longer reports it.
- v2.0.0 M1 (Logic Cell field stopped following an expression on Reset All): fixed in `742ea51`. Reset All now sets `disableAutoExpression: true` ([`src/options.ts:25-31`](https://github.com/bitfocus/companion-module-stagetec-xci/blob/b2fdf4c4b04b683855529815155e289e3da844e0/src/options.ts#L25-L31)).
- v2.0.0 L1 (connection stayed yellow after a failed logic cell read): fixed in `8d30e24`. A successful status read now reads the cells again when the last cell read failed ([`src/main.ts:300-301`](https://github.com/bitfocus/companion-module-stagetec-xci/blob/b2fdf4c4b04b683855529815155e289e3da844e0/src/main.ts#L300-L301)), and the Help explains it.
- v2.0.0 N1 (code comment about crosspoint and alarm feedbacks): fixed in `031422e`. The router wording is gone from [`src/subscriptions.ts:1-4`](https://github.com/bitfocus/companion-module-stagetec-xci/blob/b2fdf4c4b04b683855529815155e289e3da844e0/src/subscriptions.ts#L1-L4).
- v2.0.0 N2 (spelling in the Help and a log message): fixed in `ada8159` and `031422e`. The Help now says "received" and "occurred", and so does the Nexus error log line ([`src/main.ts:420`](https://github.com/bitfocus/companion-module-stagetec-xci/blob/b2fdf4c4b04b683855529815155e289e3da844e0/src/main.ts#L420)).
- `031422e` also removed the module's own check for traps from an unexpected IP. That check was dead code: the socket wrapper already drops every packet not from the configured XCI address ([`src/wrapper.ts:34-40`](https://github.com/bitfocus/companion-module-stagetec-xci/blob/b2fdf4c4b04b683855529815155e289e3da844e0/src/wrapper.ts#L34-L40)).

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Companion's module host for API 2.x modules doesn't catch an uncaught exception in the module's process, so an unhandled `'error'` event from the net-snmp session ends that process | `@companion-module/base` 2.2.2 registers no `uncaughtException` or `unhandledRejection` handler (its `dist` was searched), and the crash was reproduced with plain Node and net-snmp 3.29.2. Companion's host-side entrypoint wasn't checked | [M1](#m1-an-unreadable-snmp-reply-crashes-the-connection-and-wipes-every-latch-and-count) |
| A2 | When a module's process exits on a crash, Companion restarts the connection and runs `init()` again, so the logic cells' latches and counts start again from false and 0 instead of keeping their values | The latches and counts live only in memory (`LogicCells`, `src/xci.ts`) and are never saved. Companion's restart behaviour wasn't checked in its source | [M1](#m1-an-unreadable-snmp-reply-crashes-the-connection-and-wipes-every-latch-and-count) |
