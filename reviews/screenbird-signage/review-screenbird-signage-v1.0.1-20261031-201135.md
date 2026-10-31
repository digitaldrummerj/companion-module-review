# Review: screenbird-signage v1.0.1 (follow-up)

| Field | Value |
| --- | --- |
| **Module** | `companion-module-screenbird-signage` |
| **Scope** | `tag` |
| **Version** | v1.0.1 |
| **Release** | New module — never published |
| **API** | 2.0 (base 2.0.4, yarn.lock) — requires Companion 4.3+ |
| **Template** | `companion-module-template-ts-v2.0.4` @ `d62230e` (2026-08-28, pinned) |
| **Review commit** | [`3b13111`](https://github.com/bitfocus/companion-module-screenbird-signage/tree/3b13111e83769150fdd9662eeadac25cc2f90e28) |
| **Prior review** | [v1.0.0 (2026-10-30)](review-screenbird-signage-v1.0.0-20261030-192328.md) — ❌ Changes Required |
| **Review date** | 2026-10-31 |

This is a follow-up to the v1.0.0 review. The module has still never been published, so this is still a first release: there is no published previous tag to diff against, and the whole module was reviewed again at v1.0.1. Every finding is classified 🆕 NEW. `yarn install --immutable`, `yarn package` and `yarn lint` all passed.

All seven findings from the v1.0.0 review are fixed in v1.0.1 (commit `3b13111`, "Module 1.0.1: review findings"):

| Prior finding | Status |
| --- | --- |
| C1: Prettier ignores a different license file than the template | ✅ Fixed: `.prettierignore` matches the template |
| C2: Yarn is missing the template's pre-approval for Companion packages | ✅ Fixed: `.yarnrc.yml` matches the template |
| C3: Yarn package age gate uses a different value than the template | ✅ Fixed: `npmMinimalAgeGate: 3d` |
| H1: CI builds on Node 26, but the module and the API 2.0 template use Node 22 | ✅ Fixed: `node.yaml` uses Node 22.x |
| H2: The CI checkout step differs from the API 2.0 template | ✅ Fixed: `node.yaml` matches the API 2.0 template |
| L1: Scene go and Scene stop with no scene chosen fail with an unclear HTTP error | ✅ Fixed: both actions now say "choose a scene" |
| N1: Unused refresh method on the module instance | ✅ Fixed: the method was removed |

## Verdict: ✅ Approved

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | In API 2.0, Companion 4.3+ checks a dropdown's saved value (not only an expression result) against the field's current choices, and refuses the action or skips the feedback when the value has no match and `allowCustom` is not set | The v2.0 compliance reference (expression validation, and the upgrade-script note that a bad value fails with "Value is not in the list of choices"); the `@companion-module/base` typings don't say whether plain values are checked, and Companion's host code was not checked | [L2](#l2-scene-and-screen-buttons-may-be-refused-while-the-scene-and-screen-lists-are-still-empty) |

## 📋 Issues

### Non-blocking

- [ ] [L1: Connection stays on Connecting forever when live updates can never open](#l1-connection-stays-on-connecting-forever-when-live-updates-can-never-open)
- [ ] [L2: Scene and screen buttons may be refused while the scene and screen lists are still empty](#l2-scene-and-screen-buttons-may-be-refused-while-the-scene-and-screen-lists-are-still-empty)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟢 Low

### L1: Connection stays on Connecting forever when live updates can never open

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/connection.ts:197-204`](https://github.com/bitfocus/companion-module-screenbird-signage/blob/3b13111e83769150fdd9662eeadac25cc2f90e28/src/connection.ts#L197-L204), [`src/connection.ts:387-411`](https://github.com/bitfocus/companion-module-screenbird-signage/blob/3b13111e83769150fdd9662eeadac25cc2f90e28/src/connection.ts#L387-L411)

**What goes wrong:** Take a user whose network allows normal HTTPS requests to `api.screenbird.app` but blocks the live-update WebSocket to `/v1/events` (a corporate proxy, for example). Scenes and screens load, and buttons such as "Scene: go" and "Stop all" work. But the connection status in Companion stays yellow, "Connecting – Waiting for the live connection", forever, and the log gets another "Screenbird refused the live connection" warning every 30 seconds. Feedbacks such as "Scene is live" only update after a button press on this connection, so changes made in Screenbird itself never show. Nothing tells the user that live updates are unavailable rather than still starting up. Users whose network allows the WebSocket are not affected.

**Why it happens:** The status shows Connecting whenever the scenes and screens are loaded but the live socket is not open. When the socket fails before it opens (a refused upgrade or a handshake timeout), the module only schedules another attempt, with the wait capped at 30 seconds. It never records a problem, so the status can't move from Connecting to a warning, however many attempts fail in a row.

**Fix:** count the socket attempts that fail before they open, and after a few in a row show a warning that explains the situation. Reset the count and clear the warning when a socket opens.

```ts
this.problem = {
	status: InstanceStatus.UnknownWarning,
	message: 'Live updates unavailable (the connection to /v1/events cannot open); feedbacks update only after button presses',
}
```

### L2: Scene and screen buttons may be refused while the scene and screen lists are still empty

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:145-154`](https://github.com/bitfocus/companion-module-screenbird-signage/blob/3b13111e83769150fdd9662eeadac25cc2f90e28/src/main.ts#L145-L154), [`src/actions.ts:19-32`](https://github.com/bitfocus/companion-module-screenbird-signage/blob/3b13111e83769150fdd9662eeadac25cc2f90e28/src/actions.ts#L19-L32), [`src/feedbacks.ts:16-29`](https://github.com/bitfocus/companion-module-screenbird-signage/blob/3b13111e83769150fdd9662eeadac25cc2f90e28/src/feedbacks.ts#L16-L29)

**What goes wrong:** Say a user has a "Scene: go" button set to the scene "Lobby", and Companion has just started, or the Screenbird API can't be reached yet. The scene list hasn't loaded, so the Scene dropdown has no choices. Companion may then refuse the press with "Value is not in the list of choices" before the module runs (see [A1](#-assumptions-to-confirm)). The module's own fallback, which sends the saved scene id anyway because "a press can be what brings the connection back", then never runs. In the same window, "Scene is live" and "Screen shows" feedbacks may be skipped instead of showing false. Once the lists load, normally within seconds, everything works, so the effect is limited to start-up and to recovery after the connection was stopped for a bad token or missing access.

**Why it happens:** The Scene, Screen and Content dropdowns take their choices from the loaded lists and don't set `allowCustom` (the dropdown setting that lets a value outside the list through). While the lists are empty, at start-up and after the module clears its state, no saved id matches a choice. The scene-id check in [`src/main.ts:145-154`](https://github.com/bitfocus/companion-module-screenbird-signage/blob/3b13111e83769150fdd9662eeadac25cc2f90e28/src/main.ts#L145-L154) was written to send the saved id in exactly this case, but it is not reached if Companion refuses the value first.

**Fix:** decide which behaviour you want. If presses during start-up should still reach Screenbird, add `allowCustom: true` to the Scene and Screen dropdowns in `src/actions.ts`; the module already rejects unknown ids with a clear error. Otherwise, remove the "sent as is" comment and branch in `resolveSceneId()`, since Companion handles that case.

```ts
const sceneOption = {
	type: 'dropdown',
	id: 'scene',
	label: 'Scene',
	choices: scenes,
	default: scenes[0]?.id ?? '',
	allowCustom: true,
} as const
```

## 📝 Additional Notes

- `tsconfig.build.json`: the `exclude` list differs from the template. The module has `["node_modules/**", "src/**/*.test.ts"]`; the template has `["node_modules/**", "src/**/*spec.ts", "src/**/__tests__/*", "src/**/__mocks__/*"]`. Fine as long as the module builds — no change required.
- `tsconfig.json`: the template's `compilerOptions` key is missing, and `exclude` is the last entry, without the template's trailing comma. Fine as long as the module builds — no change required.
- The module ships its own end-to-end test harness (`yarn test`, which runs `test/run-all.sh` against a local mock API). It was not run for this review, because it rebuilds `dist/` and `pkg/` inside the clone.
