# Review: companion-module-feelworld-l3-series v1.1.0

| Field | Value |
| --- | --- |
| **Module** | [companion-module-feelworld-l3-series](https://github.com/bitfocus/companion-module-feelworld-l3-series) |
| **Scope** | `tag` |
| **Version** | v1.1.0 |
| **Release** | New module — never published |
| **API** | 2.1 (base 2.1.3, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Review commit** | [`8ea2538`](https://github.com/bitfocus/companion-module-feelworld-l3-series/tree/8ea2538d5685bc9e3e0b0744da95582ab68b5885) |
| **Reviewed** | 2026-10-30 |

This is the module's first release, so there is no previous tag to diff against: the whole module was reviewed, and every finding is classified 🆕 NEW.

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | The switcher answers at least one of the read queries the module sends right after connecting (for example the PGM source query `0x20 0x0d`), so "first reply received" can stand in for "device reachable" | The module's own `handleFixedFrame()` handles replies to these queries; not verified on hardware | [M5](#m5-connection-shows-ok-even-when-the-switchers-ip-is-wrong-or-the-switcher-is-off) |
| A2 | The device reports Program/Preview channels 0-based (HDMI 1 = 0 … Media = 4), as the module's comments state ("实测确认" = confirmed by testing) | Comments at `src/feedbacks.ts:15` and `src/main.ts:504-505`, plus the preset mapping at `src/presets.ts:353-354`; not verified on hardware | [M6](#m6-the-pgmpvw-match-alert-never-lights-when-program-and-preview-are-both-on-input-1), [M7](#m7-program-and-preview-source-variables-show-0-for-input-1), [L4](#l4-source-dropdown-values-are-0-4-for-input-1-media-which-is-confusing-in-expression-mode) |

## 📋 Issues

### Blocking

- [ ] [C1: Missing .gitattributes file](#c1-missing-gitattributes-file)
- [ ] [C2: .gitignore is missing template entries](#c2-gitignore-is-missing-template-entries)
- [ ] [C3: Missing .husky/pre-commit hook](#c3-missing-huskypre-commit-hook)
- [ ] [C4: .prettierignore differs from the template](#c4-prettierignore-differs-from-the-template)
- [ ] [C5: .yarnrc.yml is missing template keys](#c5-yarnrcyml-is-missing-template-keys)
- [ ] [C6: .vscode/settings.json is committed](#c6-vscodesettingsjson-is-committed)
- [ ] [C7: package.json repository URL lacks the git+ prefix](#c7-packagejson-repository-url-lacks-the-git-prefix)
- [ ] [C8: package.json is missing the postinstall script](#c8-packagejson-is-missing-the-postinstall-script)
- [ ] [C9: package.json is missing the husky devDependency](#c9-packagejson-is-missing-the-husky-devdependency)
- [ ] [C10: package.json is missing the lint-staged devDependency](#c10-packagejson-is-missing-the-lint-staged-devdependency)
- [ ] [C11: package.json is missing the lint-staged section](#c11-packagejson-is-missing-the-lint-staged-section)
- [ ] [H1: release.yaml differs from the template](#h1-releaseyaml-differs-from-the-template)

### Non-blocking

- [ ] [M1: Missing bug report issue template](#m1-missing-bug-report-issue-template)
- [ ] [M2: Missing issue template config](#m2-missing-issue-template-config)
- [ ] [M3: Missing feature request issue template](#m3-missing-feature-request-issue-template)
- [ ] [M4: Missing node.yaml workflow](#m4-missing-nodeyaml-workflow)
- [ ] [M5: Connection shows OK even when the switcher's IP is wrong or the switcher is off](#m5-connection-shows-ok-even-when-the-switchers-ip-is-wrong-or-the-switcher-is-off)
- [ ] [M6: The PGM/PVW Match Alert never lights when Program and Preview are both on Input 1](#m6-the-pgmpvw-match-alert-never-lights-when-program-and-preview-are-both-on-input-1)
- [ ] [M7: Program and Preview source variables show 0 for Input 1](#m7-program-and-preview-source-variables-show-0-for-input-1)
- [ ] [M8: Action and feedback schemas are untyped, so option ids and values are not type-checked](#m8-action-and-feedback-schemas-are-untyped-so-option-ids-and-values-are-not-type-checked)
- [ ] [L1: Startup state-sync timers keep firing after the connection's settings are saved or it is disabled](#l1-startup-state-sync-timers-keep-firing-after-the-connections-settings-are-saved-or-it-is-disabled)
- [ ] [L2: PGM Source Indicator default highlight is almost black](#l2-pgm-source-indicator-default-highlight-is-almost-black)
- [ ] [L3: Numbered copies of actions instead of one action with an option](#l3-numbered-copies-of-actions-instead-of-one-action-with-an-option)
- [ ] [L4: Source dropdown values are 0-4 for Input 1-Media, which is confusing in expression mode](#l4-source-dropdown-values-are-0-4-for-input-1-media-which-is-confusing-in-expression-mode)
- [ ] [L5: Long-running toggle actions ignore Abort actions](#l5-long-running-toggle-actions-ignore-abort-actions)
- [ ] [N1: Duplicate send code and untyped JSON handling](#n1-duplicate-send-code-and-untyped-json-handling)
- [ ] [N2: Tracked device state is not exposed as variables](#n2-tracked-device-state-is-not-exposed-as-variables)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🔴 Critical

### C1: Missing .gitattributes file

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.gitattributes` (missing)

**What goes wrong:** The template ships a `.gitattributes` that forces LF line endings. Without it, a contributor on Windows can commit CRLF files, which produces noisy diffs and Prettier failures.

**Why it happens:** The file tracked by the template is not in the module repo.

**Expected (template):**

```text
* text=auto eol=lf
```

**Fix:** copy `.gitattributes` from `companion-module-template-ts`.

### C2: .gitignore is missing template entries

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.gitignore:1-12`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/.gitignore#L1-L12)

**What goes wrong:** Files the template keeps out of git (`package-lock.json`, `DEBUG-*` logs, `.vscode`) can be committed by accident. One already has been: see [C6](#c6-vscodesettingsjson-is-committed).

**Why it happens:** The module's `.gitignore` uses its own patterns (`dist/`, `pkg/`, `*.tgz`, `.yarn/*` with negations, plus `protocol_new.md` and `testWork/`) instead of the template's list.

**Missing template entries:** `package-lock.json`, `/pkg`, `/*.tgz`, `/dist`, `DEBUG-*`, `/.yarn`, `/.vscode`.

**Fix:** copy the template's `.gitignore`. Extra local entries such as `protocol_new.md` and `testWork/` can be added below it.

### C3: Missing .husky/pre-commit hook

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.husky/pre-commit` (missing)

**What goes wrong:** Commits are not checked by lint-staged, so unformatted or lint-failing code can be committed.

**Why it happens:** The template's pre-commit hook (`lint-staged`) is not in the repo. It goes together with [C8](#c8-packagejson-is-missing-the-postinstall-script)-[C11](#c11-packagejson-is-missing-the-lint-staged-section).

**Fix:** copy `.husky/pre-commit` from the template.

### C4: .prettierignore differs from the template

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.prettierignore:1-2`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/.prettierignore#L1-L2)

**What goes wrong:** `yarn format` reformats `package.json` and `LICENSE.md`, which the template deliberately leaves alone.

**Why it happens:** The template entries were replaced rather than extended.

**Found vs expected:**

```text
found:     package-lock.json, yarn.lock
template:  package.json, /LICENSE.md
```

**Fix:** use the template's `.prettierignore`. Keeping `yarn.lock` as an extra line is fine.

### C5: .yarnrc.yml is missing template keys

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.yarnrc.yml:1`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/.yarnrc.yml#L1)

**What goes wrong:** The supply-chain protections the template sets for every module are off: dependency install scripts run, and freshly published (possibly malicious) package versions are installed at once.

**Why it happens:** The module's file only has `nodeLinker: node-modules`.

**Expected (template):**

```yaml
enableScripts: false

nodeLinker: node-modules

npmMinimalAgeGate: 3d

npmPreapprovedPackages:
  - "@companion-module/*"
```

**Fix:** copy the template's `.yarnrc.yml`.

### C6: .vscode/settings.json is committed

- **Source:** 🤖 validate-template (GITIGNORED-COMMITTED)
- **Classification:** 🆕 NEW
- **File:** [`.vscode/settings.json:1-8`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/.vscode/settings.json#L1-L8)

**What goes wrong:** Personal editor settings are shipped to every contributor.

**Why it happens:** The template's `.gitignore` excludes `/.vscode`, but the module's `.gitignore` does not (see [C2](#c2-gitignore-is-missing-template-entries)), so the file was committed.

**Fix:** remove it from the repo (`git rm --cached .vscode/settings.json`) and add `/.vscode` to `.gitignore`.

### C7: package.json repository URL lacks the git+ prefix

- **Source:** 🤖 validate-template (PKG-REPO)
- **Classification:** 🆕 NEW
- **File:** [`package.json:27`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/package.json#L27)

**Found vs expected:**

```text
found:    https://github.com/bitfocus/companion-module-feelworld-l3-series.git
expected: git+https://github.com/bitfocus/companion-module-feelworld-l3-series.git
```

**Fix:** add the `git+` prefix to `repository.url`.

### C8: package.json is missing the postinstall script

- **Source:** 🤖 validate-template (PKG-SCRIPT)
- **Classification:** 🆕 NEW
- **File:** [`package.json:7-15`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/package.json#L7-L15)

**What goes wrong:** `yarn install` never installs the git hooks, so the pre-commit check from [C3](#c3-missing-huskypre-commit-hook) would not run even once the hook file exists.

**Expected (template):**

```json
"postinstall": "husky"
```

**Fix:** add the script to `scripts`.

### C9: package.json is missing the husky devDependency

- **Source:** 🤖 validate-template (PKG-DEVDEP)
- **Classification:** 🆕 NEW
- **File:** [`package.json:38-46`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/package.json#L38-L46)

**Expected (template):** `"husky": "^9.1.7"` in `devDependencies`.

**Fix:** `yarn add -D husky`.

### C10: package.json is missing the lint-staged devDependency

- **Source:** 🤖 validate-template (PKG-DEVDEP)
- **Classification:** 🆕 NEW
- **File:** [`package.json:38-46`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/package.json#L38-L46)

**Expected (template):** `"lint-staged": "^17.6.0"` in `devDependencies`.

**Fix:** `yarn add -D lint-staged`.

### C11: package.json is missing the lint-staged section

- **Source:** 🤖 validate-template (PKG-LINTSTAGED)
- **Classification:** 🆕 NEW
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/package.json)

**Expected (template):**

```json
"lint-staged": {
	"*.{css,json,md,scss}": ["prettier --write"],
	"*.{ts,tsx,js,jsx}": ["yarn lint:raw --fix"]
}
```

**Fix:** copy the `lint-staged` section from the template's `package.json`.

## 🟠 High

### H1: release.yaml differs from the template

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.github/workflows/release.yaml:47`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/.github/workflows/release.yaml#L47)

**What goes wrong:** The package attached to a GitHub release is named with the `v` prefix (for example `feelworld-l3-series-v1.1.0.tgz`), where the template's workflow names it `feelworld-l3-series-1.1.0.tgz`.

**Why it happens:** The asset-name line drops the template's `#v` strip.

**Found vs expected:**

```text
found:    NAME="${GITHUB_REPOSITORY#*/companion-module-}-${TAG}"
template: NAME="${GITHUB_REPOSITORY#*/companion-module-}-${TAG#v}"
```

**Fix:** copy the template's `.github/workflows/release.yaml`.

## 🟡 Medium

### M1: Missing bug report issue template

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.github/ISSUE_TEMPLATE/bug_report.yml` (missing)

**Fix:** copy the file from the template.

### M2: Missing issue template config

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.github/ISSUE_TEMPLATE/config.yml` (missing)

**Fix:** copy the file from the template.

### M3: Missing feature request issue template

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.github/ISSUE_TEMPLATE/feature_request.yml` (missing)

**Fix:** copy the file from the template.

### M4: Missing node.yaml workflow

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.github/workflows/node.yaml` (missing)

**What goes wrong:** Pushes and pull requests are not linted or built by CI.

**Fix:** copy `.github/workflows/node.yaml` from the template.

### M5: Connection shows OK even when the switcher's IP is wrong or the switcher is off

- **Source:** 🔎 protocol reviewer + QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:125-130`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L125-L130)

**What goes wrong:** A user enters a wrong Device IP Address (for example 192.168.1.150 when the L3 is at 192.168.1.100), or the switcher is powered off. The connection still turns green (OK) in the Connections list. Buttons send commands into the void and feedbacks (Program/Preview source, PIP, mute and so on) never update, with nothing in the UI saying the device is unreachable.

**Why it happens:** The status is set to OK when the local UDP socket starts listening. That only means Companion opened a local port, which always succeeds; it says nothing about the switcher. The status is never tied to a reply from the device, even though the module sends read queries right after connecting that the device answers.

```ts
// src/main.ts:125-130
this.socket.on('listening', () => {
	this.updateStatus(InstanceStatus.Ok)
	this.log('info', `Connected to ${this.config.host}:${this.config.port}`)
	this.syncAllStates()
})
```

**Fix:** set the status to Connecting when the socket starts listening, switch it to OK in `handleResponse()` when the first valid reply arrives from the configured host, and set ConnectionFailure (for example "No response from device") if nothing arrives within a few seconds of the startup queries.

### M6: The PGM/PVW Match Alert never lights when Program and Preview are both on Input 1

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.ts:112-114`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/feedbacks.ts#L112-L114)

**What goes wrong:** A user adds the "PGM/PVW Match Alert" feedback so a button turns yellow when Program and Preview show the same source. With Input 2 on both, the button turns yellow. With Input 1 on both, it stays dark, so the alert never works for the first HDMI input.

**Why it happens:** The device numbers its channels from 0, so Input 1 is channel 0 (the module's own comment at [`src/feedbacks.ts:15`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/feedbacks.ts#L15) says so). The feedback also requires the Program channel to be non-zero, probably to hide the alert before the first state sync, when both stored values start at 0. But 0 is also the real value for Input 1, so a genuine Input 1 match is always hidden.

```ts
// src/feedbacks.ts:112-114
callback: () => {
	return self.getCurrentPgm() === self.getCurrentPvw() && self.getCurrentPgm() !== 0
},
```

**Fix:** remove the `!== 0` check, and mark "not yet known" separately: start `currentPgm` / `currentPvw` at -1 (or add a "known" flag) and check `self.getCurrentPgm() >= 0`.

### M7: Program and Preview source variables show 0 for Input 1

- **Source:** 🔎 compliance reviewer + QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:662-667`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L662-L667), [`src/main.ts:504-514`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L504-L514), [`src/variables.ts:10-11`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/variables.ts#L10-L11)

**What goes wrong:** A user puts `$(feelworld-l3-series:current_pgm)` on a button label, or writes a trigger such as `$(feelworld-l3-series:current_pgm) == 1`, expecting it to follow the "PGM Source 1" action. With HDMI 1 on Program the variable shows 0, HDMI 2 shows 1, and Media shows 4. So a label reads "PGM: 0" and the expression is off by one.

**Why it happens:** The device reports channels from 0 (HDMI 1-4 = 0-3, Media = 4), and the module publishes those raw values as "Current Program Source" / "Current Preview Source". Everything else the user sees (the action names "PGM Source 1" to "5", the preset text "PGM 1", the feedback choices "Input 1" to "Media") counts from 1.

```ts
// src/main.ts:662-667
private updateVariableValues(): void {
	this.setVariableValues({
		current_pgm: this.currentPgm,
		current_pvw: this.currentPvw,
	})
}
```

**Fix:** publish 1-based values (`current_pgm: this.currentPgm + 1`), or add name variables as well (for example `current_pgm_name` = "Input 1" / "Media"), and say in the variable name what the value means (for example "Current Program Source (1-5, 5 = Media)"). This is the first release, so change it now, before users build expressions on the 0-based value; no upgrade script is needed.

### M8: Action and feedback schemas are untyped, so option ids and values are not type-checked

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:8`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/actions.ts#L8), [`src/feedbacks.ts:11`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/feedbacks.ts#L11)

**What goes wrong:** No visible effect today; this is code quality. A typo in a feedback option id, or in a preset's feedback options (for example `{ scnee: '1' }`), would compile and ship, and the button would silently never light.

**Why it happens:** Both schemas are declared as "any id, any options" (`Record<string, { options: CompanionOptionValues }>`), so the callbacks have to cast (`feedback.options.source as string`, at `src/feedbacks.ts` lines 83, 98, 191, 256 and 281) and the presets build their options as `Record<string, any>`. API 2.x lets a module declare each action and feedback with its options, so that `CompanionPresetDefinitions<ModuleSchema>` checks preset ids and options at compile time.

**Fix:** declare concrete schemas, for example `type FeedbacksSchema = { pgm_source: { type: 'boolean'; options: { source: string } }; scene_active: { type: 'boolean'; options: { scene: string } }; pip_active: { type: 'boolean'; options: Record<string, never> }; … }`, and the same for actions. Then drop the `as string` casts and the `Record<string, any>` preset option maps.

## 🟢 Low

### L1: Startup state-sync timers keep firing after the connection's settings are saved or it is disabled

- **Source:** 🔎 protocol reviewer + QA reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:95-110`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L95-L110), [`src/main.ts:633-659`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L633-L659)

**What goes wrong:** Each time the connection starts (on enable and on every settings save), the module schedules about 21 one-shot timers, 100 ms apart, that send read queries (PGM, PVW, PIP, key, LOGO, mute, volume, scene, FTB, AFV 1-5) over roughly 2.1 seconds. Nothing cancels them. If the user changes the Device IP Address (say from 192.168.1.100 to 192.168.1.101) within that window, the old run's leftover queries go out on the new socket next to the new run's, so the device gets duplicate reads. If the connection is disabled in that window, the leftover timers each log a "Socket not connected" error. The module's other short timers (the 100 ms button flash, the 1 s stream/disk warnings, the logo-toggle readback) are not tracked or cleared either.

**Why it happens:** The sync routine creates each timer with `setTimeout` and throws the handle away. On teardown, `destroy()` only clears the JSON-wait timer and closes the socket, and a settings save (`configUpdated()`) only closes the socket, so neither can cancel the pending timers.

**Evidence:**

```ts
// src/main.ts:95-110
async destroy(): Promise<void> {
	this.clearJsonWait()
	if (this.socket) {
		this.socket.close()
		this.socket = null
	}
}

async configUpdated(config: ModuleConfig): Promise<void> {
	this.config = config
	if (this.socket) {
		this.socket.close()
		this.socket = null
	}
	await this.connect()
}
// src/main.ts:655-659
queries.forEach((query, i) => {
	setTimeout(() => {
		query().catch(() => {})
	}, i * 100)
})
// src/main.ts:1087-1092
flashAction(id: string, ms = 100): void {
	this.flashUntil[id] = Date.now() + ms
	this.checkAllFeedbacks()
	setTimeout(() => {
		delete this.flashUntil[id]
		this.checkAllFeedbacks()
	}, ms)
}
```

**Confirm by:** open [`src/main.ts:655-659`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L655-L659) and see that the timer handles are discarded, then [`src/main.ts:95-110`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L95-L110): `destroy()` and `configUpdated()` cancel none of them.

**Fix:** keep the sync timer handles and clear them in `destroy()`, in `configUpdated()` before closing the old socket, and at the start of each new sync. Track the flash and warning timers the same way.

```ts
private syncTimers: NodeJS.Timeout[] = []

private clearSyncTimers(): void {
	for (const t of this.syncTimers) clearTimeout(t)
	this.syncTimers = []
}

// in syncAllStates(): this.clearSyncTimers(), then
// this.syncTimers.push(setTimeout(() => { query().catch(() => {}) }, i * 100))
```

### L2: PGM Source Indicator default highlight is almost black

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.ts:50-51`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/feedbacks.ts#L50-L51), [`src/feedbacks.ts:77-80`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/feedbacks.ts#L77-L80)

**What goes wrong:** A user adds the "PGM Source Indicator" feedback to their own button (not from a preset) and picks "Input 1". When Input 1 goes to Program, the button turns #28181C, a very dark maroon that is hard to tell from Companion's default black. The presets look fine because they use #B71F16 red.

**Why it happens:** The feedback's default style uses `PGM_ACTIVE_BG = 0x28181c`, while [`src/presets.ts:212`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/presets.ts#L212) defines its own `PGM_ACTIVE_BG = 0xb71f16`.

**Fix:** use one shared constant (for example `0xb71f16`) for both the feedback default style and the preset style.

### L3: Numbered copies of actions instead of one action with an option

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:144-153`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/actions.ts#L144-L153), [`src/actions.ts:294-317`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/actions.ts#L294-L317)

**What goes wrong:** The action list holds about 90 entries, many of them numbered copies: "PGM Source 1" to "5", "PVW Source 1" to "5", "Scene 1" to "8", "Effect Mode 1" to "16", "AFV 1" to "5 Toggle", "Stream 1" to "4 Toggle", "PIP Template 1" to "8". None has an option, so users cannot pick the input from a variable or expression; for example, one "Set Program" button driven by `$(custom:next_cam)` is not possible. The feedbacks are inconsistent too: "PGM Source Indicator" and "Scene Active" have a dropdown, but "AFV 1" to "5 Active" and "Stream 1" to "4 Active" are separate feedbacks.

**Why it happens:** Every action is built from a fixed spec with no options (see [`src/actions.ts:327`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/actions.ts#L327)), and the index is baked into the action id.

**Fix:** before the first release locks these ids in, consider single actions with a dropdown or number option (for example `pgm_source` with option `source`, `scene_recall` with option `scene`, `afv_toggle` with option `channel`) and matching single feedbacks. Changing ids later needs upgrade scripts, so now is the cheapest time. Keeping the numbered actions is also acceptable.

### L4: Source dropdown values are 0-4 for Input 1-Media, which is confusing in expression mode

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.ts:16-30`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/feedbacks.ts#L16-L30)

**What goes wrong:** A user switches the "Source" option of "PGM Source Indicator" to expression mode and enters 1, meaning Input 1. The feedback then lights for Input 2, because the values behind the labels are '0' = Input 1 … '4' = Media.

**Why it happens:** In API 2.x users can enter any dropdown as an expression, and they type the stored value, not the label. These values are the device's 0-based channel numbers.

**Fix:** use values that match the labels ('1' to '5', or 'input1' to 'input4' / 'media') and convert to the device channel in the callback. No upgrade script is needed for a first release; update the preset options at [`src/presets.ts:354`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/presets.ts#L354) too.

### L5: Long-running toggle actions ignore Abort actions

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:744-767`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L744-L767), [`src/main.ts:848-869`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L848-L869)

**What goes wrong:** If a button aborts its actions (Companion 5's "Abort actions") while "Stream 1 Toggle" is waiting for the device's confirmation, the module carries on: it keeps sending the stop/retry commands for up to about 3.2 s and may then flag the stream as on or show "ADDRESS EMPTY".

**Why it happens:** The stream toggle waits up to 1.5 s, sends a reset, waits 200 ms and waits another 1.5 s; the record toggle waits up to 1.5 s for the USB-disk query; the volume step and background query wait up to 1 s. The action callback at [`src/actions.ts:328`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/actions.ts#L328) never passes Companion's abort signal (`context.signal`) to these helpers.

**Fix:** pass `context.signal` into these helpers, check `signal.aborted` after each wait and return early (a wait that also resolves on the signal's `abort` event works well).

## 💡 Nice to Have

### N1: Duplicate send code and untyped JSON handling

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:676-711`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L676-L711), [`src/main.ts:326`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L326), [`src/main.ts:352`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L352)

**What goes wrong:** No user-visible effect. `sendBuffer()` and `sendCommand()` repeat the same socket check and send logic, and the JSON report parser uses `any` throughout, which makes future protocol changes easy to get wrong.

**Fix:** have `sendCommand()` build the string and call `sendBuffer(Buffer.from(command, 'ascii'), command)`, and add a small interface for the `0xB1 0x58` report (`pgmpvwInfo`, `streamInfo`, `recordInfo`, …) instead of `any`.

### N2: Tracked device state is not exposed as variables

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/variables.ts:3-12`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/variables.ts#L3-L12)

**What goes wrong:** Users can press "PVW Vol +1" / "PGM Vol +1" but cannot show the current volume on a button, although the module already reads it. The same goes for the current scene, recording, stream 1-4 state and transition type: they are only available as on/off highlights, not as text such as "SCN 3" or "VOL 72".

**Fix:** add variables such as `pgm_volume`, `pvw_volume`, `current_scene`, `recording`, `stream_1` to `stream_4` and `transition_type`, and set them wherever the matching state changes (`handleFixedFrame()` / `applyJsonReport()`).

## 📝 Additional Notes

- `tsconfig.build.json` differs from the template: `exclude` uses `src/**/*.spec.ts` where the template has `src/**/*spec.ts` (line 4). It builds fine; no change required.
