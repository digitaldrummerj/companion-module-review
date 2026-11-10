# Review: digico-osc v2.1.1 (follow-up to the v2.1.0 review)

| Field | Value |
| --- | --- |
| **Module** | [`companion-module-digico-osc`](https://github.com/bitfocus/companion-module-digico-osc) |
| **Scope** | `tag` (follow-up: changes `v2.1.0..v2.1.1`, plus a re-check of every v2.1.0 finding; the changes since the last published v1.0.4 were reviewed in v2.1.0) |
| **Version** | v2.1.1 ([`6a485f4`](https://github.com/bitfocus/companion-module-digico-osc/commit/6a485f437e155b5ef09d6942208a2614169b5361)) |
| **Release** | Update — last published v1.0.4 |
| **API** | 2.2 (base 2.2.2, yarn.lock) — requires Companion 5.1+ |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Previous review** | [v2.1.0 (2026-11-09)](review-digico-osc-v2.1.0-20261109-172628.md), Changes Required; what happened to each of its findings is in [📝 Additional Notes](#-additional-notes) |
| **Reviewed** | 2026-11-09 |

## Verdict: ❌ Changes Required

## ❓ Assumptions

Some findings depend on assumptions the reviewers couldn't check. They're listed in [❓ Assumptions to Confirm](#-assumptions-to-confirm) at the end of this review.

## 📋 Issues

### Blocking

- [ ] [H1: The help page names the macro feedback "OSC button state", but Companion lists it as "OSC Macro State"](#h1-the-help-page-names-the-macro-feedback-osc-button-state-but-companion-lists-it-as-osc-macro-state)

### Non-blocking

- [ ] [L1: A macro state feedback for a button the console doesn't have still re-queries the button list on every macro change](#l1-a-macro-state-feedback-for-a-button-the-console-doesnt-have-still-re-queries-the-button-list-on-every-macro-change)
- [ ] [L2: The Dynamics Mode action and feedback are labelled "Maybe?" for users](#l2-the-dynamics-mode-action-and-feedback-are-labelled-maybe-for-users)
- [ ] [N1: Count variables are named like sections instead of counts](#n1-count-variables-are-named-like-sections-instead-of-counts)
- [ ] [N2: An unchanged Layout Bank list re-checks every Layout Bank feedback once per bank](#n2-an-unchanged-layout-bank-list-re-checks-every-layout-bank-feedback-once-per-bank)
- [ ] [N3: The legacy action table still maps the v1 Macro action to Recall Macro](#n3-the-legacy-action-table-still-maps-the-v1-macro-action-to-recall-macro)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟠 High

### H1: The help page names the macro feedback "OSC button state", but Companion lists it as "OSC Macro State"

- **Source:** 🔎 compliance reviewer — verified
- **Classification:** v2.1.0 H3, partly fixed (the line was rewritten in this release, still with the wrong name)
- **File:** [`companion/HELP.md:72`](https://github.com/bitfocus/companion-module-digico-osc/blob/6a485f437e155b5ef09d6942208a2614169b5361/companion/HELP.md#L72)

**What goes wrong:** A user reads "Using feedbacks" on the help page and searches the feedback picker for "OSC button state". No feedback has that name: Companion lists it as **[Macros] OSC Macro State**. Two lines further down, the help page uses the correct name, so the page also contradicts itself. The connection-settings part of the v2.1.0 finding is fixed: the settings table now says Receive Port, Transmit Port and Mixer IP Address.

**Why it happens:** Feedback names come straight from the `boolean_feedback_name` column of `digico_entities.csv` (only trimmed). The v2.1.1 edit replaced "Macro button state" with another name that isn't the feedback's either.

**Evidence:**

```text
// companion/HELP.md:72
... set its feedback style in Companion to choose the active color. **[Macros] OSC button state** is a boolean feedback for macro buttons.
// companion/HELP.md:74
... The replacement **[Macros] OSC Macro State** feedback controls colors only; ...
// digico_entities.csv:3 (column boolean_feedback_name)
/Macros/Buttons/state/*,Int,0,2,R,OSC macro button state,,1,indexedRecord,[Macros] OSC Macro State Value,Macro,[Macros] OSC Macro State,True when the OSC Macro matches the selected state.,macroButtonState,...
// src/commandTable.ts:183
				booleanFeedbackName: get('boolean_feedback_name').trim(),
// src/feedbacks.ts:133-134
				feedbacks[row.booleanFeedbackId] = {
					name: row.booleanFeedbackName,
```

**Confirm by:** open [`companion/HELP.md:72`](https://github.com/bitfocus/companion-module-digico-osc/blob/6a485f437e155b5ef09d6942208a2614169b5361/companion/HELP.md#L72) and compare the bold name with `boolean_feedback_name` in [`digico_entities.csv:3`](https://github.com/bitfocus/companion-module-digico-osc/blob/6a485f437e155b5ef09d6942208a2614169b5361/digico_entities.csv#L3) and with line 74.

**Fix:** use the feedback's real name on line 72: `**[Macros] OSC Macro State** is a boolean feedback for macro buttons.`

## 🟢 Low

### L1: A macro state feedback for a button the console doesn't have still re-queries the button list on every macro change

- **Source:** 🔎 protocol reviewer, QA reviewer
- **Classification:** v2.1.0 M1, partly fixed
- **File:** [`src/main.ts:454`](https://github.com/bitfocus/companion-module-digico-osc/blob/6a485f437e155b5ef09d6942208a2614169b5361/src/main.ts#L454), [`src/main.ts:565-566`](https://github.com/bitfocus/companion-module-digico-osc/blob/6a485f437e155b5ef09d6942208a2614169b5361/src/main.ts#L565-L566), [`src/entity-schemas.json:39-42`](https://github.com/bitfocus/companion-module-digico-osc/blob/6a485f437e155b5ef09d6942208a2614169b5361/src/entity-schemas.json#L39-L42)

**What goes wrong:** The runaway loop from v2.1.0 is gone: records that didn't change no longer trigger re-checks or definition rebuilds. But a user with **[Macros] OSC Macro State** for Macro 6 on a session that only has OSC macro buttons 0–3 still causes one full `/Macros/Buttons/?` query, and a 1-second wait, every time any macro button changes state on the console. In the reviewers' test, 5 state changes of button 2 caused 5 extra list queries. The cost is a little console traffic and debug-log noise.

**Why it happens:** The new "list already loaded" guard (`loadedRecordLists`) never turns on for the macro list. It looks up the record's definition by the response path `/Macros/Buttons/state`, but the schema stores that definition under the key `/Macros/Buttons/state/*`, so the lookup returns nothing and `/Macros/Buttons` is never recorded. The only list the lookup does find, `/Layout/Layout/Banks`, is never queried this way, so the guard currently has no effect anywhere.

```ts
// src/main.ts:565-566
const definition = getEntityRecordDefinition(record.schemaPath)
if (definition?.queryPath) this.loadedRecordLists.add(definition.queryPath)
```

**Fix:** find the definition by its response path, e.g. `entityRecordDefinitions().find((d) => d.responsePath === record.schemaPath)`, or key `loadedRecordLists` by `record.schemaPath` and check that in `getIndexedRecordOrQuery()`.

### L2: The Dynamics Mode action and feedback are labelled "Maybe?" for users

- **Source:** 🔎 compliance reviewer
- **Classification:** v2.1.0 L2, still open
- **File:** [`digico_osc.csv:429`](https://github.com/bitfocus/companion-module-digico-osc/blob/6a485f437e155b5ef09d6942208a2614169b5361/digico_osc.csv#L429)

**What goes wrong:** Users still see an action and feedback named "Dynamics Mode - Maybe?", which reads as unfinished and doesn't say what the values mean.

**Why it happens:** The row is unchanged and still writable (`RW`), and `src/value-mappings.json` has no entry for `gate-duck-comp`.

**Fix:** confirm the parameter on a console and give it a real name and value labels, or mark the row read-only/unlisted until it is confirmed.

## 💡 Nice to Have

### N1: Count variables are named like sections instead of counts

- **Source:** 🔎 compliance reviewer
- **Classification:** v2.1.0 N2, still open
- **File:** [`src/variables.ts:4-13`](https://github.com/bitfocus/companion-module-digico-osc/blob/6a485f437e155b5ef09d6942208a2614169b5361/src/variables.ts#L4-L13)

**What goes wrong:** In the variable list, the counts are named "Input Channels", "Aux Outputs" and so on, so they read like sections rather than numbers.

**Fix:** name them "Input channel count", "Aux output count", and so on.

### N2: An unchanged Layout Bank list re-checks every Layout Bank feedback once per bank

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:555-561`](https://github.com/bitfocus/companion-module-digico-osc/blob/6a485f437e155b5ef09d6942208a2614169b5361/src/main.ts#L555-L561), [`src/main.ts:571-580`](https://github.com/bitfocus/companion-module-digico-osc/blob/6a485f437e155b5ef09d6942208a2614169b5361/src/main.ts#L571-L580)

**What goes wrong:** Nothing visible. When the console re-sends an identical layout bank list, every **Layout Bank** feedback is re-checked once per bank record (4 re-checks for a 4-bank list). No query is sent and no definitions refresh runs, so the cost is a little CPU.

**Why it happens:** For lists stored as one collection (`collectRecords: true`), the new change check compares the single record's previous value with the whole collected array, so they never match.

**Fix:** for `collectRecords` definitions, compute "changed" from the record alone (`JSON.stringify(previous) !== JSON.stringify(record.value)`).

### N3: The legacy action table still maps the v1 Macro action to Recall Macro

- **Source:** 🔎 compliance reviewer, QA reviewer
- **Classification:** 🆕 NEW (the v2.1.1 fix made this line unused)
- **File:** [`src/upgrades.ts:30`](https://github.com/bitfocus/companion-module-digico-osc/blob/6a485f437e155b5ef09d6942208a2614169b5361/src/upgrades.ts#L30), [`src/upgrades.ts:133-147`](https://github.com/bitfocus/companion-module-digico-osc/blob/6a485f437e155b5ef09d6942208a2614169b5361/src/upgrades.ts#L133-L147)

**What goes wrong:** Nothing visible: upgraded Macro buttons now correctly press OSC macro button N − 1. But the `legacyActions` table still says `macros` → `/Macros/Recall_Macro/*`, the mapping that caused v2.1.0 H1. It is only used to get past the "no mapping" check; the special case at lines 133–147 then replaces it.

**Fix:** handle `macros` before the table lookup and delete line 30, or change line 30 to `/Macros/Buttons/press` so the table matches what the upgrade produces.

## 📝 Additional Notes

- `tsconfig.build.json` adds `"resolveJsonModule": true` after the template's `"verbatimModuleSyntax": true`. The module builds, so no change is required.
- `node.yaml` still leaves out `persist-credentials: false` on the checkout step; as in the v2.1.0 review, this is not treated as a finding.
- The README's version history renamed the `2.1.0` heading to `2.1.1`, so there is no 2.1.0 entry and this release's fixes (the macro upgrade, the help corrections) aren't listed.
- What happened to the findings of the [v2.1.0 review](review-digico-osc-v2.1.0-20261109-172628.md) (IDs below are that review's):

| v2.1.0 finding | Status in v2.1.1 |
| --- | --- |
| H1 upgraded v1 Macro buttons recall macro N | Fixed: they now press OSC macro button N − 1, as v1 did (checked by running the compiled upgrade script) |
| H2 `release.yaml` rewritten | Fixed: it matches the template |
| H3 help page names settings and the macro feedback differently | Partly: the settings names are fixed; the feedback name is still wrong ([H1](#h1-the-help-page-names-the-macro-feedback-osc-button-state-but-companion-lists-it-as-osc-macro-state)) |
| M1 macro feedback for a missing button keeps querying and rebuilding | Partly: the loop and rebuilds are gone; the list is still re-queried on every macro change ([L1](#l1-a-macro-state-feedback-for-a-button-the-console-doesnt-have-still-re-queries-the-button-list-on-every-macro-change)) |
| M2 upgraded macro feedbacks lose Use Console Macro Name | Addressed as suggested: the help page now says the option isn't carried over |
| L1 handshake waits forever when the Receive Port can't be opened | Fixed: the bind failure now ends the parked query and the port-unavailable status shows |
| L2 "Maybe?" label | Still open ([L2](#l2-the-dynamics-mode-action-and-feedback-are-labelled-maybe-for-users)) |
| L3 each refresh resends megabytes | Fixed: refreshes only run when a record really changes |
| L4 base dependency range | Fixed: `~2.2.2` |
| N1 silent console shows a warning | Fixed: it now shows a connection failure |
| N2 count variable names | Still open ([N1](#n1-count-variables-are-named-like-sections-instead-of-counts)) |

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Companion re-runs a feedback's callback each time the module calls `checkFeedbacksById` for it | base 2.2.2 `checkFeedbacksById` only forwards the ids to the host (`module-api/base.js:112-113`); host-side scheduling not checked | [L1](#l1-a-macro-state-feedback-for-a-button-the-console-doesnt-have-still-re-queries-the-button-list-on-every-macro-change), [N2](#n2-an-unchanged-layout-bank-list-re-checks-every-layout-bank-feedback-once-per-bank) |
