# Review: pltech-kumatimer v2.5.0 (follow-up)

| | |
| --- | --- |
| **Module** | pltech-kumatimer |
| **Version** | v2.5.0 |
| **Release** | Update — last published v2.4.0 |
| **API** | 2.0 (base 2.0.4, yarn.lock) — requires Companion 4.3+ |
| **Template** | `companion-module-template-ts-v2.0.4` @ `d62230e` (2026-08-28, pinned) |
| **Scope** | `tag` (the `v2.4.0..v2.5.0` diff) |
| **Review commit** | [`6f9a8f9`](https://github.com/bitfocus/companion-module-pltech-kumatimer/commit/6f9a8f9678543770d2845a547a49ee80a278929a) |
| **Previous review** | [v2.1.0 (2026-06-14)](review-pltech-kumatimer-v2.1.0-20260614-220611.md) |
| **Reviewed** | 2026-10-30 |

This is a follow-up to the v2.1.0 review. Every finding from that review is fixed (see [📝 Additional Notes](#-additional-notes)). The build, `yarn package` and `yarn lint` all pass. The remaining blocking item is one template difference that came in with v2.1.1 and was not covered by the last review.

## Verdict: ❌ Changes Required

## 📋 Issues

### Blocking

- [ ] [H1: LICENSE copyright line differs from the template](#h1-license-copyright-line-differs-from-the-template)

### Non-blocking

- [ ] [M1: GitHub lint workflow uses an older checkout action than the template](#m1-github-lint-workflow-uses-an-older-checkout-action-than-the-template)
- [ ] [L1: Timer mode buttons and the TCR Off feedback light up while KUMA Timer is offline](#l1-timer-mode-buttons-and-the-tcr-off-feedback-light-up-while-kuma-timer-is-offline)
- [ ] [N1: Active layout feedback always shows both the Slot and the Name field](#n1-active-layout-feedback-always-shows-both-the-slot-and-the-name-field)
- [ ] [N2: New flag and count variables are stored as text in expressions](#n2-new-flag-and-count-variables-are-stored-as-text-in-expressions)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟠 High

### H1: LICENSE copyright line differs from the template

- **Source:** 🤖 validate-template (LICENSE-DIFF)
- **Classification:** 🆕 NEW (not in the last review: changed in v2.1.1, unchanged in v2.5.0)
- **File:** [`LICENSE:3`](https://github.com/bitfocus/companion-module-pltech-kumatimer/blob/6f9a8f9678543770d2845a547a49ee80a278929a/LICENSE#L3)

**What goes wrong:** The module's `LICENSE` file does not match the template's license text, which Companion modules are expected to ship unchanged.

**Why it happens:** The copyright line was rewritten to name the module's author instead of keeping the template's line.

**Evidence:**

```text
LICENSE line 3
  found:    Copyright (c) 2026 PL TECH Ltd
  template: Copyright (c) 2022 Bitfocus AS - Open Source
```

**Confirm by:** open [`LICENSE:3`](https://github.com/bitfocus/companion-module-pltech-kumatimer/blob/6f9a8f9678543770d2845a547a49ee80a278929a/LICENSE#L3) and compare it with the template's `LICENSE`.

**Fix:** restore the template's `LICENSE` file as it is.

## 🟡 Medium

### M1: GitHub lint workflow uses an older checkout action than the template

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW (not in the last review: the file is unchanged since v1.8.0, and the template has since moved to `actions/checkout@v7`)
- **File:** [`.github/workflows/node.yaml:18`](https://github.com/bitfocus/companion-module-pltech-kumatimer/blob/6f9a8f9678543770d2845a547a49ee80a278929a/.github/workflows/node.yaml#L18)

**What goes wrong:** The repository's GitHub lint workflow checks out the code with `actions/checkout@v4`. The template uses `actions/checkout@v7`. Nothing in Companion changes, but the workflow drifts from the template and runs on an older action.

**Why it happens:** The workflow file was copied from an earlier template and has not been updated since.

**Fix:** copy the template's `.github/workflows/node.yaml`, or change line 18 to `- uses: actions/checkout@v7`.

## 🟢 Low

### L1: Timer mode buttons and the TCR Off feedback light up while KUMA Timer is offline

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.ts:148`](https://github.com/bitfocus/companion-module-pltech-kumatimer/blob/6f9a8f9678543770d2845a547a49ee80a278929a/src/feedbacks.ts#L148), [`src/feedbacks.ts:183`](https://github.com/bitfocus/companion-module-pltech-kumatimer/blob/6f9a8f9678543770d2845a547a49ee80a278929a/src/feedbacks.ts#L183)

**What goes wrong:** When the KUMA Timer host can't be reached, the connection shows Connection Failure. The new "Switch to Timer mode" preset still turns green, as if the timer were confirmed to be in Timer mode. A "TCR: selected source is …" feedback set to Off also lights up. An operator glancing at the surface sees a confirmed-looking state that comes from defaults, not from the timer. The effect is cosmetic, and the connection status already shows the failure.

**Why it happens:** When a poll fails, the module clears its stored status to an empty object and re-checks all feedbacks ([`src/main.ts:100-104`](https://github.com/bitfocus/companion-module-pltech-kumatimer/blob/6f9a8f9678543770d2845a547a49ee80a278929a/src/main.ts#L100-L104)). The "Display mode is … (TIMER / CLOCK)" and "TCR: selected source is …" feedbacks fill a missing value with `'TIMER'` and `'off'`, so those defaults match.

```ts
// src/feedbacks.ts:148
String(lastStatus().tcr_source ?? 'off').toLowerCase() === String(feedback.options['source']),
// src/feedbacks.ts:183
String(lastStatus().display_mode ?? 'TIMER').toUpperCase() === String(feedback.options['mode']),
```

**Fix:** return false when the field is missing, and do the same for `tcr_source` (or default to `'off'` only while the host is reachable).

```ts
const m = lastStatus().display_mode
return m !== undefined && m.toUpperCase() === String(feedback.options['mode'])
```

## 💡 Nice to Have

### N1: Active layout feedback always shows both the Slot and the Name field

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.ts:185-212`](https://github.com/bitfocus/companion-module-pltech-kumatimer/blob/6f9a8f9678543770d2845a547a49ee80a278929a/src/feedbacks.ts#L185-L212)

**What goes wrong:** A user adds the new "Layout preset is the active one" feedback to a button and sees three fields: "Match by", "Slot (1 = first)" and "Preset name". Both the Slot and the Name field stay visible whichever match mode is picked. With "Match by" set to Name, the Slot field still shows 1 even though it is ignored. Nothing breaks, and the labels explain which field is used, so this is UI polish only.

**Why it happens:** The Slot and Name options have no visibility rule. On API 2.0, an option's `isVisibleExpression` can only refer to a field that has `disableAutoExpression: true`, and the "Match by" dropdown doesn't set it. The feedback copies the layout of the existing "Recall Layout Preset" action.

**Fix:** add `disableAutoExpression: true` to the `mode` dropdown, then show each field only for its mode. Optionally make the same change in the "Recall Layout Preset" action so the two stay consistent.

```ts
{ type: 'dropdown', id: 'mode', /* … */ disableAutoExpression: true },
{ type: 'number', id: 'slot', /* … */ isVisibleExpression: "$(options:mode) == 'slot'" },
{ type: 'textinput', id: 'name', /* … */ isVisibleExpression: "$(options:mode) == 'name'" },
```

### N2: New flag and count variables are stored as text in expressions

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/variables.ts:204-230`](https://github.com/bitfocus/companion-module-pltech-kumatimer/blob/6f9a8f9678543770d2845a547a49ee80a278929a/src/variables.ts#L204-L230)

**What goes wrong:** A user builds a trigger or an expression from the new variables, for example `$(kumatimer:time_glide_active) == true` or `$(kumatimer:ppt_slide) > 3`. The values are the text `'true'`/`'false'` and `'3'`, not a real true/false or number, so `== true` is never true and the user has to write `== 'true'` instead. Button text looks the same either way, and the module's older variables (such as `qlab_hold` and `sms_active`) already behave like this.

**Why it happens:** The code that sets and clears the variables wraps every new flag and count in `String(...)`, for example `time_glide_active: String(data.warp_active ?? false)` and `ppt_slide: String(data.ppt?.slide ?? 0)`. On API 2.0 a variable value can be any JSON value, so true/false and numbers can be stored as they are.

**Fix:** for the new variables (`omt_*`, `ltc_generator_*`, `ltc_chase_*`, `dsan_rx_active`, `blackmagic_active`, `tcr_following`, `time_glide_active`, `time_jump_active`, `ppt_slide`, `ppt_slide_total`, `ppt_builds_remaining`), set the raw value in both `updateVariables` and `clearVariables`, e.g. `time_glide_active: data.warp_active ?? false` and `ppt_slide: data.ppt?.slide ?? 0`. This is optional, and best done together with the existing variables so the module stays consistent.

## 📝 Additional Notes

- Every finding from the [v2.1.0 review](review-pltech-kumatimer-v2.1.0-20260614-220611.md) is fixed: the template packaging items C1–C14 (`tsconfig.build.json`, `.gitignore`, `.prettierignore`, `license`, the `postinstall` / `build:main` / `lint:raw` scripts, `husky` / `lint-staged` / `rimraf`, the `lint-staged` section) no longer show up in the validator.
- Prior H1 is fixed: an upgrade script now fills in an empty `password` for connections saved before the field existed ([`src/upgrades.ts:9-26`](https://github.com/bitfocus/companion-module-pltech-kumatimer/blob/6f9a8f9678543770d2845a547a49ee80a278929a/src/upgrades.ts#L9-L26)).
- Prior H2 is fixed: `yarn lint` passes.
- Prior M1 is fixed: cue presets are capped at the 12 cue slots that have variables ([`src/presets.ts:246-249`](https://github.com/bitfocus/companion-module-pltech-kumatimer/blob/6f9a8f9678543770d2845a547a49ee80a278929a/src/presets.ts#L246-L249)).
- Prior M2 is fixed: a rejected command, including a wrong password (HTTP 401), now sets the connection to Connection Failure with "Auth failed — check the password" ([`src/main.ts:131-140`](https://github.com/bitfocus/companion-module-pltech-kumatimer/blob/6f9a8f9678543770d2845a547a49ee80a278929a/src/main.ts#L131-L140)).
