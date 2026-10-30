# Review: biamp-tesira v4.0.1

| | |
| --- | --- |
| **Module** | `companion-module-biamp-tesira` ([repo](https://github.com/bitfocus/companion-module-biamp-tesira)) |
| **Version** | v4.0.1 (`55f2bc2`, 2026-10-20) |
| **Release** | Update — last published v3.0.3 |
| **API** | 2.1 (base 2.1.3, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Previous tag** | v3.0.3 (`5aeb94f`, 2026-06-09) |
| **Scope** | tag (`v3.0.3..v4.0.1`) |
| **Language** | TypeScript |
| **Build** | `yarn install --immutable`, `yarn package` and `yarn lint` pass |
| **Review date** | 2026-10-30 |

This is a follow-up to the [v4.0.0 review](review-biamp-tesira-v4.0.0-20261006-202001.md). v4.0.0 was never published, so this release is still compared with v3.0.3. v4.0.1 fixes both blocking findings from that review (the upgrade scripts now read and write the Companion 5 `{ isExpression, value }` format, and the v4 subscription migration is its own script), plus M1–M4, M6, M7, L1, L2, L5 and N1–N4. Still open from v4.0.0: M5 (now [M2](#m2-the-compiler-no-longer-checks-actions-feedbacks-or-presets)), L3 (now [L1](#l1-meter-and-level-feedbacks-with-a-blank-instance-id-ignore-the-device-range); a tooltip was added) and the subscription-action part of L4 (now [M1](#m1-vu-meter-gauges-stick-at-full-scale-when-a-meters-instance-tag-has-no-meter-in-its-name)). The two blocking findings below were not in the v4.0.0 review because the TypeScript template moved to Node 26 on 2026-10-08 and added `release.yaml` on 2026-10-09, after that review.

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Companion does not fill in a new secret field's default value for connections that were created before the field existed | General Companion behaviour (upgrade scripts exist to fill such values); not verifiable from the module code | [L2](#l2-older-connections-now-log-in-with-an-empty-password-instead-of-default) |

## 📋 Issues

### Blocking

- [ ] [C1: Module runs on Node 22 instead of the Node 26 runtime of the Companion 5 template](#c1-module-runs-on-node-22-instead-of-the-node-26-runtime-of-the-companion-5-template)
- [ ] [H1: The CI workflow builds on Node 22 instead of Node 26](#h1-the-ci-workflow-builds-on-node-22-instead-of-node-26)

### Non-blocking

- [ ] [M1: VU meter gauges stick at full scale when a meter's instance tag has no meter in its name](#m1-vu-meter-gauges-stick-at-full-scale-when-a-meters-instance-tag-has-no-meter-in-its-name)
- [ ] [M2: The compiler no longer checks actions, feedbacks or presets](#m2-the-compiler-no-longer-checks-actions-feedbacks-or-presets)
- [ ] [M3: The release workflow from the template is missing](#m3-the-release-workflow-from-the-template-is-missing)
- [ ] [L1: Meter and level feedbacks with a blank instance ID ignore the device range](#l1-meter-and-level-feedbacks-with-a-blank-instance-id-ignore-the-device-range)
- [ ] [L2: Older connections now log in with an empty password instead of default](#l2-older-connections-now-log-in-with-an-empty-password-instead-of-default)
- [ ] [L3: Level range overrides separated by semicolons or new lines are silently dropped](#l3-level-range-overrides-separated-by-semicolons-or-new-lines-are-silently-dropped)
- [ ] [N1: Every single-value poll or subscription creates a duplicate variable](#n1-every-single-value-poll-or-subscription-creates-a-duplicate-variable)
- [ ] [N2: Fixed-choice dropdowns can be switched to expression mode](#n2-fixed-choice-dropdowns-can-be-switched-to-expression-mode)
- [ ] [N3: Hand-added meter feedbacks still draw bitmaps instead of native gauges](#n3-hand-added-meter-feedbacks-still-draw-bitmaps-instead-of-native-gauges)

---

## 🔴 Critical

### C1: Module runs on Node 22 instead of the Node 26 runtime of the Companion 5 template

- **Source:** 🤖 validate-template (MAN-RUNTIME)
- **Classification:** 🆕 NEW
- **File:** [`companion/manifest.json:35`](https://github.com/bitfocus/companion-module-biamp-tesira/blob/55f2bc2a0122a1775f0bb73bc908359bb9f48e57/companion/manifest.json#L35), [`tsconfig.build.json:2`](https://github.com/bitfocus/companion-module-biamp-tesira/blob/55f2bc2a0122a1775f0bb73bc908359bb9f48e57/tsconfig.build.json#L2)

**What goes wrong:** The module tells Companion to run it on Node 22, and it is compiled with the Node 22 TypeScript preset. Every API 2.1 (Companion 5) module made from the current template runs on Node 26, so this module runs on a different runtime from the reference it is supposed to match. That makes later problems harder to troubleshoot.

**Why it happens:** This release moved the module from the Companion 4 API (base `~1.14.1`) to the Companion 5 API (base `2.1.3`), but kept the Node 22 runtime in the manifest and the Node 22 preset in the build config. The template's API 2.1 branch now uses `node26` and `@companion-module/tools/tsconfig/node26/recommended.json`.

**Evidence:**

```text
companion/manifest.json:35   "type": "node22"                     (template: "node26")
tsconfig.build.json:2        "extends": "@companion-module/tools/tsconfig/node22/recommended-esm.json"
                             (template: "@companion-module/tools/tsconfig/node26/recommended.json")
```

**Confirm by:** `grep -n '"type": "node' companion/manifest.json` shows `node26`, and [`tsconfig.build.json:2`](https://github.com/bitfocus/companion-module-biamp-tesira/blob/55f2bc2a0122a1775f0bb73bc908359bb9f48e57/tsconfig.build.json#L2) extends the `node26/recommended.json` preset.

**Fix:** switch the manifest runtime to Node 26 and extend the template's Node 26 preset in the build config.

```json
"runtime": {
	"type": "node26",
```

```json
"extends": "@companion-module/tools/tsconfig/node26/recommended.json",
```

---

## 🟠 High

### H1: The CI workflow builds on Node 22 instead of Node 26

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.github/workflows/node.yaml:21-25`](https://github.com/bitfocus/companion-module-biamp-tesira/blob/55f2bc2a0122a1775f0bb73bc908359bb9f48e57/.github/workflows/node.yaml#L21-L25)

**What goes wrong:** The GitHub check that runs on every push builds and lints the module on Node 22, so it doesn't test the Node 26 runtime the module should run on (see [C1](#c1-module-runs-on-node-22-instead-of-the-node-26-runtime-of-the-companion-5-template)).

**Why it happens:** This release updated the workflow's checkout and setup-node actions to match the template, but left the Node version at 22.x. The commented-out test job has the same 22.x lines, and the file ends with two commented lines (a codecov step) that the template doesn't have.

**Evidence:**

```diff
--- companion-module-template-ts/.github/workflows/node.yaml
+++ .github/workflows/node.yaml
@@ -21 +21 @@
-      - name: Use Node.js 26.x
+      - name: Use Node.js 22.x
@@ -25 +25 @@
-          node-version: 26.x
+          node-version: 22.x
@@ -62 +62 @@
-  #     - name: Use Node.js 26.x
+  #     - name: Use Node.js 22.x
@@ -65 +65 @@
-  #         node-version: 26.x
+  #         node-version: 22.x
@@ -76,0 +77,2 @@
+  #     - name: Send coverage
+  #       uses: codecov/codecov-action@v5
```

**Confirm by:** `diff companion-module-template-ts/.github/workflows/node.yaml .github/workflows/node.yaml` prints nothing.

**Fix:** copy the template's `node.yaml` (Node 26.x, which matches the Node 26 runtime from C1).

---

## 🟡 Medium

### M1: VU meter gauges stick at full scale when a meter's instance tag has no meter in its name

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:565-574`](https://github.com/bitfocus/companion-module-biamp-tesira/blob/55f2bc2a0122a1775f0bb73bc908359bb9f48e57/src/actions.ts#L565-L574), [`src/main.ts:616-623`](https://github.com/bitfocus/companion-module-biamp-tesira/blob/55f2bc2a0122a1775f0bb73bc908359bb9f48e57/src/main.ts#L616-L623), [`src/main.ts:1043-1052`](https://github.com/bitfocus/companion-module-biamp-tesira/blob/55f2bc2a0122a1775f0bb73bc908359bb9f48e57/src/main.ts#L1043-L1052), [`src/main.ts:555-558`](https://github.com/bitfocus/companion-module-biamp-tesira/blob/55f2bc2a0122a1775f0bb73bc908359bb9f48e57/src/main.ts#L555-L558)

**What goes wrong:** A user drags the manual **VU meter** preset (or uses **Custom attribute subscription** with the **Audio Meter (Peak & RMS): level** template) and sets the instance tag to their real block, for example `Lobby_AM`. At -20 dB the gauge should be about 40% full (meter-scale index 4.8 of 12). Instead `$(biamp-tesira:manual_meter_1_scaled)` is overwritten with a level percentage (71.4 against the default -100 to 12 dB range), so the gauge, whose maximum is 12, shows full and red all the time. The module also polls `Lobby_AM get minLevel 1` and `get maxLevel 1`, which the meter block rejects, so **last_error** fills with errors. v4.0.1 fixed this for tags in **Always subscribe these VU meter instance tags**, but not for the subscription action.

**Why it happens:** The module only treats a subscription as a meter when the caller says so. The startup VU list now does, but the **Custom attribute subscription** action knows the chosen template is an Audio Meter and still doesn't pass that on. The module then guesses the type from the tag name, and any tag without "meter", "rms", "peak" or "vu" is treated as a level control. When a value arrives, the meter step writes `…_scaled` and the level step then writes the same variable again with a level percentage.

**Fix:** in the **Custom attribute subscription** callback, work out the type from the chosen template and pass it on (for example `kind: 'meter'` for the Audio Meter templates), and use the same type for `queueRangeProbeForInstance` instead of guessing from the tag name. As a safety net, skip the level `_scaled` write in `storeValueTokens` when the meter step has already written that variable.

### M2: The compiler no longer checks actions, feedbacks or presets

- **Source:** 🔎 QA reviewer, compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:35`](https://github.com/bitfocus/companion-module-biamp-tesira/blob/55f2bc2a0122a1775f0bb73bc908359bb9f48e57/src/actions.ts#L35), [`src/actions.ts:48`](https://github.com/bitfocus/companion-module-biamp-tesira/blob/55f2bc2a0122a1775f0bb73bc908359bb9f48e57/src/actions.ts#L48), [`src/feedbacks.ts:360`](https://github.com/bitfocus/companion-module-biamp-tesira/blob/55f2bc2a0122a1775f0bb73bc908359bb9f48e57/src/feedbacks.ts#L360), [`src/presets.ts:214-219`](https://github.com/bitfocus/companion-module-biamp-tesira/blob/55f2bc2a0122a1775f0bb73bc908359bb9f48e57/src/presets.ts#L214-L219), [`src/presets.ts:441`](https://github.com/bitfocus/companion-module-biamp-tesira/blob/55f2bc2a0122a1775f0bb73bc908359bb9f48e57/src/presets.ts#L441), [`src/main.ts:146-149`](https://github.com/bitfocus/companion-module-biamp-tesira/blob/55f2bc2a0122a1775f0bb73bc908359bb9f48e57/src/main.ts#L146-L149)

**What goes wrong:** Nothing visible today: the converted presets, gauges, feedback styles and advanced-feedback results all match the base 2.1.3 typings. But a later typo (an unknown gauge property, a preset pointing at a feedback id that doesn't exist, `useVariables` on a number field) would pass the build. Companion validates layered presets strictly, so such a mistake would only show up as a broken button in the Presets tab, for example the **07 VU Meters (Discovered)** presets drawing nothing. This was M5 in the v4.0.0 review and is unchanged.

**Why it happens:** The actions, feedbacks and presets are typed as `Record<string, any>` ("anything goes") instead of the library's definition types, and `ModuleTypes` only declares `config` and `secrets`. The presets are still written in the old v1 shape (`type: 'button'`, `category`) and converted at runtime by an untyped `convertPresetsForCompanion5()`, which is also why the API scan reports 59 v1 preset hits. Every entry does end up as `type: 'simple'` or `type: 'layered'` and is registered with `setPresetDefinitions(structure, presets)`. `tsconfig.build.json` also sets `noImplicitAny: false`.

**Fix:** declare the action and feedback schemas in `ModuleTypes`, type the definitions as `CompanionActionDefinitions<ModuleTypes['actions']>` and `CompanionFeedbackDefinitions<ModuleTypes['feedbacks']>`, and write the presets directly as `CompanionPresetDefinitions<ModuleTypes>` (`type: 'simple'` / `type: 'layered'`, no `category`). Then remove `convertPresetsForCompanion5()` and the `any` helpers.

### M3: The release workflow from the template is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.github/workflows/release.yaml` (missing)

**What goes wrong:** No user-visible effect. The template now ships a `release.yaml` GitHub workflow (added 2026-10-09), and the module doesn't have it.

**Fix:** copy the template's `.github/workflows/release.yaml`.

---

## 🟢 Low

### L1: Meter and level feedbacks with a blank instance ID ignore the device range

- **Source:** 🔎 QA reviewer, compliance reviewer
- **Classification:** 🔙 REGRESSION
- **File:** [`src/feedbacks.ts:52-56`](https://github.com/bitfocus/companion-module-biamp-tesira/blob/55f2bc2a0122a1775f0bb73bc908359bb9f48e57/src/feedbacks.ts#L52-L56), [`src/feedbacks.ts:77-91`](https://github.com/bitfocus/companion-module-biamp-tesira/blob/55f2bc2a0122a1775f0bb73bc908359bb9f48e57/src/feedbacks.ts#L77-L91)

**What goes wrong:** An existing v3 button has a **VU meter (vertical)** or **Level meter (horizontal)** feedback with **Value or variable** set to `$(biamp-tesira:Podium_Level_level_1)` and a blank **Instance ID for live range**. Under v3 the bar used the device's real range (for example -40 to 0 dB) or the **Level range overrides** entry. Under v4 it silently falls back to the feedback's **Minimum dB** / **Maximum dB** (-100 to 12), so a -10 dB level that showed 75% full now shows about 80%, and an override such as `Podium_Level=-40:0` is ignored. v4.0.1 added a tooltip explaining the blank-field behaviour, but no upgrade script fills in the instance ID for existing buttons.

**Why it happens:** v3 worked out the instance tag from the variable name in the source field. Companion 5 fills in variables before the feedback runs, so the source arrives as a number such as `-10`, and the code that reads the tag from `$(conn:var)` never matches. That code is now dead.

**Fix:** add a feedback upgrade script that fills in the instance ID from the raw source variable name when it is blank and the source is a plain `$(label:<tag>_level_1)` or `…_meter_1` value. Alternatively, mark the source fields `disableAutoExpression` and read them raw. Then remove `extractVariableId` / `inferAliasFromSource`, or keep them only for the upgrade.

### L2: Older connections now log in with an empty password instead of default

- **Source:** 🔎 QA reviewer
- **Classification:** 🔙 REGRESSION
- **File:** [`src/main.ts:850`](https://github.com/bitfocus/companion-module-biamp-tesira/blob/55f2bc2a0122a1775f0bb73bc908359bb9f48e57/src/main.ts#L850), [`src/main.ts:195`](https://github.com/bitfocus/companion-module-biamp-tesira/blob/55f2bc2a0122a1775f0bb73bc908359bb9f48e57/src/main.ts#L195), [`src/main.ts:211`](https://github.com/bitfocus/companion-module-biamp-tesira/blob/55f2bc2a0122a1775f0bb73bc908359bb9f48e57/src/main.ts#L211)

**What goes wrong:** A connection created before the **Login password** secret existed has no stored password. On a Tesira that prompts for login with the default credentials, v3 sent `default` and logged in. v4.0.1 sends an empty password, the login is rejected, and the connection shows an authentication failure until the user opens the connection settings and saves the password. Connections that have a saved password are not affected.

**Why it happens:** When this release made the password fallback consistent (v4.0.0 review N3), it changed the fallback from `'default'` to an empty string in all three places. That no longer matches the field's own default of `default` ([`src/config.ts:56`](https://github.com/bitfocus/companion-module-biamp-tesira/blob/55f2bc2a0122a1775f0bb73bc908359bb9f48e57/src/config.ts#L56)) or the username fallback, which is still `default`. No upgrade script fills in the missing secret (see A1).

**Fix:** use `'default'` as the fallback in `respondToLoginPrompt`, `init()` and `configUpdated()`, or add an upgrade script that sets `updatedSecrets: { loginPassword: 'default' }` when the secret is missing.

### L3: Level range overrides separated by semicolons or new lines are silently dropped

- **Source:** 🔎 QA reviewer
- **Classification:** 🔙 REGRESSION
- **File:** [`src/range-overrides.ts:6-28`](https://github.com/bitfocus/companion-module-biamp-tesira/blob/55f2bc2a0122a1775f0bb73bc908359bb9f48e57/src/range-overrides.ts#L6-L28)

**What goes wrong:** A user who entered `Lobby_Level=-80:12;Podium_Level=-40:0` in **Level range overrides** under v3 upgrades to v4. The whole string is now read as one invalid entry, so every override is dropped and the meter feedbacks and gauges go back to -100 to 12 dB without any warning. The CHANGELOG now mentions this, but no upgrade converts the value.

**Why it happens:** The new shared parser splits entries only on `,`, while the v3 feedback parser also accepted `;` and new lines.

**Fix:** add a config upgrade script that replaces `;` and new lines in `levelRangeOverrides` with `,`, or have `parseRangeOverrides` split on `/[,;\n]/`.

---

## 💡 Nice to Have

### N1: Every single-value poll or subscription creates a duplicate variable

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:1036-1041`](https://github.com/bitfocus/companion-module-biamp-tesira/blob/55f2bc2a0122a1775f0bb73bc908359bb9f48e57/src/main.ts#L1036-L1041)

**What goes wrong:** A poll such as `Level1 get minLevel 1` now creates both `$(biamp-tesira:Level1_minLevel_1)` and `$(biamp-tesira:Level1_minLevel_1_1)` with the same value, so the variable list in Companion fills up with redundant entries.

**Why it happens:** Indexed variables are now created for every reply, including replies with a single value. Before, they were only created when there were several values.

**Fix:** only create indexed variables when there is more than one value, or only for the meter sources that the native gauges read.

### N2: Fixed-choice dropdowns can be switched to expression mode

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:224`](https://github.com/bitfocus/companion-module-biamp-tesira/blob/55f2bc2a0122a1775f0bb73bc908359bb9f48e57/src/actions.ts#L224), [`src/actions.ts:304`](https://github.com/bitfocus/companion-module-biamp-tesira/blob/55f2bc2a0122a1775f0bb73bc908359bb9f48e57/src/actions.ts#L304), [`src/feedbacks.ts:387`](https://github.com/bitfocus/companion-module-biamp-tesira/blob/55f2bc2a0122a1775f0bb73bc908359bb9f48e57/src/feedbacks.ts#L387), [`src/feedbacks.ts:446`](https://github.com/bitfocus/companion-module-biamp-tesira/blob/55f2bc2a0122a1775f0bb73bc908359bb9f48e57/src/feedbacks.ts#L446), [`src/feedbacks.ts:504`](https://github.com/bitfocus/companion-module-biamp-tesira/blob/55f2bc2a0122a1775f0bb73bc908359bb9f48e57/src/feedbacks.ts#L504)

**What goes wrong:** Dropdowns such as the mute action's **State** (toggle / true / false), and the feedbacks' **Muted when value is**, **Comparison** and **Match mode**, show an expression toggle in the editor. A user who switches one to expression mode and types a value that isn't a choice id (for example `on`) gets an action or feedback that Companion silently skips. Users who keep the normal dropdown are not affected.

**Why it happens:** In Companion 5 every dropdown without `disableAutoExpression` can be switched to expression mode. Only `command` and `templateId` got `disableAutoExpression: true` in this release.

**Fix:** add `disableAutoExpression: true` to the fixed-choice dropdowns that make no sense as expressions, or add an `expressionDescription` listing the valid ids where expression input should stay.

### N3: Hand-added meter feedbacks still draw bitmaps instead of native gauges

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.ts:619-1990`](https://github.com/bitfocus/companion-module-biamp-tesira/blob/55f2bc2a0122a1775f0bb73bc908359bb9f48e57/src/feedbacks.ts#L619-L1990), [`src/feedbacks.ts:1993-2013`](https://github.com/bitfocus/companion-module-biamp-tesira/blob/55f2bc2a0122a1775f0bb73bc908359bb9f48e57/src/feedbacks.ts#L1993-L2013)

**What goes wrong:** No visible problem today. The presets already use Companion 5 native gauges, but a user who adds a meter feedback by hand (for example **Meter - VU Meter - Full Button**) still gets a pixel bitmap drawn by one of twelve advanced feedbacks. The Companion 5 library discourages advanced feedbacks, and they are likely to be removed in a future major version.

**Why it happens:** The release wraps the advanced feedbacks correctly for API 2.1 (`affectedProperties: ['imageBuffer']` and base64 encoding), but keeps the bitmap approach rather than moving to value feedbacks and gauge elements.

**Fix:** over time, replace the advanced meter feedbacks with value feedbacks that return the scaled number (or composite elements via `setCompositeElementDefinitions`), and use them as gauge `value` sources in layered presets.
