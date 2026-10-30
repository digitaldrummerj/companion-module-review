# Review: companion-module-thenoteslist-thenoteslist v1.2.5 (follow-up)

| | |
| --- | --- |
| **Module** | `companion-module-thenoteslist-thenoteslist` ([repo](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist)) |
| **Scope** | `tag` |
| **Version** | v1.2.5 (`d0d442f`) |
| **Release** | New module — never published |
| **API** | 1 (base 1.14.1, yarn.lock) |
| **Template** | `companion-module-template-ts-v1` @ `42609d8` (2026-03-03, pinned) · `.yarnrc.yml` from `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Previous tag** | none (first release, so the whole module was reviewed) |
| **Prior review** | [v1.0.0 review](review-thenoteslist-thenoteslist-v1.0.0-20261005-024911.md) (❌ Changes Required) |
| **Language** | TypeScript |
| **Build** | `yarn install --immutable`, `yarn package` and `yarn lint` all pass |
| **Transports** | HTTP (global `fetch`, polling the cloud API) · OSC over TCP to an ETC Eos desk (`node-osc` 11.7.1, read-only) |
| **Review date** | 2026-10-30 |

This is still the module's first release: no earlier tag was ever published, so there is no previous tag to diff against and the whole module was reviewed. Every finding below is classified as new.

**Follow-up to the v1.0.0 review:** this review checks the maintainer's changes against the [v1.0.0 review](review-thenoteslist-thenoteslist-v1.0.0-20261005-024911.md). All of that review's findings are resolved in v1.2.5:

- **Blocking (C1–C13, H1–H3):** the template check now reports no findings. The module uses yarn 4 with a committed `yarn.lock`, `.yarnrc.yml` and `packageManager`. It has the template's scripts, devDependencies, husky/lint-staged, template files, `.gitignore` entries, a Node 22 manifest and `.github` files. Actions, feedbacks, presets, variables and upgrade scripts are in their own files. A clean checkout packages and lints. (Under the current review rules, the old C11 eslint extension and the H1 LICENSE copyright line would not be raised anyway.)
- **Non-blocking (M1–M8, L1–L11, N1–N6):** each one is fixed in the code. Keep cursor offset is measured against the old live cue, and the Eos feedback follows a real connected flag. A generation counter guards stale async work. Requests time out after 10 s, polls cannot overlap, and the token is moved into Companion's secrets by an upgrade script. The Eos reader restarts only when its settings change, and it destroys its socket. `osc` was replaced by `node-osc`. Reconnects back off with a connect timeout, and errors are logged. Cue counts are capped, and the walk flags reset on reconnect. Option visibility uses expressions, the Base URL is validated, the banner is HTML-escaped, and every action has a description.

The findings below are new in this version. None of them blocks the release.

## Verdict: ✅ Approved

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | In `@companion-module/base` 1.14 with its matching Companion host, `saveConfig()` does not call the module's `configUpdated()` back, so nothing else resets the connected flag and counts after "Start pairing" saves the cleared token | the module's own comments ([`src/main.ts:149`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/d0d442f8f6205d6f339bd8d88ea10132c7bb5ae9/src/main.ts#L149), [`src/main.ts:242`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/d0d442f8f6205d6f339bd8d88ea10132c7bb5ae9/src/main.ts#L242)) and general Companion 3.x/4.x behaviour; the host source was not checked | [L1](#l1-the-connected-key-and-outstanding-counts-keep-showing-the-old-show-after-re-pairing-starts) |
| A2 | Companion sends a connection's existing feedbacks to the module once, after `init()`, and does not re-evaluate them when the module later sends new definitions with `setFeedbackDefinitions()`; a feedback is only re-run when the module calls `checkFeedbacks` or the user edits it | the module side was read (`node_modules/@companion-module/base/dist/internal/feedback.js:225-246` only stores and forwards the definitions); the Companion host side was not checked | [M1](#m1-type-and-priority-colour-feedbacks-stay-uncoloured-after-companion-starts) |
| A3 | No build of this module was ever handed out to users under the module id `thenoteslist` | `newModule=true` in the fact sheet; the repo has unpublished local tags v1.0.0–v1.2.1 and an upgrade script that mentions 1.0.0, so private distribution is possible | [N5](#n5-the-manifest-lists-a-legacy-id-for-a-module-that-was-never-published) |

## 📋 Issues

### Non-blocking

- [ ] [M1: Type and priority colour feedbacks stay uncoloured after Companion starts](#m1-type-and-priority-colour-feedbacks-stay-uncoloured-after-companion-starts)
- [ ] [L1: The Connected key and outstanding counts keep showing the old show after re-pairing starts](#l1-the-connected-key-and-outstanding-counts-keep-showing-the-old-show-after-re-pairing-starts)
- [ ] [L2: A pairing code stays on screen when the server cannot be reached](#l2-a-pairing-code-stays-on-screen-when-the-server-cannot-be-reached)
- [ ] [L3: New note parses a cue number Companion has already resolved](#l3-new-note-parses-a-cue-number-companion-has-already-resolved)
- [ ] [N1: An unreachable Eos desk does not show in the connection status](#n1-an-unreachable-eos-desk-does-not-show-in-the-connection-status)
- [ ] [N2: The pairing log line always says the code expires in 10 minutes](#n2-the-pairing-log-line-always-says-the-code-expires-in-10-minutes)
- [ ] [N3: Go to module presets do not light up when notes are outstanding](#n3-go-to-module-presets-do-not-light-up-when-notes-are-outstanding)
- [ ] [N4: Feedbacks have no descriptions in the feedback picker](#n4-feedbacks-have-no-descriptions-in-the-feedback-picker)
- [ ] [N5: The manifest lists a legacy id for a module that was never published](#n5-the-manifest-lists-a-legacy-id-for-a-module-that-was-never-published)
- [ ] [NR1: Consider moving to Companion module API 2.x](#nr1-consider-moving-to-companion-module-api-2x)

---

## 🟡 Medium

### M1: Type and priority colour feedbacks stay uncoloured after Companion starts

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:415-422`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/d0d442f8f6205d6f339bd8d88ea10132c7bb5ae9/src/main.ts#L415-L422), [`src/feedbacks.ts:22-26`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/d0d442f8f6205d6f339bd8d88ea10132c7bb5ae9/src/feedbacks.ts#L22-L26), [`src/feedbacks.ts:40-44`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/d0d442f8f6205d6f339bd8d88ea10132c7bb5ae9/src/feedbacks.ts#L40-L44)

