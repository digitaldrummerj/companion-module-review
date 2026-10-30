# Review: stagetimerio-api v2.7.1 (follow-up to the v2.7.0 review)

| | |
| --- | --- |
| **Module** | `companion-module-stagetimerio-api` ([repo](https://github.com/bitfocus/companion-module-stagetimerio-api)) |
| **Scope** | `tag` (`v2.6.1..v2.7.1`) |
| **Version** | v2.7.1 (`a3b44c7`, 2026-10-11) |
| **Release** | Update — last published v2.6.1 |
| **API** | 1 (base 1.14.1, yarn.lock) |
| **Template** | `companion-module-template-js-v1` @ `9e222b4` (2026-03-26, pinned) · `.yarnrc.yml` from `companion-module-template-js` @ `76d25b2` (2026-10-11) |
| **Previous tag** | v2.6.1 (`67017b7`, 2026-08-03) |
| **Prior review** | [v2.7.0 review](review-stagetimerio-api-v2.7.0-20261005-024911.md) (❌ Changes Required, C1–C12) |
| **Language** | JavaScript (ESM) |
| **Build** | `yarn install --immutable` and `yarn package` pass (`stagetimerio-api-2.7.1.tgz` produced) |
| **Review date** | 2026-10-30 |

This is a follow-up review. v2.7.1 is a fix release on top of v2.7.0: it contains no new features, only the changes asked for in the v2.7.0 review (template files, `package.json` fields and scripts, manifest keywords and version, and the API-key logging fix). All twelve findings from that review are fixed, and the fixes introduce no new issues. One template difference remains: the validator now compares `.yarnrc.yml` against the current template, and that file has an extra setting that the v2.7.0 review did not check. It does not block this release; please fix it in the next release (NR1 below).

| Prior finding | Status in v2.7.1 |
| --- | --- |
| C1: no `.gitattributes` | Fixed: [`.gitattributes`](https://github.com/bitfocus/companion-module-stagetimerio-api/blob/a3b44c79d599b225f28fba4f747deb311784d6b2/.gitattributes) added (`* text=auto eol=lf`) |
| C2: `.gitignore` differs from the template | Fixed: [`.gitignore`](https://github.com/bitfocus/companion-module-stagetimerio-api/blob/a3b44c79d599b225f28fba4f747deb311784d6b2/.gitignore) now has `/.yarn`, `/*.tgz` and `DEBUG-*` |
| C3: no `.prettierignore` | Fixed: [`.prettierignore`](https://github.com/bitfocus/companion-module-stagetimerio-api/blob/a3b44c79d599b225f28fba4f747deb311784d6b2/.prettierignore) added |
| C4: `syncVersions.js` not needed | Fixed: script and `version` script removed; manifest `version` is `0.0.0` |
| C5: no `engines` field | Fixed: `node ^22.20`, `yarn ^4` |
| C6: no `prettier` setting | Fixed |
| C7: no `format` script | Fixed |
| C8: no `package` script | Fixed |
| C9: `prettier` not a devDependency | Fixed: `prettier ^3.7.4` |
| C10: `Companion` manifest keyword | Fixed: removed |
| C11: module cannot be packaged | Fixed: `yarn package` builds the `.tgz` |
| C12: API key written to the logs | Fixed: [`src/api.js:65`](https://github.com/bitfocus/companion-module-stagetimerio-api/blob/a3b44c79d599b225f28fba4f747deb311784d6b2/src/api.js#L65) and [`src/socket.js:64`](https://github.com/bitfocus/companion-module-stagetimerio-api/blob/a3b44c79d599b225f28fba4f747deb311784d6b2/src/socket.js#L64) now log only whether a key is set; the CHANGELOG tells users to rotate a key they may have shared in older logs |

## Verdict: ✅ Approved

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | The Stagetimer HTTP API has a `jump` endpoint that accepts a signed `milliseconds` query parameter, so the **Transport: Jump playhead** action (new since v2.6.1) works against the real service | The action ID is sent unchanged as the API path by `sendActionToApi` in [`src/actions.js:628-660`](https://github.com/bitfocus/companion-module-stagetimerio-api/blob/a3b44c79d599b225f28fba4f747deb311784d6b2/src/actions.js#L628-L660), through `ApiClient.send` in [`src/api.js:51-65`](https://github.com/bitfocus/companion-module-stagetimerio-api/blob/a3b44c79d599b225f28fba4f747deb311784d6b2/src/api.js#L51-L65); the CHANGELOG describes the feature. The Stagetimer API itself was not checked; the maintainer's knowledge of their own service is trusted | No finding: this is why the new action and its two presets were not flagged |

## 📋 Issues

### Non-blocking

- [ ] [NR1: Yarn config adds an unused GitHub Packages registry for the stagetimerio scope](#nr1-yarn-config-adds-an-unused-github-packages-registry-for-the-stagetimerio-scope)

---

## 🔮 Next Release

### NR1: Yarn config adds an unused GitHub Packages registry for the stagetimerio scope

- **Source:** 🤖 validate-template (CONFIG-DIFF) · moved from Critical by the reviewer: not blocking for this release, fix it in the next one
- **Classification:** ⚠️ PRE-EXISTING (the file is unchanged since v2.6.1; the v2.7.0 review did not compare `.yarnrc.yml`, the validator now checks it against the current template)
- **File:** [`.yarnrc.yml:3-5`](https://github.com/bitfocus/companion-module-stagetimerio-api/blob/a3b44c79d599b225f28fba4f747deb311784d6b2/.yarnrc.yml#L3-L5)
- **Template:** `companion-module-template-js` main @ `76d25b2`: [`.yarnrc.yml`](https://github.com/bitfocus/companion-module-template-js/blob/76d25b2fe21b492096be05678680b71bdb7ac052/.yarnrc.yml)

**What goes wrong:** No direct user-visible effect. The module's Yarn settings tell Yarn to fetch any `@stagetimerio/*` package from GitHub's package registry instead of the public npm registry. No package in that scope is used, so the setting does nothing today, but it is a difference from the template that the next person troubleshooting an install has to work out.

**Why it happens:** `.yarnrc.yml` has an `npmScopes` block on top of the template's four settings. `package.json` declares no `@stagetimerio/*` dependency, so the block appears to be left over. All four template settings (`enableScripts`, `nodeLinker`, `npmMinimalAgeGate`, `npmPreapprovedPackages`) are present with the template's values.

**Evidence:**

```text
expected (template): enableScripts: false, nodeLinker: node-modules,
                     npmMinimalAgeGate: 3d, npmPreapprovedPackages: ["@companion-module/*"]
found (module):      the same four keys, plus an extra key: npmScopes
```

```yaml
# .yarnrc.yml:3-5
npmScopes:
  stagetimerio:
    npmRegistryServer: https://npm.pkg.github.com
```

**Confirm by:** open [`.yarnrc.yml:3-5`](https://github.com/bitfocus/companion-module-stagetimerio-api/blob/a3b44c79d599b225f28fba4f747deb311784d6b2/.yarnrc.yml#L3-L5) and check that [`package.json`](https://github.com/bitfocus/companion-module-stagetimerio-api/blob/a3b44c79d599b225f28fba4f747deb311784d6b2/package.json) lists no `@stagetimerio/*` package.

**Fix (next release):** remove the `npmScopes` block so the file has only the template's settings.

```yaml
enableScripts: false

nodeLinker: node-modules

npmMinimalAgeGate: 3d

npmPreapprovedPackages:
  - "@companion-module/*"
```
