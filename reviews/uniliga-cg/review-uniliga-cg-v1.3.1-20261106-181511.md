# Review: uniliga-cg v1.3.1 (follow-up to the v1.3.0 review)

| | |
| --- | --- |
| **Module** | [companion-module-uniliga-cg](https://github.com/bitfocus/companion-module-uniliga-cg) |
| **Scope** | `tag` |
| **Version** | v1.3.1 (`cbd16f2`) |
| **Release** | Update — last published v1.1.1 |
| **API** | 1 (base 1.12.1, yarn.lock) |
| **Template** | `companion-module-template-js-v1` @ `9e222b4` (2026-03-26, pinned) · `.yarnrc.yml` from `companion-module-template-js` @ `89da037` (2026-11-01) |
| **Prior review** | [v1.3.0, 2026-10-30](review-uniliga-cg-v1.3.0-20261030-192328.md) |
| **Reviewed** | 2026-11-06 |

## Verdict: ✅ Approved

## 📋 Issues

### Non-blocking

- [ ] [L1: Connection shows OK with an empty Project ID, but variables and feedbacks never fill in](#l1-connection-shows-ok-with-an-empty-project-id-but-variables-and-feedbacks-never-fill-in)
- [ ] [N1: Duplicate not-connected check when sending a command](#n1-duplicate-not-connected-check-when-sending-a-command)

### Notes

- **Commit messages:** one commit message in this release is in German (`9204868` "Action zum Steuern von Grafik-Animationen"). Please write future commit messages in English.
- [📝 Additional Notes](#-additional-notes)

## 🟢 Low

### L1: Connection shows OK with an empty Project ID, but variables and feedbacks never fill in

- **Source:** 🔎 protocol reviewer, QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:113-116`](https://github.com/bitfocus/companion-module-uniliga-cg/blob/cbd16f2d16f7915027d015c69776cc653ac6b0f7/src/main.js#L113-L116), [`src/main.js:175-183`](https://github.com/bitfocus/companion-module-uniliga-cg/blob/cbd16f2d16f7915027d015c69776cc653ac6b0f7/src/main.js#L175-L183), [`src/main.js:209`](https://github.com/bitfocus/companion-module-uniliga-cg/blob/cbd16f2d16f7915027d015c69776cc653ac6b0f7/src/main.js#L209), [`src/main.js:225-231`](https://github.com/bitfocus/companion-module-uniliga-cg/blob/cbd16f2d16f7915027d015c69776cc653ac6b0f7/src/main.js#L225-L231)

**What goes wrong:** A user adds a Uniliga CG connection, enters a valid Target URL (for example `wss://cg.example.org/ws`) and saves without filling in Project ID. The connection turns green (OK), but variables such as `$(uniliga-cg:left_name)` and `$(uniliga-cg:match_number)` stay empty, the "Graphic visible" and "Prediction bug visible" feedbacks never light up, and buttons appear to do nothing. Nothing in the connection status tells the user that the Project ID is missing. Users who filled in the Project ID are not affected.

**Why it happens:** New since v1.1.1, the module joins the project as soon as the WebSocket opens, and it ignores every state update whose project ID is not exactly the configured one. The connection setup only checks the Target URL before it reports Connecting and then OK, so an empty Project ID is never caught: the status says OK while the module's own filter throws away every update, because those carry a real project ID. This code was already in v1.3.0; the earlier review did not raise it.

**Evidence:**

```js
// src/main.js:113-116
joinProject() {
	this.sendRaw({ type: 'join', project_id: this.config.project_id })
	this.sendRaw({ type: 'load_all', project_id: this.config.project_id })
}
// src/main.js:169-175
const url = this.config.url
if (!url || url.match(new RegExp(this.wsRegex)) === null) {
	this.updateStatus(InstanceStatus.BadConfig, `WS URL is not defined or invalid`)
	return
}

this.updateStatus(InstanceStatus.Connecting)
// src/main.js:209
if (!message || !STATE_TYPES.includes(message.type) || message.project_id !== this.config.project_id) {
```

**Fix:** in `initWebSocket()`, after the URL check, report a bad configuration when the Project ID is empty. You can also mark the Project ID config field as required, so Companion highlights it in the connection settings.

```js
if (!this.config.project_id?.trim()) {
	this.updateStatus(InstanceStatus.BadConfig, 'Project ID is not set')
	return
}
```

```js
{
	type: 'textinput',
	id: 'project_id',
	label: 'Project ID',
	tooltip: 'Set the ID of the Project you want to control',
	width: 12,
	required: true,
},
```

## 💡 Nice to Have

### N1: Duplicate not-connected check when sending a command

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:118-122`](https://github.com/bitfocus/companion-module-uniliga-cg/blob/cbd16f2d16f7915027d015c69776cc653ac6b0f7/src/main.js#L118-L122), [`src/main.js:131-138`](https://github.com/bitfocus/companion-module-uniliga-cg/blob/cbd16f2d16f7915027d015c69776cc653ac6b0f7/src/main.js#L131-L138)

**What goes wrong:** Users see no difference; this is code quality only. The "is the WebSocket open?" check and its warning log are written out twice, once in `sendCommand()` and once in `sendRaw()`, so a later change to one can easily miss the other.

**Why it happens:** `sendCommand()` checks `!this.ws || this.ws.readyState !== WebSocket.OPEN` and logs its own warning, then calls `sendRaw()`, which repeats the same check with a second warning text.

**Fix:** keep the early return in `sendCommand()` (it stops the follow-up `load_all` from being sent), but move the check into one small helper that both methods call.

```js
isOpen() {
	return this.ws?.readyState === WebSocket.OPEN
}
```

## 📝 Additional Notes

- **Follow-up to the v1.3.0 review:** every finding from the [prior review](review-uniliga-cg-v1.3.0-20261030-192328.md) is fixed in v1.3.1, and the validator and the build are clean:
  - C1-C4: `.gitattributes`, `.gitignore`, `.prettierignore` and `.yarnrc.yml` now match the template (the extra `pkg` line in `.prettierignore` is generated build output and fine).
  - C5-C8: the source files moved to `src/`, and `package.json` `main` and the manifest `runtime.entrypoint` point at `src/main.js`.
  - C9-C13: `package.json` now has the `.git` repository URL, the template `engines`, `yarn@4.12.0`, the `package` script and `prettier` as a devDependency.
  - C14: [`companion/manifest.json:20`](https://github.com/bitfocus/companion-module-uniliga-cg/blob/cbd16f2d16f7915027d015c69776cc653ac6b0f7/companion/manifest.json#L20) names `node22`.
  - C15: `yarn install --immutable` and `yarn package` pass and produce `uniliga-cg-1.3.1.tgz`.
  - H1 and N1: the comments, variable names, graphic choices, preset names and HELP.md are now in English.
  - L1: the new upgrade script in [`src/upgrade.js:18-27`](https://github.com/bitfocus/companion-module-uniliga-cg/blob/cbd16f2d16f7915027d015c69776cc653ac6b0f7/src/upgrade.js#L18-L27) rewrites old "Restart Timer" actions from `start` to `restart`.
  - L2: [`src/main.js:84-88`](https://github.com/bitfocus/companion-module-uniliga-cg/blob/cbd16f2d16f7915027d015c69776cc653ac6b0f7/src/main.js#L84-L88) rebuilds the presets in `configUpdated()`, so they pick up a renamed connection.
- The review covers everything since the last published version (v1.1.1..v1.3.1), which includes the unpublished v1.2.0 and v1.3.0 tags.
