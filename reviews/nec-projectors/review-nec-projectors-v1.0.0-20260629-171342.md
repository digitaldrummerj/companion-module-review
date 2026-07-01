# Review: nec-projectors v1.0.0

| | |
|---|---|
| **Module** | nec-projectors |
| **Version** | v1.0.0 |
| **Scope** | `tag` (first release — no previous tag, so reviewed as a full `src/` review; all findings NEW) |
| **Language / API** | TypeScript / @companion-module/base v2.x (base 2.0.4) |
| **Protocols** | HTTP (NEC `IsapiExtPj.dll` CGI control) |
| **Reviewed** | 2026-06-29 |

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 2 | 0 | 2 |
| 🟠 High | 1 | 0 | 1 |
| 🟡 Medium | 2 | 0 | 2 |
| 🟢 Low | 6 | 0 | 6 |
| 💡 Nice to Have | 4 | 0 | 4 |
| **Total** | **15** | **0** | **15** |

## Verdict: Approved

## 📋 Issues

**Blocking**

- [ ] [C1: tsconfig.build.json differs from the official template](#c1-tsconfigbuildjson-differs-from-the-official-template)
- [ ] [C2: Banned/low-value keyword NEC in manifest](#c2-bannedlow-value-keyword-nec-in-manifest)
- [ ] [H1: configUpdated race leaks poll loops and multiplies polling traffic](#h1-configupdated-race-leaks-poll-loops-and-multiplies-polling-traffic)

**Non-blocking**

- [ ] [M1: Shared NecClient session is not concurrency-safe](#m1-shared-necclient-session-is-not-concurrency-safe)
- [ ] [M2: NACK error-code lookup table is dead — every error shows Unknown error](#m2-nack-error-code-lookup-table-is-dead--every-error-shows-unknown-error)
- [ ] [L1: HTTP username/password stored in plaintext config instead of v2 secrets](#l1-http-usernamepassword-stored-in-plaintext-config-instead-of-v2-secrets)
- [ ] [L2: Post-await side effects can run after destroy](#l2-post-await-side-effects-can-run-after-destroy)
- [ ] [L3: No recovery loop when status polling is disabled](#l3-no-recovery-loop-when-status-polling-is-disabled)
- [ ] [L4: decodeInfoString advances offset by trimmed length](#l4-decodeinfostring-advances-offset-by-trimmed-length)
- [ ] [L5: selectInput skips the post-command refresh on total failure](#l5-selectinput-skips-the-post-command-refresh-on-total-failure)
- [ ] [L6: Empty logon nonce proceeds with a misleading error](#l6-empty-logon-nonce-proceeds-with-a-misleading-error)
- [ ] [N1: Dead code — NecClient.update and NecClient.reset](#n1-dead-code--necclientupdate-and-necclientreset)
- [ ] [N2: Unused decodeLensInfo and misleading lampMoving field](#n2-unused-decodelensinfo-and-misleading-lampmoving-field)
- [ ] [N3: Response framing and checksum are never validated](#n3-response-framing-and-checksum-are-never-validated)
- [ ] [N4: input_active feedback cannot distinguish HDMI 1 from HDMI 2](#n4-input_active-feedback-cannot-distinguish-hdmi-1-from-hdmi-2)
- [ ] [NR1: Request timeout hardcoded to 4000 ms](#nr1-request-timeout-hardcoded-to-4000-ms)
- [ ] [NR2: No retry/backoff on transport failure](#nr2-no-retrybackoff-on-transport-failure)

## 🔴 Critical

### C1: tsconfig.build.json differs from the official template

**File:** `tsconfig.build.json:7`

The committed `tsconfig.build.json` diverges from `companion-module-template-ts`: line 7 is `"rootDir": "./src",` where the template has `"baseUrl": "./",`. Template config files must match the official template so the build behaves predictably across the toolchain.

**Fix (maintainer):** Restore the template's `tsconfig.build.json` line (`"baseUrl": "./",`). If `rootDir` is genuinely needed, justify the deviation with the Bitfocus team — otherwise revert to template.

### C2: Banned/low-value keyword NEC in manifest

**File:** `companion/manifest.json`

The manifest `keywords` array contains the banned/low-value keyword `NEC`. The manufacturer name is already conveyed by the module id/name and is not a useful search keyword.

**Fix (maintainer):** Remove `NEC` from the `keywords` array.

## 🟡 Medium

### M2: NACK error-code lookup table is dead — every error shows Unknown error

**File:** `src/nec/protocol.ts:117`

```js
const key = `${err1.toString(16)},${err2.toString(16)}`
return ERROR_CODES[key] ?? `Unknown error (${toHex(err1)} ${toHex(err2)})`
```

`ERROR_CODES` keys are zero-padded two-digit hex (`'00,00'`, `'02,0d'`, `'02,0f'`…), but `err1.toString(16)` produces un-padded hex (`'0'`, `'2,d'`). Every documented pair — including `02,0d` "power is off" and `02,0f` "no authority" — falls through to "Unknown error (…)". So `res.errorText` is never the human-readable string anywhere. Control logic is unaffected because the retry/power-off branches compare the numeric `err1`/`err2` directly, but every logged error message is degraded.

**Fix (maintainer):** Pad both nibbles, e.g. `` const key = `${err1.toString(16).padStart(2,'0')},${err2.toString(16).padStart(2,'0')}` ``.

## 💡 Nice to Have

### N1: Dead code — NecClient.update and NecClient.reset

**File:** `src/nec/client.ts:39-43, 150-153`

`NecClient.update()` and `NecClient.reset()` are never called — `restart()` always constructs a fresh `NecClient`. Remove them, or wire `configUpdated` to `update()` instead of recreating the client.

### N2: Unused decodeLensInfo and misleading lampMoving field

**File:** `src/nec/decode.ts:177-181` (and `ProjectorState.lampMoving`)

`decodeLensInfo()` (and the `lampMoving` field it writes) is never invoked from the poll loop, and the field name (set from lens-actuator status) is misleading. Either wire lens-status polling in or drop the unused decoder/field.
