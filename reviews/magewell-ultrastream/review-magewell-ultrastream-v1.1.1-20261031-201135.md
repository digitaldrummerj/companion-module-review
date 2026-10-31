# Review: companion-module-magewell-ultrastream v1.1.1 (follow-up to the v1.1.0 review)

| Field | Value |
| --- | --- |
| **Module** | `companion-module-magewell-ultrastream` |
| **Scope** | `tag` (`v1.0.1..v1.1.1`) |
| **Version** | v1.1.1 |
| **Release** | Update — last published v1.0.1 |
| **API** | 1 (base 1.12.1, yarn.lock) |
| **Template** | `companion-module-template-ts-v1` @ `42609d8` (2026-03-03, pinned) · `.yarnrc.yml` from `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Commit** | [`417d00e`](https://github.com/bitfocus/companion-module-magewell-ultrastream/tree/417d00e2b3cefc840abd9a402f8e1a4d6c05da0b) |
| **Prior review** | [v1.1.0 (2026-10-30)](review-magewell-ultrastream-v1.1.0-20261030-090507.md) — ❌ Changes Required |
| **Reviewed** | 2026-10-31 |

## Verdict: ✅ Approved

## 📋 Issues

### Non-blocking

- [ ] [N1: Device responses are read through `as any` and unchecked casts instead of type narrowing](#n1-device-responses-are-read-through-as-any-and-unchecked-casts-instead-of-type-narrowing)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 💡 Nice to Have

### N1: Device responses are read through `as any` and unchecked casts instead of type narrowing

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/client.ts:199-202`](https://github.com/bitfocus/companion-module-magewell-ultrastream/blob/417d00e2b3cefc840abd9a402f8e1a4d6c05da0b/src/client.ts#L199-L202), [`src/actions.ts:173`](https://github.com/bitfocus/companion-module-magewell-ultrastream/blob/417d00e2b3cefc840abd9a402f8e1a4d6c05da0b/src/actions.ts#L173), [`src/actions.ts:206`](https://github.com/bitfocus/companion-module-magewell-ultrastream/blob/417d00e2b3cefc840abd9a402f8e1a4d6c05da0b/src/actions.ts#L206), [`src/feedbacks.ts:146`](https://github.com/bitfocus/companion-module-magewell-ultrastream/blob/417d00e2b3cefc840abd9a402f8e1a4d6c05da0b/src/feedbacks.ts#L146), [`src/feedbacks.ts:190`](https://github.com/bitfocus/companion-module-magewell-ultrastream/blob/417d00e2b3cefc840abd9a402f8e1a4d6c05da0b/src/feedbacks.ts#L190), [`src/feedbacks.ts:224`](https://github.com/bitfocus/companion-module-magewell-ultrastream/blob/417d00e2b3cefc840abd9a402f8e1a4d6c05da0b/src/feedbacks.ts#L224), [`src/variables.ts:99`](https://github.com/bitfocus/companion-module-magewell-ultrastream/blob/417d00e2b3cefc840abd9a402f8e1a4d6c05da0b/src/variables.ts#L99)

**What goes wrong:** Users see no difference; this is code quality only. The new Ultra Encode code reads the device's get-info, get-settings and get-status replies through `as any` and unchecked casts, so the compiler can't warn when a field is missing on one product line. Each place does check for missing fields at runtime, so nothing breaks today.

**Why it happens:** The get-info reply type is a union of the base reply and the Ultra Encode reply. Instead of narrowing the union, the code casts to `any` to test for `input-source`, and casts the settings and status replies straight to their Ultra Encode types.

**Fix:** narrow the union with the `in` operator, which removes the `as any`; for settings and status, a small type guard keyed on the product can replace the repeated casts.

```ts
const inputSource = 'input-source' in info ? info['input-source'] : undefined

function isUltraEncodeSettings(
	product: MagewellProduct | undefined,
	s: GetSettingsResponse | undefined,
): s is UltraEncodeGetSettingsResponse {
	return product === MagewellProduct.UltraEncode && s !== undefined
}
```

## 📝 Additional Notes

- **Follow-up to the v1.1.0 review:** every finding from that review is fixed in v1.1.1, and the fixes introduce no new problems.
- Prior C1 (missing `.gitattributes`): fixed. [`.gitattributes`](https://github.com/bitfocus/companion-module-magewell-ultrastream/blob/417d00e2b3cefc840abd9a402f8e1a4d6c05da0b/.gitattributes) now holds the template's `* text=auto eol=lf`.
- Prior C2 (`.gitignore` lacks `/.vscode`): fixed at [`.gitignore:10`](https://github.com/bitfocus/companion-module-magewell-ultrastream/blob/417d00e2b3cefc840abd9a402f8e1a4d6c05da0b/.gitignore#L10).
- Prior L1 (old device's input and mixer choices stay after a host change): fixed. `disconnect()` now clears the product, model, input sources and mixer info ([`src/client.ts:309-323`](https://github.com/bitfocus/companion-module-magewell-ultrastream/blob/417d00e2b3cefc840abd9a402f8e1a4d6c05da0b/src/client.ts#L309-L323)), and a host change also clears the variables and re-checks the feedbacks.
- Prior L2 (Layer Order stored as a number but offered as text ids): fixed. The "Change mixer settings" action now uses numeric ids `0` and `1`, like the feedback and the presets ([`src/actions.ts:150-162`](https://github.com/bitfocus/companion-module-magewell-ultrastream/blob/417d00e2b3cefc840abd9a402f8e1a4d6c05da0b/src/actions.ts#L150-L162)).
- Prior L3 (Ultra Stream users see input and mixer actions that do nothing): fixed. The input action and feedback are only defined when the device reports input sources, and the mixer ones only when it reports mixer info ([`src/actions.ts:124-145`](https://github.com/bitfocus/companion-module-magewell-ultrastream/blob/417d00e2b3cefc840abd9a402f8e1a4d6c05da0b/src/actions.ts#L124-L145), [`src/feedbacks.ts:125`](https://github.com/bitfocus/companion-module-magewell-ultrastream/blob/417d00e2b3cefc840abd9a402f8e1a4d6c05da0b/src/feedbacks.ts#L125), [`src/feedbacks.ts:155`](https://github.com/bitfocus/companion-module-magewell-ultrastream/blob/417d00e2b3cefc840abd9a402f8e1a4d6c05da0b/src/feedbacks.ts#L155)).
- Prior NR1 (newer `@companion-module/base`): the module stays on `~1.12.1`. That is fine for this release; moving to `~1.14.x` or API 2 remains an optional idea for a later release.
- The prior note about `tsconfig.build.json` extending the node18 preset is resolved: it now extends `@companion-module/tools/tsconfig/node22/recommended`, as the template does.
