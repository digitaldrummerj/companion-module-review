# Review: presentationtools-aps v2.11.0 (follow-up)

| | |
| --- | --- |
| **Module** | `companion-module-presentationtools-aps` ([repo](https://github.com/bitfocus/companion-module-presentationtools-aps)) |
| **Scope** | `tag` (`v2.10.0..v2.11.0`, follow-up to the v2.10.0 review) |
| **Version** | v2.11.0 (`1f25764`, 2026-10-15) |
| **Release** | Update — last published v2.9.1 |
| **API** | 1 (base 1.14.1, yarn.lock) |
| **Template** | `companion-module-template-js-v1` @ `9e222b4` (2026-03-26, pinned) · `.yarnrc.yml` from `companion-module-template-js` @ `76d25b2` (2026-10-11) |
| **Language** | JavaScript (CommonJS) |
| **Build** | `yarn install --immutable` passes · `yarn package` passes |
| **Prior review** | [v2.10.0](review-presentationtools-aps-v2.10.0-20261005-024911.md) (❌ Changes Required) |
| **Review date** | 2026-10-30 |

This is a follow-up to the v2.10.0 review. Every finding from that review is fixed in v2.11.0, including both Next Release suggestions. The template check now passes with no findings and the module packages cleanly. One new low-severity code-order issue was introduced by the fixes.

| Prior finding | Status in v2.11.0 |
| --- | --- |
| C1: Missing `.gitattributes`, `.prettierignore`, `.yarnrc.yml` | ✅ Fixed |
| C2: `.gitignore` missing template entries | ✅ Fixed |
| C3: Source files at the repository root | ✅ Fixed (moved to `src/`, `main` and manifest entrypoint updated) |
| C4: Missing `engines` and `packageManager` | ✅ Fixed (Yarn 4 lockfile regenerated) |
| C5: No `package` script | ✅ Fixed |
| C6: Manifest runtime `node18` | ✅ Fixed (`node22`) |
| H1: LICENSE copyright line | ✅ Fixed |
| H2: Base and Prettier versions behind the template | ✅ Fixed (base `~1.14.1`, Prettier `^3.7.4`) |
| M1: Trial timer leaked on each config save | ✅ Fixed ([`src/index.js:59-60`](https://github.com/bitfocus/companion-module-presentationtools-aps/blob/1f25764523d28b11d845485de0ff9c8f2ce86b95/src/index.js#L59-L60)) |
| L1: Status stays OK after APS quits | ✅ Fixed |
| L2: Connection errors show no reason | ✅ Fixed |
| L3: Missing IP or port gives no warning | ✅ Fixed (`BadConfig` status, no fallback to hidden manual fields) |
| L4: Platform kept after switching APS computer | ✅ Fixed (platform reset when the target changes) |
| L5: Go to slide action code reads like a bug | ✅ Fixed |
| Next Release: `isVisible` → `isVisibleExpression` | ✅ Done |
| Next Release: redundant `parseVariablesInString` calls | ✅ Done |

## Verdict: ✅ Approved

## 📋 Issues

### Non-blocking

- [ ] [L1: Connected-machine variables are written before they are defined on first start](#l1-connected-machine-variables-are-written-before-they-are-defined-on-first-start)

### Notes

- [📝 Additional Notes](#-additional-notes)

---

## 🟢 Low

### L1: Connected-machine variables are written before they are defined on first start

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/index.js:141-144`](https://github.com/bitfocus/companion-module-presentationtools-aps/blob/1f25764523d28b11d845485de0ff9c8f2ce86b95/src/index.js#L141-L144), [`src/index.js:181`](https://github.com/bitfocus/companion-module-presentationtools-aps/blob/1f25764523d28b11d845485de0ff9c8f2ce86b95/src/index.js#L181), [`src/index.js:465-476`](https://github.com/bitfocus/companion-module-presentationtools-aps/blob/1f25764523d28b11d845485de0ff9c8f2ce86b95/src/index.js#L465-L476)

**What goes wrong:** Nothing a user can see. When a connection starts, the module sets the **Connected machine: …** variables (for example `connected_machine_name` and `connected_machine_platform`) to `-` before it has told Companion those variables exist. A moment later the module defines them and sets them to `-` again, so the variable list and button text come out correct. This is a code-order issue only.

**Why it happens:** On startup, `configUpdated()` opens the connection (`initTCP()`) before it registers the variable definitions (`variables()`). This release added a call that clears the connected machine at the start of `initTCP()` (`setConnectedMachine(null)`), and clearing it writes the six connected-machine variable values. On the very first start those values are written while no variable definitions are registered yet.

**Fix:** register the definitions first. In `configUpdated()`, call `this.actions()`, `this.feedbacks()`, `this.variables()` and `this.presets()` before `this.initTCP()`. Alternatively, skip the value write in `setConnectedMachine()` until the definitions have been registered.

---

## 📝 Additional Notes

- `companion/HELP.md` now states that Companion 4.2 or later is required, which matches the base 1.14 upgrade.
