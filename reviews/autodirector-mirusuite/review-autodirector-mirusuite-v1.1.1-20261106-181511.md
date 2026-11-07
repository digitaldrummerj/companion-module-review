# Review: autodirector-mirusuite v1.1.1 (follow-up to the v1.1.0 review)

| | |
| --- | --- |
| **Module** | `companion-module-autodirector-mirusuite` ([repo](https://github.com/bitfocus/companion-module-autodirector-mirusuite)) |
| **Version** | v1.1.1 (`0a61715`, 2026-11-02) |
| **Release** | Update — last published v1.0.3 |
| **API** | 2.1 (base 2.1.3, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11, main) |
| **Scope** | `tag` (`v1.0.3..v1.1.1`) |
| **Previous tag** | v1.0.3 (`f43d1c4`, 2026-03-16) |
| **Language** | TypeScript |
| **Build** | `yarn install --immutable`, `yarn package` and `yarn lint` pass |
| **Review date** | 2026-11-06 |
| **Prior review** | v1.1.0 (2026-10-08). v1.1.0 was never published. Fixed in v1.1.1: C1 (packaged module failed to load), C2 (passwords lost on upgrade), C3–C6 (template files, `.gitignore`, `package.json`, Node 26), H1 (LICENSE), H2 (removed features undocumented), H3 (`any`-typed definitions), M1 (visibility rules on expression fields) and L1–L4 (no request timeout, repeated variable pushes, large arrow images). H4 (CI workflows) is fixed: `release.yaml` was added and `node.yaml` now matches the template's Node 26 setup. The prior Next Release note about Director Status is still open ([NR1](#nr1-director-status-could-become-a-boolean-or-value-feedback)) |

The maintainer fixed every finding from the v1.1.0 review. Because v1.1.0 was never published, this review still covers the whole v1.0.3..v1.1.1 release, so some findings below were already in v1.1.0 and were missed by that review.

## Verdict: ✅ Approved

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | The module host in Companion 5 drops values for variable ids that have no definition, so `$(autodirector-mirusuite:connection)` stays blank until the definitions are registered | `companion-module-base` main branch, `packages/host/src/instance.ts` (`setVariableValues` deletes unknown ids); the 2.1.x host shipped with Companion 5 was not checked | [M1](#m1-if-mirusuite-is-not-running-when-companion-starts-the-connection-has-no-actions-feedbacks-presets-or-connection-variable) |
| A2 | The `eventsource` client reconnects on its own once MiruSuite is reachable, so its open handler then loads the configuration and the definitions appear | [`src/scripts/eventhandler.ts:54-63`](https://github.com/bitfocus/companion-module-autodirector-mirusuite/blob/0a61715acbc71a2eaf5a66b97c1722f0eae11680/src/scripts/eventhandler.ts#L54-L63) and the usual `eventsource` 2.x reconnect behaviour. This only affects how the problem recovers, not whether it happens | [M1](#m1-if-mirusuite-is-not-running-when-companion-starts-the-connection-has-no-actions-feedbacks-presets-or-connection-variable) |

## 📋 Issues

### Non-blocking

- [ ] [M1: If MiruSuite is not running when Companion starts, the connection has no actions, feedbacks, presets or connection variable](#m1-if-mirusuite-is-not-running-when-companion-starts-the-connection-has-no-actions-feedbacks-presets-or-connection-variable)
- [ ] [M2: After an active-project change, one failed music-piece or setlist request blocks every later refresh](#m2-after-an-active-project-change-one-failed-music-piece-or-setlist-request-blocks-every-later-refresh)
- [ ] [L1: Every device or component event reloads about 15 endpoints and resends all definitions](#l1-every-device-or-component-event-reloads-about-15-endpoints-and-resends-all-definitions)
- [ ] [L2: The Move Camera Zoom speed field accepts values up to 10 but caps them at 1](#l2-the-move-camera-zoom-speed-field-accepts-values-up-to-10-but-caps-them-at-1)
- [ ] [L3: HELP.md describes preset sections and groups that do not exist](#l3-helpmd-describes-preset-sections-and-groups-that-do-not-exist)
- [ ] [N1: Music Follower selection feedbacks ask for raw numeric IDs while the matching actions offer a list](#n1-music-follower-selection-feedbacks-ask-for-raw-numeric-ids-while-the-matching-actions-offer-a-list)
- [ ] [N2: The release notes and HELP.md disagree on which version removed button learning](#n2-the-release-notes-and-helpmd-disagree-on-which-version-removed-button-learning)
- [ ] [N3: Aborting a running button does not cancel its MiruSuite requests](#n3-aborting-a-running-button-does-not-cancel-its-mirusuite-requests)
- [ ] [NR1: Director Status could become a boolean or value feedback](#nr1-director-status-could-become-a-boolean-or-value-feedback)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟡 Medium

### M1: If MiruSuite is not running when Companion starts, the connection has no actions, feedbacks, presets or connection variable

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🔙 REGRESSION
- **File:** [`src/main.ts:48-62`](https://github.com/bitfocus/companion-module-autodirector-mirusuite/blob/0a61715acbc71a2eaf5a66b97c1722f0eae11680/src/main.ts#L48-L62), [`src/main.ts:74-87`](https://github.com/bitfocus/companion-module-autodirector-mirusuite/blob/0a61715acbc71a2eaf5a66b97c1722f0eae11680/src/main.ts#L74-L87)

**What goes wrong:** A user starts Companion before MiruSuite is running, or MiruSuite can't be reached at that moment. The connection goes red, and the module registers nothing: its action and feedback lists are empty, existing MiruSuite buttons show their actions as unknown in the button editor, the Presets tab has no MiruSuite section, and `$(autodirector-mirusuite:connection)` shows nothing instead of "Disconnected" (A1). [`companion/HELP.md:12`](https://github.com/bitfocus/companion-module-autodirector-mirusuite/blob/0a61715acbc71a2eaf5a66b97c1722f0eae11680/companion/HELP.md#L12) tells users to put the **Connection status** variable on a button to show the connection state, and it doesn't work in this, the most common failure case. Everything appears once MiruSuite answers and the event stream reopens (A2). In v1.0.3 the module registered its actions, feedbacks, presets and variables even while offline.

**Why it happens:** Actions, feedbacks, variable definitions and presets are only registered after the first configuration load succeeds. When that load fails, `connect()` only logs and sets the status, and it pushes variable values only when a configuration was loaded before, which is never the case on first start.

**Fix:** register the definitions with the empty store when the first load fails. In `connect()`'s `catch`, call `this.updateDefinitions()` and then `this.updateVariableValues()` when `!this.store.hasConfiguration`. The dropdown helpers already fall back to "No devices available" choices, so this is safe.

### M2: After an active-project change, one failed music-piece or setlist request blocks every later refresh

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/scripts/store.ts:131-161`](https://github.com/bitfocus/companion-module-autodirector-mirusuite/blob/0a61715acbc71a2eaf5a66b97c1722f0eae11680/src/scripts/store.ts#L131-L161)

**What goes wrong:** An operator switches the active project, with a **Load Project** preset or in MiruSuite. If the Orchestra music-pieces or setlists request fails once during the refresh that follows (an error reply or the 5-second timeout), the whole refresh is thrown away and the connection shows Connection Failure. Every later refresh then fails the same way, on each device, component or project event and every stream reconnect, until the connection is restarted. Meanwhile the **Play Preset** dropdown and saved-preset buttons keep the previous project's presets, the **Active Project** feedback and `$(autodirector-mirusuite:active_project_name)` keep the old project, and new devices never appear. On the first load the module already treats these two requests as optional ("Could not refresh music pieces; keeping the last known value").

**Why it happens:** On the first pass, the music-piece and setlist requests run with `Promise.allSettled`, so a failure is tolerated. In the project-change branch they run with `Promise.all` and only a success handler, so one failure rejects the whole refresh. The new active project is only saved after this block (line 179), so the module still sees a project change on every later refresh and takes the same failing branch.

**Fix:** keep the two requests optional in the project-change path too, with `Promise.allSettled([this.backend.loadMusicPieces(), this.backend.loadSetlists()])` or a rejection handler that returns `{ status: 'rejected', reason }`. Alternatively, save the new active project before the optional refreshes.

---

## 🟢 Low

### L1: Every device or component event reloads about 15 endpoints and resends all definitions

- **Source:** 🔎 QA reviewer
- **Classification:** 🔙 REGRESSION
- **File:** [`src/main.ts:77-88`](https://github.com/bitfocus/companion-module-autodirector-mirusuite/blob/0a61715acbc71a2eaf5a66b97c1722f0eae11680/src/main.ts#L77-L88), [`src/scripts/eventhandler.ts:110-113`](https://github.com/bitfocus/companion-module-autodirector-mirusuite/blob/0a61715acbc71a2eaf5a66b97c1722f0eae11680/src/scripts/eventhandler.ts#L110-L113)

**What goes wrong:** Nothing breaks for the user, but each device or component update from MiruSuite makes the module request about 15 MiruSuite endpoints, resend every action, feedback, preset and variable definition to Companion (including the PTZ arrow-image presets), and re-run 19 feedback types, some of which download and rescale a face image. During busy shows this is much more work for Companion and the MiruSuite server than v1.0.3 did, which reloaded only the device list on a component update and redefined everything only when the devices had changed.

**Why it happens:** `loadConfiguration()` already returns whether the definitions need to change, but `updateConfiguration()` ignores that value and always calls `updateDefinitions()`. Component updates now go straight to `updateConfiguration()`.

**Fix:** use the return value (`const definitionsChanged = await this.store.loadConfiguration()`) and call `updateDefinitions()` only when it is true, extending the signature to cover projects, presets, faces and switcher inputs. For component updates, consider going back to reloading only the devices and calling `checkFeedbacks`, as v1.0.3 did.

### L2: The Move Camera Zoom speed field accepts values up to 10 but caps them at 1

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions/camera.ts:342-358`](https://github.com/bitfocus/companion-module-autodirector-mirusuite/blob/0a61715acbc71a2eaf5a66b97c1722f0eae11680/src/actions/camera.ts#L342-L358)

**What goes wrong:** In the **Move Camera** action, a user enters a **Zoom speed** of 5 to get a faster zoom. The field accepts it (its range is -10 to 10), but 5 zooms exactly like 1. **Pan speed** and **Tilt speed** show their real range of -1 to 1.

**Why it happens:** The zoom option is declared with a minimum of -10 and a maximum of 10, while the callback clamps it to -1…1, like pan and tilt.

**Fix:** set the zoom option to `min: -1` and `max: 1`, matching the clamp and the presets. If MiruSuite accepts larger zoom speeds, remove the clamp instead.

### L3: HELP.md describes preset sections and groups that do not exist

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`companion/HELP.md:20-30`](https://github.com/bitfocus/companion-module-autodirector-mirusuite/blob/0a61715acbc71a2eaf5a66b97c1722f0eae11680/companion/HELP.md#L20-L30)

**What goes wrong:** A user follows the preset table in the help and looks for sections called "Video: Cam 1" or "Audio: Mic 1", a "Saved Presets" group, or the Gamepad and Music Follower presets under **Application**. None of them exist. Companion shows one section per device, named only by its MiruSuite name (for example "Cam 1"), the saved-preset group is called "Presets", and the **Gamepad**, **Music Follower** and **Include in Orchestra** presets sit in each device's own section. Only the project, switcher, AutoCut and Orchestra-setting presets are under **Application**.

**Why it happens:** `organizePresets()` ([`src/presets/modern.ts:40-47`](https://github.com/bitfocus/companion-module-autodirector-mirusuite/blob/0a61715acbc71a2eaf5a66b97c1722f0eae11680/src/presets/modern.ts#L40-L47)) names each section after the device and puts every preset whose actions target exactly one device into that device's section. The group names are the preset categories ("General", "Person Tracking", "PTZ", "Presets", "AutoCut", "vMix Framer", "Music Follower", "Orchestra", "Gamepad").

**Fix:** update the table in `companion/HELP.md` to the real layout, or rename the sections and categories in `organizePresets()` to match the current text.

---

## 💡 Nice to Have

### N1: Music Follower selection feedbacks ask for raw numeric IDs while the matching actions offer a list

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.ts:437-479`](https://github.com/bitfocus/companion-module-autodirector-mirusuite/blob/0a61715acbc71a2eaf5a66b97c1722f0eae11680/src/feedbacks.ts#L437-L479)

**What goes wrong:** A user builds a button by hand with **Select Music Piece**, picking "Ave Maria" from the **Piece** dropdown. To light the button they add **Music Follower Piece Selected**, but it has a **Piece ID** number field (default -1) instead of a list, so they have to find MiruSuite's internal ID. **Music Follower Setlist Entry Selected** likewise needs **Setlist ID** and **Entry ID** typed in. The generated presets fill the IDs in, so only hand-built buttons are affected.

**Fix:** use the same dropdowns as the actions: piece choices from `store.getMusicPieces()`, and one `entry` dropdown with `${setlistId}:${entryId}` ids as in `selectMusicSetlistEntry`. Add an upgrade script that combines a saved `setlistId`/`entryId` pair into the new `entry` value, so existing buttons keep working.

### N2: The release notes and HELP.md disagree on which version removed button learning

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`CHANGELOG.md:3-21`](https://github.com/bitfocus/companion-module-autodirector-mirusuite/blob/0a61715acbc71a2eaf5a66b97c1722f0eae11680/CHANGELOG.md#L3-L21)

**What goes wrong:** A user upgrading from 1.0.3 reads two different stories. `CHANGELOG.md` lists the changes under "Unreleased" and says "The 1.1.0 release removed automatic button learning", while [`companion/HELP.md:80`](https://github.com/bitfocus/companion-module-autodirector-mirusuite/blob/0a61715acbc71a2eaf5a66b97c1722f0eae11680/companion/HELP.md#L80) says "Version 1.1.1 removed the automatic button learning feature". 1.1.0 was never published, so users go straight from 1.0.3 to 1.1.1.

**Fix:** rename the "Unreleased" heading to "1.1.1" and change the migration notice to 1.1.1, matching HELP.md.

### N3: Aborting a running button does not cancel its MiruSuite requests

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions/camera.ts:72-80`](https://github.com/bitfocus/companion-module-autodirector-mirusuite/blob/0a61715acbc71a2eaf5a66b97c1722f0eae11680/src/actions/camera.ts#L72-L80) (and the other network-bound action callbacks)

**What goes wrong:** A user aborts a running button, for example with Companion's "Abort actions on button". Requests already sent to MiruSuite still run to completion, for up to 5 seconds each. The effect is small because every request already has a 5-second timeout.

**Why it happens:** API 2.1 passes an abort signal (`context.signal`) to action callbacks. The module's request wrapper ([`src/api/backend.ts:54-57`](https://github.com/bitfocus/companion-module-autodirector-mirusuite/blob/0a61715acbc71a2eaf5a66b97c1722f0eae11680/src/api/backend.ts#L54-L57)) already merges a caller's signal with its timeout, but no action callback takes the `context` argument or passes the signal on.

**Fix:** accept `(event, context)` in the network-bound callbacks and pass `context.signal` through the `Backend` methods into the request's `signal`.

---

## 🔮 Next Release

### NR1: Director Status could become a boolean or value feedback

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW (carried from the v1.1.0 review's Next Release notes)
- **File:** [`src/feedbacks.ts:79-119`](https://github.com/bitfocus/companion-module-autodirector-mirusuite/blob/0a61715acbc71a2eaf5a66b97c1722f0eae11680/src/feedbacks.ts#L79-L119)

**What goes wrong:** Nothing visible today. **Director Status** is an advanced feedback that only sets the background and text colours (green when the director is running, yellow on warning or error, black otherwise). API 2.1 discourages advanced feedbacks, and they are likely to be removed in a future major version.

**Fix:** replace it with a value feedback that returns the director state, or with boolean feedbacks (Running, Warning or Error) that the presets style themselves. Keep `directorStatus` until an upgrade script moves existing buttons to the new feedback.

## 📝 Additional Notes

- `tsconfig.build.json` differs from the template: `compilerOptions` drops `"verbatimModuleSyntax": true` and adds `"module": "NodeNext"` and `"moduleResolution": "NodeNext"`; `outDir` and `rootDir` are only in a different order. The Node 26 preset in `extends` matches the template. The module builds, so no change is required.
