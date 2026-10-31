# Review: tow-mixeffect v2.1.1 (follow-up to v2.1.0)

| | |
| --- | --- |
| **Module** | [companion-module-tow-mixeffect](https://github.com/bitfocus/companion-module-tow-mixeffect) |
| **Scope** | `tag` (v2.0.6..v2.1.1) |
| **Version** | v2.1.1 (`0d886e7`) |
| **Release** | Update — last published v2.0.6 |
| **API** | 1 (base 1.14.1, yarn.lock) |
| **Template** | `companion-module-template-js-v1` @ `9e222b4` (2026-03-26, pinned) · `.yarnrc.yml` from `companion-module-template-js` @ `76d25b2` (2026-10-11) |
| **Previous review** | [v2.1.0](review-tow-mixeffect-v2.1.0-20261030-090507.md) (2026-10-30, ❌ Changes Required): all 12 blocking findings fixed |
| **Review date** | 2026-10-31 |

## Verdict: ✅ Approved

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | With `@companion-module/base` 1.14, each `setVariableValues()` call is its own message to Companion, so about 14,600 single calls cost noticeably more than one batched call | General knowledge of the base 1.x IPC wrapper; not measured against a running Companion | [L1](#l1-picking-the-new-atem-4-me-constellation-4k-plus-model-or-changing-model-sends-about-14600-separate-variable-updates) |

## 📋 Issues

### Non-blocking

- [ ] [L1: Picking the new ATEM 4 M/E Constellation 4K Plus model, or changing model, sends about 14,600 separate variable updates](#l1-picking-the-new-atem-4-me-constellation-4k-plus-model-or-changing-model-sends-about-14600-separate-variable-updates)
- [ ] [L2: Hidden spacer fields in action editors use a deprecated way to stay hidden](#l2-hidden-spacer-fields-in-action-editors-use-a-deprecated-way-to-stay-hidden)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟢 Low

### L1: Picking the new ATEM 4 M/E Constellation 4K Plus model, or changing model, sends about 14,600 separate variable updates

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/variables.js:1224-1242`](https://github.com/bitfocus/companion-module-tow-mixeffect/blob/0d886e7c3dd9846d5beda104c5d8899b45b77bab/src/variables.js#L1224-L1242), [`src/index.js:80-82`](https://github.com/bitfocus/companion-module-tow-mixeffect/blob/0d886e7c3dd9846d5beda104c5d8899b45b77bab/src/index.js#L80-L82)

**What goes wrong:** A user picks the Model "ATEM 4 M/E Constellation 4K Plus" (new in this release) and saves, or switches an existing connection from one model to another. For the 4K Plus the module defines 14,615 variables (up from 11,407 for the plain 4K) and sets each starting value with a separate update. In a local run, setting up the variables alone took about 190 ms and made 14,615 separate update calls, before any cost of sending them to Companion. With "Feedback Polling" on at a 500 ms interval, every poll also updates variables one at a time. Companion may lag briefly at startup and when the model changes, and the module may keep using noticeable CPU while it polls a 4K Plus. Nothing is functionally wrong. Before this release a model change never rebuilt the variables, so that part of the cost is new.

**Why it happens:** After defining the variables, the module walks the whole list and sets each default value on its own. Each single update first searches the full definition list for the variable, then sends one value to Companion. The release adds a model with a much larger variable set, and now also rebuilds the variables when the model changes.

**Fix:** look up definitions in a map instead of searching the list, and send all default values in one call. Do the same for each poll in `updateState` (the TODO at [`src/polling.js:40`](https://github.com/bitfocus/companion-module-tow-mixeffect/blob/0d886e7c3dd9846d5beda104c5d8899b45b77bab/src/polling.js#L40) already plans this).

```js
// in initVariables, after setVariableDefinitions
this.variableDefinitionMap = new Map(this.variableDefinitions.map((d) => [d.variableId, d]))
const values = {}
const feedbackIds = new Set()
for (const { variableId, defaultValue, storeId, feedbackId } of this.variableDefinitions) {
	values[variableId] = defaultValue
	if (storeId) this.store.variables[storeId] = defaultValue
	if (feedbackId) feedbackIds.add(feedbackId)
}
this.setVariableValues(values)
if (feedbackIds.size) this.checkFeedbacks(...feedbackIds)
```

### L2: Hidden spacer fields in action editors use a deprecated way to stay hidden

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions/utils.js:121-127`](https://github.com/bitfocus/companion-module-tow-mixeffect/blob/0d886e7c3dd9846d5beda104c5d8899b45b77bab/src/actions/utils.js#L121-L127)

**What goes wrong:** Users see no difference today: the blank spacer field used by several actions is still hidden in Companion 4.2. A later base or Companion update may stop honouring the old hiding method, and an empty, unlabeled field would then appear in those action editors.

**Why it happens:** The spacer is a static-text field hidden with an `isVisible` function. `@companion-module/base` deprecated `isVisible` functions in 1.12 in favour of `isVisibleExpression`. The line itself did not change, but this release moves the module from base ~1.8.0 to ~1.14.1, so the deprecation now applies.

**Fix:** hide the spacer with an expression instead. You could also drop the spacer field entirely, because base 1.14 lays out option fields automatically.

```js
empty: (id = 'blank') => ({
	type: 'static-text',
	id: id,
	label: '',
	value: '',
	isVisibleExpression: 'false',
}),
```

## 📝 Additional Notes

- All 12 blocking findings of the [v2.1.0 review](review-tow-mixeffect-v2.1.0-20261030-090507.md) are fixed: the module installs and builds on Node 22 with Yarn 4 (C1–C3), the manifest runtime is `node22` (C4), `.gitattributes` and `.yarnrc.yml` were added (C5, C6), `.gitignore` and `.prettierignore` match the template (C7, C8), `package.json` has the `engines` and `prettier` fields and the `format` script (C9–C11), and the extra Node 18 test job was moved out of `companion-module-checks.yaml` into its own Node 22 / Yarn 4 workflow, [`.github/workflows/module-tests.yaml`](https://github.com/bitfocus/companion-module-tow-mixeffect/blob/0d886e7c3dd9846d5beda104c5d8899b45b77bab/.github/workflows/module-tests.yaml) (H1).
