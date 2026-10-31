# Re-review: companion-module-videopathe-qplayer v1.0.1

| Field | Value |
| --- | --- |
| **Module** | `companion-module-videopathe-qplayer` |
| **Scope** | `tag` |
| **Version** | v1.0.1 |
| **Release** | New module — never published |
| **API** | 1 (base 1.14.1, yarn.lock) |
| **Template** | `companion-module-template-ts-v1` @ `42609d8` (2026-03-03, pinned) · `.yarnrc.yml` from `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Commit** | [`c3d9da9`](https://github.com/bitfocus/companion-module-videopathe-qplayer/tree/c3d9da971a891434ddf2374fb2eea0ba2271b6e8) |
| **Prior review** | [v1.0.0 review](review-videopathe-qplayer-v1.0.0-20261030-003407.md) |
| **Reviewed** | 2026-10-30 |

## Verdict: ✅ Approved

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | When a user adds a QPlayer connection, Companion labels it from the manifest `shortname` ("QPlayer"), and Companion does not rewrite a hard-coded `$(videopathe-qplayer:...)` prefix in preset text to the connection's real label | how Companion 3.x/4.x is known to label connections; Companion's host code (including any preset variable-prefix rewriting when it stores presets) not checked | [M1](#m1-readout-presets-may-not-show-the-time-media-or-player-name-because-the-variable-prefix-is-hard-coded) |

## 📋 Issues

### Non-blocking

- [ ] [M1: Readout presets may not show the time, media or player name because the variable prefix is hard-coded](#m1-readout-presets-may-not-show-the-time-media-or-player-name-because-the-variable-prefix-is-hard-coded)
- [ ] [L1: Library item dropdowns list only the first 500 library items](#l1-library-item-dropdowns-list-only-the-first-500-library-items)
- [ ] [L2: A leftover unused file says Companion does not resolve variables in options, which is wrong](#l2-a-leftover-unused-file-says-companion-does-not-resolve-variables-in-options-which-is-wrong)
- [ ] [NR1: Consider moving to API 2.x for expression support in options](#nr1-consider-moving-to-api-2x-for-expression-support-in-options)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟡 Medium

### M1: Readout presets may not show the time, media or player name because the variable prefix is hard-coded

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/presets.ts:11-13`](https://github.com/bitfocus/companion-module-videopathe-qplayer/blob/c3d9da971a891434ddf2374fb2eea0ba2271b6e8/src/presets.ts#L11-L13), [`companion/HELP.md:131`](https://github.com/bitfocus/companion-module-videopathe-qplayer/blob/c3d9da971a891434ddf2374fb2eea0ba2271b6e8/companion/HELP.md#L131), [`README.md:242`](https://github.com/bitfocus/companion-module-videopathe-qplayer/blob/c3d9da971a891434ddf2374fb2eea0ba2271b6e8/README.md#L242), [`README.md:254`](https://github.com/bitfocus/companion-module-videopathe-qplayer/blob/c3d9da971a891434ddf2374fb2eea0ba2271b6e8/README.md#L254)

**What goes wrong:** A user adds a QPlayer connection (labelled "QPlayer" by default) and drags a **Readouts** preset such as "Active remaining time" or "Active media name", or the **Select Player 1** / **Select Player 2** presets, onto a button. The button text refers to `$(videopathe-qplayer:remaining_formatted)`, but the connection's variables are published under the connection label, as `$(QPlayer:remaining_formatted)`. If Companion does not rewrite the prefix (see [A1](#-assumptions-to-confirm)), the button shows `$NA` instead of `00:42`. The same applies after renaming the connection or adding a second one ("QPlayer_2"). HELP.md and README.md give users the same hard-coded prefix.

**Why it happens:** `UpdatePresets` builds every variable reference from a fixed module id (`const moduleId = 'videopathe-qplayer'`), not from the connection's label. In Companion, variable references use the connection label.

**Fix:** build the prefix from the connection label, and in HELP.md and README.md write the examples as `$(<connection label>:p2_program_remaining_formatted)` with a note that the prefix is the connection's label.

```ts
const variable = (name: string) => `$(${self.label}:${name})`
```

## 🟢 Low

### L1: Library item dropdowns list only the first 500 library items

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:462-467`](https://github.com/bitfocus/companion-module-videopathe-qplayer/blob/c3d9da971a891434ddf2374fb2eea0ba2271b6e8/src/main.ts#L462-L467)

**What goes wrong:** With a QPlayer library of, say, 800 clips, the **Library item** dropdown in "Library: Play item", "Library: Load item" and "Library: Remove item" lists only the first 500. To reach item 501 or later, the user has to type its ID into **Library ID override** or its path into **Path override**.

**Why it happens:** The poll always requests `/api/library/items?limit=500&offset=0` and never fetches the following pages.

**Fix:** page through `/api/library/items` until a page comes back short (or use the total the endpoint reports). If 500 is an intended cap, say so in the dropdown label or the help text.

### L2: A leftover unused file says Companion does not resolve variables in options, which is wrong

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/optionVariables.ts:1-26`](https://github.com/bitfocus/companion-module-videopathe-qplayer/blob/c3d9da971a891434ddf2374fb2eea0ba2271b6e8/src/optionVariables.ts#L1-L26)

**What goes wrong:** Users see nothing different, because nothing imports this file any more. The risk is for maintainers: the header comment says "API 1.x suggests variables in fields but does not resolve them automatically". A later maintainer who believes it and wires the helper back in would parse every variable a second time, which is the problem fixed since v1.0.0 (prior review M3).

**Why it happens:** v1.0.1 correctly removed the calls to `variableOptionIds` / `resolveVariableOptions` from the action and feedback wrappers, but left the file and its comment behind. Companion resolves variables in `textinput` fields that set `useVariables` before the callback runs; base 1.14.1 marks `parseVariablesInString` in the callback context "@deprecated Companion now handles this for you".

**Fix:** delete `src/optionVariables.ts`.

## 🔮 Next Release

### NR1: Consider moving to API 2.x for expression support in options

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-videopathe-qplayer/blob/c3d9da971a891434ddf2374fb2eea0ba2271b6e8/package.json)

