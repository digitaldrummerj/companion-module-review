# Review: companion-module-renewedvision-propresenter-api v1.1.1

| | |
|---|---|
| **Module** | renewedvision-propresenter-api |
| **Review tag** | v1.1.1 |
| **Previous tag** | v1.0.5 |
| **Scope** | `tag` (v1.0.5 .. v1.1.1 diff) |
| **Language / API** | TypeScript · @companion-module/base v1.x (~1.10.0) |
| **Protocol** | HTTP + persistent status connection via `renewedvision-propresenter` library (OSC/WebSocket internal to the library) |
| **Reviewed** | 2026-06-09 |

## Verdict: ❌ Changes Required

## 📋 Issues

**Blocking**

- [ ] [C2: Module not migrated to the current Node 22 / Yarn 4 template](#c2-module-not-migrated-to-the-current-node-22--yarn-4-template)
- [ ] [C3: @companion-module/base is over 2 years old and should be updated](#c3-companion-modulebase-is-fairly-old-and-should-be-updated)
- [ ] [C4: eslint is missing and should be added](#c4-eslint-is-missing-and-should-be-added)

---

## 🔴 Critical

### C2: Module not migrated to the current Node 22 / Yarn 4 template

**File:** `package.json`, `companion/manifest.json`, `tsconfig.build.json`, `.gitignore`, `.prettierignore`, and missing toolchain files · **Classification:** 🆕 NEW (blocks this release)

The module still tracks an older template. The deterministic template comparison reports the following Critical items (carried verbatim):

| ID | File | Message |
|----|------|---------|
| FILE-MISSING | `.gitattributes` | Required file is missing |
| FILE-MISSING | `.yarnrc.yml` | Required file is missing. Will need this one you upgrade to the latest module template |
| FILE-MISSING | `eslint.config.mjs` | Required file is missing |
| FILE-MISSING | `.husky/pre-commit` | Required file is missing |
| CONFIG-DIFF | `.gitignore` | Missing template entries: `/*.tgz`, `/dist`, `DEBUG-*`, `/.yarn`, `/.vscode` |
| CONFIG-DIFF | `tsconfig.build.json` | Extends `…/node18/recommended`; template extends `…/node22/recommended` |
| PKG-FIELD | `package.json` | Missing required field `packageManager` (present in template) |
| PKG-SCRIPT | `package.json` | Missing required script `postinstall` |
| PKG-SCRIPT | `package.json` | Missing required script `package` |
| PKG-DEVDEP | `package.json` | Missing devDependency `eslint` |
| PKG-DEVDEP | `package.json` | Missing devDependency `prettier` |
| PKG-DEVDEP | `package.json` | Missing devDependency `typescript-eslint` |
| MAN-RUNTIME | `companion/manifest.json` | `runtime.type` is `node18`, should be `node22` |

A related lint failure (`LINT`, High) is downstream of this gap: `yarn lint` reports problems because the ESLint/Prettier toolchain the template installs (`eslint`, `prettier`, `typescript-eslint`, `eslint.config.mjs`) is not present. The module instead ships an ad-hoc `lint:raw`/`format` setup.

**Fix (maintainer):** re-base on the current `companion-module-template-ts` (v1): add `.gitattributes`, `.yarnrc.yml`, `eslint.config.mjs`, `.husky/pre-commit`; add the `packageManager` field and the `postinstall`/`package` scripts; add the `eslint`/`prettier`/`typescript-eslint` devDeps; switch `tsconfig.build.json` to `node22/recommended`; set `runtime.type` to `node22`; and update `.gitignore`/`.prettierignore` to match the template. Then re-run `yarn lint` clean.

### C3: @companion-module/base is fairly old and should be updated

The @companion-module/base is over 2 years old.  It should be updated to the latest v1 release along with updating node to v22.  

### C4: eslint is missing and should be added

The companion-module-template-ts has eslint included with the proper configuration.  It should be included in this module.

---

## 🔮 Next Release

These are **pre-existing** issues (present at v1.0.5, outside the v1.1.1 changed hunks) that all three reviewers surfaced. They are **not blocking** for this tag review and are **not counted** in the scorecard — captured here so they aren't lost on a future `module`/`both` pass:

- **Empty `destroy()` leaves timers and the MIDI port live** (`src/main.ts:108`). `destroy()` only logs; it never closes the MIDI port or clears the watchdog/poll `setInterval`s created on each (re)connect, so timers and listeners accumulate after the instance is deleted.
- **`transportLayerCurrent('presentation')` copy/paste** (`src/main.ts:362/376`). The announcement and audio layers both poll `'presentation'`, and all three layers assign `stageScreensResult.data` — likely a copy/paste bug producing wrong per-layer state.
