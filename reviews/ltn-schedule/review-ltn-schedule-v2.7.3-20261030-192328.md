# Review: companion-module-ltn-schedule v2.7.3 (follow-up)

| Field | Value |
| --- | --- |
| **Module** | [companion-module-ltn-schedule](https://github.com/bitfocus/companion-module-ltn-schedule) |
| **Scope** | `tag` (v2.6.0..v2.7.3) |
| **Version** | v2.7.3 (`89801bd`) |
| **Release** | Update — last published v2.6.0 |
| **API** | 2.0 (base 2.0.4, yarn.lock) — requires Companion 4.3+ |
| **Template** | `companion-module-template-js-v2.0.4` @ `e4caa76` (2026-08-28, pinned) |
| **Follow-up to** | [v2.7.2 review](review-ltn-schedule-v2.7.2-20261030-003407.md) — all 9 prior findings fixed (see [📝 Additional Notes](#-additional-notes)) |
| **Reviewed** | 2026-10-30 |

## Verdict: ✅ Approved

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | For an action option with no saved value (a number field without `default`), Companion 4.3 either passes `undefined` to the callback or refuses the action as invalid; it does not substitute 0 | The v2.0 compliance reference says a missing value fails with "A value must be provided"; Companion's validator for the non-expression, missing-value case was not read | [M2](#m2-start-timestamp-and-element-index-options-can-send-timestampundefined-or-be-refused) |
| A2 | Companion 4.3 checks plain (non-expression) dropdown values against the choices and refuses the action when a single-select dropdown gets an array. If it compares loosely, `['abc'] == 'abc'` passes and the presets keep working | The v2.0 compliance reference describes "Value is not in the list of choices" and "Failed to parse action options" as host behaviour; the exact comparison Companion uses was not inspected | [M1](#m1-graphics-layer-presets-may-do-nothing-because-they-pass-a-list-to-a-single-choice-dropdown) |

## 📋 Issues

### Non-blocking

- [ ] [M1: Graphics layer presets may do nothing because they pass a list to a single-choice dropdown](#m1-graphics-layer-presets-may-do-nothing-because-they-pass-a-list-to-a-single-choice-dropdown)
- [ ] [M2: Start timestamp and Element Index options can send timestamp=undefined or be refused](#m2-start-timestamp-and-element-index-options-can-send-timestampundefined-or-be-refused)
- [ ] [L1: Push Targets and Breaking Live presets can overwrite each other](#l1-push-targets-and-breaking-live-presets-can-overwrite-each-other)
- [ ] [L2: Upgrade script lives in main.js instead of a separate upgrades file](#l2-upgrade-script-lives-in-mainjs-instead-of-a-separate-upgrades-file)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟡 Medium

### M1: Graphics layer presets may do nothing because they pass a list to a single-choice dropdown

- **Source:** 🔎 compliance reviewer
- **Classification:** 🔙 REGRESSION
- **File:** [`src/presets.js:834-841`](https://github.com/bitfocus/companion-module-ltn-schedule/blob/89801bde6b934baf2dbc7c45f7827fd85e7dc555/src/presets.js#L834-L841)

**What goes wrong:** Every preset under Presets > Graphics > Graphics Layers runs the action "Set graphics layer status". Its "Graphics rundown element" option is a single-choice dropdown, but the preset fills it with a list holding one element id instead of the id itself. If Companion 4.3 checks the value against the dropdown's choices (see [A2](#-assumptions-to-confirm)), pressing a button made from one of these presets does nothing (the action is refused with "Failed to parse action options"), and opening the action shows an invalid selection in the dropdown.

**Why it happens:** Under the v1 base the list was quietly turned into text (`'?index=' + ['abc']` gives `?index=abc`), so the presets worked. The v2 migration converted the presets to the new `type: 'simple'` format but kept the old list value, while the action's field at [`src/actions.js:549-556`](https://github.com/bitfocus/companion-module-ltn-schedule/blob/89801bde6b934baf2dbc7c45f7827fd85e7dc555/src/actions.js#L549-L556) is a plain `dropdown`, not a `multidropdown`.

**Fix:** pass the element id itself, not a list. The callback already builds `?index=` from the value, so nothing else needs to change.

```js
options: {
	rundownElement: element.id,
	status: 'toggle',
},
```

### M2: Start timestamp and Element Index options can send timestamp=undefined or be refused

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.js:45-52`](https://github.com/bitfocus/companion-module-ltn-schedule/blob/89801bde6b934baf2dbc7c45f7827fd85e7dc555/src/actions.js#L45-L52), [`src/actions.js:485-489`](https://github.com/bitfocus/companion-module-ltn-schedule/blob/89801bde6b934baf2dbc7c45f7827fd85e7dc555/src/actions.js#L485-L489), [`src/feedback.js:459-463`](https://github.com/bitfocus/companion-module-ltn-schedule/blob/89801bde6b934baf2dbc7c45f7827fd85e7dc555/src/feedback.js#L459-L463)

**What goes wrong:** A user adds "Toggle playback running" from the action list (not from a preset) and leaves "Start timestamp" empty. Playout should start now, but the module sends `playout/start?timestamp=undefined` to Schedule. If Companion instead refuses the empty number (see [A1](#-assumptions-to-confirm)), the action doesn't run at all. The "Element Index" option of the action "Jump to an element" and of the feedback "Element playing status" have the same gap. The bundled presets avoid it because they fill in `startstamp: 0` and `index: '0'`.

**Why it happens:** Under API 2.0 a `number` option has to declare `default`, `min` and `max` (the base 2.0.4 `CompanionInputFieldNumber` typing requires all three). "Start timestamp" only has `min: 0`, and both "Element Index" fields have none of them. The v1-to-v2 migration removed `required: false` without adding the missing properties, and a JS module has no type check to catch it. With no default, the callback's test `opt.startstamp != '' && opt.startstamp != 0` is true for `undefined`, so `undefined` ends up in the URL.

**Fix:** give each number field a `default`, `min` and `max`, and only send a timestamp when it's above 0.

```js
// Start timestamp
{ type: 'number', label: 'Start timestamp', id: 'startstamp', default: 0, min: 0, max: Number.MAX_SAFE_INTEGER, range: false },
// Element Index (action and feedback)
{ id: 'index', type: 'number', label: 'Element Index', default: 0, min: 0, max: 100000, asInteger: true },
// playback_toggle callback
cmd = opt.startstamp > 0 ? '?timestamp=' + opt.startstamp : '?timestamp=NOW'
```

## 🟢 Low

### L1: Push Targets and Breaking Live presets can overwrite each other

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/presets.js:69-112`](https://github.com/bitfocus/companion-module-ltn-schedule/blob/89801bde6b934baf2dbc7c45f7827fd85e7dc555/src/presets.js#L69-L112), [`src/presets.js:474-541`](https://github.com/bitfocus/companion-module-ltn-schedule/blob/89801bde6b934baf2dbc7c45f7827fd85e7dc555/src/presets.js#L474-L541)

**What goes wrong:** When a Breaking Live livestream has the same id as a push target, the "BL" preset replaces the push target preset. Both the Push Targets and Breaking Live sections then show the same "BL" button, so dragging the push target preset gives a button that toggles breaking live instead. This happens for certain right after connecting to an API 5+ server: until the target and livestream lists arrive, both hold a placeholder with id `fill`, so both sections briefly show "BL fill". It fixes itself once the real lists arrive. Whether real Schedule ids can collide was not checked.

**Why it happens:** Push target presets are stored under the raw target id, and since this release Breaking Live presets are stored under the raw livestream id (`useId: live.id`) in the same presets object. In v2.6.0 they were stored under their name (`BL <label>`), which kept them apart. Graphics presets already avoid this with a `graphics-rundown-` prefix. The livestream preset also carries a stray `useId` property that is not part of a preset definition.

**Fix:** prefix each family's preset keys, use the same prefix in the section's `definitions`, and keep the key in a local variable instead of a `useId` property.

```js
presets['target-' + target.id] = targetPreset
definitions: this.data.targets.map((t) => 'target-' + t.id),

presets['breaking-live-' + live.id] = livePreset
definitions: this.data.livestreams.map((l) => 'breaking-live-' + l.id),
```

### L2: Upgrade script lives in main.js instead of a separate upgrades file

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:176-217`](https://github.com/bitfocus/companion-module-ltn-schedule/blob/89801bde6b934baf2dbc7c45f7827fd85e7dc555/src/main.js#L176-L217)

**What goes wrong:** Users see no difference; this is code organisation. The new playback-status upgrade script (which correctly unwraps the 2.x `{ isExpression, value }` options) sits in the entry file next to the instance class. The template keeps upgrade scripts in `src/upgrades.js`, where later scripts are easier to append without reordering or deleting one by accident.

**Why it happens:** The fix for the prior review's M2 replaced the library helper with a hand-written function and `export const UpgradeScripts = [...]` inside `src/main.js`.

**Fix:** move `convertPlaybackStatusToBoolean` and the `UpgradeScripts` array into `src/upgrades.js`, import it in `src/main.js` and re-export it. Keep the script at index 0.

```js
// src/main.js
import { UpgradeScripts } from './upgrades.js'
export { UpgradeScripts }
```

## 📝 Additional Notes

- Prior review C1 fixed: `approvedGitRepositories` removed from [`.yarnrc.yml`](https://github.com/bitfocus/companion-module-ltn-schedule/blob/89801bde6b934baf2dbc7c45f7827fd85e7dc555/.yarnrc.yml).
- Prior review C2 fixed: `index.js` moved to [`src/main.js`](https://github.com/bitfocus/companion-module-ltn-schedule/blob/89801bde6b934baf2dbc7c45f7827fd85e7dc555/src/main.js); `package.json` `main` and the manifest `entrypoint` updated.
- Prior review C3 fixed: [`.gitignore`](https://github.com/bitfocus/companion-module-ltn-schedule/blob/89801bde6b934baf2dbc7c45f7827fd85e7dc555/.gitignore) now has `/*.tgz`, `DEBUG-*` and `/.yarn`.
- Prior review C4 fixed: [`.gitattributes`](https://github.com/bitfocus/companion-module-ltn-schedule/blob/89801bde6b934baf2dbc7c45f7827fd85e7dc555/.gitattributes) added with the template's content.
- Prior review H1 fixed: Clear graphics engine, Start all and Stop all graphics layers (and every other callback) now start with `let cmd = ''`, so the request is sent.
- Prior review M1 fixed: [`src/variables.js:41`](https://github.com/bitfocus/companion-module-ltn-schedule/blob/89801bde6b934baf2dbc7c45f7827fd85e7dc555/src/variables.js#L41) only computes played time when the start time is set.
- Prior review M2 fixed: the playback-status upgrade script now reads `.value` from wrapped options and skips expressions ([`src/main.js:180-215`](https://github.com/bitfocus/companion-module-ltn-schedule/blob/89801bde6b934baf2dbc7c45f7827fd85e7dc555/src/main.js#L180-L215)).
- Prior review L1 fixed: the Toggle PGM Recording preset's feedback now passes `options: {}`.
- Prior review L2 fixed: the dead `parseVariablesInString` branch in Reconfigure connection is removed.
- `validate-template.ps1 -RunBuild` is clean for v2.7.3, and `yarn install --immutable` plus `yarn package` succeed.
