# Review — clearcom-rest v0.4.0

| | |
|---|---|
| **Module** | clearcom-rest |
| **Version** | v0.4.0 |
| **Scope** | `tag` |
| **Language** | TypeScript |
| **API** | @companion-module/base ~2.0.4 (v2) |
| **Protocols** | HTTP (REST) + socket.io-client v2 over HTTP long-polling |
| **Reviewed** | 2026-06-08 |
| **Previous tag** | (none — first release) |

## Verdict: ❌ Changes Required

## 📋 Issues

**Blocking**

- [ ] [C1: .gitattributes is missing](#c1-gitattributes-is-missing)
- [ ] [C2: .gitignore missing template entries](#c2-gitignore-missing-template-entries)
- [ ] [C3: tsconfig.json differs from template](#c3-tsconfigjson-differs-from-template)
- [ ] [C4: tsconfig.build.json uses the non-ESM tools base on an ESM package](#c4-tsconfigbuildjson-uses-the-non-esm-tools-base-on-an-esm-package)
- [ ] [C5: built tarball clearcom-rest-0.4.0.tgz is committed](#c5-built-tarball-clearcom-rest-040tgz-is-committed)
- [ ] [C6: package.json repository.url is the template placeholder](#c6-packagejson-repositoryurl-is-the-template-placeholder)
- [ ] [C7: manifest id does not match name](#c7-manifest-id-does-not-match-name)
- [ ] [H1: No socket error handler](#h1-no-socket-error-handler)
- [ ] [H4: socket.io-client pinned to EOL v2 with a hand-written type shim](#h4-socketio-client-pinned-to-eol-v2-with-a-hand-written-type-shim)
- [ ] [H5: bogus fs dependency in package.json](#h5-bogus-fs-dependency-in-packagejson)
- [ ] [H6: Write failures are swallowed and never surface to the operator](#h6-write-failures-are-swallowed-and-never-surface-to-the-operator)

**Non-blocking**

- [ ] [M9: feedback definitions are type-cast away](#m9-feedback-definitions-are-type-cast-away)
- [ ] [N1: parseKeyAssignCapabilities uses console.warn](#n1-parsekeyassigncapabilities-uses-consolewarn)

---

## 🔴 Critical

### C1: .gitattributes is missing

**Severity:** Critical · **Classification:** 🆕 NEW · **Location:** repo root (deterministic template check `FILE-MISSING`)

The required `.gitattributes` file from the official TS template is absent. Without it, line-ending normalization is not enforced and the lockfile/build artifacts can diff inconsistently across platforms.

**Fix:** copy `.gitattributes` from `companion-module-template-ts` into the repo root.

### C2: .gitignore missing template entries

**Severity:** Critical · **Classification:** 🆕 NEW · **Location:** `.gitignore` (deterministic check `CONFIG-DIFF`)

`.gitignore` is missing the template entries `/*.tgz` and `/.vscode`. The current file ignores `/pkg.tgz` and `.vscode` but not the `/*.tgz` glob — which is exactly why the packed tarball (C5) ended up committed.

**Fix:** add `/*.tgz` and `/.vscode` to `.gitignore` to match the template.

### C3: tsconfig.json differs from template

**Severity:** Critical · **Classification:** 🆕 NEW · **Location:** `tsconfig.json:6` (deterministic check `CONFIG-DIFF`)

Line 6 reads `"types": ["node"]` where the template ships `"types": ["node" /* , "jest" ] // uncomment this if using jest */]`. Template parity is required.

**Fix:** restore the template's `tsconfig.json` `types` line verbatim (the commented jest hint is intentional).

### C4: tsconfig.build.json uses the non-ESM tools base on an ESM package

**Severity:** Critical · **Classification:** 🆕 NEW · **Location:** `tsconfig.build.json:2` (deterministic check `CONFIG-DIFF`)

`extends` points at `@companion-module/tools/tsconfig/node22/recommended.json`, but the template (and this package, which is `"type": "module"` in `package.json`) requires the ESM base `recommended-esm.json`. The build currently succeeds only because the file locally overrides `module`/`moduleResolution` to `nodenext`; it should inherit the correct ESM base instead of diverging from the template.

**Fix:** change `extends` to `@companion-module/tools/tsconfig/node22/recommended-esm.json` and drop redundant local overrides that the ESM base already provides.

### C5: built tarball clearcom-rest-0.4.0.tgz is committed

**Severity:** Critical · **Classification:** 🆕 NEW · **Location:** `clearcom-rest-0.4.0.tgz` (deterministic check `GITIGNORED-COMMITTED`)

The packed release tarball is committed to the repo. The template `.gitignore` excludes `/*.tgz`; a build artifact must not be tracked in source control.

**Fix:** `git rm --cached clearcom-rest-0.4.0.tgz`, delete it from the repo, and add the `/*.tgz` ignore (C2).

### C6: package.json repository.url is the template placeholder

**Severity:** Critical · **Classification:** 🆕 NEW · **Location:** `package.json:20` (deterministic check `PKG-REPO`; also raised by compliance review)

`repository.url` is still `git+https://github.com/bitfocus/companion-module-your-module-name.git`. The real repo is `companion-module-clearcom-rest` (correct in `manifest.json`). Bitfocus packaging/CI keys off this field.

**Fix:** set `repository.url` (and the `bugs` URL) to the actual GitHub repository.

### C7: manifest id does not match name

**Severity:** Critical · **Classification:** 🆕 NEW · **Location:** `companion/manifest.json:3-4` (deterministic check `MAN-IDNAME`)

`id` is `"clearcom-rest"` but `name` is `"clearcom rest"` (a space instead of a hyphen). The manifest `name` is expected to match the `id` slug (lowercase, hyphenated); the human-facing label is carried by `shortname`/products.

**Fix:** set `manifest.name` to `"clearcom-rest"` to match `id`.

---

## 🟠 High

### H1: No socket error handler

**Severity:** High · **Classification:** 🆕 NEW · **Location:** `src/network.ts:510-609`

The socket.io client registers `connect`, `disconnect`, and `connect_error`, but no `'error'` handler. A mid-session transport/parse `'error'` in socket.io-client can surface as an unhandled exception and is never reflected in `InstanceStatus`.

**Fix:** add `socket.on('error', (err) => { log.error(...); instance.updateStatus(InstanceStatus.ConnectionFailure, String(err)) })`.

### H4: socket.io-client pinned to EOL v2 with a hand-written type shim

**Severity:** High · **Classification:** 🆕 NEW · **Location:** `package.json:29`, `src/socket-io-client.d.ts`

`"socket.io-client": "2"` pins an EOL major version, forced via a hand-written `socket-io-client.d.ts` shim because the real types are incompatible. This is a maintenance/security liability for a release.

**Fix:** confirm the Arcadia genuinely requires the EIO/socket.io v2 protocol; if it does, document why and pin a specific patched version. Otherwise upgrade to socket.io-client v4 and drop the custom shim.

### H5: bogus fs dependency in package.json

**Severity:** High · **Classification:** 🆕 NEW · **Location:** `package.json:27`

`"fs": "^0.0.1-security"` is the npm placeholder/security-hold squat package, not Node's built-in `fs`. The code correctly imports the real built-in (`fs/promises` in `src/loadSchemas.ts:6`), so this dependency is unused and should not be installed.

**Fix:** delete the `fs` entry from `dependencies`.

### H6: Write failures are swallowed and never surface to the operator

**Severity:** High · **Classification:** 🆕 NEW · **Location:** `src/arcadia.ts:160-162` (same pattern in `setKeyset`/`putKeysets` 219-221, `sendCall` 365-367, `remoteMicKill` 336-338, `startNulling` 383-385)

`executeWrite` catches the `putRequest` error, logs it, and returns silently. When an operator presses a button to change gain/label/role and the device rejects it (or is unreachable), the action appears to succeed — no operator-visible signal and no `InstanceStatus` change. Combined with `withTimeout` suppressing `DeviceRequestError` (actions.ts:143), a rejected write is effectively invisible, and a transport error mid-action is silent too.

**Fix:** let transport errors propagate to surface a connection-level failure via `instance.updateStatus(InstanceStatus.ConnectionFailure, …)`; reserve silent handling for genuine device-level rejections only, and consider a visible log on rejection.

---

## 🟡 Medium

### M9: feedback definitions are type-cast away

**Severity:** Medium · **Classification:** 🆕 NEW · **Location:** `src/feedbacks.ts:531-536` (also `feedbacks.ts:55`, `actions.ts:191`)

`UpdateFeedbacks` builds feedbacks as `Record<string, FeedbackDef>` where `FeedbackDef = Record<string, unknown>` (line 42), then forces them through `setFeedbackDefinitions(... as unknown as Parameters<...>[0])`. This bypasses all v2 feedback-shape type-checking (option field types, `defaultStyle`, callback return typing), so structural mistakes are not caught at compile time. The `as string` casts similarly suppress the typed store comparisons.

**Fix:** type the builders against `CompanionFeedbackDefinitions` (and the per-type definition interfaces already imported) and drop the `as unknown as` cast so the compiler validates the definitions.

---

## 💡 Nice to Have

### N1: parseKeyAssignCapabilities uses console.warn

**Severity:** Nice to Have · **Classification:** 🆕 NEW · **Location:** `src/parseSchemas.ts:465`

Uses raw `console.warn` instead of the module logger, bypassing the configurable log-level filtering used everywhere else.

**Fix:** route through the module logger.