**What goes wrong:** A user adds the **Colour key by note type (matches the chip in the app)** feedback to a key, for example with Module = Cue Notes and Type = Director, so the key shows the Director chip colour. After Companion restarts, or after the connection is disabled and enabled again, the key stays plain grey. It only gets its colour once something makes Companion run that feedback again, for example editing the feedback's options. When the show's type or priority colours change in The Notes List, the keys keep the old colour. **Colour key by priority** behaves the same way.

**Why it happens:** `init()` starts `configUpdated()` without waiting for it, so Companion first runs the existing feedbacks while the show's types and priorities (`self.options`) are still unknown, and both callbacks return no style. When the `/me` reply later brings the types and priorities, `refreshMe()` stores them and calls `updateEntities()`, which only sends new feedback definitions. In base 1.14, sending definitions does not re-run any existing feedback (see [A2](#-assumptions-to-confirm)). The module never calls `checkFeedbacks('type_color', 'priority_color')`; its only `checkFeedbacks` calls cover `connected`, `outstanding_above`, `eos_connected` and `selected_cue_*`.

**Fix:** re-check both colour feedbacks whenever the show's types and priorities change.

```ts
// src/main.ts, in refreshMe(), inside `if (key !== this.optionsKey)`
this.options = me.options
this.updateEntities()
this.checkFeedbacks('type_color', 'priority_color')
```

## 🟢 Low

