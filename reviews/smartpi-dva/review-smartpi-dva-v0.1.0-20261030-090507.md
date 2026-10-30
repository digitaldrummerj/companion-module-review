# Review: companion-module-smartpi-dva v0.1.0

| Field | Value |
| --- | --- |
| **Module** | `companion-module-smartpi-dva` |
| **Scope** | `tag` |
| **Version** | v0.1.0 (commit [`18073b4`](https://github.com/bitfocus/companion-module-smartpi-dva/commit/18073b4d4ab9d7d449b02d46b00afebc0b8e60e8)) |
| **Release** | New module — never published |
| **API** | 2.2 (base 2.2.1, yarn.lock) |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Previous tag** | none — first release, so there is no diff and the whole module was reviewed |
| **Reviewed** | 2026-10-30 |

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Companion passes `secret-text` config fields (here "X-API-Key") to the module in the separate `secrets` object, not in `config`, so a blank or missing key reaches the request code as described | the module's `ModuleSecrets` typing and the v2 secrets model; Companion's host side not traced | [M1](#m1-connection-stays-at-connecting-forever-when-use-x-api-key-is-ticked-but-the-key-is-blank) |
| A2 | Companion ignores a status update that arrives shortly after `destroy()`, so the late "Destroyed" status has no visible effect | base 2.2.1 `updateStatus` only forwards to the host; what the host does after teardown not checked | [L5](#l5-final-destroyed-status-is-sent-by-a-timer-up-to-2-s-after-the-module-is-destroyed) |

## 📋 Issues

### Blocking

- [ ] [H1: No feedbacks, so buttons can't show the DVA's state](#h1-no-feedbacks-so-buttons-cant-show-the-dvas-state)

### Non-blocking

- [ ] [M1: Connection stays at Connecting forever when Use X-API-Key is ticked but the key is blank](#m1-connection-stays-at-connecting-forever-when-use-x-api-key-is-ticked-but-the-key-is-blank)
- [ ] [L1: A rejected Add to Queue turns the whole connection red until the next poll](#l1-a-rejected-add-to-queue-turns-the-whole-connection-red-until-the-next-poll)
- [ ] [L2: An empty Host polls a host called api and shows a DNS error instead of a config error](#l2-an-empty-host-polls-a-host-called-api-and-shows-a-dns-error-instead-of-a-config-error)
- [ ] [L3: Endpoints the module never uses are polled every cycle and can put the connection in a warning state](#l3-endpoints-the-module-never-uses-are-polled-every-cycle-and-can-put-the-connection-in-a-warning-state)
- [ ] [L4: Allow Insecure Connections turns off TLS checking for the whole module process](#l4-allow-insecure-connections-turns-off-tls-checking-for-the-whole-module-process)
- [ ] [L5: Final Destroyed status is sent by a timer up to 2 s after the module is destroyed](#l5-final-destroyed-status-is-sent-by-a-timer-up-to-2-s-after-the-module-is-destroyed)
- [ ] [L6: Status messages after teardown go to `console.log` instead of the connection log](#l6-status-messages-after-teardown-go-to-consolelog-instead-of-the-connection-log)
- [ ] [N1: No presets, so users must build every DVA button by hand](#n1-no-presets-so-users-must-build-every-dva-button-by-hand)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟠 High

### H1: No feedbacks, so buttons can't show the DVA's state

- **Source:** 🔎 compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.ts:3-8`](https://github.com/bitfocus/companion-module-smartpi-dva/blob/18073b4d4ab9d7d449b02d46b00afebc0b8e60e8/src/feedbacks.ts#L3-L8)

**What goes wrong:** A user who adds a SmartPi DVA button in Companion gets only the "Add to Queue" action. The Feedbacks list for this connection is empty, so a button can't turn red while an announcement plays, show that a Node is offline, or show that a queue entry is Waiting. The module already polls the DVA's queue and status every "Update Interval (S)" (60 s by default), so it has this state; none of it can reach a button's look. A first release needs at least one feedback.

**Why it happens:** The feedback registration passes an empty list to Companion, and the feedback type is declared as "no feedbacks". The state the module polls (the queue, the status of all Nodes, the device status) is stored but never exposed as a feedback.

**Evidence:**

```ts
// src/feedbacks.ts:1-8
import type ModuleInstance from './main.js'

/** None yet. */
export type FeedbackSchema = Record<string, never>

export function UpdateFeedbacks(self: ModuleInstance): void {
	self.setFeedbackDefinitions({})
}
```

```ts
// src/main.ts:366-367
	#updateFeedbacks(): void {
		UpdateFeedbacks(this)
```

```ts
// src/main.ts:169
		this.#pollTimer = setInterval(() => void this.#poll(), this.config.interval * 1000)
```

A grep of `src/` for "eedback" turns up only `feedbacks.ts`, the call site in `main.ts`, a commented-out line in `upgrades.ts`, and test mocks. `git tag` lists only `v0.1.0`, so this is the first release.

**Confirm by:** open [`src/feedbacks.ts:3-8`](https://github.com/bitfocus/companion-module-smartpi-dva/blob/18073b4d4ab9d7d449b02d46b00afebc0b8e60e8/src/feedbacks.ts#L3-L8). `setFeedbackDefinitions({})` is called with an empty object, and grepping `src/` for "eedback" finds no other definitions.

**Fix:** Add at least one boolean feedback built from the state the module already polls. For example, "Announcement playing/queued" (an announcement dropdown from `getAnnouncementChoices`, an optional Waiting/Playing status, checked against `self.state.getQueue`), and/or "Node online" (a node from `getStatusAll`, true when `onlineStatus === 'Online'`). Type it in `FeedbackSchema`, then call `self.checkFeedbacks(...)` from `#poll` when `getQueue` or `getStatusAll` changes. The companion-v2-feedbacks and companion-v2-feedback-file-pattern skills show the pattern.

## 🟡 Medium

### M1: Connection stays at Connecting forever when Use X-API-Key is ticked but the key is blank

- **Source:** 🔎 protocol reviewer + QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:293-296`](https://github.com/bitfocus/companion-module-smartpi-dva/blob/18073b4d4ab9d7d449b02d46b00afebc0b8e60e8/src/main.ts#L293-L296), [`src/main.ts:244-254`](https://github.com/bitfocus/companion-module-smartpi-dva/blob/18073b4d4ab9d7d449b02d46b00afebc0b8e60e8/src/main.ts#L244-L254)

**What goes wrong:** A user ticks "Use X-API-Key" in the connection settings but leaves "X-API-Key" empty, or the key was not carried over on an import. The connection status stays yellow "Connecting – Config updated — reinitialising" and never changes. The only hint is a "Poll failed: X-API-Key is enabled but no key is configured" line in the log every "Update Interval (S)", and the "Add to Queue" action fails silently in the same way. Nothing in the connections list tells the user the problem is their configuration.

**Why it happens:** The missing-key check throws before any request is made, so it never reaches the code that sets a Connection Failure status. The poll then sees every request fail with a plain error, which matches neither of its two "show a warning" conditions, so it leaves the status alone on the assumption that the request code already reported it.

**Fix:** Check the config in `configUpdated()`: if `config.apikey && !secrets.xapikey` (or `!config.host`), set `InstanceStatus.BadConfig` with a message such as "X-API-Key is enabled but no key is configured", and return without starting polling. You can also set `BadConfig` in `sendMsg` before throwing.

## 🟢 Low

### L1: A rejected Add to Queue turns the whole connection red until the next poll

- **Source:** 🔎 protocol reviewer + QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:322-333`](https://github.com/bitfocus/companion-module-smartpi-dva/blob/18073b4d4ab9d7d449b02d46b00afebc0b8e60e8/src/main.ts#L322-L333)

**What goes wrong:** A user presses a button with "Add to Queue" for an announcement that has since been deleted on the DVA, or for a group the device refuses. The device answers 400 or 404, and the connection status turns red "Unexpected status 400", even though the device is reachable and polling works. With the default 60 s "Update Interval (S)" the connection can look broken for up to a minute, until the next successful poll sets it back to OK.

**Why it happens:** Every HTTP response, from an action as well as from a poll, is turned into a connection-wide status. A rejection of one command is therefore reported as a connection fault.

**Fix:** Set the connection status from HTTP codes only for poll requests, or only for codes that describe the connection (401/403, 5xx, 3xx). Report an action's 4xx by throwing or logging from the action callback; Companion already shows a failed action in the log.

### L2: An empty Host polls a host called api and shows a DNS error instead of a config error

- **Source:** 🔎 protocol reviewer + QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:130-147`](https://github.com/bitfocus/companion-module-smartpi-dva/blob/18073b4d4ab9d7d449b02d46b00afebc0b8e60e8/src/main.ts#L130-L147), [`src/main.ts:287`](https://github.com/bitfocus/companion-module-smartpi-dva/blob/18073b4d4ab9d7d449b02d46b00afebc0b8e60e8/src/main.ts#L287)

**What goes wrong:** A freshly added connection with no "Host" entered starts polling at once. The status shows a red Connection Failure such as "getaddrinfo ENOTFOUND api", and the log repeats the error every interval. The user would expect a "Bad config" status asking them to enter a host.

**Why it happens:** `configUpdated()` always starts polling without checking that a host is set. With an empty host the request URL becomes `http:///api/status`, which URL parsing reads as the host `api`.

**Fix:** In `configUpdated()`, if `!config.host`, set `InstanceStatus.BadConfig` with a message such as "Enter the DVA host", stop polling and return.

### L3: Endpoints the module never uses are polled every cycle and can put the connection in a warning state

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:46-48`](https://github.com/bitfocus/companion-module-smartpi-dva/blob/18073b4d4ab9d7d449b02d46b00afebc0b8e60e8/src/main.ts#L46-L48), [`src/main.ts:60-66`](https://github.com/bitfocus/companion-module-smartpi-dva/blob/18073b4d4ab9d7d449b02d46b00afebc0b8e60e8/src/main.ts#L60-L66)

**What goes wrong:** Every poll also requests the queue, destinations, regions and areas, although no action, variable, feedback or preset uses them. If one of those responses fails the module's schema check (for example a queue entry whose `queuedTime` has no timezone offset), the connection shows a yellow "1 of 7 requests failed, see log" warning on every poll even though the module works fully. A change in destinations, regions or areas also rebuilds the action list for no visible change.

**Why it happens:** The poll list is every GET endpoint in the registry, not the ones the module reads. The list that triggers an action rebuild includes destinations, regions and areas, but "Add to Queue" only reads announcements and groups. The schema comments in `src/schemas/common.ts` say these response shapes "have not yet been checked against a live Node".

**Fix:** Poll only the endpoints whose data is used (`getStatus`, `getStatusAll`, `getAnnouncements`, `getGroups`) until features use the others, and reduce `definitionSources` to `getAnnouncements` and `getGroups`.

### L4: Allow Insecure Connections turns off TLS checking for the whole module process

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:137`](https://github.com/bitfocus/companion-module-smartpi-dva/blob/18073b4d4ab9d7d449b02d46b00afebc0b8e60e8/src/main.ts#L137)

**What goes wrong:** Nothing visible changes in how the connection behaves. When a user ticks "Allow Insecure Connections", the module also switches off certificate checking for its whole process, and Node logs a warning that certificate verification is disabled. The setting is redundant: the per-connection HTTP agent already skips certificate checks for this connection only.

**Why it happens:** `configUpdated()` writes `process.env.NODE_TLS_REJECT_UNAUTHORIZED` from the setting, while `#updateDispatcher` already builds an agent with `rejectUnauthorized: false` for the insecure case.

**Fix:** Remove the `process.env.NODE_TLS_REJECT_UNAUTHORIZED = ...` line and rely on the agent, which already scopes the insecure TLS setting to this module's requests.

### L5: Final Destroyed status is sent by a timer up to 2 s after the module is destroyed

- **Source:** 🔎 protocol reviewer + QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/status.ts:96-100`](https://github.com/bitfocus/companion-module-smartpi-dva/blob/18073b4d4ab9d7d449b02d46b00afebc0b8e60e8/src/status.ts#L96-L100)

**What goes wrong:** Users see nothing (see [A2](#-assumptions-to-confirm)). When the connection is disabled or deleted, the module's last status update ("Destroyed") goes through the 2 s status throttle, so it can be sent after teardown has finished, and a pending timer is left running after `destroy()`. The timer fires once and ends, so nothing accumulates.

**Why it happens:** The status manager's `destroy()` flushes the throttle first and then queues the "Disconnected / Destroyed" update. With trailing-only throttling, that last update is held for the next window instead of running at once, and nothing cancels the timer afterwards.

**Fix:** Reverse the order and cancel: queue the Disconnected / "Destroyed" status, then call `this.setNewStatus.flush()`, then `this.setNewStatus.cancel()`. Or call the parent's `updateStatus(...)` directly and then `cancel()`.

### L6: Status messages after teardown go to `console.log` instead of the connection log

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/status.ts:81-83`](https://github.com/bitfocus/companion-module-smartpi-dva/blob/18073b4d4ab9d7d449b02d46b00afebc0b8e60e8/src/status.ts#L81-L83)

**What goes wrong:** No visible effect for users. A status update attempted after the connection is deleted or disabled is written to `console.log`, so it appears only in Companion's debug output and not in the connection's log view.

**Why it happens:** The status manager logs that case with `console.log`; API 2.x modules are expected to log through `this.log` or `createModuleLogger`.

**Fix:** Use `this.#parentInstance.log('debug', ...)`, or a `createModuleLogger('StatusManager')` instance, in place of `console.log`.

## 💡 Nice to Have

### N1: No presets, so users must build every DVA button by hand

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/presets.ts:4-6`](https://github.com/bitfocus/companion-module-smartpi-dva/blob/18073b4d4ab9d7d449b02d46b00afebc0b8e60e8/src/presets.ts#L4-L6)

**What goes wrong:** The Presets tab for a SmartPi DVA connection is empty. To queue announcement "232: WAITING OUTSIDE" on a group, a user has to create a blank button, add the "Add to Queue" action and pick the options themselves.

**Why it happens:** `UpdatePresets` registers an empty preset list.

**Fix:** Once feedbacks exist, generate one preset per announcement (and/or per group) from the polled state, in a v2 structure section such as "Announcements" with a template group, using `presetDefaults` from `consts.ts` for the style. The companion-v2-preset-category-file skill shows the pattern.

## 📝 Additional Notes

- `tsconfig.build.json`: `exclude` uses `src/**/__tests__/**` and `src/**/__mocks__/**`, where the template has `src/**/__tests__/*` and `src/**/__mocks__/*`. Fine as long as the module builds — no change required.
