# Review: mds-otobako-pro v1.1.0

| | |
| --- | --- |
| **Module** | `companion-module-mds-otobako-pro` |
| **Version** | v1.1.0 |
| **Release** | New module — never published |
| **API** | 2.1 (base 2.1.3, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-js` @ `76d25b2` (2026-10-11) |
| **Scope** | `tag` (first release: no previous tag to diff against, so the whole module was reviewed) |
| **Commit** | [`a41ab65`](https://github.com/bitfocus/companion-module-mds-otobako-pro/blob/a41ab6571d9535cd05c9d87816b58f14b9c89c7f) |
| **Reviewed** | 2026-10-30 |

This is the module's first release, so there is no diff: every finding below is classified 🆕 NEW.

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | When a preset is placed, Companion rewrites the hard-coded `$(otobako:…)` prefix in the preset text to the connection's real label, so the GO and Now playing presets show their variables even though the connection's default label (from the shortname "otobako Pro") is not `otobako`. If Companion 5 no longer does this, those two presets would show an unresolved variable and this would become a Medium finding | Reviewers' recollection of Companion's preset handling; not verifiable from the module or `@companion-module/base` | No finding today: the preset text in [`src/main.js:185`](https://github.com/bitfocus/companion-module-mds-otobako-pro/blob/a41ab6571d9535cd05c9d87816b58f14b9c89c7f/src/main.js#L185) and [`src/main.js:229`](https://github.com/bitfocus/companion-module-mds-otobako-pro/blob/a41ab6571d9535cd05c9d87816b58f14b9c89c7f/src/main.js#L229) |
| A2 | Node's built-in `fetch` (undici) keeps a reply's body, and possibly its connection, until the body is read, cancelled or garbage-collected | undici documentation guidance; not reproduced (running the module's code was not possible in this environment) | [N1](#n1-http-replies-are-left-unread-on-button-presses-and-failed-polls) |

## 📋 Issues

### Blocking

- [ ] [C1: Module runs on Node 22 instead of the Node 26 runtime of the API 2.1 template](#c1-module-runs-on-node-22-instead-of-the-node-26-runtime-of-the-api-21-template)
- [ ] [C2: `test.js` sits at the repository root instead of under `src/`](#c2-testjs-sits-at-the-repository-root-instead-of-under-src)
- [ ] [H1: LICENSE does not match the template](#h1-license-does-not-match-the-template)

### Non-blocking

- [ ] [M1: Access token is stored and shown as plain connection config, not as a secret](#m1-access-token-is-stored-and-shown-as-plain-connection-config-not-as-a-secret)
- [ ] [M2: Release workflow file is missing](#m2-release-workflow-file-is-missing)
- [ ] [L1: Connection status says only fetch failed when the Mac cannot be reached](#l1-connection-status-says-only-fetch-failed-when-the-mac-cannot-be-reached)
- [ ] [L2: A token pasted with a trailing space is rejected as an invalid token](#l2-a-token-pasted-with-a-trailing-space-is-rejected-as-an-invalid-token)
- [ ] [L3: Cancelled actions keep waiting for their HTTP request](#l3-cancelled-actions-keep-waiting-for-their-http-request)
- [ ] [N1: HTTP replies are left unread on button presses and failed polls](#n1-http-replies-are-left-unread-on-button-presses-and-failed-polls)
- [ ] [N2: Variables are re-sent to Companion every 500 ms even when nothing changed](#n2-variables-are-re-sent-to-companion-every-500-ms-even-when-nothing-changed)

## 🔴 Critical

### C1: Module runs on Node 22 instead of the Node 26 runtime of the API 2.1 template

- **Source:** 🤖 validate-template (MAN-RUNTIME)
- **Classification:** 🆕 NEW
- **File:** [`companion/manifest.json`](https://github.com/bitfocus/companion-module-mds-otobako-pro/blob/a41ab6571d9535cd05c9d87816b58f14b9c89c7f/companion/manifest.json), [`package.json`](https://github.com/bitfocus/companion-module-mds-otobako-pro/blob/a41ab6571d9535cd05c9d87816b58f14b9c89c7f/package.json)

**What goes wrong:** Companion starts the module on the Node 22 runtime, while every other API 2.1 module built from the current template runs on Node 26. The module is then tested and supported on a different runtime from the rest of the API 2.1 modules, which makes later problems harder to troubleshoot.

**Why it happens:** The manifest's `runtime.type` tells Companion which Node version to run the module on. The module declares `node22`; the API 2.1 template declares `node26`. `package.json` `engines.node` is also still `^22.20`, where the template has `^26`.

**Evidence:**

```text
companion/manifest.json  runtime.type
  Template expects: "type": "node26"
  Found:            "type": "node22"
package.json  engines.node
  Template expects: "^26"
  Found:            "^22.20"
```

**Confirm by:** open [`companion/manifest.json`](https://github.com/bitfocus/companion-module-mds-otobako-pro/blob/a41ab6571d9535cd05c9d87816b58f14b9c89c7f/companion/manifest.json) and look at `runtime.type`.

**Fix:** switch both the manifest runtime and the Node engine to Node 26, as in the template.

```json
"runtime": { "type": "node26", "api": "nodejs-ipc", "apiVersion": "0.0.0", "entrypoint": "../src/main.js" }
```

```json
"engines": { "node": "^26" }
```

### C2: `test.js` sits at the repository root instead of under `src/`

- **Source:** 🤖 validate-template (SRC-AT-ROOT)
- **Classification:** 🆕 NEW
- **File:** [`test.js`](https://github.com/bitfocus/companion-module-mds-otobako-pro/blob/a41ab6571d9535cd05c9d87816b58f14b9c89c7f/test.js)

**What goes wrong:** Users won't see anything different. The repository layout doesn't match the template: all module source belongs under `src/`, and a JavaScript file at the root is outside the structure that reviewers and the build tools expect.

**Why it happens:** `test.js` is a `node --test` file (run by the `test` script in `package.json`) that imports `./src/main.js` and `./node_modules/@companion-module/base/generated/validate_manifest.js` from the repository root.

**Evidence:**

```text
test.js: source file at module root. All source must be under src/.
```

**Confirm by:** open [`test.js:1-11`](https://github.com/bitfocus/companion-module-mds-otobako-pro/blob/a41ab6571d9535cd05c9d87816b58f14b9c89c7f/test.js#L1-L11).

**Fix:** move the test under `src/` (or a tests folder) and adjust its relative imports, or remove it.

```js
// e.g. src/main.test.js
import validate from '../node_modules/@companion-module/base/generated/validate_manifest.js'
import Instance from './main.js'
```

## 🟠 High

### H1: LICENSE does not match the template

- **Source:** 🤖 validate-template (LICENSE-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`LICENSE:3`](https://github.com/bitfocus/companion-module-mds-otobako-pro/blob/a41ab6571d9535cd05c9d87816b58f14b9c89c7f/LICENSE#L3)

**What goes wrong:** The module's license text differs from the one every Companion module ships with.

**Why it happens:** Line 3 of `LICENSE` was changed from the template's copyright line.

**Evidence:**

```text
LICENSE line 3
  Template expects: Copyright (c) 2022 Bitfocus AS - Open Source
  Found:            Copyright (c) 2026 MDS, Inc.
```

**Confirm by:** open [`LICENSE:3`](https://github.com/bitfocus/companion-module-mds-otobako-pro/blob/a41ab6571d9535cd05c9d87816b58f14b9c89c7f/LICENSE#L3).

**Fix:** replace `LICENSE` with the template's `LICENSE` verbatim.

## 🟡 Medium

### M1: Access token is stored and shown as plain connection config, not as a secret

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:93-100`](https://github.com/bitfocus/companion-module-mds-otobako-pro/blob/a41ab6571d9535cd05c9d87816b58f14b9c89c7f/src/main.js#L93-L100)

**What goes wrong:** A user pastes the token from otobako Pro's "External Control" screen into the connection's "Token / トークン" field. The token then shows in clear text in the connection settings and is included whenever the user exports their Companion config or shares a config file. Anyone on the venue network who gets that export can trigger GO, Stop and the pads.

**Why it happens:** The token field is an ordinary text field (`type: 'textinput'`), so its value sits in the normal config store. Base 2.1.3 offers a `secret-text` field type whose value Companion keeps in a separate secrets store and hands to the module as the `secrets` argument of `init(config, isFirstInit, secrets)` and `configUpdated(config, secrets)`. Because this is the first release, no saved configs need migrating.

**Fix:** make the token a secret field and read it from the secrets the module receives.

```js
{ type: 'secret-text', id: 'token', label: 'Token / トークン', width: 12, default: '' }

async init(config, isFirstInit, secrets) { this.config = config; this.secrets = secrets; /* … */ }
async configUpdated(config, secrets) { this.config = config; this.secrets = secrets; this.startPolling() }

// in buildURL()
const token = (this.secrets?.token || '').trim()
```

### M2: Release workflow file is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.github/workflows/release.yaml` (missing)

**What goes wrong:** The repository has no release workflow, so it doesn't follow the release process every module built from the template uses.

**Why it happens:** The template tracks `.github/workflows/release.yaml`; the module only has `.github/workflows/companion-module-checks.yaml`.

**Evidence:**

```text
.github/workflows/release.yaml: tracked by companion-module-template-js, not present in the module
```

**Confirm by:** list [`.github/workflows/`](https://github.com/bitfocus/companion-module-mds-otobako-pro/tree/a41ab6571d9535cd05c9d87816b58f14b9c89c7f/.github/workflows). Only `companion-module-checks.yaml` is there.

**Fix:** copy `.github/workflows/release.yaml` from `companion-module-template-js` unchanged.

## 🟢 Low

### L1: Connection status says only fetch failed when the Mac cannot be reached

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:310-312`](https://github.com/bitfocus/companion-module-mds-otobako-pro/blob/a41ab6571d9535cd05c9d87816b58f14b9c89c7f/src/main.js#L310-L312), [`src/main.js:361-363`](https://github.com/bitfocus/companion-module-mds-otobako-pro/blob/a41ab6571d9535cd05c9d87816b58f14b9c89c7f/src/main.js#L361-L363)

**What goes wrong:** A user enters the wrong address (192.168.1.21 instead of .20), the wrong port, or a `MyMac.local` name that Windows can't resolve. The connection turns red, but the status text only says "fetch failed" or "This operation was aborted". It doesn't say whether the connection was refused, the name couldn't be resolved or the Mac didn't answer in time, so the user can't tell which setting to fix.

**Why it happens:** Both error handlers show `error.message`. Node's `fetch` always reports "fetch failed" and puts the real reason (`ECONNREFUSED`, `ENOTFOUND`, `EHOSTUNREACH`) in `error.cause`; the module's own 2-second timeout produces the generic abort message.

**Fix:** build the status text from the underlying cause, and name the timeout explicitly.

```js
const reason =
	error?.name === 'AbortError'
		? `Timeout (no reply from ${host}:${port})`
		: (error?.cause?.code ?? error?.cause?.message ?? error?.message ?? String(error))
this.updateStatus(InstanceStatus.ConnectionFailure, reason)
```

### L2: A token pasted with a trailing space is rejected as an invalid token

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:274-278`](https://github.com/bitfocus/companion-module-mds-otobako-pro/blob/a41ab6571d9535cd05c9d87816b58f14b9c89c7f/src/main.js#L274-L278)

**What goes wrong:** A user copies the token from otobako Pro and pastes it with a trailing space, which often happens when copying from a dialog. Every poll and every button press then fails, and the connection shows "Invalid token / トークンが違います" even though the token looks right in the field. The Address field forgives the same mistake.

**Why it happens:** `buildURL()` trims the host but uses the token as typed, so the space is sent as part of the token (`?token=abc%20`).

**Fix:** trim the token the same way as the host.

```js
const token = (this.config?.token || '').trim()
```

### L3: Cancelled actions keep waiting for their HTTP request

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:114-145`](https://github.com/bitfocus/companion-module-mds-otobako-pro/blob/a41ab6571d9535cd05c9d87816b58f14b9c89c7f/src/main.js#L114-L145), [`src/main.js:286-323`](https://github.com/bitfocus/companion-module-mds-otobako-pro/blob/a41ab6571d9535cd05c9d87816b58f14b9c89c7f/src/main.js#L286-L323)

**What goes wrong:** A user presses a button running "GO (play and advance)" or "Play pad" while the Mac is unreachable, then the action is cancelled (for example the button's actions are aborted or the connection is disabled). The request keeps waiting up to its 2-second timeout anyway, so a connection-failure status or log line can still appear after the action was cancelled. The 2-second cap keeps the effect small.

**Why it happens:** API 2.1 passes each action callback a `context` with an abort `signal` for network work. The callbacks don't accept `context`, and `fetchWithTimeout()` only uses its own timeout controller.

**Fix:** pass the action's abort signal through and combine it with the timeout.

```js
callback: async (action, context) => this.send('/go', context.signal),

// fetchWithTimeout(url, signal)
const timeout = AbortSignal.timeout(REQUEST_TIMEOUT)
return fetch(url, { signal: signal ? AbortSignal.any([signal, timeout]) : timeout })
```

## 💡 Nice to Have

### N1: HTTP replies are left unread on button presses and failed polls

- **Source:** 🔎 protocol reviewer + QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:293-309`](https://github.com/bitfocus/companion-module-mds-otobako-pro/blob/a41ab6571d9535cd05c9d87816b58f14b9c89c7f/src/main.js#L293-L309), [`src/main.js:349-357`](https://github.com/bitfocus/companion-module-mds-otobako-pro/blob/a41ab6571d9535cd05c9d87816b58f14b9c89c7f/src/main.js#L349-L357)

**What goes wrong:** Users won't see anything different; this is code hygiene. When GO, Stop, Fade out, Next/Prev or a pad is pressed, and whenever a status poll gets a 401 or another error reply (every 500 ms with a wrong token), the module checks only the HTTP status code and never reads or discards the reply. Node's `fetch` recommends always doing one or the other, so the connection is released straight away (see A2).

**Why it happens:** `send()` and the 401 / non-OK branches of `poll()` return without reading the body; only the successful poll reads it with `response.json()`.

**Fix:** discard the reply body whenever it isn't needed.

```js
await response.body?.cancel().catch(() => {})
```

### N2: Variables are re-sent to Companion every 500 ms even when nothing changed

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:367-378`](https://github.com/bitfocus/companion-module-mds-otobako-pro/blob/a41ab6571d9535cd05c9d87816b58f14b9c89c7f/src/main.js#L367-L378)

**What goes wrong:** No visible effect. The module sends the `playing`, `standby` and `se_count` variables to Companion twice a second, even while nothing is playing, which is constant traffic that achieves nothing. Feedbacks are already re-checked only on a change.

**Why it happens:** `applyStatus()` compares the playing / fading state before calling `checkFeedbacks()`, but calls `setVariableValues()` on every poll.

**Fix:** remember the last values sent and send only the ones that changed.

```js
const next = { playing: status?.playing ?? '', standby: status?.standby ?? '', se_count: status?.seCount ?? 0 }
const changedVars = Object.fromEntries(Object.entries(next).filter(([k, v]) => this.lastVars?.[k] !== v))
if (Object.keys(changedVars).length) this.setVariableValues(changedVars)
this.lastVars = next
```
