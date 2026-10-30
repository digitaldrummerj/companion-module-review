# Review: syncthingfoundation-syncthing v1.0.1 (follow-up to the v1.0.0 review)

| | |
| --- | --- |
| **Module** | `companion-module-syncthingfoundation-syncthing` ([repo](https://github.com/bitfocus/companion-module-syncthingfoundation-syncthing)) |
| **Scope** | `tag` (first release, so the whole module was reviewed) |
| **Version** | v1.0.1 (`ae19f13`) |
| **Release** | New module — never published |
| **API** | 2.0 (base 2.0.4, yarn.lock) — requires Companion 4.3+ |
| **Template** | `companion-module-template-ts-v2.0.4` @ `d62230e` (2026-08-28, pinned) |
| **Previous tag** | none published (a local `v1.0.0` tag was reviewed on 2026-10-08) |
| **Language** | TypeScript |
| **Build** | `yarn install --immutable`, `yarn package` and `yarn lint` pass |
| **Review date** | 2026-10-30 |

This is a follow-up to the [v1.0.0 review](review-syncthingfoundation-syncthing-v1.0.0-20261005-024911.md), which asked for changes (C1, H1, H2). The module has still never been published, so there is no released tag to diff against: the whole module was reviewed again, and every finding is classified as new.

All six findings from the v1.0.0 review are fixed in v1.0.1 (see [📝 Additional Notes](#-additional-notes)). The template check is now clean. The findings below are all non-blocking.

## Verdict: ✅ Approved

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Companion can save an empty or 0 value for a number config field (here "GUI port", min 1, default 8384) when the user clears the field and saves | Companion's UI behaviour as the QA reviewer understands it; not confirmable from the module code or the base package | [L2](#l2-an-empty-gui-port-falls-back-to-8384-in-the-shown-url-but-not-in-the-actual-connection) |

## 📋 Issues

### Non-blocking

- [ ] [L1: A single failed action marks the whole connection as failed](#l1-a-single-failed-action-marks-the-whole-connection-as-failed)
- [ ] [L2: An empty GUI port falls back to 8384 in the shown URL but not in the actual connection](#l2-an-empty-gui-port-falls-back-to-8384-in-the-shown-url-but-not-in-the-actual-connection)
- [ ] [L3: An IPv6 host gives a broken GUI URL variable and log address](#l3-an-ipv6-host-gives-a-broken-gui-url-variable-and-log-address)
- [ ] [L4: Every detail poll sends one status request per folder all at the same time](#l4-every-detail-poll-sends-one-status-request-per-folder-all-at-the-same-time)
- [ ] [L5: The source manifest hard-codes the API version the build fills in](#l5-the-source-manifest-hard-codes-the-api-version-the-build-fills-in)
- [ ] [N1: Folder presets can overwrite each other for folder ids ending in pause, override or revert](#n1-folder-presets-can-overwrite-each-other-for-folder-ids-ending-in-pause-override-or-revert)
- [ ] [N2: Status variables hold the text true or false instead of a real boolean](#n2-status-variables-hold-the-text-true-or-false-instead-of-a-real-boolean)

### Notes

- [📝 Additional Notes](#-additional-notes)

---

## 🟢 Low

### L1: A single failed action marks the whole connection as failed

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:273-286`](https://github.com/bitfocus/companion-module-syncthingfoundation-syncthing/blob/ae19f13171bbaeaae1d42e4e93b6b5e2b48c2c2e/src/main.ts#L273-L286), [`src/main.ts:847-863`](https://github.com/bitfocus/companion-module-syncthingfoundation-syncthing/blob/ae19f13171bbaeaae1d42e4e93b6b5e2b48c2c2e/src/main.ts#L847-L863)

**What goes wrong:** An operator types a folder id that doesn't exist (for example `music-old`) into the **Folder** option of **Folder: pause, resume or toggle** or **Rescan one folder**. Syncthing answers HTTP 404 or 500, and the connection status turns red with "PATCH /rest/config/folders/music-old failed with HTTP 404". The **Connected to Syncthing** feedback goes inactive, `$(syncthing:connected)` becomes `false` and `$(syncthing:devices_connected)` drops to 0, although the connection itself is fine. The forced poll that runs right after the action usually restores the status, but if a poll is already running that forced poll is skipped and the false failure stays for up to 5 seconds. The log also gets an error line that looks like a connection problem.

**Why it happens:** Every action error goes through the same failure handler as a failed poll. That handler marks every device disconnected, publishes `connected=false` and sets the connection status to "connection failure". It doesn't tell a network or API key problem apart from a normal error answer to a request that reached Syncthing.

**Fix:** only treat network errors (no HTTP status) and rejected API keys as a connection failure in `runAction`. For any other HTTP error answer, log a warning such as `${name} failed: HTTP 404` and leave the connection status and variables alone.

### L2: An empty GUI port falls back to 8384 in the shown URL but not in the actual connection

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:314-321`](https://github.com/bitfocus/companion-module-syncthingfoundation-syncthing/blob/ae19f13171bbaeaae1d42e4e93b6b5e2b48c2c2e/src/main.ts#L314-L321), [`src/main.ts:336-342`](https://github.com/bitfocus/companion-module-syncthingfoundation-syncthing/blob/ae19f13171bbaeaae1d42e4e93b6b5e2b48c2c2e/src/main.ts#L336-L342)
- **Depends on:** [A1](#-assumptions-to-confirm)

**What goes wrong:** If the **GUI port** field is ever saved empty or 0, `$(syncthing:gui_url)` and the network search both use port 8384, but the connection and the automatic API key lookup go to port 80. The connection fails with "connection refused" on port 80 while the help text and `gui_url` still show `:8384`, so the user can't see why.

**Why it happens:** The GUI URL ([`src/config.ts:47`](https://github.com/bitfocus/companion-module-syncthingfoundation-syncthing/blob/ae19f13171bbaeaae1d42e4e93b6b5e2b48c2c2e/src/config.ts#L47)) and the network search ([`src/main.ts:177`](https://github.com/bitfocus/companion-module-syncthingfoundation-syncthing/blob/ae19f13171bbaeaae1d42e4e93b6b5e2b48c2c2e/src/main.ts#L177), [`src/main.ts:197`](https://github.com/bitfocus/companion-module-syncthingfoundation-syncthing/blob/ae19f13171bbaeaae1d42e4e93b6b5e2b48c2c2e/src/main.ts#L197)) fall back to 8384 when the port is empty. The REST client and the API key lookup get the raw config value, and Node uses port 80 when it is empty.

**Fix:** work out one effective port and use it everywhere.

```ts
const port = this.config.port || DEFAULT_PORT
// pass `port` to new SyncthingApi({...}) and to discoverApiKey({...})
```

### L3: An IPv6 host gives a broken GUI URL variable and log address

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/config.ts:41-48`](https://github.com/bitfocus/companion-module-syncthingfoundation-syncthing/blob/ae19f13171bbaeaae1d42e4e93b6b5e2b48c2c2e/src/config.ts#L41-L48), [`src/api.ts:62-64`](https://github.com/bitfocus/companion-module-syncthingfoundation-syncthing/blob/ae19f13171bbaeaae1d42e4e93b6b5e2b48c2c2e/src/api.ts#L62-L64)

**What goes wrong:** The **Host** field deliberately accepts a bare IPv6 address such as `2001:db8::5`. `$(syncthing:gui_url)` then becomes `http://2001:db8::5:8384`, which no browser or "open URL" action can parse, and the "Connected to Syncthing ... at" log line shows the same broken address. The connection itself works, because the host and port are passed to Node separately.

**Why it happens:** The GUI URL and the client's display URL are built as `scheme://host:port` without the square brackets a URL needs around an IPv6 address.

**Fix:** wrap the host in brackets when it contains a colon, in both `guiUrlFor` and `SyncthingApi.baseUrl`.

```ts
const host = config.host.includes(':') ? `[${config.host}]` : config.host
```

### L4: Every detail poll sends one status request per folder all at the same time

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:724-776`](https://github.com/bitfocus/companion-module-syncthingfoundation-syncthing/blob/ae19f13171bbaeaae1d42e4e93b6b5e2b48c2c2e/src/main.ts#L724-L776)

**What goes wrong:** On an instance with many folders and devices (say 40 folders and 15 devices), each detail poll sends 40 folder status requests and 15 device completion requests at the same moment. That happens every 30 seconds while the event stream is down, every 120 seconds otherwise, and after every action press except **Restart** and **Shut down**. The module's own comment calls the folder status call expensive. A busy or low-powered NAS may then show folders with state `unknown` now and then, when requests run into the 10-second timeout.

**Why it happens:** The detail poll starts every folder and device request inside one `Promise.all`, with no limit on how many run at once, and every action forces a full detail poll.

**Fix:** limit how many detail requests run at once (for example 4 at a time with a small worker queue). Consider having an action refresh only the folder or device it touched instead of forcing a full poll.

### L5: The source manifest hard-codes the API version the build fills in

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`companion/manifest.json:21`](https://github.com/bitfocus/companion-module-syncthingfoundation-syncthing/blob/ae19f13171bbaeaae1d42e4e93b6b5e2b48c2c2e/companion/manifest.json#L21)

**What goes wrong:** No user-visible effect: the released package is correct. The committed manifest says `"apiVersion": "2.0.4"` where the template has `"0.0.0"`. If `@companion-module/base` is bumped later, the hand-written value in the source manifest goes stale and misleads anyone who reads or copies it.

**Why it happens:** The template ships the placeholder `"0.0.0"`, and `companion-module-build` writes the installed base version into the packaged manifest when it builds the module. This module's source manifest has the resolved value typed in by hand.

**Fix:** set `runtime.apiVersion` back to `"0.0.0"`, as in the template, and let `yarn package` fill it in.

---

## 💡 Nice to Have

### N1: Folder presets can overwrite each other for folder ids ending in pause, override or revert

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/presets.ts:162-163`](https://github.com/bitfocus/companion-module-syncthingfoundation-syncthing/blob/ae19f13171bbaeaae1d42e4e93b6b5e2b48c2c2e/src/presets.ts#L162-L163), [`src/presets.ts:200-202`](https://github.com/bitfocus/companion-module-syncthingfoundation-syncthing/blob/ae19f13171bbaeaae1d42e4e93b6b5e2b48c2c2e/src/presets.ts#L200-L202)

**What goes wrong:** With two Syncthing folders `music` and `music-pause`, the preset "Folder music: pause" is replaced by the main preset of folder `music-pause`, because both get the preset id `folder_music_pause`. The **Folders** section of the Presets tab then lists that id twice and the pause preset for `music` is missing. Folder ids ending in `-override` or `-revert` have the same effect.

**Why it happens:** Each folder's prefix is unique, but the preset ids add fixed suffixes (`_pause`, `_override`, `_revert`) to it, and the result can equal another folder's plain `folder_<prefix>` id. This is the preset-id version of the variable-name clash fixed in this release.

**Fix:** use a separator a cleaned-up prefix can never contain (for example `folder_${varPrefix}__pause`), or a separate namespace such as `folderpause_${varPrefix}`.

### N2: Status variables hold the text true or false instead of a real boolean

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:808-838`](https://github.com/bitfocus/companion-module-syncthingfoundation-syncthing/blob/ae19f13171bbaeaae1d42e4e93b6b5e2b48c2c2e/src/main.ts#L808-L838), [`src/main.ts:865-878`](https://github.com/bitfocus/companion-module-syncthingfoundation-syncthing/blob/ae19f13171bbaeaae1d42e4e93b6b5e2b48c2c2e/src/main.ts#L865-L878), [`src/variables.ts:208-249`](https://github.com/bitfocus/companion-module-syncthingfoundation-syncthing/blob/ae19f13171bbaeaae1d42e4e93b6b5e2b48c2c2e/src/variables.ts#L208-L249)

**What goes wrong:** `$(syncthing:connected)`, `$(syncthing:in_sync)`, `$(syncthing:all_in_sync)`, `$(syncthing:restart_required)` and the per-folder and per-device `_paused`, `_in_sync` and `_connected` variables hold the text `"true"` / `"false"`. `$(syncthing:completion)` holds text such as `"99.5"`, while the per-folder completion is a number. A user writing an expression like `$(syncthing:connected) == true` or `$(syncthing:completion) >= 100` has to know to compare against text. Buttons that only display the value look the same either way.

**Why it happens:** The module turns these values into strings before publishing them. In API 2.0 a variable value can be any JSON value, so real booleans and numbers are allowed.

**Fix:** publish real values (`connected: true`, `in_sync: localInSync(this.state)`, `completion: this.state.completion`). Doing it before the first published release avoids changing what existing expressions see later.

---

## 📝 Additional Notes

- **Prior review, C1 (lint config layout): fixed.** [`eslint.config.mjs`](https://github.com/bitfocus/companion-module-syncthingfoundation-syncthing/blob/ae19f13171bbaeaae1d42e4e93b6b5e2b48c2c2e/eslint.config.mjs) now stores the shared config in a variable and spreads it; the template check passes.
- **Prior review, H1 (module checks workflow): fixed.** [`.github/workflows/companion-module-checks.yaml`](https://github.com/bitfocus/companion-module-syncthingfoundation-syncthing/blob/ae19f13171bbaeaae1d42e4e93b6b5e2b48c2c2e/.github/workflows/companion-module-checks.yaml) matches the template again.
- **Prior review, H2 (upgrade-script secrets type): fixed.** [`src/upgrades.ts:4`](https://github.com/bitfocus/companion-module-syncthingfoundation-syncthing/blob/ae19f13171bbaeaae1d42e4e93b6b5e2b48c2c2e/src/upgrades.ts#L4) is now `CompanionStaticUpgradeScript<ModuleConfig, ModuleSecrets>[]`.
- **Prior review, M1 (feedbacks reject typed-in ids): fixed.** Actions and feedbacks now share the same folder and device fields with `allowCustom: true` ([`src/feedbacks.ts:51-82`](https://github.com/bitfocus/companion-module-syncthingfoundation-syncthing/blob/ae19f13171bbaeaae1d42e4e93b6b5e2b48c2c2e/src/feedbacks.ts#L51-L82)).
- **Prior review, L1 (folder variable names could collide): fixed.** The duplicate per-folder `errors` variable was removed (it held the same value as `pull_errors`), and a test now checks the suffixes can't collide. No folder variable name clashes remain.
- **Prior review, L2 (pause mode dropdowns): fixed.** `mode` is typed `PauseMode` / `PauseAllMode`, and all three mode dropdowns set `disableAutoExpression: true`.
- The new findings above were already present in v1.0.0 and weren't raised by that review. None of them blocks this release.
