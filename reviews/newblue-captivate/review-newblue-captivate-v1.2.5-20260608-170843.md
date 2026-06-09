# Review — newblue-captivate v1.2.5

| | |
|---|---|
| **Module** | newblue-captivate |
| **Review tag** | v1.2.5 |
| **Previous tag** | v1.2.4 |
| **Scope** | `tag` (only the `v1.2.4..v1.2.5` diff) |
| **API** | @companion-module/base `~1.12` (v1) · JS |
| **Runtime** | `nodejs-ipc`, entrypoint `../captivate.js` |
| **Date** | 2026-06-08 |

> **Note on scope.** The entire `v1.2.4..v1.2.5` diff is a **version bump only** — `"version": "1.2.4"` → `"1.2.5"` in `package.json` and `companion/manifest.json`, two lines, no code changed.

## Verdict

❌ **Changes Required**

## 📋 Issues

### 🔴 Critical (Blocking)

#### LICENSE file missing

`LICENSE` — the module declares `"license": "MIT"` in both `package.json` and the manifest, but no `LICENSE` file is present. The official template requires it.
**Fix:** add an MIT `LICENSE` file at the module root (copy the template's and set the copyright holder).

#### Source files at module root instead of `src/`

`captivate.js`, `bump-version.js` — all module source must live under `src/`. The entrypoint (`captivate.js`, ~38 KB) and helper scripts sit at the repo root, and the manifest entrypoint points at `../captivate.js` rather than the template's `../src/main.js`. The `lib/*.js` files are likewise outside `src/`.
**Fix:** move source under `src/` (e.g. `src/main.js` + `src/lib/…`), update `package.json` `main` and the manifest `runtime.entrypoint` accordingly. Regenerating from the current `companion-module-template-js-v1` is the cleanest path.

#### `package.json` missing required field `engines`

`package.json` — the template declares an `engines` field; it is absent here.
**Fix:** add the `engines` block from the current template.

#### `package.json` missing required field `packageManager`

`package.json` — the template pins the package manager (Yarn 4) via `packageManager`; it is absent here.
**Fix:** add the `packageManager` field matching the template.

#### `.yarnrc.yml` missing

`.yarnrc.yml` — required by the current template (Yarn 4 / Corepack toolchain). Absent.
**Fix:** add the template's `.yarnrc.yml`.

#### `.gitattributes` missing

`.gitattributes` — required template file is absent.
**Fix:** add the template's `.gitattributes`.

#### `.prettierignore` missing

`.prettierignore` — required template file is absent.
**Fix:** add the template's `.prettierignore`.

#### `.gitignore` missing required template entries

`.gitignore` — missing `node_modules/`, `/*.tgz`, `DEBUG-*`, and `/.yarn`. The current file ignores `node_modules` (no trailing slash) and `/pkg.tgz` but diverges from the template set, and does not ignore the `/.yarn` directory or `DEBUG-*` logs.
**Fix:** align `.gitignore` with the template, ensuring `node_modules/`, `/*.tgz`, `DEBUG-*`, and `/.yarn` are present.

#### Manifest `runtime.type` is `node18`

`companion/manifest.json` (`runtime.type`) — should be `node22` to match the current template/runtime.
**Fix:** set `"type": "node22"` in the manifest `runtime` block. (Manifest `api: "nodejs-ipc"` and `apiVersion: "0.0.0"` are correct — they match the template — no change needed there.)

#### destory is not closing the websocket

**`destroy()` does not tear down the socket or timers** — `captivate.js:160-162`. `destroy()` only logs. On module delete/disable the WebSocket is never closed, the `connectionWatchdog` `setInterval` (`captivate.js:274`) and the recurring `refreshIntegrations` schedule (`captivate.js:185`) keep firing, and the QWebChannel subscriptions (a `disconnectCallbacks()` helper exists but is never called) stay live. The socket is a local `let` rather than `this.socket`, so it cannot be reached from `destroy()`. *Suggested future fix:* store the socket on `this`; in `destroy()` close it, `clearInterval(this.connectionWatchdog)`, clear every timer in `this.scheduleRunner`, and call `disconnectCallbacks()`.

#### There is no need for the build.sh file

Companion has a build system built into it and having a custom module build system is not allowed as it can impact the ability to properly publish the module.  

#### configUpdated() open new connection without tearing down old one

**`configUpdated()` opens a new connection without tearing down the old one** — `captivate.js:164-174` → `initQWebChannel`. Each config change creates a fresh `WebSocket` and reconnect interval while the prior socket/watchdog remain live, so repeated edits stack orphaned sockets and overlapping reconnect loops. *Suggested future fix:* perform the same teardown at the top of `initQWebChannel()` before opening a new connection.

### Nice to Have (Non-Blocking)

#### There is no need to keep manifest.json and package.json version in sync

You can make the manifest.json version 0.0.0 as during the publish process, the version from package.json will be copied to the manifest.json version.