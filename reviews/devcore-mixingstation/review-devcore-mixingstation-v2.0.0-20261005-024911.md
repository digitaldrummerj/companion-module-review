# Review: devcore-mixingstation v2.0.0

| | |
| --- | --- |
| **Module** | `companion-module-devcore-mixingstation` ([repo](https://github.com/bitfocus/companion-module-devcore-mixingstation)) |
| **Version** | v2.0.0 (`d6029cd`) |
| **Previous tag** | v1.0.1 |
| **Scope:** | tag (`v1.0.1..v2.0.0`) |
| **Language** | TypeScript (ESM), WebSocket via `ws` |
| **Template** | [API 1 TypeScript template](https://github.com/bitfocus/companion-module-template-ts/tree/42609d8dab515a25ec2f3b3c7adafe57aa41b7be) (`companion-module-template-ts` @ `42609d8`, 2026-03-03, the last API 1 commit) · `.yarnrc.yml` from `companion-module-template-ts` @ `d62230e` (2026-08-28) |
| **API** | 1 (base 1.12.1, yarn.lock) |
| **Build** | `yarn install --immutable`, `yarn package` and `yarn lint` pass (`devcore-mixingstation-2.0.0.tgz`) |
| **Review date** | 2026-10-05 |

This release splits the single "Set Value" action into Channel, FX and Others variants, adds Set Relative and fade times, and creates a `mixer_*` variable for every path used by an action or feedback.

**About the template:** the official TypeScript template repository has moved to the module API 2.1 (Companion 5). This module uses API 1, so every template finding below links to the API 1 version of the template, at commit [`42609d8`](https://github.com/bitfocus/companion-module-template-ts/tree/42609d8dab515a25ec2f3b3c7adafe57aa41b7be). Earlier versions of the template are no longer maintained, but that commit preserves the API 1 files.

## Verdict: ❌ Changes Required

## 📋 Issues

### Blocking

- [ ] [C1: The repository has no .gitattributes file](#c1-the-repository-has-no-gitattributes-file)
- [ ] [C2: Built packages and editor settings can be committed by accident](#c2-built-packages-and-editor-settings-can-be-committed-by-accident)
- [ ] [H1: Channel buttons from v1.0.1 stop controlling the mixer after the upgrade](#h1-channel-buttons-from-v101-stop-controlling-the-mixer-after-the-upgrade)
- [ ] [H2: Mixer value feedbacks from v1.0.1 stop working after the upgrade](#h2-mixer-value-feedbacks-from-v101-stop-working-after-the-upgrade)
- [ ] [H3: Mixer variables for actions disappear after a restart, and editing an action can freeze a feedback](#h3-mixer-variables-for-actions-disappear-after-a-restart-and-editing-an-action-can-freeze-a-feedback)
- [ ] [H4: Upgraded Set Value buttons have an empty Mode and no Fade Time](#h4-upgraded-set-value-buttons-have-an-empty-mode-and-no-fade-time)
- [ ] [H5: The help page still describes the old Set Value action and Mixer value feedback](#h5-the-help-page-still-describes-the-old-set-value-action-and-mixer-value-feedback)

### Non-blocking

- [ ] [M1: The CI workflow builds with Node.js 18 instead of 22](#m1-the-ci-workflow-builds-with-nodejs-18-instead-of-22)

### Notes

- [📝 Additional Notes](#-additional-notes)

---

## 🔴 Critical

### C1: The repository has no .gitattributes file

- **Source:** 🤖 validate-template (FILE-MISSING)
- **File:** `.gitattributes`
- **Template:** [API 1 TypeScript template](https://github.com/bitfocus/companion-module-template-ts/tree/42609d8dab515a25ec2f3b3c7adafe57aa41b7be): [`.gitattributes`](https://github.com/bitfocus/companion-module-template-ts/blob/42609d8dab515a25ec2f3b3c7adafe57aa41b7be/.gitattributes)

**What goes wrong:** No user-visible effect. The template `companion-module-template-ts-v1` ships a `.gitattributes` file (it keeps line endings consistent across platforms), and this module doesn't have one.

**Fix:** copy `.gitattributes` from the template.

### C2: Built packages and editor settings can be committed by accident

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **File:** [`.gitignore:1-8`](https://github.com/bitfocus/companion-module-devcore-mixingstation/blob/d6029cdd77df4f7d81060720bfdfc596b5f9f660/.gitignore#L1-L8)
- **Template:** [API 1 TypeScript template](https://github.com/bitfocus/companion-module-template-ts/tree/42609d8dab515a25ec2f3b3c7adafe57aa41b7be): [`.gitignore`](https://github.com/bitfocus/companion-module-template-ts/blob/42609d8dab515a25ec2f3b3c7adafe57aa41b7be/.gitignore)

**What goes wrong:** No user-visible effect. `yarn package` writes `devcore-mixingstation-2.0.0.tgz` to the repo root, and nothing stops that file (or a `.vscode` folder) from being committed.

**Why it happens:** the template's `.gitignore` entries `/*.tgz` and `/.vscode` are missing.

**Fix:** add both entries, or replace the file with the template's `.gitignore` and keep the module's extra entries (`/.idea`, `DEBUG-*`).

---

## 🟠 High

### H1: Channel buttons from v1.0.1 stop controlling the mixer after the upgrade

- **Source:** 🔎 AI reviewer — verified
- **Classification:** 🔙 REGRESSION
- **File:** [`src/upgrades.ts:44-55`](https://github.com/bitfocus/companion-module-devcore-mixingstation/blob/d6029cdd77df4f7d81060720bfdfc596b5f9f660/src/upgrades.ts#L44-L55) (consumer: [`src/ActionAndFeedbackFactory.ts:57-59`](https://github.com/bitfocus/companion-module-devcore-mixingstation/blob/d6029cdd77df4f7d81060720bfdfc596b5f9f660/src/ActionAndFeedbackFactory.ts#L57-L59), [`src/ActionAndFeedbackFactory.ts:224-254`](https://github.com/bitfocus/companion-module-devcore-mixingstation/blob/d6029cdd77df4f7d81060720bfdfc596b5f9f660/src/ActionAndFeedbackFactory.ts#L224-L254))

**What goes wrong:** A user on v1.0.1 has a button with the old "Set Value" or "Toggle Value" action on a channel parameter, for example the fader level of channel 4 (`ch.3.mix.lvl`). After installing v2.0.0, the button is converted to **Set Value (Channel)** with **Channel** set to channel 4, but pressing it no longer changes the mixer. The **Path** dropdown shows a value that is not in its list, and the `mixer_*` variable for that button points at a path that doesn't exist. Every channel button carried over from v1.0.1 is affected. FX and other (non-channel) buttons are not.

**Why it happens:** In v1.0.1 the **Path** option held the full path from the root (`ch.3.mix.lvl`). In v2.0.0 the channel is a separate **Channel** option, and **Path** holds only the part after it (`mix.lvl`); the module glues them back together when the button runs. The new upgrade script fills in **Channel** but leaves the full old path in **Path**, so the module builds `ch.3.ch.3.mix.lvl`, and the same doubled path is used to subscribe and unsubscribe.

**Evidence:**

```ts
// src/upgrades.ts:44-55 (v2.0.0)
function updatePaths(action: CompanionMigrationAction): boolean {
	if (!action.options.path) {
		return false
	}

	const path = action.options.path as string
	if (path.startsWith('ch.')) {
		const chId = path.split('.')[1]
		action.actionId = 'setChValue'
		action.options.ch = 'ch.' + chId
		return true
	}

// src/ActionAndFeedbackFactory.ts:46-59 (v2.0.0)
		const chParams = this.treeToDropdown(this.chTree, '')
		actions.setChValue = this.buildValueAction('Set Value (Channel)', chParams, {
		...
			getPrefix(options) {
				return (options.ch as string) + '.'
			},

// src/ActionAndFeedbackFactory.ts:117-122 (v2.0.0): chTree holds only the merged children of each channel, so the v2 path choices are relative, e.g. "mix.lvl"
				if (key == 'ch') {
					for (const chId in node.child) {
						...
						const ch = node.child[chId]
						if (ch.child) {
							this.mergeInto(ch.child, this.chTree)

// src/ActionAndFeedbackFactory.ts:224-226, 239-240, 247-248 (v2.0.0)
			callback: async (event) => {
				const mode = event.options.mode as string
				const path = decorator.getPrefix(event.options) + (event.options.path as string)
			subscribe: async (info) => {
				const path = decorator.getPrefix(info.options) + (info.options.path as string)
			unsubscribe: async (info) => {
				const path = decorator.getPrefix(info.options) + (info.options.path as string)

// v1.0.1 src/CompanionDataFactory.ts:33-34: v1 paths were built from the root, e.g. "ch.3.mix.lvl"
			const tree = await this.ms.getAllDataPaths()
			choices = this.getAllParams(tree.child, '')
				const prefix = path + key + '.'
				...
				const items = this.getAllParams(child.child, path + key + '.')
```

Running `updatePaths` on a v1.0.1 action:

```text
{"actionId":"setChValue","options":{"path":"ch.3.mix.lvl","valN":0,"ch":"ch.3"}} => ch.3.ch.3.mix.lvl
```

**Reproduced in Companion 5:** Live-tested in Companion 5.1.0 (2026-10-11): a page saved under v1.0.1 was imported onto a test page, the connection was switched to v2.0.0 so the upgrade script ran, and the module was connected to a stand-in Mixing Station server that logs every request it receives. A v1.0.1 button that set `ch.3.mix.lvl` to `-10` became **Set Value (Channel)** with **Channel** = `Ch 4` and **Path** shown as `?? (ch.3.mix.lvl)`, a value that isn't in the list. Pressing it, and a converted "Toggle Value" button on `ch.3.mix.on`, sent:

```text
v1.0.1 press:  POST /console/data/set/ch.3.mix.lvl/val       {"value":-10}
v2.0.0 press:  POST /console/data/set/ch.3.ch.3.mix.lvl/val  {"value":-10}   (unknown path)
v2.0.0 press:  GET  /console/data/get/ch.3.ch.3.mix.on/val                    (unknown path)
```

An FX button (`fx.0.par.mix`) and an "Others" button (`main.0.mix.lvl`) on the same page still set the right path.

**Confirm by:** open [`src/upgrades.ts:50-54`](https://github.com/bitfocus/companion-module-devcore-mixingstation/blob/d6029cdd77df4f7d81060720bfdfc596b5f9f660/src/upgrades.ts#L50-L54) and check that `options.path` is never stripped of its `ch.N.` prefix. Then open [`src/ActionAndFeedbackFactory.ts:57-59`](https://github.com/bitfocus/companion-module-devcore-mixingstation/blob/d6029cdd77df4f7d81060720bfdfc596b5f9f660/src/ActionAndFeedbackFactory.ts#L57-L59) and [`src/ActionAndFeedbackFactory.ts:226`](https://github.com/bitfocus/companion-module-devcore-mixingstation/blob/d6029cdd77df4f7d81060720bfdfc596b5f9f660/src/ActionAndFeedbackFactory.ts#L226), where `getPrefix` adds `options.ch + '.'` again in front of the full path.

**Fix:** in the channel branch of the upgrade script, remove the `ch.N.` part from **Path** so it holds only the relative path.

```ts
if (path.startsWith('ch.')) {
	const parts = path.split('.')
	action.actionId = 'setChValue'
	action.options.ch = 'ch.' + parts[1]
	action.options.path = parts.slice(2).join('.')
	return true
}
```

If a v2.0.0 build has already reached users, add this as a new upgrade script instead of editing the existing one: Companion runs each upgrade script only once per connection.

---

### H2: Mixer value feedbacks from v1.0.1 stop working after the upgrade

- **Source:** 🔎 AI reviewer — verified
- **Classification:** 🔙 REGRESSION
- **File:** [`src/upgrades.ts:19-40`](https://github.com/bitfocus/companion-module-devcore-mixingstation/blob/d6029cdd77df4f7d81060720bfdfc596b5f9f660/src/upgrades.ts#L19-L40) (definitions: [`src/ActionAndFeedbackFactory.ts:62`](https://github.com/bitfocus/companion-module-devcore-mixingstation/blob/d6029cdd77df4f7d81060720bfdfc596b5f9f660/src/ActionAndFeedbackFactory.ts#L62), [`src/ActionAndFeedbackFactory.ts:84`](https://github.com/bitfocus/companion-module-devcore-mixingstation/blob/d6029cdd77df4f7d81060720bfdfc596b5f9f660/src/ActionAndFeedbackFactory.ts#L84), [`src/ActionAndFeedbackFactory.ts:98`](https://github.com/bitfocus/companion-module-devcore-mixingstation/blob/d6029cdd77df4f7d81060720bfdfc596b5f9f660/src/ActionAndFeedbackFactory.ts#L98))

**What goes wrong:** A user on v1.0.1 has buttons that light up from the **Mixer value** feedback (for example a mute indicator). After installing v2.0.0, those buttons no longer change style, because the module no longer has a feedback with that id. The `mixer_*` variable that the feedback was providing also disappears, unless another action or feedback uses the same path, so button text such as `$(mixingstation:mixer_ch-1-grp-dca-0)` stops updating. Every existing user with this feedback on a button is affected.

**Why it happens:** v1.0.1 shipped exactly one feedback, `getValue` ("Mixer value"). v2.0.0 replaces it with three new feedbacks: **Value (Channel)**, **Value (FX)** and **Value (Others)**. An *upgrade script* is the code Companion runs once on saved buttons to rename old actions and feedbacks to new ones. This release's upgrade script converts actions only: it never looks at the saved feedbacks and always returns an empty feedback list, so the old feedbacks keep pointing at `getValue`.

**Evidence:**

```ts
// src/upgrades.ts:19-40 (v2.0.0)
		const result: CompanionStaticUpgradeResult<ModuleConfig> = {
			updatedConfig: null,
			updatedActions: [],
			updatedFeedbacks: [],
		}

		for (const action of props.actions) {
			if (action.actionId == 'toggleValue') {
				...
			}
			if (action.actionId == 'setValue') {
				...
			}
		}
		return result
```

```ts
// src/CompanionDataFactory.ts:49-64 (v1.0.1, via `git show v1.0.1:src/CompanionDataFactory.ts`)
		fbk.getValue = {
			name: 'Mixer value',
			type: 'boolean',
			...
			options: [
				{
					id: 'path',
					type: 'dropdown',
```

```ts
// src/ActionAndFeedbackFactory.ts:62,84,98 (v2.0.0, the only feedback ids now defined; `grep -rn "getValue =" src` finds no `getValue` feedback)
		feedback.setChValue = this.buildValueFeedback('Value (Channel)', chParams, {
		feedback.setFxValue = this.buildValueFeedback('Value (FX)', fxParams, {
		feedback.setValue = this.buildValueFeedback('Value (Others)', otherParams, {
```

```ts
// src/ms/FeedbackHandler.ts:28-36,98-107 (v2.0.0: the `mixer_*` variables are defined only for subscribed paths)
	mapFeedback(id: string, path: string): void {
		...
		this.subscribeValue(path)
	}
	private updateVariables() {
		for (const path in this.subscriptions) {
			variables.push({ variableId: this.toVariableId(path), name: 'Mixer: ' + path })
		...
		return 'mixer_' + path.replaceAll('.', '-')
```

**Reproduced in Companion 5:** in the same live test, both upgraded buttons kept their **Mixer value** feedback with the id `getValue`, and the button editor showed it as "getValue (undefined)" with the message "This is not a known feedback".

**Confirm by:** open [`src/upgrades.ts:25-39`](https://github.com/bitfocus/companion-module-devcore-mixingstation/blob/d6029cdd77df4f7d81060720bfdfc596b5f9f660/src/upgrades.ts#L25-L39) and check that it loops only over `props.actions` and never touches `props.feedbacks`. Then run `git show v1.0.1:src/CompanionDataFactory.ts` and look at line 49 (`fbk.getValue`). No feedback with the id `getValue` exists in v2.0.0.

**Fix:** convert the saved **Mixer value** feedbacks in the upgrade script as well, choosing the new feedback from the start of the path.

- `ch.` paths become `setChValue`: set `options.ch` and strip the `ch.N.` prefix from `options.path`, as in H1.
- `fx.` paths become `setFxValue`.
- Everything else becomes `setValue` (Others).

```ts
for (const feedback of props.feedbacks) {
	if (feedback.feedbackId !== 'getValue') continue
	const path = String(feedback.options.path ?? '')
	if (path.startsWith('ch.')) {
		const parts = path.split('.')
		feedback.feedbackId = 'setChValue'
		feedback.options.ch = 'ch.' + parts[1]
		feedback.options.path = parts.slice(2).join('.')
	} else if (path.startsWith('fx.')) {
		feedback.feedbackId = 'setFxValue'
	} else {
		feedback.feedbackId = 'setValue'
	}
	result.updatedFeedbacks.push(feedback)
}
```

---

### H3: Mixer variables for actions disappear after a restart, and editing an action can freeze a feedback

- **Source:** 🔎 AI reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:78-89`](https://github.com/bitfocus/companion-module-devcore-mixingstation/blob/d6029cdd77df4f7d81060720bfdfc596b5f9f660/src/main.ts#L78-L89), [`src/ActionAndFeedbackFactory.ts:239-254`](https://github.com/bitfocus/companion-module-devcore-mixingstation/blob/d6029cdd77df4f7d81060720bfdfc596b5f9f660/src/ActionAndFeedbackFactory.ts#L239-L254), [`src/ms/FeedbackHandler.ts:56-68`](https://github.com/bitfocus/companion-module-devcore-mixingstation/blob/d6029cdd77df4f7d81060720bfdfc596b5f9f660/src/ms/FeedbackHandler.ts#L56-L68)

**What goes wrong:** The help page tells users that adding an action for a mixer parameter creates a `mixer_*` variable for it. That works while the user is building buttons, but after Companion restarts (or the connection is restarted), the variable is never created for paths that only actions use, so button text showing that variable stays empty. A second problem follows: if a feedback and an action use the same path, editing or deleting that action after a restart can make the feedback stop updating, with no error shown. Changing the connection settings also drops every action's subscription. Paths used by feedbacks alone are not affected.

**Why it happens:** A *subscription* is how the module starts watching a mixer value: Companion calls an action's or feedback's `subscribe` handler when it is added to a button, and once for every saved one right after the module starts. At that moment this module hasn't defined its value actions yet; it only defines them once Mixing Station reports that it is connected to a mixer. So the saved actions are skipped. When the definitions do arrive, the module asks Companion to subscribe its feedbacks again, but not its actions. The module also counts how many actions and feedbacks use each path, and stops watching the path when the count reaches zero. Removing a never-subscribed action still lowers the count, which can take a feedback's count from 1 to 0 and stop the updates it depends on.

**Evidence:**

```ts
// src/main.ts:22-27
	async init(config: ModuleConfig): Promise<void> {
		this.config = config

		await this.updateCompanionDefinitions()
		this.connectToMs()
	}
```

```ts
// src/main.ts:78-89
	async updateCompanionDefinitions(): Promise<void> {
		this.logger.debug('Updating actions')
		if (!this.ms || !this.feedbackHandler) return
		...
		this.setActionDefinitions(data.actions)
		this.setFeedbackDefinitions(data.feedback)

		// Update any feedbacks used by companion
		this.subscribeFeedbacks()
	}
```

```ts
// src/CompanionDataFactory.ts:32,41-47 (the value actions are built only when the app state is CONNECTED)
		if (this.ms.getAppState().topState == TopState.CONNECTED) {
			...
			if (this.ms.getAppState().topState == TopState.CONNECTED) {
				new ActionAndFeedbackFactory(
					...
				).build(treeNodes, actions, feedback)
```

```js
// node_modules/@companion-module/base/dist/module-api/base.js:112,123-127 (base 1.12.1)
                await this.init(this.#lastConfig, !!msg.isFirstInit);
            ...
            setImmediate(() => {
                // Subscribe all of the actions and feedbacks
                this._handleUpdateActions({ actions }, true).catch((e) => {
```

```js
// node_modules/@companion-module/base/dist/internal/actions.js:56-62,88-91 and 148-150
    handleUpdateActions(actions) {
        for (const [id, action] of Object.entries(actions)) {
            const existing = this.#actionInstances.get(id);
            if (existing) {
                // Call unsubscribe
                const definition = this.#actionDefinitions.get(existing.actionId);
                if (definition?.unsubscribe) {
        ...
                this.#actionInstances.set(id, action);
                // Inserted or updated
                const definition = this.#actionDefinitions.get(action.actionId);
                if (definition?.subscribe) {
    ...
    setActionDefinitions(actions) {
        const hostActions = [];
        this.#actionDefinitions.clear();
```

```ts
// src/ActionAndFeedbackFactory.ts:239-254
			subscribe: async (info) => {
				const path = decorator.getPrefix(info.options) + (info.options.path as string)
				...
				this.feedbackHandler.subscribeValue(path)
			},
			unsubscribe: async (info) => {
				...
				this.feedbackHandler.unsubscribeValue(path)
			},
```

```ts
// src/ms/FeedbackHandler.ts:56-68
	unsubscribeValue(path: string): void {
		const subscription = this.subscriptions[path]
		if (!subscription) {
			this.logger.warning('No subscription found for ' + path + ' but expected one')
			return
		}

		subscription.usages--
		if (subscription.usages == 0) {
			delete this.subscriptions[path]
			this.ms.unsubscribe(path)
			this.updateVariables()
		}
	}
```

```ts
// src/main.ts:66-70 (configUpdated -> connectToMs replaces the handler and its subscription map)
	private connectToMs(): void {
		...
		this.feedbackHandler = new FeedbackHandler(this.ms, this, new ModuleLogger(this, 'Fdk'))
```

```text
// companion/HELP.md:58-59
The module will dynamically create variables based on the configured actions and feedback items. Thus, if you want to display
a variable of a mixer value, make sure to create either an action or feedback item for it first.
```

**Reproduced in Companion 5:** in the same live test, with the module connected and the stand-in server answering:

- After a plain restart of the connection, the connection's log showed "Updating action definitions (5 actions)" but no "Subscribe act:" line, the server received no subscribe request for any action path, and the variables page said "Connection has no variables". That includes the FX and "Others" buttons, whose paths are valid.
- Editing the FX button's **Value** (50 → 51) made Companion call the action's subscribe straight away ("Subscribe act: fx.0.par.mix", then "Updating variable definitions (1 variables)"), and `$(mixingstation_live_test:mixer_fx-0-par-mix)` appeared.
- After one more restart, the variable was gone again.

So Companion does accept the new action definitions when `setActionDefinitions()` is called later, but it doesn't replay the saved actions' subscribe callbacks for them. Feedbacks only work after a restart because the module calls `this.subscribeFeedbacks()` itself.

**Confirm by:** open [`src/main.ts:78-89`](https://github.com/bitfocus/companion-module-devcore-mixingstation/blob/d6029cdd77df4f7d81060720bfdfc596b5f9f660/src/main.ts#L78-L89) and confirm there is no `this.subscribeActions()` next to `this.subscribeFeedbacks()`. Then open base `dist/module-api/base.js:123-127` and `dist/internal/actions.js:88-91`: the saved actions are replayed once, right after `init()`, and at that point the value-action definitions don't exist yet, so `definition?.subscribe` is undefined.

**Fix:** ask Companion to subscribe the actions again whenever the definitions are rebuilt, and remember which action subscribed which path so that repeated calls don't double-count.

- Call `this.subscribeActions()` right after `setActionDefinitions()` in `updateCompanionDefinitions()`.
- Track action subscriptions per action instance id, the way `mapFeedback` / `feedbackMap` already does for feedbacks ([`src/ms/FeedbackHandler.ts:28-42`](https://github.com/bitfocus/companion-module-devcore-mixingstation/blob/d6029cdd77df4f7d81060720bfdfc596b5f9f660/src/ms/FeedbackHandler.ts#L28-L42)). Subscribe then does nothing for an id that is already subscribed, and unsubscribe only lowers the count for an id that actually subscribed. Without this, `subscribeActions()` running on every connected/idle state change would keep raising the counts.
- After `configUpdated()` creates the new handler, re-subscribe both actions and feedbacks.

### H4: Upgraded Set Value buttons have an empty Mode and no Fade Time

- **Source:** 🔎 AI reviewer (raised to High by the review maintainer)
- **Classification:** 🆕 NEW
- **File:** [`src/upgrades.ts:26-38`](https://github.com/bitfocus/companion-module-devcore-mixingstation/blob/d6029cdd77df4f7d81060720bfdfc596b5f9f660/src/upgrades.ts#L26-L38), [`src/upgrades.ts:44-60`](https://github.com/bitfocus/companion-module-devcore-mixingstation/blob/d6029cdd77df4f7d81060720bfdfc596b5f9f660/src/upgrades.ts#L44-L60)

**What goes wrong:** Every button upgraded from the v1.0.1 "Set Value" action opens in the editor with an empty **Mode** dropdown. None of the upgraded buttons (including converted "Toggle Value" ones) gets a **Fade Time (ms)** value. The editor shows the default `0` in that field, but nothing is saved. The buttons still set the value today, only because the action treats a missing Mode as **Set Absolute** and a missing fade time is left out of the request. A user who opens one of these buttons sees a blank required setting, and any later change that relies on Mode or Fade Time being set would break every upgraded button.

**Why it happens:** the upgrade script adds **Mode** only to converted "Toggle Value" actions, and never adds the new **Fade Time (ms)** option. It also leaves "Others" Set Value actions out of `updatedActions`.

**Evidence:**

```ts
// src/upgrades.ts:26-38 (v2.0.0)
for (const action of props.actions) {
	if (action.actionId == 'toggleValue') {
		action.actionId = 'setValue'
		action.options.mode = MODE_TOGGLE
		updatePaths(action)
		result.updatedActions.push(action)
		continue
	}

	if (action.actionId == 'setValue') {
		if (updatePaths(action)) {
			result.updatedActions.push(action)
		}
	}
}
```

**Reproduced in Companion 5:** Live-tested in Companion 5.1.0 (2026-10-11): a page saved under v1.0.1 was imported onto a test page, the connection was switched to v2.0.0 so the upgrade script ran, and the module was connected to a stand-in Mixing Station server that logs every request it receives. The options Companion stored after the upgrade:

```text
Set Value (Channel)  path, valN, ch          (no mode, no fT)
Set Value (Channel)  path, mode=toggle, ch   (no fT)   <- from Toggle Value
Set Value (FX)       path, valN              (no mode, no fT)
Set Value (Others)   path, valN              (no mode, no fT)
```

The button editor showed **Mode** blank on each converted Set Value button. Pressing the FX and "Others" buttons sent `{"value":50}` and `{"value":-15}` with no `fade` field.

**Confirm by:** open [`src/upgrades.ts:26-38`](https://github.com/bitfocus/companion-module-devcore-mixingstation/blob/d6029cdd77df4f7d81060720bfdfc596b5f9f660/src/upgrades.ts#L26-L38) and check that `mode` is set only in the `toggleValue` branch and that `fT` is never set. Then compare with the `mode` and `fT` options in [`src/ActionAndFeedbackFactory.ts:182-220`](https://github.com/bitfocus/companion-module-devcore-mixingstation/blob/d6029cdd77df4f7d81060720bfdfc596b5f9f660/src/ActionAndFeedbackFactory.ts#L182-L220).

**Fix:** set the new options on every converted action, and report every converted action as updated:

- set `action.options.mode ??= 'setAbs'` and `action.options.fT ??= 0` for every `setValue` and `toggleValue` action;
- push each of them to `result.updatedActions`, including the "Others" ones that `updatePaths()` doesn't change.

### H5: The help page still describes the old Set Value action and Mixer value feedback

- **Source:** 🔎 AI reviewer (raised to High by the review maintainer)
- **Classification:** 🆕 NEW
- **File:** [`companion/HELP.md:30-54`](https://github.com/bitfocus/companion-module-devcore-mixingstation/blob/d6029cdd77df4f7d81060720bfdfc596b5f9f660/companion/HELP.md#L30-L54), [`companion/HELP.md:62-67`](https://github.com/bitfocus/companion-module-devcore-mixingstation/blob/d6029cdd77df4f7d81060720bfdfc596b5f9f660/companion/HELP.md#L62-L67)

**What goes wrong:** This release replaces the single "Set Value" action and "Mixer value" feedback, but the help page wasn't updated. A user following it looks for a **Set Value** action and a **Mixer value** feedback, neither of which exists any more. The example path `ch.1.grp.dca.0` is now split across the **Channel** dropdown and a relative **Path**, so the example can't be followed either. This is the first place a user goes when the upgraded buttons (H1, H2) stop working.

**Evidence:**

```md
<!-- companion/HELP.md:30-34 and :64 (v2.0.0) -->
| Action             | Description                           |
| ------------------ | ------------------------------------- |
| `Start Offline`    | Starts offline mode in mixing station |
| `Connect to Mixer` | Connects mixing station to a mixer    |
| `Set Value`        | Sets a mixer parameter                |
...
1. Add a new feedback to a button: `Mixer value`
2. Chose the parameter, for example `ch.1.grp.dca.0` for the DCA 1 assignment of Channel 2
```

The module now defines **Set Value (Channel)**, **Set Value (FX)** and **Set Value (Others)** ([`src/ActionAndFeedbackFactory.ts:47`](https://github.com/bitfocus/companion-module-devcore-mixingstation/blob/d6029cdd77df4f7d81060720bfdfc596b5f9f660/src/ActionAndFeedbackFactory.ts#L47), [`:78`](https://github.com/bitfocus/companion-module-devcore-mixingstation/blob/d6029cdd77df4f7d81060720bfdfc596b5f9f660/src/ActionAndFeedbackFactory.ts#L78), [`:92`](https://github.com/bitfocus/companion-module-devcore-mixingstation/blob/d6029cdd77df4f7d81060720bfdfc596b5f9f660/src/ActionAndFeedbackFactory.ts#L92)) and the feedbacks **Value (Channel)**, **Value (FX)** and **Value (Others)** ([`:62`](https://github.com/bitfocus/companion-module-devcore-mixingstation/blob/d6029cdd77df4f7d81060720bfdfc596b5f9f660/src/ActionAndFeedbackFactory.ts#L62), [`:84`](https://github.com/bitfocus/companion-module-devcore-mixingstation/blob/d6029cdd77df4f7d81060720bfdfc596b5f9f660/src/ActionAndFeedbackFactory.ts#L84), [`:98`](https://github.com/bitfocus/companion-module-devcore-mixingstation/blob/d6029cdd77df4f7d81060720bfdfc596b5f9f660/src/ActionAndFeedbackFactory.ts#L98)).

**Confirm by:** open [`companion/HELP.md`](https://github.com/bitfocus/companion-module-devcore-mixingstation/blob/d6029cdd77df4f7d81060720bfdfc596b5f9f660/companion/HELP.md) and search for `Mixer value` and `Set Value`. Then compare with the names in [`src/ActionAndFeedbackFactory.ts:47-98`](https://github.com/bitfocus/companion-module-devcore-mixingstation/blob/d6029cdd77df4f7d81060720bfdfc596b5f9f660/src/ActionAndFeedbackFactory.ts#L47-L98).

**Fix:** update the Actions and Feedback / Variables sections:

- list **Set Value (Channel/FX/Others)** and explain the new **Channel** dropdown and the relative **Path**;
- rename the feedback example to **Value (Channel)**, and redo the `ch.1.grp.dca.0` example as **Channel** = channel 2 and **Path** = `grp.dca.0`;
- mention the new **Fade Time (ms)** option next to the existing fade-time note.

---

## 🟡 Medium

### M1: The CI workflow builds with Node.js 18 instead of 22

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **File:** [`.github/workflows/node.yaml:19-23`](https://github.com/bitfocus/companion-module-devcore-mixingstation/blob/d6029cdd77df4f7d81060720bfdfc596b5f9f660/.github/workflows/node.yaml#L19-L23)
- **Template:** [API 1 TypeScript template](https://github.com/bitfocus/companion-module-template-ts/tree/42609d8dab515a25ec2f3b3c7adafe57aa41b7be): [`.github/workflows/node.yaml`](https://github.com/bitfocus/companion-module-template-ts/blob/42609d8dab515a25ec2f3b3c7adafe57aa41b7be/.github/workflows/node.yaml)

**What goes wrong:** No user-visible effect. The GitHub workflow tests the module on Node.js 18, but Companion runs it on Node.js 22 (`runtime.type: "node22"` in the manifest). The workflow's own comment says the two should match.

```yaml
- name: Use Node.js 18.x
  # This should match the version of Node.js you have defined in the manifest.json runtime field
  uses: actions/setup-node@v4
  with:
    node-version: 18.x
```

**Fix:** change both the step name and `node-version` to `22.x`, as in the template.

---

## 📝 Additional Notes

- [`tsconfig.build.json`](https://github.com/bitfocus/companion-module-devcore-mixingstation/blob/d6029cdd77df4f7d81060720bfdfc596b5f9f660/tsconfig.build.json) differs from the [template's](https://github.com/bitfocus/companion-module-template-ts/blob/42609d8dab515a25ec2f3b3c7adafe57aa41b7be/tsconfig.build.json): it extends `@companion-module/tools/tsconfig/node18/recommended` where the template uses `node22/recommended`, while the manifest declares `node22`. The module builds and lints, so no change is required, but switching to the node22 config would match the runtime.
