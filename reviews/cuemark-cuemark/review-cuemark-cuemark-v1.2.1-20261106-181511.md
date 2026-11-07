# Re-review: companion-module-cuemark-cuemark v1.2.1

| | |
| --- | --- |
| **Module** | `companion-module-cuemark-cuemark` |
| **Scope** | `tag` — the module has never been published, so there is no published tag to diff against: the whole module was reviewed again, every finding is 🆕 NEW, and each finding of the [v1.2.0 review](review-cuemark-cuemark-v1.2.0-20261031-201135.md) was re-checked against v1.2.1 (`v1.2.0..v1.2.1`: 10 files, +702/−469) |
| **Version** | `v1.2.1` ([`520480f`](https://github.com/bitfocus/companion-module-cuemark-cuemark/tree/520480f3b50d6ac26aff1916895323de9feb7895)) |
| **Release** | New module — never published |
| **API** | 1 (base 1.12.1, yarn.lock) |
| **Template** | `companion-module-template-js-v1` @ `9e222b4` (2026-03-26, pinned) · `.yarnrc.yml` from `companion-module-template-js` @ `89da037` (2026-11-01) |
| **Follow-up to** | [v1.2.0 review](review-cuemark-cuemark-v1.2.0-20261031-201135.md) (2026-10-31): all seven of its findings are fixed |
| **Build** | `yarn install --immutable` and `yarn package` pass |
| **Date** | 2026-11-06 |

## Verdict: ✅ Approved

## 📋 Issues

### Notes

- **v1.2.0 review:** all seven findings of the [v1.2.0 review](review-cuemark-cuemark-v1.2.0-20261031-201135.md) are fixed in v1.2.1 (details in Additional Notes).
- [📝 Additional Notes](#-additional-notes)

## 📝 Additional Notes

- **Fixed since the v1.2.0 review** — every finding of the [v1.2.0 review](review-cuemark-cuemark-v1.2.0-20261031-201135.md) is fixed in v1.2.1:
  - [v1.2.0 H1](review-cuemark-cuemark-v1.2.0-20261031-201135.md#h1-the-manifest-lists-a-legacy-id-although-the-module-has-never-been-published) (legacy id in the manifest): `legacyIds` is now `[]` ([`companion/manifest.json:20`](https://github.com/bitfocus/companion-module-cuemark-cuemark/blob/520480f3b50d6ac26aff1916895323de9feb7895/companion/manifest.json#L20)).
  - [v1.2.0 M1](review-cuemark-cuemark-v1.2.0-20261031-201135.md#m1-a-wrong-key-leaves-the-connection-on-connecting-with-no-error) (a wrong Key leaves Connecting): the poll now shares the button presses' answer check, so a refused key shows "Key refused — …" and any other error reply shows "Cuemark said …" ([`src/index.js:73-86`](https://github.com/bitfocus/companion-module-cuemark-cuemark/blob/520480f3b50d6ac26aff1916895323de9feb7895/src/index.js#L73-L86), [`src/index.js:276-280`](https://github.com/bitfocus/companion-module-cuemark-cuemark/blob/520480f3b50d6ac26aff1916895323de9feb7895/src/index.js#L276-L280)), and saving the settings resets the status to Connecting ([`src/index.js:49-55`](https://github.com/bitfocus/companion-module-cuemark-cuemark/blob/520480f3b50d6ac26aff1916895323de9feb7895/src/index.js#L49-L55)).
  - [v1.2.0 L1](review-cuemark-cuemark-v1.2.0-20261031-201135.md#l1-turning-off-read-what-is-on-deck-leaves-the-connection-on-connecting) (Read what is on deck off leaves Connecting): with the box unticked the module asks Cuemark once, sets the status from the answer and starts no timer, and the tooltip now says the variables and feedbacks don't update ([`src/index.js:109-118`](https://github.com/bitfocus/companion-module-cuemark-cuemark/blob/520480f3b50d6ac26aff1916895323de9feb7895/src/index.js#L109-L118), [`src/index.js:285`](https://github.com/bitfocus/companion-module-cuemark-cuemark/blob/520480f3b50d6ac26aff1916895323de9feb7895/src/index.js#L285)).
  - [v1.2.0 L2](review-cuemark-cuemark-v1.2.0-20261031-201135.md#l2-the-connection-log-fills-with-a-debug-line-twice-a-second-while-cuemark-is-closed) (a debug line twice a second while Cuemark is closed): the line is logged only when the status changes, and the poll slows to every 3 s while Cuemark doesn't answer ([`src/index.js:23-25`](https://github.com/bitfocus/companion-module-cuemark-cuemark/blob/520480f3b50d6ac26aff1916895323de9feb7895/src/index.js#L23-L25), [`src/index.js:88-93`](https://github.com/bitfocus/companion-module-cuemark-cuemark/blob/520480f3b50d6ac26aff1916895323de9feb7895/src/index.js#L88-L93)).
  - [v1.2.0 L3](review-cuemark-cuemark-v1.2.0-20261031-201135.md#l3-the-go-to-page-action-sends-a-fractional-page-number-as-typed) (fractional page number): the page is rounded to a whole page of at least 1, and the option has `step: 1` ([`src/index.js:28`](https://github.com/bitfocus/companion-module-cuemark-cuemark/blob/520480f3b50d6ac26aff1916895323de9feb7895/src/index.js#L28), [`src/index.js:149-154`](https://github.com/bitfocus/companion-module-cuemark-cuemark/blob/520480f3b50d6ac26aff1916895323de9feb7895/src/index.js#L149-L154)).
  - [v1.2.0 L4](review-cuemark-cuemark-v1.2.0-20261031-201135.md#l4-upgrade-scripts-are-declared-in-indexjs-rather-than-a-separate-upgradesjs) (upgrade scripts in index.js): they now live in [`src/upgrades.js`](https://github.com/bitfocus/companion-module-cuemark-cuemark/blob/520480f3b50d6ac26aff1916895323de9feb7895/src/upgrades.js#L7), which [`src/main.js:14-18`](https://github.com/bitfocus/companion-module-cuemark-cuemark/blob/520480f3b50d6ac26aff1916895323de9feb7895/src/main.js#L14-L18) passes to `runEntrypoint`.
  - [v1.2.0 N1](review-cuemark-cuemark-v1.2.0-20261031-201135.md#n1-every-poll-resends-all-variables-and-feedbacks-even-when-nothing-changed) (every poll resends everything): the status is sent only when it changes, and each poll sends only the variables that changed and re-checks only the feedbacks that flipped ([`src/index.js:57-66`](https://github.com/bitfocus/companion-module-cuemark-cuemark/blob/520480f3b50d6ac26aff1916895323de9feb7895/src/index.js#L57-L66), [`src/index.js:298-312`](https://github.com/bitfocus/companion-module-cuemark-cuemark/blob/520480f3b50d6ac26aff1916895323de9feb7895/src/index.js#L298-L312)).
