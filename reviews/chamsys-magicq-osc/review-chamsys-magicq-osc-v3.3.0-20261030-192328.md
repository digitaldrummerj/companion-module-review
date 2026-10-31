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

This release has no new findings.

## Verdict: ✅ Approved
