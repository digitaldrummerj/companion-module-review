# Re-review: devcore-mixingstation v2.0.2

| | |
| --- | --- |
| **Module** | `companion-module-devcore-mixingstation` ([repo](https://github.com/bitfocus/companion-module-devcore-mixingstation)) |
| **Scope** | `tag` (`v1.0.1..v2.0.2`) |
| **Version** | v2.0.2 (`e4909b0`) |
| **Release** | Update — last published v1.0.1 |
| **API** | 1 (base 1.12.1, yarn.lock) |
| **Template** | `companion-module-template-ts-v1` @ `42609d8` (2026-03-03, pinned) · `.yarnrc.yml` from `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Previous review** | [v2.0.0 (2026-10-05)](review-devcore-mixingstation-v2.0.0-20261005-024911.md) |
| **Language** | TypeScript (ESM), WebSocket via `ws` |
| **Build** | `yarn install --immutable`, `yarn package` and `yarn lint` pass |
| **Review date** | 2026-10-30 |

This is a follow-up to the v2.0.0 review. Since v2.0.0, the maintainer changed the upgrade script, action subscriptions, the help page and the project config (v2.0.1 and v2.0.2 differ only in the version number). Every finding from the v2.0.0 review is fixed:

| Prior finding | Status | Where |
| --- | --- | --- |
| C1: The repository has no .gitattributes file | ✅ Fixed | [`.gitattributes`](https://github.com/bitfocus/companion-module-devcore-mixingstation/blob/e4909b01a38dc431f80dff87248ed03321cc4036/.gitattributes) added |
| C2: Built packages and editor settings can be committed by accident | ✅ Fixed | [`.gitignore`](https://github.com/bitfocus/companion-module-devcore-mixingstation/blob/e4909b01a38dc431f80dff87248ed03321cc4036/.gitignore) now ignores `/*.tgz` and `/.vscode` |
| H1: Channel buttons from v1.0.1 stop controlling the mixer after the upgrade | ✅ Fixed | [`src/upgrades.ts:59-64`](https://github.com/bitfocus/companion-module-devcore-mixingstation/blob/e4909b01a38dc431f80dff87248ed03321cc4036/src/upgrades.ts#L59-L64) strips the `ch.N.` prefix from **Path** |
| H2: Mixer value feedbacks from v1.0.1 stop working after the upgrade | ✅ Fixed | [`src/upgrades.ts:40-47`](https://github.com/bitfocus/companion-module-devcore-mixingstation/blob/e4909b01a38dc431f80dff87248ed03321cc4036/src/upgrades.ts#L40-L47) converts `getValue` feedbacks (one edge case left, see [L3](#l3-upgraded-mixer-value-feedbacks-with-no-path-show-as-an-unknown-feedback)) |
| H3: Mixer variables for actions disappear after a restart, and editing an action can freeze a feedback | ✅ Fixed | [`src/main.ts:87-89`](https://github.com/bitfocus/companion-module-devcore-mixingstation/blob/e4909b01a38dc431f80dff87248ed03321cc4036/src/main.ts#L87-L89) calls `subscribeActions()`; actions are tracked per id in [`src/ms/FeedbackHandler.ts:45-62`](https://github.com/bitfocus/companion-module-devcore-mixingstation/blob/e4909b01a38dc431f80dff87248ed03321cc4036/src/ms/FeedbackHandler.ts#L45-L62) |
| H4: Upgraded Set Value buttons have an empty Mode and no Fade Time | ✅ Fixed | [`src/upgrades.ts:26-38`](https://github.com/bitfocus/companion-module-devcore-mixingstation/blob/e4909b01a38dc431f80dff87248ed03321cc4036/src/upgrades.ts#L26-L38) sets `mode` and `fT` on every converted action |
| H5: The help page still describes the old Set Value action and Mixer value feedback | ✅ Fixed | [`companion/HELP.md:28-74`](https://github.com/bitfocus/companion-module-devcore-mixingstation/blob/e4909b01a38dc431f80dff87248ed03321cc4036/companion/HELP.md#L28-L74) |
| M1: The CI workflow builds with Node.js 18 instead of 22 | ✅ Fixed | [`.github/workflows/node.yaml`](https://github.com/bitfocus/companion-module-devcore-mixingstation/blob/e4909b01a38dc431f80dff87248ed03321cc4036/.github/workflows/node.yaml) uses `22.x` |
| Note: `tsconfig.build.json` extends the node18 config | ✅ Fixed | [`tsconfig.build.json`](https://github.com/bitfocus/companion-module-devcore-mixingstation/blob/e4909b01a38dc431f80dff87248ed03321cc4036/tsconfig.build.json) extends `node22/recommended` |

The findings below are new, non-blocking, and mostly edge cases around an empty **Path** option.

## Verdict: ✅ Approved

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Mixing Station rejects or ignores a subscribe or set request for an incomplete path such as `ch.0.`, and doesn't treat it as a real parameter | the path format in `companion/HELP.md` (for example `ch.1.grp.dca.0`); Mixing Station's API was not checked. The stray variable itself follows from the module code alone | [L1](#l1-a-new-channel-action-or-feedback-with-no-path-chosen-creates-a-junk-mixer-ch0-variable) |
| A2 | Companion lets a user edit or delete an action on a button while that action's definition is not registered (Mixing Station has no mixer connected), and sends those changes to the module | base 1.12.1 `dist/internal/actions.js` `handleUpdateActions` skips subscribe/unsubscribe when the definition is missing; whether the Companion UI allows the edit was not checked | [L2](#l2-value-actions-edited-or-deleted-while-no-mixer-is-connected-keep-watching-their-old-path) |

## 📋 Issues

### Non-blocking

- [ ] [L1: A new channel action or feedback with no Path chosen creates a junk "Mixer: ch.0." variable](#l1-a-new-channel-action-or-feedback-with-no-path-chosen-creates-a-junk-mixer-ch0-variable)
- [ ] [L2: Value actions edited or deleted while no mixer is connected keep watching their old path](#l2-value-actions-edited-or-deleted-while-no-mixer-is-connected-keep-watching-their-old-path)
- [ ] [L3: Upgraded Mixer value feedbacks with no Path show as an unknown feedback](#l3-upgraded-mixer-value-feedbacks-with-no-path-show-as-an-unknown-feedback)
- [ ] [N1: Value (Channel) feedback lists Path before Channel, unlike the matching action](#n1-value-channel-feedback-lists-path-before-channel-unlike-the-matching-action)
- [ ] [NR1: The module moved to API 1.12 in this release, but 1.14 or v2 is available](#nr1-the-module-moved-to-api-112-in-this-release-but-114-or-v2-is-available)

---

## 🟢 Low

### L1: A new channel action or feedback with no Path chosen creates a junk "Mixer: ch.0." variable

- **Source:** 🔎 protocol reviewer, QA reviewer, compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/ActionAndFeedbackFactory.ts:224-254`](https://github.com/bitfocus/companion-module-devcore-mixingstation/blob/e4909b01a38dc431f80dff87248ed03321cc4036/src/ActionAndFeedbackFactory.ts#L224-L254), [`src/ActionAndFeedbackFactory.ts:282-313`](https://github.com/bitfocus/companion-module-devcore-mixingstation/blob/e4909b01a38dc431f80dff87248ed03321cc4036/src/ActionAndFeedbackFactory.ts#L282-L313)

**What goes wrong:** A user adds the **Set Value (Channel)** action or the **Value (Channel)** feedback to a button. The **Path** dropdown starts empty and **Channel** defaults to the first channel. Before a Path is picked, the module already asks Mixing Station to watch the path `ch.0.`, and a variable named "Mixer: ch.0." (`mixer_ch-0-`) appears in the connection's variable list. It never gets a value. Each channel the user picks while Path is still empty adds another junk variable (for example `mixer_ch-3-`). Pressing the button with no Path sends a set request to `ch.0./val`, which does nothing useful. The junk entries go away once a Path is chosen, and stay if the Path is left blank. The FX and Others variants are not affected.

**Why it happens:** The subscribe, unsubscribe and feedback handlers skip an empty Path by checking whether the *combined* path is empty. For the channel variants, the combined path always starts with the channel prefix (`ch.0.`), so it is never empty, even when **Path** itself is. The action's press handler has no empty-Path check at all.

**Evidence:**

```ts
// src/ActionAndFeedbackFactory.ts:57-59
getPrefix(options) {
	return (options.ch as string) + '.'
},
// src/ActionAndFeedbackFactory.ts:239-245
subscribe: async (info) => {
	const path = decorator.getPrefix(info.options) + (info.options.path as string)
	if (path == '') {
		return
	}
	this.logger.debug('Subscribe act: ' + path)
	this.feedbackHandler.mapAction(info.id, path)
```

**Fix:** check the **Path** option itself before adding the channel prefix, in the action's press, subscribe and unsubscribe handlers and in the feedback's callback, subscribe and unsubscribe handlers.

```ts
const rawPath = info.options.path as string
if (!rawPath) return
const path = decorator.getPrefix(info.options) + rawPath
```

### L2: Value actions edited or deleted while no mixer is connected keep watching their old path

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/ms/FeedbackHandler.ts:45-62`](https://github.com/bitfocus/companion-module-devcore-mixingstation/blob/e4909b01a38dc431f80dff87248ed03321cc4036/src/ms/FeedbackHandler.ts#L45-L62)

**What goes wrong:** Mixing Station is idle (no mixer connected), so the module has no value actions defined. During that time the user changes a **Set Value (Channel)** button's **Path** from `mix.lvl` to `mix.on`, or deletes the button. When a mixer connects again, the module still watches the old path: `mixer_ch-1-mix-on` is never created, so button text using `$(mixingstation:mixer_ch-1-mix-on)` stays empty, and the stale `mixer_ch-1-mix-lvl` variable stays until the connection is restarted.

**Why it happens:** While the definitions are missing, Companion can't run the action's unsubscribe handler, so the module never forgets the old path. When the definitions come back, the module asks Companion to re-subscribe every action (the H3 fix). The new tracking code then sees that this action id is already known and returns early. It compares only the id, not the path the id was watching.

**Evidence:**

```ts
// src/ms/FeedbackHandler.ts:45-54
mapAction(id: string, path: string): void {
	if (this.actionMap[id]) {
		// Might get called multiple times when action definitions are rebuilt
		this.logger.debug('Action ' + id + ' already subscribed')
		return
	}
	this.actionMap[id] = { path: path }

	this.subscribeValue(path)
}
```

**Fix:** when an id is already known with a different path, stop watching the old path and watch the new one. Apply the same change to `mapFeedback`. Optionally, clear `actionMap` and its usage counts before `subscribeActions()` in `updateCompanionDefinitions()`, so deleted actions are dropped too.

```ts
const existing = this.actionMap[id]
if (existing) {
	if (existing.path === path) return
	this.unsubscribeValue(existing.path)
}
this.actionMap[id] = { path: path }
this.subscribeValue(path)
```

### L3: Upgraded Mixer value feedbacks with no Path show as an unknown feedback

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/upgrades.ts:40-47`](https://github.com/bitfocus/companion-module-devcore-mixingstation/blob/e4909b01a38dc431f80dff87248ed03321cc4036/src/upgrades.ts#L40-L47), [`src/upgrades.ts:53-56`](https://github.com/bitfocus/companion-module-devcore-mixingstation/blob/e4909b01a38dc431f80dff87248ed03321cc4036/src/upgrades.ts#L53-L56)

**What goes wrong:** A v1.0.1 button has a **Mixer value** feedback whose Path was never set. After the upgrade, that feedback keeps its old id `getValue`, which no longer exists, so the button editor shows it as an unknown feedback instead of **Value (Others)**. Feedbacks with a Path are converted correctly. Actions with an empty Path end up as **Set Value (Others)** only because their old id `setValue` still exists.

**Why it happens:** The shared path helper in the upgrade script returns before it renames the entry when **Path** is empty. For feedbacks, that leaves the old id in place.

**Fix:** when **Path** is empty, still rename the entry to `setValue` (Others), so empty feedbacks are converted like empty actions.

```ts
if (!entry.options.path) {
	setId(entry, 'setValue')
	return false
}
```

Companion runs each upgrade script only once per connection, so if v2.0.2 has already reached users, add this as a new upgrade script.

---

## 💡 Nice to Have

### N1: Value (Channel) feedback lists Path before Channel, unlike the matching action

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/ActionAndFeedbackFactory.ts:62-71`](https://github.com/bitfocus/companion-module-devcore-mixingstation/blob/e4909b01a38dc431f80dff87248ed03321cc4036/src/ActionAndFeedbackFactory.ts#L62-L71)

**What goes wrong:** The **Set Value (Channel)** action shows Mode, Channel, Path, Value. The **Value (Channel)** feedback shows Path, then Channel, so the user picks a parameter before the channel it belongs to. Cosmetic only.

**Why it happens:** Both definitions insert **Channel** at position 1. The action has **Mode** at position 0, so Channel lands before Path. The feedback has only **Path** at position 0, so Channel lands after it.

**Fix:** insert **Channel** at position 0 in the feedback: `feedback.options.splice(0, 0, { ... })`.

---

## 🔮 Next Release

### NR1: The module moved to API 1.12 in this release, but 1.14 or v2 is available

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`package.json:26`](https://github.com/bitfocus/companion-module-devcore-mixingstation/blob/e4909b01a38dc431f80dff87248ed03321cc4036/package.json#L26)

**What goes wrong:** No user-visible effect today. The module stays on the 1.12 feature set: without 1.13, Companion doesn't parse variables in text input fields automatically and secret-text config fields aren't available; without 1.14, the config panel doesn't get the automatic layout.

**Why it happens:** `@companion-module/base` was raised from `~1.11.3` to `~1.12.1`, not to the latest 1.x line.

**Fix:** in a later release, move to `@companion-module/base` `~1.14` (Companion 4.2+), or migrate to API 2.x (Companion 4.3+), and use the matching template for that level.
