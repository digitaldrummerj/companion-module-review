# Companion Module Review: moxa-e2200series v2.0.0

| Field | Value |
| --- | --- |
| **Module** | [companion-module-moxa-e2200series](https://github.com/bitfocus/companion-module-moxa-e2200series) |
| **Version** | v2.0.0 (commit [`75956f1`](https://github.com/bitfocus/companion-module-moxa-e2200series/commit/75956f1ca51b667eb9fe48435a6233732d10cfca)) |
| **Release** | Update — last published v1.0.6 |
| **API** | 2.2 (base 2.2.2, yarn.lock) — requires Companion 5.1+ |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Scope** | `tag` — `v1.0.6..v2.0.0`. v2.0.0 rewrites the module in TypeScript on API 2.2 (v1.0.6 was JavaScript on base 1.12), so every file under `src/` is new and was reviewed, along with the upgrade path from v1.0.6 |
| **Reviewed** | 2026-11-10 |

## Verdict: ✅ Approved

## 📋 Issues

### Non-blocking

- [ ] [M1: Users who switch a dropdown to an expression aren't told which numbers it expects](#m1-users-who-switch-a-dropdown-to-an-expression-arent-told-which-numbers-it-expects)
- [ ] [N1: Right after Companion starts, button presses can wait several seconds behind duplicate reads](#n1-right-after-companion-starts-button-presses-can-wait-several-seconds-behind-duplicate-reads)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟡 Medium

### M1: Users who switch a dropdown to an expression aren't told which numbers it expects

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/options.ts:59-65`](https://github.com/bitfocus/companion-module-moxa-e2200series/blob/75956f1ca51b667eb9fe48435a6233732d10cfca/src/options.ts#L59-L65), [`src/options.ts:9-56`](https://github.com/bitfocus/companion-module-moxa-e2200series/blob/75956f1ca51b667eb9fe48435a6233732d10cfca/src/options.ts#L9-L56)

**What goes wrong:** In Companion 5 any action or feedback option can be switched to an expression, which v1.0.6 didn't offer. A user who switches **Trigger** on **Set DI Trigger** to an expression has to return a number, but nothing tells them that 0 = Low to High, 1 = High to Low and 2 = Both. The same applies to:

- **Status** on **Set DO Status** (0 = Off, 1 = On);
- **Mode** on **Set DO Mode**, **Set DI Mode** and the matching feedbacks (0 = DO or DI, 1 = Pulse or Counter);
- **Pulse** on **Set DO Pulse** and **Count** on **Set DI Count Start** (0 = Stop, 1 = Start);
- the **DO** and **DI** pickers (a channel number counted from 0, such as `3`, or an array such as `[0, 1]` on the actions).

An expression that returns the label instead, for example `"Both"`, matches no choice, so Companion skips the action and nothing reaches the device. The normal dropdowns work as before.

**Why it happens:** The choice ids are the numbers the device uses (0, 1, 2), kept so that buttons saved by v1.0.6 still work. The dropdowns built by `choiceOption()`, `outputsOption()`, `inputsOption()`, `outputOption()` and `inputOption()` have no `expressionDescription`, the hint Companion shows under an option in expression mode.

**Fix:** Keep the ids (changing them would need an upgrade script) and add an `expressionDescription` built from the choices, for example `'0 = Low to High, 1 = High to Low, 2 = Both'` in `choiceOption()` and `'A channel number from 0, or an array of them, e.g. [0, 1]'` on the channel pickers. For choices that make no sense as an expression, such as on/off and start/stop, `disableAutoExpression: true` removes the expression toggle instead.

## 💡 Nice to Have

### N1: Right after Companion starts, button presses can wait several seconds behind duplicate reads

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:155`](https://github.com/bitfocus/companion-module-moxa-e2200series/blob/75956f1ca51b667eb9fe48435a6233732d10cfca/src/actions.ts#L155) (and the other `subscribe` hooks in that file), [`src/protocol.ts:78`](https://github.com/bitfocus/companion-module-moxa-e2200series/blob/75956f1ca51b667eb9fe48435a6233732d10cfca/src/protocol.ts#L78), [`src/client.ts:11`](https://github.com/bitfocus/companion-module-moxa-e2200series/blob/75956f1ca51b667eb9fe48435a6233732d10cfca/src/client.ts#L11)

**What goes wrong:** Take a page with 60 buttons that use actions such as **Set DO Status**, **Set DO Mode** or **Get DO Status**. When Companion starts, or the connection is enabled, the module sends one read for each of those actions on top of its own connect query: about 70 requests through a queue that sends at most 10 a second. For roughly 7 seconds, a press of **Set DO Status → On** waits behind those reads, so the output switches late. After that, presses respond normally.

**Why it happens:** Each action has a `subscribe` hook that reads its parameter from the device, and Companion runs those hooks for every saved action right after `init()`. The connect query (`fullQuery()`) already reads every one of those parameters, so at startup the hook reads are duplicates. They share the module's single request queue (one request at a time, at most one every 100 ms) with the user's button presses.

**Fix:** Skip the hook's read until the connect query has finished (the module already tracks that in `#queried`), so the hooks only read for actions that are placed or edited later.

## 📝 Additional Notes

- `tsconfig.build.json` differs from the template: its `exclude` has `src/**/__tests__/**` and `src/**/__mocks__/**` where the template has `src/**/__tests__/*` and `src/**/__mocks__/*`. The module builds and lints; no change required.
