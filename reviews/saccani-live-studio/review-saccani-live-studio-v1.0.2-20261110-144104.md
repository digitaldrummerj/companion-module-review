# Companion Module Review: saccani-live-studio v1.0.2 (follow-up to the v1.0.1 review)

| Field | Value |
| --- | --- |
| **Module** | [companion-module-saccani-live-studio](https://github.com/bitfocus/companion-module-saccani-live-studio) |
| **Version** | v1.0.2 (commit [`7862c86`](https://github.com/bitfocus/companion-module-saccani-live-studio/commit/7862c8606fdd5a6beb31d0623fba03736e922f7b)) |
| **Release** | New module — never published |
| **API** | 2.0 (base 2.0.4, yarn.lock) — requires Companion 4.3+ |
| **Template** | `companion-module-template-ts-v2.0.4` @ `d62230e` (2026-08-28, pinned) · `.yarnrc.yml` from `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Scope** | `tag` — first release: no version has been published, so the whole module at v1.0.2 was reviewed again, and the changes since v1.0.1 (`v1.0.1..v1.0.2`) were checked against the v1.0.1 review |
| **Prior review** | [v1.0.1 review, 2026-11-09](review-saccani-live-studio-v1.0.1-20261109-172628.md) (❌ Changes Required): all 19 findings (C1–C5, H1–H7, M1, L1–L5, N1) are fixed in v1.0.2 |
| **Reviewed** | 2026-11-10 |

## Verdict: ✅ Approved

## ❓ Assumptions

Some findings depend on assumptions the reviewers couldn't check. They're listed in [❓ Assumptions to Confirm](#-assumptions-to-confirm) at the end of this review.

## 📋 Issues

### Non-blocking

- [ ] [N1: When the app doesn't answer, the connection status says a command was not retried, though no button was pressed](#n1-when-the-app-doesnt-answer-the-connection-status-says-a-command-was-not-retried-though-no-button-was-pressed)
- [ ] [N2: The README links to an API specification that returns 404 and says v1.0.2 is still awaiting review](#n2-the-readme-links-to-an-api-specification-that-returns-404-and-says-v102-is-still-awaiting-review)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 💡 Nice to Have

### N1: When the app doesn't answer, the connection status says a command was not retried, though no button was pressed

- **Source:** 🔎 protocol reviewer, QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/network-control.ts:138-141`](https://github.com/bitfocus/companion-module-saccani-live-studio/blob/7862c8606fdd5a6beb31d0623fba03736e922f7b/src/network-control.ts#L138-L141), [`src/main.ts:139`](https://github.com/bitfocus/companion-module-saccani-live-studio/blob/7862c8606fdd5a6beb31d0623fba03736e922f7b/src/main.ts#L139)

**What goes wrong:** A user enters the LAN address of the Mac running Saccani Live Studio, for example `http://192.168.1.40:8765`, in "App API URL". If that Mac is asleep or off the network, or the app is frozen, the module's background status check gets no answer within 5 seconds, and the connection shows Connection Failure with "Saccani Live Studio API request timed out; the command was not retried." ([A1](#-assumptions-to-confirm)). No button was pressed, so the message sends the user looking for a failed command instead of at the app not answering on that address. Nothing else breaks, and the status recovers once the app answers.

**Why it happens:** Every request uses the same 5-second timeout, both the commands that buttons send and the status check that runs every 250 ms, and the timeout's message is written for commands. A failed status check is shown as the connection status unchanged.

**Fix:** Use a neutral timeout message, such as `Saccani Live Studio at ${this.base.origin} did not answer within 5 s.`, and add "the command was not retried" only on the command path (for example with a flag that the command code passes to `http()`).

### N2: The README links to an API specification that returns 404 and says v1.0.2 is still awaiting review

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`README.md:17`](https://github.com/bitfocus/companion-module-saccani-live-studio/blob/7862c8606fdd5a6beb31d0623fba03736e922f7b/README.md#L17), [`README.md:80`](https://github.com/bitfocus/companion-module-saccani-live-studio/blob/7862c8606fdd5a6beb31d0623fba03736e922f7b/README.md#L80)

**What goes wrong:** A developer reading the module's GitHub page who follows "public API specification" gets GitHub's 404 page: the `Supergiovane/SaccaniLiveStudio` repository isn't visible to visitors who aren't signed in. Line 17 says "version 1.0.2 is awaiting Bitfocus review" and tells readers to import a `.tgz` until the module appears in Companion, which stops being true once the module is approved. Companion users see neither line, because the in-app help is `companion/HELP.md`.

**Why it happens:** The link points at a repository that isn't public, and the release-status sentence was written for the time before approval.

**Fix:** Link to a public copy of the specification (or remove the sentence if the repository is private on purpose), and reword line 17 so it doesn't depend on the review state, or drop it.

## 📝 Additional Notes

- The `resolutions` entry `"minimatch@npm:^10.2.2": "^11.0.1"` in `package.json` is still needed: without it, `yarn npm audit` reports GHSA-g3hv-75wg-m249 for the minimatch 10.2.6 that typescript-eslint pulls in. Keeping it is what the v1.0.1 review's H7 asked for; no change required.

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Companion shows the message passed to `updateStatus()` next to the connection's status in the Connections list, so users read the timeout text as written | `@companion-module/base` 2.0.4 forwards the message to the host; how Companion displays it was not checked | [N1](#n1-when-the-app-doesnt-answer-the-connection-status-says-a-command-was-not-retried-though-no-button-was-pressed) |
