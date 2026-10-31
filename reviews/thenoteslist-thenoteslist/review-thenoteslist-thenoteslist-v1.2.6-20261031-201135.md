# Review: companion-module-thenoteslist-thenoteslist v1.2.6 (follow-up)

| | |
| --- | --- |
| **Module** | `companion-module-thenoteslist-thenoteslist` ([repo](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist)) |
| **Scope** | `tag` |
| **Version** | v1.2.6 (`431706f`) |
| **Release** | Update — last published v1.2.5 |
| **API** | 1 (base 1.14.1, yarn.lock) |
| **Template** | `companion-module-template-ts-v1` @ `42609d8` (2026-03-03, pinned) · `.yarnrc.yml` from `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Previous tag** | v1.2.5 (`d0d442f`), diff `v1.2.5..v1.2.6` (8 files) |
| **Prior review** | [v1.2.5 review](review-thenoteslist-thenoteslist-v1.2.5-20261030-192328.md) (✅ Approved, non-blocking findings only) |
| **Language** | TypeScript |
| **Build** | `yarn install --immutable`, `yarn package` and `yarn lint` all pass |
| **Transports** | HTTP (global `fetch`, polling the cloud API) · OSC over TCP to an ETC Eos desk (`node-osc`, read-only) |
| **Review date** | 2026-10-31 |

**Follow-up to the v1.2.5 review:** this release acts on the [v1.2.5 review](review-thenoteslist-thenoteslist-v1.2.5-20261030-192328.md). Each of its non-blocking suggestions was checked against the new code, and all of them are resolved:

- **M1 (colour feedbacks stay uncoloured after a restart):** fixed. When the show's types and priorities arrive, the module now re-runs the **Colour key by note type** and **Colour key by priority** feedbacks ([`src/main.ts:462`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/431706fcab5bdfe2099a36a82b3505603b48b28a/src/main.ts#L462)).
- **L1 (Connected key and counts keep the old show after re-pairing):** fixed. Re-pairing now clears the connected flag, the counts, the station and production names, and the **Connected** and **Outstanding count above threshold** feedbacks, through the same helper the "not paired" path uses ([`src/main.ts:182`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/431706fcab5bdfe2099a36a82b3505603b48b28a/src/main.ts#L182), [`src/main.ts:485-498`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/431706fcab5bdfe2099a36a82b3505603b48b28a/src/main.ts#L485-L498)).
- **L2 (pairing code stays on screen when the server is unreachable):** fixed. After 3 failed pairing checks in a row, the status changes to Connection failure with the code and the reason, and one warning is logged. The PAIR CODE status comes back on the next successful check ([`src/main.ts:233-234`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/431706fcab5bdfe2099a36a82b3505603b48b28a/src/main.ts#L233-L234), [`src/main.ts:270-273`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/431706fcab5bdfe2099a36a82b3505603b48b28a/src/main.ts#L270-L273)). The 429 and 404/409/410 replies keep their own handling.
- **L3 (New note parses an already-resolved cue number):** fixed. The action uses the cue number Companion has already resolved, and still falls back to the cue cursor for a blank or `$NA` value ([`src/actions.ts:41-42`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/431706fcab5bdfe2099a36a82b3505603b48b28a/src/actions.ts#L41-L42)).
- **N1 (an unreachable Eos desk does not show in the status):** fixed. While the server side is fine, the status is now a warning ("… · Eos desk not connected") when an Eos desk is set but not connected. Server failures still take priority ([`src/main.ts:349-354`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/431706fcab5bdfe2099a36a82b3505603b48b28a/src/main.ts#L349-L354)).
- **N2 (pairing log always says 10 minutes):** fixed. The log line now shows the real minutes left ([`src/main.ts:200`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/431706fcab5bdfe2099a36a82b3505603b48b28a/src/main.ts#L200)).
- **N3 (Go to module presets do not light up):** fixed. The **Go to …** presets now turn red while the module has notes open ([`src/presets.ts:115-122`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/431706fcab5bdfe2099a36a82b3505603b48b28a/src/presets.ts#L115-L122)).
- **N4 (feedbacks have no descriptions):** fixed. Every feedback now has a description ([`src/feedbacks.ts:11-76`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/431706fcab5bdfe2099a36a82b3505603b48b28a/src/feedbacks.ts#L11-L76)).
- **N5 (legacy id for a never-published module):** fixed. `legacyIds` is back to `[]`, as in the template ([`companion/manifest.json:17`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/431706fcab5bdfe2099a36a82b3505603b48b28a/companion/manifest.json#L17)). Every published tag used the id `thenoteslist-thenoteslist`, so no user is affected.
- **NR1 (move to API 2.x):** still a suggestion for a later release. Nothing breaks on API 1.

The release also adds an upgrade script that saves **Send cue labels** as on for older connections that have no value yet, so the settings switch matches what the module already does ([`src/upgrades.ts:29-38`](https://github.com/bitfocus/companion-module-thenoteslist-thenoteslist/blob/431706fcab5bdfe2099a36a82b3505603b48b28a/src/upgrades.ts#L29-L38)). It is appended after the existing scripts and leaves an explicit off setting alone.

No new issues were found in the `v1.2.5..v1.2.6` changes. The changes add no timers, sockets or listeners, and `destroy()` is unchanged.

## Verdict: ✅ Approved
