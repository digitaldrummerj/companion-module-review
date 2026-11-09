# Review: companion-module-warecotech-warecue v1.1.2 (follow-up to the v1.1.1 review)

| Field | Value |
| --- | --- |
| **Module** | `companion-module-warecotech-warecue` |
| **Scope** | `tag` |
| **Version** | v1.1.2 |
| **Release** | New module — never published |
| **API** | 1 (base 1.13.6, yarn.lock) |
| **Template** | `companion-module-template-ts-v1` @ `42609d8` (2026-03-03, pinned) · `.yarnrc.yml` from `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Previous tag** | none — first release (never published), so there is no published diff and the whole module was reviewed |
| **Prior review** | [v1.1.1 review](review-warecotech-warecue-v1.1.1-20261030-090507.md) (2026-10-30, ❌ Changes Required); every prior finding was re-checked, see [📝 Additional Notes](#-additional-notes) |
| **Review commit** | [`e78a108`](https://github.com/bitfocus/companion-module-warecotech-warecue/commit/e78a10887e7b566290aa64798bbce511b2b43c4a) |
| **Reviewed** | 2026-11-09 |

## Verdict: ✅ Approved

## ❓ Assumptions

Some findings depend on assumptions the reviewers couldn't check. They're listed in [❓ Assumptions to Confirm](#-assumptions-to-confirm) at the end of this review.

## 📋 Issues

### Non-blocking

- [ ] [L1: Auth token shown in plain text in the connection status when the host is a mistyped IP address](#l1-auth-token-shown-in-plain-text-in-the-connection-status-when-the-host-is-a-mistyped-ip-address)
- [ ] [L2: Connection status variable is blank during the first connection attempt](#l2-connection-status-variable-is-blank-during-the-first-connection-attempt)
- [ ] [L3: Local variables typed into an action's Output, Scene, Cue or Timer field are not expanded](#l3-local-variables-typed-into-an-actions-output-scene-cue-or-timer-field-are-not-expanded)
- [ ] [L4: Swap preview and program re-arms the old program scene even when the take fails](#l4-swap-preview-and-program-re-arms-the-old-program-scene-even-when-the-take-fails)
- [ ] [N1: Arming a preview scene or a cue that does not exist does nothing and leaves no log line](#n1-arming-a-preview-scene-or-a-cue-that-does-not-exist-does-nothing-and-leaves-no-log-line)
- [ ] [NR1: Move to the template's base 1.14, and plan the API 2 migration](#nr1-move-to-the-templates-base-114-and-plan-the-api-2-migration)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟢 Low

### L1: Auth token shown in plain text in the connection status when the host is a mistyped IP address

- **Source:** 🔎 protocol reviewer, QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/connection.ts:55-63`](https://github.com/bitfocus/companion-module-warecotech-warecue/blob/e78a10887e7b566290aa64798bbce511b2b43c4a/src/connection.ts#L55-L63)
- **Assumptions:** [A1, A2](#-assumptions-to-confirm)

**What goes wrong:** A user has set an "Auth token (optional)", which v1.1.2 now stores as a secret and masks in the settings. They then mistype the "WareCue host / IP" as `192.168.1.300` or `10.0.0.256`. The field's hostname check accepts these, and the connection status on the Connections page then reads `Cannot connect to ws://192.168.1.300:8090: SyntaxError: Invalid URL: ws://192.168.1.300:8090?token=s3cret-token`. The token is in clear text, so anyone who sees the Connections page, a screenshot of it or a log sees it, which undoes the masking added in this release. The status also flips between Connecting and Bad Config every 3 seconds until the host is fixed. Users without a token, and users with a valid host, are not affected.

**Why it happens:** The module adds the token to the WebSocket address as `?token=…`. When the address can't be parsed, the `ws` library (8.22.0) throws an error whose text is the full address, token included. The module puts that error text straight into the Bad Config status message. Each retry first reports Connecting again, so the status keeps changing.

**Evidence:**

```ts
// src/connection.ts:55-56
const headers = this.#token ? { Authorization: `Bearer ${this.#token}` } : undefined
const url = this.#token ? `${this.#url}?token=${encodeURIComponent(this.#token)}` : this.#url
// src/connection.ts:59-63
try {
	ws = new WebSocket(url, { headers })
} catch (err) {
	// A malformed host or port: say so in the status instead of retrying silently.
	this.#handlers.onStatus('badconfig', `Cannot connect to ${this.#url}: ${String(err)}`)
```

```text
SyntaxError: Invalid URL: ws://192.168.1.300:8090?token=s3cret-token
```

(Reproduced with the installed `ws` 8.22.0; base 1.13.6 `Regex.HOSTNAME` accepts `192.168.1.300`, `10.0.0.256` and `1.2.3.4.5`.)

**Fix:** keep the raw error text out of the status, and log it only with the token removed.

```ts
this.#handlers.onStatus('badconfig', `Invalid host or port: ${this.#url}`)
this.#handlers.log('debug', String(err).split(encodeURIComponent(this.#token)).join('***'))
```

Also consider not scheduling a reconnect when the address can't be built: it will never parse until `configUpdated()` brings a new host. If WareCue accepts the `Authorization: Bearer` header on its own, the `?token=` query parameter can be dropped as well.

### L2: Connection status variable is blank during the first connection attempt

- **Source:** 🔎 protocol reviewer, QA reviewer, compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:26-31`](https://github.com/bitfocus/companion-module-warecotech-warecue/blob/e78a10887e7b566290aa64798bbce511b2b43c4a/src/main.ts#L26-L31), [`src/main.ts:88-91`](https://github.com/bitfocus/companion-module-warecotech-warecue/blob/e78a10887e7b566290aa64798bbce511b2b43c4a/src/main.ts#L88-L91), [`src/connection.ts:54`](https://github.com/bitfocus/companion-module-warecotech-warecue/blob/e78a10887e7b566290aa64798bbce511b2b43c4a/src/connection.ts#L54)
- **Assumptions:** [A3](#-assumptions-to-confirm)

**What goes wrong:** A user puts `$(warecue:connection)` on a button to show the link state. When Companion starts, or the connection is enabled, while the WareCue PC is off, the button shows an empty value instead of `connecting` until the first attempt fails and it changes to `disconnected`. If the host doesn't answer at all, that can take tens of seconds. In v1.1.1 the variable read `connecting` straight away. The connection's own status on the Connections page (yellow Connecting) is not affected, only the variable.

**Why it happens:** `init()` reports Connecting before the variable definitions exist. Base 1.13.6 treats a value for an undefined variable as "delete it", and the definitions created a moment later start the variable at an empty string. Then the new "only forward a status when it changes" check (added in v1.1.2 for the prior N1) drops the second Connecting report from the connection itself, because it matches the first one. So `connecting` is never written to the defined variable.

**Evidence:**

```ts
// src/main.ts:26-31
async init(config: ModuleConfig, _isFirstInit: boolean, secrets: ModuleSecrets): Promise<void> {
	this.config = config
	this.secrets = secrets ?? {}
	this.#onStatus('connecting')
	this.#connect()
}
// src/main.ts:88-91
#onStatus(status: ConnStatus, message?: string): void {
	const key = `${status}|${message ?? ''}`
	if (key === this.#lastStatus) return
	this.#lastStatus = key
```

**Fix:** remove the early Connecting report from `init()`, because the connection already reports it when it opens. Alternatively, reset the remembered status in `#connect()` right after the definitions are rebuilt, so the next status always gets through.

```ts
// in #connect(), after this.#rebuildDefinitions()
this.#lastStatus = ''
```

### L3: Local variables typed into an action's Output, Scene, Cue or Timer field are not expanded

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:20-21`](https://github.com/bitfocus/companion-module-warecotech-warecue/blob/e78a10887e7b566290aa64798bbce511b2b43c4a/src/actions.ts#L20-L21)
- **Assumptions:** [A4](#-assumptions-to-confirm)

**What goes wrong:** The field tooltip invites typing a `$(variable)`, and global variables such as `$(internal:…)` work. But a button-scoped variable such as `$(this:page)`, or a button's local `$(local:…)` variable, typed into the Output field of "Output: take scene" (or the Scene, Cue or Timer field of other actions) is not expanded. The press sends a reference WareCue can't match, and the log shows `output.scene failed: …`. Feedbacks are not affected, because v1.1.2 made them expand variables through their own context.

**Why it happens:** The actions' shared helper expands variables through the connection-wide `self.parseVariablesInString()`. In base 1.13.6 that call doesn't tell Companion which button the action is on, so variables that depend on the button can't be resolved. The action callback's own `context.parseVariablesInString()` passes the button and action ids. Dropdown custom values are not expanded by Companion itself, because only text inputs have `useVariables`.

**Evidence:**

```ts
// src/actions.ts:20-21
const str = async (ev: CompanionActionEvent, key: string): Promise<string> =>
	(await self.parseVariablesInString(String(ev.options[key] ?? ''))).trim()
```

**Fix:** take the context in each callback and parse through it, the way `feedbacks.ts` already does with `opt()`.

```ts
const str = async (ev: CompanionActionEvent, ctx: CompanionActionContext, key: string): Promise<string> =>
	(await ctx.parseVariablesInString(String(ev.options[key] ?? ''))).trim()
// callback: async (ev, ctx) => … await str(ev, ctx, 'output') …
```

### L4: Swap preview and program re-arms the old program scene even when the take fails

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:83-94`](https://github.com/bitfocus/companion-module-warecotech-warecue/blob/e78a10887e7b566290aa64798bbce511b2b43c4a/src/actions.ts#L83-L94)

**What goes wrong:** Output 1 has Scene 3 on program and Scene 5 armed in preview. The operator presses a button with "Output: swap preview ↔ program" while WareCue is unreachable, or WareCue refuses the take. Program stays on Scene 3, but the module still arms Scene 3 in preview: the PVW button and `$(warecue:output_1_preview)` now show Scene 3, the TAKE-ready feedback goes off, and the operator has to re-arm Scene 5 by hand. When the take succeeds, the swap works as intended.

**Why it happens:** The action sends the take without waiting for WareCue's answer, then immediately moves the old program scene into the preview, whatever the result.

**Evidence:**

```ts
// src/actions.ts:90-92
const programId = output.activeSceneId
void self.send('output.scene', { outputId: output.id, sceneRef: previewSceneOf(self, output)!.id })
self.setPreview(output.id, programId)
```

**Fix:** wait for the result and only swap the local preview when the take succeeded.

```ts
const r = await self.send('output.scene', { outputId: output.id, sceneRef: previewSceneOf(self, output)!.id })
if (r.ok) self.setPreview(output.id, programId)
```

## 💡 Nice to Have

### N1: Arming a preview scene or a cue that does not exist does nothing and leaves no log line

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:63-72`](https://github.com/bitfocus/companion-module-warecotech-warecue/blob/e78a10887e7b566290aa64798bbce511b2b43c4a/src/actions.ts#L63-L72), [`src/actions.ts:164-181`](https://github.com/bitfocus/companion-module-warecotech-warecue/blob/e78a10887e7b566290aa64798bbce511b2b43c4a/src/actions.ts#L164-L181)

**What goes wrong:** A user sets "Cue: arm (set standby)" to cue `12a`, which does not exist, or "Output: preview (arm) scene" to a scene name with a typo. Pressing the button does nothing, and nothing appears in the connection log. Commands sent to WareCue now log `… failed: …` (the prior L2 fix), so these two locally resolved actions are the only silent ones.

**Why it happens:** Both actions look the output, scene or cue up locally first and simply return when nothing matches, without logging.

**Fix:** log a warning in those branches, matching the failure logging added to `send()`.

```ts
// cue_set_standby callback
const ref = await str(ev, 'cue')
const index = resolveCueIndex(self, ref)
if (index === null) {
	self.log('warn', `Cue: arm — no cue matches "${ref}"`)
	return
}
void self.send('cue.setStandby', { index })
```

## 🔮 Next Release

### NR1: Move to the template's base 1.14, and plan the API 2 migration

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`package.json:30`](https://github.com/bitfocus/companion-module-warecotech-warecue/blob/e78a10887e7b566290aa64798bbce511b2b43c4a/package.json#L30)

**What goes wrong:** Users see nothing different today. The module is built on `@companion-module/base` 1.13.6, while the API 1.x TypeScript template it follows now uses `~1.14.1`. Staying on 1.13 means missing the 1.14 fixes and the automatic config layout (Companion 4.2+). The longer-term path is API 2.x, which adds expression support in options. This carries forward the v1.1.1 review's R1.

**Why it happens:** `package.json` pins `"@companion-module/base": "~1.13.6"`; the template (`companion-module-template-ts-v1` @ `42609d8`) has `"~1.14.1"`. Both use `~`, so this is a version lag, not a layout difference.

**Fix:** in a future release, bump to `"@companion-module/base": "~1.14.1"`, rebuild, and check the config panel under the automatic layout. Later, plan the move to API 2.x (Companion 4.3+/5.0+) with the v1-to-v2 migration guide.

## 📝 Additional Notes

- This is the module's first release (never published): there is no published version to diff against, so the whole module was reviewed and every finding is 🆕 NEW. This review is a follow-up to the [v1.1.1 review](review-warecotech-warecue-v1.1.1-20261030-090507.md); the v1.1.1 → v1.1.2 changes (`6cc1087` "fix: address Bitfocus review of v1.1.1, release 1.1.2", `ba37a56` issue templates, merges `1b108b6` and `e78a108`) were checked against each of its findings.
- **Prior blocking findings, all fixed:** C1–C17 (missing `.gitattributes`, `.husky/pre-commit`, `eslint.config.mjs` and `tsconfig.build.json`; the `.gitignore` and `.prettierignore` differences; the missing `package.json` scripts, devDependencies and `lint-staged` section; the "stream deck" keyword; the entrypoint mismatch) and H1 (the changed `if:` in `companion-module-checks.yaml`). The template validator now reports no findings, and `yarn install --immutable`, `yarn package` and `yarn lint` all pass.
- **Prior M1–M4, fixed:** the issue templates and `.github/workflows/node.yaml` are now in the repo.
- **Prior M5–M8, fixed:** cue dropdowns store the cue number (or the cue's id) and scene dropdowns the scene id, so duplicate names no longer collide; feedbacks expand variables through their own context; the PGM/PVW display presets use the connection's label; the timer message is no longer parsed twice.
- **Prior L1–L3, fixed:** a blank host now shows Bad Config "Host is not set" (a mistyped IP address is [L1](#l1-auth-token-shown-in-plain-text-in-the-connection-status-when-the-host-is-a-mistyped-ip-address)); failed sends are logged by `send()`; changing host or port clears the old show from buttons, variables and dropdowns straight away.
- **Prior N1–N2, fixed:** the status is only forwarded when it changes (its side effect is [L2](#l2-connection-status-variable-is-blank-during-the-first-connection-attempt)); the auth token is now a `secret-text` field.
- **Prior R1, carried forward** as [NR1](#nr1-move-to-the-templates-base-114-and-plan-the-api-2-migration): base is still `~1.13.6`.

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Companion shows the message passed to `updateStatus()` (here the Bad Config text) next to the connection's status on the Connections page, where anyone using the admin UI can see it, and may also write it to the connection log | General Companion UI behaviour; the module only calls `updateStatus(InstanceStatus.BadConfig, message)`. Companion's host code not checked | [L1](#l1-auth-token-shown-in-plain-text-in-the-connection-status-when-the-host-is-a-mistyped-ip-address) |
| A2 | Companion checks the "WareCue host / IP" field only against its regex, so a host such as `192.168.1.300` can be saved | Base 1.13.6 `Regex.HOSTNAME` accepts `192.168.1.300` (run locally); Companion's config editor not checked | [L1](#l1-auth-token-shown-in-plain-text-in-the-connection-status-when-the-host-is-a-mistyped-ip-address) |
| A3 | When the WareCue PC is powered off, the first connection attempt stays in Connecting for the operating system's TCP connect timeout (roughly 20 s to 2 min), so the blank variable is visible for that long | Typical OS TCP connect behaviour; the module passes no `handshakeTimeout` to `ws` | [L2](#l2-connection-status-variable-is-blank-during-the-first-connection-attempt) |
| A4 | Companion can't resolve `$(this:…)` or `$(local:…)` variables when `parseVariablesInString` is called without a control id, and doesn't expand variables in a dropdown's custom value itself | Base 1.13.6: `InstanceBase.parseVariablesInString` sends `controlId: undefined`, while the action context passes `controlId` and `actionInstanceId`; `useVariables` exists only on text inputs. Companion's host code not checked | [L3](#l3-local-variables-typed-into-an-actions-output-scene-cue-or-timer-field-are-not-expanded) |
