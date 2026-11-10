# Review: telycam-ptz-ip-camera v1.2.1

| Field | Value |
| --- | --- |
| **Module** | [`companion-module-telycam-ptz-ip-camera`](https://github.com/bitfocus/companion-module-telycam-ptz-ip-camera) |
| **Scope** | `tag` (changes `v1.2.0..v1.2.1`) |
| **Version** | v1.2.1 ([`f1f6795`](https://github.com/bitfocus/companion-module-telycam-ptz-ip-camera/commit/f1f679515a390f08a2b49f2b3c323c515619eec9)) |
| **Release** | Update — last published v1.2.0 |
| **API** | 2.0 (base 2.0.4, yarn.lock) — requires Companion 4.3+ |
| **Template** | `companion-module-template-ts-v2.0.4` @ `d62230e` (2026-08-28, pinned) · `.yarnrc.yml` from `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Reviewed** | 2026-11-09 |

## Verdict: ✅ Approved

## 📋 Issues

### Non-blocking

- [ ] [L1: The Auto Tracking action starts a 200 ms re-check timer that destroy() doesn't cancel](#l1-the-auto-tracking-action-starts-a-200-ms-re-check-timer-that-destroy-doesnt-cancel)
- [ ] [L2: The help page doesn't mention the new Auto Tracking feedback and preset, and still says status is read only over HTTP](#l2-the-help-page-doesnt-mention-the-new-auto-tracking-feedback-and-preset-and-still-says-status-is-read-only-over-http)
- [ ] [N1: Tracking buttons light up even when no command was sent](#n1-tracking-buttons-light-up-even-when-no-command-was-sent)
- [ ] [NR1: package.json has no packageManager field, so installs can fall back to Yarn 1 and rewrite the lockfile](#nr1-packagejson-has-no-packagemanager-field-so-installs-can-fall-back-to-yarn-1-and-rewrite-the-lockfile)
- [ ] [NR2: The CI workflow (node.yaml) uses older action versions and a commented-out Codecov step](#nr2-the-ci-workflow-nodeyaml-uses-older-action-versions-and-a-commented-out-codecov-step)

## 🟢 Low

### L1: The Auto Tracking action starts a 200 ms re-check timer that destroy() doesn't cancel

- **Source:** 🔎 protocol reviewer, QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions/system.ts:86-88`](https://github.com/bitfocus/companion-module-telycam-ptz-ip-camera/blob/f1f679515a390f08a2b49f2b3c323c515619eec9/src/actions/system.ts#L86-L88), [`src/main.ts:44-48`](https://github.com/bitfocus/companion-module-telycam-ptz-ip-camera/blob/f1f679515a390f08a2b49f2b3c323c515619eec9/src/main.ts#L44-L48)

**What goes wrong:** A user presses a **Tracking ON** or **Tracking OFF** button (action **System: Auto Tracking On/Off**) and disables or deletes the connection, or saves its settings, within 200 ms. The re-check timer still fires once: after a disable it only logs "UDP socket not initialized", and after a settings save it sends one status query on the new socket. Users see nothing beyond, at most, that log line.

**Why it happens:** The action schedules `setTimeout(() => self.queryAutoTrackingStatus(), 200)` without keeping the handle, so `destroy()` and `configUpdated()` can't clear it. It stays Low because it fires once and `sendViscaCommand()` returns early when there is no socket.

**Fix:** keep the handle on the instance (e.g. `autoTrackingQueryTimer`), clear it before scheduling a new one, and clear it in `destroy()` next to `stopHttpPolling()`.

### L2: The help page doesn't mention the new Auto Tracking feedback and preset, and still says status is read only over HTTP

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`companion/HELP.md:11-58`](https://github.com/bitfocus/companion-module-telycam-ptz-ip-camera/blob/f1f679515a390f08a2b49f2b3c323c515619eec9/companion/HELP.md#L11-L58), [`src/config.ts:19`](https://github.com/bitfocus/companion-module-telycam-ptz-ip-camera/blob/f1f679515a390f08a2b49f2b3c323c515619eec9/src/config.ts#L19), [`README.md:5-15`](https://github.com/bitfocus/companion-module-telycam-ptz-ip-camera/blob/f1f679515a390f08a2b49f2b3c323c515619eec9/README.md#L5-L15)

**What goes wrong:** The help page lists the new `auto_tracking` variable but not the new **Auto Tracking State Indicator** feedback (State: ON/OFF), the **Auto Tracking Status** preset, or the green highlight now on the **Tracking ON** / **Tracking OFF** presets. The connection settings ("Motion uses VISCA, status uses HTTP"), the help ("HTTP CGI API: Used for reading current status") and the README ("the HTTP polling interval") also no longer match: the auto-tracking state is now read over VISCA UDP on the same timer. A user who sets **Polling Interval** to `0` to stop HTTP polling also stops auto-tracking updates, and nothing tells them so.

**Why it happens:** The release added the feedback, preset and VISCA inquiry, but only the variable was added to the help page. The VISCA query is sent only from the poll ([`src/main.ts:209-210`](https://github.com/bitfocus/companion-module-telycam-ptz-ip-camera/blob/f1f679515a390f08a2b49f2b3c323c515619eec9/src/main.ts#L209-L210)), which doesn't start when the interval is 0 ([`src/main.ts:186-190`](https://github.com/bitfocus/companion-module-telycam-ptz-ip-camera/blob/f1f679515a390f08a2b49f2b3c323c515619eec9/src/main.ts#L186-L190)).

**Fix:** add an Auto Tracking part to the help's Features section naming the feedback and the three presets; say in Protocol Notes and the config info text that VISCA over UDP also reads the auto-tracking state; and describe **Polling Interval** as the interval for all status polling, where `0` also stops auto-tracking updates.

## 💡 Nice to Have

### N1: Tracking buttons light up even when no command was sent

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions/system.ts:83-85`](https://github.com/bitfocus/companion-module-telycam-ptz-ip-camera/blob/f1f679515a390f08a2b49f2b3c323c515619eec9/src/actions/system.ts#L83-L85)

**What goes wrong:** On a connection with no **Camera IP Address (Target IP)** (status: Bad Configuration), pressing **Tracking ON** sends nothing, yet the button turns green and `$(telycam-ptz-ip-camera:auto_tracking)` shows `on`. The re-check 200 ms later is skipped too, so the wrong state stays on the buttons. The connection status already shows the misconfiguration, so the impact is small.

**Why it happens:** `sendViscaCommand()` returns nothing and only logs a warning when it can't send; the action updates the variable and feedback regardless.

**Fix:** have `sendViscaCommand()` return `true` when it sent and `false` when it bailed out, and only update `auto_tracking` and check the feedback on `true`.

## 🔮 Next Release

Both template differences below were already in v1.2.0 and don't block v1.2.1. Please fix them in the next release.

### NR1: package.json has no packageManager field, so installs can fall back to Yarn 1 and rewrite the lockfile

- **Source:** 🤖 validate-template (PKG-FIELD)
- **Classification:** full-module template check (also missing in v1.2.0)
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-telycam-ptz-ip-camera/blob/f1f679515a390f08a2b49f2b3c323c515619eec9/package.json)

**What goes wrong:** Without a `packageManager` field, Corepack doesn't know the module uses Yarn 4, so a machine with Yarn 1 installed globally uses that instead. That is what happened during this review: the install replaced the committed Yarn 4 `yarn.lock` with a `# yarn lockfile v1` file, so the build ran on dependency versions the maintainer never locked.

**Why it happens:** The template pins the package manager in `package.json` (`"packageManager": "yarn@4.17.0"`); this module's `package.json` has no such field.

**Evidence:** validator: `Missing required field 'packageManager' (present in template)`

```text
Template expects:  "packageManager": "yarn@4.17.0"   (companion-module-template-ts-v2.0.4/package.json:48)
Found:             (no packageManager field)
```

**Fix:** add the template's field to `package.json` and commit the `yarn.lock` that `yarn install` writes with it:

```json
"packageManager": "yarn@4.17.0"
```

### NR2: The CI workflow (node.yaml) uses older action versions and a commented-out Codecov step

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** full-module template check (file unchanged since v1.2.0)
- **File:** [`.github/workflows/node.yaml:18-21`](https://github.com/bitfocus/companion-module-telycam-ptz-ip-camera/blob/f1f679515a390f08a2b49f2b3c323c515619eec9/.github/workflows/node.yaml#L18-L21), [`.github/workflows/node.yaml:59-76`](https://github.com/bitfocus/companion-module-telycam-ptz-ip-camera/blob/f1f679515a390f08a2b49f2b3c323c515619eec9/.github/workflows/node.yaml#L59-L76)

**What goes wrong:** The CI workflow no longer matches the template it is judged by, so later template updates can't be copied over cleanly and CI differences are harder to troubleshoot.

**Why it happens:** The workflow pins `actions/checkout@v4` and `actions/setup-node@v4` where the template uses `@v7` and `@v6`, and its commented-out test job adds a "Send coverage" step (Codecov) that the template doesn't have.

**Evidence:** validator: `Differs from template (line 15: found '- uses: actions/checkout@v4', template '- uses: actions/checkout@v7')`

```diff
# companion-module-template-ts-v2.0.4 vs module .github/workflows/node.yaml
-      - uses: actions/checkout@v7
+      - uses: actions/checkout@v4
-        uses: actions/setup-node@v6
+        uses: actions/setup-node@v4
-  #     - uses: actions/checkout@v7
+  #     - uses: actions/checkout@v4
-  #       uses: actions/setup-node@v6
+  #       uses: actions/setup-node@v4
+  #     - name: Send coverage
+  #       uses: codecov/codecov-action@v5
```

**Confirm by:** `diff companion-module-template-ts-v2.0.4/.github/workflows/node.yaml .github/workflows/node.yaml` should show no difference.

**Fix:** copy the template's `node.yaml` unchanged.
