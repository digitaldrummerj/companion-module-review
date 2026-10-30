# Review: companion-module-outline-et v1.0.0

| Field | Value |
| --- | --- |
| **Module** | `companion-module-outline-et` |
| **Scope** | `tag` |
| **Version** | `v1.0.0` |
| **Release** | New module — never published |
| **API** | 2.0 (base 2.0.4, yarn.lock) — requires Companion 4.3+ |
| **Template** | `companion-module-template-ts-v2.0.4` @ `d62230e` (2026-08-28, pinned) |
| **Commit** | [`cae9980`](https://github.com/bitfocus/companion-module-outline-et/tree/cae99808de355b33abbe15f7175840a05f2de1b0) |
| **Review date** | 2026-10-30 |

This is the module's first release, so there is no previous tag to diff against: the whole module was reviewed, and every finding is classified 🆕 NEW. `yarn install --immutable`, `yarn package` and `yarn lint` all succeeded.

## Verdict: ❌ Changes Required

## 📋 Issues

### Blocking

- [ ] [C1: Prettier ignore file differs from the template](#c1-prettier-ignore-file-differs-from-the-template)
- [ ] [H1: CI workflow differs from the template](#h1-ci-workflow-differs-from-the-template)
- [ ] [H2: LICENSE copyright line differs from the template](#h2-license-copyright-line-differs-from-the-template)

### Non-blocking

- [ ] [L1: A cancelled command's reply timer can outlive the connection by up to half a second](#l1-a-cancelled-commands-reply-timer-can-outlive-the-connection-by-up-to-half-a-second)
- [ ] [N1: Port-in-use warning blames a duplicate connection that may not exist](#n1-port-in-use-warning-blames-a-duplicate-connection-that-may-not-exist)

## 🔴 Critical

### C1: Prettier ignore file differs from the template

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.prettierignore:2`](https://github.com/bitfocus/companion-module-outline-et/blob/cae99808de355b33abbe15f7175840a05f2de1b0/.prettierignore#L2)

**What goes wrong:** The module's Prettier ignore list doesn't match the API 2.0 template. Modules are expected to keep the template's config files unchanged, so that every module formats and builds the same way and later troubleshooting isn't thrown off by local differences.

**Why it happens:** Line 2 of `.prettierignore` was changed from the template's `/LICENSE.md` to `/LICENSE`.

**Evidence:**

```text
module   .prettierignore:2   /LICENSE
template .prettierignore:2   /LICENSE.md
```

**Confirm by:** `diff companion-module-template-ts-v2.0.4/.prettierignore .prettierignore` returns no output.

**Fix:** restore the template's `.prettierignore`.

```text
package.json
/LICENSE.md
```

## 🟠 High

### H1: CI workflow differs from the template

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.github/workflows/node.yaml:12-53`](https://github.com/bitfocus/companion-module-outline-et/blob/cae99808de355b33abbe15f7175840a05f2de1b0/.github/workflows/node.yaml#L12-L53)

**What goes wrong:** The module's GitHub Actions workflow is a reworked version of the template's. A `.github` file that the module has must match the template for its API level, so CI behaves the same across modules.

**Why it happens:** The job was renamed and its steps were changed: checkout gained `persist-credentials: false`, the template-repository preparation step was removed, `yarn build` was replaced by `yarn typecheck`, and formatting and test steps were added in place of the template's commented-out `test` job.

**Evidence:**

- [`node.yaml:12-13`](https://github.com/bitfocus/companion-module-outline-et/blob/cae99808de355b33abbe15f7175840a05f2de1b0/.github/workflows/node.yaml#L12-L13): job `check:` / `name: Lint, types and tests`. Template: `lint:` / `name: Lint`.
- [`node.yaml:19-20`](https://github.com/bitfocus/companion-module-outline-et/blob/cae99808de355b33abbe15f7175840a05f2de1b0/.github/workflows/node.yaml#L19-L20): added `with: persist-credentials: false` on checkout.
- [`node.yaml:22`](https://github.com/bitfocus/companion-module-outline-et/blob/cae99808de355b33abbe15f7175840a05f2de1b0/.github/workflows/node.yaml#L22): comment reworded.
- Template lines 27-35 (the "Prepare Environment (For template repository)" step) are removed.
- [`node.yaml:34-36`](https://github.com/bitfocus/companion-module-outline-et/blob/cae99808de355b33abbe15f7175840a05f2de1b0/.github/workflows/node.yaml#L34-L36): "Check types" runs `yarn typecheck`. Template: "Build and check types" runs `yarn build`.
- [`node.yaml:44-53`](https://github.com/bitfocus/companion-module-outline-et/blob/cae99808de355b33abbe15f7175840a05f2de1b0/.github/workflows/node.yaml#L44-L53): added "Check formatting" (`yarn format:check`) and "Build and run tests" (`yarn test`) steps. Template lines 51-74 are the commented-out `test` job.

```yaml
# .github/workflows/node.yaml:12-20 (module)
  check:
    name: Lint, types and tests
    runs-on: ubuntu-latest
    timeout-minutes: 15

    steps:
      - uses: actions/checkout@v7
        with:
          persist-credentials: false
```

**Confirm by:** `diff companion-module-template-ts-v2.0.4/.github/workflows/node.yaml .github/workflows/node.yaml` returns no output.

**Fix:** replace `.github/workflows/node.yaml` with the template's copy from `companion-module-template-ts-v2.0.4`. To run the tests in CI, uncomment the template's own `test` job rather than adding steps to the `lint` job.

### H2: LICENSE copyright line differs from the template

- **Source:** 🤖 validate-template (LICENSE-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`LICENSE:3`](https://github.com/bitfocus/companion-module-outline-et/blob/cae99808de355b33abbe15f7175840a05f2de1b0/LICENSE#L3)

**What goes wrong:** The module's licence names a different copyright holder than the template's licence file.

**Why it happens:** Line 3 of `LICENSE` was changed from the template's copyright line.

**Evidence:**

```text
module   LICENSE:3   Copyright (c) 2026 Outline
template LICENSE:3   Copyright (c) 2022 Bitfocus AS - Open Source
```

**Confirm by:** [`LICENSE`](https://github.com/bitfocus/companion-module-outline-et/blob/cae99808de355b33abbe15f7175840a05f2de1b0/LICENSE) matches the template byte-for-byte.

**Fix:** restore the template's `LICENSE` file unchanged.

## 🟢 Low

### L1: A cancelled command's reply timer can outlive the connection by up to half a second

- **Source:** 🔎 protocol reviewer, QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/protocol/command-channel.ts:66-73`](https://github.com/bitfocus/companion-module-outline-et/blob/cae99808de355b33abbe15f7175840a05f2de1b0/src/protocol/command-channel.ts#L66-L73), [`src/protocol/command-channel.ts:88-104`](https://github.com/bitfocus/companion-module-outline-et/blob/cae99808de355b33abbe15f7175840a05f2de1b0/src/protocol/command-channel.ts#L88-L104)

**What goes wrong:** Nothing visible. An operator presses a "Step 90°" button, then STOP before the turntable answers, then disables or deletes the connection within 500 ms. The reply timer of the cancelled Step command is still running after `destroy()` and fires within the reply timeout (500 ms). When it fires it does nothing: no datagram, log line, status change or variable update follows, and it never repeats. This is cleanup hygiene only, but `destroy()` should stop every timer the module started.

**Why it happens:** When STOP cancels a command that was already sent, the module deliberately keeps that command's reply timer running, so the command holds its send turn until its reply would have timed out. When the connection closes, only the timer of the request pending at that moment (the STOP) is cleared, not the timer of the command the STOP cancelled. The session releases all send turns on disconnect, so the leftover timer finds nothing left to do.

**Fix:** keep a reference to a cancelled-but-sent request and clear its timer when the channel closes. For example, set `private draining: PendingRequest | null` in `cancel()` when `pending.turn !== null`, and in `close()` also call:

```ts
if (this.draining?.timer) clearTimeout(this.draining.timer)
this.draining?.turn?.done()
```

## 💡 Nice to Have

### N1: Port-in-use warning blames a duplicate connection that may not exist

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/protocol/local-port.ts:15-21`](https://github.com/bitfocus/companion-module-outline-et/blob/cae99808de355b33abbe15f7175840a05f2de1b0/src/protocol/local-port.ts#L15-L21), [`src/et-session.ts:193-199`](https://github.com/bitfocus/companion-module-outline-et/blob/cae99808de355b33abbe15f7175840a05f2de1b0/src/et-session.ts#L193-L199)

**What goes wrong:** Two Outline ET connections can point at different turntables that get the same local port. For example, 192.168.0.100 and 10.0.39.116 both map to port 20100. The second connection still works on an automatic port, but its log says "Is another connection to this turntable open? Use one connection per turntable.", which sends the operator looking for a duplicate connection that doesn't exist. The same message appears when an unrelated application holds the port.

**Why it happens:** The local port is the base plus the address's last two octets (third × 256 + fourth) modulo 10000, which isn't unique across subnets. The fallback warning always blames a second connection to the same turntable.

**Fix:** word the warning neutrally, for example: "Local UDP port 20100 is in use (EADDRINUSE), possibly by another connection to this turntable or by another application; an automatic port is used instead."
