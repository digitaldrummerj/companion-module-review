# Re-review: allenheath-dt168 v1.0.0-beta.2

| Field | Value |
| --- | --- |
| **Module** | `companion-module-allenheath-dt168` |
| **Repository** | [bitfocus/companion-module-allenheath-dt168](https://github.com/bitfocus/companion-module-allenheath-dt168) |
| **Scope** | `tag` |
| **Version** | v1.0.0-beta.2 (commit [`95800c5`](https://github.com/bitfocus/companion-module-allenheath-dt168/commit/95800c5c4c5a2452ff731ddb018f6262583b0598)) |
| **Release** | New module — never published |
| **API** | 2.1 (base 2.1.3, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-js` @ `89da037` (2026-11-01) |
| **Prior review** | [v1.0.0-beta.1 (2026-11-06)](review-allenheath-dt168-v1.0.0-beta.1-20261106-181511.md): every finding from it is fixed, see [📝 Additional Notes](#-additional-notes) |
| **Compared against** | Nothing published: this is still the first release, so there is no published diff and the whole module was reviewed again |
| **Build** | `yarn install --immutable` and `yarn package` pass (`allenheath-dt168-1.0.0-beta.2.tgz` built) |
| **Reviewed** | 2026-11-09 |

## Verdict: ❌ Changes Required

## ❓ Assumptions

Some findings depend on assumptions the reviewers couldn't check. They're listed in [❓ Assumptions to Confirm](#-assumptions-to-confirm) at the end of this review.

## 📋 Issues

### Blocking

- [ ] [H1: `yarn format` skips every file outside a fixed list of folders, unlike the template's whole-repository format](#h1-yarn-format-skips-every-file-outside-a-fixed-list-of-folders-unlike-the-templates-whole-repository-format)

### Non-blocking

- [ ] [L1: Entering the DT168 IP with leading zeros leaves the connection failing even though the device answers](#l1-entering-the-dt168-ip-with-leading-zeros-leaves-the-connection-failing-even-though-the-device-answers)
- [ ] [L2: README still says the packaged module was tested on Node 22](#l2-readme-still-says-the-packaged-module-was-tested-on-node-22)
- [ ] [N1: Unreachable missing-state check in the preamp change path](#n1-unreachable-missing-state-check-in-the-preamp-change-path)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟠 High

### H1: `yarn format` skips every file outside a fixed list of folders, unlike the template's whole-repository format

- **Source:** 🔎 compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`package.json:11`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/95800c5c4c5a2452ff731ddb018f6262583b0598/package.json#L11)

**What goes wrong:** Companion users see nothing different. The difference is for the maintainer and contributors. In the template, `yarn format` formats the whole repository. Here it only covers `src`, `test`, `companion`, `.github` and the root `*.md`/`*.json` files, so any other file is never formatted. For example, `prettier --check .` flags `.yarnrc.yml`, but neither `yarn format` nor `yarn format:check` (the check the CI workflow runs) ever looks at it. Anyone comparing the module with the template, or wondering why a file was not formatted, has one more difference to rule out.

**Why it happens:** The module replaced the template's `format` command with an explicit list of paths. The extra `format:check` script is an addition and is not a finding on its own. This line was already in v1.0.0-beta.1. The previous review's H3 (the `package.json` differences) should have listed it but didn't, which is why it only appears now.

**Evidence:**

```json
// package.json:7-13 (module, v1.0.0-beta.2)
	"scripts": {
		"package": "companion-module-build",
		"test": "node --test test/*.test.js",
		"check": "companion-module-check",
		"format": "prettier --write src test companion .github *.md *.json",
		"format:check": "prettier --check src test companion .github *.md *.json"
	},
```

```json
// companion-module-template-js/package.json:6-9 (template 89da037)
	"scripts": {
		"format": "prettier -w .",
		"package": "companion-module-build"
	},
```

```text
// prettier --check .  (run in the module clone, read-only)
Checking formatting...
[warn] .yarnrc.yml
[warn] Code style issues found in the above file. Run Prettier with --write to fix.
```

**Confirm by:** open [`package.json:11`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/95800c5c4c5a2452ff731ddb018f6262583b0598/package.json#L11) next to `companion-module-template-js/package.json` line 7. The template runs `prettier -w .`, while the module runs `prettier --write` on a fixed list of paths.

**Fix:** use the template's command. If you keep the extra `format:check` script, make it check the whole repository too.

```json
"format": "prettier -w .",
"format:check": "prettier --check ."
```

Running `yarn format` once afterwards re-quotes one line in `.yarnrc.yml` (`"@companion-module/*"` becomes `'@companion-module/*'`). Commit that change, or `yarn format:check` in CI will fail. The template check compares `.yarnrc.yml` by its keys, so the quote style doesn't matter there.

## 🟢 Low

### L1: Entering the DT168 IP with leading zeros leaves the connection failing even though the device answers

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/client.js:28`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/95800c5c4c5a2452ff731ddb018f6262583b0598/src/client.js#L28)

**What goes wrong:** Say a user types the "DT168 IPv4 address" as `192.168.001.010`, perhaps copied from a tool that zero-pads addresses. The field accepts it, because Companion's IP check allows leading zeros. The module sends its status polls, but every reply arrives from `192.168.1.10`, which doesn't match the saved text, so the module throws every reply away. The connection shows "Connection failure: No confirmed reply from DT168" and retries every 5 seconds, even though the DT168 is answering. Typing the address as `192.168.1.10` fixes it. Users who enter the address without leading zeros are not affected.

**Why it happens:** The module ignores any packet whose sender address isn't exactly the text in the config field. Node always reports the sender in its normal form (`192.168.1.10`), so a zero-padded config value never matches. The host text goes from the config field ([`src/main.js:39`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/95800c5c4c5a2452ff731ddb018f6262583b0598/src/main.js#L39), `regex: Regex.IP`) into the client unchanged ([`src/main.js:65`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/95800c5c4c5a2452ff731ddb018f6262583b0598/src/main.js#L65)), so the first refresh always times out. A local test that sent a packet to `127.000.000.001` received it from `127.0.0.1`.

```js
// src/client.js:27-28
const message = (b, r) => {
	if (r.address !== this.host) return
```

**Fix:** convert the address to its normal form once, before using it, so the sending and the reply filter use the same text. For example, in the `DTClient` constructor:

```js
this.host = host.trim().split('.').map((o) => String(Number(o))).join('.')
```

Alternatively, check the address in `connect()` with `net.isIPv4(this.config.host)` and set `InstanceStatus.BadConfig` with "Enter the IP without leading zeros".

### L2: README still says the packaged module was tested on Node 22

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`README.md:34`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/95800c5c4c5a2452ff731ddb018f6262583b0598/README.md#L34)

**What goes wrong:** Someone reading the README on GitHub sees "The packaged module was tested with Node 22 and the real module-base library". The module now runs on Node 26 (`"type": "node26"` in the manifest), and [`companion/HELP.md:23`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/95800c5c4c5a2452ff731ddb018f6262583b0598/companion/HELP.md#L23) says "Node 26 module runtime", so the two documents disagree. This is documentation only and doesn't change how the module behaves.

**Why it happens:** This release moved the module to Node 26 and updated HELP.md and the README's "Build and test" section ([`README.md:19`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/95800c5c4c5a2452ff731ddb018f6262583b0598/README.md#L19)), but missed this sentence in the "Beta scope" section.

**Fix:** change the sentence at [`README.md:34`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/95800c5c4c5a2452ff731ddb018f6262583b0598/README.md#L34) to say Node 26, or drop the Node version from it.

## 💡 Nice to Have

### N1: Unreachable missing-state check in the preamp change path

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/client.js:106-107`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/95800c5c4c5a2452ff731ddb018f6262583b0598/src/client.js#L106-L107)

**What goes wrong:** Users see nothing different; this is code quality only. When a channel has never been reported, a change still fails correctly with "No current preamp state", because the second half of the check catches it.

**Why it happens:** `{ ...this.states.get(channel) }` always produces an object, even when the map has no entry (`{ ...undefined }` is `{}`). So `!before` can never be true, and only `!before.seen` does any work. Someone reading the code could think the missing-state case depends on the first test.

```js
// src/client.js:106-107
const before = { ...this.states.get(channel) }
if (!before || !before.seen) throw Error('No current preamp state')
```

**Fix:** check the map entry before copying it.

```js
const current = this.states.get(channel)
if (!current?.seen) throw Error('No current preamp state')
const before = { ...current }
```

## 📝 Additional Notes

- **Follow-up to the [v1.0.0-beta.1 review](review-allenheath-dt168-v1.0.0-beta.1-20261106-181511.md).** Every finding from that review is fixed in v1.0.0-beta.2. No blocking finding from it is still open, and nothing was carried forward:
  - **C1-C4** (`.gitignore`, `.prettierignore`, `.yarnrc.yml`): fixed. All three files now match the template ([`.gitignore`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/95800c5c4c5a2452ff731ddb018f6262583b0598/.gitignore), [`.prettierignore`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/95800c5c4c5a2452ff731ddb018f6262583b0598/.prettierignore), [`.yarnrc.yml`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/95800c5c4c5a2452ff731ddb018f6262583b0598/.yarnrc.yml)).
  - **C5** (shared Prettier config): fixed. [`package.json:34`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/95800c5c4c5a2452ff731ddb018f6262583b0598/package.json#L34) sets `"prettier": "@companion-module/tools/.prettierrc.json"` and the custom `.prettierrc.json` is gone.
  - **C6** (Node 26): fixed in [`companion/manifest.json:17`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/95800c5c4c5a2452ff731ddb018f6262583b0598/companion/manifest.json#L17), [`package.json:16`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/95800c5c4c5a2452ff731ddb018f6262583b0598/package.json#L16), [`.github/workflows/test.yaml:17`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/95800c5c4c5a2452ff731ddb018f6262583b0598/.github/workflows/test.yaml#L17) and [`README.md:19`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/95800c5c4c5a2452ff731ddb018f6262583b0598/README.md#L19). One leftover sentence is [L2](#l2-readme-still-says-the-packaged-module-was-tested-on-node-22).
  - **H1** (ES module layout): fixed. `"type": "module"`, `main` and the manifest entrypoint point at `src/main.js`, which uses `export default class DT168Instance`, and `src/entry.mjs` is deleted ([`package.json:5-6`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/95800c5c4c5a2452ff731ddb018f6262583b0598/package.json#L5-L6), [`src/main.js:10-12`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/95800c5c4c5a2452ff731ddb018f6262583b0598/src/main.js#L10-L12)).
  - **H2** (Refresh all preamp states while disconnected): fixed. The action now goes through the same connection check as every other action and logs "DT168 is not connected" ([`src/actions.js:72-76`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/95800c5c4c5a2452ff731ddb018f6262583b0598/src/actions.js#L72-L76), [`src/main.js:125-128`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/95800c5c4c5a2452ff731ddb018f6262583b0598/src/main.js#L125-L128)).
  - **H3** (`package.json` differences): fixed. The `package` script is `companion-module-build`, `engines` includes `"yarn": "^4"`, and the dependency ranges match the template ([`package.json:8-25`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/95800c5c4c5a2452ff731ddb018f6262583b0598/package.json#L8-L25)). The `format` script that finding missed is [H1](#h1-yarn-format-skips-every-file-outside-a-fixed-list-of-folders-unlike-the-templates-whole-repository-format) here.
  - **H4** (README says the repository is not allocated): fixed. [`README.md:5`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/95800c5c4c5a2452ff731ddb018f6262583b0598/README.md#L5) now states the beta status.
  - **H5** (everything inline in `main.js`): fixed. [`src/upgrades.js`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/95800c5c4c5a2452ff731ddb018f6262583b0598/src/upgrades.js) exists, and actions, feedbacks, variables and presets are in their own files.
  - **M1** (aborting doesn't stop queued changes): fixed. The abort signal is passed to the client and checked before the state read and again before the send ([`src/actions.js:5-11`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/95800c5c4c5a2452ff731ddb018f6262583b0598/src/actions.js#L5-L11), [`src/client.js:101-110`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/95800c5c4c5a2452ff731ddb018f6262583b0598/src/client.js#L101-L110)).
  - **N1** (every poll re-sends everything): fixed. Only changed variables are sent, feedbacks are re-checked only when a pad, phantom or connected value changes, and the status is set to OK only when the connection comes online ([`src/main.js:70-77`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/95800c5c4c5a2452ff731ddb018f6262583b0598/src/main.js#L70-L77), [`src/main.js:106-124`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/95800c5c4c5a2452ff731ddb018f6262583b0598/src/main.js#L106-L124)).
  - **N2** (State option in expression mode): addressed with the suggested `expressionDescription` ([`src/actions.js:17`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/95800c5c4c5a2452ff731ddb018f6262583b0598/src/actions.js#L17)).

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | On Linux, the system address lookup may read zero-padded octets as octal (`010` becomes 8), so a zero-padded host could also send the polls to a different IP, which is worse than only dropping the replies | known glibc `inet_aton` behaviour; only macOS was tested, where `dns.lookup('192.168.001.010')` returned `192.168.1.10`. Linux was not tested. The main claim, that replies are dropped by the exact text comparison, was reproduced and holds on any OS | [L1](#l1-entering-the-dt168-ip-with-leading-zeros-leaves-the-connection-failing-even-though-the-device-answers) |
