# Review: epiphan-pearl v3.0.0

| Field | Value |
| --- | --- |
| **Module** | `companion-module-epiphan-pearl` |
| **Scope** | `tag` |
| **Version** | v3.0.0 |
| **Release** | Update — last published v2.2.1 |
| **API** | 2.2 (base 2.2.2, yarn.lock) — requires Companion 5.1+ |
| **Template** | `companion-module-template-js` @ `89da037` (2026-11-01) |
| **Compared** | `v2.2.1..v3.0.0` (60 commits, 56 files, +16308/−2726; a full rewrite from base 1.x to 2.2) |
| **Review commit** | [`5e4d53b`](https://github.com/bitfocus/companion-module-epiphan-pearl/tree/5e4d53bf1c48a6382a1745ca99c939949e620e7b) |
| **Date** | 2026-11-06 |

## Verdict: ❌ Changes Required

## ❓ Assumptions

Some findings depend on assumptions the reviewers couldn't check. They're listed in [❓ Assumptions to Confirm](#-assumptions-to-confirm) at the end of this review.

## 📋 Issues

### Blocking

- [ ] [C1: `.gitattributes` is missing](#c1-gitattributes-is-missing)
- [ ] [C2: `.gitignore` lacks the template's entries](#c2-gitignore-lacks-the-templates-entries)
- [ ] [C3: `.prettierignore` is missing](#c3-prettierignore-is-missing)
- [ ] [C4: `.yarnrc.yml` is missing](#c4-yarnrcyml-is-missing)
- [ ] [C5: Source file at the module root (`index.js`)](#c5-source-file-at-the-module-root-indexjs)
- [ ] [C6: `packageManager` is Yarn 1](#c6-packagemanager-is-yarn-1)
- [ ] [C7: The `package` script is missing](#c7-the-package-script-is-missing)
- [ ] [C8: The build fails](#c8-the-build-fails)
- [ ] [H1: Polling keeps running after the connection is disabled or saved with an invalid host](#h1-polling-keeps-running-after-the-connection-is-disabled-or-saved-with-an-invalid-host)
- [ ] [H2: The Audio meter feedback draws no level meter](#h2-the-audio-meter-feedback-draws-no-level-meter)

### Non-blocking

- [ ] [M1: The `release.yaml` workflow is missing](#m1-the-releaseyaml-workflow-is-missing)
- [ ] [M2: Very old buttons upgraded to 3.0.0 lose their Layout, Stream and Recorder feedback colours](#m2-very-old-buttons-upgraded-to-300-lose-their-layout-stream-and-recorder-feedback-colours)
- [ ] [M3: The connection stays OK while the encoder answers every request with an HTTP error](#m3-the-connection-stays-ok-while-the-encoder-answers-every-request-with-an-http-error)
- [ ] [M4: Upgraded recorder and stream buttons that did nothing now start or stop recording and streaming](#m4-upgraded-recorder-and-stream-buttons-that-did-nothing-now-start-or-stop-recording-and-streaming)
- [ ] [L1: Audio meter buttons replace Bad configuration with Connection failure](#l1-audio-meter-buttons-replace-bad-configuration-with-connection-failure)
- [ ] [L2: New CMS events never appear in the Event dropdown, and its status labels go stale](#l2-new-cms-events-never-appear-in-the-event-dropdown-and-its-status-labels-go-stale)
- [ ] [L3: Upgraded All Streams buttons light when any stream is live, and Toggle stops all](#l3-upgraded-all-streams-buttons-light-when-any-stream-is-live-and-toggle-stops-all)
- [ ] [L4: One failed request makes layouts, inputs or outputs vanish for one poll](#l4-one-failed-request-makes-layouts-inputs-or-outputs-vanish-for-one-poll)
- [ ] [L5: A slow preview image or audio-level request flips the connection to Connection failure](#l5-a-slow-preview-image-or-audio-level-request-flips-the-connection-to-connection-failure)
- [ ] [L6: Audio gain nudge on an unpaired input sets channel B to channel A's gain](#l6-audio-gain-nudge-on-an-unpaired-input-sets-channel-b-to-channel-as-gain)
- [ ] [L7: Upgraded development-build Single touch OK feedbacks lose their inversion](#l7-upgraded-development-build-single-touch-ok-feedbacks-lose-their-inversion)
- [ ] [L8: A host typed with a port passes validation and ends in Connection failure](#l8-a-host-typed-with-a-port-passes-validation-and-ends-in-connection-failure)
- [ ] [L9: The encoder password is a plain text field, not a secret](#l9-the-encoder-password-is-a-plain-text-field-not-a-secret)
- [ ] [L10: Aborting a button's actions does not cancel the request to the encoder](#l10-aborting-a-buttons-actions-does-not-cancel-the-request-to-the-encoder)
- [ ] [N1: README and CHANGELOG describe a Storage eject action that no longer exists](#n1-readme-and-changelog-describe-a-storage-eject-action-that-no-longer-exists)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🔴 Critical

### C1: `.gitattributes` is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.gitattributes` (does not exist)

**What goes wrong:** Without the template's line-ending rule, files can be checked out or committed with Windows (CRLF) line endings, which then show up as whole-file changes in diffs.

**Why it happens:** The template tracks a `.gitattributes` file and the module has none. It was also missing at v2.2.1.

**Expected vs found:** "Required file is missing (tracked by the template)". The template has `* text=auto eol=lf`; the module has no `.gitattributes`.

**Fix:** add `.gitattributes` with the template's content.

```text
* text=auto eol=lf
```

### C2: `.gitignore` lacks the template's entries

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.gitignore`](https://github.com/bitfocus/companion-module-epiphan-pearl/blob/5e4d53bf1c48a6382a1745ca99c939949e620e7b/.gitignore)

**What goes wrong:** An npm lockfile, Yarn's `.yarn` folder or a `DEBUG-*` log can be committed by accident.

**Why it happens:** The module's `.gitignore` has unanchored `pkg`, `pkg.tgz` and `*.tgz` instead of the template's entries. This release edited the file (+8 lines) without adding them.

**Expected vs found:** "Missing template .gitignore entries: package-lock.json, /pkg, /*.tgz, DEBUG-*, /.yarn". The template's `.gitignore` is `node_modules/`, `package-lock.json`, `/pkg`, `/*.tgz`, `DEBUG-*`, `/.yarn`. The module's extra entries (`doc/`, `tools/`, `.claude/`, `doc/source/`) are allowed and can stay.

**Fix:** add the missing template entries, keeping the module's own extras.

```text
node_modules/
package-lock.json
/pkg
/*.tgz
DEBUG-*
/.yarn
```

### C3: `.prettierignore` is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.prettierignore` (does not exist)

**What goes wrong:** `yarn format` (`prettier -w .`) also rewrites files the template keeps out of Prettier, such as `package.json`.

**Why it happens:** The template tracks a `.prettierignore` file and the module has none. It was also missing at v2.2.1.

**Expected vs found:** "Required file is missing (tracked by the template)". The template has `package.json` and `/LICENSE.md`; the module has no `.prettierignore`.

**Fix:** add `.prettierignore` with the template's content.

```text
package.json
/LICENSE.md
```

### C4: `.yarnrc.yml` is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.yarnrc.yml` (does not exist); this release added [`.yarnrc`](https://github.com/bitfocus/companion-module-epiphan-pearl/blob/5e4d53bf1c48a6382a1745ca99c939949e620e7b/.yarnrc) instead

**What goes wrong:** Installs run without the template's Yarn settings, which block dependency install scripts and freshly published packages.

**Why it happens:** This release added a Yarn 1 `.yarnrc` (`ignore-engines true`) instead of the template's Yarn 4 `.yarnrc.yml` (see [C6](#c6-packagemanager-is-yarn-1)).

**Expected vs found:** "Required file is missing (tracked by the template)". The template has `enableScripts: false`, `nodeLinker: node-modules`, `npmMinimalAgeGate: 3d` and `npmPreapprovedPackages: ["@companion-module/*"]`.

**Fix:** add the template's `.yarnrc.yml` and delete the Yarn 1 `.yarnrc` once the module is on Yarn 4.

```yaml
enableScripts: false
nodeLinker: node-modules
npmMinimalAgeGate: 3d
npmPreapprovedPackages:
  - '@companion-module/*'
```

### C5: Source file at the module root (`index.js`)

- **Source:** 🤖 validate-template (SRC-AT-ROOT)
- **Classification:** 🆕 NEW
- **File:** [`index.js`](https://github.com/bitfocus/companion-module-epiphan-pearl/blob/5e4d53bf1c48a6382a1745ca99c939949e620e7b/index.js), [`package.json:5`](https://github.com/bitfocus/companion-module-epiphan-pearl/blob/5e4d53bf1c48a6382a1745ca99c939949e620e7b/package.json#L5), [`companion/manifest.json:35`](https://github.com/bitfocus/companion-module-epiphan-pearl/blob/5e4d53bf1c48a6382a1745ca99c939949e620e7b/companion/manifest.json#L35)

**What goes wrong:** The module's entry point lives outside `src/`, so its layout differs from every other module built from the template.

**Why it happens:** This release moved the code into `src/` but kept a root `index.js` shim, which `package.json` `main: "index.js"` and the manifest's `runtime.entrypoint: "../index.js"` point to.

**Expected vs found:** "Source file at module root — all source must be under src/".

**Fix:** move the entry under `src/` (the template uses `src/main.js`; any name is fine) and point `main` and `entrypoint` at the same file.

### C6: `packageManager` is Yarn 1

- **Source:** 🤖 validate-template (PKG-YARN)
- **Classification:** 🆕 NEW
- **File:** [`package.json:29`](https://github.com/bitfocus/companion-module-epiphan-pearl/blob/5e4d53bf1c48a6382a1745ca99c939949e620e7b/package.json#L29)

**What goes wrong:** The module is built with Yarn 1 instead of the Yarn 4 the template uses.

**Why it happens:** This release introduced the `packageManager` field with Yarn 1. Commit `7504e2c` ("fix(ci): let yarn 1 install @companion-module/tools 3.x on Node 26") chose Yarn 1 on purpose.

**Expected vs found:** "packageManager 'yarn@1.22.22' should start with 'yarn@4'". The template has `"packageManager": "yarn@4.18.1"` plus `"engines": { "yarn": "^4" }`.

**Fix:** switch to Yarn 4 (for example `corepack use yarn@4.18.1`), add `"yarn": "^4"` to `engines`, add the template's `.yarnrc.yml` ([C4](#c4-yarnrcyml-is-missing)) and regenerate `yarn.lock`. Yarn 4 does not refuse a dependency over its `engines` range the way Yarn 1 does, so the `ignore-engines` workaround should no longer be needed (confirm with `yarn install` on Node 26).

### C7: The `package` script is missing

- **Source:** 🤖 validate-template (PKG-SCRIPT)
- **Classification:** 🆕 NEW
- **File:** [`package.json:6-10`](https://github.com/bitfocus/companion-module-epiphan-pearl/blob/5e4d53bf1c48a6382a1745ca99c939949e620e7b/package.json#L6-L10)

**What goes wrong:** `yarn package` cannot run, so the module cannot be packaged the way the template expects.

**Why it happens:** `package.json` defines only `format`, `lint` and `test`. It was also missing at v2.2.1.

**Expected vs found:** "Missing required script 'package'". The template has `"package": "companion-module-build"`.

**Fix:** add the template's script.

```json
"package": "companion-module-build"
```

### C8: The build fails

- **Source:** 🤖 validate-template (BUILD-PACKAGE)
- **Classification:** 🆕 NEW
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-epiphan-pearl/blob/5e4d53bf1c48a6382a1745ca99c939949e620e7b/package.json)

**What goes wrong:** The validator's build step fails, so no module package is produced. `yarn install --immutable` passed.

**Why it happens:** This follows from [C7](#c7-the-package-script-is-missing): with no `package` script, `yarn package` cannot run.

**Expected vs found:** "yarn package (build) failed".

**Fix:** the same change as C7. Confirm that `yarn package` passes once the script is added.

## 🟠 High

### H1: Polling keeps running after the connection is disabled or saved with an invalid host

- **Source:** 🔎 protocol reviewer + QA reviewer — verified
- **Classification:** 🔙 REGRESSION
- **File:** [`src/instance.js:457-467`](https://github.com/bitfocus/companion-module-epiphan-pearl/blob/5e4d53bf1c48a6382a1745ca99c939949e620e7b/src/instance.js#L457-L467)

**What goes wrong:** A v2.0 poll sends 20 or more requests to the encoder, so a poll is often still running when the user saves the connection settings or disables the connection. If the user saves an invalid Target IP (for example `not a host!`) while a poll is running, the connection first shows "Bad configuration". Within a few seconds it switches to "Connection failure – ERR_INVALID_URL", and the module keeps polling the bad address until a valid config is saved. Disabling the connection during a poll does the same: the status goes to Disconnected, then the encoder keeps receiving poll requests and the status goes back to OK. Companion stops the module's process after `destroy()`, so in practice the disable case lasts only until then, but the Bad configuration case stays in a live connection. Saving a **valid** config during a poll is not affected (the next start clears the stray timer). In v2.2.1, both paths always stopped polling.

**Why it happens:** The main poll schedules its next run itself: when one poll finishes, its `.finally()` sets a new timer. `destroy()` and `configUpdated()` cancel only the timer that is waiting, not a poll that is already running, and nothing checks afterwards whether the connection was destroyed or re-configured. So the running poll finishes, sets a fresh timer, and the loop starts again. The audio level poll (`startMeterTimer()`) already guards against this with the config generation counter; the main poll does not. The restarted loop also creates a new HTTP agent (an undici `Agent`) that nothing closes.

**Evidence:**

```js
// src/instance.js:457-467
	initInterval() {
		if (this.timer) clearTimeout(this.timer)
		const runOnce = () => {
			this.pollAll()
				.catch(() => {})
				.finally(() => {
					this.timer = setTimeout(runOnce, this.nextPollDelayMs())
				})
		}
		this.timer = setTimeout(runOnce, this.nextPollDelayMs())
	}
```

```js
// src/instance.js:229-245  (configUpdated: the Bad configuration path returns without restarting, relying on stopTimers)
	async configUpdated(config) {
		this.stopTimers()
		// a poll that is still running belongs to the old configuration; the generation guard in
		// pollAllInner makes it discard its result, so there is no need to wait for it here
		this.configGeneration++
		...
		const problem = validateConfig(this.config)
		if (problem) {
			this.log('error', problem)
			this.applyStatus(InstanceStatus.BadConfig, problem)
			// definitions must exist even while the config is unusable
			this.updateSystem()
			return
		}
```

```js
// src/instance.js:330-336
	stopTimers() {
		...
		if (this.timer) clearTimeout(this.timer)
		...
		this.timer = undefined
```

```js
// src/poller.js:146-147  (the only early-out in the poll; no generation/destroyed check before requests)
	async pollAllInner() {
		if (!this.config || !this.config.host) return
```

```js
// src/api.js:114-117  (the restarted loop re-creates the Agent that destroy() closed)
	ensureDispatcher() {
		if (!this.dispatcher) this.dispatcher = createDispatcher(this.config)
		return this.dispatcher
	},
```

```js
// v2.2.1 index.js:92-93, 391 (git show v2.2.1:index.js)
	async destroy() {
		clearInterval(this.timer)
	...
		this.timer = setInterval(this.dataPoller.bind(this), Math.ceil(this.config.pollfreq * 1000) || 10000)
```

```text
Reproduced with the module's own test/harness.js and test/mock-pearl.js on localhost, poll_interval 500:
- destroy() while a poll was running: status right after destroy was 'disconnected'; the mock then
  received 150 requests in 3 s, this.timer was armed again, this.dispatcher was re-created, and the last
  status was 'ok' ('API v2.0').
- configUpdated({host:'not a host!'}) while a poll was running: status went to 'bad_config', then
  flipped to 'connection_failure' / 'ERR_INVALID_URL', and this.timer stayed armed.
- Control: 5 valid-config saves during running polls left the poll rate unchanged (5 polls per 3 s).
```

**Confirm by:** open [`src/instance.js:462-464`](https://github.com/bitfocus/companion-module-epiphan-pearl/blob/5e4d53bf1c48a6382a1745ca99c939949e620e7b/src/instance.js#L462-L464): the `.finally()` re-arms `this.timer` with no `configGeneration` or destroyed check. The Bad configuration return in `configUpdated()` ([`src/instance.js:239-244`](https://github.com/bitfocus/companion-module-epiphan-pearl/blob/5e4d53bf1c48a6382a1745ca99c939949e620e7b/src/instance.js#L239-L244)) and `destroy()` ([`src/instance.js:311-325`](https://github.com/bitfocus/companion-module-epiphan-pearl/blob/5e4d53bf1c48a6382a1745ca99c939949e620e7b/src/instance.js#L311-L325)) never call `initInterval()` again to clear that new timer.

**Fix:** remember the config generation when the poll loop starts, and stop scheduling the next poll once it has changed, the way `startMeterTimer()` does. `configUpdated()` and `destroy()` already bump `configGeneration`, so this covers both paths.

```js
initInterval() {
	if (this.timer) clearTimeout(this.timer)
	const generation = this.configGeneration
	const runOnce = () => {
		this.timer = undefined
		if (generation !== this.configGeneration) return
		this.pollAll()
			.catch(() => {})
			.finally(() => {
				if (generation !== this.configGeneration || this.timer) return
				this.timer = setTimeout(runOnce, this.nextPollDelayMs())
			})
	}
	this.timer = setTimeout(runOnce, this.nextPollDelayMs())
}
```

Add a test that calls `destroy()` while `instance.pollPromise` is set and checks that `instance.timer` stays undefined after the poll settles.

### H2: The Audio meter feedback draws no level meter

- **Source:** 🔎 compliance reviewer — ⚠️ needs your check
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.js:783-789`](https://github.com/bitfocus/companion-module-epiphan-pearl/blob/5e4d53bf1c48a6382a1745ca99c939949e620e7b/src/feedbacks.js#L783-L789), [`src/meter.js:156-170`](https://github.com/bitfocus/companion-module-epiphan-pearl/blob/5e4d53bf1c48a6382a1745ca99c939949e620e7b/src/meter.js#L156-L170)

**What goes wrong:** A user drags the Audio meter feedback onto a button and picks an input, for example XLR A. The module polls the levels every 500 ms, but the image it gives Companion is a raw byte array, while API 2.x expects the pixels as a base64 text string. So the stereo bars are most likely not drawn (or Companion logs a bad feedback value), and the button shows only its own text. The module's tests can't catch this: they check the raw byte count (72 × 72 × 4), which is right either way.

**Why it happens:** An advanced feedback returns its picture in `imageBuffer`. Base 1.x accepted a `Uint8Array` or a string there and carried it over EJSON; base 2.2.2 declares it as a string only, "Base64 encoded pixel buffer". `renderMeter()` returns a `Uint8Array`, and the feedback passes it to `imageBuffer` unchanged. Sent as plain JSON, a `Uint8Array` becomes an object of index keys (`{"0":255,"1":0,…}`), not pixels. The meter code was not adapted during the base 2.2.2 migration (commit `a7ecbb8`).

**Evidence:**

```js
// src/feedbacks.js:775-789
			affectedProperties: ['imageBuffer'],
			callback: (feedback) => {
				try {
					trackFeedback(this, feedback, 'meter', String(feedback.options.inputId ?? ''))
					const levels = meterOf(this.state.inputs?.[String(feedback.options.inputId ?? '')])
					// no levels yet (nothing subscribed, no signal, or a device without the endpoint):
					// return nothing at all so the button keeps its text and its own style
					if (!levels) return {}
					const width = Math.round(Number(feedback.image?.width) || METER_DEFAULT_SIZE)
					const height = Math.round(Number(feedback.image?.height) || METER_DEFAULT_SIZE)
					return {
						imageBuffer: renderMeter(width, height, levels),
						imageBufferEncoding: { pixelFormat: 'RGBA' },
						imageBufferPosition: { x: 0, y: 0, width, height },
					}
```

```js
// src/meter.js:156-170
 * @returns {Uint8Array} width * height * 4 bytes, RGBA
 */
function renderMeter(width, height, levels = {}) {
	const layout = meterLayout(width, height)
	const buffer = new Uint8Array(layout.width * layout.height * 4)
	...
	for (const bar of bars) paintBar(buffer, layout, bar)
	return buffer
}
```

```ts
// node_modules/@companion-module/base/dist/module-api/feedback.d.ts:79-85  (base 2.2.2)
/** The resulting style of an advanced feedback */
export interface CompanionAdvancedFeedbackResult extends CompanionFeedbackButtonStyleResult {
    /** Base64 encoded pixel buffer */
    imageBuffer?: string;
    imageBufferEncoding?: CompanionImageBufferEncoding;
    imageBufferPosition?: CompanionImageBufferPosition;
}
```

```text
// grep -rn "base64|imageBuffer|Buffer.from" src index.js  (the only conversion is in api.js, none for the meter)
src/feedbacks.js:786:						imageBuffer: renderMeter(width, height, levels),
src/api.js:417:				return buffer.toString('base64')

// node -e: JSON.stringify({imageBuffer:new Uint8Array([255,0,10,255])})
{"imageBuffer":{"0":255,"1":0,"2":10,"3":255}}
```

```js
// test/meter.test.js:271
		assert.equal(result.imageBuffer.length, 72 * 72 * 4)
```

**Confirm by:** in Companion 5.1, add the Audio meter feedback to a button on a connected encoder with audio, and see whether the bars draw or the log shows a pixel-buffer error. The code half is certain ([`src/feedbacks.js:786`](https://github.com/bitfocus/companion-module-epiphan-pearl/blob/5e4d53bf1c48a6382a1745ca99c939949e620e7b/src/feedbacks.js#L786) passes the raw array); what is unverified is whether Companion's module host converts it ([A1](#-assumptions-to-confirm)).

**Fix:** encode the pixels as base64 before returning them, or have `renderMeter()` return the base64 string.

```js
imageBuffer: Buffer.from(renderMeter(width, height, levels)).toString('base64'),
```

Update [`test/meter.test.js:271`](https://github.com/bitfocus/companion-module-epiphan-pearl/blob/5e4d53bf1c48a6382a1745ca99c939949e620e7b/test/meter.test.js#L271) to decode before checking the length: `Buffer.from(result.imageBuffer, 'base64').length === 72 * 72 * 4`.

## 🟡 Medium

### M1: The `release.yaml` workflow is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.github/workflows/release.yaml` (does not exist)

**What goes wrong:** The module lacks the template's release workflow.

**Why it happens:** "Required file is missing (tracked by the template)". The module has `.github/workflows/companion-module-checks.yaml`, which matches the template, and an extra `.github/dependabot.yml`, which is fine.

**Fix:** copy `.github/workflows/release.yaml` from the template.

### M2: Very old buttons upgraded to 3.0.0 lose their Layout, Stream and Recorder feedback colours

- **Source:** 🔎 compliance reviewer — verified
- **Classification:** 🔙 REGRESSION
- **File:** [`src/instance.js:488-503`](https://github.com/bitfocus/companion-module-epiphan-pearl/blob/5e4d53bf1c48a6382a1745ca99c939949e620e7b/src/instance.js#L488-L503)

**What goes wrong:** This affects buttons saved with module 1.x, the Companion 2.x era (for example an imported old export). Back then, the Channel layout, Streaming state and Recorder state feedbacks stored their colours as options (for example fg = white, bg = red). On 3.0.0, the first upgrade script moves those into the feedback's style still wrapped, as `{ isExpression: false, value: 16777215 }` instead of `16777215`. The feedback becomes Layout active (or Stream state / Recorder state), but its colour is not a colour, so when the layout is active the button does not turn the red and white the user chose. Anyone who used module 2.x on Companion 3 or 4 already ran this script with plain values and is not affected.

**Why it happens:** Companion 5 hands every API 2.x upgrade script its options wrapped as `{ isExpression, value }`. Upgrade script 0 is base's `CreateConvertToBooleanFeedbackUpgradeScript` helper, and in base 2.2.2 that helper copies the wrapped option into `feedback.style` without taking `.value`. The module's own `acceptWrappedOptions()` wrapper unwraps options for `convertToParityV300` but not for script 0. On v2.2.1 (base 1.x) the helper received plain values and worked.

**Evidence:**

```js
// src/instance.js:488-503
const upgradeToBooleanFeedbacks = CreateConvertToBooleanFeedbackUpgradeScript({
	channelLayout: {
		fg: 'color',
		bg: 'bgcolor',
	},
	...
})

const upgradeScripts = [upgradeToBooleanFeedbacks, ...upgrades]
```

```js
// node_modules/@companion-module/base/dist/module-api/upgrade.js:36-41  (base 2.2.2)
for (const [option_key, style_key] of Object.entries(upgrade_rules)) {
    const rawVal = feedback.options[option_key];
    if (rawVal !== undefined) {
        feedback.style[style_key] = rawVal;
        delete feedback.options[option_key];
```

```text
// node simulation of the full exported upgradeScripts chain on a wrapped channelLayout feedback:
"feedbackId": "layout_active",
"options": { "layoutId": { "isExpression": false, "value": "1-2" } },
"style": {
  "color":   { "isExpression": false, "value": 16777215 },
  "bgcolor": { "isExpression": false, "value": 16711680 }
}
```

**Fix:** keep a script at index 0, but replace the helper with a small custom script in `src/upgrades.js`. For each listed feedback and colour option, read the wrapped option; if `!raw.isExpression`, set `feedback.style[styleKey] = raw.value`. Delete the option either way, and push the feedback once. Replacing it in place is safe: connections that already ran script 0 ran it correctly under base 1.x and never run it again. Add a test that feeds wrapped fg/bg values through `upgradeScripts[0]` using the real base helper, not the harness stub. Reference: companion-v1-to-v2-expression-upgrades, `references/scripts.md`.

### M3: The connection stays OK while the encoder answers every request with an HTTP error

- **Source:** 🔎 QA reviewer + protocol reviewer
- **Classification:** 🔙 REGRESSION
- **File:** [`src/poller.js:176-188`](https://github.com/bitfocus/companion-module-epiphan-pearl/blob/5e4d53bf1c48a6382a1745ca99c939949e620e7b/src/poller.js#L176-L188), [`src/api.js:237-258`](https://github.com/bitfocus/companion-module-epiphan-pearl/blob/5e4d53bf1c48a6382a1745ca99c939949e620e7b/src/api.js#L237-L258)

**What goes wrong:** Suppose the encoder's web server stays reachable but its API answers every request with an HTTP error, such as the HTML "500 Internal Server Error" page the module's own comment describes. The connection status stays "OK – API v2.0" indefinitely. Every poll fails, so the recorder, stream and layout feedbacks freeze at their last state and actions fail, and the log shows a single "No valid answer from device: HTTP 500 …" line. Reproduced: after 4 s of HTTP 500 on every request, the status was still `ok` / `API v2.0`. Users who watch the connection status, or a trigger on it, never learn that the encoder stopped answering properly. In v2.2.1, any non-OK response set "Connection failure".

**Why it happens:** `request()` now sets a status only for network errors and timeouts (Connection failure), a 401 (Authentication failure) and success (OK). That is a sensible choice, so that one rejected action (for example a 409) does not mark the whole connection as failed. But when the core poll requests (`/channels`, `/recorders`) fail with an HTTP error, `pollAllInner()` only logs once and counts the failure; it never sets a status, so the previous OK stays.

**Fix:** in the core-failure branch of `pollAllInner()`, set a failure status unless the status is already Authentication failure, for example `this.applyStatus(InstanceStatus.ConnectionFailure, reason || 'No valid answer from device')` (or UnknownError for an HTTP 5xx). The next successful poll already restores OK through `applyOkStatus()`.

### M4: Upgraded recorder and stream buttons that did nothing now start or stop recording and streaming

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🔙 REGRESSION
- **File:** [`src/upgrades.js:136-138`](https://github.com/bitfocus/companion-module-epiphan-pearl/blob/5e4d53bf1c48a6382a1745ca99c939949e620e7b/src/upgrades.js#L136-L138)

**What goes wrong:** In 2.2.x, the Control recording and Control streaming actions had an Action choice `---` (value 99) that did nothing; v2.2.1 returned early for it. Take a button with Control recording set to `---`, kept for its feedback or as a placeholder. After upgrading to 3.0.0 it becomes Recorder → Start / Stop, so pressing it now stops a running recording or starts a new one. A `---` stream button likewise becomes Stream → Toggle and can take a live stream off air. The upgrade notes promise recorder buttons keep their Start, Stop, Reset or Toggle command, but `---` is silently turned into a toggle.

**Why it happens:** The upgrade's command maps translate 99 to `toggle` instead of to something that does nothing, and the new actions have no do-nothing command.

**Fix:** don't map 99 to toggle. Either leave such actions unconverted and call `recordRemovedLegacy('action', action.actionId, action.controlId)` so `init()` names them in the log, or add a do-nothing command such as `{ id: 'none', label: '---' }` to the Recorder and Stream actions and map 99 to it.

## 🟢 Low

### L1: Audio meter buttons replace Bad configuration with Connection failure

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/meter.js:235-250`](https://github.com/bitfocus/companion-module-epiphan-pearl/blob/5e4d53bf1c48a6382a1745ca99c939949e620e7b/src/meter.js#L235-L250), [`src/feedbacks.js:146-156`](https://github.com/bitfocus/companion-module-epiphan-pearl/blob/5e4d53bf1c48a6382a1745ca99c939949e620e7b/src/feedbacks.js#L146-L156)

**What goes wrong:** Take a connection whose Target IP is empty or invalid (status "Bad configuration") with buttons that use the Audio meter feedback. When Companion starts the module, or the user places or changes such a feedback, the module starts its 500 ms level poll anyway. Reproduced with the harness: with host `''` the status was `bad_config` after init, and one Audio meter evaluation turned it into `connection_failure` / `ERR_INVALID_URL` within 1.5 s, with the meter timer still running. The user sees a connection error instead of the hint to fix the settings, and the module retries an invalid URL twice a second. Preview feedbacks (with Preview interval above 0) trigger a one-off request the same way.

**Why it happens:** `configUpdated()` returns early on a bad config without connecting, but the first evaluation of every audio feedback starts the level poll (`subscribeMeter()` → `startMeterTimer()`), whatever the config state. `startMeterTimer()` checks only for subscriptions and the config generation, not whether the config is usable.

**Fix:** remember whether the current config is usable (for example `this.configValid = !problem` in `configUpdated()`), and return early from `startMeterTimer()` and `pollPreviews()` while it is false. `connect()` already restarts the meter and previews once a valid config is saved.

### L2: New CMS events never appear in the Event dropdown, and its status labels go stale

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/poller.js:73-89`](https://github.com/bitfocus/companion-module-epiphan-pearl/blob/5e4d53bf1c48a6382a1745ca99c939949e620e7b/src/poller.js#L73-L89), [`src/choices.js:217-229`](https://github.com/bitfocus/companion-module-epiphan-pearl/blob/5e4d53bf1c48a6382a1745ca99c939949e620e7b/src/choices.js#L217-L229)

**What goes wrong:** The Event option of the Event action and of the Event state / Event command applies feedbacks lists the polled events as "title (status)", as HELP.md says. If an operator schedules a new event in the Pearl CMS after Companion connected, it never appears in the dropdown, and an entry such as "Lecture (scheduled)" keeps that label after the event ran. This lasts until something unrelated forces a rebuild (a channel or layout change, a settings save, or a restart), so the operator has to type the event id by hand.

**Why it happens:** The action and feedback definitions are rebuilt only when `structureKey()` changes. It covers channels, recorders, inputs, outputs, storages, single touch and presets, but not the event list that the Event dropdown is built from.

**Fix:** add the event ids and titles to `structureKey()`, e.g. `events: (s.events?.list || []).map((e) => [e?.id, e?.title])`. Leave the status out if a rebuild on every status change is unwanted; the label would then show only the title.

### L3: Upgraded All Streams buttons light when any stream is live, and Toggle stops all

- **Source:** 🔎 QA reviewer
- **Classification:** 🔙 REGRESSION
- **File:** [`src/feedbacks.js:373-376`](https://github.com/bitfocus/companion-module-epiphan-pearl/blob/5e4d53bf1c48a6382a1745ca99c939949e620e7b/src/feedbacks.js#L373-L376), [`src/utils.js:307-312`](https://github.com/bitfocus/companion-module-epiphan-pearl/blob/5e4d53bf1c48a6382a1745ca99c939949e620e7b/src/utils.js#L307-L312), [`src/upgrades.js:350-354`](https://github.com/bitfocus/companion-module-epiphan-pearl/blob/5e4d53bf1c48a6382a1745ca99c939949e620e7b/src/upgrades.js#L350-L354)

**What goes wrong:** Take a channel with two publishers, YouTube and Facebook, where YouTube is live and Facebook failed to start. In 2.2.1, an "All Streams" Streaming state feedback was off (it needed every publisher started), and its Toggle action started the missing stream. After the upgrade, the converted Stream state "All publishers / Started" feedback lights green because one started publisher is enough, and pressing the converted Toggle sends Stop to every publisher, taking YouTube off air. The upgrade notes don't mention this change of meaning for existing buttons.

**Why it happens:** In 2.2.1 the "all" case checked that every publisher was started. In 3.0.0 the aggregate state is "started" if any publisher is started, and the toggle sends stop if any publisher is active. The upgrade ([`src/upgrades.js:210-221`](https://github.com/bitfocus/companion-module-epiphan-pearl/blob/5e4d53bf1c48a6382a1745ca99c939949e620e7b/src/upgrades.js#L210-L221)) converts the ids but keeps no record of the old meaning.

**Fix:** if the change is intended (for Stream Deck parity), say so in the CHANGELOG upgrade notes for "All Streams" buttons. Otherwise, convert legacy "All Streams" buttons to a check that every publisher is started (for example a new `all_started` state), and make the converted toggle keep the old rule: start unless every publisher is started.

### L4: One failed request makes layouts, inputs or outputs vanish for one poll

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/poller.js:214-219`](https://github.com/bitfocus/companion-module-epiphan-pearl/blob/5e4d53bf1c48a6382a1745ca99c939949e620e7b/src/poller.js#L214-L219), [`src/poller.js:282-294`](https://github.com/bitfocus/companion-module-epiphan-pearl/blob/5e4d53bf1c48a6382a1745ca99c939949e620e7b/src/poller.js#L282-L294), [`src/poller.js:413-416`](https://github.com/bitfocus/companion-module-epiphan-pearl/blob/5e4d53bf1c48a6382a1745ca99c939949e620e7b/src/poller.js#L413-L416)

**What goes wrong:** If one sub-request of a poll fails (for example `GET /channels/1/layouts` or `GET /outputs`) while the core channel and recorder requests succeed, that poll stores an empty list. The Layout active feedback goes dark, every action and feedback definition is rebuilt, the log says "Device configuration has changed, choices and presets updated.", and that domain's variables are removed; on the next poll they all come back, with a second rebuild. A failed `GET /outputs` also permanently loses the `output_<id>_source` value and the "Output source recently set" state set by the Output Source action.

**Why it happens:** The second-round requests are collected with `Promise.allSettled`, and a rejected request leaves its part of the new state at the empty default. Unlike firmware, identity and presets, which fall back to the previous poll, these parts never reuse the previous data.

**Fix:** when a second-round request fails, carry that part over from the previous state (`prev.channels[cid].layouts`, `prev.outputs`, `prev.inputs`, `prev.storages`), so the structure key and the optimistic fields survive one failed request.

### L5: A slow preview image or audio-level request flips the connection to Connection failure

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/api.js:203-217`](https://github.com/bitfocus/companion-module-epiphan-pearl/blob/5e4d53bf1c48a6382a1745ca99c939949e620e7b/src/api.js#L203-L217)

**What goes wrong:** With preview buttons (Preview / Layout preview feedbacks) or an Audio meter feedback placed, a single timed-out preview or `/sources/status` request sets the connection status to "Connection failure – Request timed out", and the next successful request sets it back to OK. The module's own comment says preview requests do time out on a busy encoder, so the status can flash red repeatedly while recording, streaming and control all work, and a trigger on the connection status fires falsely.

**Why it happens:** `request()` sets Connection failure on every network error or timeout, whatever its `optional` / `silent` flags. The preview and level requests pass `optional: true, silent: true`, but those flags only affect 404/405 handling and logging.

**Fix:** add an option such as `noStatus: true` (or treat `optional` as "never touch the status") and skip the status change for those requests in `request()`. Pass it from `fetchPreviewImage()` and `pollMeterLevelsInner()`, and leave the connection status to the core poll.

### L6: Audio gain nudge on an unpaired input sets channel B to channel A's gain

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/audio.js:40-59`](https://github.com/bitfocus/companion-module-epiphan-pearl/blob/5e4d53bf1c48a6382a1745ca99c939949e620e7b/src/audio.js#L40-L59)

**What goes wrong:** Take an analog input whose channels are set individually (stereo pair off), with channel A at 20 and channel B at 40. Pressing an Audio → Gain → Up 1 button sets both channels to 21: channel B drops by 19 instead of rising by 1, an audible level jump on a live input.

**Why it happens:** The current gain of an unpaired input is read from channel A (or B when A is missing), and the new value, current + step, is written to both channels.

**Fix:** for an unpaired input, nudge each channel from its own current value, e.g. `{ local_audio: { channels: { channelA: { gain: clamp(a + delta) }, channelB: { gain: clamp(b + delta) } } } }`, or let the action pick a channel.

### L7: Upgraded development-build Single touch OK feedbacks lose their inversion

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/upgrades.js:380-385`](https://github.com/bitfocus/companion-module-epiphan-pearl/blob/5e4d53bf1c48a6382a1745ca99c939949e620e7b/src/upgrades.js#L380-L385)

**What goes wrong:** This affects only buttons made with the unreleased 2.3–2.6 development builds that use the Single touch OK feedback ("true while the single touch control is OK"). After the upgrade it becomes Single touch state → Error without the inversion, so the button lights when the control is in error instead of when it is OK. Released 2.2.x buttons are not affected.

**Why it happens:** The script flips the inversion with `feedback.isInverted = !feedback.isInverted`, which assumes a plain boolean. In base 2.x, `isInverted` is typed as a wrapped value (`{ isExpression, value }`), and `acceptWrappedOptions()` unwraps only the options, so `!{…}` is always `false`.

**Fix:** unwrap before negating, e.g. `const inv = isWrappedOption(feedback.isInverted) ? feedback.isInverted.value : feedback.isInverted; feedback.isInverted = { isExpression: false, value: !inv }`, and keep the plain-boolean path for 1.x-shaped data.

### L8: A host typed with a port passes validation and ends in Connection failure

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/instance.js:31-32`](https://github.com/bitfocus/companion-module-epiphan-pearl/blob/5e4d53bf1c48a6382a1745ca99c939949e620e7b/src/instance.js#L31-L32), [`src/api.js:171-172`](https://github.com/bitfocus/companion-module-epiphan-pearl/blob/5e4d53bf1c48a6382a1745ca99c939949e620e7b/src/api.js#L171-L172)

**What goes wrong:** A user types the address with a port into the host field, e.g. `192.168.1.10:8080`. Instead of the clear Bad configuration message "Invalid IP address or hostname given in configuration", the connection shows "Connection failure – ERR_INVALID_URL" and never connects.

**Why it happens:** The IPv6 part of the host check accepts any string of digits and dots with a single colon. The request code then wraps the value in brackets as an IPv6 address, giving `http://[192.168.1.10:8080]:80/…`.

**Fix:** require at least two colons for the IPv6 form, or validate with `net.isIP(host)` plus the hostname pattern. Optionally detect `host:port` and give a specific Bad configuration hint to put the port in the Port field.

### L9: The encoder password is a plain text field, not a secret

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/config.js:68-74`](https://github.com/bitfocus/companion-module-epiphan-pearl/blob/5e4d53bf1c48a6382a1745ca99c939949e620e7b/src/config.js#L68-L74)

**What goes wrong:** In the connection settings, the encoder's admin password is typed into, and shown in, a normal text field, and it is stored in the connection config with the other settings, so it travels with config data. API 2.x, adopted in this release, offers a `secret-text` field that is stored separately in the connection's secrets. The field was already plain text in v2.2.1, but secrets only became available with this migration.

**Why it happens:** The Password field is still `type: 'textinput'`.

**Fix:** change the field to `type: 'secret-text'`, read it from the `secrets` argument of `init(config, isFirstInit, secrets)` / `configUpdated(config, secrets)`, and add an upgrade script that moves `config.password` into `updatedSecrets.password` and deletes it from the config. Reference: companion-v2-config, companion-v2-upgrades.

### L10: Aborting a button's actions does not cancel the request to the encoder

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/api.js:190`](https://github.com/bitfocus/companion-module-epiphan-pearl/blob/5e4d53bf1c48a6382a1745ca99c939949e620e7b/src/api.js#L190), [`src/actions.js:150-152`](https://github.com/bitfocus/companion-module-epiphan-pearl/blob/5e4d53bf1c48a6382a1745ca99c939949e620e7b/src/actions.js#L150-L152)

**What goes wrong:** If Companion aborts a button's running actions (an abort action, or the connection being disabled), a request already on its way, such as the Event action (a GET then a POST) or Get layout data, keeps running until its own timeout ends. That can be up to 60 s with a high "Request timeout (ms)", so a command can still reach the encoder after the user aborted it.

**Why it happens:** `request()` builds its abort signal only from the timeout. API 2.1+ passes an abort signal to every action callback in `context.signal`; the action wrapper receives `context` but never passes the signal on.

**Fix:** let `request()` accept an optional `signal` and combine it with the timeout via `AbortSignal.any([AbortSignal.timeout(timeout), signal])`, and pass `context.signal` from the action callbacks through the `wrap()` helper. Reference: companion-v2-actions (abort signals, 2.1+).

## 💡 Nice to Have

### N1: README and CHANGELOG describe a Storage eject action that no longer exists

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`README.md:10`](https://github.com/bitfocus/companion-module-epiphan-pearl/blob/5e4d53bf1c48a6382a1745ca99c939949e620e7b/README.md#L10), [`CHANGELOG.md:35`](https://github.com/bitfocus/companion-module-epiphan-pearl/blob/5e4d53bf1c48a6382a1745ca99c939949e620e7b/CHANGELOG.md#L35), [`CHANGELOG.md:60`](https://github.com/bitfocus/companion-module-epiphan-pearl/blob/5e4d53bf1c48a6382a1745ca99c939949e620e7b/CHANGELOG.md#L60)

**What goes wrong:** The README says the module can "eject storage", and the CHANGELOG lists "Storage eject" among the actions that need a second press, but this release removed the Storage eject action (HELP.md says ejecting is done on the device). The CHANGELOG also says a removed action still on a button "is reported once per start in the connection log", but it is reported only on the first start after the upgrade.

**Why it happens:** The docs were not updated when the action was dropped. The removed-action report is filled only while the 3.0.0 upgrade script runs, which happens once per connection.

**Fix:** remove "eject storage" from the README and "Storage eject" from the CHANGELOG's confirm bullet, and reword the CHANGELOG line to "reported once, on the first start after the upgrade" (or rescan the stored actions on every start if a per-start warning is wanted).

## 📝 Additional Notes

- API compliance was re-checked on 2026-11-06 against the API 2.2 rules (companion-v2-api-compliance 1.2.0): API 2.2 requires Companion 5.1+; the 2.2 rules were checked, with no findings. There are no deprecated or unknown `Regex` keys (3.0.0 replaces v2.2.1's `Regex.IP` with a Host text field with no regex and a `number` Port field, converted by the `portAsNumberV300` upgrade script), no value feedbacks, no preset using `storeResult` or a `hasResult` action, no UDP or shared socket, and every dynamic variable id passes through `safeId()` behind a fixed prefix, so Companion 5.1+ drops none. [L8](#l8-a-host-typed-with-a-port-passes-validation-and-ends-in-connection-failure) is about the module's own host check, not a deprecated `Regex`, and is unchanged.
- There is no API 2.2 template. The template-file findings ([C1](#c1-gitattributes-is-missing)–[C8](#c8-the-build-fails), [M1](#m1-the-releaseyaml-workflow-is-missing)) compare against `companion-module-template-js` main @ `89da037` (API 2.1, `node26` runtime).

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Companion 5.1's module host does not turn a raw `Uint8Array` `imageBuffer` into base64. It expects the base64 string that base 2.2.2 declares, so a raw array does not draw (or arrives over JSON IPC as an object of index keys) | base 2.2.2 types `imageBuffer?: string` ("Base64 encoded pixel buffer"); base 1.15.1 accepted a `Uint8Array` or a string over EJSON IPC. The host code ships inside Companion and was not read | [H2](#h2-the-audio-meter-feedback-draws-no-level-meter) |
| A2 | A current Companion can still import or upgrade saved buttons from module 1.x (the Companion 2.x era) that never ran upgrade script 0, and it draws a style colour stored as `{ isExpression, value }` wrongly instead of as the colour | script 0 was added in module 2.0.0 (commit `f5e4d69`, 2023); base types `color`/`bgcolor` as plain colour values. The host's import path and renderer were not checked | [M2](#m2-very-old-buttons-upgraded-to-300-lose-their-layout-stream-and-recorder-feedback-colours) |
| A3 | The encoder's web server can answer the core API requests with HTTP 5xx or an HTML error page while the device is still reachable on the network | the module's own comment at [`src/api.js:247`](https://github.com/bitfocus/companion-module-epiphan-pearl/blob/5e4d53bf1c48a6382a1745ca99c939949e620e7b/src/api.js#L247); not confirmed on a device | [M3](#m3-the-connection-stays-ok-while-the-encoder-answers-every-request-with-an-http-error) |
| A4 | Companion evaluates every placed feedback, including Audio meter, after `init()` even while the connection is in Bad configuration | usual host behaviour after `setFeedbackDefinitions()`; the reproduction called the feedback callback through the module's test harness | [L1](#l1-audio-meter-buttons-replace-bad-configuration-with-connection-failure) |
| A5 | Preview and `/sources/status` requests time out often enough on real encoders for the status flapping to be visible | the module's own comment at [`src/poller.js:8-11`](https://github.com/bitfocus/companion-module-epiphan-pearl/blob/5e4d53bf1c48a6382a1745ca99c939949e620e7b/src/poller.js#L8-L11) says simultaneous preview requests "tend to overwhelm" the device | [L5](#l5-a-slow-preview-image-or-audio-level-request-flips-the-connection-to-connection-failure) |
| A6 | Companion 5 passes `isInverted` to upgrade scripts wrapped as `{ isExpression, value }`, and reads a bare boolean written back as "not inverted" | base 2.2.2 `upgrade.d.ts:110` types `isInverted?: ExpressionOrValue<boolean>`; the known wrapping rule covers options, and the host's handling of `isInverted` was not checked | [L7](#l7-upgraded-development-build-single-touch-ok-feedbacks-lose-their-inversion) |
| A7 | `secret-text` values are kept in the connection's separate secrets store and are not shown in plain text on the settings page | base 2.2.2 `input.d.ts` ("the value for this will be in the secrets store, not the config store"); export and UI behaviour is Companion-side | [L9](#l9-the-encoder-password-is-a-plain-text-field-not-a-secret) |