**What goes wrong:** Nothing breaks today. The module is on `@companion-module/base` ~1.14.1 (Companion 4.2+). With API 2.0 (Companion 4.3+) or 2.1 (Companion 5.0+), users could type expressions into options such as seek percent, volume percent and the remaining-time thresholds, and API 2.1 adds abort signals and action results that suit the Link test and WebRTC actions.

**Fix:** in a future release, plan the move to `@companion-module/base` 2.x following the v1-to-v2 migration guide. Check the 2.x breaking changes first: ESM entrypoint, removal of `isVisible` functions, and expression-aware options.

## 📝 Additional Notes

- Follow-up to the [v1.0.0 review](review-videopathe-qplayer-v1.0.0-20261030-003407.md). This is still a first release, so there is no published tag to diff against and the whole module was reviewed; every finding is classified 🆕 NEW. The v1.0.0..v1.0.1 changes (14 files) were used to verify the prior findings.
- Prior C1 (extra `ignores` option in `eslint.config.mjs`): closed. The option is still there, but extending `generateEslintConfig` this way is now an accepted deviation.
- Prior C2–C5 (husky `postinstall`, `husky` and `lint-staged` devDependencies, `lint-staged` section): fixed.
- Prior H1 (API PIN never sent): fixed. `init()` and `configUpdated()` now store the `secrets` argument, and the PIN is read from it for both the HTTP header and the WebSocket URL.
- Prior M1 (every variable and feedback re-sent four times a second): fixed. The ticker only repaints while something is playing or counting down, sends only changed variables, and re-checks only the time-based feedbacks.
- Prior M2 (No target playlist still sent the active playlist): fixed. An empty choice now sends an empty target.
- Prior M3 (variables resolved a second time): fixed in the wrappers; the leftover helper file is [L2](#l2-a-leftover-unused-file-says-companion-does-not-resolve-variables-in-options-which-is-wrong).
- Prior M4 (workflow action versions): not changed; no longer reported.
- Prior L1–L5 (rejected command turned the connection red, crash on an unexpected reply, unexplained Bad Configuration, `isVisible` functions, Open monitor window preset toggling): all fixed.
- `yarn install --immutable`, `yarn package` and `yarn lint` all pass.
