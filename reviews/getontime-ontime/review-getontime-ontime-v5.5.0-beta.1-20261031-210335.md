# Review: companion-module-getontime-ontime v5.5.0-beta.1 (follow-up to v5.4.2-beta.2)

| Field | Value |
| --- | --- |
| **Module** | `companion-module-getontime-ontime` |
| **Scope** | `tag` (v5.4.1..v5.5.0-beta.1) |
| **Version** | v5.5.0-beta.1 |
| **Release** | Update — last published v5.4.1 |
| **API** | 2.1 (base 2.1.3, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Prior review** | [v5.4.2-beta.2](review-getontime-ontime-v5.4.2-beta.2-20261030-003407.md) |
| **Commit** | [`cc8d404`](https://github.com/bitfocus/companion-module-getontime-ontime/tree/cc8d404e014d7a9522c738f499c568364f82ed80) |
| **Date** | 2026-10-31 |

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Most Companion installs have no custom variable named `ContourShuttleRing`, and an expression that refers to a custom variable that doesn't exist gives no usable speed (undefined, empty or an error) | The name points to the maintainer's own Contour Shuttle setup; nothing in the module defines it or mentions it in HELP.md. Companion's expression evaluation was not checked against the host code | [M2](#m2-turning-a-dial-with-the-change-teleprompter-speed-preset-does-not-change-the-speed) |
| A2 | Ontime sends the `all` refetch in normal use, for example when a different project is loaded, so the custom fields can change on that refresh | The module's own `all` handler re-fetches the custom fields, which suggests the maintainer expects them to change. When Ontime actually sends it was not checked against the Ontime server | [M3](#m3-after-ontime-sends-a-full-refresh-the-custom-field-feedback-and-presets-still-show-the-old-projects-fields) |
| A3 | A message action that the old 5.2.0 upgrade script skipped is still stored by Companion under its old action id, or as a "Message control" action with no properties, so a newly appended upgrade script would still receive it and could repair it | Companion stores only the actions an upgrade script returns (confirmed host behaviour). How Companion keeps an action whose id no longer exists in the module's definitions is not visible from the module code | [M4](#m4-users-who-already-upgraded-keep-their-broken-message-buttons-and-server-address-because-the-fix-edits-upgrade-scripts-that-already-ran) |

## 📋 Issues

### Blocking

- [ ] [C1: Yarn is set to accept dependencies from any git repository, a setting the template does not have](#c1-yarn-is-set-to-accept-dependencies-from-any-git-repository-a-setting-the-template-does-not-have)

### Non-blocking

- [ ] [M1: The CI workflow is named node.yml where the template uses node.yaml](#m1-the-ci-workflow-is-named-nodeyml-where-the-template-uses-nodeyaml)
- [ ] [M2: Turning a dial with the Change Teleprompter Speed preset does not change the speed](#m2-turning-a-dial-with-the-change-teleprompter-speed-preset-does-not-change-the-speed)
- [ ] [M3: After Ontime sends a full refresh, the Custom Field feedback and presets still show the old project's fields](#m3-after-ontime-sends-a-full-refresh-the-custom-field-feedback-and-presets-still-show-the-old-projects-fields)
- [ ] [M4: Users who already upgraded keep their broken message buttons and server address, because the fix edits upgrade scripts that already ran](#m4-users-who-already-upgraded-keep-their-broken-message-buttons-and-server-address-because-the-fix-edits-upgrade-scripts-that-already-ran)
- [ ] [L1: The Scroll Teleprompter preset scrolls 4 lines back but only 1 line forward](#l1-the-scroll-teleprompter-preset-scrolls-4-lines-back-but-only-1-line-forward)
- [ ] [L2: Typos and three different names for the same setting in the new teleprompter labels](#l2-typos-and-three-different-names-for-the-same-setting-in-the-new-teleprompter-labels)
- [ ] [L3: The new teleprompter dropdowns can be switched to expression mode, unlike the module's other toggle options](#l3-the-new-teleprompter-dropdowns-can-be-switched-to-expression-mode-unlike-the-modules-other-toggle-options)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🔴 Critical

### C1: Yarn is set to accept dependencies from any git repository, a setting the template does not have

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW (added in this release by f2f655a "chore: match template")
- **File:** [`.yarnrc.yml:1-2`](https://github.com/bitfocus/companion-module-getontime-ontime/blob/cc8d404e014d7a9522c738f499c568364f82ed80/.yarnrc.yml#L1-L2)

**What goes wrong:** The module's Yarn settings no longer match the template's. The extra setting approves dependencies fetched from every git repository (`'**'`), something no other template-based module allows, and it makes the module's install behave differently from the reference when someone troubleshoots it later. The module has no git dependencies, so the setting isn't needed.

**Why it happens:** This release brought `.yarnrc.yml` in line with the template (the `@getontime/*` pre-approval from the prior review is now commented out), but it also added an `approvedGitRepositories` key at the top. The template's `.yarnrc.yml` has only `enableScripts`, `nodeLinker`, `npmMinimalAgeGate` and `npmPreapprovedPackages`, and all four match.

**Evidence:** validator reports "Extra keys not in template: approvedGitRepositories".

```yaml
# .yarnrc.yml:1-2
approvedGitRepositories:
  - '**'
```

**Fix:** remove the `approvedGitRepositories` key so the file matches the template. The commented-out `# - "@getontime/*"` line can stay.

```yaml
enableScripts: false

nodeLinker: node-modules

npmMinimalAgeGate: 3d

npmPreapprovedPackages:
  - '@companion-module/*'
```

## 🟡 Medium

### M1: The CI workflow is named node.yml where the template uses node.yaml

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW (the workflow was added in this release)
- **File:** [`.github/workflows/node.yml`](https://github.com/bitfocus/companion-module-getontime-ontime/blob/cc8d404e014d7a9522c738f499c568364f82ed80/.github/workflows/node.yml)

**What goes wrong:** The template's CI workflow `.github/workflows/node.yaml` is reported missing. The module ships the same workflow under the name `node.yml`, so a later bulk update of template files from Bitfocus would add a second, duplicate workflow instead of replacing this one.

**Why it happens:** The file's content is identical to the template's `node.yaml`; only the extension differs.

**Fix:** rename `.github/workflows/node.yml` to `.github/workflows/node.yaml`.

### M2: Turning a dial with the Change Teleprompter Speed preset does not change the speed

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/presets.ts:936-970`](https://github.com/bitfocus/companion-module-getontime-ontime/blob/cc8d404e014d7a9522c738f499c568364f82ed80/src/presets.ts#L936-L970)

**What goes wrong:** A user drags the new Teleprompter > "Change Teleprompter Speed" preset onto a Stream Deck+ dial and turns it. Turning left and turning right do exactly the same thing: both run "Set Speed Teleprompter" with the speed taken from a custom variable called `ContourShuttleRing`, which almost nobody has (it looks like a leftover from the maintainer's Contour Shuttle setup). The speed is never set to a useful value, and because "Auto Start" is on, each turn just sends "play". The user can't step the speed from, say, 14 to 15 lines per minute, even though the module has a "Change Speed Teleprompter" action for exactly that.

**Why it happens:** Both rotate steps of the preset use the "Set Speed Teleprompter" action (`TeleprompterSetSpeed`) with the speed as the expression `$(custom:ContourShuttleRing)`, instead of "Change Speed Teleprompter" (`TeleprompterChangeSpeed`) with a negative step for left and a positive step for right.

**Fix:** use "Change Speed Teleprompter" with `speedBy: -1` on `rotate_left` and `speedBy: 1` on `rotate_right` (or another small step), and remove the `$(custom:ContourShuttleRing)` reference. If a shuttle-ring preset is wanted too, give it its own name and document the custom variable it needs in HELP.md.

```ts
rotate_left: [{ actionId: ActionId.TeleprompterChangeSpeed, options: { speedBy: -1 } }],
rotate_right: [{ actionId: ActionId.TeleprompterChangeSpeed, options: { speedBy: 1 } }],
```

### M3: After Ontime sends a full refresh, the Custom Field feedback and presets still show the old project's fields

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/connection.ts:49-63`](https://github.com/bitfocus/companion-module-getontime-ontime/blob/cc8d404e014d7a9522c738f499c568364f82ed80/src/connection.ts#L49-L63)

**What goes wrong:** An operator loads a different project in Ontime whose custom fields are different (for example "Presenter" and "Camera" instead of "Lighting"). When Ontime announces this with its full (`all`) refresh, the module updates its variables and actions, but the "Custom Field" feedback's dropdown still lists the old fields, and Presets > Custom Fields still shows "Current event custom field: Lighting" buttons. The new fields only appear after a custom-fields refresh or a reconnect.

**Why it happens:** The new `all` branch stores the new custom fields and then refreshes only the action and variable definitions. The `custom-fields` branch right below it, changed in the same release, also refreshes the feedback definitions and the presets, with a comment explaining why. The `all` branch skips those two steps.

**Fix:** in the `all` branch, after the events are fetched, also refresh the feedbacks and presets, as the `custom-fields` branch does. Moving the shared steps into one helper that both branches call keeps them from drifting apart again.

```ts
this.state.applyPendingFeedbackDefinition()
this.module.setPresetDefinitions(...generatePresets(this.state.customFields, this.label))
```

### M4: Users who already upgraded keep their broken message buttons and server address, because the fix edits upgrade scripts that already ran

- **Source:** 🔎 compliance reviewer + QA reviewer
- **Classification:** 🆕 NEW (still open from the v5.4.2-beta.2 review, where it was M3)
- **File:** [`src/upgrades.ts:74-84`](https://github.com/bitfocus/companion-module-getontime-ontime/blob/cc8d404e014d7a9522c738f499c568364f82ed80/src/upgrades.ts#L74-L84), [`src/upgrades.ts:171-188`](https://github.com/bitfocus/companion-module-getontime-ontime/blob/cc8d404e014d7a9522c738f499c568364f82ed80/src/upgrades.ts#L171-L188), [`src/actions/message.ts:208-266`](https://github.com/bitfocus/companion-module-getontime-ontime/blob/cc8d404e014d7a9522c738f499c568364f82ed80/src/actions/message.ts#L208-L266)

**What goes wrong:** HELP.md says "Fixed migration of configs from module version 4 and of message actions from before 5.2" ([`companion/HELP.md:53`](https://github.com/bitfocus/companion-module-getontime-ontime/blob/cc8d404e014d7a9522c738f499c568364f82ed80/companion/HELP.md#L53)), but the fix only reaches someone upgrading straight from an older version. Anyone who already ran module 5.0.0 to 5.4.1 keeps the old result: an old "Timer Blink" or "Set Message" button left at its default option was skipped by the 5.2.0 migration and stays broken, and a v4 config whose port was dropped keeps an "Ontime server address" of `http://192.168.1.10` instead of `http://192.168.1.10:4001`.

**Why it happens:** Companion runs each upgrade script only once per connection and records how many it has run. The corrections were written into two scripts that already shipped: the v4 config conversion `update5` (position 5 in `upgradeScripts`) and `upgrade_collectMessageActions` (position 10). Connections that already passed those positions never run them again, and no new script was added at the end of the list.

**Fix:** keep the corrected script bodies for fresh upgrades, and append a new script at the end of `upgradeScripts` that repairs what the old versions left behind. `ActionUpdater(upgrade_collectMessageActions)` can be appended again as-is: it only matches the legacy action ids, so re-running it is safe. Optionally add a step that fills in default properties on a "Message control" action left with none. A script can't recover the lost v4 port, so add a line to HELP.md asking users who came from v4 to check that the server address includes the port.

```ts
	ActionUpdater(upgrade_ensureAddRemoveTimeDefaultValue),
	ActionUpdater(upgrade_collectMessageActions), // re-run for connections the old 5.2.0 script skipped
]
```

## 🟢 Low

### L1: The Scroll Teleprompter preset scrolls 4 lines back but only 1 line forward

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/presets.ts:908-934`](https://github.com/bitfocus/companion-module-getontime-ontime/blob/cc8d404e014d7a9522c738f499c568364f82ed80/src/presets.ts#L908-L934)

**What goes wrong:** On a Stream Deck+ dial, one click left on the new "Scroll Teleprompter" preset scrolls the script back 4 lines, but one click right moves it forward only 1 line. An operator nudging the script back and forth by the same number of clicks doesn't end up where they started.

**Why it happens:** The left step uses `scroll: -4` and the right step `scroll: 1`. If the faster rewind is intended, nothing explains it.

**Fix:** use the same step size both ways (for example `-1` and `1`), or say in the preset name or HELP.md that left rewinds faster.

### L2: Typos and three different names for the same setting in the new teleprompter labels

- **Source:** 🔎 compliance reviewer + QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions/teleprompter.ts:58`](https://github.com/bitfocus/companion-module-getontime-ontime/blob/cc8d404e014d7a9522c738f499c568364f82ed80/src/actions/teleprompter.ts#L58), [`src/feedbacks/teleprompter.ts:78`](https://github.com/bitfocus/companion-module-getontime-ontime/blob/cc8d404e014d7a9522c738f499c568364f82ed80/src/feedbacks/teleprompter.ts#L78), [`src/variables.ts:43-45`](https://github.com/bitfocus/companion-module-getontime-ontime/blob/cc8d404e014d7a9522c738f499c568364f82ed80/src/variables.ts#L43-L45), [`companion/HELP.md:23`](https://github.com/bitfocus/companion-module-getontime-ontime/blob/cc8d404e014d7a9522c738f499c568364f82ed80/companion/HELP.md#L23)

**What goes wrong:** Users see small text errors, and the same teleprompter setting under three names. Nothing breaks, but the labels are harder to understand:

- The "Auto Start" tooltip of "Set Speed Teleprompter" says "it wil automatically start".
- In the feedback picker, "Teleprompter is holding at end" has the description "Indicator colour for teleprompter hold mode", copied from "Teleprompter Mode", so the two can't be told apart.
- The variable `teleprompter_ended` is named "Teleprompter is holding at end of", which stops mid-sentence.
- The setting is "Stop Mode" in the action, "Teleprompter Mode" in the feedback and "hold mode" in the variable.
- HELP.md says the module will "stop retying the connection, manually restart it". Since this release, saving the connection settings also retries.

**Fix:**

- "wil" → "will"; "retying" → "retrying".
- Give "Teleprompter is holding at end" its own description, e.g. "Indicator colour while the teleprompter is holding at the end of an event or the script".
- Rename the variable to e.g. "Teleprompter holding at end of (event/script)".
- Pick one name for the mode across the action, feedback and variable.
- In HELP.md, mention that saving the connection settings also retries.

### L3: The new teleprompter dropdowns can be switched to expression mode, unlike the module's other toggle options

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions/teleprompter.ts:24-34`](https://github.com/bitfocus/companion-module-getontime-ontime/blob/cc8d404e014d7a9522c738f499c568364f82ed80/src/actions/teleprompter.ts#L24-L34), [`src/actions/teleprompter.ts:109-119`](https://github.com/bitfocus/companion-module-getontime-ontime/blob/cc8d404e014d7a9522c738f499c568364f82ed80/src/actions/teleprompter.ts#L109-L119), [`src/feedbacks/teleprompter.ts:34-43`](https://github.com/bitfocus/companion-module-getontime-ontime/blob/cc8d404e014d7a9522c738f499c568364f82ed80/src/feedbacks/teleprompter.ts#L34-L43), [`src/feedbacks/teleprompter.ts:59-68`](https://github.com/bitfocus/companion-module-getontime-ontime/blob/cc8d404e014d7a9522c738f499c568364f82ed80/src/feedbacks/teleprompter.ts#L59-L68), [`src/feedbacks/teleprompter.ts:84-94`](https://github.com/bitfocus/companion-module-getontime-ontime/blob/cc8d404e014d7a9522c738f499c568364f82ed80/src/feedbacks/teleprompter.ts#L84-L94)

**What goes wrong:** In "Play/Pause/Toggle Teleprompter", "Set Teleprompter Stop Mode" and the three teleprompter feedbacks, the Action / Teleprompter Mode / State dropdown has an expression toggle. If a user switches it on and types a value that isn't one of the exact choice ids (`play`, `pause`, `toggle`, `event`, `script`, `any`), Companion skips the action or feedback without any message. The module's existing toggle-style options turn this off (for example [`src/actions/message.ts:54`](https://github.com/bitfocus/companion-module-getontime-ontime/blob/cc8d404e014d7a9522c738f499c568364f82ed80/src/actions/message.ts#L54)), so the new options behave differently.

**Why it happens:** On API 2.x every option except a text input gets an expression toggle unless it sets `disableAutoExpression: true`, and the new dropdowns don't.

**Fix:** add `disableAutoExpression: true` to these five dropdowns, as the module's other toggle-style options do. Do it in this beta: once users have saved expressions in these fields, turning the toggle off breaks their buttons.

## 📝 Additional Notes

- Follow-up to the [v5.4.2-beta.2 review](review-getontime-ontime-v5.4.2-beta.2-20261030-003407.md). Fixed in this release: C1 (`.gitattributes`), C2 (`.gitignore`), C3 (`.husky/pre-commit`), C4 (`.prettierignore`), C5 (`@getontime/*` pre-approval, now commented out), C6 (`postinstall` script), C7 (`companion` keyword), C8 (Node 26 runtime and tsconfig preset), M1 (issue forms added), L1 (HELP.md now explains that a "Bad configuration" error stops retrying, and saving the settings reconnects).
- Prior M2 (CI and release workflows) is mostly fixed: `release.yaml` was added and `build.yml` replaced; only the `node.yml` file name remains ([M1](#m1-the-ci-workflow-is-named-nodeyml-where-the-template-uses-nodeyaml)).
- Prior M3 (edited upgrade scripts) is still open and carried forward as [M4](#m4-users-who-already-upgraded-keep-their-broken-message-buttons-and-server-address-because-the-fix-edits-upgrade-scripts-that-already-ran).
