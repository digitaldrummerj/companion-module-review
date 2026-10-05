# Review: companion-module-utopianacademy-deckboy v1.0.2

| | |
|---|---|
| **Module** | `companion-module-utopianacademy-deckboy` |
| **Version** | v1.0.2 |
| **Scope:** | tag |
| **Previous tag** | none. This is the first release, so there is no diff and the whole module was reviewed. Every finding is 🆕 NEW. |
| **Template** | `companion-module-template-js` @ `e4caa76` (2026-08-28) |
| **API** | 2.1 (base 2.1.3, yarn.lock) — requires Companion 5.0+ |
| **Language** | JavaScript (ESM) |
| **Protocol** | TCP, newline-terminated plain-text commands, polled `STATUS` reply (`TCPHelper`) |
| **Review date** | 2026-10-05 |

## Verdict: ❌ Changes Required

## 📋 Issues

**Blocking**

- [ ] [C1: Source file main.js sits at the module root](#c1-source-file-mainjs-sits-at-the-module-root)
- [ ] [C2: yarn.lock is out of sync with package.json](#c2-yarnlock-is-out-of-sync-with-packagejson)
- [ ] [C3: package.json repository url points to the app repo](#c3-packagejson-repository-url-points-to-the-app-repo)
- [ ] [C4: package.json is missing the packageManager field](#c4-packagejson-is-missing-the-packagemanager-field)
- [ ] [C5: package.json is missing the prettier field](#c5-packagejson-is-missing-the-prettier-field)
- [ ] [C6: package.json is missing the prettier devDependency](#c6-packagejson-is-missing-the-prettier-devdependency)
- [ ] [C7: package.json is missing the format script](#c7-packagejson-is-missing-the-format-script)
- [ ] [C8: Placeholder maintainer in the manifest](#c8-placeholder-maintainer-in-the-manifest)
- [ ] [H2: LICENSE differs from the template](#h2-license-differs-from-the-template)

**Non-blocking**

- [ ] [M1: No end handler, so a clean close leaves the module marked connected]
(#m1-no-end-handler-so-a-clean-close-leaves-the-module-marked-connected)
- [ ] [M3: Naming a deck on a button moves the global deck focus](#m3-naming-a-deck-on-a-button-moves-the-global-deck-focus)
- [ ] [M4: A dead link is never detected, so the surface shows stale state](#m4-a-dead-link-is-never-detected-so-the-surface-shows-stale-state)
- [ ] [L1: Polling keeps running while disconnected and floods the log](#l1-polling-keeps-running-while-disconnected-and-floods-the-log)
- [ ] [L2: Acknowledgement-only chunks clear the pending STATUS flag](#l2-acknowledgement-only-chunks-clear-the-pending-status-flag)
- [ ] [L3: Receive buffer is unbounded and decodes UTF-8 per chunk](#l3-receive-buffer-is-unbounded-and-decodes-utf-8-per-chunk)
- [ ] [L4: Two callbacks throw when the option value is missing](#l4-two-callbacks-throw-when-the-option-value-is-missing)
- [ ] [L5: Number options are sent without validation](#l5-number-options-are-sent-without-validation)
- [ ] [L6: Index-style number fields lack asInteger](#l6-index-style-number-fields-lack-asinteger)
- [ ] [L7: Fixed-choice dropdown ids use mixed casing](#l7-fixed-choice-dropdown-ids-use-mixed-casing)
- [ ] [L8: VJ deck options stop at 8 while the deck limit is 16](#l8-vj-deck-options-stop-at-8-while-the-deck-limit-is-16)
- [ ] [L9: Manifest apiVersion is hand-set and there is no schema reference](#l9-manifest-apiversion-is-hand-set-and-there-is-no-schema-reference)
- [ ] [N1: Republish only changed variables and feedbacks](#n1-republish-only-changed-variables-and-feedbacks)
- [ ] [N2: Quoted values cannot contain an escaped double quote](#n2-quoted-values-cannot-contain-an-escaped-double-quote)
- [ ] [N3: Add an empty UpgradeScripts export](#n3-add-an-empty-upgradescripts-export)

---

## 🔴 Critical

### C1: Source file main.js sits at the module root

**Classification:** 🆕 NEW · **File:** `main.js` · **Source:** validate-template (SRC-AT-ROOT)

All module source must live under `src/`. The entry point `main.js` is at the repository root, and `package.json` `main` and `companion/manifest.json` `runtime.entrypoint` (`../main.js`) point at it.

**Fix:** move it to `src/main.js` (the template layout) and update `package.json` `main` to `src/main.js` and the manifest `entrypoint` to `../src/main.js`. Fix the relative imports (`./src/actions.js` becomes `./actions.js`, and so on) and the imports in `test/`.

### C2: yarn.lock is out of sync with package.json

**Classification:** 🆕 NEW · **File:** `yarn.lock:8`, `package.json:17` · **Source:** deterministic check (BUILD-INSTALL), confirmed by the compliance reviewer

The committed Yarn 4 lockfile was generated for a different `package.json`. Its workspace entry is `utopianacademy-deckboy@workspace:.`, with `"@companion-module/base": "npm:~2.1.3"` and a `prettier` devDependency. The committed `package.json` is named `companion-module-utopianacademy-deckboy`, asks for `"@companion-module/base": "^2.1.3"`, and has no prettier.

- `yarn install --immutable` under Yarn 4.12.0 fails with `YN0028: The lockfile would have been modified by this install, which is explicitly forbidden.` The install would change the base descriptor from `~2.1.3` to `^2.1.3`, rename the workspace, drop prettier, and add `colord ^2.9.4` and `zod`.
- The validator's build gate did not catch this. With no `packageManager` field, corepack did not pick Yarn 4, the install ran under Yarn classic 1.22.22, and classic ignores `--immutable`.
- A normal install ignores the lock and resolves base **2.2.0**, not the locked 2.1.3. The clone's `node_modules/@companion-module/base` is 2.2.0, and the built `utopianacademy-deckboy-1.0.2.tgz` manifest says `"apiVersion":"2.2.0"`. The package as built needs a newer Companion than the 5.0 the module targets, so Companion 5.0 hosts will refuse it.

**Fix:** pin `"@companion-module/base": "~2.1.3"` if 2.1 is the intended API level (or target 2.2 on purpose and test on the matching Companion). Add `packageManager` (C4) and restore the template's prettier field and devDependency (C5, C6). Then run `yarn install` under Yarn 4, commit the regenerated `yarn.lock`, and confirm that `yarn install --immutable` passes.

### C3: package.json repository url points to the app repo

**Classification:** 🆕 NEW · **File:** `package.json:8-12` · **Source:** validate-template (PKG-REPO)

`repository.url` is `git+https://github.com/Utopian-Academy/Deckboy.git`. It should be `git+https://github.com/bitfocus/companion-module-utopianacademy-deckboy.git`. The `directory` key also points into the app repo, so drop it.

### C4: package.json is missing the packageManager field

**Classification:** 🆕 NEW · **File:** `package.json` · **Source:** validate-template (PKG-FIELD)

The template sets `packageManager` (Yarn 4). Without it, corepack falls back to whatever global Yarn is installed, which is how the stale lockfile in C2 got through the build. Add `"packageManager": "yarn@4.17.0"`, as the template has it.

### C5: package.json is missing the prettier field

**Classification:** 🆕 NEW · **File:** `package.json` · **Source:** validate-template (PKG-FIELD)

The template's `"prettier": "@companion-module/tools/.prettierrc.json"` field is missing. The repo has a `.prettierignore`, but no formatter config is wired up. Restore the field from the template.

### C6: package.json is missing the prettier devDependency

**Classification:** 🆕 NEW · **File:** `package.json:20-22` · **Source:** validate-template (PKG-DEVDEP)

The template lists `prettier` in `devDependencies`. Restore it as `"prettier": "^3.8.3"`, as the template has it. The stale `yarn.lock` (C2) still carries it.

### C7: package.json is missing the format script

**Classification:** 🆕 NEW · **File:** `package.json:13-16` · **Source:** validate-template (PKG-SCRIPT)

The template's `format` script (`prettier -w .`) is missing. Restore it alongside the existing `test` and `package` scripts.

### C8: Placeholder maintainer in the manifest

**Classification:** 🆕 NEW · **File:** `companion/manifest.json:11-17` · **Source:** validate-template (MAN-PLACEHOLDER)

The only maintainer is `name: "Deckboy Contributors"` with an empty `email`. You should be able to remove the email.

---

## 🟠 High

### H2: LICENSE differs from the template

**Classification:** 🆕 NEW · non-blocking · **File:** `LICENSE:3` · **Source:** validate-template (LICENSE-DIFF)

Line 3 reads `Copyright (c) 2026 Utopian Academy`, but the template has `Copyright (c) 2022 Bitfocus AS - Open Source`. The license is still MIT, so this does not block, but please align it with the template.

---

## 🟡 Medium

### M2: Take cue by number sends TAKE even when the cue number is empty

**Classification:** 🆕 NEW · **File:** `src/actions.js:75-79` (also `select_cue` at `src/actions.js:62-65`) · **Source:** QA reviewer

If `options.cue` resolves to `''` (an empty variable, a cleared field), `SELECT ` is trimmed to `SELECT`, which Deckboy rejects. `TAKE` is still sent straight after, so whatever cue is currently selected goes live. On a live show, that puts the wrong cue on air.

**Fix:** check that `cue` is non-empty (ideally a positive integer) before sending anything, and return without sending if it isn't. Apply the same check in `select_cue`.

### M3: Naming a deck on a button moves the global deck focus

**Classification:** 🆕 NEW · **File:** `src/actions.js:28-34` · **Source:** QA reviewer

`withDeck` sends `DECK n` as its own line, which is the same command `focus_deck` sends (`src/actions.js:166`). After a "Stop, deck 2" press, Deckboy's focus is on deck 2, so every deck-0 ("focused deck") button then acts on deck 2. That includes every Transport preset, which all use `deck: 0`, and the focus-based feedbacks. `companion/HELP.md:29-30` says "a button that names its deck always acts on that deck", but it doesn't mention this side effect.

**Fix:** use a one-line, deck-scoped form if Deckboy has one (for example `DECK n TAKE`). Otherwise restore the previous focus afterwards (send `DECK <state.global.focus>`), or document clearly in HELP.md that deck-specific buttons move focus.

### M4: A dead link is never detected, so the surface shows stale state

**Classification:** 🆕 NEW · **File:** `main.js:153-172` · **Source:** QA reviewer

When a STATUS goes unanswered, the stall logic only logs at debug level and asks again. It never marks the connection as bad. If the network silently disappears (cable pulled, host powered off), no `error` arrives until TCP retransmission or keepalive gives up, which can take minutes. Until then `connected` stays `yes`, `connection_lost` stays off, and the last tally and countdown values stay frozen on the buttons. That defeats the "Connection watchdog" preset.

**Fix:** count consecutive stalls. After 2–3 stalls, call `setConnected(false)`, set `updateStatus(InstanceStatus.ConnectionFailure, 'No STATUS reply')`, and recreate the socket with `openConnection()`.

---

## 🟢 Low

### L1: Polling keeps running while disconnected and floods the log

**Classification:** 🆕 NEW · **File:** `main.js:108-119`, `main.js:140-143`, `main.js:207-209` · **Source:** protocol + QA reviewers

Polling is only stopped in `openConnection()` and `destroy()`. While disconnected, `requestStatus()` keeps calling `sendCommand('STATUS')`. Because of the stall timer, that logs `warn "Not connected — dropped command: STATUS"` about every 1.5 s. Each failed reconnect (every 2 s) also logs at `error` level. If Deckboy is closed overnight, the log fills up.

**Fix:** call `stopPolling()` in the `'error'` and `'end'` handlers. The `'connect'` handler already restarts polling. Log the connection error only when its message changes.

### L2: Acknowledgement-only chunks clear the pending STATUS flag

**Classification:** 🆕 NEW · **File:** `main.js:244`, `main.js:247-255` · **Source:** QA reviewer (protocol reviewer noted the same side effect)

A chunk that holds only `OK …` or `ERR …` lines (the reply to a button press) still reaches `flushReport()` with no report. That path sets `statusPending = false` while a STATUS is still outstanding, so a second STATUS goes out on the next poll.

**Fix:** clear `statusPending` only when a report is actually flushed, or when the stall timeout expires.

### L3: Receive buffer is unbounded and decodes UTF-8 per chunk

**Classification:** 🆕 NEW · **File:** `main.js:217-223` · **Source:** protocol + QA reviewers

- `receiveBuffer` has no size limit. A peer that never sends a newline (the wrong port, or a non-Deckboy service on 5510) makes it grow for the life of the connection. **Fix:** cap it, for example log a warning and reset it when it passes 64 KB.
- `chunk.toString('utf8')` runs on each chunk separately, so a multi-byte character (a non-ASCII cue name) that lands on a chunk boundary is corrupted. **Fix:** decode with `StringDecoder` from `node:string_decoder`.

### L4: Two callbacks throw when the option value is missing

**Classification:** 🆕 NEW · **File:** `src/actions.js:229` (`vj_mode`), `src/actions.js:470` (`fx_copy_paste`) · **Source:** QA reviewer

`options.state.toUpperCase()` and `options.action.toUpperCase()` throw a TypeError if the value is undefined (for example, an action saved before the option existed). **Fix:** use `String(options.state ?? 'toggle').toUpperCase()`, the pattern `blackout` already uses at line 133.

### L5: Number options are sent without validation

**Classification:** 🆕 NEW · **File:** `src/actions.js:139, 144, 149, 237, 265, 291, 313, 329, 417, 425` · **Source:** QA reviewer

These callbacks interpolate `${options.value}` (and similar) straight into the command. A missing or non-numeric value goes out as literal text, for example `MASTERVOL undefined`. **Fix:** check with `Number.isFinite(Number(v))`, and skip and log when the check fails.

### L6: Index-style number fields lack asInteger

**Classification:** 🆕 NEW · **File:** `src/actions.js:17-24, 165, 193, 288-289, 310, 319, 335, 422, 431, 447`; `src/feedbacks.js:20-27, 115, 125` · **Source:** compliance reviewer

The deck, output, display, effect-index and slot `number` fields have no `asInteger: true`. In 2.x any field can be switched to expression mode, so a computed `2.5` passes the min/max check and goes out as `DECK 2.5` or `AUDIOFX 2.5 OFF`. **Fix:** add `asInteger: true` to these index fields. Skill: companion-v2-actions / companion-v2-feedbacks.

### L7: Fixed-choice dropdown ids use mixed casing

**Classification:** 🆕 NEW · **File:** `src/actions.js:127-129, 178-180, 223-225, 276-277, 438-439, 495-497` · **Source:** compliance reviewer

`blackout`, `output_enable`, `vj_mode` and `vj_quantise` use the ids `on`/`off`/`toggle`. `text_mode` and `audiofx_bypass` use `ON`/`OFF`/`TOGGLE`. In 2.x users type these ids in expression mode, and the wrong case makes Companion skip the action. **Fix:** pick one casing for the ids and upper-case at send time where the device needs it. Or set `disableAutoExpression: true` on these fixed-state dropdowns, which make little sense as expressions. Skill: companion-v2-actions.

### L8: VJ deck options stop at 8 while the deck limit is 16

**Classification:** 🆕 NEW · **File:** `src/actions.js:288-289` · **Source:** compliance reviewer

`vj_decks` caps Deck A and Deck B at `max: 8`. Every other deck option uses `MAX_DECKS` (16), and `src/variables.js:19-21` says that shared constant exists to keep these ranges in step. **Fix:** use `MAX_DECKS`. If VJ mode really supports only 8 decks, add a named constant and a comment saying so.

### L9: Manifest apiVersion is hand-set and there is no schema reference

**Classification:** 🆕 NEW · **File:** `companion/manifest.json:22` · **Source:** compliance reviewer

`runtime.apiVersion` is hard-coded as `"2.1.3"`, and the manifest has no `"$schema"`. The 2.x convention is `"apiVersion": "0.0.0"` (the build fills in the real value) plus `"$schema": "../node_modules/@companion-module/base/assets/manifest.schema.json"`. The hard-coded value is already wrong for the current build, which stamped 2.2.0 (see C2). Skill: companion-v2-module-scaffold.

---

## 💡 Nice to Have

### N1: Republish only changed variables and feedbacks

**Classification:** 🆕 NEW · **File:** `main.js:283-290` · **Source:** protocol + QA reviewers

`publishState()` sends every variable and runs `checkAllFeedbacks()` on every STATUS reply. At the default poll rate that is 4 times a second, even when nothing changed. Keep the last published values, pass only the changed keys to `setVariableValues()`, and call `checkAllFeedbacks()` only when the parsed state or `connected` changed.

### N2: Quoted values cannot contain an escaped double quote

**Classification:** 🆕 NEW · **File:** `src/protocol.js:23` · **Source:** QA reviewer

The `"([^"]*)"` pattern stops at the first `"`. A cue name that contains a double quote cuts the value short and shifts the fields after it. Confirm how Deckboy escapes quotes, and if it uses `\"`, match with `"((?:[^"\\]|\\.)*)"`.

### N3: Add an empty UpgradeScripts export

**Classification:** 🆕 NEW · **File:** `main.js:293-296` · **Source:** compliance reviewer

There is no `UpgradeScripts` named export. That's fine for a first release, because Companion treats a missing export as an empty list. Adding `src/upgrades.js` with `export const UpgradeScripts = []`, re-exported from the entry point, gives the first option rename a place to go. Skill: companion-v2-upgrades.

---
