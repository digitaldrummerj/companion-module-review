# Review: companion-module-cuetone-cueplayer v1.0.0

| | |
| --- | --- |
| **Module** | `companion-module-cuetone-cueplayer` |
| **Scope** | `tag` (first release: there is no previous tag, so the whole module was reviewed) |
| **Version** | v1.0.0 |
| **Release** | New module — never published |
| **API** | 2.1 (base 2.1.3, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Commit** | [`7c44935`](https://github.com/bitfocus/companion-module-cuetone-cueplayer/tree/7c44935537498596bc5f6cc98507638a428d1871) |
| **Date** | 2026-10-30 |

## Verdict: ✅ Approved

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | When an option is switched to expression mode, Companion can't evaluate another field's `isVisibleExpression` that references it, so the dependent fields show or hide wrongly. Whether they end up hidden or shown depends on the Companion host | The base 2.1.3 `input.d.ts` note ("you can only reference fields which are set to `disableAutoExpression`"); not observed in a running Companion | [M1](#m1-go-action-the-list-id-and-song-id-fields-show-or-hide-wrongly-when-the-song-option-is-in-expression-mode) |

## 📋 Issues

### Non-blocking

- [ ] [M1: Go action: the List ID and Song ID fields show or hide wrongly when the Song option is in expression mode](#m1-go-action-the-list-id-and-song-id-fields-show-or-hide-wrongly-when-the-song-option-is-in-expression-mode)
- [ ] [M2: Aborting a button's actions doesn't stop the CuePlayer command from being sent](#m2-aborting-a-buttons-actions-doesnt-stop-the-cueplayer-command-from-being-sent)
- [ ] [L1: Token field help says the token is sent as a Bearer header, but over the network it is only used to sign requests](#l1-token-field-help-says-the-token-is-sent-as-a-bearer-header-but-over-the-network-it-is-only-used-to-sign-requests)
- [ ] [L2: On/Off/Toggle and pad-slot dropdowns allow expression mode they don't need](#l2-onofftoggle-and-pad-slot-dropdowns-allow-expression-mode-they-dont-need)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟡 Medium

### M1: Go action: the List ID and Song ID fields show or hide wrongly when the Song option is in expression mode

- **Source:** 🔎 compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:101-125`](https://github.com/bitfocus/companion-module-cuetone-cueplayer/blob/7c44935537498596bc5f6cc98507638a428d1871/src/actions.ts#L101-L125)

**What goes wrong:** A user adds the "곡 재생 (처음부터) · Go" action and switches its "곡" (Song) dropdown to expression mode, for example to pick the song from a variable or to enter `custom`. The "목록 ID" / "곡 ID" (List ID / Song ID) text fields then stop following the Song choice: they can be hidden when the user needs them, or shown when they don't apply. With the dropdown in normal mode (the default) everything works, and the action itself still sends the right song; only the editor display goes wrong.

**Why it happens:** The two text fields decide whether they are visible with `isVisibleExpression`, which reads the Song option (`$(options:track)`). The base 2.1.3 typings say a visibility expression may only read fields that can't be switched to expression mode (`disableAutoExpression: true`), because an expression field's value can't be evaluated there. The Song dropdown doesn't set that flag, and nothing in `src/` does.

**Evidence:**

```ts
// src/actions.ts:101-125
{
	id: 'track',
	type: 'dropdown',
	label: '곡',
	choices: trackChoices(host.library()),
	default: TRACK_SELECTED,
	minChoicesForSearch: 0,
	allowCustom: true,
},
{
	id: 'playlistId',
	type: 'textinput',
	label: '목록 ID (비우면 아무 목록)',
	default: '',
	useVariables: true,
	isVisibleExpression: `$(options:track) == '${TRACK_CUSTOM}'`,
},
{
	id: 'trackId',
	type: 'textinput',
	label: '곡 ID',
	default: '',
	useVariables: true,
	isVisibleExpression: `$(options:track) == '${TRACK_CUSTOM}'`,
},
```

```ts
// node_modules/@companion-module/base/dist/module-api/input.d.ts:31-43 (base 2.1.3)
 * You can access a value of the current options using `$(options:some_field_id)`.
 * Note: you can only reference fields which are set to `disableAutoExpression` here, as other fields can be expressions and frequently changing values
 */
isVisibleExpression?: string;
...
disableAutoExpression?: boolean;
```

**Confirm by:** open [`src/actions.ts:101-125`](https://github.com/bitfocus/companion-module-cuetone-cueplayer/blob/7c44935537498596bc5f6cc98507638a428d1871/src/actions.ts#L101-L125). The `track` dropdown has no `disableAutoExpression: true`, but `$(options:track)` is used in `isVisibleExpression` on lines 116 and 124.

**Fix:** stop the Song dropdown from being switched to expression mode. Users can still pass variables through the List ID / Song ID text fields, which already accept variables. Alternatively, drop the `isVisibleExpression` on the two text fields and always show them.

```ts
{
	id: 'track',
	type: 'dropdown',
	// ...
	allowCustom: true,
	disableAutoExpression: true,
},
```

### M2: Aborting a button's actions doesn't stop the CuePlayer command from being sent

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:74-76`](https://github.com/bitfocus/companion-module-cuetone-cueplayer/blob/7c44935537498596bc5f6cc98507638a428d1871/src/actions.ts#L74-L76), [`src/actions.ts:85-93`](https://github.com/bitfocus/companion-module-cuetone-cueplayer/blob/7c44935537498596bc5f6cc98507638a428d1871/src/actions.ts#L85-L93), [`src/actions.ts:127-129`](https://github.com/bitfocus/companion-module-cuetone-cueplayer/blob/7c44935537498596bc5f6cc98507638a428d1871/src/actions.ts#L127-L129)

**What goes wrong:** A button runs a CuePlayer action (for example "페이드 정지 · Fade out" or "효과음 울리기 · Pad trigger") and the user then aborts the running actions, for example with Companion's abort action. The HTTP command to CuePlayer is still sent and waited on for up to 2.5 s, so an aborted button can still fire its CuePlayer command.

**Why it happens:** On API 2.1, Companion hands each action callback an abort signal (`context.signal`) that fires when the user aborts. The action callbacks call `host.send(...)`, which makes the HTTP request with a 2.5 s timeout, without passing that signal on or checking it first.

**Fix:** take the callback's second argument, `(event, context)`, and pass `context.signal` through `send()` into `http.request({ signal })`, or at least return early when `context.signal.aborted` is set.

## 🟢 Low

### L1: Token field help says the token is sent as a Bearer header, but over the network it is only used to sign requests

- **Source:** 🔎 protocol reviewer, QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/config.ts:56-58`](https://github.com/bitfocus/companion-module-cuetone-cueplayer/blob/7c44935537498596bc5f6cc98507638a428d1871/src/config.ts#L56-L58)

**What goes wrong:** A user setting up CuePlayer on another computer reads the "토큰 (같은 네트워크일 때) · Token" field help: "Sent as Authorization: Bearer." For a remote IP such as 192.168.1.50 that isn't true: the module signs each request with the token and never sends the token itself. A user troubleshooting an Authentication Failure (for example because their CuePlayer is older than Mac 1.1.43 / Windows 1.0.49 and doesn't accept signed requests), or worried about the token travelling in clear text, gets misleading guidance. Control itself is not affected.

**Why it happens:** The field description wasn't updated when request signing was added. [`src/api.ts:79-102`](https://github.com/bitfocus/companion-module-cuetone-cueplayer/blob/7c44935537498596bc5f6cc98507638a428d1871/src/api.ts#L79-L102) sends HMAC headers (`X-Cue-Time` / `X-Cue-Nonce` / `X-Cue-Signature`) and adds the Bearer header only when CuePlayer runs on the same computer. [`companion/HELP.md:73`](https://github.com/bitfocus/companion-module-cuetone-cueplayer/blob/7c44935537498596bc5f6cc98507638a428d1871/companion/HELP.md#L73) already describes this correctly.

**Fix:** change the description to match HELP.md, for example: "Signed per request (HMAC); the token itself is only sent as Bearer to CuePlayer on this computer. Requires CuePlayer Mac 1.1.43 / Windows 1.0.49+."

### L2: On/Off/Toggle and pad-slot dropdowns allow expression mode they don't need

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:84`](https://github.com/bitfocus/companion-module-cuetone-cueplayer/blob/7c44935537498596bc5f6cc98507638a428d1871/src/actions.ts#L84), [`src/actions.ts:175`](https://github.com/bitfocus/companion-module-cuetone-cueplayer/blob/7c44935537498596bc5f6cc98507638a428d1871/src/actions.ts#L175), [`src/actions.ts:182`](https://github.com/bitfocus/companion-module-cuetone-cueplayer/blob/7c44935537498596bc5f6cc98507638a428d1871/src/actions.ts#L182)

**What goes wrong:** Nothing visibly breaks. In the "동작" (Mode) option of Voice-over / Stop after current / Repeat one, users can switch to expression mode, and a typo such as `tgl` makes the action do nothing without telling them, because the value matches no choice. This is UX polish.

**Why it happens:** The toggle/on/off `mode` dropdown doesn't set `disableAutoExpression: true`, which is recommended for choices that make no sense as expressions. The pad `slot` dropdowns have no `expressionDescription` saying an expression must return 1-10.

**Fix:** add `disableAutoExpression: true` to the `mode` dropdown in the `onOff` helper. Optionally add an `expressionDescription` to the pad `slot` dropdowns. This is a first release, so no saved expressions can break yet.

## 📝 Additional Notes

- This is the module's first release: there is no previous tag to diff against, so the whole module was reviewed. `yarn install --immutable`, `yarn package` and `yarn lint` all passed.
- `tsconfig.json` differs from the template: it adds `compilerOptions.allowJs: true` and `checkJs: false`, and widens `include` to `test/**/*.ts` and `test/**/*.mjs`. Fine as long as the module builds — no change required.
