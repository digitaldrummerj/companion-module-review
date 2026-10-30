# Review: generic-ptpv2-client v2.1.0

| Field | Value |
| --- | --- |
| **Module** | [companion-module-generic-ptpv2-client](https://github.com/bitfocus/companion-module-generic-ptpv2-client) |
| **Scope** | `tag` (v2.0.0..v2.1.0) |
| **Version** | v2.1.0 |
| **Release** | Update — last published v2.0.0 |
| **API** | 2.2 (base 2.2.1, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Review commit** | [`93d86ee`](https://github.com/bitfocus/companion-module-generic-ptpv2-client/commit/93d86ee086598ed4adb2fc889c1f28ac48f0ef85) |
| **Reviewed** | 2026-10-30 |

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | When several UDP sockets on one computer share port 320 (Node `dgram` with `reuseAddr: true`), the OS delivers a unicast datagram to only one of them, not necessarily the one that sent the request, while multicast reaches all of them | General Linux/macOS/Windows socket behaviour and libuv's handling of `UV_UDP_REUSEADDR`; the module's own [`companion/HELP.md:120`](https://github.com/bitfocus/companion-module-generic-ptpv2-client/blob/93d86ee086598ed4adb2fc889c1f28ac48f0ef85/companion/HELP.md#L120) states the same premise. Which socket the OS picks was not reproduced | [M1](#m1-with-unicast-delay-requests-on-a-lost-reply-is-blamed-on-the-master-and-the-options-own-help-gives-no-warning), [L3](#l3-help-advice-to-enable-unicast-delay-requests-on-one-connection-only-may-still-leave-that-connection-unable-to-lock) |
| A2 | Companion runs each connection in its own process, so two connections on one computer each bind their own sockets to ports 319/320 | Companion's per-connection child-process model, also stated in the module's `randomPortNumber()` comment in `src/ptpv2.ts`; Companion's host code not checked | [M1](#m1-with-unicast-delay-requests-on-a-lost-reply-is-blamed-on-the-master-and-the-options-own-help-gives-no-warning), [L3](#l3-help-advice-to-enable-unicast-delay-requests-on-one-connection-only-may-still-leave-that-connection-unable-to-lock) |

## 📋 Issues

### Blocking

- [ ] [C1: Repository has no `.gitattributes`, so line endings are not pinned to LF](#c1-repository-has-no-gitattributes-so-line-endings-are-not-pinned-to-lf)
- [ ] [C2: Editor settings folder `/.vscode` is not ignored by git](#c2-editor-settings-folder-vscode-is-not-ignored-by-git)
- [ ] [C3: Yarn config adds a setting the template does not have](#c3-yarn-config-adds-a-setting-the-template-does-not-have)
- [ ] [H1: Node CI workflow (`node.yaml`) differs from the template](#h1-node-ci-workflow-nodeyaml-differs-from-the-template)
- [ ] [H2: Release workflow (`release.yaml`) builds its own package instead of using the shared Bitfocus build](#h2-release-workflow-releaseyaml-builds-its-own-package-instead-of-using-the-shared-bitfocus-build)

### Non-blocking

- [ ] [M1: With Unicast Delay Requests on, a lost reply is blamed on the master and the option's own help gives no warning](#m1-with-unicast-delay-requests-on-a-lost-reply-is-blamed-on-the-master-and-the-options-own-help-gives-no-warning)
- [ ] [L1: Sync rate, Sync loss and Multiple Masters values freeze when Syncs stop arriving](#l1-sync-rate-sync-loss-and-multiple-masters-values-freeze-when-syncs-stop-arriving)
- [ ] [L2: One out-of-order Sync is counted as two lost Syncs](#l2-one-out-of-order-sync-is-counted-as-two-lost-syncs)
- [ ] [L3: Help advice to enable Unicast Delay Requests on one connection only may still leave that connection unable to lock](#l3-help-advice-to-enable-unicast-delay-requests-on-one-connection-only-may-still-leave-that-connection-unable-to-lock)
- [ ] [N1: Every connection start or config save logs the first master as a warning](#n1-every-connection-start-or-config-save-logs-the-first-master-as-a-warning)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🔴 Critical

### C1: Repository has no `.gitattributes`, so line endings are not pinned to LF

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW (template requirement; the file is also absent at v2.0.0)
- **File:** `.gitattributes` (missing)

**What goes wrong:** A contributor who checks the repo out on Windows can commit files with CRLF line endings, which then show up as whole-file diffs and can break the lint and formatting checks.

**Why it happens:** Every module built from the template ships a `.gitattributes` that tells git to store text files with LF endings. This repo has none.

**Evidence:** template expects `.gitattributes` containing `* text=auto eol=lf`; found: no `.gitattributes` at the repo root.

**Confirm by:** `ls .gitattributes` at the repo root fails.

**Fix:** copy the template's `.gitattributes`.

```text
* text=auto eol=lf
```

### C2: Editor settings folder `/.vscode` is not ignored by git

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW (template requirement; the file is unchanged since v2.0.0)
- **File:** [`.gitignore:1-10`](https://github.com/bitfocus/companion-module-generic-ptpv2-client/blob/93d86ee086598ed4adb2fc889c1f28ac48f0ef85/.gitignore#L1-L10)

**What goes wrong:** Personal VS Code settings in `.vscode/` can be committed by accident and end up in every contributor's checkout.

**Why it happens:** The template's `.gitignore` lists `/.vscode`; this one does not. The extra `/coverage` and `.DS_Store` entries are fine.

**Evidence:**

```text
// .gitignore:1-9
node_modules/
package-lock.json
/pkg
/*.tgz
/dist
/coverage
DEBUG-*
/.yarn
.DS_Store
```

**Confirm by:** `grep -n '/.vscode' .gitignore` returns nothing.

**Fix:** add the template entry.

```text
/.vscode
```

### C3: Yarn config adds a setting the template does not have

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW (template requirement; the file is unchanged since v2.0.0)
- **File:** [`.yarnrc.yml:1-2`](https://github.com/bitfocus/companion-module-generic-ptpv2-client/blob/93d86ee086598ed4adb2fc889c1f28ac48f0ef85/.yarnrc.yml#L1-L2)

**What goes wrong:** The module's Yarn setup is no longer the one every other module uses, so installs and supply-chain protections behave differently from what Bitfocus expects when building it.

**Why it happens:** The template's `.yarnrc.yml` holds only `enableScripts`, `nodeLinker`, `npmMinimalAgeGate` and `npmPreapprovedPackages`. This one adds `approvedGitRepositories` set to approve every Git repository (`'**'`).

**Evidence:**

```yaml
# .yarnrc.yml:1-2
approvedGitRepositories:
  - '**'
```

**Confirm by:** `sed -n '1,3p' .yarnrc.yml`.

**Fix:** remove the `approvedGitRepositories` block so the file matches the template.

## 🟠 High

### H1: Node CI workflow (`node.yaml`) differs from the template

- **Source:** 🤖 validate-template (CONFIG-DIFF), raised to High by the review maintainer's `.github` rule (validator: Medium)
- **Classification:** 🆕 NEW (changed in this release: `node.yaml` 13 +-)
- **File:** [`.github/workflows/node.yaml:11-12`](https://github.com/bitfocus/companion-module-generic-ptpv2-client/blob/93d86ee086598ed4adb2fc889c1f28ac48f0ef85/.github/workflows/node.yaml#L11-L12), [`.github/workflows/node.yaml:21-38`](https://github.com/bitfocus/companion-module-generic-ptpv2-client/blob/93d86ee086598ed4adb2fc889c1f28ac48f0ef85/.github/workflows/node.yaml#L21-L38), [`.github/workflows/node.yaml:47-81`](https://github.com/bitfocus/companion-module-generic-ptpv2-client/blob/93d86ee086598ed4adb2fc889c1f28ac48f0ef85/.github/workflows/node.yaml#L47-L81)

**What goes wrong:** The module's CI no longer matches the template every module shares, so when a build or CI problem comes up it can't be compared against (or fixed like) the other modules.

**Why it happens:** This release edited the workflow away from the template:

- adds a top-level `permissions: contents: read` block (lines 11-12);
- `actions/checkout@v7` without the template's `with: persist-credentials: false` (line 21);
- `actions/setup-node@v7` where the template uses `@v6` (line 24);
- removes the template step "Prepare Environment (For template repository)";
- adds `yarn test:types` to the build step (line 38);
- adds an enabled `test` job that runs `yarn test:coverage` and uploads to `codecov/codecov-action@v7` (lines 47-81); the template ships the test job commented out, using `setup-node@v6` and `yarn test`.

**Evidence:**

```yaml
# .github/workflows/node.yaml:11-12
permissions:
  contents: read
# .github/workflows/node.yaml:21-24
      - uses: actions/checkout@v7
      - name: Use Node.js 26.x
        # This should match the version of Node.js you have defined in the manifest.json runtime field
        uses: actions/setup-node@v7
```

Template (`companion-module-template-ts/.github/workflows/node.yaml:18-23`):

```yaml
      - uses: actions/checkout@v7
        with:
          persist-credentials: false
      - name: Use Node.js 26.x
        # This should match the version of Node.js you have defined in the manifest.json runtime field
        uses: actions/setup-node@v6
```

**Confirm by:** `diff companion-module-template-ts/.github/workflows/node.yaml .github/workflows/node.yaml`.

**Fix:** copy the template's `node.yaml`. Uncommenting the template's own test job is fine if you want tests in CI.

### H2: Release workflow (`release.yaml`) builds its own package instead of using the shared Bitfocus build

- **Source:** 🤖 validate-template (CONFIG-DIFF), raised to High by the review maintainer's `.github` rule (validator: Medium)
- **Classification:** 🆕 NEW (file added in this release: `release.yaml` +65)
- **File:** [`.github/workflows/release.yaml:10-65`](https://github.com/bitfocus/companion-module-generic-ptpv2-client/blob/93d86ee086598ed4adb2fc889c1f28ac48f0ef85/.github/workflows/release.yaml#L10-L65)

**What goes wrong:** The package attached to a GitHub release is built by the module's own steps, a `--dev` build, rather than by Bitfocus's shared module workflow that the template uses. Testers can get a package that differs from what the shared build produces, and release problems can't be diagnosed the same way as for other modules.

**Why it happens:** The template's release workflow has a `package` job that calls `bitfocus/actions/.github/workflows/module-checks.yaml@main` (with `git-ref`, `prerelease`, `upload-artifact`, guarded by `if: !contains(github.repository, 'companion-module-template-')`) and a separate `attach` job that downloads the `pkg` artifact, renames it to `<name>-<version>.tgz` and uploads it. This module replaces both with a single job that checks out, installs, runs `yarn package --dev [--prerelease]` and uploads `./*.tgz` with `gh release upload`. It also adds a comment block at lines 10-13.

**Evidence:**

```yaml
# .github/workflows/release.yaml:15-16
  package:
    name: Package and attach to release
# .github/workflows/release.yaml:49-54
        run: |
          if [ "$IS_PRERELEASE" = 'true' ]; then
            yarn package --dev --prerelease
          else
            yarn package --dev
          fi
# .github/workflows/release.yaml:62-63
        run: |
          gh release upload "${{ github.event.release.tag_name }}" ./*.tgz --clobber
```

Template (`companion-module-template-ts/.github/workflows/release.yaml:11-20`):

```yaml
  package:
    name: Package module

    # The template itself cannot be packaged, as its manifest still holds placeholders
    if: ${{ !contains(github.repository, 'companion-module-template-') }}

    permissions:
      packages: read

    uses: bitfocus/actions/.github/workflows/module-checks.yaml@main
```

**Confirm by:** `diff companion-module-template-ts/.github/workflows/release.yaml .github/workflows/release.yaml`.

**Fix:** replace the file with the template's `release.yaml`.

## 🟡 Medium

### M1: With Unicast Delay Requests on, a lost reply is blamed on the master and the option's own help gives no warning

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:278-290`](https://github.com/bitfocus/companion-module-generic-ptpv2-client/blob/93d86ee086598ed4adb2fc889c1f28ac48f0ef85/src/main.ts#L278-L290), [`src/config.ts:120-131`](https://github.com/bitfocus/companion-module-generic-ptpv2-client/blob/93d86ee086598ed4adb2fc889c1f28ac48f0ef85/src/config.ts#L120-L131), [`src/ptpv2.ts:1041-1063`](https://github.com/bitfocus/companion-module-generic-ptpv2-client/blob/93d86ee086598ed4adb2fc889c1f28ac48f0ef85/src/ptpv2.ts#L1041-L1063), [`src/ptpv2.ts:521-522`](https://github.com/bitfocus/companion-module-generic-ptpv2-client/blob/93d86ee086598ed4adb2fc889c1f28ac48f0ef85/src/ptpv2.ts#L521-L522)

**What goes wrong:** A user adds two PTP connections that watch the same network card, for example PTPv2 domain 0 and domain 127, or one PTPv1 and one PTPv2 connection (a setup this release explicitly supports). They tick the new "Unicast Delay Requests" checkbox on both. The master's reply goes back unicast to the computer, the OS hands it to only one of the connections, and the other never completes an exchange: "PTP Synced" stays off, `$(ptp:delayResponding)` goes false, and the log says "Delay Requests are already unicast, so the master itself is not responding — check that it permits them." That advice is wrong: the master is answering, but the reply went to the other connection. `companion/HELP.md` warns against this setup, but the checkbox's own help text in the connection settings, which is what most users read, says nothing about it. Multicast mode (the default) is not affected.

**Why it happens:** Each connection binds its sockets to ports 319/320 with `reuseAddr: true` and tells replies apart by a random port number in the request. Multicast replies are copied to every socket, so that works; a unicast reply to the computer's address goes to only one of the sockets sharing the port (see [A1](#-assumptions-to-confirm)). The warning in `listenForMasterContention` assumes the master is at fault whenever unicast is on.

**Fix:** add the "only one connection per interface" warning to the "Unicast Delay Requests" help text in the connection settings, and reword the log message so it also names another connection or PTP application on this computer sharing port 320 as a possible cause, instead of saying only that the master is not responding. Optionally fall back to multicast after several unanswered unicast requests and report it in a variable.

## 🟢 Low

### L1: Sync rate, Sync loss and Multiple Masters values freeze when Syncs stop arriving

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/ptpv2.ts:1253-1258`](https://github.com/bitfocus/companion-module-generic-ptpv2-client/blob/93d86ee086598ed4adb2fc889c1f28ac48f0ef85/src/ptpv2.ts#L1253-L1258), [`src/ptpv2.ts:1279-1284`](https://github.com/bitfocus/companion-module-generic-ptpv2-client/blob/93d86ee086598ed4adb2fc889c1f28ac48f0ef85/src/ptpv2.ts#L1279-L1284), [`src/main.ts:305-314`](https://github.com/bitfocus/companion-module-generic-ptpv2-client/blob/93d86ee086598ed4adb2fc889c1f28ac48f0ef85/src/main.ts#L305-L314) (same helpers in `src/ptpv1.ts`)

**What goes wrong:** A user puts `$(ptp:syncRate)` and `$(ptp:syncLossPercent)` on a button to watch for multicast loss. If multicast is dropped completely, the case these figures exist for, the button keeps showing the last good values (for example "Sync Messages Received (per second)" = 8 and "Sync Messages Lost (%)" = 0) instead of falling to 0 and rising. The "Multiple PTP Masters Detected" feedback and `$(ptp:masterContention)` also stay true if both masters go quiet. The connection status and the sync feedback do show the loss, so the user is not completely blind.

**Why it happens:** The new metrics update (`metrics_changed`) is only sent when a Sync or Announce arrives, and master contention is only re-checked when a Sync arrives. The Sync-timeout and master-lost paths don't recompute or publish these values, so they stop updating exactly when nothing is arriving.

**Fix:** in the Sync-receipt timeout callback (`startSyncTimeout` in both clients), also emit `metrics_changed` and re-check contention. Alternatively run a 1-second interval while the client is alive (cleared in `destroy()`) that emits `metrics_changed`, so the sliding window prunes and the rate decays to 0.

### L2: One out-of-order Sync is counted as two lost Syncs

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/metrics.ts:31-36`](https://github.com/bitfocus/companion-module-generic-ptpv2-client/blob/93d86ee086598ed4adb2fc889c1f28ac48f0ef85/src/metrics.ts#L31-L36), [`src/ptpv2.ts:1245-1261`](https://github.com/bitfocus/companion-module-generic-ptpv2-client/blob/93d86ee086598ed4adb2fc889c1f28ac48f0ef85/src/ptpv2.ts#L1245-L1261)

**What goes wrong:** If Syncs 10, 12, 11, 13 arrive in that order, "Sync Messages Lost (count)" goes up by 2 and "Sync Messages Lost (%)" shows loss, although every message arrived. On a network that sometimes reorders packets (LAG or ECMP between sites) the loss figure is inflated and can send an operator looking for multicast drops that aren't happening.

**Why it happens:** When 12 arrives after 10, one Sync (11) is counted as lost. When the late 11 then arrives, it can't be compared, so the counter re-bases its "last seen" number back to 11. When 13 arrives, 12 is counted as missing again.

**Fix:** when the new sequence number is only slightly *older* than the last one (a late packet, not a restart), keep the last-seen number unchanged instead of re-basing to the older value; optionally take the late packet back off the lost count. Re-base only on a real forward jump.

### L3: Help advice to enable Unicast Delay Requests on one connection only may still leave that connection unable to lock

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`companion/HELP.md:120`](https://github.com/bitfocus/companion-module-generic-ptpv2-client/blob/93d86ee086598ed4adb2fc889c1f28ac48f0ef85/companion/HELP.md#L120)

**What goes wrong:** A user runs a PTPv1 connection for Dante and a PTPv2 connection for AES67 on the same Companion computer and interface. Following the help, they tick "Unicast Delay Requests" on just one of them. The master's unicast reply may be delivered to the *other* connection, which drops it because it isn't its own. The unicast connection then logs "Master has not answered the last 3 Delay Requests sent to (master IP)", `$(ptp:delayResponding)` is false, and it never locks. The help suggests this setup is safe.

**Why it happens:** Both connections bind ports 319/320 with `reuseAddr: true` ([`src/ptpv1.ts:404-405`](https://github.com/bitfocus/companion-module-generic-ptpv2-client/blob/93d86ee086598ed4adb2fc889c1f28ac48f0ef85/src/ptpv1.ts#L404-L405), [`src/ptpv2.ts:521-522`](https://github.com/bitfocus/companion-module-generic-ptpv2-client/blob/93d86ee086598ed4adb2fc889c1f28ac48f0ef85/src/ptpv2.ts#L521-L522)). A unicast reply reaches only one of the sockets sharing the port, and which one is the OS's choice, not the connection that sent the request (see [A1](#-assumptions-to-confirm)).

**Fix:** correct the help: unicast only works reliably when this connection is the only one on the computer bound to ports 319/320. Optionally add the same hint to the log message described in [M1](#m1-with-unicast-delay-requests-on-a-lost-reply-is-blamed-on-the-master-and-the-options-own-help-gives-no-warning).

## 💡 Nice to Have

### N1: Every connection start or config save logs the first master as a warning

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:123`](https://github.com/bitfocus/companion-module-generic-ptpv2-client/blob/93d86ee086598ed4adb2fc889c1f28ac48f0ef85/src/main.ts#L123), [`src/main.ts:232`](https://github.com/bitfocus/companion-module-generic-ptpv2-client/blob/93d86ee086598ed4adb2fc889c1f28ac48f0ef85/src/main.ts#L232)

**What goes wrong:** After this release, enabling the connection or saving its config writes `PTPv2 Master Changed: <clock id> Address: <ip>` at warning level, together with a "PTP Sync Changed. Unlocked" warning, even when nothing is wrong and the first master has just been found. Users who watch the Companion log for warnings see a false alarm on every start.

**Why it happens:** The master-changed log was raised from info to warn, and the same event fires for the first master heard as for a real handover.

**Fix:** log at info when there was no previous master (first adoption) and at warn only for a real change, for example by passing the previous master in the event.

## 📝 Additional Notes

- `tsconfig.build.json` differs from the template: `exclude` adds `"src/tests/**"` (line 4). Fine as long as the module builds — no change required.
- The module is on API 2.2 (base 2.2.1). The API compliance checks have no 2.2 reference yet, so it was reviewed against the 2.0 and 2.1 rules only.
