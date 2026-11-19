# Review: nextologies-nextotalk v1.0.3

| Field | Value |
| --- | --- |
| **Module** | `companion-module-nextologies-nextotalk` |
| **Repository** | [bitfocus/companion-module-nextologies-nextotalk](https://github.com/bitfocus/companion-module-nextologies-nextotalk) |
| **Scope** | `tag` (v1.0.1..v1.0.3) |
| **Version** | v1.0.3 |
| **Release** | Update — last published v1.0.1 |
| **API** | 1 (base 1.14.1, yarn.lock) |
| **Template** | `companion-module-template-ts-v1` @ `42609d8` (2026-03-03, pinned) · `.yarnrc.yml` from `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Commit** | [`39b7160`](https://github.com/bitfocus/companion-module-nextologies-nextotalk/commit/39b7160dad53efebd04ca4a0f86a3175f8c2ec70) |
| **Reviewed** | 2026-11-19 |

## Verdict: ✅ Approved

## ❓ Assumptions

Some findings depend on assumptions the reviewers couldn't check. They're listed in [❓ Assumptions to Confirm](#-assumptions-to-confirm) at the end of this review.

## 📋 Issues

### Non-blocking

- [ ] [M1: Room names with four or more words get their first and last lines cut off on the key](#m1-room-names-with-four-or-more-words-get-their-first-and-last-lines-cut-off-on-the-key)
- [ ] [M2: Room names in Chinese, Japanese, Korean, Arabic or with emoji show as empty boxes on the key](#m2-room-names-in-chinese-japanese-korean-arabic-or-with-emoji-show-as-empty-boxes-on-the-key)
- [ ] [L1: Connections upgraded from 1.0.1 stay on port 7005, which the new HELP says not to use](#l1-connections-upgraded-from-101-stay-on-port-7005-which-the-new-help-says-not-to-use)
- [ ] [L2: Inactive or unknown-state rooms now show their name in bright white instead of dimmed grey](#l2-inactive-or-unknown-state-rooms-now-show-their-name-in-bright-white-instead-of-dimmed-grey)
- [ ] [L3: yarn lint fails on a fresh clone until the render assets are generated](#l3-yarn-lint-fails-on-a-fresh-clone-until-the-render-assets-are-generated)

## 🟡 Medium

### M1: Room names with four or more words get their first and last lines cut off on the key

- **Source:** 🔎 QA reviewer
- **Classification:** 🔙 REGRESSION
- **File:** [`src/key-art.ts:37-43`](https://github.com/bitfocus/companion-module-nextologies-nextotalk/blob/39b7160dad53efebd04ca4a0f86a3175f8c2ec70/src/key-art.ts#L37-L43), [`src/key-art.ts:49-58`](https://github.com/bitfocus/companion-module-nextologies-nextotalk/blob/39b7160dad53efebd04ca4a0f86a3175f8c2ec70/src/key-art.ts#L49-L58), [`src/key-art.ts:88-94`](https://github.com/bitfocus/companion-module-nextologies-nextotalk/blob/39b7160dad53efebd04ca4a0f86a3175f8c2ec70/src/key-art.ts#L88-L94)

**What goes wrong:** The Microphone Status feedback now draws the room name into the button image, one word per line. Take an operator whose room is called "Studio B Main Feed", with the NextoTalk font level at 8 or higher. The top of "Studio" falls off the top of the key and most of "Feed" falls off the bottom. At the default level 5 the same happens to any name of five or more words, such as "Weekly All Hands Sync Meeting". Rooms like "Studio A Main Feed" and "Studio B Main Feed" then look almost the same, so the operator can press the wrong key. In v1.0.1 these names fit: the title was 9-12 px and packed up to 9 characters per line, so "Studio B Main Feed" took 2 lines. The reviewer rendered the built module: at level 10 the name takes 4 lines at 39 px, and the last line's baseline sits at y=155.8 on a 144 px image.

**Why it happens:** The name is always split into one word per line, and the font is now much larger: 28 px at level 5 and 39 px at level 10, on a 144 px image. The font-size fitting step (`fitFontPx()`) only shrinks the text when the widest line is too wide. It never checks that all the lines together fit the key's height, and the text block is centred vertically, so a tall block spills past both the top and bottom edges. The 10 px minimum size also lets a single very long word (25 or more characters) overflow sideways.

**Evidence:**

```ts
// src/key-art.ts:49-51
function textSvg(lines: string[], size: number): string {
	const lineHeight = size * 1.2
	const firstY = KEY_SIZE / 2 - ((lines.length - 1) * lineHeight) / 2 + size * 0.35
```

```ts
// src/key-art.ts:88-94
export function fitFontPx(lines: string[], level: number): number {
	const size = fontPx(level)
	if (!lines.length) return size
	const width = measureWidestLine(lines, size)
	if (width <= MAX_TEXT_WIDTH) return size
	return Math.max(MIN_FONT_PX, Math.floor((size * MAX_TEXT_WIDTH) / width))
}
```

**Fix:** limit the font size by the key's height as well as its width. Alternatively, pack short words onto one line when the name has more than about three words. A test that renders a five-word name at level 10 and checks that the text stays inside 0..144 on both axes would catch a regression.

```ts
const maxByHeight = Math.floor((KEY_SIZE - 8) / (lines.length * 1.2))
return Math.min(widthFittedSize, maxByHeight)
```

### M2: Room names in Chinese, Japanese, Korean, Arabic or with emoji show as empty boxes on the key

- **Source:** 🔎 QA reviewer
- **Classification:** 🔙 REGRESSION (depends on [A2](#-assumptions-to-confirm))
- **File:** [`src/key-art.ts:14-16`](https://github.com/bitfocus/companion-module-nextologies-nextotalk/blob/39b7160dad53efebd04ca4a0f86a3175f8c2ec70/src/key-art.ts#L14-L16)

**What goes wrong:** Take a user whose Google Meet or NextoTalk room is named "会议室 A", "غرفة 1" or "Studio 🎙". On a button with the Microphone Status feedback, those characters show as empty rectangles, e.g. "□□□ A", "□□□□ 1" or "Studio □". The reviewer rendered these names with the built module, and the images show the boxes. Every non-Latin room then looks the same, so the operator can't tell which key mutes which room. In v1.0.1 the name went into Companion's own button title, which draws these scripts with Companion's fallback fonts (see [A2](#-assumptions-to-confirm)). Rooms named only in Latin, Greek, Cyrillic or Hebrew letters are not affected.

**Why it happens:** The image renderer is given exactly one font, Arimo Bold, which covers Latin, Greek, Cyrillic and Hebrew, and it is told not to load any system fonts. For any other script or emoji it has no font to fall back to, so it draws the "missing glyph" box instead of failing. Because the render succeeds, the module's existing fallback to Companion's own title (in `keyStyle()` in `src/feedbacks.ts`) never runs.

**Evidence:**

```ts
// src/key-art.ts:14-16
const FONT_FAMILY = 'Arimo' // metric-compatible with Helvetica/Arial, the plugin's font
const FONT_BYTES = Buffer.from(ROOM_NAME_FONT_BASE64, 'base64')
const FONT_OPTIONS = { fontBuffers: [FONT_BYTES], defaultFontFamily: FONT_FAMILY, loadSystemFonts: false }
```

**Fix:** before rendering, check that the name only uses characters the bundled font covers, and otherwise use the existing Companion-title fallback so Companion's own fonts draw it. Adjust the ranges to Arimo's real coverage. Another option is to bundle a fallback font (e.g. Noto for CJK, Arabic and emoji). A test that renders a CJK name would catch a regression.

```ts
// Latin, Greek, Cyrillic, Hebrew and common punctuation
const ARIMO_COVERED = /^[ -׿Ḁ-⁯₠-⃏\s]*$/

if (!ARIMO_COVERED.test(name)) {
	return { text: name, size: fontSizePxFromLevel(level), png64: ART_PNG64[art] }
}
```

## 🟢 Low

### L1: Connections upgraded from 1.0.1 stay on port 7005, which the new HELP says not to use

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW (depends on [A1](#-assumptions-to-confirm))
- **File:** [`src/config.ts:17`](https://github.com/bitfocus/companion-module-nextologies-nextotalk/blob/39b7160dad53efebd04ca4a0f86a3175f8c2ec70/src/config.ts#L17), [`src/main.ts:99`](https://github.com/bitfocus/companion-module-nextologies-nextotalk/blob/39b7160dad53efebd04ca4a0f86a3175f8c2ec70/src/main.ts#L99), [`companion/HELP.md:18`](https://github.com/bitfocus/companion-module-nextologies-nextotalk/blob/39b7160dad53efebd04ca4a0f86a3175f8c2ec70/companion/HELP.md#L18), [`src/upgrades.ts:5`](https://github.com/bitfocus/companion-module-nextologies-nextotalk/blob/39b7160dad53efebd04ca4a0f86a3175f8c2ec70/src/upgrades.ts#L5)

**What goes wrong:** Anyone who added the connection on 1.0.0 or 1.0.1 and kept the default has WebSocket Port = 7005 saved. Updating to 1.0.3 changes only the default for new connections, so their connection stays on 7005. The 1.0.3 HELP now says: "Do not use 7005: that is the fixed port of the Elgato Stream Deck plugin, and the extension talks to both at once." If that user also runs the Elgato plugin, the connection status shows "Port 7005 in use?", or the Elgato plugin can't open its port. They have to work out from the Troubleshooting table that they should change the port to 7006 and update the extension to match, because nothing tells them when they upgrade. Users who don't run the Elgato plugin see no change.

**Why it happens:** Commit `6b4fa54` changed the config default (and the `|| 7006` fallback in `src/main.ts`) from 7005 to 7006. Companion keeps a connection's saved settings across module updates; only an upgrade script can change them, and this module's upgrade script list is still empty. HELP.md has no note for people upgrading.

**Fix:** tell users on 7005 what to do. The simplest option is an "Upgrading from 1.0.1" line in `companion/HELP.md`: change WebSocket Port from 7005 to 7006 and set the NextoTalk extension to the same port. If the extension always expects 7006 for Companion, you could instead add an upgrade script that moves a saved 7005 to 7006, and mention the change in HELP.

```ts
export const UpgradeScripts: CompanionStaticUpgradeScript<ModuleConfig>[] = [
	(_context, props) => ({
		updatedConfig: props.config?.port === 7005 ? { ...props.config, port: 7006 } : null,
		updatedActions: [],
		updatedFeedbacks: [],
	}),
]
```

### L2: Inactive or unknown-state rooms now show their name in bright white instead of dimmed grey

- **Source:** 🔎 QA reviewer
- **Classification:** 🔙 REGRESSION
- **File:** [`src/feedbacks.ts:86-90`](https://github.com/bitfocus/companion-module-nextologies-nextotalk/blob/39b7160dad53efebd04ca4a0f86a3175f8c2ec70/src/feedbacks.ts#L86-L90), [`src/key-art.ts:55`](https://github.com/bitfocus/companion-module-nextologies-nextotalk/blob/39b7160dad53efebd04ca4a0f86a3175f8c2ec70/src/key-art.ts#L55)

**What goes wrong:** In v1.0.1, a Microphone Status button for a room that is mapped but inactive (meeting tab closed, or no mic status received yet) showed the room name in dim grey over the empty artwork, so the operator could see the room was idle. In v1.0.3 the name is drawn into the image in white for every state, so an inactive "Control Room" key has the same bright white text as a live one. The dark background still sets it apart, but the dimmed look is gone.

**Why it happens:** The text drawn into the image is always white. When the image renders, the feedback leaves Companion's own title empty, so the grey text colour the inactive branch still sets (`color: combineRgb(100, 100, 100)`) has nothing to apply to.

**Evidence:**

```ts
// src/feedbacks.ts:86-90
							return {
								bgcolor: combineRgb(0, 0, 0),
								color: combineRgb(100, 100, 100),
								...(await keyStyle(self, 'empty', info.name, info.fontSize)),
							}
```

```ts
// src/key-art.ts:55
`<text x="${KEY_SIZE / 2}" y="${(firstY + i * lineHeight).toFixed(1)}" font-family="${FONT_FAMILY}" font-weight="bold" font-size="${size}" fill="white" text-anchor="middle">${escapeXml(l)}</text>`,
```

**Fix:** pass a text colour into the renderer, e.g. `#646464` for the empty (inactive) artwork and `white` otherwise, and include it in the render cache key. If white is intended, remove the unused grey `color` instead.

### L3: yarn lint fails on a fresh clone until the render assets are generated

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/key-art.ts:2`](https://github.com/bitfocus/companion-module-nextologies-nextotalk/blob/39b7160dad53efebd04ca4a0f86a3175f8c2ec70/src/key-art.ts#L2), [`eslint.config.mjs:19-26`](https://github.com/bitfocus/companion-module-nextologies-nextotalk/blob/39b7160dad53efebd04ca4a0f86a3175f8c2ec70/eslint.config.mjs#L19-L26)

**What goes wrong:** Companion users see no difference. A contributor who clones the repository, runs `yarn install` and then `yarn lint` gets `Can't resolve './generated/render-assets.js'` (`n/no-missing-import`) on `src/key-art.ts:2`, and lint fails. The pre-commit hook runs the same lint, so it also blocks a commit that touches `src/key-art.ts` until the contributor has run `yarn build` or `yarn test`. CI is not affected, because the lint workflow runs `yarn build` before `yarn lint`. The reviewer reproduced this in a fresh clone of v1.0.3.

**Why it happens:** `src/generated/render-assets.ts` is gitignored and only created by the `gen:render-assets` step inside the `build`, `dev` and `test` scripts; `yarn install` doesn't create it. The new ESLint block for `src/key-art.ts` turns off only `n/no-unpublished-import`, not `n/no-missing-import`, so importing the not-yet-generated file is still an error.

**Evidence:**

```ts
// src/key-art.ts:1-2
import { initWasm, Resvg } from '@resvg/resvg-wasm'
import { RESVG_WASM_BASE64, ROOM_NAME_FONT_BASE64 } from './generated/render-assets.js'
```

```js
// eslint.config.mjs:19-26
	{
		// Imports src/generated/render-assets.ts — generated at build time (gitignored) and
		// bundled into the package by webpack, so "unpublished" doesn't apply.
		files: ['src/key-art.ts'],
		rules: {
			'n/no-unpublished-import': 'off',
		},
	},
```

**Fix:** also turn off `n/no-missing-import` in the existing `src/key-art.ts` block of `eslint.config.mjs`. TypeScript still catches a truly missing import at build time. Don't add the generator to the `lint` script, because that would change a template script.

```js
		rules: {
			'n/no-unpublished-import': 'off',
			'n/no-missing-import': 'off',
		},
```

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Companion keeps a connection's saved config values when the module is updated, so an existing connection stays on port 7005 unless an upgrade script changes it | Standard Companion config persistence; upgrade scripts are the only mechanism that changes saved config, and this module's `src/upgrades.ts` is empty. Companion's host code not checked | [L1](#l1-connections-upgraded-from-101-stay-on-port-7005-which-the-new-help-says-not-to-use) |
| A2 | Companion's built-in button-title renderer (used in v1.0.1 through `text: info.name`) has fallback fonts for CJK and emoji, so these names showed correctly before this release | Recollection of Companion 3.x font registration; not checked in the module or `@companion-module/base`. If Companion never drew these scripts, the finding is 🆕 NEW rather than a regression, but the empty boxes are still visible | [M2](#m2-room-names-in-chinese-japanese-korean-arabic-or-with-emoji-show-as-empty-boxes-on-the-key) |