### L1: The Connected key and outstanding counts keep showing the old show after re-pairing starts

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:164-200`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/d0d442f8f6205d6f339bd8d88ea10132c7bb5ae9/src/main.ts#L164-L200)

**What goes wrong:** A user paired to show A ticks **Start pairing** and saves, to move the station to show B. The module revokes the show A station and shows a new PAIR CODE. But the **Connected** feedback stays green, `$(notes-list:connected)` stays `true`, and `$(notes-list:cue_outstanding)` and the other outstanding variables (and the **Outstanding count above threshold** keys) keep show A's last numbers, for example 12 cue notes. They stay that way for the whole pairing window. If the code expires, they stay that way for good: the connection status says Disconnected "Pairing code expired" while the key still says connected.

**Why it happens:** Saving the settings stops the polling loops, and `beginPairing()` revokes and clears the token. Neither one resets the connected flag, the `connected` variable or the counts. The module does reset all of them when `/me` answers 401 ([`src/main.ts:428-447`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/d0d442f8f6205d6f339bd8d88ea10132c7bb5ae9/src/main.ts#L428-L447), commented "Keys must not keep showing the revoked station's counts"). The revoke-to-re-pair path never reaches that code, because polling has already stopped (see [A1](#-assumptions-to-confirm)).

**Fix:** after the revoke in `beginPairing()`, clear the paired state the same way the 401 branch of `refreshMe()` does. A small shared helper keeps the two paths the same.

```ts
private clearPairedState(): void {
	this.connected = false
	for (const m of MODULES) this.counts[m.id] = 0
	this.setVariableValues({
		connected: 'false',
		station_name: '',
		production_name: '',
		cue_outstanding: '',
		work_outstanding: '',
		production_outstanding: '',
		electrician_outstanding: '',
	})
	this.checkFeedbacks('connected', 'outstanding_above')
}
```

### L2: A pairing code stays on screen when the server cannot be reached

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:246-257`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/d0d442f8f6205d6f339bd8d88ea10132c7bb5ae9/src/main.ts#L246-L257)

**What goes wrong:** A user ticks **Start pairing** and gets code ABC123. The connection status says "PAIR CODE ABC123 — enter it in the show's Settings → Button stations". The Notes List then becomes unreachable, for example because the network drops or the server returns error 500. Every pairing check fails, but the status keeps showing the code as if pairing were working. The failures only go to the debug log. The user types the code into the app, the station never pairs, and nothing says why.

**Why it happens:** The pairing check's error handler only deals with 429 (wait) and 404/409/410 (pairing ended). Every other error, including network failures and timeouts (status 0) and server errors (5xx), is logged at `debug` and the connection status is never changed.

**Fix:** after a few failed pairing checks in a row (status 0 or 5xx), set the status to Connection Failure with the code and the reason, for example ``updateStatus(InstanceStatus.ConnectionFailure, `Pairing code ${pairing.code}: cannot reach the server (${describe(e)})`)``. Also log one `warn` line. Put the PAIR CODE status back on the next successful check.

