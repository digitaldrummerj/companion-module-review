# Review: livemotion-livematrix v0.1.0

| Field | Value |
| --- | --- |
| **Module** | `companion-module-livemotion-livematrix` |
| **Scope** | `tag` |
| **Version** | v0.1.0 ([`f50815e`](https://github.com/bitfocus/companion-module-livemotion-livematrix/tree/f50815e828341b43e8e8a96f262735e8ebc52320)) |
| **Release** | New module — never published |
| **API** | 2.2 (base 2.2.1, yarn.lock) — requires Companion 5.1+ |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Previous tag** | none — first release, so the whole module was reviewed |
| **Reviewed** | 2026-11-16 |

## Verdict: ❌ Changes Required

## ❓ Assumptions

Some findings depend on assumptions the reviewers couldn't check. They're listed in [❓ Assumptions to Confirm](#-assumptions-to-confirm) at the end of this review.

## 📋 Issues

### Blocking

- [ ] [C1: Missing the template's `build:main` script (`build` runs tsc directly)](#c1-missing-the-templates-buildmain-script-build-runs-tsc-directly)
- [ ] [C2: Missing the template's `dev` script (renamed to `watch`)](#c2-missing-the-templates-dev-script-renamed-to-watch)
- [ ] [H1: Manifest lists a legacy id for a module that has never been published](#h1-manifest-lists-a-legacy-id-for-a-module-that-has-never-been-published)
- [ ] [H2: Actions, feedbacks and variables all sit in `src/index.ts` instead of the template's separate files](#h2-actions-feedbacks-and-variables-all-sit-in-srcindexts-instead-of-the-templates-separate-files)
- [ ] [H3: `@companion-module/base` uses a caret range, so a lockfile refresh can raise the minimum Companion version](#h3-companion-modulebase-uses-a-caret-range-so-a-lockfile-refresh-can-raise-the-minimum-companion-version)
- [ ] [H4: Action and feedback options aren't type-checked, so a typo in a preset builds but does nothing](#h4-action-and-feedback-options-arent-type-checked-so-a-typo-in-a-preset-builds-but-does-nothing)

### Non-blocking

- [ ] [M1: Connection status shows only Disconnected and hides why the connection failed](#m1-connection-status-shows-only-disconnected-and-hides-why-the-connection-failed)
- [ ] [L1: A talk press still waiting when the connection is disabled starts a heartbeat timer that never stops](#l1-a-talk-press-still-waiting-when-the-connection-is-disabled-starts-a-heartbeat-timer-that-never-stops)
- [ ] [L2: Talk key presets open the mic 120 ms late even though they never use double tap](#l2-talk-key-presets-open-the-mic-120-ms-late-even-though-they-never-use-double-tap)
- [ ] [L3: Server host and Control API host will log a deprecation warning once base moves to 2.2.2](#l3-server-host-and-control-api-host-will-log-a-deprecation-warning-once-base-moves-to-222)
- [ ] [N1: Mode and Press behaviour dropdowns could opt out of expression mode](#n1-mode-and-press-behaviour-dropdowns-could-opt-out-of-expression-mode)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🔴 Critical

### C1: Missing the template's `build:main` script (`build` runs tsc directly)

- **Source:** 🤖 validate-template (PKG-SCRIPT), merged with 🔎 compliance reviewer — verified (the `build` command itself)
- **Classification:** 🆕 NEW
- **File:** [`package.json:23`](https://github.com/bitfocus/companion-module-livemotion-livematrix/blob/f50815e828341b43e8e8a96f262735e8ebc52320/package.json#L23)

**What goes wrong:** Operators see no difference. A maintainer, script or doc that uses the template's script names does: `yarn build:main` fails because there is no such script, and `yarn build` runs the TypeScript compiler itself instead of cleaning `dist/` and handing off to `build:main` the way every module built from the template does.

**Why it happens:** The module folded the template's `build:main` command into `build`. The template keeps them apart: `build` removes `dist/` and then runs `build:main`, which does the compile. Every script name in the template is required, and the `build` command should match the template's too.

**Evidence:**

```json
// package.json:23-24 (module)
"build": "rimraf dist && tsc --project tsconfig.build.json",
"watch": "tsc --project tsconfig.build.json --watch",

// companion-module-template-ts package.json:10-12 (main, e0d42b7)
"build": "rimraf dist && run build:main",
"build:main": "tsc -p tsconfig.build.json",
"dev": "tsc -p tsconfig.build.json --watch",
```

**Confirm by:** `grep -n '"build:main"' package.json` returns nothing; then compare [`package.json:23`](https://github.com/bitfocus/companion-module-livemotion-livematrix/blob/f50815e828341b43e8e8a96f262735e8ebc52320/package.json#L23) with the template's `package.json:10-11`.

**Fix:** use the template's build scripts exactly (this also fixes [C2](#c2-missing-the-templates-dev-script-renamed-to-watch)). Keep `test` as it is.

```json
"build": "rimraf dist && run build:main",
"build:main": "tsc -p tsconfig.build.json",
"dev": "tsc -p tsconfig.build.json --watch",
```

### C2: Missing the template's `dev` script (renamed to `watch`)

- **Source:** 🤖 validate-template (PKG-SCRIPT)
- **Classification:** 🆕 NEW
- **File:** [`package.json:24`](https://github.com/bitfocus/companion-module-livemotion-livematrix/blob/f50815e828341b43e8e8a96f262735e8ebc52320/package.json#L24)

**What goes wrong:** Operators see no difference. `yarn dev`, the template's watch-and-rebuild command, fails because the script is called `watch` in this module.

**Why it happens:** The template's `dev` script was renamed to `watch` (and spells `-p` as `--project`). Every script name in the template is required.

**Evidence:**

```json
// package.json:24 (module)
"watch": "tsc --project tsconfig.build.json --watch",

// companion-module-template-ts package.json:12 (main, e0d42b7)
"dev": "tsc -p tsconfig.build.json --watch",
```

**Confirm by:** `grep -n '"dev"' package.json` returns nothing.

**Fix:** rename `watch` to `dev` with the template's command, `"dev": "tsc -p tsconfig.build.json --watch"` (included in the [C1](#c1-missing-the-templates-buildmain-script-build-runs-tsc-directly) snippet). Keeping `watch` as an extra script is fine.

## 🟠 High

### H1: Manifest lists a legacy id for a module that has never been published

- **Source:** 🤖 validate-template (MAN-LEGACYIDS)
- **Classification:** 🆕 NEW
- **File:** [`companion/manifest.json:24`](https://github.com/bitfocus/companion-module-livemotion-livematrix/blob/f50815e828341b43e8e8a96f262735e8ebc52320/companion/manifest.json#L24)

**What goes wrong:** Companion reads `legacyIds` as the module's earlier names, and opens a connection saved under any of those ids (in a config, a page export or a backup) with this module instead. This module has never been published, so it has no earlier names. Listing `livematrix` would let this module claim any connection saved under that id, whatever module it really belonged to.

**Why it happens:** The manifest ships `"legacyIds": ["livematrix"]`. The template has an empty list, which is what a first release needs.

**Evidence:**

```json
// companion/manifest.json:24 (module)
"legacyIds": ["livematrix"],

// companion-module-template-ts companion/manifest.json:24
"legacyIds": [],
```

**Confirm by:** `grep -n legacyIds companion/manifest.json`.

**Fix:** empty the list, as in the template.

```json
"legacyIds": [],
```

### H2: Actions, feedbacks and variables all sit in `src/index.ts` instead of the template's separate files

- **Source:** 🔎 compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/index.ts:493-985`](https://github.com/bitfocus/companion-module-livemotion-livematrix/blob/f50815e828341b43e8e8a96f262735e8ebc52320/src/index.ts#L493-L985)

**What goes wrong:** Operators see no difference. Maintainers and reviewers do: the TypeScript template keeps actions in `src/actions.ts`, feedbacks in `src/feedbacks.ts` and variable definitions in `src/variables.ts`. This module builds all three inside the 1,684-line `src/index.ts`, so anyone troubleshooting the "Talk key down" action or the "Talk active" feedback won't find it where every other TypeScript module keeps it.

**Why it happens:** The three definition lists are private methods on the module class (`getActionDefinitions`, `getFeedbackDefinitions`, `getVariableDefinitions`) instead of the template's `UpdateActions` / `UpdateFeedbacks` / `UpdateVariableDefinitions` functions in their own files. `config.ts`, `presets.ts` and `upgrades.ts` are already split out the way the template has them.

**Evidence:**

```text
// ls src/ (module at v0.1.0)
activity.ts brand.ts config.ts connection.ts icons.ts index.ts key-state.ts levels.ts options.ts presets.ts protocol.ts upgrades.ts
// wc -l src/index.ts
1684 src/index.ts

// companion-module-template-ts (main, e0d42b7) ls src/
actions.ts config.ts feedbacks.ts main.ts presets.ts upgrades.ts variables.ts
```

```ts
// src/index.ts:493-502
	private setupDefinitions(): void {
		this.setActionDefinitions(this.getActionDefinitions())
		this.setFeedbackDefinitions(this.getFeedbackDefinitions())
		const { structure, presets } = getPresetDefinitions(this.keys)
		this.setPresetDefinitions(structure, presets)
		this.setVariableDefinitions(this.getVariableDefinitions())
		this.pushVariableValues()
	}

	private getActionDefinitions(): CompanionActionDefinitions {
// src/index.ts:719
	private getFeedbackDefinitions(): CompanionFeedbackDefinitions {
// src/index.ts:941
	private getVariableDefinitions(): CompanionVariableDefinitions {
```

```ts
// companion-module-template-ts src/main.ts:2-7
import { GetConfigFields, type ModuleConfig } from './config.js'
import { UpdateVariableDefinitions, type VariablesSchema } from './variables.js'
import { UpgradeScripts } from './upgrades.js'
import { UpdateActions, type ActionsSchema } from './actions.js'
import { UpdateFeedbacks, type FeedbacksSchema } from './feedbacks.js'
import { UpdatePresets } from './presets.js'
```

**Confirm by:** run `ls src/` in the module: there is no `actions.ts`, `feedbacks.ts` or `variables.ts`. Then open [`src/index.ts:502`](https://github.com/bitfocus/companion-module-livemotion-livematrix/blob/f50815e828341b43e8e8a96f262735e8ebc52320/src/index.ts#L502), [`src/index.ts:719`](https://github.com/bitfocus/companion-module-livemotion-livematrix/blob/f50815e828341b43e8e8a96f262735e8ebc52320/src/index.ts#L719) and [`src/index.ts:941`](https://github.com/bitfocus/companion-module-livemotion-livematrix/blob/f50815e828341b43e8e8a96f262735e8ebc52320/src/index.ts#L941), where the three lists are built as private methods.

**Fix:** move each definition list into its own file, as the TypeScript template does.

- `getActionDefinitions` ([`src/index.ts:502-717`](https://github.com/bitfocus/companion-module-livemotion-livematrix/blob/f50815e828341b43e8e8a96f262735e8ebc52320/src/index.ts#L502-L717)) → `src/actions.ts`, exported as `UpdateActions(self)` with an `ActionsSchema` type.
- `getFeedbackDefinitions` ([`src/index.ts:719-939`](https://github.com/bitfocus/companion-module-livemotion-livematrix/blob/f50815e828341b43e8e8a96f262735e8ebc52320/src/index.ts#L719-L939)) → `src/feedbacks.ts`, as `UpdateFeedbacks(self)` with a `FeedbacksSchema` type.
- `getVariableDefinitions` ([`src/index.ts:941-985`](https://github.com/bitfocus/companion-module-livemotion-livematrix/blob/f50815e828341b43e8e8a96f262735e8ebc52320/src/index.ts#L941-L985)) → `src/variables.ts`, as `UpdateVariableDefinitions(self)` with a `VariablesSchema` type.

The callbacks call instance methods such as `resolveKey`, `onTalkDown` and `keyState`, so make those methods public or pass in a small interface. The schema types also fix [H4](#h4-action-and-feedback-options-arent-type-checked-so-a-typo-in-a-preset-builds-but-does-nothing).

### H3: `@companion-module/base` uses a caret range, so a lockfile refresh can raise the minimum Companion version

- **Source:** 🔎 compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`package.json:35`](https://github.com/bitfocus/companion-module-livemotion-livematrix/blob/f50815e828341b43e8e8a96f262735e8ebc52320/package.json#L35)

**What goes wrong:** Nothing visible today: yarn.lock pins base 2.2.1, so the module runs on API 2.2 and needs Companion 5.1+. But `^2.2.1` also accepts 2.3.0 and later. The next `yarn up` or lockfile refresh can move the module to a newer API level, and with it the minimum Companion version, without anyone deciding to. Users still on Companion 5.1 could then find that the connection no longer loads after they update the module.

**Why it happens:** The template pins base with a tilde (`~`), which only accepts patch updates, so the API level changes only when the maintainer bumps it on purpose. API 2.2 is a valid choice; only the range operator differs.

**Evidence:**

```json
// package.json:34-37 (module)
	"dependencies": {
		"@companion-module/base": "^2.2.1",
		"ws": "^8.22.0"
	},

// companion-module-template-ts package.json:25-27 (main, e0d42b7)
	"dependencies": {
		"@companion-module/base": "~2.1.3"
	},
```

```text
// yarn.lock:30-32
"@companion-module/base@npm:^2.2.1":
  version: 2.2.1
  resolution: "@companion-module/base@npm:2.2.1"

// semver, run with the module's node_modules
satisfies('2.3.0','^2.2.1') -> true
satisfies('2.3.0','~2.2.1') -> false
```

**Confirm by:** open [`package.json:35`](https://github.com/bitfocus/companion-module-livemotion-livematrix/blob/f50815e828341b43e8e8a96f262735e8ebc52320/package.json#L35): it reads `"^2.2.1"`, where the template's `package.json:26` uses `"~2.1.3"`.

**Fix:** switch to a tilde range. This keeps API 2.2 and matches the template's style; bump the minor version on purpose when you want a newer API level.

```json
"@companion-module/base": "~2.2.1",
```

### H4: Action and feedback options aren't type-checked, so a typo in a preset builds but does nothing

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/config.ts:20-26`](https://github.com/bitfocus/companion-module-livemotion-livematrix/blob/f50815e828341b43e8e8a96f262735e8ebc52320/src/config.ts#L20-L26)

**What goes wrong:** Nothing visible today. But TypeScript can't catch a misspelled action or feedback id in a preset (for example `feedbackId: 'talk_latchd'`) or an option of the wrong type, so a preset with such a typo would build and then silently do nothing on the user's button. The TypeScript template types its actions, feedbacks and variables, and this module differs from it.

**Why it happens:** The module's schema type declares actions and feedbacks as `Record<string, any>`, so every action, feedback and preset definition falls back to untyped options. The callbacks then need casts such as `options.press_behaviour as PressBehaviour` ([`src/options.ts:154`](https://github.com/bitfocus/companion-module-livemotion-livematrix/blob/f50815e828341b43e8e8a96f262735e8ebc52320/src/options.ts#L154)) and `options.mode as SetMode` ([`src/options.ts:158`](https://github.com/bitfocus/companion-module-livemotion-livematrix/blob/f50815e828341b43e8e8a96f262735e8ebc52320/src/options.ts#L158)).

**Evidence:**

```ts
// src/config.ts:20-26
export type LivematrixManifest = {
	config: LivematrixConfig
	secrets: LivematrixSecrets
	actions: Record<string, any>
	feedbacks: Record<string, any>
	variables: CompanionVariableValues
}
// src/options.ts:154, 158
	return (options.press_behaviour as PressBehaviour | undefined) ?? 'auto'
	return (options.mode as SetMode | undefined) ?? 'toggle'
// companion-module-template-ts/src/main.ts:9-15 (main @ e0d42b7)
export type ModuleSchema = {
	config: ModuleConfig
	secrets: undefined
	actions: ActionsSchema
	feedbacks: FeedbacksSchema
	variables: VariablesSchema
}
```

**Confirm by:** open [`src/config.ts:20-26`](https://github.com/bitfocus/companion-module-livemotion-livematrix/blob/f50815e828341b43e8e8a96f262735e8ebc52320/src/config.ts#L20-L26), where `actions` and `feedbacks` are `Record<string, any>`, and compare it with `ModuleSchema` in `companion-module-template-ts/src/main.ts`.

**Fix:** declare real schemas, as the template does with `ActionsSchema` / `FeedbacksSchema` / `VariablesSchema`. For example `talk_down: { options: { selection_mode: string; key_index: number; key_target: string; press_behaviour: PressBehaviour; hold_selects: boolean; also_select: boolean } }`, and value feedbacks with a `result` type (`key_listen_level_db: { type: 'value'; options: …; result: number }`, which API 2.2 expects). Then type the definitions with them and drop the casts. Renaming the type to `ModuleSchema`, as in the template, fits in with this. Pairs naturally with [H2](#h2-actions-feedbacks-and-variables-all-sit-in-srcindexts-instead-of-the-templates-separate-files).

## 🟡 Medium

### M1: Connection status shows only Disconnected and hides why the connection failed

- **Source:** 🔎 protocol reviewer, QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/index.ts:258-269`](https://github.com/bitfocus/companion-module-livemotion-livematrix/blob/f50815e828341b43e8e8a96f262735e8ebc52320/src/index.ts#L258-L269)

**What goes wrong:** A user sets up the connection with the defaults ("Use TLS" on, "Accept a self-signed certificate" off, port 9443) against a server with a self-signed certificate, or the server isn't running, or the port is wrong. On the Connections page the status just reads "Disconnected", with no message, and stays that way through every 5-second retry. The real cause ("self-signed certificate", "Hostname/IP does not match certificate's altnames", "connect ECONNREFUSED 192.168.1.20:9443") only appears in the log. A related case: once a login has been refused for a passing reason (for example a full licence), later failures such as an unreachable server keep showing that old refusal as the status message.

**Why it happens:** When a connection attempt fails, the `ws` library reports an error and then a close, one right after the other. The module's error handler sets "Connection failure" with the reason, and the close handler immediately overwrites it with a plain "Disconnected" (or with the old login-refusal reason), so the failure status with its reason is never visible. The reviewers reproduced this with the module's own test harness: the statuses went connecting → connection failure "connect ECONNREFUSED 127.0.0.1:…" → disconnected.

```ts
// src/index.ts:258-269
				close: (reconnecting) => {
					this.clearHolds()
					this.clearActivity()
					this.pushVariableValues()
					if (!reconnecting) return
					if (this.retryReason) this.updateStatus(InstanceStatus.ConnectionFailure, this.retryReason)
					else this.updateStatus(InstanceStatus.Disconnected)
				},
				error: (message) => {
					this.log('error', `WebSocket error: ${message}`)
					this.updateStatus(InstanceStatus.ConnectionFailure, message)
				},
```

**Fix:** remember the last socket error of the current attempt and show it when the socket closes. Set it in the error callback, clear it on open and on login success, and in the close callback call `updateStatus(InstanceStatus.ConnectionFailure, this.retryReason ?? this.lastSocketError)` when either is set, falling back to Disconnected only when there is no reason. Also clear `retryReason` when a later attempt fails for a different cause, so an old licence message doesn't cover an unreachable server. Depends on [A1](#-assumptions-to-confirm).

## 🟢 Low

### L1: A talk press still waiting when the connection is disabled starts a heartbeat timer that never stops

- **Source:** 🔎 protocol reviewer, QA reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/index.ts:218-223`](https://github.com/bitfocus/companion-module-livemotion-livematrix/blob/f50815e828341b43e8e8a96f262735e8ebc52320/src/index.ts#L218-L223)

**What goes wrong:** An operator presses a "Talk key down" button on a key that can both talk and listen, and within the next fraction of a second the connection is disabled, deleted or shut down. On these keys a press waits 120 ms before it opens the mic, and a tap's release waits 250 ms. Those waiting presses aren't cancelled when the connection is torn down, so the press still lands afterwards, records the key as held and starts the 10-second "momentary heartbeat" timer, and nothing stops that timer again. Nothing shows in Companion, because the heartbeat has no connection left to send on; the timer just keeps running until the module process ends. The reviewers reproduced it with the module's own test harness: 300 ms after `destroy()` the heartbeat timer was running with one key held. The same thing can happen during "Save" in the connection settings, when a press lands while the old connection is being closed.

**Why it happens:** When a connection is removed, Companion calls the module's `destroy()` to clean up. `destroy()` stops the heartbeat, the level repeats and the activity timer, but not the three maps of one-shot timers (`pressTimers`, `settleTimers`, `selectHoldTimers`). Only `resetSession()` clears those, and only `configUpdated()` calls it. A press timer that fires after `destroy()` goes through `applyTalkPress` → `setTalkActive` → `sendKeyState(…, 'momentary', true)` → `recordHold` → `syncHeartbeat`, which creates a new interval after the holds were already cleared.

**Evidence:**

```ts
// src/index.ts:218-223
	async destroy(): Promise<void> {
		this.clearHolds()
		this.stopAllLevelRepeats()
		clearTimeout(this.activityTrailTimer)
		await this.disconnect()
	}

// src/index.ts:1150-1158
		if (PRESS_SETTLE_MS > 0 && this.doubleTapArmedForKey(key)) {
			this.pressTimers.set(
				key.target_id,
				setTimeout(() => {
					this.pressTimers.delete(key.target_id)
					this.applyTalkPress(key)
				}, PRESS_SETTLE_MS),
			)
			return
		}

// src/index.ts:1616-1619
		this.heartbeatTimer ??= setInterval(() => {
			if (this.heldKeys.size === 0) return
			this.send({ type: 'momentary_heartbeat', held: [...this.heldKeys.values()] })
		}, this.heartbeatIntervalMs)

// src/index.ts:1664-1670 (resetSession, called only from configUpdated)
		for (const timer of this.settleTimers.values()) clearTimeout(timer)
		this.settleTimers.clear()
		for (const timer of this.pressTimers.values()) clearTimeout(timer)
		this.pressTimers.clear()
		this.stopAllLevelRepeats()
		for (const timer of this.selectHoldTimers.values()) clearTimeout(timer)
		this.selectHoldTimers.clear()
```

**Confirm by:** open [`src/index.ts:218-223`](https://github.com/bitfocus/companion-module-livemotion-livematrix/blob/f50815e828341b43e8e8a96f262735e8ebc52320/src/index.ts#L218-L223): `destroy()` never clears `pressTimers` or `settleTimers`; only [`src/index.ts:1664-1670`](https://github.com/bitfocus/companion-module-livemotion-livematrix/blob/f50815e828341b43e8e8a96f262735e8ebc52320/src/index.ts#L1664-L1670) does.

**Fix:** move the timer-clearing part of `resetSession()` into a `clearTimers()` helper that clears `settleTimers`, `pressTimers`, `selectHoldTimers`, the level repeats and `activityTrailTimer`, and call it first in both `destroy()` and `configUpdated()`, before `clearHolds()`. Otherwise a press timer can still fire during `await this.disconnect()` and rebuild the held keys and the heartbeat. A `destroyed` flag that `syncHeartbeat()` checks before creating an interval is a good extra guard.

### L2: Talk key presets open the mic 120 ms late even though they never use double tap

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/index.ts:1147-1158`](https://github.com/bitfocus/companion-module-livemotion-livematrix/blob/f50815e828341b43e8e8a96f262735e8ebc52320/src/index.ts#L1147-L1158)

**What goes wrong:** On a user or party-line key that can both talk and listen, the "Talk key" and "Talk key (by index)" presets turn double tap off ("Double tap switches listening" unchecked on "Talk key up"). Every push-to-talk press on those buttons still waits 120 ms before talk is sent, and with "Press behaviour: Momentary only" a tap shorter than 120 ms sends nothing at all. The same happens on any button an operator builds with that checkbox unchecked. The delay only exists to hide the double-tap gesture, which these buttons never use.

**Why it happens:** The press side decides whether to wait by looking only at the key's abilities (can it talk and listen?). The "Double tap switches listening" option exists only on "Talk key up", so "Talk key down" can't know that this button never double taps.

**Fix:** add the same "Double tap switches listening" checkbox (or a hidden flag) to "Talk key down", set it to off in the talk presets' down action, and only arm the 120 ms wait when it is on, for example `if (PRESS_SETTLE_MS > 0 && this.doubleTapArmed(key, doubleTapListen))`.

### L3: Server host and Control API host will log a deprecation warning once base moves to 2.2.2

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/config.ts:58`](https://github.com/bitfocus/companion-module-livemotion-livematrix/blob/f50815e828341b43e8e8a96f262735e8ebc52320/src/config.ts#L58), [`src/config.ts:121`](https://github.com/bitfocus/companion-module-livemotion-livematrix/blob/f50815e828341b43e8e8a96f262735e8ebc52320/src/config.ts#L121)

**What goes wrong:** Nothing today: in the locked base 2.2.1, `Regex.HOSTNAME` is still a plain constant. Once base moves to 2.2.2 or later, the connection log shows a deprecation warning ("Regex.HOSTNAME is deprecated …") when the config fields load. The pattern also rejects IPv6 addresses in the "Server host" field. Depends on [A2](#-assumptions-to-confirm).

**Why it happens:** API 2.2.2 deprecates the hostname and IP regex presets in favour of a plain text field (or `Regex.IPV4` / `Regex.IPV6` when the device really needs that address family). Both config fields still use `Regex.HOSTNAME`.

**Fix:** remove `regex: Regex.HOSTNAME` from the "Server host" and "Control API host" fields and drop the `Regex` import. `validateConfig` already rejects an empty host, and both fields stay text fields with string values, so no upgrade script is needed.

## 💡 Nice to Have

### N1: Mode and Press behaviour dropdowns could opt out of expression mode

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/options.ts:108-116`](https://github.com/bitfocus/companion-module-livemotion-livematrix/blob/f50815e828341b43e8e8a96f262735e8ebc52320/src/options.ts#L108-L116), [`src/options.ts:143-151`](https://github.com/bitfocus/companion-module-livemotion-livematrix/blob/f50815e828341b43e8e8a96f262735e8ebc52320/src/options.ts#L143-L151)

**What goes wrong:** Nothing breaks. The "Mode" (Toggle / On / Off) and "Press behaviour" fields of "Talk set", "Listen set", "Talk key down" and similar actions show the expression-mode toggle in the action editor, which rarely makes sense for a fixed choice.

**Why it happens:** Neither dropdown sets `disableAutoExpression: true`, which API 2.x recommends for fixed on/off/toggle-style choices.

**Fix:** add `disableAutoExpression: true` to `getPressBehaviourOption()` and `getSetModeOption()`. Leave it off if you want users to drive the mode from a variable.

## 📝 Additional Notes

- This is the module's first release, so there is no earlier tag to compare with: the whole module was reviewed.
- `tsconfig.build.json` leaves out the template's `"verbatimModuleSyntax": true` compiler option (`compilerOptions` ends at `"rootDir": "./src"`, [`tsconfig.build.json:7`](https://github.com/bitfocus/companion-module-livemotion-livematrix/blob/f50815e828341b43e8e8a96f262735e8ebc52320/tsconfig.build.json#L7)). The module builds and lints, so no change is required.

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Companion shows the message passed to `updateStatus` next to the connection status on the Connections page, so a "Connection failure" carrying the error text would reach the user | general Companion UI behaviour; not determinable from the module or base 2.2.1 | [M1](#m1-connection-status-shows-only-disconnected-and-hides-why-the-connection-failed) |
| A2 | Base 2.2.2 and later log a deprecation warning in the connection log when a module reads `Regex.HOSTNAME` | companion-v2-api-compliance `references/v2.2.md` (2.2.2 patch table); the installed base 2.2.1 has no such warning, so it couldn't be confirmed | [L3](#l3-server-host-and-control-api-host-will-log-a-deprecation-warning-once-base-moves-to-222) |
