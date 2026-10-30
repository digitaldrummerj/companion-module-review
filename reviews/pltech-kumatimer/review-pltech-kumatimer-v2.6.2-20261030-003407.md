# Review: pltech-kumatimer v2.6.2 (follow-up to the v2.1.0 review)

| | |
| --- | --- |
| **Module** | pltech-kumatimer |
| **Scope** | `tag` (the `v2.4.0..v2.6.2` diff: 19 files, +1886/-75) |
| **Version** | v2.6.2 (previous tag v2.4.0) |
| **Release** | Update — last published v2.4.0 |
| **API** | 2.0 (base 2.0.4, yarn.lock) — requires Companion 4.3+ |
| **Template** | `companion-module-template-ts-v2.0.4` @ `d62230e` (2026-08-28, pinned) |
| **Commit** | [`c51c0b6`](https://github.com/bitfocus/companion-module-pltech-kumatimer/tree/c51c0b6cdb5fa81404c08779497e5453d7c87f76) |
| **Prior review** | [v2.1.0 (2026-06-14)](review-pltech-kumatimer-v2.1.0-20260614-220611.md) — every finding in it is fixed (see [📝 Additional Notes](#-additional-notes)) |
| **Reviewed** | 2026-10-30 |

This release adds Time Glide / Time Jump actions, source-neutral TCR (QLab, Mitti, Millumin, KumaPoint) feedbacks and variables, PowerPoint variables, display-mode and layout feedbacks, and a new `src/tcr.ts`. `yarn install --immutable`, `yarn package` and `yarn lint` all pass. The blocking items are template-compliance checks on files this release did not touch.

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | KUMA Timer answers HTTP 400 to "Time Glide: finish in a set duration" with a zero duration, and possibly to "Time Glide: cancel" / "Time Jump: cancel" when nothing is running | the module's own comment at [`src/actions.ts:290-294`](https://github.com/bitfocus/companion-module-pltech-kumatimer/blob/c51c0b6cdb5fa81404c08779497e5453d7c87f76/src/actions.ts#L290-L294); the host itself was not tested | [L2](#l2-a-zero-length-time-glide-turns-the-connection-red) |

## 📋 Issues

### Blocking

- [ ] [H1: LICENSE copyright line differs from the template](#h1-license-copyright-line-differs-from-the-template)

### Non-blocking

- [ ] [M1: GitHub workflow uses an older checkout action than the template](#m1-github-workflow-uses-an-older-checkout-action-than-the-template)
- [ ] [L1: Timer mode and TCR source buttons light up while KUMA Timer is offline](#l1-timer-mode-and-tcr-source-buttons-light-up-while-kuma-timer-is-offline)
- [ ] [L2: A zero-length Time Glide turns the connection red](#l2-a-zero-length-time-glide-turns-the-connection-red)
- [ ] [L3: PowerPoint slide-of variable keeps the old slide after KUMA Timer goes offline](#l3-powerpoint-slide-of-variable-keeps-the-old-slide-after-kuma-timer-goes-offline)
- [ ] [N1: Layout feedback shows both the Slot and the Name field](#n1-layout-feedback-shows-both-the-slot-and-the-name-field)
- [ ] [N2: New actions and feedbacks read options untyped](#n2-new-actions-and-feedbacks-read-options-untyped)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟠 High

### H1: LICENSE copyright line differs from the template

- **Source:** 🤖 validate-template (LICENSE-DIFF)
- **Classification:** ⚠️ Pre-existing — not in this release's diff (changed in v2.1.1)
- **File:** [`LICENSE:3`](https://github.com/bitfocus/companion-module-pltech-kumatimer/blob/c51c0b6cdb5fa81404c08779497e5453d7c87f76/LICENSE#L3)

**What goes wrong:** Users see no effect. The module's `LICENSE` no longer matches the template that every Companion module ships with.

**Why it happens:** v2.1.1 replaced the template's copyright line with the maintainer's company.

**Evidence:**

```text
line 3: found    'Copyright (c) 2026 PL TECH Ltd'
        template 'Copyright (c) 2022 Bitfocus AS - Open Source'
```

**Fix:** restore the template's `LICENSE` file unchanged.

## 🟡 Medium

### M1: GitHub workflow uses an older checkout action than the template

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** ⚠️ Pre-existing — not in this release's diff (the template moved to v7 since the module copied it)
- **File:** [`.github/workflows/node.yaml:18`](https://github.com/bitfocus/companion-module-pltech-kumatimer/blob/c51c0b6cdb5fa81404c08779497e5453d7c87f76/.github/workflows/node.yaml#L18)

**What goes wrong:** Users see no effect. The lint workflow pins `actions/checkout@v4` where the template now uses `actions/checkout@v7`.

**Why it happens:** The workflow was copied from an older template and not refreshed.

**Fix:** copy `.github/workflows/node.yaml` from the current template (`- uses: actions/checkout@v7`).

## 🟢 Low

### L1: Timer mode and TCR source buttons light up while KUMA Timer is offline

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.ts:302-303`](https://github.com/bitfocus/companion-module-pltech-kumatimer/blob/c51c0b6cdb5fa81404c08779497e5453d7c87f76/src/feedbacks.ts#L302-L303), [`src/feedbacks.ts:148-149`](https://github.com/bitfocus/companion-module-pltech-kumatimer/blob/c51c0b6cdb5fa81404c08779497e5453d7c87f76/src/feedbacks.ts#L148-L149)

**What goes wrong:** An operator uses the new "Switch to Timer mode" preset, which carries the "Display mode is … (TIMER / CLOCK)" feedback set to Timer, or a button with "TCR: selected source is …" set to Off. When KUMA Timer stops answering, the connection turns red, yet the TIMER MODE button stays lit as if the timer were in Timer mode, and the "Source = Off" button lights up. The buttons show a known state while the host is offline.

**Why it happens:** After a failed poll the module clears its saved status to an empty object ([`src/main.ts:103`](https://github.com/bitfocus/companion-module-pltech-kumatimer/blob/c51c0b6cdb5fa81404c08779497e5453d7c87f76/src/main.ts#L103)). Both feedbacks fill in a default when the field is missing (`'TIMER'` for the display mode, `'off'` for the TCR source), so the default value matches the button's option.

**Fix:** return false when the field is missing. If the default is there for older hosts that don't send the field, apply it only when a status has actually been received.

```ts
callback: (feedback) => {
	const m = lastStatus().display_mode
	return m !== undefined && String(m).toUpperCase() === String(feedback.options['mode'])
},
```

Do the same for `tcr_source`.

### L2: A zero-length Time Glide turns the connection red

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:290-322`](https://github.com/bitfocus/companion-module-pltech-kumatimer/blob/c51c0b6cdb5fa81404c08779497e5453d7c87f76/src/actions.ts#L290-L322), [`src/main.ts:133-142`](https://github.com/bitfocus/companion-module-pltech-kumatimer/blob/c51c0b6cdb5fa81404c08779497e5453d7c87f76/src/main.ts#L133-L142)

**What goes wrong:** An operator sets "Time Glide: finish in a set duration" to Hours 0, Minutes 0, Seconds 0 and presses the button. The host rejects it (HTTP 400, per the module's own comment, see [A1](#-assumptions-to-confirm)), and the connection shows red "Connection Failure: HTTP 400" until the next poll (500 ms by default). Nothing tells the operator that the action's input was the problem. The same can happen with "Time Glide: cancel" or "Time Jump: cancel" when nothing is running.

**Why it happens:** The new actions send whatever the number fields contain. The command helper treats every non-OK reply as a connection failure, although the new code's comment says a 400 here only means the command was a no-op.

**Fix:** skip the send and log a warning when hours, minutes and seconds are all 0. For an HTTP 400 from `/api/command`, log a warning and leave the connection status alone, so the red status stays reserved for 401 and network errors.

### L3: PowerPoint slide-of variable keeps the old slide after KUMA Timer goes offline

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/variables.ts:309-358`](https://github.com/bitfocus/companion-module-pltech-kumatimer/blob/c51c0b6cdb5fa81404c08779497e5453d7c87f76/src/variables.ts#L309-L358)

**What goes wrong:** A button shows `$(pltech-kumatimer:ppt_slide_of)` as "19/115" during a show. If KUMA Timer stops answering, every other PowerPoint variable resets (slide goes to 0, file and builds go blank), but this button keeps showing "19/115" until the host comes back. Before the first successful poll the variable has no value at all.

**Why it happens:** v2.6.x adds the `ppt_slide_of` variable to the definitions ([`src/variables.ts:160`](https://github.com/bitfocus/companion-module-pltech-kumatimer/blob/c51c0b6cdb5fa81404c08779497e5453d7c87f76/src/variables.ts#L160)) and to the update path ([`src/variables.ts:251`](https://github.com/bitfocus/companion-module-pltech-kumatimer/blob/c51c0b6cdb5fa81404c08779497e5453d7c87f76/src/variables.ts#L251)), but not to `clearVariables()`. It is the only defined variable that is missing there.

**Fix:** add `ppt_slide_of: ''` to `clearVariables()`, next to `ppt_slide_total: '0'` at line 346.

## 💡 Nice to Have

### N1: Layout feedback shows both the Slot and the Name field

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.ts:305-335`](https://github.com/bitfocus/companion-module-pltech-kumatimer/blob/c51c0b6cdb5fa81404c08779497e5453d7c87f76/src/feedbacks.ts#L305-L335)

**What goes wrong:** In "Layout preset is the active one", a user who picks Match by = Name still sees the "Slot (1 = first)" field, and Match by = Slot number still shows "Preset name". The labels say which one applies, so nothing breaks, but the editor is cluttered. The "Match by" dropdown can also be switched to expression mode, which makes no sense for a mode selector.

**Why it happens:** Neither field sets `isVisibleExpression`, and the "Match by" dropdown doesn't set `disableAutoExpression`.

**Fix:** add `disableAutoExpression: true` to the "Match by" dropdown (`mode`), then `isVisibleExpression: "$(options:mode) == 'slot'"` on `slot` and `isVisibleExpression: "$(options:mode) == 'name'"` on `name`. Under API 2.0 a visibility expression may only reference fields that have `disableAutoExpression` set, so the first step is required.

### N2: New actions and feedbacks read options untyped

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:295-335`](https://github.com/bitfocus/companion-module-pltech-kumatimer/blob/c51c0b6cdb5fa81404c08779497e5453d7c87f76/src/actions.ts#L295-L335)

**What goes wrong:** Users see no effect (pure code quality). The new Time Glide actions and the new TCR, PowerPoint, Time Glide and layout feedbacks take `options: Record<string, unknown>` and convert with `Number()` / `String()` / `as string`, so a renamed or mistyped option id would compile and quietly read `undefined`.

**Why it happens:** `KumaTypes` in `src/types.ts` declares only `config` and `secrets`, with no `actions` / `feedbacks` schema, so option ids can't be type-checked. The new code follows the module's existing pattern.

**Fix:** optionally add `actions` and `feedbacks` schemas to `KumaTypes` so the callbacks get typed options and the conversions can go.

## 📝 Additional Notes

- Follow-up to the [v2.1.0 review](review-pltech-kumatimer-v2.1.0-20260614-220611.md): all of its findings are fixed in v2.6.2. C1–C14 (template files, `.gitignore`, `.prettierignore`, `package.json` fields, scripts, devDependencies and `lint-staged`) no longer show up in the template check. H1 is fixed by the `backfillPassword` upgrade script in [`src/upgrades.ts`](https://github.com/bitfocus/companion-module-pltech-kumatimer/blob/c51c0b6cdb5fa81404c08779497e5453d7c87f76/src/upgrades.ts). H2 is fixed (`yarn lint` passes). M1 is fixed (cue presets are capped at `CUE_SLOTS` in [`src/presets.ts:249`](https://github.com/bitfocus/companion-module-pltech-kumatimer/blob/c51c0b6cdb5fa81404c08779497e5453d7c87f76/src/presets.ts#L249)). M2 is fixed (a failed command now sets Connection Failure, with "Auth failed — check the password" for a 401, in [`src/main.ts:133-142`](https://github.com/bitfocus/companion-module-pltech-kumatimer/blob/c51c0b6cdb5fa81404c08779497e5453d7c87f76/src/main.ts#L133-L142)).
- The two template findings (H1, M1) are in files this release did not change. The checkout version only differs because the template moved to v7.
