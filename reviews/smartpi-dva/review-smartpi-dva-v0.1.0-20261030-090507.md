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

- [ ] [H1: CI workflow `.github/workflows/node.yaml` differs from the template](#h1-ci-workflow-githubworkflowsnodeyaml-differs-from-the-template)
- [ ] [H2: Release workflow `.github/workflows/release.yaml` differs from the template](#h2-release-workflow-githubworkflowsreleaseyaml-differs-from-the-template)
- [ ] [H3: No feedbacks, so buttons can't show the DVA's state](#h3-no-feedbacks-so-buttons-cant-show-the-dvas-state)

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

### H1: CI workflow `.github/workflows/node.yaml` differs from the template

- **Source:** 🤖 validate-template (CONFIG-DIFF). Raised to High by the review maintainer: a `.github` file the module has that differs from the template.
- **Classification:** 🆕 NEW
- **File:** [`.github/workflows/node.yaml`](https://github.com/bitfocus/companion-module-smartpi-dva/blob/18073b4d4ab9d7d449b02d46b00afebc0b8e60e8/.github/workflows/node.yaml)

**What goes wrong:** The module's CI workflow no longer matches the one every module built from `companion-module-template-ts` ships with. When a CI run behaves differently from other modules, whoever troubleshoots it has to work out the module's own variant first.

**Why it happens:** The workflow was edited by hand. It adds a top-level permissions block, drops the template's `persist-credentials: false` on checkout, moves `actions/setup-node` to `@v7`, adds a `yarn test:types` step, and turns the template's commented-out `test` job into a different live job that uploads coverage to Codecov.

**Evidence:**

- [`.github/workflows/node.yaml:11-12`](https://github.com/bitfocus/companion-module-smartpi-dva/blob/18073b4d4ab9d7d449b02d46b00afebc0b8e60e8/.github/workflows/node.yaml#L11-L12) adds `permissions: contents: read`.
- [`.github/workflows/node.yaml:21`](https://github.com/bitfocus/companion-module-smartpi-dva/blob/18073b4d4ab9d7d449b02d46b00afebc0b8e60e8/.github/workflows/node.yaml#L21) drops the template's `with: persist-credentials: false` on `actions/checkout@v7` (template lines 18-20).
- [`.github/workflows/node.yaml:24`](https://github.com/bitfocus/companion-module-smartpi-dva/blob/18073b4d4ab9d7d449b02d46b00afebc0b8e60e8/.github/workflows/node.yaml#L24) and [`:56`](https://github.com/bitfocus/companion-module-smartpi-dva/blob/18073b4d4ab9d7d449b02d46b00afebc0b8e60e8/.github/workflows/node.yaml#L56) use `actions/setup-node@v7` where the template has `@v6` (template line 23).
- [`.github/workflows/node.yaml:38`](https://github.com/bitfocus/companion-module-smartpi-dva/blob/18073b4d4ab9d7d449b02d46b00afebc0b8e60e8/.github/workflows/node.yaml#L38) adds `yarn test:types`.
- [`.github/workflows/node.yaml:47-81`](https://github.com/bitfocus/companion-module-smartpi-dva/blob/18073b4d4ab9d7d449b02d46b00afebc0b8e60e8/.github/workflows/node.yaml#L47-L81) replaces the template's commented-out `test` job with a live job that runs `yarn test:coverage` and uploads coverage with `codecov/codecov-action@v7`.
- The template's "Prepare Environment (For template repository)" step is removed. That removal is expected in a module.

```diff
+permissions:
+  contents: read
+
       - uses: actions/checkout@v7
-        with:
-          persist-credentials: false
-        uses: actions/setup-node@v6
+        uses: actions/setup-node@v7
           yarn build
+          yarn test:types
```

**Confirm by:** `diff companion-module-template-ts/.github/workflows/node.yaml .github/workflows/node.yaml` prints nothing, apart from the template-repository-only step and the template's own commented test job being uncommented.

**Fix:** Copy `.github/workflows/node.yaml` from `companion-module-template-ts`. If you want to run unit tests, uncomment the template's `test` job as it ships.

### H2: Release workflow `.github/workflows/release.yaml` differs from the template

- **Source:** 🤖 validate-template (CONFIG-DIFF). Raised to High by the review maintainer: a `.github` file the module has that differs from the template.
- **Classification:** 🆕 NEW
- **File:** [`.github/workflows/release.yaml`](https://github.com/bitfocus/companion-module-smartpi-dva/blob/18073b4d4ab9d7d449b02d46b00afebc0b8e60e8/.github/workflows/release.yaml)

**What goes wrong:** When a GitHub release is published, this module builds and attaches its package with its own script instead of the shared Bitfocus module-checks workflow. The attached package is a `--dev` build, and it is named differently from what every other module's release produces.

**Why it happens:** The template's two jobs were replaced with one hand-rolled job. The template's `package` job calls `bitfocus/actions/.github/workflows/module-checks.yaml@main` (with `git-ref`, `prerelease` and `upload-artifact: true`), and its `attach` job downloads that artifact and renames `pkg.tgz` to a standard asset name. The module's job checks out the tag, runs `yarn install` and `yarn package --dev [--prerelease]`, and uploads `./*.tgz` itself.

**Evidence:**

- [`.github/workflows/release.yaml:10-13`](https://github.com/bitfocus/companion-module-smartpi-dva/blob/18073b4d4ab9d7d449b02d46b00afebc0b8e60e8/.github/workflows/release.yaml#L10-L13) adds a comment block.
- [`.github/workflows/release.yaml:15-65`](https://github.com/bitfocus/companion-module-smartpi-dva/blob/18073b4d4ab9d7d449b02d46b00afebc0b8e60e8/.github/workflows/release.yaml#L15-L65) replaces the template's `package` and `attach` jobs (template lines 10-53) with one `package` job; `timeout-minutes` is 15 against the template's 5.
- [`.github/workflows/release.yaml:41-57`](https://github.com/bitfocus/companion-module-smartpi-dva/blob/18073b4d4ab9d7d449b02d46b00afebc0b8e60e8/.github/workflows/release.yaml#L41-L57) runs `yarn package --dev [--prerelease]`.
- [`.github/workflows/release.yaml:63`](https://github.com/bitfocus/companion-module-smartpi-dva/blob/18073b4d4ab9d7d449b02d46b00afebc0b8e60e8/.github/workflows/release.yaml#L63) uploads with `gh release upload "${{ github.event.release.tag_name }}" ./*.tgz --clobber`, dropping the template's asset-naming logic and its `--repo "$GITHUB_REPOSITORY"` / `TAG` env.

```yaml
# template release.yaml:20-25
    uses: bitfocus/actions/.github/workflows/module-checks.yaml@main
    with:
      git-ref: ${{ github.event.release.tag_name }}
      prerelease: ${{ github.event.release.prerelease }}
      upload-artifact: true
```

**Confirm by:** `diff companion-module-template-ts/.github/workflows/release.yaml .github/workflows/release.yaml` prints nothing.

**Fix:** Copy `.github/workflows/release.yaml` from `companion-module-template-ts` unchanged.

### H3: No feedbacks, so buttons can't show the DVA's state

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
