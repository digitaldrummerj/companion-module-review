# Review: companion-module-cuetone-cueplayer v1.1.0

| Field | Value |
| --- | --- |
| **Module** | `companion-module-cuetone-cueplayer` |
| **Scope** | `tag` (first release: no previous tag, so this is a full review of the module) |
| **Version** | `v1.1.0` |
| **Release** | New module — never published |
| **API** | 2.1 (base 2.1.3, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Commit** | [`c6e2221`](https://github.com/bitfocus/companion-module-cuetone-cueplayer/blob/c6e222162a126c5b17a76f9d2e2ead7533b3c57e) |
| **Reviewed** | 2026-10-30 |

This module has never been published, so there is no previous release to diff against. Every file was reviewed, and every finding is classified 🆕 NEW.

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Companion's options editor resolves `$(options:<id>)` in an `isVisibleExpression` only for fields that set `disableAutoExpression: true`, as the base typings say. If Companion also resolves value-mode fields, the effect shrinks to the case where the user switches "곡" to expression mode | the `@companion-module/base` 2.1.3 typing comment at `input.d.ts:35-43`; the base package has no runtime check, and Companion's UI source was not inspected | [M1](#m1-playlist-id-and-track-id-fields-on-the-go-action-may-never-appear) |
| A2 | A Companion dropdown with `allowCustom: true` accepts a typed value such as `p12:t34` and passes it unchanged to the action callback, so the custom-ID path still works without the hidden fields | standard dropdown behaviour; not live-tested | [M1](#m1-playlist-id-and-track-id-fields-on-the-go-action-may-never-appear) |
| A3 | An expression-mode value that doesn't match one of a dropdown's choices makes Companion skip the action | the v2.0 compliance reference ("Expression validation") and the `allowInvalidValues` typing comment in `input.d.ts:45-51` | [L2](#l2-voice-over-stop-after-current-and-repeat-one-actions-can-be-switched-to-expression-mode) |

## 📋 Issues

### Blocking

- [ ] [H1: LICENSE file does not match the template](#h1-license-file-does-not-match-the-template)

### Non-blocking

- [ ] [M1: Playlist ID and Track ID fields on the Go action may never appear](#m1-playlist-id-and-track-id-fields-on-the-go-action-may-never-appear)
- [ ] [L1: Token help text says the token is sent as a Bearer header, but over the network it is not](#l1-token-help-text-says-the-token-is-sent-as-a-bearer-header-but-over-the-network-it-is-not)
- [ ] [L2: Voice-over, Stop after current and Repeat one actions can be switched to expression mode](#l2-voice-over-stop-after-current-and-repeat-one-actions-can-be-switched-to-expression-mode)
- [ ] [N1: Library load keeps fetching playlists after the connection is disabled or its settings are saved](#n1-library-load-keeps-fetching-playlists-after-the-connection-is-disabled-or-its-settings-are-saved)
- [ ] [N2: Cancelled button presses still wait for the HTTP request to finish](#n2-cancelled-button-presses-still-wait-for-the-http-request-to-finish)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟠 High

### H1: LICENSE file does not match the template

- **Source:** 🤖 validate-template (LICENSE-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`LICENSE:3`](https://github.com/bitfocus/companion-module-cuetone-cueplayer/blob/c6e222162a126c5b17a76f9d2e2ead7533b3c57e/LICENSE#L3)

**What goes wrong:** The module's `LICENSE` is not the template's license text. Modules in the Bitfocus repository ship the template's LICENSE unchanged, so this one has to be replaced before release.

**Why it happens:** Line 3 of `LICENSE` was changed from the template's copyright line to the module author's own.

**Evidence:**

```text
LICENSE:3
found:    Copyright (c) 2026 CueTone
template: Copyright (c) 2022 Bitfocus AS - Open Source
```

**Confirm by:** `diff LICENSE <template>/LICENSE` against `companion-module-template-ts` shows no differences.

**Fix:** replace [`LICENSE`](https://github.com/bitfocus/companion-module-cuetone-cueplayer/blob/c6e222162a126c5b17a76f9d2e2ead7533b3c57e/LICENSE) with the template's LICENSE text exactly.

## 🟡 Medium

### M1: Playlist ID and Track ID fields on the Go action may never appear

- **Source:** 🔎 compliance reviewer — ⚠️ needs your check
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:104-128`](https://github.com/bitfocus/companion-module-cuetone-cueplayer/blob/c6e222162a126c5b17a76f9d2e2ead7533b3c57e/src/actions.ts#L104-L128)

**What goes wrong:** A user adds the "곡 재생 (처음부터) · Go" action to a button and sets the "곡" dropdown to "직접 입력 (목록 ID · 곡 ID)", so they can type a playlist ID and a track ID (for example `p12` and `t34`). The "목록 ID (비우면 아무 목록)" and "곡 ID" fields are meant to appear at that point, but they may stay hidden, so that way of entering custom IDs can't be used. Typing `p12:t34` straight into the "곡" dropdown still works, because the dropdown accepts custom values (see [A2](#-assumptions-to-confirm)). If the user switches "곡" to expression mode, the two fields have no fixed value to test against at all.

**Why it happens:** In API 2.x, a user can switch any action option to expression mode unless the option sets `disableAutoExpression: true`. The two ID fields decide whether to show themselves with an `isVisibleExpression` that reads the "곡" field (`$(options:track)`). The base typings say such an expression may only read fields that set `disableAutoExpression`, and the "곡" dropdown doesn't set it.

**Evidence:**

```ts
// src/actions.ts:104-128
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
					...
					isVisibleExpression: `$(options:track) == '${TRACK_CUSTOM}'`,
				},
				{
					id: 'trackId',
					...
					isVisibleExpression: `$(options:track) == '${TRACK_CUSTOM}'`,
				},
```

```ts
// node_modules/@companion-module/base/dist/module-api/input.d.ts:35-43 (base 2.1.3)
     * You can access a value of the current options using `$(options:some_field_id)`.
     * Note: you can only reference fields which are set to `disableAutoExpression` here, as other fields can be expressions and frequently changing values
     */
    isVisibleExpression?: string;
```

```ts
// src/library.ts:35-41 (the typed-value path, which doesn't need the hidden fields)
export function decodeTrackChoice(value: string): { playlistId?: string; trackId?: string } {
	const v = value.trim()
	if (!v || v === TRACK_CUSTOM) return {}
	const i = v.indexOf(':')
	if (i < 0) return { trackId: v }
	return { playlistId: v.slice(0, i) || undefined, trackId: v.slice(i + 1) || undefined }
}
```

**Confirm by:** in Companion 5.0+, add the "곡 재생 (처음부터) · Go" action, set "곡" to "직접 입력 (목록 ID · 곡 ID)" in value mode, and check whether the "목록 ID" and "곡 ID" fields appear. Then add `disableAutoExpression: true` to the `track` option at [`src/actions.ts:104-112`](https://github.com/bitfocus/companion-module-cuetone-cueplayer/blob/c6e222162a126c5b17a76f9d2e2ead7533b3c57e/src/actions.ts#L104-L112) and check again.

**Fix:** stop the "곡" dropdown from being switched to expression mode. This is a first release, so no saved expressions can break, and `allowCustom: true` still lets users type a value.

```ts
{
	id: 'track',
	type: 'dropdown',
	label: '곡',
	choices: trackChoices(host.library()),
	default: TRACK_SELECTED,
	minChoicesForSearch: 0,
	allowCustom: true,
	disableAutoExpression: true,
},
```

Alternatively, drop the `isVisibleExpression` on `playlistId` and `trackId` and keep them always visible; `goRequest()` already ignores them unless "곡" is set to "직접 입력". See companion-v2-actions.

## 🟢 Low

### L1: Token help text says the token is sent as a Bearer header, but over the network it is not

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/config.ts:53-60`](https://github.com/bitfocus/companion-module-cuetone-cueplayer/blob/c6e222162a126c5b17a76f9d2e2ead7533b3c57e/src/config.ts#L53-L60)

**What goes wrong:** In the connection settings, the help text under "토큰 (같은 네트워크일 때) · Token" ends with "Sent as Authorization: Bearer." When CuePlayer runs on another computer (for example at 192.168.1.50), the module never sends the token: it signs each request with it instead. Connections work either way, but a user worried about the token crossing the LAN in clear text, or debugging authentication with a packet capture, gets the wrong picture.

**Why it happens:** The field description wasn't updated when request signing was added. The module only sends the token as a Bearer header when CuePlayer runs on the same computer (a loopback address such as 127.0.0.1); otherwise it sends HMAC signature headers ([`src/api.ts:89-102`](https://github.com/bitfocus/companion-module-cuetone-cueplayer/blob/c6e222162a126c5b17a76f9d2e2ead7533b3c57e/src/api.ts#L89-L102)).

**Fix:** change the description to match what the module does, for example: "Requests are signed with this token (HMAC). The token itself is only sent when CuePlayer runs on this computer."

### L2: Voice-over, Stop after current and Repeat one actions can be switched to expression mode

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:87`](https://github.com/bitfocus/companion-module-cuetone-cueplayer/blob/c6e222162a126c5b17a76f9d2e2ead7533b3c57e/src/actions.ts#L87)

**What goes wrong:** On the "보이스오버 · Voice-over", "끝나면 정지 · Stop after current" and "한 곡 반복 · Repeat one" actions, a user can switch the "동작" field to expression mode. If the expression returns anything other than `on`, `off` or `toggle` (for example `1` or `true`), Companion rejects the value and skips the action, so the button does nothing (see [A3](#-assumptions-to-confirm)). Normal use of the dropdown is not affected.

**Why it happens:** The "동작" dropdown is a fixed three-way choice but doesn't set `disableAutoExpression: true`, which API 2.x recommends for on/off/toggle fields.

**Fix:** add `disableAutoExpression: true` to the `mode` dropdown in the `onOff` helper. This is safe now because the module has never been published. See companion-v2-actions.

```ts
options: [{ id: 'mode', type: 'dropdown', label: '동작', choices: MODE_CHOICES, default: 'toggle', disableAutoExpression: true }],
```

## 💡 Nice to Have

### N1: Library load keeps fetching playlists after the connection is disabled or its settings are saved

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/library.ts:16-29`](https://github.com/bitfocus/companion-module-cuetone-cueplayer/blob/c6e222162a126c5b17a76f9d2e2ead7533b3c57e/src/library.ts#L16-L29)

**What goes wrong:** A user has 40 playlists in CuePlayer. While the module is loading the song list for the Go action's "곡" dropdown, the user saves new connection settings (for example a new host IP) or disables the connection. The old connection keeps requesting each playlist from the old CuePlayer until all 40 are fetched. The result is thrown away, so buttons, feedbacks and variables don't change; the only effect is a short burst of extra HTTP requests to the old host.

**Why it happens:** `loadLibrary()` fetches the playlists one by one in a loop and never checks whether the connection was stopped. Stopping the connection clears its timers but can't cancel this loop; `reloadLibrary()` only checks `running` after the whole loop has finished.

**Fix:** give `loadLibrary` a way to stop early, for example a `() => this.running` callback it checks before each request, or an `AbortSignal` that `stop()` aborts and that is passed to `http.request({ signal })`.

### N2: Cancelled button presses still wait for the HTTP request to finish

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:77-79`](https://github.com/bitfocus/companion-module-cuetone-cueplayer/blob/c6e222162a126c5b17a76f9d2e2ead7533b3c57e/src/actions.ts#L77-L79), [`src/actions.ts:88-96`](https://github.com/bitfocus/companion-module-cuetone-cueplayer/blob/c6e222162a126c5b17a76f9d2e2ead7533b3c57e/src/actions.ts#L88-L96), [`src/actions.ts:138-140`](https://github.com/bitfocus/companion-module-cuetone-cueplayer/blob/c6e222162a126c5b17a76f9d2e2ead7533b3c57e/src/actions.ts#L138-L140)

**What goes wrong:** When Companion cancels a running action (for example while CuePlayer is slow to answer), the HTTP request keeps going until its 2.5-second timeout. With "재생/일시정지 · Play/Pause toggle" that can be two requests, so up to about 5 seconds. Nothing visibly breaks, so this is polish.

**Why it happens:** API 2.1 gives action callbacks a cancel signal (`context.signal`). The callbacks don't pass it on, and the HTTP client ([`src/api.ts:153-209`](https://github.com/bitfocus/companion-module-cuetone-cueplayer/blob/c6e222162a126c5b17a76f9d2e2ead7533b3c57e/src/api.ts#L153-L209)) uses `node:http` with a timeout but no `AbortSignal`.

**Fix:** optionally pass `context.signal` from the callback's second argument through `send()` into `http.request({ signal })`, or check `signal.aborted` between the status read and the command in `togglePlayPause`. See the v2.1 abort-signal notes in companion-v2-actions.

## 📝 Additional Notes

- `tsconfig.json` differs from the template: it adds `compilerOptions.allowJs` (plus `checkJs`, `rootDir` and `noEmit`), and its `include` adds `test/**/*.ts` and `test/**/*.mjs`. Not blocking; the module builds and lints — no change required.
