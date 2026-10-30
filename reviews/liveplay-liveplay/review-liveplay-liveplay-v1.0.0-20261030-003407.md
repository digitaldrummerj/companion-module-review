# Review: liveplay-liveplay v1.0.0

| Field | Value |
| --- | --- |
| **Module** | [companion-module-liveplay-liveplay](https://github.com/bitfocus/companion-module-liveplay-liveplay) |
| **Scope** | `tag` |
| **Version** | v1.0.0 |
| **Release** | New module — never published |
| **API** | 2.1 (base 2.1.3, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11, main) |
| **Commit** | [`a05d600`](https://github.com/bitfocus/companion-module-liveplay-liveplay/commit/a05d600141f415c6a796f7418be8fb473370b0fa) |
| **Reviewed** | 2026-10-30 |

This is the module's first release, so there is no previous tag to diff against: the whole module was reviewed, and every finding is classified 🆕 NEW.

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Companion 5.0 honours `context.signal` on action callbacks and fires it when the user aborts a button, so ignoring it means the request still reaches LivePlay after an abort | API 2.1 reference in the companion-v2-api-compliance skill (abort signals); the host behaviour itself was not checked in Companion source | [M1](#m1-pressing-abort-on-a-liveplay-button-does-not-cancel-the-http-request-already-sent) |
| A2 | Advanced feedbacks are likely to be removed in a future major Companion API version | The companion-v2-api-compliance v2.1 reference, which states the deprecation intent; there is no deprecation marker in the 2.1.3 typings | [M2](#m2-six-colour-and-name-feedbacks-use-the-advanced-feedback-type-that-companion-plans-to-remove) |

## 📋 Issues

### Blocking

- [ ] [C1: Module targets Node 22 instead of the Node 26 runtime the API 2.1 template uses](#c1-module-targets-node-22-instead-of-the-node-26-runtime-the-api-21-template-uses)
- [ ] [C2: Pre-commit hook does not match the template](#c2-pre-commit-hook-does-not-match-the-template)

### Non-blocking

- [ ] [M1: Pressing Abort on a LivePlay button does not cancel the HTTP request already sent](#m1-pressing-abort-on-a-liveplay-button-does-not-cancel-the-http-request-already-sent)
- [ ] [M2: Six colour and name feedbacks use the advanced feedback type that Companion plans to remove](#m2-six-colour-and-name-feedbacks-use-the-advanced-feedback-type-that-companion-plans-to-remove)
- [ ] [M3: CI builds and lints on Node 22 while the module should run on Node 26](#m3-ci-builds-and-lints-on-node-22-while-the-module-should-run-on-node-26)
- [ ] [M4: Release workflow replaces the template's shared module checks with a custom publish job](#m4-release-workflow-replaces-the-templates-shared-module-checks-with-a-custom-publish-job)
- [ ] [L1: A stray space in the server host leaves the connection stuck on Connection Failure](#l1-a-stray-space-in-the-server-host-leaves-the-connection-stuck-on-connection-failure)
- [ ] [L2: One failed project fetch silently removes cue names, Trigger Cue presets and index lookups](#l2-one-failed-project-fetch-silently-removes-cue-names-trigger-cue-presets-and-index-lookups)
- [ ] [L3: Memory grows slowly with every cue fired over a long session](#l3-memory-grows-slowly-with-every-cue-fired-over-a-long-session)
- [ ] [L4: A variable typed into a feedback's Item UUID field is never resolved](#l4-a-variable-typed-into-a-feedbacks-item-uuid-field-is-never-resolved)
- [ ] [L5: On/Off/Toggle and direction dropdowns offer an expression mode that only causes silent failures](#l5-onofftoggle-and-direction-dropdowns-offer-an-expression-mode-that-only-causes-silent-failures)
- [ ] [L6: Large shows flood the Presets tab and variable list with one entry per cue](#l6-large-shows-flood-the-presets-tab-and-variable-list-with-one-entry-per-cue)
- [ ] [N1: Connection config info text runs two sentences together](#n1-connection-config-info-text-runs-two-sentences-together)

## 🔴 Critical

### C1: Module targets Node 22 instead of the Node 26 runtime the API 2.1 template uses

- **Source:** 🤖 validate-template (MAN-RUNTIME)
- **Classification:** 🆕 NEW
- **File:** [`companion/manifest.json:18-19`](https://github.com/bitfocus/companion-module-liveplay-liveplay/blob/a05d600141f415c6a796f7418be8fb473370b0fa/companion/manifest.json#L18-L19), [`tsconfig.build.json:2`](https://github.com/bitfocus/companion-module-liveplay-liveplay/blob/a05d600141f415c6a796f7418be8fb473370b0fa/tsconfig.build.json#L2)

**What goes wrong:** The module is built on API 2.1 (Companion 5.0+), but its manifest tells Companion to run it on Node 22, and the TypeScript build uses the Node 22 preset. Every API 2.1 module is expected to run on Node 26, as the template does. A module that differs from its template here makes later troubleshooting harder, because it doesn't run in the environment everyone else assumes.

**Why it happens:** The manifest's `runtime.type` and the `extends` preset in `tsconfig.build.json` were left at the Node 22 values instead of the API 2.1 template's Node 26 values.

**Evidence:**

| File | Template expects | Found |
| --- | --- | --- |
| `companion/manifest.json` | `"runtime": { "type": "node26" }` | `"type": "node22"` |
| `tsconfig.build.json` | `"extends": "@companion-module/tools/tsconfig/node26/recommended.json"` | `"extends": "@companion-module/tools/tsconfig/node22/recommended-esm.json"` |

**Fix:** switch the runtime to Node 26 in the manifest and extend the template's Node 26 tsconfig preset (also update CI, see [M3](#m3-ci-builds-and-lints-on-node-22-while-the-module-should-run-on-node-26)).

```json
"runtime": {
	"type": "node26",
```

```json
"extends": "@companion-module/tools/tsconfig/node26/recommended.json",
```

### C2: Pre-commit hook does not match the template

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.husky/pre-commit:1`](https://github.com/bitfocus/companion-module-liveplay-liveplay/blob/a05d600141f415c6a796f7418be8fb473370b0fa/.husky/pre-commit#L1)

**What goes wrong:** No effect for users. The pre-commit hook passes an extra flag to `lint-staged`, so contributors' commits are checked differently from every other module built on the template.

**Why it happens:** The hook was edited after it was copied from the template.

**Evidence:**

| Template expects | Found |
| --- | --- |
| `lint-staged` | `lint-staged --relative` |

**Fix:** restore the template's hook.

```text
lint-staged
```

## 🟡 Medium

### M1: Pressing Abort on a LivePlay button does not cancel the HTTP request already sent

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:173-205`](https://github.com/bitfocus/companion-module-liveplay-liveplay/blob/a05d600141f415c6a796f7418be8fb473370b0fa/src/main.ts#L173-L205)

**What goes wrong:** An operator fires a button with, say, "Trigger cart slot" (slot 3) or "Load project", then presses Abort (or the button runs `internal:abortButton`) while LivePlay is slow to answer. Companion treats the action as aborted, but the module's request keeps running for up to 5 seconds and still reaches LivePlay, so the cue plays or the project loads anyway. Day to day there is little visible effect, because requests normally finish in milliseconds.

**Why it happens:** API 2.1 gives every action callback an abort signal (`context.signal`) for network calls like these. The module's shared request helper (`apiRequest()`) only uses its own 5-second timeout signal, and no action callback in `src/actions.ts` passes the callback's signal through.

**Fix:** let the request helper accept an abort signal and combine it with the timeout, then pass `context.signal` from the network actions (see companion-v2-actions).

```ts
signal: AbortSignal.any([AbortSignal.timeout(5000), signal].filter(Boolean))
// in each network action:
callback: async (event, context) => { await self.apiPost(path, body, context.signal) }
```

### M2: Six colour and name feedbacks use the advanced feedback type that Companion plans to remove

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.ts:262-392`](https://github.com/bitfocus/companion-module-liveplay-liveplay/blob/a05d600141f415c6a796f7418be8fb473370b0fa/src/feedbacks.ts#L262-L392)

**What goes wrong:** No visible effect today: "Up Next item color", "Selected item color", "Playing item color (with end-of-cue flash)", "Cart slot color", "Item color by UUID" and "Cue button (name, color and play state)" all work in Companion 5.0. But advanced feedbacks are discouraged and are likely to go in a future major API version, so buttons users build on them now would then need rework.

**Why it happens:** All six are declared `type: 'advanced'` and return a style object (`{ bgcolor, color, text }`). The API 2.1 guidance for new code is boolean or value feedbacks, or layered presets. The module already uses that pattern for its gauges (value feedbacks `cue_color_rgb` / `cue_text_rgb` feeding layered presets).

**Fix:** optional for a first release. Keep the advanced feedbacks if simple-button users need them, but for new presets prefer the value-feedback and layered-preset pattern the gauges already use, for example a `next_color_rgb` value feedback driving a layered element's colour expression (see companion-v2-feedbacks and companion-v2-preset-category-file).

### M3: CI builds and lints on Node 22 while the module should run on Node 26

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.github/workflows/node.yaml:18-23`](https://github.com/bitfocus/companion-module-liveplay-liveplay/blob/a05d600141f415c6a796f7418be8fb473370b0fa/.github/workflows/node.yaml#L18-L23)

**What goes wrong:** The CI workflow checks the module on a different Node version from the one it should run on in Companion, so a problem that only shows up on Node 26 would pass CI. The checkout step also leaves the GitHub token stored in the workspace, which the template turns off.

**Why it happens:** The workflow runs the "Use Node.js 22.x" step with `node-version: 22.x` where the template uses `26.x`, and the checkout step is missing the template's `with: persist-credentials: false`.

**Evidence:**

```yaml
# .github/workflows/node.yaml:18-23
      - uses: actions/checkout@v7
      - name: Use Node.js 22.x
        # This should match the version of Node.js you have defined in the manifest.json runtime field
        uses: actions/setup-node@v6
        with:
          node-version: 22.x
```

**Fix:** copy the template's `node.yaml`. This goes together with the move to Node 26 in [C1](#c1-module-targets-node-22-instead-of-the-node-26-runtime-the-api-21-template-uses).

### M4: Release workflow replaces the template's shared module checks with a custom publish job

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.github/workflows/release.yaml:5-42`](https://github.com/bitfocus/companion-module-liveplay-liveplay/blob/a05d600141f415c6a796f7418be8fb473370b0fa/.github/workflows/release.yaml#L5-L42)

**What goes wrong:** Releases of this module no longer go through the checks every other module's release runs. The template's release workflow runs when a GitHub release is published, packages the module through Bitfocus's shared `module-checks` workflow, and attaches the package with `gh release upload`. This module's workflow skips all of that.

**Why it happens:** The template's `release.yaml` was replaced with a custom workflow that:

- runs on a tag push, with `contents: write` at the workflow level;
- uses Node 22.x;
- runs a plain `yarn install` and `yarn package` instead of the shared `bitfocus/actions/.github/workflows/module-checks.yaml@main` workflow;
- publishes with the third-party `softprops/action-gh-release@v2` action.

**Evidence:**

```yaml
# .github/workflows/release.yaml:5-11
on:
  push:
    tags:
      - 'v[0-9]+.[0-9]+.[0-9]+*'

permissions:
  contents: write
# .github/workflows/release.yaml:38-42
      - name: Create release with package attached
        uses: softprops/action-gh-release@v2
        with:
          files: '*.tgz'
          generate_release_notes: true
```

**Fix:** copy the template's `release.yaml`.

## 🟢 Low

### L1: A stray space in the server host leaves the connection stuck on Connection Failure

- **Source:** 🔎 protocol reviewer, QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:156-158`](https://github.com/bitfocus/companion-module-liveplay-liveplay/blob/a05d600141f415c6a796f7418be8fb473370b0fa/src/main.ts#L156-L158), [`src/main.ts:325`](https://github.com/bitfocus/companion-module-liveplay-liveplay/blob/a05d600141f415c6a796f7418be8fb473370b0fa/src/main.ts#L325)

**What goes wrong:** A user pastes the IP address 192.168.1.20 with a trailing space into "Server IP / hostname". The connection never comes up: the status keeps showing `No LivePlay server at http://192.168.1.20 :4480` and retries every few seconds, even though LivePlay is running. The space is hard to spot in the status text, so the user may think the server is down. Nothing crashes.

**Why it happens:** The REST base URL and the WebSocket URL are both built from the raw host value, which is never trimmed. A space inside the host makes the URL invalid, so every probe fails with "Invalid URL" and is reported as "No LivePlay server". The "host is not set" check also lets a host made only of spaces through, so it shows Connection Failure instead of Bad Config.

**Fix:** trim the host once when the config arrives, in both `init()` and `configUpdated()`, and test the trimmed value in `startConnection()` so a blank host reports "Server host is not set". Optionally add a hostname `regex` to the field.

```ts
this.config = { ...config, host: config.host.trim() }
```

### L2: One failed project fetch silently removes cue names, Trigger Cue presets and index lookups

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:367-379`](https://github.com/bitfocus/companion-module-liveplay-liveplay/blob/a05d600141f415c6a796f7418be8fb473370b0fa/src/main.ts#L367-L379), [`src/main.ts:501-511`](https://github.com/bitfocus/companion-module-liveplay-liveplay/blob/a05d600141f415c6a796f7418be8fb473370b0fa/src/main.ts#L501-L511)

**What goes wrong:** If fetching the open project fails once while connecting or after an edit (for example it times out after 3 seconds on a large show), the module treats the project as empty. Every `$(liveplay:item_name_<uuid>)` and `$(liveplay:item_name_at_2_35)` variable disappears, the "Trigger Cue" preset groups vanish, "Select item by index path" logs `No item at index path "2,35"`, and the "Cue button" / "Cue name" feedbacks show the raw UUID or index instead of the cue name. Nothing is logged, the connection still shows OK, and this lasts until the next project edit or reconnect.

**Why it happens:** The quiet probe helper turns every failure (non-2xx, timeout, network error) into an empty result without logging. The catalog refresh passes that result straight on, so a failed fetch looks exactly like an empty project and the catalog is cleared and re-published.

**Fix:** when a project is open but the fetch returns nothing, keep the existing catalog (clear it only when no project is open), log a warning with the HTTP status, and optionally schedule a retry.

### L3: Memory grows slowly with every cue fired over a long session

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/state.ts:64`](https://github.com/bitfocus/companion-module-liveplay-liveplay/blob/a05d600141f415c6a796f7418be8fb473370b0fa/src/state.ts#L64), [`src/state.ts:126`](https://github.com/bitfocus/companion-module-liveplay-liveplay/blob/a05d600141f415c6a796f7418be8fb473370b0fa/src/state.ts#L126), [`src/state.ts:323-329`](https://github.com/bitfocus/companion-module-liveplay-liveplay/blob/a05d600141f415c6a796f7418be8fb473370b0fa/src/state.ts#L323-L329)

**What goes wrong:** Over a long-running Companion session (days of shows, thousands of cue triggers, several project loads), the module keeps one entry for every engine cue id it has ever seen. Each entry is small, so in normal use nothing is visible; it is a slow leak, not a crash.

**Why it happens:** The cue-id-to-item map (`cueToItem`) is filled when a summary arrives, on every cue state change and on every playback snapshot, but nothing ever removes entries. Clearing playback and re-seeding from a full summary both leave it alone, even though the code's own comment says cue ids change across loads.

**Fix:** remove the entry when a cue reports Stopped, and/or call `cueToItem.clear()` in `clearPlayback()` and at the start of `applySummary()` before re-seeding.

### L4: A variable typed into a feedback's Item UUID field is never resolved

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.ts:113`](https://github.com/bitfocus/companion-module-liveplay-liveplay/blob/a05d600141f415c6a796f7418be8fb473370b0fa/src/feedbacks.ts#L113), [`src/feedbacks.ts:123`](https://github.com/bitfocus/companion-module-liveplay-liveplay/blob/a05d600141f415c6a796f7418be8fb473370b0fa/src/feedbacks.ts#L123), [`src/feedbacks.ts:207`](https://github.com/bitfocus/companion-module-liveplay-liveplay/blob/a05d600141f415c6a796f7418be8fb473370b0fa/src/feedbacks.ts#L207), [`src/feedbacks.ts:220`](https://github.com/bitfocus/companion-module-liveplay-liveplay/blob/a05d600141f415c6a796f7418be8fb473370b0fa/src/feedbacks.ts#L220), [`src/feedbacks.ts:346`](https://github.com/bitfocus/companion-module-liveplay-liveplay/blob/a05d600141f415c6a796f7418be8fb473370b0fa/src/feedbacks.ts#L346)

**What goes wrong:** A user adds "Item is playing" (or "Item is paused", "Item is selected", "Item is armed as Up Next", "Item color by UUID") and types `$(liveplay:selected_uuid)` into "Item UUID". The feedback compares the literal text with real UUIDs, so it never turns on. The same text works in the matching actions ("Play item by UUID", "Pause item"), which makes the difference confusing. Switching the field to expression mode does work.

**Why it happens:** These feedbacks' Item UUID text fields are declared without `useVariables: true`, while every action UUID field and the feedbacks' cue option set it. In base 2.1.3 `useVariables` controls whether `$(...)` is parsed in a plain text field.

**Fix:** add `useVariables: true` to the `uuid` text field in `item_playing`, `item_paused`, `item_selected`, `item_is_next` and `item_color`.

### L5: On/Off/Toggle and direction dropdowns offer an expression mode that only causes silent failures

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:292-302`](https://github.com/bitfocus/companion-module-liveplay-liveplay/blob/a05d600141f415c6a796f7418be8fb473370b0fa/src/actions.ts#L292-L302), [`src/actions.ts:387-396`](https://github.com/bitfocus/companion-module-liveplay-liveplay/blob/a05d600141f415c6a796f7418be8fb473370b0fa/src/actions.ts#L387-L396), [`src/actions.ts:480-489`](https://github.com/bitfocus/companion-module-liveplay-liveplay/blob/a05d600141f415c6a796f7418be8fb473370b0fa/src/actions.ts#L480-L489), [`src/actions.ts:534`](https://github.com/bitfocus/companion-module-liveplay-liveplay/blob/a05d600141f415c6a796f7418be8fb473370b0fa/src/actions.ts#L534), [`src/actions.ts:550`](https://github.com/bitfocus/companion-module-liveplay-liveplay/blob/a05d600141f415c6a796f7418be8fb473370b0fa/src/actions.ts#L550), [`src/actions.ts:574`](https://github.com/bitfocus/companion-module-liveplay-liveplay/blob/a05d600141f415c6a796f7418be8fb473370b0fa/src/actions.ts#L574)

**What goes wrong:** In "Master limiter", "Show Mode", "Bus mute", "Bus PFL", "Preview mono audition" and "Select next / previous item", the Mode / Direction dropdown shows the expression toggle. A user who switches it on and types `On` (capitalised) or `1` gets an action that Companion skips silently, because the value isn't one of the allowed choices (`toggle` / `on` / `off`, or `1` / `-1`).

**Why it happens:** In API 2.x every field other than a text input gets expression mode automatically unless it sets `disableAutoExpression: true`. A computed value that isn't in the dropdown's choices fails validation, and fixed-choice mode selectors gain nothing from expressions.

**Fix:** add `disableAutoExpression: true` to these Mode / Direction dropdowns (including the users of `MODE_CHOICES`), or, if expressions are wanted, add an `expressionDescription` listing the valid ids.

### L6: Large shows flood the Presets tab and variable list with one entry per cue

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/presets-cues.ts:68-102`](https://github.com/bitfocus/companion-module-liveplay-liveplay/blob/a05d600141f415c6a796f7418be8fb473370b0fa/src/presets-cues.ts#L68-L102), [`src/variables.ts:179-183`](https://github.com/bitfocus/companion-module-liveplay-liveplay/blob/a05d600141f415c6a796f7418be8fb473370b0fa/src/variables.ts#L179-L183)

**What goes wrong:** With a 400-cue LivePlay project open, the Presets tab gets about 400 near-identical "Trigger Cue" buttons and the variable list gets about 800 `item_name_*` variables. Both are re-published on every catalog change (an item added, renamed or reordered in LivePlay), so browsing presets and variables becomes slow and cluttered. The two Manual presets (by index and by UUID, driven by a local variable) already cover the same need.

**Why it happens:** The cue presets loop over every playable item in the catalog and create one preset each, and the variable definitions add two name variables per item. The v2 guidance prefers local variables or template preset groups to generating hundreds of similar presets.

**Fix:** consider a `type: 'template'` preset group that takes the cue as a template value, or cap the per-cue list or make it opt-in with a config checkbox (see companion-v2-preset-category-file).

## 💡 Nice to Have

### N1: Connection config info text runs two sentences together

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/config.ts:25-26`](https://github.com/bitfocus/companion-module-liveplay-liveplay/blob/a05d600141f415c6a796f7418be8fb473370b0fa/src/config.ts#L25-L26)

**What goes wrong:** In the connection's config panel, the "Information" text reads "…paste it below.Without a login the LivePlay API is open…", with no space between the sentences. Cosmetic only.

**Why it happens:** The two string literals are joined with `+` and neither has a space at the join.

**Fix:** add a trailing space to the second literal: `'...paste it below. ' +`.
