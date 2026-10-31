# Review: chamsys-magicq-osc v3.3.0 (follow-up)

| | |
| --- | --- |
| **Module** | `companion-module-chamsys-magicq-osc` ([repo](https://github.com/bitfocus/companion-module-chamsys-magicq-osc)) |
| **Scope** | `tag` (`v3.1.1..v3.3.0`) |
| **Version** | v3.3.0 (`ead4984`, 2026-10-27) |
| **Release** | Update — last published v3.1.1 |
| **API** | 2.0 (base 2.0.4, yarn.lock) — requires Companion 4.3+ |
| **Template** | `companion-module-template-js-v2.0.4` @ `e4caa76` (2026-08-28, pinned) |
| **Prior review** | [v3.2.1, 2026-10-05](review-chamsys-magicq-osc-v3.2.1-20261005-024911.md) (❌ Changes Required) |
| **Language** | JavaScript (ESM) |
| **Build** | `yarn install --immutable` and `yarn package` pass |
| **Review date** | 2026-10-30 |

This is a follow-up to the v3.2.1 review. All 13 findings from that review are fixed in v3.3.0:

| Prior finding | Status in v3.3.0 |
| --- | --- |
| C1: settings can't be opened (`Regex` not imported) | ✅ Fixed: `Regex` imported in [`src/main.js:1`](https://github.com/bitfocus/companion-module-chamsys-magicq-osc/blob/ead4984af7bfff16648cbfde0ac68db6c3654582/src/main.js#L1) |
| H1: unticking Enable Feedback removes feedbacks, variables and forwarding | ✅ Fixed: feedbacks and variables are always registered, forwarding no longer depends on the checkbox, and `companion/HELP.md` explains the change |
| M1: saving the settings drops execute variables | ✅ Fixed: known executes are re-added and their values re-published |
| M2: one network error leaves the connection red | ✅ Fixed: only bind failures set Connection Failure, with a retry after 5 s |
| M3: show/hide checks read expression fields | ✅ Fixed: Comparison method and Toggle? have `disableAutoExpression: true` |
| M4: Flash, Black Out and Swap Mode accept expressions | ✅ Fixed: `disableAutoExpression: true` on all three |
| L1: OSC message without a number sets NaN | ✅ Fixed: first argument read and checked |
| L2: Connecting forever with no reply | ✅ Fixed: 10 s warning and subscription re-send |
| L3: setup errors not caught | ✅ Fixed: setup is synchronous and wrapped in try/catch |
| L4: status update on every fader move | ✅ Fixed: status only sent when it changes |
| L5: Toggle does nothing when the hidden level is blank | ✅ Fixed: level only checked when Toggle? is off |
| L6: execute pages limited differently per path | ✅ Fixed: one rule (page 1-10, number 1-1000) on all four paths |
| N1: empty RPC Command still sent | ✅ Fixed: trimmed and rejected when empty |

The findings below are new to this review.

## Verdict: ✅ Approved

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | When a module adds a new connection setting, Companion doesn't write that setting's default into an existing connection's saved settings at startup. The value stays missing until the user opens and saves the connection's settings | `@companion-module/base` 2.0.4 has no default fill-in for config (only an upgrade script's `updatedConfig` can add a value); Companion's host code not checked | [M1](#m1-connections-created-on-v310-or-earlier-silently-lose-console-feedback-after-upgrading-to-v330) |

## 📋 Issues

### Non-blocking

- [ ] [M1: Connections created on v3.1.0 or earlier silently lose console feedback after upgrading to v3.3.0](#m1-connections-created-on-v310-or-earlier-silently-lose-console-feedback-after-upgrading-to-v330)
- [ ] [N1: Numeric options are still free-text boxes, so a typo like 1O is only caught when the button is pressed](#n1-numeric-options-are-still-free-text-boxes-so-a-typo-like-1o-is-only-caught-when-the-button-is-pressed)

---

## 🟡 Medium

### M1: Connections created on v3.1.0 or earlier silently lose console feedback after upgrading to v3.3.0

- **Source:** 🔎 QA reviewer
- **Classification:** 🔙 REGRESSION
- **File:** [`src/main.js:88-90`](https://github.com/bitfocus/companion-module-chamsys-magicq-osc/blob/ead4984af7bfff16648cbfde0ac68db6c3654582/src/main.js#L88-L90), [`src/main.js:379-383`](https://github.com/bitfocus/companion-module-chamsys-magicq-osc/blob/ead4984af7bfff16648cbfde0ac68db6c3654582/src/main.js#L379-L383), [`src/main.js:489`](https://github.com/bitfocus/companion-module-chamsys-magicq-osc/blob/ead4984af7bfff16648cbfde0ac68db6c3654582/src/main.js#L489), [`src/upgrades.js:1`](https://github.com/bitfocus/companion-module-chamsys-magicq-osc/blob/ead4984af7bfff16648cbfde0ac68db6c3654582/src/upgrades.js#L1)

**What goes wrong:** A user who added the MagicQ connection on v3.1.0 or earlier has no saved **Enable Feedback** value, because that checkbox didn't exist then. On v3.1.1 (the last published version) that didn't matter: the module always listened on the **Feedback Port** (9000), asked the console for feedback and processed what it sent back. After upgrading to v3.3.0, the missing value counts as "off". The module stops listening on 9000 and ignores the console. The variables `$(magicq:pb1)`…`$(magicq:pb10)` and the execute variables stop following faders moved on the desk, and buttons using the **Playback Level**, **Playback Flash** or **Execute Level** feedbacks only reflect what Companion itself sent. The connection still shows a green OK, so nothing tells the user feedback stopped. The same happens to a v3.1.1 user who had unticked **Enable Feedback** while it had no effect. Users who open and save the connection settings (with the box ticked) are not affected.

**Why it happens:** The module reads the setting as `!!this.config.enableFeedback`, so a missing value is treated as false, even though the field's default is ticked. There is no upgrade script that fills in `enableFeedback: true` for settings saved before the field existed (see [A1](#-assumptions-to-confirm)). The comment at [`src/main.js:62`](https://github.com/bitfocus/companion-module-chamsys-magicq-osc/blob/ead4984af7bfff16648cbfde0ac68db6c3654582/src/main.js#L62) ("With feedback off they reflect what this module sent, as in v3.1.1") describes behaviour v3.1.1 never had: v3.1.1 never read `enableFeedback` outside its settings page.

**Evidence:**

```js
// src/main.js:88-90
	feedbackEnabled() {
		return !!this.config.enableFeedback
	}
// src/main.js:379-383
		const feedbackEnabled = this.feedbackEnabled()
		const forwardOSC = !!this.config.forwardOSC
		// Forwarding relays what the console sends, so it needs the listening
		// socket too, whether or not feedback is enabled.
		const listen = feedbackEnabled || forwardOSC
// src/upgrades.js:1
export default []
```

```js
// git show v3.1.1:index.js:288, 302 (always bound the Feedback Port and subscribed)
			localPort: this.config.rxPort,
			this.sendOSC('/feedback/pb+exec')
```

**Confirm by:** run `git show v3.1.1:index.js | grep -n enableFeedback` (matches only in the settings fields) and `git show v3.1.0:index.js | grep -n enableFeedback` (no matches). Then open [`src/main.js:88-90`](https://github.com/bitfocus/companion-module-chamsys-magicq-osc/blob/ead4984af7bfff16648cbfde0ac68db6c3654582/src/main.js#L88-L90), where `!!undefined` is false, and [`src/upgrades.js:1`](https://github.com/bitfocus/companion-module-chamsys-magicq-osc/blob/ead4984af7bfff16648cbfde0ac68db6c3654582/src/upgrades.js#L1).

**Fix:** treat a missing value as ticked, and tell users who unticked it that it now takes effect.

```js
feedbackEnabled() {
	return this.config.enableFeedback !== false
}
```

Or add a config upgrade script in `src/upgrades.js` that sets `enableFeedback: true` when it's missing and returns it as `updatedConfig`. Either way, add a line to the "Notes for upgrading" in `companion/HELP.md` saying **Enable Feedback** now takes effect, so anyone who unticked it knows to tick it again.

---

## 💡 Nice to Have

### N1: Numeric options are still free-text boxes, so a typo like 1O is only caught when the button is pressed

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.js:10-25`](https://github.com/bitfocus/companion-module-chamsys-magicq-osc/blob/ead4984af7bfff16648cbfde0ac68db6c3654582/src/actions.js#L10-L25)

**What goes wrong:** Options such as **Playback fader (1-10)**, **Fader value (0-100 %)**, **Execute Page (1-10)** and **Execute Nr (1-1000)** on the **Set the playback fader level**, **Execute** and **Adjust Execute Level** actions, and the same fields on the **Playback Level** and **Execute Level** feedbacks, are plain text boxes. If a user types `1O` (letter O) or `150`, the editor only shows a red hint; the button saves, and pressing it does nothing except log a warning such as "Set playback fader: playback must be 1-10 and level a number". Nothing is broken today: the module rejects bad input safely.

**Why it happens:** This release keeps these options as text boxes (`type: 'textinput'` with `regex: Regex.NUMBER` and `useVariables: true`). In API 2.0 any field type can take variables through expression mode, so a number field would work and would block the bad value in the editor.

**Fix:** optional, for a later release. Change the numeric options (`pbId`, `pbVal`, `exeP`, `exeNr`, `exeVal`, `execPage`, `execNumber`, `execVal`, `tenSceneItem`, `tenSceneZone`) to `type: 'number'` with `min`/`max` (for example `pbId` 1-10, `pbVal` 0-100). Add an upgrade script in `src/upgrades.js` that calls `FixupNumericOrVariablesValueToExpressions` for those options, so saved buttons that use `$(...)` become expressions. Leave `pbVal` / `exeVal` on the Adjust actions as text if an empty value should mean "not set".
