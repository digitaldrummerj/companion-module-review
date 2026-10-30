# Review: companion-module-google-nest v1.0.1

| | |
| --- | --- |
| **Module** | [companion-module-google-nest](https://github.com/bitfocus/companion-module-google-nest) |
| **Scope** | `tag` |
| **Version** | v1.0.1 (`7a489db`) |
| **Release** | New module — never published |
| **API** | 2.0 (base 2.0.4, yarn.lock) — requires Companion 4.3+ |
| **Template** | `companion-module-template-ts-v2.0.4` @ `d62230e` (2026-08-28, pinned) |
| **Review date** | 2026-10-30 |

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | When a user adds a new connection, Companion calls `init()` with the default (blank) config straight away; when the user then enters the credentials and saves, Companion calls `configUpdated()`, not `init()` again | Usual Companion connection lifecycle; not visible in the module or in `@companion-module/base` | [H4](#h4-after-the-credentials-are-entered-on-a-new-connection-the-device-dropdowns-in-every-action-and-feedback-stay-empty) |
| A2 | Companion re-runs a module's boolean feedbacks only when the module calls `checkFeedbacks()` / `checkAllFeedbacks()` (or when the feedback or its options change), never on a timer of its own | `@companion-module/base` 2.0.4 typings document `checkFeedbacks` as the way to request re-execution; the host-side scheduler was not checked or live-tested | [H3](#h3-the-device-online-thermostat-mode-active-and-hvac-running-feedbacks-never-update-after-the-first-draw) |
| A3 | Google's SDM API rejects requests (for example HTTP 429) once the per-minute quota is exceeded, which turns the connection status to an error | The module's own Poll Interval tooltip ("rate limit of 5 queries per minute"); the exact behaviour is Google's | [H2](#h2-every-config-save-adds-another-poll-timer-so-the-module-ends-up-hitting-the-google-api-rate-limit), [L1](#l1-the-minimum-poll-interval-of-12-seconds-exceeds-the-5-requests-per-minute-limit-stated-in-the-modules-own-tooltip) |
| A4 | The 'Mode' dropdown in 'Set Temperature' was meant to choose which setpoint (heat or cool) to change. If the intent was "change whichever setpoint is active", the dropdown is only a misleading leftover and the finding is closer to Medium. Nest SDM probably also rejects SetHeat when the thermostat is not in HEAT mode | The option is declared and typed but never read; Nest's command validation could not be checked from the code | [H5](#h5-set-temperature-ignores-its-mode-option-and-changes-whichever-setpoint-the-thermostat-is-currently-using) |
| A5 | With base 2.0 the Companion host catches a rejected action callback and logs it, so an uncaught command failure is a missing-log problem, not a crash | The action-callback invocation is not in the base 2.0.4 package in `node_modules`, so it could not be checked locally | [L2](#l2-a-failed-thermostat-command-is-not-logged-by-the-module-and-does-not-change-the-connection-status) |

## 📋 Issues

### Blocking

- [ ] [H1: CI workflow differs from the template and tests on Node 26 instead of Node 22](#h1-ci-workflow-differs-from-the-template-and-tests-on-node-26-instead-of-node-22)
- [ ] [H2: Every config save adds another poll timer, so the module ends up hitting the Google API rate limit](#h2-every-config-save-adds-another-poll-timer-so-the-module-ends-up-hitting-the-google-api-rate-limit)
- [ ] [H3: The Device Online, Thermostat Mode active and HVAC running feedbacks never update after the first draw](#h3-the-device-online-thermostat-mode-active-and-hvac-running-feedbacks-never-update-after-the-first-draw)
- [ ] [H4: After the credentials are entered on a new connection, the Device dropdowns in every action and feedback stay empty](#h4-after-the-credentials-are-entered-on-a-new-connection-the-device-dropdowns-in-every-action-and-feedback-stay-empty)
- [ ] [H5: Set Temperature ignores its Mode option and changes whichever setpoint the thermostat is currently using](#h5-set-temperature-ignores-its-mode-option-and-changes-whichever-setpoint-the-thermostat-is-currently-using)

### Non-blocking

- [ ] [M1: A thermostat that is Off when the module starts is missing from every action's Device dropdown](#m1-a-thermostat-that-is-off-when-the-module-starts-is-missing-from-every-actions-device-dropdown)
- [ ] [M2: Thermostat actions silently do nothing when the thermostat's mode does not match](#m2-thermostat-actions-silently-do-nothing-when-the-thermostats-mode-does-not-match)
- [ ] [M3: Variables do not show a setpoint change made by an action until the next poll](#m3-variables-do-not-show-a-setpoint-change-made-by-an-action-until-the-next-poll)
- [ ] [M4: Client Secret and OAuth Refresh Token are stored as plain-text config, not as secrets](#m4-client-secret-and-oauth-refresh-token-are-stored-as-plain-text-config-not-as-secrets)
- [ ] [L1: The minimum poll interval of 12 seconds exceeds the 5-requests-per-minute limit stated in the module's own tooltip](#l1-the-minimum-poll-interval-of-12-seconds-exceeds-the-5-requests-per-minute-limit-stated-in-the-modules-own-tooltip)
- [ ] [L2: A failed thermostat command is not logged by the module and does not change the connection status](#l2-a-failed-thermostat-command-is-not-logged-by-the-module-and-does-not-change-the-connection-status)
- [ ] [L3: Every token expiry triggers two token refresh requests at once](#l3-every-token-expiry-triggers-two-token-refresh-requests-at-once)
- [ ] [L4: Two config fields share the id info](#l4-two-config-fields-share-the-id-info)
- [ ] [L5: Variable IDs change when a device or home is renamed, and can collide](#l5-variable-ids-change-when-a-device-or-home-is-renamed-and-can-collide)
- [ ] [L6: Template placeholder preset My first Preset button ships in the Presets tab](#l6-template-placeholder-preset-my-first-preset-button-ships-in-the-presets-tab)
- [ ] [N1: Fixed-choice dropdowns allow expression mode they do not need](#n1-fixed-choice-dropdowns-allow-expression-mode-they-do-not-need)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟠 High

### H1: CI workflow differs from the template and tests on Node 26 instead of Node 22

- **Source:** 🤖 validate-template (CONFIG-DIFF), raised to High by the review maintainer
- **Classification:** 🆕 NEW
- **File:** [`.github/workflows/node.yaml:19-25`](https://github.com/bitfocus/companion-module-google-nest/blob/7a489db3d35759bf44dee976db468a11f115aedb/.github/workflows/node.yaml#L19-L25), [`.github/workflows/node.yaml:62-65`](https://github.com/bitfocus/companion-module-google-nest/blob/7a489db3d35759bf44dee976db468a11f115aedb/.github/workflows/node.yaml#L62-L65)

**What goes wrong:** The GitHub CI check builds and lints the module on Node 26, but Companion runs this module on Node 22 (the `node22` runtime in [`companion/manifest.json:19`](https://github.com/bitfocus/companion-module-google-nest/blob/7a489db3d35759bf44dee976db468a11f115aedb/companion/manifest.json#L19)). A green CI run therefore doesn't prove the module works on the Node version it actually ships on, and the workflow no longer matches the template that later troubleshooting is compared against.

**Why it happens:** The workflow was edited away from the v2.0.4 template: it adds a `with: persist-credentials: false` block to the checkout step and changes the Node version from 22.x to 26.x, in both the active job and the commented-out test job.

**Evidence:** validator message "Differs from template (line 19: found '        with:', template '      - name: Use Node.js 22.x')".

```yaml
# .github/workflows/node.yaml:18-25 (module)
      - uses: actions/checkout@v7
        with:
          persist-credentials: false
      - name: Use Node.js 26.x
        # This should match the version of Node.js you have defined in the manifest.json runtime field
        uses: actions/setup-node@v6
        with:
          node-version: 26.x
```

The template has no `with:` block after `actions/checkout@v7`, and uses `- name: Use Node.js 22.x` / `node-version: 22.x`. Lines 62 and 65 (the commented-out test job) also say 26.x where the template says 22.x.

**Confirm by:** `diff companion-module-template-ts-v2.0.4/.github/workflows/node.yaml .github/workflows/node.yaml` prints nothing once fixed.

**Fix:** copy `.github/workflows/node.yaml` unchanged from `companion-module-template-ts` v2.0.4 (Node 22.x, no extra checkout `with:` block).

### H2: Every config save adds another poll timer, so the module ends up hitting the Google API rate limit

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:53-60`](https://github.com/bitfocus/companion-module-google-nest/blob/7a489db3d35759bf44dee976db468a11f115aedb/src/main.ts#L53-L60), [`src/main.ts:86-90`](https://github.com/bitfocus/companion-module-google-nest/blob/7a489db3d35759bf44dee976db468a11f115aedb/src/main.ts#L86-L90)

**What goes wrong:** A user saves the connection settings three times, for example to fix the Client Secret and then to change 'Poll Interval (seconds)' from 30 to 60. Now three poll timers run at once (30 s, 30 s and 60 s), and each poll makes 2 Google requests (devices and structures). The module sends about 10 requests a minute instead of 4. The config tooltip itself says the SDM sandbox allows 5 a minute, so polls start failing and the connection status turns to an error ("Poll failed: SDM GET ... failed (429)"). Changing the poll interval also has no real effect, because the old timers keep running at the old rate. Only disabling and re-enabling the connection clears the extra timers.

**Why it happens:** Saving the settings calls `configUpdated()`, which starts a new repeating timer without stopping the one already running. The module only remembers the newest timer, so the older ones can never be stopped, not even by `destroy()` when the connection is disabled.

**Evidence:**

```ts
// src/main.ts:27
	private pollTimer: NodeJS.Timeout | null = null
```

```ts
// src/main.ts:48-60
	async destroy(): Promise<void> {
		this.log('debug', 'I am DEAD!')
		this.stopPolling()
	}

	async configUpdated(config: ModuleConfig): Promise<void> {
		this.config = config
		this.log('info', 'Config updated')
		this.client = new SdmClient(config)

		await this.getGoogleNestDevices()
		this.startPolling(config.pollIntervalSec ?? 30)
	}
```

```ts
// src/main.ts:86-97
	private startPolling(intervalSec: number): void {
		this.pollTimer = setInterval(() => {
			void this.getGoogleNestDevices()
		}, intervalSec * 1000)
	}

	private stopPolling(): void {
		if (this.pollTimer) {
			clearInterval(this.pollTimer)
			this.pollTimer = null
		}
	}
```

```ts
// src/config.ts:63-70
			id: 'pollIntervalSec',
			label: 'Poll Interval (seconds)',
...
				'How often to refresh device state from the SDM API, the SDM sandbox has a rate limit of 5 queries per minute. set the poll rate appropriately',
```

**Confirm by:** open [`src/main.ts:53-60`](https://github.com/bitfocus/companion-module-google-nest/blob/7a489db3d35759bf44dee976db468a11f115aedb/src/main.ts#L53-L60) and [`src/main.ts:86-90`](https://github.com/bitfocus/companion-module-google-nest/blob/7a489db3d35759bf44dee976db468a11f115aedb/src/main.ts#L86-L90). `configUpdated()` calls `startPolling()`, which overwrites `this.pollTimer` without clearing it first. The only `clearInterval` in `src/` is in `stopPolling()`, which only `destroy()` calls.

**Fix:** stop the running timer before starting a new one, so only one poll timer exists at a time.

```ts
	private startPolling(intervalSec: number): void {
		this.stopPolling()
		this.pollTimer = setInterval(() => {
			void this.getGoogleNestDevices()
		}, intervalSec * 1000)
	}
```

### H3: The Device Online, Thermostat Mode active and HVAC running feedbacks never update after the first draw

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:99-128`](https://github.com/bitfocus/companion-module-google-nest/blob/7a489db3d35759bf44dee976db468a11f115aedb/src/main.ts#L99-L128), [`src/feedbacks.ts:56-59`](https://github.com/bitfocus/companion-module-google-nest/blob/7a489db3d35759bf44dee976db468a11f115aedb/src/feedbacks.ts#L56-L59), [`src/feedbacks.ts:90-93`](https://github.com/bitfocus/companion-module-google-nest/blob/7a489db3d35759bf44dee976db468a11f115aedb/src/feedbacks.ts#L90-L93), [`src/feedbacks.ts:112-115`](https://github.com/bitfocus/companion-module-google-nest/blob/7a489db3d35759bf44dee976db468a11f115aedb/src/feedbacks.ts#L112-L115)

**What goes wrong:** A user adds the 'Thermostat: HVAC running' feedback to a button. The furnace starts, and on the next poll the variable `$(google-nest:..._hvac_status)` changes to HEATING, but the button stays unlit. When the furnace stops, a lit button doesn't turn off either. The same happens with 'Device: Online' when a device goes offline, and with 'Thermostat: Mode active' after the mode changes (from the wall unit, the Google Home app, or the module's own 'Set mode' action). The buttons only change when the user edits the feedback or the connection restarts.

**Why it happens:** Every poll refreshes the module's internal device list and the variables, but the module never tells Companion to re-check its feedbacks. Companion re-runs a feedback's check only when the module calls `checkFeedbacks()` (or when the feedback's options change), and nothing in `src/` calls it. The action callbacks also change the cached device state without calling it.

**Evidence:**

```ts
// src/main.ts:86-90
	private startPolling(intervalSec: number): void {
		this.pollTimer = setInterval(() => {
			void this.getGoogleNestDevices()
		}, intervalSec * 1000)
	}
```

```ts
// src/main.ts:111-122
			this.devices.clear()
			for (const device of rawDevices) {
				...
				this.devices.set(id, device)
			}
			this.updateVariableDefinitions()
			this.updateStatus(InstanceStatus.Ok)
```

```ts
// src/feedbacks.ts:56-59, 90-93, 112-115
			callback: ({ options }) => {
				const device = self.devices.get(options.deviceId)
				return device?.traits[TRAIT.CONNECTIVITY]?.status === 'ONLINE'
			},
			...
			callback: ({ options }) => {
				const device = self.devices.get(options.deviceId)
				return device?.traits[TRAIT.THERMOSTAT_MODE]?.mode === options.mode
			},
			...
			callback: ({ options }) => {
				const status = self.devices.get(options.deviceId)?.traits[TRAIT.HVAC]?.status
				return status === 'HEATING' || status === 'COOLING'
			},
```

```ts
// node_modules/@companion-module/base/dist/module-api/base.d.ts:125-135
    /**
     * Request all feedbacks of all types to be re-executed
     */
    checkAllFeedbacks(): void;
    /**
     * Request all feedbacks of the specified types to be re-executed.
     ...
    checkFeedbacks(feedbackType: StringKeys<TManifest['feedbacks']>, ...feedbackTypes: StringKeys<TManifest['feedbacks']>[]): void;
```

`grep -rn "checkFeedbacks\|checkAllFeedbacks" src/` returns nothing. `updateFeedbacks()` is called only once, in `init()` ([`src/main.ts:43`](https://github.com/bitfocus/companion-module-google-nest/blob/7a489db3d35759bf44dee976db468a11f115aedb/src/main.ts#L43)).

**Confirm by:** open [`src/main.ts:99-128`](https://github.com/bitfocus/companion-module-google-nest/blob/7a489db3d35759bf44dee976db468a11f115aedb/src/main.ts#L99-L128) and run `grep -rn checkFeedbacks src/`. There are no matches, so the feedbacks in [`src/feedbacks.ts`](https://github.com/bitfocus/companion-module-google-nest/blob/7a489db3d35759bf44dee976db468a11f115aedb/src/feedbacks.ts) never re-run after a poll changes the device list.

**Fix:** ask Companion to re-check the feedbacks after each poll rebuilds the device list, and after each action changes a cached device trait.

```ts
			this.updateVariableDefinitions()
			this.checkFeedbacks('device_online', 'thermostat_mode', 'hvac_active')
			this.updateStatus(InstanceStatus.Ok)
```

### H4: After the credentials are entered on a new connection, the Device dropdowns in every action and feedback stay empty

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:33-60`](https://github.com/bitfocus/companion-module-google-nest/blob/7a489db3d35759bf44dee976db468a11f115aedb/src/main.ts#L33-L60), [`src/feedbacks.ts:27-37`](https://github.com/bitfocus/companion-module-google-nest/blob/7a489db3d35759bf44dee976db468a11f115aedb/src/feedbacks.ts#L27-L37), [`src/actionsThermostat.ts:9-22`](https://github.com/bitfocus/companion-module-google-nest/blob/7a489db3d35759bf44dee976db468a11f115aedb/src/actionsThermostat.ts#L9-L22)

**What goes wrong:** A user adds the Google Nest connection. It starts with blank Client ID, Client Secret, Project ID and Refresh Token, so the first poll fails and the module builds its actions and feedbacks with no devices. The user then fills in valid credentials and clicks Save. The poll now succeeds and the device variables appear, but the 'Device' dropdown in 'Set mode', 'Set Temperature', 'Fan Timer', 'Device: Online' and every other action and feedback is still empty, so no device can be chosen. The dropdowns only fill in after the connection is disabled and re-enabled. This is the normal first-setup path for every new user.

**Why it happens:** The Device dropdown choices are a copy of the device list taken when the action and feedback definitions are built. The module builds those definitions only once, at the end of `init()`. Neither saving the settings (`configUpdated()`) nor a later successful poll rebuilds them, so they keep the empty list from startup.

**Evidence:**

```ts
// src/main.ts:33-46
	async init(config: ModuleConfig): Promise<void> {
		this.config = config
		//this.log('info', 'Config: ' + JSON.stringify(this.config))
		this.client = new SdmClient(config)

		this.updateStatus(InstanceStatus.Ok)

		await this.getGoogleNestDevices()
		this.startPolling(config.pollIntervalSec ?? 30) // get devices immediately on startup
		this.updateActions() // export actions
		this.updateFeedbacks() // export feedbacks
		this.updatePresets() // export Presets
		this.updateVariableDefinitions() // export variable definitions
	}
```

```ts
// src/main.ts:53-60
	async configUpdated(config: ModuleConfig): Promise<void> {
		this.config = config
		this.log('info', 'Config updated')
		this.client = new SdmClient(config)

		await this.getGoogleNestDevices()
		this.startPolling(config.pollIntervalSec ?? 30)
	}
```

```ts
// src/feedbacks.ts:27-37 (choices copied when the definitions are built)
export function UpdateFeedbacks(self: ModuleInstance): void {
	const deviceChoices = Array.from(self.devices.values()).map((d) => ({
		id: d.name.split('/').pop()!,
		label: getDisplayName(d),
	}))
	const deviceThermostatChoices = Array.from(self.devices.values())
		.filter((d) => d.type === 'sdm.devices.types.THERMOSTAT')
```

```text
// grep -rn "updateActions\|updateFeedbacks\|setActionDefinitions\|setFeedbackDefinitions" src
src/main.ts:42:		this.updateActions() // export actions
src/main.ts:43:		this.updateFeedbacks() // export feedbacks
src/feedbacks.ts:39:	self.setFeedbackDefinitions({
src/actions.ts:17:	self.setActionDefinitions({
```

**Confirm by:** open [`src/main.ts:53-60`](https://github.com/bitfocus/companion-module-google-nest/blob/7a489db3d35759bf44dee976db468a11f115aedb/src/main.ts#L53-L60) and [`src/main.ts:99-128`](https://github.com/bitfocus/companion-module-google-nest/blob/7a489db3d35759bf44dee976db468a11f115aedb/src/main.ts#L99-L128): `configUpdated()` and the poll's success path only refresh the variables. `updateActions()` / `updateFeedbacks()` run only at [`src/main.ts:42-43`](https://github.com/bitfocus/companion-module-google-nest/blob/7a489db3d35759bf44dee976db468a11f115aedb/src/main.ts#L42-L43).

**Fix:** rebuild the actions, feedbacks and presets whenever the device list changes. The simplest way is to call them from `configUpdated()` after the first poll; better, call them inside `getGoogleNestDevices()` whenever the set of device IDs or names changes, so a later successful poll also fills the dropdowns.

```ts
		await this.getGoogleNestDevices()
		this.updateActions()
		this.updateFeedbacks()
		this.updatePresets()
```

### H5: Set Temperature ignores its Mode option and changes whichever setpoint the thermostat is currently using

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/actionsThermostat.ts:150-208`](https://github.com/bitfocus/companion-module-google-nest/blob/7a489db3d35759bf44dee976db468a11f115aedb/src/actionsThermostat.ts#L150-L208)

**What goes wrong:** A user adds the 'Set Temperature' action with Mode = Heat and Temperature = 18 °C. If the thermostat is currently in Cool mode, the module sends a cool setpoint of 18 °C instead, which is a large cooling change rather than a heat target. If the thermostat is in Heat/Cool or Off, nothing is sent and nothing is logged. The Mode dropdown in the action has no effect at all.

**Why it happens:** The action decides which setpoint to change from the thermostat's current mode (as last polled), and never reads the Mode the user picked in the action.

**Evidence:**

```ts
// src/actionsThermostat.ts:150-159
				{
					type: 'dropdown' as const,
					id: 'mode',
					label: 'Mode',
					default: 'COOL',
					choices: [
						{ id: 'COOL', label: 'Cool' },
						{ id: 'HEAT', label: 'Heat' },
					],
				},
```

```ts
// src/actionsThermostat.ts:170-187
			callback: async (
				event: CompanionActionEvent<{ deviceId: string; mode: 'HEAT' | 'COOL'; temperature: number }>,
			) => {
				const device = self.devices.get(event.options.deviceId)
				const mode = device?.traits['sdm.devices.traits.ThermostatMode']?.mode
				const setpoint = device?.traits['sdm.devices.traits.ThermostatTemperatureSetpoint']

				if (!device || !mode || !setpoint || !self.client) return

				switch (mode) {
					case 'COOL':
						await self.client.executeCommand(
							device.name,
							'sdm.devices.commands.ThermostatTemperatureSetpoint.SetCool',
							{
								coolCelsius: event.options.temperature,
							},
						)
```

```text
// grep -rn "options.mode" src/ (no hit inside set_temperature)
src/feedbacks.ts:92:				return device?.traits[TRAIT.THERMOSTAT_MODE]?.mode === options.mode
src/actionsThermostat.ts:305:					mode: event.options.mode,
src/actionsThermostat.ts:338:					mode: event.options.mode,
```

**Confirm by:** open [`src/actionsThermostat.ts:140-210`](https://github.com/bitfocus/companion-module-google-nest/blob/7a489db3d35759bf44dee976db468a11f115aedb/src/actionsThermostat.ts#L140-L210). The action declares a 'Mode' dropdown at lines 150-159, but the callback switches on the device's cached mode at line 179 and never reads `event.options.mode`. The switch has no default branch, so Heat/Cool and Off do nothing silently.

**Fix:** switch on the Mode the user picked. If it doesn't match the thermostat's current mode, log a warning instead of silently changing the other setpoint. If the intent really is "use the thermostat's current mode", remove the Mode option so the action doesn't offer a choice it ignores.

```ts
				switch (event.options.mode) {
					case 'COOL':
						if (mode !== 'COOL') {
							self.log('warn', `${getDisplayName(device)} is in ${mode} mode; cannot set a cool setpoint`)
							return
						}
```

## 🟡 Medium

### M1: A thermostat that is Off when the module starts is missing from every action's Device dropdown

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actionsThermostat.ts:9-22`](https://github.com/bitfocus/companion-module-google-nest/blob/7a489db3d35759bf44dee976db468a11f115aedb/src/actionsThermostat.ts#L9-L22)

**What goes wrong:** A user's Nest thermostat is switched Off (or in Eco) when Companion starts. The thermostat doesn't appear in the Device dropdown of any action, including 'Set mode' and 'Fan Timer', which are exactly what the user would use to switch it back to Heat or Cool. The user can't build a button to turn it on.

**Why it happens:** All seven thermostat actions share one device list, and that list only keeps thermostats that are in Heat, Cool or Heat/Cool with a matching setpoint. 'Set mode', 'Set ECO mode' and 'Fan Timer' don't need a setpoint, but use the same filtered list.

**Fix:** give 'Set mode', 'Set ECO mode' and 'Fan Timer' a plain list of every thermostat (`d.type === 'sdm.devices.types.THERMOSTAT'`). Keep the setpoint filter only for the temperature actions, or drop it and check the mode in the callback.

### M2: Thermostat actions silently do nothing when the thermostat's mode does not match

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actionsThermostat.ts:57-86`](https://github.com/bitfocus/companion-module-google-nest/blob/7a489db3d35759bf44dee976db468a11f115aedb/src/actionsThermostat.ts#L57-L86), [`src/actionsThermostat.ts:120-137`](https://github.com/bitfocus/companion-module-google-nest/blob/7a489db3d35759bf44dee976db468a11f115aedb/src/actionsThermostat.ts#L120-L137), [`src/actionsThermostat.ts:253-273`](https://github.com/bitfocus/companion-module-google-nest/blob/7a489db3d35759bf44dee976db468a11f115aedb/src/actionsThermostat.ts#L253-L273)

**What goes wrong:** Pressing an 'Adjust Temperature' button while the thermostat is in Heat/Cool or Off, or a 'Set Temperature (Heat/Cool)' / 'Adjust Temperature (Heat/Cool)' button while it is in Heat or Cool, does nothing. There is no log line, no error and no status change, so the operator can't tell why the button "doesn't work". The same happens when the chosen device isn't in the module's cached list.

**Why it happens:** The mode `switch` statements have no default branch, and the early `return` guards don't log anything.

**Fix:** add a default branch that logs a warning, for example "Thermostat Living Room is in HEAT mode; use 'Adjust Temperature' instead", and log when the device or the client is missing.

### M3: Variables do not show a setpoint change made by an action until the next poll

- **Source:** 🔎 protocol reviewer + QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actionsThermostat.ts:188-206`](https://github.com/bitfocus/companion-module-google-nest/blob/7a489db3d35759bf44dee976db468a11f115aedb/src/actionsThermostat.ts#L188-L206), [`src/actionsThermostat.ts:263-267`](https://github.com/bitfocus/companion-module-google-nest/blob/7a489db3d35759bf44dee976db468a11f115aedb/src/actionsThermostat.ts#L263-L267)

**What goes wrong:** A user presses 'Adjust Temperature' (Increase) on a thermostat set to 21 °C. The command is sent and the module's cached setpoint becomes 21.5, but a button showing the setpoint variable (for example `$(google-nest:home_living_room_thermostattemperaturesetpoint_heatcelsius)`) keeps showing 21 for up to one poll interval (30 s by default, up to 300 s). An operator pressing quickly can't see where the setpoint is.

**Why it happens:** The action callbacks (also at lines 66-69, 81-84 and 131-135) update the cached device state in place but don't push the new values to the variables or re-check the feedbacks.

**Fix:** after a successful command, refresh the variable values (for example with `self.updateVariableDefinitions()` or a lighter values-only update) and call `self.checkFeedbacks()`.

### M4: Client Secret and OAuth Refresh Token are stored as plain-text config, not as secrets

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/config.ts:31-36`](https://github.com/bitfocus/companion-module-google-nest/blob/7a489db3d35759bf44dee976db468a11f115aedb/src/config.ts#L31-L36), [`src/config.ts:53-60`](https://github.com/bitfocus/companion-module-google-nest/blob/7a489db3d35759bf44dee976db468a11f115aedb/src/config.ts#L53-L60), [`src/main.ts:13`](https://github.com/bitfocus/companion-module-google-nest/blob/7a489db3d35759bf44dee976db468a11f115aedb/src/main.ts#L13)

**What goes wrong:** The Google OAuth Client Secret and Refresh Token are shown in clear text in the connection settings and are included in normal config exports and support bundles. Anyone with access to Companion's web UI or an exported `.companionconfig` file can take control of the user's Nest devices.

**Why it happens:** Both are ordinary `textinput` config fields, and the module declares `secrets: undefined`. API 2.0 (base 2.0.4) supports `secret-text` fields, which Companion keeps in a separate secrets store and passes to `init()` / `configUpdated()` as their own argument.

**Fix:** move `clientSecret` and `refreshToken` into a `ModuleSecrets` type, set `secrets: ModuleSecrets` in the module schema, declare both fields as `type: 'secret-text'`, and read them from the `secrets` argument of `init(config, isFirstInit, secrets)` / `configUpdated(config, secrets)`. This is a first release, so no upgrade script is needed.

## 🟢 Low

### L1: The minimum poll interval of 12 seconds exceeds the 5-requests-per-minute limit stated in the module's own tooltip

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/config.ts:61-71`](https://github.com/bitfocus/companion-module-google-nest/blob/7a489db3d35759bf44dee976db468a11f115aedb/src/config.ts#L61-L71)

**What goes wrong:** A user sets 'Poll Interval (seconds)' to the minimum the field allows, 12. Each poll makes 2 Google requests (devices and structures), so that is 10 requests a minute, twice the 5-a-minute sandbox limit the tooltip warns about. Polls may fail and the connection status flips to an error.

**Why it happens:** Every poll fetches both the device list and the structure list, but the minimum of 12 s looks like it was chosen for one request per poll.

**Fix:** raise the minimum to 24 s, or fetch the structures only once (they rarely change). Alternatively, correct the tooltip so it says each poll uses 2 requests.

### L2: A failed thermostat command is not logged by the module and does not change the connection status

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actionsThermostat.ts:59-65`](https://github.com/bitfocus/companion-module-google-nest/blob/7a489db3d35759bf44dee976db468a11f115aedb/src/actionsThermostat.ts#L59-L65), [`src/actionsThermostat.ts:304-306`](https://github.com/bitfocus/companion-module-google-nest/blob/7a489db3d35759bf44dee976db468a11f115aedb/src/actionsThermostat.ts#L304-L306), [`src/actionsThermostat.ts:337-339`](https://github.com/bitfocus/companion-module-google-nest/blob/7a489db3d35759bf44dee976db468a11f115aedb/src/actionsThermostat.ts#L337-L339), [`src/actionsThermostat.ts:379-382`](https://github.com/bitfocus/companion-module-google-nest/blob/7a489db3d35759bf44dee976db468a11f115aedb/src/actionsThermostat.ts#L379-L382)

**What goes wrong:** If Google rejects a command (for example a 'Set Temperature' outside the allowed range, or an expired token), the button press does nothing visible. The module writes no error line of its own naming the device, and the connection status stays OK.

**Why it happens:** The action callbacks send the command without a `try`/`catch`, so the error goes to Companion's generic action error handling instead of being logged with the device's name.

**Fix:** wrap the command call in a `try`/`catch` (or a shared helper) and log the failure, for example:

```ts
self.log('error', `Set mode on ${getDisplayName(device)} failed: ${err.message}`)
```

### L3: Every token expiry triggers two token refresh requests at once

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/sdm-client.ts:46-51`](https://github.com/bitfocus/companion-module-google-nest/blob/7a489db3d35759bf44dee976db468a11f115aedb/src/sdm-client.ts#L46-L51)

**What goes wrong:** No visible effect in normal use. At startup and roughly every hour, the poll asks for devices and structures at the same time, both see an expired token, and both ask Google for a new one, doubling the token requests.

**Why it happens:** The token refresh isn't shared between requests that run at the same time.

**Fix:** keep the pending refresh and let both requests wait for it, for example `this.refreshing ??= this.refreshAccessToken().finally(() => (this.refreshing = undefined))`, then `await this.refreshing` in `getToken()`.

### L4: Two config fields share the id info

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/config.ts:13-16`](https://github.com/bitfocus/companion-module-google-nest/blob/7a489db3d35759bf44dee976db468a11f115aedb/src/config.ts#L13-L16), [`src/config.ts:45-52`](https://github.com/bitfocus/companion-module-google-nest/blob/7a489db3d35759bf44dee976db468a11f115aedb/src/config.ts#L45-L52)

**What goes wrong:** The connection settings page has two information text blocks, both with the id `info`. Users see nothing obvious, but duplicate field ids can confuse how the config UI tracks its fields.

**Why it happens:** The second information block was copied from the first without changing its id.

**Fix:** give the second block a unique id, for example `refreshTokenInfo`.

### L5: Variable IDs change when a device or home is renamed, and can collide

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/helpers.ts:15-24`](https://github.com/bitfocus/companion-module-google-nest/blob/7a489db3d35759bf44dee976db468a11f115aedb/src/helpers.ts#L15-L24)

**What goes wrong:** Variable names are built from the home name and the device's display name (for example `my_home_living_room_temperature_ambienttemperaturecelsius`). Renaming the thermostat in the Google Home app changes every variable name, so buttons using `$(google-nest:...)` go blank. Two thermostats with the same name in the same home, or names that differ only in non-English characters, get the same variable name and overwrite each other.

**Why it happens:** The variable id is made from the friendly names instead of the device's stable Google id.

**Fix:** use the stable device id from `device.name` (or a short form of it) in variable ids, and keep the friendly name in the variable's label and the `_name` variable.

### L6: Template placeholder preset My first Preset button ships in the Presets tab

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/presets.ts:6-35`](https://github.com/bitfocus/companion-module-google-nest/blob/7a489db3d35759bf44dee976db468a11f115aedb/src/presets.ts#L6-L35)

**What goes wrong:** In the Presets tab, users see "Section One" → "Group One" ("A starting point for preset definitions!") with one preset, "My first Preset button", which has no actions and no feedbacks and does nothing for a Nest thermostat.

**Why it happens:** `presets.ts` is still the template example.

**Fix:** remove the placeholder, or replace it with real thermostat presets (for example setpoint up/down buttons with the 'Thermostat: Mode active' feedback and the setpoint variable in the text). Presets are optional for a first release.

## 💡 Nice to Have

### N1: Fixed-choice dropdowns allow expression mode they do not need

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actionsThermostat.ts:35-44`](https://github.com/bitfocus/companion-module-google-nest/blob/7a489db3d35759bf44dee976db468a11f115aedb/src/actionsThermostat.ts#L35-L44), [`src/actionsThermostat.ts:286-296`](https://github.com/bitfocus/companion-module-google-nest/blob/7a489db3d35759bf44dee976db468a11f115aedb/src/actionsThermostat.ts#L286-L296), [`src/actionsThermostat.ts:353-362`](https://github.com/bitfocus/companion-module-google-nest/blob/7a489db3d35759bf44dee976db468a11f115aedb/src/actionsThermostat.ts#L353-L362)

**What goes wrong:** No visible problem by default. Users can switch the Direction, Mode and Fan Mode dropdowns to expression mode, where a value like `heat` (lower case) fails validation and the action is skipped without a clear reason.

**Why it happens:** These dropdowns don't set `disableAutoExpression`.

**Fix:** add `disableAutoExpression: true` to these dropdowns, or add an `expressionDescription` that lists the valid ids (HEAT, COOL, HEATCOOL, OFF, MANUAL_ECO, ON).

## 📝 Additional Notes

- First release: the module has never been published, so there is no previous tag to diff against. The whole module was reviewed, and every finding is classified 🆕 NEW.
- Build and lint passed (`yarn install --immutable`, `yarn package`, `yarn lint`).