### L3: New note parses a cue number Companion has already resolved

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:14-20`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/d0d442f8f6205d6f339bd8d88ea10132c7bb5ae9/src/actions.ts#L14-L20), [`src/actions.ts:40-41`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/d0d442f8f6205d6f339bd8d88ea10132c7bb5ae9/src/actions.ts#L40-L41)

**What goes wrong:** Users see no difference; this is about code clarity. The **Cue number (blank = none)** option of **New note (opens the editor in your tab)** is marked as accepting variables. Companion therefore replaces variables such as `$(notes-list:selected_cue)` before the action runs. The action then parses the already-resolved value (for example `12.5`) for variables a second time.

**Why it happens:** Since API 1.13, Companion resolves variables in text options that declare `useVariables` before it calls the action. The module targets 1.14.1, uses no local variables (`$(this:` and `$(local:` appear nowhere in `src`), and still calls `context.parseVariablesInString` on the field.

**Fix:** use `String(event.options.cueNumber ?? '').trim()` directly and drop the `await context.parseVariablesInString(...)` call. Keep the existing fallback to `self.cursorCue()` for a blank or `$NA` value.

## 💡 Nice to Have

### N1: An unreachable Eos desk does not show in the connection status

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:274-280`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/d0d442f8f6205d6f339bd8d88ea10132c7bb5ae9/src/main.ts#L274-L280)

**What goes wrong:** A user mistypes the **Eos desk IP**, for example 10.101.100.11 instead of 10.101.100.101. The connection status stays green "Ok", because it reflects only The Notes List server. The only signs of the problem are one warning line in the log, the `eos_connected` variable and the **Eos desk connected (read-only reader)** feedback. A user who has not put that feedback on a key may not notice that **New note** no longer picks up the live cue.

**Why it happens:** The Eos reader reports its connection only to the variable and the feedback. The connection status is set only from the HTTP server's state.

**Fix:** optional. When an Eos desk IP is set but the reader is not connected, and the server side is fine, show it in the status, for example `updateStatus(InstanceStatus.UnknownWarning, 'Eos desk not connected')`. Go back to Ok when the desk connects. The existing Eos feedback and preset already cover this, so this only makes the problem easier to notice.

### N2: The pairing log line always says the code expires in 10 minutes

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:196-199`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/d0d442f8f6205d6f339bd8d88ea10132c7bb5ae9/src/main.ts#L196-L199)

**What goes wrong:** The log line "PAIRING CODE: … Expires in 10 minutes" is fixed text. If the server gives the code a different lifetime, the log is wrong, while the settings window shows the real minutes left. Only the log text is affected.

**Fix:** work out the minutes left with `Math.round((this.pairing.expiresAt - Date.now()) / 60000)` and put that number in the log line.

### N3: Go to module presets do not light up when notes are outstanding

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/presets.ts:105-116`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/d0d442f8f6205d6f339bd8d88ea10132c7bb5ae9/src/presets.ts#L105-L116)

**What goes wrong:** A user drags in the **Go to Work Notes** preset. The key reads "WORK / 3 OPEN" but has the same colour whether 0 or 12 notes are open. The module already has the **Outstanding count above threshold** feedback for this, but no preset uses it, so the user has to add it to each key by hand.

**Fix:** add the outstanding feedback to the `goto_${m.id}` presets, with a style that fits the house look.

```ts
feedbacks: [
	{
		feedbackId: 'outstanding_above',
		options: { module: m.id, threshold: 0 },
		style: { bgcolor: combineRgb(220, 38, 38), color: combineRgb(255, 255, 255) },
	},
],
```

### N4: Feedbacks have no descriptions in the feedback picker

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.ts:8-73`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/d0d442f8f6205d6f339bd8d88ea10132c7bb5ae9/src/feedbacks.ts#L8-L73)

**What goes wrong:** When users add a feedback to a button, entries such as **Outstanding count above threshold** or **Selected cue is not the live cue** have no explanatory line, while every action has a clear description. This is cosmetic.

**Fix:** add a short `description` to each feedback, for example for `outstanding_above`: "Turns the key red while the chosen module has more outstanding notes than the threshold."

### N5: The manifest lists a legacy id for a module that was never published

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`companion/manifest.json:17`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/d0d442f8f6205d6f339bd8d88ea10132c7bb5ae9/companion/manifest.json#L17)

**What goes wrong:** `legacyIds` tells Companion that connections saved under the module id `thenoteslist` belong to this module. This is the module's first Bitfocus release, so no published module has that id. If the module was never handed out under `thenoteslist` (see [A3](#-assumptions-to-confirm)), the entry does nothing and only adds confusion.

**Fix:** keep `legacyIds` only if builds with the id `thenoteslist` were given to users. Otherwise set it back to `"legacyIds": []`, as in the template.

## 🔮 Next Release

### NR1: Consider moving to Companion module API 2.x

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`package.json:24`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/d0d442f8f6205d6f339bd8d88ea10132c7bb5ae9/package.json#L24)

**What goes wrong:** Nothing breaks today. The module is on the latest API 1 (base 1.14.1, Companion 4.2+). API 2.x (Companion 4.3+ / 5.0+) adds expressions in options. From 2.1 it also adds action results and abort signals, which suit the module's HTTP calls.

**Fix:** when convenient, migrate following the companion-v1-to-v2-migration guide, and check the target API level against companion-v2-api-compliance first.
