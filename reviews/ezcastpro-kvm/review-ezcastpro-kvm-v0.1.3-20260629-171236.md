# Review — ezcastpro-kvm v0.1.3

| | |
|---|---|
| **Module** | ezcastpro-kvm |
| **Version** | v0.1.3 |
| **Scope** | tag (first release — no previous tag, so reviewed as a full module review) |
| **Language** | TypeScript |
| **API** | @companion-module/base v1.x (~1.14.1) |
| **Protocols** | HTTP (CMS JSON-RPC); `node:net` used only for IPv4 validation |
| **Reviewed** | 2026-06-29 |

> First release (`previousTag` = none). With no diff available, the `tag` scope falls back to a full review of the whole `src/`; every finding below is NEW.

## Verdict: Approved

## 📋 Issues

**Non-blocking**
- [ ] [M1: Unbounded CIDR expansion can OOM or hang the instance](#m1-unbounded-cidr-expansion-can-oom-or-hang-the-instance)
- [ ] [M2: refreshInFlight finally clears the wrong promise](#m2-refreshinflight-finally-clears-the-wrong-promise)
- [ ] [L1: In-flight HTTP requests are not aborted on destroy or reconfigure](#l1-in-flight-http-requests-are-not-aborted-on-destroy-or-reconfigure)
- [ ] [L2: Discovery failure leaves status reporting Ok](#l2-discovery-failure-leaves-status-reporting-ok)
- [ ] [L3: Fragile substring-based role detection](#l3-fragile-substring-based-role-detection)
- [ ] [L4: JSON-RPC response id is not validated](#l4-json-rpc-response-id-is-not-validated)
- [ ] [N1: Admin password uses textinput instead of secret-text](#n1-admin-password-uses-textinput-instead-of-secret-text)
- [ ] [N2: Stale version in HTTP User-Agent header](#n2-stale-version-in-http-user-agent-header)
- [ ] [N3: Plaintext credentials over HTTP](#n3-plaintext-credentials-over-http)
- [ ] [N4: Dead fallback in defaultDevice](#n4-dead-fallback-in-defaultdevice)
- [ ] [N5: Trailing-space labels for unnamed devices](#n5-trailing-space-labels-for-unnamed-devices)

## 🟡 Medium

### M1: Unbounded CIDR expansion can OOM or hang the instance

**File:** `src/protocol.ts:218-232` (`hostsFromCidr`), called from `discoverDevices` (line 234) and `discover()` (`src/main.ts:309`)

`hostsFromCidr` accepts any prefix `/1`–`/32` and eagerly builds the full host array. A user typo such as `192.168.0.0/8` allocates ~16M strings; `/1` (~2.1B) crashes the module process before any request is sent. Even when memory survives, every offline host blocks for the full `requestTimeoutMs`, so a large range at concurrency 64 can take tens of minutes. Discovery is reachable from `init`/`configUpdated` (autoDiscover defaults true) and from the `discover_devices` action.

**Fix:** Enforce a sane minimum prefix (e.g. reject prefix `< 22`, ~1024 hosts) or cap the generated host count, and surface the rejection via `InstanceStatus.BadConfig` rather than expanding.

### M2: refreshInFlight finally clears the wrong promise

**File:** `src/main.ts:279-281` (interacting with `configUpdated` line 96 and `destroy` line 85)

```ts
this.refreshInFlight = this.doRefreshStatus(generation).finally(() => {
    if (this.refreshInFlight) this.refreshInFlight = undefined
})
```

The `.finally` clears `refreshInFlight` on truthiness, not identity. If a poll-started refresh (P1) is in flight when `configUpdated()` resets `refreshInFlight` and `start()` launches a new refresh (P2), P1's `finally` later nulls out P2. The in-flight dedup guard at line 276 is then bypassed while P2 is still running, allowing duplicate concurrent `getDeviceInfo` requests. State corruption is prevented by the `generation` guards, but the dedup is defeated.

**Fix:** Capture the promise and compare identity: `const p = this.doRefreshStatus(generation).finally(() => { if (this.refreshInFlight === p) this.refreshInFlight = undefined }); this.refreshInFlight = p`.

## 🟢 Low

### L1: In-flight HTTP requests are not aborted on destroy or reconfigure

**File:** `src/protocol.ts:82-141`; callers in `src/main.ts:80-89, 285-307, 309-335`

`cmsCall` does not accept an `AbortSignal` and the `http.ClientRequest` is not stored, so requests already issued keep running after `destroy()`/`configUpdated()`. The `generation`/`destroyed` guards correctly prevent stale state writes, so this is bounded by `requestTimeoutMs` (≤15s) rather than a true leak — but a `discover()` in flight at teardown can leave up to 64 sockets alive until they time out.

**Fix:** Thread an `AbortController` (aborted in `destroy()`/`configUpdated()`) into `cmsCall` via `http.request`'s `signal` option.

### L2: Discovery failure leaves status reporting Ok

**File:** `src/main.ts:322-328`

When discovery fails and `rxSelectionMode !== 'discovered'`, the catch logs a warning and stores `lastError`/`last_error` but never updates `InstanceStatus`. If the user enabled `autoDiscover` to populate device/preset lists, a persistent discovery failure (bad subnet, network down) leaves the module reporting `Ok` (from the separate `refreshStatus` path) with no surfaced indication that discovery is broken.

**Fix:** Acceptable as a design choice, but consider surfacing discovery failure consistently (status or a clearly-named variable) so operators can tell discovery is down.

### L3: Fragile substring-based role detection

**File:** `src/protocol.ts:158-159`

`role` is derived from `text.includes('rx')` / `includes('tx')` over the lowercased `dev_name + product_name + model`. A device whose names contain neither token becomes `'unknown'` and won't appear in `getRxChoices()` nor be treated as TX in `getTxForChannel`. Devices renamed via the module's own `set_assigned_name` can lose their role classification.

**Fix:** Prefer an explicit role/type field from the device info if the CMS API exposes one, and fall back to the heuristic.

### L4: JSON-RPC response id is not validated

**File:** `src/protocol.ts:74-79, 124-131`

The request always sends `id: 1` and the parsed response `id` is never checked against the request. Harmless over single-shot HTTP POSTs (no multiplexing), but worth tightening for correctness.

**Fix:** Validate the response `id` matches the request `id`, or document why it's safe to ignore.

## 💡 Nice to Have

### N1: Admin password uses textinput instead of secret-text

**File:** `src/config.ts:50-56`

The `password` field holds a device admin credential but is declared `type: 'textinput'`. Per the v1.13+ API, credentials should use `type: 'secret-text'` so the value is masked in the UI and protected in connection exports.

**Fix:** Change the `password` field to `type: 'secret-text'`.

### N2: Stale version in HTTP User-Agent header

**File:** `src/protocol.ts:100`

The header is hardcoded `companion-module-ezcastpro-kvm/0.1.2` while the release is v0.1.3, so it drifts every release.

**Fix:** Drop the version suffix or source it from the package/manifest version.

### N3: Plaintext credentials over HTTP

**File:** `src/protocol.ts:90-101, 183-208`

The admin `password` is sent in a multipart body to port 80 with no TLS. This is dictated by the device's CMS API and likely unavoidable, but a tooltip noting that the password traverses the network in clear text would help operators make an informed choice.

**Fix:** Add a tooltip/help note on the password field (no code change to transport required).

### N4: Dead fallback in defaultDevice

**File:** `src/actions.ts:14`

`deviceChoices[0]?.id ?? self.getEffectiveRxHost() ?? '192.168.96.101'` — `getEffectiveRxHost()` always returns a `string`, so the trailing `?? '192.168.96.101'` literal is unreachable.

**Fix:** Simplify to make the intended default explicit.

### N5: Trailing-space labels for unnamed devices

**File:** `src/main.ts:169`

`${device.host} - ${device.role.toUpperCase()} ${device.deviceName}` yields a trailing space when `deviceName` is empty. Cosmetic.

**Fix:** Trim the label or omit the trailing segment when `deviceName` is empty.
