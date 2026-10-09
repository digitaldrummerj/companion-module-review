# Review: biamp-tesira v4.0.0

| | |
| --- | --- |
| **Module** | `companion-module-biamp-tesira` ([repo](https://github.com/bitfocus/companion-module-biamp-tesira)) |
| **Version** | v4.0.0 (`cce0e0b`, 2026-08-30) |
| **Previous tag** | v3.0.3 (`5aeb94f`, 2026-06-09) |
| **Scope:** | tag (`v3.0.3..v4.0.0`) |
| **Language** | TypeScript |
| **Template** | `companion-module-template-ts` @ `d62230e` (2026-08-28, main, fresh) |
| **API** | 2.1 (base 2.1.3, yarn.lock) — requires Companion 5.0+ |
| **Build** | `yarn install`, `yarn package` and `yarn lint` pass |
| **Review date** | 2026-10-06 |

This release moves the module from the Companion 4 module API (v1, base `~1.14.1`) to the Companion 5 module API (2.1, base `2.1.3`). Every finding below is new in this release or a regression caused by it.

## Verdict: ❌ Changes Required

## 📋 Issues

### Blocking

- [ ] [C1: Hold-to-adjust buttons stop working after upgrading an old config](#c1-hold-to-adjust-buttons-stop-working-after-upgrading-an-old-config)
- [ ] [C2: Old subscribe-parameter buttons stop working after the upgrade](#c2-old-subscribe-parameter-buttons-stop-working-after-the-upgrade)

### Non-blocking

- [ ] [M1: Level gauges show the wrong fill after a reconnect or a tag refresh](#m1-level-gauges-show-the-wrong-fill-after-a-reconnect-or-a-tag-refresh)
- [ ] [M2: Custom attribute subscription buttons from v3 stop working](#m2-custom-attribute-subscription-buttons-from-v3-stop-working)
- [ ] [M3: Meter buttons made from v3 presets show an unknown Subscription template](#m3-meter-buttons-made-from-v3-presets-show-an-unknown-subscription-template)
- [ ] [M4: Some presets get invalid text sizes](#m4-some-presets-get-invalid-text-sizes)
- [ ] [M5: Type checking was switched off for actions, feedbacks and presets](#m5-type-checking-was-switched-off-for-actions-feedbacks-and-presets)
- [ ] [M6: The new upgrade tests do not use the data Companion 5 actually sends](#m6-the-new-upgrade-tests-do-not-use-the-data-companion-5-actually-sends)
- [ ] [M7: The CI workflow uses an older checkout action](#m7-the-ci-workflow-uses-an-older-checkout-action)
- [ ] [L1: Leftover no-op parseVariablesInString helper](#l1-leftover-no-op-parsevariablesinstring-helper)
- [ ] [L2: Device data ending in user or password can be mistaken for a login prompt](#l2-device-data-ending-in-user-or-password-can-be-mistaken-for-a-login-prompt)
- [ ] [L3: Hand-built meter feedbacks ignore the device range when Instance tag is blank](#l3-hand-built-meter-feedbacks-ignore-the-device-range-when-instance-tag-is-blank)
- [ ] [L4: A VU meter tag without meter in its name gets the wrong scaled value](#l4-a-vu-meter-tag-without-meter-in-its-name-gets-the-wrong-scaled-value)
- [ ] [L5: Preset sections appear out of order and their ids shift](#l5-preset-sections-appear-out-of-order-and-their-ids-shift)
- [ ] [N1: A wrong password leaves the connection on Connecting forever](#n1-a-wrong-password-leaves-the-connection-on-connecting-forever)
- [ ] [N2: The connection status briefly loses its explanation](#n2-the-connection-status-briefly-loses-its-explanation)
- [ ] [N3: The password fallback differs between startup and saving the config](#n3-the-password-fallback-differs-between-startup-and-saving-the-config)
- [ ] [N4: Level range overrides are re-read on every level update](#n4-level-range-overrides-are-re-read-on-every-level-update)

---

## 🔴 Critical

### C1: Hold-to-adjust buttons stop working after upgrading an old config

- **Source:** 🔎 compliance reviewer — verified
- **Classification:** 🔙 REGRESSION
- **File:** [`src/upgrades.ts:67-73`](https://github.com/bitfocus/companion-module-biamp-tesira/blob/cce0e0b32e922f3f46e01a5625decafb31697b69/src/upgrades.ts#L67-L73)

**What goes wrong:** A user on module v2.x or earlier has a button that raises a fader while it's held (the old "increment fader level with timer" action, set to repeat every 250 ms). After installing v4.0.0, the button is converted to the new **Start hold level adjustment** action, but its **Repeat interval (ms)** shows **0** instead of 250, and pressing it does nothing. Companion logs "Failed to parse action options. One or more options were invalid" with the button's location, and **Repeat interval (ms)** reports "A value must be provided". The button stays broken until the user opens it and re-enters the interval. Every hold button carried over from v2.x is affected. Users already on v3.x are not, because Companion runs each upgrade script only once per connection and they ran this one when they installed v3.

**Why it happens:** When a module version renames actions or options, it ships an *upgrade script* that Companion runs once on each saved button to rename them. In the Companion 4 API that script saw each option as a plain value (`250`). In the Companion 5 API that this release moves to, Companion hands the script every option as a small object holding the value and an "is this an expression?" flag: `{ isExpression: false, value: 250 }`. The script's overall approach is correct: it renames the action and options in place and returns the action, and Companion saves it. The problem is only the interval conversion, which wasn't updated for the object form. It tries to turn the whole object into a number, gets "not a number", falls back to `500`, and saves a bare `500` instead of the expected object. Companion stores what the script returns unchanged. Companion reads the setting's `.value` and gets nothing from a bare number, so the editor shows the interval as 0, and when the button runs Companion rejects the option as missing and refuses to run the action ([Companion `ChildHandlerNew.ts`](https://github.com/bitfocus/companion/blob/b615afd3be310f84d77877aa3806bda428332541/companion/lib/Instance/Connection/ChildHandlerNew.ts#L382-L398)).

**Evidence:**

```ts
// src/upgrades.ts:67-73
		case 'level_hold_start':
			changed = renameOption(options, 'rate', 'intervalMs') || changed
			if (options.intervalMs !== undefined) {
				const interval = Number(options.intervalMs)
				options.intervalMs = Number.isFinite(interval) ? interval : 500
				changed = true
			}
```

```ts
// node_modules/@companion-module/base/dist/module-api/upgrade.d.ts:58-60
export type CompanionMigrationOptionValues = {
    [key: string]: ExpressionOrValue<JsonValue | undefined> | undefined;
};
```

Running the module's built `dist/upgrades.js` on one of these buttons, in the shape Companion stores it:

```text
BEFORE options.rate        = {"isExpression":false,"value":250}
AFTER  actionId            = level_hold_start
AFTER  options.intervalMs  = 500        (bare, not wrapped)
AFTER  options.instanceTag = {"isExpression":false,"value":"Lobby_Level"}   (wrapped correctly)
When the button runs, Companion reads intervalMs.value -> undefined -> "A value must be provided"
```

Reproduced in Companion 5 by importing a biamp v2.1.0 page and switching the connection to v4.0.0: the hold button's **Repeat interval (ms)** shows 0, and the subscription button's **Subscription template** (C2) is blank.

**Confirm by:** open [`src/upgrades.ts:70-71`](https://github.com/bitfocus/companion-module-biamp-tesira/blob/cce0e0b32e922f3f46e01a5625decafb31697b69/src/upgrades.ts#L70-L71). `Number()` is applied to the whole option object, not to its `.value`.

**Fix:** read the number out of `.value`, leave expressions alone, and save the result back in the same object shape.

```ts
const opt = options.intervalMs as ExpressionOrValue<JsonValue> | undefined
if (opt && !opt.isExpression) {
	const interval = Number(opt.value)
	options.intervalMs = { isExpression: false, value: Number.isFinite(interval) ? interval : 500 }
	changed = true
}
```

The helpers `renameOption` and `stringifyOption` ([`src/upgrades.ts:29-42`](https://github.com/bitfocus/companion-module-biamp-tesira/blob/cce0e0b32e922f3f46e01a5625decafb31697b69/src/upgrades.ts#L29-L42)) have the same blind spot: `stringifyOption` does nothing when it gets the object form, so the number-to-text conversions it's meant to do never happen.

---

### C2: Old subscribe-parameter buttons stop working after the upgrade

- **Source:** 🔎 compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/upgrades.ts:83-89`](https://github.com/bitfocus/companion-module-biamp-tesira/blob/cce0e0b32e922f3f46e01a5625decafb31697b69/src/upgrades.ts#L83-L89)

**What goes wrong:** A user on module v2.x or earlier has a button using the old "subscribe parameter" action. After installing v4.0.0 the button is converted to **Custom attribute subscription**, but its **Subscription template** is **blank**, and pressing it does nothing. Companion logs "Failed to parse action options", with **Subscription template** reported as "Value is not in the list of choices". The button stays broken until the user re-selects the template. Users already on v3.x are not affected.

**Why it happens:** This is the same cause as C1. Companion 5 gives upgrade scripts each option as `{ isExpression: false, value: … }` and stores whatever comes back unchanged. The branch added in this release moves the old attribute across correctly, but writes the new template setting as a bare `'custom'`. Companion reads `.value` from it and gets nothing, so the editor shows the template as blank, and when the button runs the field fails validation. **Subscription template** is always visible, so it is always validated, and Companion refuses to run the action.

**Evidence:**

```ts
// src/upgrades.ts:83-89
		case 'subscribe_helper':
			if (options.attribute !== undefined) {
				options.templateId = 'custom'
				options.customAttribute = options.attribute
				delete options.attribute
				changed = true
			}
```

Running the built script on Companion 5-shaped input gives `"templateId": "custom"` next to `"customAttribute": { "isExpression": false, "value": "level" }`.

**Confirm by:** open [`src/upgrades.ts:85`](https://github.com/bitfocus/companion-module-biamp-tesira/blob/cce0e0b32e922f3f46e01a5625decafb31697b69/src/upgrades.ts#L85). The value written is `'custom'`, not `{ isExpression: false, value: 'custom' }`.

**Fix:** write the template in the same object shape as the other options.

```ts
options.templateId = { isExpression: false, value: 'custom' }
```

This migration also belongs in a new upgrade script rather than the existing one (see M2).

---

## 🟡 Medium

### M1: Level gauges show the wrong fill after a reconnect or a tag refresh

- **Source:** 🔎 QA reviewer
- **Classification:** 🔙 REGRESSION
- **File:** [`src/main.ts:896-909`](https://github.com/bitfocus/companion-module-biamp-tesira/blob/cce0e0b32e922f3f46e01a5625decafb31697b69/src/main.ts#L896-L909), [`src/main.ts:1008-1014`](https://github.com/bitfocus/companion-module-biamp-tesira/blob/cce0e0b32e922f3f46e01a5625decafb31697b69/src/main.ts#L1008-L1014)

**What goes wrong:** For a Level block whose range isn't the default -100 to 12 dB, the gauge presets and the `…_scaled` variables show the wrong fill after every reconnect, or after pressing **Refresh instance tags**. For example, a fader limited to -40 to 0 dB shows as almost full at -20 dB.

**Why it happens:** The module asks the device for each block's real min/max range, and refreshing the list of instance tags clears those learned ranges. v3 then asked again for every tag; this release removed that step, so the ranges stay cleared and the module falls back to -100 to 12.

**Fix:** keep the learned ranges when the tag list refreshes, or re-request the ranges of subscribed tags afterwards (or fall back to the `…_minLevel_1` / `…_maxLevel_1` variables, which still hold them).

### M2: Custom attribute subscription buttons from v3 stop working

- **Source:** 🔎 QA reviewer, compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/upgrades.ts:83-92`](https://github.com/bitfocus/companion-module-biamp-tesira/blob/cce0e0b32e922f3f46e01a5625decafb31697b69/src/upgrades.ts#L83-L92)

**What goes wrong:** A user upgrading from v3.x has **Custom attribute subscription** buttons created under v3. After installing v4.0.0, pressing one logs the error "Instance tag, attribute, and variable name are required" and nothing is subscribed.

**Why it happens:** Companion runs each upgrade script only once per connection and remembers that it has. This release added the new subscription migration to the end of the *existing* script, which v3 users have already run, so their buttons never get migrated.

**Fix:** put the existing upgrade script back as it was released (plus the C1/C2 fixes) and add the new migration as a second script.

### M3: Meter buttons made from v3 presets show an unknown Subscription template

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:499`](https://github.com/bitfocus/companion-module-biamp-tesira/blob/cce0e0b32e922f3f46e01a5625decafb31697b69/src/actions.ts#L499), [`src/presets.ts:838`](https://github.com/bitfocus/companion-module-biamp-tesira/blob/cce0e0b32e922f3f46e01a5625decafb31697b69/src/presets.ts#L838)

**What goes wrong:** Buttons made from the v3 meter presets have a **Subscription template** value that no longer matches any choice in the dropdown, so the editor shows it as unknown. The buttons still work only because the action quietly falls back to the custom attribute.

**Why it happens:** This release corrected the template's internal id (`audio_meter_peak_rms__level` → `audio_meter_peak_rms___level`), but existing buttons still store the old id, and no upgrade script maps it.

**Fix:** in the new upgrade script from M2, change the old id to the new one.

### M4: Some presets get invalid text sizes

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/presets.ts:232`](https://github.com/bitfocus/companion-module-biamp-tesira/blob/cce0e0b32e922f3f46e01a5625decafb31697b69/src/presets.ts#L232)

**What goes wrong:** The "Discover instance ID's" preset gets the text size "NaN", and other presets get sizes like 15 and 45 that Companion doesn't offer, so their text may render at an unexpected size.

**Why it happens:** The preset conversion adds 1 to every text size, which turns "auto" into "NaN" and 14/44 into 15/45.

**Fix:** keep "auto" as is and only adjust numeric sizes, keeping them valid.

### M5: Type checking was switched off for actions, feedbacks and presets

- **Source:** 🔎 compliance reviewer, QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:48`](https://github.com/bitfocus/companion-module-biamp-tesira/blob/cce0e0b32e922f3f46e01a5625decafb31697b69/src/actions.ts#L48), [`src/feedbacks.ts:361`](https://github.com/bitfocus/companion-module-biamp-tesira/blob/cce0e0b32e922f3f46e01a5625decafb31697b69/src/feedbacks.ts#L361), [`src/presets.ts:215-220`](https://github.com/bitfocus/companion-module-biamp-tesira/blob/cce0e0b32e922f3f46e01a5625decafb31697b69/src/presets.ts#L215-L220), [`src/presets.ts:427`](https://github.com/bitfocus/companion-module-biamp-tesira/blob/cce0e0b32e922f3f46e01a5625decafb31697b69/src/presets.ts#L427)

**What goes wrong:** No direct user-visible effect. The TypeScript checks that catch malformed actions, feedbacks and presets at build time are off, which is how M4 got through.

**Why it happens:** This release typed those definitions as `Record<string, any>` ("anything goes") instead of the library's types. The presets are also still written in the old format and converted at runtime.

**Fix:** use the library's definition types (a `ModuleSchema` for actions and feedbacks, `CompanionPresetDefinitions` for presets) and write the presets in the new format directly.

### M6: The new upgrade tests do not use the data Companion 5 actually sends

- **Source:** 🔎 compliance reviewer (verified; downgraded from High)
- **Classification:** 🆕 NEW
- **File:** [`test/review-regressions.test.js:35-81`](https://github.com/bitfocus/companion-module-biamp-tesira/blob/cce0e0b32e922f3f46e01a5625decafb31697b69/test/review-regressions.test.js#L35-L81)

**What goes wrong:** No direct user-visible effect. The tests for the upgrade script pass, but they don't test what really happens, which is why C1 and C2 weren't caught.

**Why it happens:** The tests give the script plain values (`250`), the Companion 4 format, while Companion 5 sends `{ isExpression: false, value: 250 }`. Nothing tests the hold-interval upgrade at all.

**Fix:** feed and check the Companion 5 object format, add a case for expression values, and add a hold-interval case.

### M7: The CI workflow uses an older checkout action

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **File:** [`.github/workflows/node.yaml:18`](https://github.com/bitfocus/companion-module-biamp-tesira/blob/cce0e0b32e922f3f46e01a5625decafb31697b69/.github/workflows/node.yaml#L18)

**What goes wrong:** No user-visible effect. The GitHub workflow uses `actions/checkout@v4`, while the template uses `actions/checkout@v7`.

**Fix:** update the version to match the template's workflow.

---

## 🟢 Low

### L1: Leftover no-op parseVariablesInString helper

- **Source:** 🔎 protocol reviewer, compliance reviewer, QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:175-178`](https://github.com/bitfocus/companion-module-biamp-tesira/blob/cce0e0b32e922f3f46e01a5625decafb31697b69/src/main.ts#L175-L178) (about 40 uses in [`src/actions.ts`](https://github.com/bitfocus/companion-module-biamp-tesira/blob/cce0e0b32e922f3f46e01a5625decafb31697b69/src/actions.ts))

**What goes wrong:** No user-visible effect. Variables in action options still work, because Companion 5 fills them in before the action runs.

**Why it happens:** Companion 5 removed `parseVariablesInString()`. Rather than update about 40 call sites, the module added its own version that just returns its input, which makes the action code look like it does something it doesn't.

**Fix:** delete the helper and read the option values directly, as `feedbacks.ts` already does.

### L2: Device data ending in user or password can be mistaken for a login prompt

- **Source:** 🔎 protocol reviewer, QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/login-prompt.ts:7-8`](https://github.com/bitfocus/companion-module-biamp-tesira/blob/cce0e0b32e922f3f46e01a5625decafb31697b69/src/login-prompt.ts#L7-L8), [`src/main.ts:787-807`](https://github.com/bitfocus/companion-module-biamp-tesira/blob/cce0e0b32e922f3f46e01a5625decafb31697b69/src/main.ts#L787-L807)

**What goes wrong:** Rarely, a reply from the Tesira that happens to end in a word followed by "user:" or "password:" (an alias or a label value, say) is treated as a login prompt. The module then sends the username or password as a command and throws that reply away.

**Why it happens:** This release made the login-prompt check looser, so it now matches those words anywhere at the end of a line, and the check keeps running for the whole session, not just at login.

**Fix:** only look for login prompts until the device's Welcome message has been seen on that connection, and keep any complete lines that arrived before the prompt.

### L3: Hand-built meter feedbacks ignore the device range when Instance tag is blank

- **Source:** 🔎 QA reviewer
- **Classification:** 🔙 REGRESSION
- **File:** [`src/feedbacks.ts:53-57`](https://github.com/bitfocus/companion-module-biamp-tesira/blob/cce0e0b32e922f3f46e01a5625decafb31697b69/src/feedbacks.ts#L53-L57), [`src/feedbacks.ts:78-92`](https://github.com/bitfocus/companion-module-biamp-tesira/blob/cce0e0b32e922f3f46e01a5625decafb31697b69/src/feedbacks.ts#L78-L92)

**What goes wrong:** A user who builds a meter feedback by hand and leaves **Instance tag** blank (relying on the source variable instead) gets the default range rather than the device's real range or their override. Presets aren't affected because they fill in the tag.

**Why it happens:** The module used to work out the tag from the variable name in the source field. In Companion 5 that field arrives with the variable already replaced by its value, so there is no name left to read.

**Fix:** say in the help that **Instance tag** is required for automatic ranges, or remove the dead inference code.

### L4: A VU meter tag without meter in its name gets the wrong scaled value

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:990-1000`](https://github.com/bitfocus/companion-module-biamp-tesira/blob/cce0e0b32e922f3f46e01a5625decafb31697b69/src/main.ts#L990-L1000), [`src/main.ts:1079-1092`](https://github.com/bitfocus/companion-module-biamp-tesira/blob/cce0e0b32e922f3f46e01a5625decafb31697b69/src/main.ts#L1079-L1092)

**What goes wrong:** If a tag listed in **Always subscribe these VU meter instance tags** has no "meter", "rms", "peak" or "vu" in its name (e.g. `LOBBY-MTR`), its `…_meter_1_scaled` variable flips between two different scales: 0–12 one moment, 0–100 the next.

**Why it happens:** The module guesses the tag type from its name, so it treats this one as a level control as well as a meter, and both write to the same variable.

**Fix:** treat tags from the VU meter list as meters only, without guessing from the name.

### L5: Preset sections appear out of order and their ids shift

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/presets.ts:306-310`](https://github.com/bitfocus/companion-module-biamp-tesira/blob/cce0e0b32e922f3f46e01a5625decafb31697b69/src/presets.ts#L306-L310)

**What goes wrong:** In the preset picker, sections "10/11/12 …" appear before "04 Mute Controls". Section ids also change whenever the discovered tags change.

**Why it happens:** Sections are listed in the order presets are first created, and numbered by position.

**Fix:** sort sections by name and base each id on its category.

---

## 💡 Nice to Have

### N1: A wrong password leaves the connection on Connecting forever

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:662-663`](https://github.com/bitfocus/companion-module-biamp-tesira/blob/cce0e0b32e922f3f46e01a5625decafb31697b69/src/main.ts#L662-L663), [`src/main.ts:718-722`](https://github.com/bitfocus/companion-module-biamp-tesira/blob/cce0e0b32e922f3f46e01a5625decafb31697b69/src/main.ts#L718-L722), [`src/main.ts:800-806`](https://github.com/bitfocus/companion-module-biamp-tesira/blob/cce0e0b32e922f3f46e01a5625decafb31697b69/src/main.ts#L800-L806)

**What goes wrong:** With a wrong **Login password**, the connection stays on "Connecting" indefinitely instead of reporting an authentication failure.

**Why it happens:** When the Tesira rejects the password and asks again, the module silently sends the same password again, forever.

**Fix:** after two login prompts on one connection, set the status to Authentication Failure and stop answering until the next reconnect or config change.

### N2: The connection status briefly loses its explanation

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:859-862`](https://github.com/bitfocus/companion-module-biamp-tesira/blob/cce0e0b32e922f3f46e01a5625decafb31697b69/src/main.ts#L859-L862)

**What goes wrong:** While connecting, the status sometimes shows a bare "Connecting" instead of "Waiting for command socket login".

**Why it happens:** One of the two connections sets the status without a message.

**Fix:** pass `'Waiting for command socket login'` there as well.

### N3: The password fallback differs between startup and saving the config

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:182`](https://github.com/bitfocus/companion-module-biamp-tesira/blob/cce0e0b32e922f3f46e01a5625decafb31697b69/src/main.ts#L182), [`src/main.ts:198`](https://github.com/bitfocus/companion-module-biamp-tesira/blob/cce0e0b32e922f3f46e01a5625decafb31697b69/src/main.ts#L198)

**What goes wrong:** No user-visible effect today. At startup a missing password defaults to an empty password; when the config is saved, it defaults to "no password setting at all".

**Fix:** use the same default in both places.

### N4: Level range overrides are re-read on every level update

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:1010`](https://github.com/bitfocus/companion-module-biamp-tesira/blob/cce0e0b32e922f3f46e01a5625decafb31697b69/src/main.ts#L1010)

**What goes wrong:** No user-visible effect, just wasted work. The **Level range overrides** setting is parsed again on every level update (every 250 ms per subscribed tag).

**Fix:** parse it once when the config loads or changes, and reuse the result.

---

## 🔮 Next Release

- The module still uses 12 "advanced" feedbacks, which the Companion 5 library marks as discouraged and likely to be removed in a future version. The presets already use the newer gauge elements, so plan to move the remaining meter feedbacks over as well.

---

## 🧪 Tests

`yarn test` (build, then `node --test`): **14/14 pass**. The tests check range parsing, login-prompt detection, connection status, meter and level scaling, feedback image encoding, and the layered preset gauges. The upgrade-script tests use the wrong input format (see M6).

---

## 📝 Additional Notes

- `tsconfig.build.json` differs from the template: it adds `src/**/*.d.ts` to `include`, sets `noImplicitAny: false`, uses `Node16` `module`/`moduleResolution` with `baseUrl`/`paths`, and drops `rootDir` and `verbatimModuleSyntax`. The module builds and lints, so no change is required.
- **Level range overrides** now expects entries separated by commas (as the help text always said) instead of `;` or new lines. Anyone on v3 who used `;` will silently lose their overrides, so this is worth a line in the CHANGELOG.
