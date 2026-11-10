# Review: liveplay-liveplay v1.1.1 (follow-up to v1.1.0)

| Field | Value |
| --- | --- |
| **Module** | [companion-module-liveplay-liveplay](https://github.com/bitfocus/companion-module-liveplay-liveplay) |
| **Scope** | `tag` |
| **Version** | v1.1.1 |
| **Release** | New module — never published |
| **API** | 2.1 (base 2.1.3, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Commit** | [`100cc1b`](https://github.com/bitfocus/companion-module-liveplay-liveplay/commit/100cc1bfb5dac50289186692e3279842b79014d8) |
| **Previous review** | [v1.1.0, 2026-11-06](review-liveplay-liveplay-v1.1.0-20261106-181511.md) — Changes Required |
| **Reviewed** | 2026-11-09 |

This is a follow-up to the v1.1.0 review. The module has still never been published, so there is no published release to diff against. The whole module was reviewed again, and every finding is classified 🆕 NEW. The v1.1.0..v1.1.1 changes (5 files, +44/−14) were also checked against each finding of the v1.1.0 review. **All 4 earlier findings are fixed**; the per-finding check is in [📝 Additional Notes](#-additional-notes).

Both High findings below are in `package.json` lines that are unchanged since v1.0.0. The review now compares dependency ranges and the pre-commit lint command with the template, which the earlier reviews did not, so they are raised here for the first time.

## Verdict: ❌ Changes Required

## ❓ Assumptions

Some findings depend on assumptions the reviewers couldn't check. They're listed in [❓ Assumptions to Confirm](#-assumptions-to-confirm) at the end of this review.

## 📋 Issues

### Blocking

- [ ] [H1: The module is locked to one exact version of the Companion base library, unlike the template](#h1-the-module-is-locked-to-one-exact-version-of-the-companion-base-library-unlike-the-template)
- [ ] [H2: The pre-commit hook lints TypeScript files with a different command from the template](#h2-the-pre-commit-hook-lints-typescript-files-with-a-different-command-from-the-template)

### Non-blocking

- [ ] [L1: Cart slot fields accept fractional slots such as 2.5, which name no real cart slot](#l1-cart-slot-fields-accept-fractional-slots-such-as-25-which-name-no-real-cart-slot)
- [ ] [N1: Index-path cue buttons re-scan the whole cue list four times a second while a cue is on air](#n1-index-path-cue-buttons-re-scan-the-whole-cue-list-four-times-a-second-while-a-cue-is-on-air)
- [ ] [N2: The current state variable shows Pause, a command word, for a paused cue](#n2-the-current-state-variable-shows-pause-a-command-word-for-a-paused-cue)

### Notes

- **Translated button labels:** [`src/locale.ts`](https://github.com/bitfocus/companion-module-liveplay-liveplay/blob/100cc1bfb5dac50289186692e3279842b79014d8/src/locale.ts#L59-L353) still holds the per-language preset names and button labels taken from LivePlay's own translations. The validator reports them as non-English text (NOT-ENGLISH, 111 lines), but they were accepted in the v1.1.0 review because translation is a supported feature of the module, and the file is unchanged since then. No change requested.
- [📝 Additional Notes](#-additional-notes)

## 🟠 High

### H1: The module is locked to one exact version of the Companion base library, unlike the template

- **Source:** 🔎 compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`package.json:26`](https://github.com/bitfocus/companion-module-liveplay-liveplay/blob/100cc1bfb5dac50289186692e3279842b79014d8/package.json#L26)

**What goes wrong:** Users see no difference today. The module can only ever install `@companion-module/base` 2.1.3, so a `yarn install` or lockfile refresh never picks up a 2.1.x patch release of the Companion base library (fixes to how the module talks to Companion, or to its typings). It also makes this module differ from every other API 2.1 TypeScript module built from the template. When something misbehaves later, a difference like this sends people troubleshooting the module instead of the real cause.

**Why it happens:** `package.json` lists the dependency as the exact version `"2.1.3"`. The TypeScript template (API 2.1) uses the tilde range `"~2.1.3"`, which allows any 2.1.x release from 2.1.3 up. The lockfile resolves the exact pin.

**Evidence:**

```json
// package.json:25-28 (module @ v1.1.1)
	"dependencies": {
		"@companion-module/base": "2.1.3",
		"ws": "^8.18.0"
	},
```

```json
// companion-module-template-ts/package.json:25-27 (template @ e0d42b7)
	"dependencies": {
		"@companion-module/base": "~2.1.3"
	},
```

```text
// yarn.lock:30-32 (module @ v1.1.1)
"@companion-module/base@npm:2.1.3":
  version: 2.1.3
  resolution: "@companion-module/base@npm:2.1.3"
```

**Confirm by:** open [`package.json:26`](https://github.com/bitfocus/companion-module-liveplay-liveplay/blob/100cc1bfb5dac50289186692e3279842b79014d8/package.json#L26). It reads `"@companion-module/base": "2.1.3"`, while line 26 of the template's `package.json` reads `"~2.1.3"`.

**Fix:** use the template's tilde range, then run `yarn install` and commit the updated `yarn.lock`.

```json
"@companion-module/base": "~2.1.3",
```

### H2: The pre-commit hook lints TypeScript files with a different command from the template

- **Source:** 🔎 compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`package.json:46-48`](https://github.com/bitfocus/companion-module-liveplay-liveplay/blob/100cc1bfb5dac50289186692e3279842b79014d8/package.json#L46-L48)

**What goes wrong:** Users see no difference. When a contributor commits, the pre-commit hook fixes the staged TypeScript files with a bare `eslint --fix`, while every module built from the TypeScript template runs the module's own lint script, `yarn lint:raw --fix`. The two commands do the same thing today, because `lint:raw` is just `eslint`. If the lint setup changes later (for example `lint:raw` gains a flag), this module's hook silently behaves differently, and troubleshooting has to start by finding out why.

**Why it happens:** The `lint-staged` section of `package.json` (the list of commands the pre-commit hook runs on staged files) uses a different command for `*.{ts,tsx,js,jsx}` than the template does.

**Evidence:**

```json
// package.json:42-49 (module @ v1.1.1)
	"lint-staged": {
		"*.{css,json,md,scss}": [
			"prettier --write"
		],
		"*.{ts,tsx,js,jsx}": [
			"eslint --fix"
		]
	},
```

```json
// companion-module-template-ts/package.json:40-47 (template @ e0d42b7)
	"lint-staged": {
		"*.{css,json,md,scss}": [
			"prettier --write"
		],
		"*.{ts,tsx,js,jsx}": [
			"yarn lint:raw --fix"
		]
	},
```

```json
// package.json:13 (module @ v1.1.1)
		"lint:raw": "eslint",
```

**Confirm by:** open [`package.json:47`](https://github.com/bitfocus/companion-module-liveplay-liveplay/blob/100cc1bfb5dac50289186692e3279842b79014d8/package.json#L47). It reads `"eslint --fix"`, while line 45 of the template's `package.json` reads `"yarn lint:raw --fix"`.

**Fix:** use the template's command for TypeScript and JavaScript files.

```json
"*.{ts,tsx,js,jsx}": [
	"yarn lint:raw --fix"
]
```

## 🟢 Low

### L1: Cart slot fields accept fractional slots such as 2.5, which name no real cart slot

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:267-283`](https://github.com/bitfocus/companion-module-liveplay-liveplay/blob/100cc1bfb5dac50289186692e3279842b79014d8/src/actions.ts#L267-L283), [`src/feedbacks.ts:61-69`](https://github.com/bitfocus/companion-module-liveplay-liveplay/blob/100cc1bfb5dac50289186692e3279842b79014d8/src/feedbacks.ts#L61-L69)

**What goes wrong:** Say a user sets the slot of a "Trigger cart slot" button with an expression such as `$(local:n) / 2`, which gives 2.5. Companion accepts the value because it is between 1 and 64, and the module asks LivePlay to play cart slot `1.5` (`/api/transport/cart/1.5/play`), which is not a slot on the cart wall. The "Cart slot is playing" feedback and the "Cart slot progress / color / text color / name" value feedbacks look up slot 1.5 as well, which the module never has, so the button stays unlit and its name shows "2.5". Users who type a whole number are not affected.

**Why it happens:** Both slot fields are number fields with a minimum and maximum but without `asInteger: true`. Companion checks the range of the value but only rounds it to a whole number when the field sets `asInteger`.

**Fix:** add `asInteger: true` to the `slot` option of "Trigger cart slot" ([`src/actions.ts:270-278`](https://github.com/bitfocus/companion-module-liveplay-liveplay/blob/100cc1bfb5dac50289186692e3279842b79014d8/src/actions.ts#L270-L278)) and to the shared `cartSlotOption` ([`src/feedbacks.ts:61-69`](https://github.com/bitfocus/companion-module-liveplay-liveplay/blob/100cc1bfb5dac50289186692e3279842b79014d8/src/feedbacks.ts#L61-L69)).

```ts
min: 1,
max: 64,
asInteger: true,
```

## 💡 Nice to Have

### N1: Index-path cue buttons re-scan the whole cue list four times a second while a cue is on air

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/state.ts:309-315`](https://github.com/bitfocus/companion-module-liveplay-liveplay/blob/100cc1bfb5dac50289186692e3279842b79014d8/src/state.ts#L309-L315), [`src/feedbacks.ts:54-58`](https://github.com/bitfocus/companion-module-liveplay-liveplay/blob/100cc1bfb5dac50289186692e3279842b79014d8/src/feedbacks.ts#L54-L58), [`src/main.ts:834-835`](https://github.com/bitfocus/companion-module-liveplay-liveplay/blob/100cc1bfb5dac50289186692e3279842b79014d8/src/main.ts#L834-L835)

**What goes wrong:** No visible effect at normal show sizes. While any cue is playing or paused, the module re-checks every "Cue progress (value, for gauges)" feedback every 250 ms. A button built from the "Trigger cue by index path" preset finds its cue by walking the whole cue list each time, so 32 such buttons on a 400-cue show cost about 51,000 lookups a second inside the module. Buttons that target a cue by UUID, including the generated "Trigger Cue" presets, are not affected. This depends on [A1](#-assumptions-to-confirm).

**Why it happens:** The progress feedback turns an index path such as `2,35` into a cue by calling `uuidAtIndex()`, which loops over every cue in the project and joins each cue's index path into a string to compare it. The 250 ms tick re-checks the progress feedbacks for as long as anything is on air, paused cues included.

**Fix:** build a map from index path to UUID once, when the cue list is loaded, and look the path up in `uuidAtIndex()`. You could also skip the progress re-check while every on-air cue is paused, because a paused cue's progress doesn't move.

```ts
private uuidByIndex = new Map<string, string>()
// in applyCatalog(), after filling this.catalog:
this.uuidByIndex.clear()
for (const item of this.catalog.values()) if (item.index) this.uuidByIndex.set(item.index.join(','), item.uuid)
// uuidAtIndex():
return this.uuidByIndex.get(index.join(',')) ?? ''
```

### N2: The current state variable shows Pause, a command word, for a paused cue

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/variables.ts:109-110`](https://github.com/bitfocus/companion-module-liveplay-liveplay/blob/100cc1bfb5dac50289186692e3279842b79014d8/src/variables.ts#L109-L110)

**What goes wrong:** A button showing `$(liveplay:current_state)` reads "Playing" while the current cue plays and "Pause" when it is paused. "Pause" reads like an instruction rather than a state, and doesn't match the "Fading in" and "Fading out" values of the same variable. The "Cue state" value feedback already returns `paused` correctly.

**Why it happens:** The function that builds the variable's text (`transportLabel()`) reuses the label of the Pause button for the Paused state.

**Fix:** return a state word for the Paused state, like the fading states do.

```ts
case Transport.Paused:
	return 'Paused'
```

## 📝 Additional Notes

- **v1.1.0 H1 (the manifest claims the `liveplay` module id), fixed:** [`companion/manifest.json:24`](https://github.com/bitfocus/companion-module-liveplay-liveplay/blob/100cc1bfb5dac50289186692e3279842b79014d8/companion/manifest.json#L24) now reads `"legacyIds": []`, as in the template.
- **v1.1.0 L1 (every cue start re-downloads the whole project), fixed:** a new `catalogDirty` flag ([`src/main.ts:101`](https://github.com/bitfocus/companion-module-liveplay-liveplay/blob/100cc1bfb5dac50289186692e3279842b79014d8/src/main.ts#L101)) is set only by `project_changed` and the `item_*` patches ([`src/main.ts:716-724`](https://github.com/bitfocus/companion-module-liveplay-liveplay/blob/100cc1bfb5dac50289186692e3279842b79014d8/src/main.ts#L716-L724)), or when the summary shows a different project or item count. The summary refresh re-reads the project document only when the flag is set ([`src/main.ts:741-750`](https://github.com/bitfocus/companion-module-liveplay-liveplay/blob/100cc1bfb5dac50289186692e3279842b79014d8/src/main.ts#L741-L750)), so cue starts, Up Next and cart-slot changes fetch just the summary.
- **v1.1.0 L2 (a config with no host fails to start), fixed:** `normalizeConfig()` now uses `String(config.host ?? '').trim()` ([`src/main.ts:78-80`](https://github.com/bitfocus/companion-module-liveplay-liveplay/blob/100cc1bfb5dac50289186692e3279842b79014d8/src/main.ts#L78-L80)), so a config without a host reaches the "Server host is not set" check.
- **v1.1.0 N1 (Bus fader adjust changes the shown level while disconnected), fixed:** `wsSend()` returns whether the message went out ([`src/main.ts:229-236`](https://github.com/bitfocus/companion-module-liveplay-liveplay/blob/100cc1bfb5dac50289186692e3279842b79014d8/src/main.ts#L229-L236)), and "Bus fader: adjust" updates its cached level only when it did ([`src/actions.ts:540`](https://github.com/bitfocus/companion-module-liveplay-liveplay/blob/100cc1bfb5dac50289186692e3279842b79014d8/src/actions.ts#L540)).

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | When the module calls `checkFeedbacks('cue_progress', …)`, Companion re-runs the callback of every placed "Cue progress" feedback, so each index-path gauge button looks up its cue once per 250 ms tick | Usual Companion behaviour for `checkFeedbacks`; base 2.1.3 only forwards the call to Companion (`dist/module-api/base.js`), and Companion's own host code was not checked | [N1](#n1-index-path-cue-buttons-re-scan-the-whole-cue-list-four-times-a-second-while-a-cue-is-on-air) |
