# Review: nextologies-nextotalk v1.0.2 (follow-up to the v1.0.0 review)

| | |
| --- | --- |
| **Module** | nextologies-nextotalk |
| **Scope** | `tag` (v1.0.1..v1.0.2) |
| **Version** | v1.0.2 |
| **Release** | Update — last published v1.0.1 |
| **API** | 1 (base 1.14.1, yarn.lock) |
| **Template** | `companion-module-template-ts-v1` @ `42609d8` (2026-03-03, pinned) · `.yarnrc.yml` from `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Prior review** | [v1.0.0 (2026-08-03)](review-nextologies-nextotalk-v1.0.0-20260803-184331.md). All of its blocking findings are resolved (see [📝 Additional Notes](#-additional-notes)) |
| **Reviewed commit** | [`e3fc882`](https://github.com/bitfocus/companion-module-nextologies-nextotalk/commit/e3fc882f9033b73ceecec33425612108de144b14) |
| **Protocols** | WebSocket server (`ws` ^8.21.0), key images drawn with `@resvg/resvg-wasm` 2.6.2 |
| **Reviewed** | 2026-11-06 |

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Companion keeps a connection's module process running for as long as the connection is enabled (days or weeks on a show machine), so leaked memory builds up and is only given back when the connection or Companion restarts | Companion runs each connection in a long-lived child process; the module's own prune comment in `src/state.ts` expects "weeks of uptime". Companion's host code was not checked | [H1](#h1-module-memory-grows-every-time-a-new-key-image-is-drawn-and-is-never-given-back) |
| A2 | The NextoTalk extension sends enough distinct room names and font-size levels in real use (the module's comment says "hundreds of meetings/day") for the leak to reach about 10 MB a day | The maintainer's comment in `src/state.ts:176-181`, not observed traffic. The leak itself (about 15 KB per new image) was measured | [H1](#h1-module-memory-grows-every-time-a-new-key-image-is-drawn-and-is-never-given-back) |
| A3 | Companion's built-in button text renderer, which drew the room name up to v1.0.1, wraps text that is wider than the button onto more lines, so multi-word names from `update_room_name` used to be readable | How Companion 3.x/4.x renders button text; cannot be checked from the module or `@companion-module/base` | [M1](#m1-renamed-rooms-and-bare-meeting-ids-are-drawn-on-one-line-and-cut-off-at-the-button-edges) |
| A4 | The NextoTalk Chrome extension connects to port 7006 out of the box, so a user who follows the help page's 7005 ends up with a port mismatch | The message of commit `6b4fa54` ("Default to 7006, matching what the Chrome extension expects"); the extension's code is not in this repo. The help page disagreeing with the module's own default is confirmed from code either way | [L1](#l1-help-page-still-says-the-default-websocket-port-is-7005-but-new-connections-listen-on-7006) |

## 📋 Issues

### Blocking

- [ ] [H1: Module memory grows every time a new key image is drawn and is never given back](#h1-module-memory-grows-every-time-a-new-key-image-is-drawn-and-is-never-given-back)
- [ ] [H2: yarn test fails on a fresh checkout because a generated file only exists after a build](#h2-yarn-test-fails-on-a-fresh-checkout-because-a-generated-file-only-exists-after-a-build)

### Non-blocking

- [ ] [M1: Renamed rooms and bare meeting IDs are drawn on one line and cut off at the button edges](#m1-renamed-rooms-and-bare-meeting-ids-are-drawn-on-one-line-and-cut-off-at-the-button-edges)
- [ ] [L1: Help page still says the default WebSocket port is 7005, but new connections listen on 7006](#l1-help-page-still-says-the-default-websocket-port-is-7005-but-new-connections-listen-on-7006)
- [ ] [L2: A room mapped without a mic state shows red and muted instead of the new neutral look](#l2-a-room-mapped-without-a-mic-state-shows-red-and-muted-instead-of-the-new-neutral-look)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟠 High

### H1: Module memory grows every time a new key image is drawn and is never given back

- **Source:** 🔎 QA reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/key-art.ts:66-75`](https://github.com/bitfocus/companion-module-nextologies-nextotalk/blob/e3fc882f9033b73ceecec33425612108de144b14/src/key-art.ts#L66-L75)

**What goes wrong:** In v1.0.2 the Microphone Status feedback draws the room name into the button image itself. Each time it draws an image it has not drawn before, about 15 KB of memory stays allocated in the module's process for good. A new image is drawn for every new room name (for example a new meeting called "Team Sync"), for each of its three looks (no status / muted / unmuted) and for each room-name font size. A site with a few fixed rooms loses well under 1 MB in total and won't notice. A site that goes through hundreds of meetings a day, which is the load the module's own hourly prune is built for, loses about 10 MB or more a day, and the connection's process keeps growing until the connection or Companion is restarted. Once more than 200 name/look/size combinations are in use, the module's image cache starts dropping old entries, so ordinary mute toggles redraw images and leak again.

**Why it happens:** The image is drawn by the resvg library, which runs as WebAssembly, so its objects hold memory that JavaScript's garbage collector doesn't manage. In the pinned version (`@resvg/resvg-wasm` 2.6.2) the renderer object (`Resvg`) is released only when the code calls its `.free()` method: unlike the rendered image, it is never registered for automatic clean-up. `renderKeyPng64()` creates a new renderer and a rendered image for every image that isn't cached and frees neither, so each renderer's copy of the parsed SVG (with the embedded key artwork) stays in memory. The rendered image is only freed whenever the garbage collector happens to get to it.

**Evidence:**

```ts
// src/key-art.ts:56-76  (file is new in v1.0.2)
// Feedbacks re-run often with the same inputs; keep recent renders.
const cache = new Map<string, string>()
const CACHE_LIMIT = 200

// Returns the key image (artwork + room name) as base64 PNG for a feedback's `png64`.
export async function renderKeyPng64(art: KeyArt, name: string, level: number): Promise<string> {
	const cacheKey = `${art}|${level}|${name}`
	const cached = cache.get(cacheKey)
	if (cached) return cached

	await ensureRenderer()
	const resvg = new Resvg(keySvg(ART_PNG64[art], name, level), {
		fitTo: { mode: 'width', value: KEY_SIZE },
		font: { fontBuffers: [FONT_BYTES], defaultFontFamily: FONT_FAMILY, loadSystemFonts: false },
	})
	const png64 = Buffer.from(resvg.render().asPng()).toString('base64')

	if (cache.size >= CACHE_LIMIT) cache.delete(cache.keys().next().value as string)
	cache.set(cacheKey, png64)
	return png64
}
```

```js
// node_modules/@resvg/resvg-wasm/index.js:279-293  (v2.6.2)
var ResvgFinalization = typeof FinalizationRegistry === "undefined" ? { register: () => {
}, unregister: () => {
} } : new FinalizationRegistry((ptr) => wasm.__wbg_resvg_free(ptr >>> 0));
var Resvg = class {
  __destroy_into_raw() {
    const ptr = this.__wbg_ptr;
    this.__wbg_ptr = 0;
    ResvgFinalization.unregister(this);
    return ptr;
  }
  free() {
    const ptr = this.__destroy_into_raw();
    wasm.__wbg_resvg_free(ptr);
  }
// node_modules/@resvg/resvg-wasm/index.js:298-315: the constructor sets this.__wbg_ptr
// and returns; it never calls ResvgFinalization.register
```

```text
$ grep -n "Finalization.register" node_modules/@resvg/resvg-wasm/index.js
148:    BBoxFinalization.register(obj, obj.__wbg_ptr, obj);
222:    RenderedImageFinalization.register(obj, obj.__wbg_ptr, obj);
$ grep -rn "\.free()" src/
(no matches)

Measured with the module's own built renderKeyPng64 (unique names, gc() between steps), wasm memory:
renders   1000   2000   3000   4000   5000   6000
MB        98.9  113.2  128.5  143.3  157.9  173.1   (about 14.8 KB more per uncached render)
with img.free() + resvg.free(): 2.2 MB, flat from 0 to 6000
```

**Confirm by:** open [`src/key-art.ts:66-71`](https://github.com/bitfocus/companion-module-nextologies-nextotalk/blob/e3fc882f9033b73ceecec33425612108de144b14/src/key-art.ts#L66-L71) and check that neither `resvg.free()` nor a free of the `.render()` result is called. Then check in `node_modules/@resvg/resvg-wasm/index.js:298-315` that the `Resvg` constructor never calls `ResvgFinalization.register`, so only an explicit `.free()` releases it.

**Fix:** free both WebAssembly objects explicitly, even when drawing throws.

```ts
const resvg = new Resvg(keySvg(ART_PNG64[art], name, level), {
	fitTo: { mode: 'width', value: KEY_SIZE },
	font: { fontBuffers: [FONT_BYTES], defaultFontFamily: FONT_FAMILY, loadSystemFonts: false },
})
let png64: string
try {
	const img = resvg.render()
	try {
		png64 = Buffer.from(img.asPng()).toString('base64')
	} finally {
		img.free()
	}
} finally {
	resvg.free()
}
```

Optionally, make the cache least-recently-used (on a hit, delete the key and set it again) so the images in use every day aren't the ones evicted and redrawn.

### H2: yarn test fails on a fresh checkout because a generated file only exists after a build

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`package.json:16`](https://github.com/bitfocus/companion-module-nextologies-nextotalk/blob/e3fc882f9033b73ceecec33425612108de144b14/package.json#L16), [`src/key-art.ts:2`](https://github.com/bitfocus/companion-module-nextologies-nextotalk/blob/e3fc882f9033b73ceecec33425612108de144b14/src/key-art.ts#L2)

**What goes wrong:** The module's own test command doesn't work from a clean checkout. A developer or CI job that clones the repo and runs `yarn install && yarn test` (for example the commented-out test job in `.github/workflows/node.yaml`, once enabled) gets a failed suite with 0 tests run: `FAIL src/__tests__/main.test.ts - Error: Failed to load url ./generated/render-assets.js (resolved id: ./generated/render-assets.js) in .../src/key-art.ts. Does the file exist?`. After a build, the same 2 tests pass.

**Why it happens:** `src/key-art.ts` imports `./generated/render-assets.js`. That file is gitignored (`/src/generated`) and is written only by `scripts/gen-render-assets.mjs`, which the `build` and `dev` scripts run but `test` (`vitest run`) does not. The test imports `main.js`, which pulls in the feedbacks and then `key-art.ts`, so loading fails before any test runs.

**Evidence:**

```text
package.json:16        "test": "vitest run"
package.json:10        "build": "rimraf dist && run gen:render-assets && run build:main"
src/key-art.ts:2       import { RESVG_WASM_BASE64, ROOM_NAME_FONT_BASE64 } from './generated/render-assets.js'
.gitignore:10          /src/generated
git ls-tree e3fc882    src/generated is not in the repository (only scripts/gen-render-assets.mjs)
```

**Confirm by:** clone the tag, run `yarn install && yarn test` without building first, and see the suite fail to load `./generated/render-assets.js`. Then compare [`package.json:16`](https://github.com/bitfocus/companion-module-nextologies-nextotalk/blob/e3fc882f9033b73ceecec33425612108de144b14/package.json#L16) (`test`) with [`package.json:10`](https://github.com/bitfocus/companion-module-nextologies-nextotalk/blob/e3fc882f9033b73ceecec33425612108de144b14/package.json#L10) (`build`, which runs `gen:render-assets`).

**Fix:** generate the assets before running vitest, for example `"test": "run gen:render-assets && vitest run"` (Yarn 4 does not run `pretest` hooks, so the step has to be in the script itself), or run the generator from a vitest `globalSetup`.

## 🟡 Medium

### M1: Renamed rooms and bare meeting IDs are drawn on one line and cut off at the button edges

- **Source:** 🔎 QA reviewer + protocol reviewer
- **Classification:** 🔙 REGRESSION
- **File:** [`src/main.ts:457`](https://github.com/bitfocus/companion-module-nextologies-nextotalk/blob/e3fc882f9033b73ceecec33425612108de144b14/src/main.ts#L457), [`src/key-art.ts:33-35`](https://github.com/bitfocus/companion-module-nextologies-nextotalk/blob/e3fc882f9033b73ceecec33425612108de144b14/src/key-art.ts#L33-L35), [`src/state.ts:128`](https://github.com/bitfocus/companion-module-nextologies-nextotalk/blob/e3fc882f9033b73ceecec33425612108de144b14/src/state.ts#L128)

**What goes wrong:** When the NextoTalk extension renames a room (its `update_room_name` message), for example to "Control Room One", the Microphone Status button now shows the bold name on a single line, centred and cut off on both sides (roughly "ntrol Room O"). Up to v1.0.1 the name went into the button's Companion text, which wraps long text onto more lines. The same happens when a room has no title yet and the button falls back to the raw meeting ID ("abc-defg-hij" is 156 px wide on the 144 px image), and for any single word wider than the button at the room's font size ("Conference" is 152 px at the default level 5). The name stays cut off until a later mic-status or mapping message stores it again. Short, multi-word names that arrive through `map_meeting_room_to_key`, `room_allocated` or `update_mic_status` are drawn correctly.

**Why it happens:** The new image drawing (`keySvg()`) only starts a new line where the name already contains a line break, and it has no shrink-to-fit. Its comment assumes every name has already been split by `lineBreakedMeetingTitle()`. Three message handlers do that ([`src/main.ts:278`](https://github.com/bitfocus/companion-module-nextologies-nextotalk/blob/e3fc882f9033b73ceecec33425612108de144b14/src/main.ts#L278), [`src/main.ts:341`](https://github.com/bitfocus/companion-module-nextologies-nextotalk/blob/e3fc882f9033b73ceecec33425612108de144b14/src/main.ts#L341), [`src/main.ts:378`](https://github.com/bitfocus/companion-module-nextologies-nextotalk/blob/e3fc882f9033b73ceecec33425612108de144b14/src/main.ts#L378)), but the `update_room_name` handler stores the name unchanged, and the meeting-ID fallback in `getRoomInfoForMeeting()` is not split either. Anything wider than the 144 px image is cropped. The widths above were measured with the bundled Arimo Bold font in resvg.

**Evidence:**

```ts
// src/main.ts:457  (update_room_name handler)
				this.state.updateRoomName(meetingId, roomName)
// src/key-art.ts:33-35
// `name` is already line-broken by lineBreakedMeetingTitle() in main.ts.
function keySvg(artPng64: string, name: string, level: number): string {
	const lines = name.split('\n').filter((l) => l.length > 0)
// src/state.ts:128
			name: this.meetingIdTitleMap[meetingId] || meetingId,
```

**Fix:** do the line breaking inside `keySvg()`, so every source of a name is covered, including the meeting-ID fallback: when the name has no `\n`, split it with the same `/\s+|(?<=[-_])/` pattern. At minimum, store `this.lineBreakedMeetingTitle(roomName)` in the `update_room_name` handler (the acknowledgement can keep sending the raw `roomName`). For single words that are still too wide, measure each line (for example with `new Resvg(textOnlySvg).getBBox()`, then free it) and reduce the font size until the widest line fits inside the 144 px key with a small margin.

## 🟢 Low

### L1: Help page still says the default WebSocket port is 7005, but new connections listen on 7006

- **Source:** 🔎 protocol reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`companion/HELP.md:11`](https://github.com/bitfocus/companion-module-nextologies-nextotalk/blob/e3fc882f9033b73ceecec33425612108de144b14/companion/HELP.md#L11), [`companion/HELP.md:18`](https://github.com/bitfocus/companion-module-nextologies-nextotalk/blob/e3fc882f9033b73ceecec33425612108de144b14/companion/HELP.md#L18), [`companion/HELP.md:145`](https://github.com/bitfocus/companion-module-nextologies-nextotalk/blob/e3fc882f9033b73ceecec33425612108de144b14/companion/HELP.md#L145)

**What goes wrong:** A user adding a new Nextologies Meet Controller connection gets a WebSocket Port of 7006, but the help page says the default is 7005 in three places: the requirements list, setup step 2 and the troubleshooting row "Port 7005 in use". A user who follows the help and points the extension at 7005 sees the connection status as OK ("v1.0.2 · 127.0.0.1:7006"), but the `connected_clients` variable stays at 0 and no mic-status buttons light up. A user who instead sets the module to 7005 to match the help collides with the Elgato plugin's fixed port, which is the reason commit `6b4fa54` gives for moving away from 7005. Existing connections keep their saved port and are not affected.

**Why it happens:** Commit `6b4fa54` changed the default port from 7005 to 7006 in [`src/config.ts:17`](https://github.com/bitfocus/companion-module-nextologies-nextotalk/blob/e3fc882f9033b73ceecec33425612108de144b14/src/config.ts#L17) and [`src/main.ts:98`](https://github.com/bitfocus/companion-module-nextologies-nextotalk/blob/e3fc882f9033b73ceecec33425612108de144b14/src/main.ts#L98), but did not update `companion/HELP.md`, which this release edits only at line 77 (the font-size text).

**Fix:** change the three mentions of 7005 in `companion/HELP.md` to 7006. In the troubleshooting row, also say that 7005 is the Elgato plugin's fixed port, so users know not to pick it.

### L2: A room mapped without a mic state shows red and muted instead of the new neutral look

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:266-274`](https://github.com/bitfocus/companion-module-nextologies-nextotalk/blob/e3fc882f9033b73ceecec33425612108de144b14/src/main.ts#L266-L274), [`src/state.ts:124-130`](https://github.com/bitfocus/companion-module-nextologies-nextotalk/blob/e3fc882f9033b73ceecec33425612108de144b14/src/state.ts#L124-L130)

**What goes wrong:** v1.0.2 adds a neutral Microphone Status look (black, grey text, empty artwork) for rooms that are allocated or mapped but have no mic status yet. When a room is mapped to a button with `map_meeting_room_to_key` and the message carries no `isMuted` value, the button still turns red with the muted icon, so the operator sees "muted" while the module doesn't know the mic state. Rooms allocated through `room_allocated`, or mapped with an `isMuted` value, get the right look.

**Why it happens:** The new "has mic status" check is true as soon as the module has stored any mute value for the meeting. The mapping handler stores a default of "muted" when the message has no `isMuted`, so the check passes and the feedback takes the muted branch. The new comment in `src/state.ts` says that mapped rooms without a mic status must render neutral, which this path contradicts.

**Fix:** in the `map_meeting_room_to_key` handler, store the mic status only when `isMuted` is present (busy and speaking can still be updated on their own), so the meeting has no stored mute value and the neutral look applies.

## 📝 Additional Notes

- **Follow-up to the [v1.0.0 review](review-nextologies-nextotalk-v1.0.0-20260803-184331.md):** all five of its blocking findings are resolved at v1.0.2. Accepted client sockets now have an `error` listener and the server sets a 1 MiB `maxPayload` (prior C1, [`src/main.ts:102`](https://github.com/bitfocus/companion-module-nextologies-nextotalk/blob/e3fc882f9033b73ceecec33425612108de144b14/src/main.ts#L102), [`src/main.ts:153`](https://github.com/bitfocus/companion-module-nextologies-nextotalk/blob/e3fc882f9033b73ceecec33425612108de144b14/src/main.ts#L153)). `eslint.config.mjs` now spreads the template's `generateEslintConfig()` output and adds scoped overrides, which is an accepted deviation (prior C3). `repository.url` points at the bitfocus org (prior C4). The manifest keywords no longer repeat the product name (prior C6). The version shown in the connection status, the `module_version` variable and the welcome payload is read from `package.json` (prior C7, [`src/main.ts:22`](https://github.com/bitfocus/companion-module-nextologies-nextotalk/blob/e3fc882f9033b73ceecec33425612108de144b14/src/main.ts#L22)).
