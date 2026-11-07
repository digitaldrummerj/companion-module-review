# Review: pltech-kumatimer v2.7.0 (follow-up to the v2.6.2 review)

| | |
| --- | --- |
| **Module** | pltech-kumatimer |
| **Scope** | `tag` (the `v2.6.2..v2.7.0` diff: 16 files, +559/-251) |
| **Version** | v2.7.0 (previous tag v2.6.2) |
| **Release** | Update — last published v2.6.2 |
| **API** | 2.0 (base 2.0.4, yarn.lock) — requires Companion 4.3+ |
| **Template** | `companion-module-template-ts-v2.0.4` @ `d62230e` (2026-08-28, pinned) |
| **Commit** | [`5aefc39`](https://github.com/bitfocus/companion-module-pltech-kumatimer/tree/5aefc3938a26d3a6d22c9175e6b56a58799e99e3) |
| **Prior review** | [v2.6.2 (2026-10-30)](review-pltech-kumatimer-v2.6.2-20261030-003407.md) — approved; none of its findings changed in this release (see [📝 Additional Notes](#-additional-notes)) |
| **Reviewed** | 2026-11-06 |

This release adds Opening Animation actions, feedbacks, variables and presets, an Overtime Blink action, feedback, variable and preset, and the `ppt_notes` / `ppt_notes_next` speaker-notes variables. `yarn install --immutable`, `yarn package` and `yarn lint` all pass.

## Verdict: ✅ Approved

## ❓ Assumptions

Some findings depend on assumptions the reviewers couldn't check. They're listed in [❓ Assumptions to Confirm](#-assumptions-to-confirm) at the end of this review.

## 📋 Issues

### Non-blocking

- [ ] [L1: Help page doesn't describe the new Opening animation features](#l1-help-page-doesnt-describe-the-new-opening-animation-features)
- [ ] [L2: BLINK and NEON look buttons light up while KUMA Timer is offline](#l2-blink-and-neon-look-buttons-light-up-while-kuma-timer-is-offline)
- [ ] [N1: The Action field of the new on/off actions can be switched to expression mode](#n1-the-action-field-of-the-new-onoff-actions-can-be-switched-to-expression-mode)
- [ ] [N2: New opener and blink actions and feedbacks read options untyped](#n2-new-opener-and-blink-actions-and-feedbacks-read-options-untyped)
- [ ] [NR1: GitHub workflow uses older checkout and setup-node actions than the template](#nr1-github-workflow-uses-older-checkout-and-setup-node-actions-than-the-template)
- [ ] [NR2: Migration notes and a code comment are written in Polish, so other maintainers can't read them](#nr2-migration-notes-and-a-code-comment-are-written-in-polish-so-other-maintainers-cant-read-them)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟢 Low

### L1: Help page doesn't describe the new Opening animation features

- **Source:** 🔎 QA reviewer, compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`companion/HELP.md:28-50`](https://github.com/bitfocus/companion-module-pltech-kumatimer/blob/5aefc3938a26d3a6d22c9175e6b56a58799e99e3/companion/HELP.md#L28-L50), [`companion/HELP.md:56-71`](https://github.com/bitfocus/companion-module-pltech-kumatimer/blob/5aefc3938a26d3a6d22c9175e6b56a58799e99e3/companion/HELP.md#L56-L71), [`companion/HELP.md:77-118`](https://github.com/bitfocus/companion-module-pltech-kumatimer/blob/5aefc3938a26d3a6d22c9175e6b56a58799e99e3/companion/HELP.md#L77-L118), [`companion/HELP.md:128-136`](https://github.com/bitfocus/companion-module-pltech-kumatimer/blob/5aefc3938a26d3a6d22c9175e6b56a58799e99e3/companion/HELP.md#L128-L136), [`README.md:34-37`](https://github.com/bitfocus/companion-module-pltech-kumatimer/blob/5aefc3938a26d3a6d22c9175e6b56a58799e99e3/README.md#L34-L37)

**What goes wrong:** A user opens the KUMA Timer connection's help in Companion to find out how to drive the new opening animation and finds nothing about it. "Available Actions" lists "Overtime Blink On / Off" but not "Opening Animation On / Off" or "Opening Animation: Choose Look". "Available Feedbacks" lists none of the three new feedbacks ("Overtime blink is on", "Opening animation: on the outputs now", "Opening animation: this look is selected"). The variables table has no `opener_active`, `opener_look` or `opener_look_name`, and "Preset Buttons" has no "Opening animation" category. README.md doesn't mention the opener either. The features still work; users just only find them through the Presets panel or the action picker. Separately, README.md says the state-flag variables use "the same ids as the matching feedbacks" and lists `blink_overtime`, but the feedback id is `blink_overtime_on`.

**Why it happens:** Commit `7cb5747` added the opener features to the actions, feedbacks, variables and presets but didn't touch `companion/HELP.md` or `README.md`. The commits for the overtime blink (`0d02518`) and the speaker-notes variables (`af09b27`) did update both files, apart from the blink feedback row.

**Fix:** in `companion/HELP.md`, add rows for the two Opening Animation actions, the three new feedbacks (including "Overtime blink is on") and the `opener_active` / `opener_look` / `opener_look_name` variables, with the host requirement (v1.20.2+) and the look ids (`neon` / `roll` / `glitch`, shown as NEON / FLIP / GLITCH). Add an "Opening animation" bullet (on/off, NEON / FLIP / GLITCH looks, next look) to "Preset Buttons". Make the same variable addition to the README list, and either rename the feedback reference there or note that the blink flag's feedback is `blink_overtime_on`.

### L2: BLINK and NEON look buttons light up while KUMA Timer is offline

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.ts:424`](https://github.com/bitfocus/companion-module-pltech-kumatimer/blob/5aefc3938a26d3a6d22c9175e6b56a58799e99e3/src/feedbacks.ts#L424), [`src/feedbacks.ts:452-453`](https://github.com/bitfocus/companion-module-pltech-kumatimer/blob/5aefc3938a26d3a6d22c9175e6b56a58799e99e3/src/feedbacks.ts#L452-L453), [`src/variables.ts:359-362`](https://github.com/bitfocus/companion-module-pltech-kumatimer/blob/5aefc3938a26d3a6d22c9175e6b56a58799e99e3/src/variables.ts#L359-L362)

**What goes wrong:** An operator adds the new "Overtime blink: on / off" preset (BLINK) and the "Opening animation: NEON look" preset. KUMA Timer then stops answering and the connection turns red ("Connection Failure"). The BLINK button switches to "BLINK ON" in orange, the NEON button turns blue as if NEON were selected, and the "Opening animation: next look" button reads "LOOK NEON". The variables `$(pltech-kumatimer:blink_overtime)` and `$(pltech-kumatimer:opener_look_name)` show `true` and `NEON`. The buttons claim a known state while there is no host. This is the same pattern as L1 in the v2.6.2 review (Timer mode and TCR source buttons).

**Why it happens:** After a failed poll the module clears its saved status to an empty object ([`src/main.ts:103`](https://github.com/bitfocus/companion-module-pltech-kumatimer/blob/5aefc3938a26d3a6d22c9175e6b56a58799e99e3/src/main.ts#L103)), then resets the variables and re-checks every feedback. "Overtime blink is on" falls back to on when the field is missing, and "Opening animation: this look is selected" falls back to `neon`. The variable reset writes the same defaults. Those defaults are meant for older hosts that don't send the fields (see [A1](#-assumptions-to-confirm)), but they also apply when no status has been received at all.

**Fix:** apply the defaults only when a status has actually been received, and reset the variables to "unknown" values when the host is unreachable.

```ts
// src/feedbacks.ts
callback: () => {
	const s = lastStatus()
	return s.status !== undefined && (s.blink_overtime ?? true)
},
// ...
callback: (feedback) => {
	const s = lastStatus()
	return s.status !== undefined && String(s.opener_look ?? 'neon') === String(feedback.options['look'])
},
```

In `clearVariables()` set `blink_overtime: 'false'`, `opener_look: ''` and `opener_look_name: ''`.

## 💡 Nice to Have

### N1: The Action field of the new on/off actions can be switched to expression mode

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:12-22`](https://github.com/bitfocus/companion-module-pltech-kumatimer/blob/5aefc3938a26d3a6d22c9175e6b56a58799e99e3/src/actions.ts#L12-L22), [`src/actions.ts:406`](https://github.com/bitfocus/companion-module-pltech-kumatimer/blob/5aefc3938a26d3a6d22c9175e6b56a58799e99e3/src/actions.ts#L406), [`src/actions.ts:431`](https://github.com/bitfocus/companion-module-pltech-kumatimer/blob/5aefc3938a26d3a6d22c9175e6b56a58799e99e3/src/actions.ts#L431)

**What goes wrong:** Users only notice this if they switch the "Action" field of "Overtime Blink On / Off" or "Opening Animation On / Off" to expression mode. An expression that returns anything other than `toggle`, `on` or `off` (for example `true` or `1`) isn't one of the choices, so the button doesn't do what the user expects. Editor polish only.

**Why it happens:** Both new actions reuse the shared on/off/toggle dropdown (`onOffToggle`), which doesn't set `disableAutoExpression: true`. The API 2.0 guidance recommends that flag for mode selectors like on/off/toggle.

**Fix:** add `disableAutoExpression: true` to `onOffToggle`. If expression use should stay possible, add an `expressionDescription` saying the expression must return `toggle`, `on` or `off`.

### N2: New opener and blink actions and feedbacks read options untyped

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:432-433`](https://github.com/bitfocus/companion-module-pltech-kumatimer/blob/5aefc3938a26d3a6d22c9175e6b56a58799e99e3/src/actions.ts#L432-L433), [`src/actions.ts:455-459`](https://github.com/bitfocus/companion-module-pltech-kumatimer/blob/5aefc3938a26d3a6d22c9175e6b56a58799e99e3/src/actions.ts#L455-L459), [`src/feedbacks.ts:452-453`](https://github.com/bitfocus/companion-module-pltech-kumatimer/blob/5aefc3938a26d3a6d22c9175e6b56a58799e99e3/src/feedbacks.ts#L452-L453)

**What goes wrong:** Users see no effect; this is code quality only. The new "Opening Animation On / Off", "Opening Animation: Choose Look" and "Overtime Blink On / Off" actions, and the "Opening animation: this look is selected" feedback, take `options: Record<string, unknown>` and check types by hand (`typeof action.options['look'] === 'string'`, `String(feedback.options['look'])`). A mistyped option id would compile and quietly read `undefined`.

**Why it happens:** `KumaTypes` in `src/types.ts` declares only `config` and `secrets`, with no `actions` / `feedbacks` schema, so option ids can't be type-checked. The new code follows the existing pattern raised as N2 in the v2.6.2 review.

**Fix:** optionally add `actions` and `feedbacks` schemas to `KumaTypes` so the callbacks get typed options and the manual `typeof` / `String()` conversions can go.

## 🔮 Next Release

### NR1: GitHub workflow uses older checkout and setup-node actions than the template

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW (carried over: the file is unchanged since v1.8.0 and was [M1 in the v2.6.2 review](review-pltech-kumatimer-v2.6.2-20261030-003407.md#m1-github-workflow-uses-an-older-checkout-action-than-the-template))
- **File:** [`.github/workflows/node.yaml:18`](https://github.com/bitfocus/companion-module-pltech-kumatimer/blob/5aefc3938a26d3a6d22c9175e6b56a58799e99e3/.github/workflows/node.yaml#L18), [`.github/workflows/node.yaml:21`](https://github.com/bitfocus/companion-module-pltech-kumatimer/blob/5aefc3938a26d3a6d22c9175e6b56a58799e99e3/.github/workflows/node.yaml#L21)

**What goes wrong:** Users see no effect. The module's GitHub lint workflow runs on older versions of the checkout and Node setup actions than the API 2.0 template, so its CI no longer matches what every other module built from that template runs. A difference like this makes later troubleshooting harder.

**Why it happens:** The workflow was copied from an older template and has not been refreshed since. The template has since moved to `actions/checkout@v7` and `actions/setup-node@v6`. The commented-out `test:` job differs the same way, and it also has two extra commented-out lines (a codecov step) that the template doesn't have.

**Evidence:**

```diff
# diff companion-module-template-ts-v2.0.4/.github/workflows/node.yaml .github/workflows/node.yaml
18c18
<       - uses: actions/checkout@v7
---
>       - uses: actions/checkout@v4
21c21
<         uses: actions/setup-node@v6
---
>         uses: actions/setup-node@v4
59c59
<   #     - uses: actions/checkout@v7
---
>   #     - uses: actions/checkout@v4
61c61
<   #       uses: actions/setup-node@v6
---
>   #       uses: actions/setup-node@v4
74a75,76
>   #     - name: Send coverage
>   #       uses: codecov/codecov-action@v5
```

The validator reports this as "line 15" because it skips comment lines; the actual file line is 18.

**Confirm by:** `diff companion-module-templates/companion-module-template-ts-v2.0.4/.github/workflows/node.yaml .github/workflows/node.yaml`, or open [`.github/workflows/node.yaml:18-21`](https://github.com/bitfocus/companion-module-pltech-kumatimer/blob/5aefc3938a26d3a6d22c9175e6b56a58799e99e3/.github/workflows/node.yaml#L18-L21).

**Fix:** copy `.github/workflows/node.yaml` from the API 2.0 template (`companion-module-template-ts-v2.0.4` @ `d62230e`).

### NR2: Migration notes and a code comment are written in Polish, so other maintainers can't read them

- **Source:** 🔎 compliance reviewer — verified
- **Classification:** 🆕 NEW (this release re-aligned the Polish tables and added an English banner on top, but left the Polish text; the file dates from v2.0.3 and the comment from v2.4.0)
- **File:** [`MIGRATION_NOTES.md:11-395`](https://github.com/bitfocus/companion-module-pltech-kumatimer/blob/5aefc3938a26d3a6d22c9175e6b56a58799e99e3/MIGRATION_NOTES.md#L11-L395), [`src/actions.ts:414-415`](https://github.com/bitfocus/companion-module-pltech-kumatimer/blob/5aefc3938a26d3a6d22c9175e6b56a58799e99e3/src/actions.ts#L414-L415)

**What goes wrong:** Nothing changes in the Companion UI; the problem is for people working on the module. A maintainer, Bitfocus reviewer or contributor who doesn't read Polish opens `MIGRATION_NOTES.md` to learn why the module was built the way it is: why the connection settings fields are required, why cue and preset buttons aren't template presets, what the "S1" to "S10" surprise findings were. Almost all of it is in Polish ("Migrujemy pltech-kumatimer z ...", "Recon findings — co dotyka naszego kodu", table columns "Decyzja | Wybór | Implikacja"). Only the new banner at lines 3-9 is in English. The comment above the "Blackmagic Output On / Off" action also quotes a request in Polish. Every file in a module has to be in English so anyone who maintains or troubleshoots it can read it.

**Why it happens:** `MIGRATION_NOTES.md` is the author's own migration log, written in Polish and committed to the repo. This release rewrote every Polish table in it (Prettier re-alignment) and added the English banner, but kept the Polish text. The English rule covers the whole module, so the Polish comment in [`src/actions.ts:414-415`](https://github.com/bitfocus/companion-module-pltech-kumatimer/blob/5aefc3938a26d3a6d22c9175e6b56a58799e99e3/src/actions.ts#L414-L415), from an earlier release, is part of this finding too. The Polish parts of `MIGRATION_NOTES.md` are lines 11-395: the status, TL;DR, decision tables, recon tables, risk register, the S1-S10 findings and the day logs.

**Evidence:**

```markdown
<!-- MIGRATION_NOTES.md:11-16 (tracked file, per git ls-files) -->
> **Status:** Plan zlockowany 30 kwi 2026 wieczór. Implementation start: poniedziałek (Day 1).
> Cały recon zrobiony, decyzje podjęte, czekamy na pn rano.

## TL;DR

Migrujemy `pltech-kumatimer` z `@companion-module/base@~1.14.1` na **`^2.0.4`**. ~10-13h aktywnej roboty rozłożone na 5 dni roboczych. **70% breaking changes z oficjalnego guide nas nie dotyczy** — zostaje 13 must-fix punktów + opcjonalne refactoringi.
```

```markdown
<!-- MIGRATION_NOTES.md:22 and 31 -->
| #        | Decyzja                | Wybór                                                                   | Implikacja   ...
## Recon findings — co dotyka naszego kodu
```

```markdown
<!-- MIGRATION_NOTES.md:316-318 (S9; the same pattern runs through the day logs and the "Decyzje recap" table at 388-395) -->
**Decyzja:** zostawiam individual preset definitions (50 LOC overhead vs templates), labels pozostają dynamiczne. Udokumentowane w komentarzu `setupPresets()` header.
```

```ts
// src/actions.ts:413-415
		blackmagic_enable: {
			// RC2, 17 Sep 2026 (Pawel: "guzik do companion z START i STOP
			// Blackmagic output... lub toggle") — starts/stops "Live KUMA
```

```diff
# git diff v2.6.2..v2.7.0 -- MIGRATION_NOTES.md (excerpt): the release adds the English banner and re-aligns the Polish tables
+> ## Variable names are a contract (Dashboard presets read them)
-| # | Decyzja | Wybór | Implikacja |
+| #        | Decyzja                | Wybór                                                                   | Implikacja      ...
```

**Confirm by:** open [`MIGRATION_NOTES.md`](https://github.com/bitfocus/companion-module-pltech-kumatimer/blob/5aefc3938a26d3a6d22c9175e6b56a58799e99e3/MIGRATION_NOTES.md#L11-L395): lines 11 to 395 are Polish prose and tables (Status, TL;DR, "Decyzja | Wybór | Implikacja", "Recon findings — co dotyka naszego kodu", S1-S10, the day logs). Then open [`src/actions.ts:414-415`](https://github.com/bitfocus/companion-module-pltech-kumatimer/blob/5aefc3938a26d3a6d22c9175e6b56a58799e99e3/src/actions.ts#L414-L415) and find the Polish quote "guzik do companion z START i STOP ... lub toggle".

**Fix:** translate `MIGRATION_NOTES.md` into English, or remove it from the repo. It is a private migration log and also points at the author's local tooling (`~/family/contracts.md`, `python3 ~/family/bin/family.py`, `/tmp/api2-tsc-errors.log`), so moving the parts that still matter into English code comments or a short English CONTRIBUTING note may be simpler. Rewrite the comment in `src/actions.ts` in English, for example:

```ts
// RC2, 17 Sep 2026 (Pawel asked for a Companion button with START and STOP for the Blackmagic output, or a toggle)
```

## 📝 Additional Notes

- Follow-up to the [v2.6.2 review](review-pltech-kumatimer-v2.6.2-20261030-003407.md) (approved): none of its findings were changed in v2.7.0. Its M1 (workflow action versions) is carried forward as [NR1](#nr1-github-workflow-uses-older-checkout-and-setup-node-actions-than-the-template), for the next release. The rest stay open, unchanged and non-blocking, as listed below.
- v2.6.2 L1 is still open: Timer mode and TCR source buttons light up while KUMA Timer is offline ([`src/feedbacks.ts:149`](https://github.com/bitfocus/companion-module-pltech-kumatimer/blob/5aefc3938a26d3a6d22c9175e6b56a58799e99e3/src/feedbacks.ts#L149), [`src/feedbacks.ts:303`](https://github.com/bitfocus/companion-module-pltech-kumatimer/blob/5aefc3938a26d3a6d22c9175e6b56a58799e99e3/src/feedbacks.ts#L303)). It can be fixed together with [L2](#l2-blink-and-neon-look-buttons-light-up-while-kuma-timer-is-offline).
- v2.6.2 L2 is still open: a zero-length "Time Glide: finish in a set duration" still turns the connection red, because every non-OK command reply sets Connection Failure ([`src/main.ts:133-142`](https://github.com/bitfocus/companion-module-pltech-kumatimer/blob/5aefc3938a26d3a6d22c9175e6b56a58799e99e3/src/main.ts#L133-L142)).
- v2.6.2 L3 is still open: `ppt_slide_of` is still missing from `clearVariables()` ([`src/variables.ts:328-400`](https://github.com/bitfocus/companion-module-pltech-kumatimer/blob/5aefc3938a26d3a6d22c9175e6b56a58799e99e3/src/variables.ts#L328-L400)), so it keeps the last slide after KUMA Timer goes offline. The new `ppt_notes` / `ppt_notes_next` variables are cleared correctly.
- v2.6.2 N1 and N2 are still open: the layout feedback still shows both the Slot and the Name field, and option types are still unchecked (the new code repeats this, see [N2](#n2-new-opener-and-blink-actions-and-feedbacks-read-options-untyped)).

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | KUMA Timer hosts older than v1.21.0 (overtime blink) and v1.20.2 (opening animation) leave `blink_overtime` / `opener_look` out of `/api/status`, which is why the module falls back to "on" and "neon" | the module's own comments in [`src/types.ts:160-165`](https://github.com/bitfocus/companion-module-pltech-kumatimer/blob/5aefc3938a26d3a6d22c9175e6b56a58799e99e3/src/types.ts#L160-L165) and [`src/actions.ts:402-404`](https://github.com/bitfocus/companion-module-pltech-kumatimer/blob/5aefc3938a26d3a6d22c9175e6b56a58799e99e3/src/actions.ts#L402-L404); no host was tested. It shapes only the suggested fix, not the offline behaviour, which is confirmed in the code | [L2](#l2-blink-and-neon-look-buttons-light-up-while-kuma-timer-is-offline) |
