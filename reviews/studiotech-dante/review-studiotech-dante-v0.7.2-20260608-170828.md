# Review — studiotech-dante v0.7.2

| | |
|---|---|
| **Module** | studiotech-dante |
| **Version** | v0.7.2 |
| **Scope** | tag (first release — no previous tag, so reviewed as a full module review) |
| **Language / API** | TypeScript / @companion-module/base v2.x (`~2.0.0`) |
| **Protocols** | UDP (Dante control / ConMon over `dgram`) |
| **Reviewed** | 2026-06-08 |
| **Previous tag** | (none — first release) |

## Verdict: ❌ Changes Required

## 📋 Issues

**Blocking**

- [ ] [C1: .gitignore missing template entry /*.tgz](#c1-gitignore-missing-template-entry-tgz)
- [ ] [C3: tsconfig.build.json extends non-ESM recommended config](#c3-tsconfigbuildjson-extends-non-esm-recommended-config)
- [ ] [C4: Packaged tarball studiotech-dante-0.7.2.tgz committed to the repo](#c4-packaged-tarball-studiotech-dante-072tgz-committed-to-the-repo)
- [ ] [C5: package.json repository.url points at the wrong repo](#c5-packagejson-repositoryurl-points-at-the-wrong-repo)
- [ ] [C6: manifest id does not match name](#c6-manifest-id-does-not-match-name)
- [ ] [C7: manifest contains banned keyword Dante](#c7-manifest-contains-banned-keyword-dante)
- [ ] [C8: Help file is not a changelog](#c8-help-file-does-not-need-changelog-in-it)
- [ ] [C9: remove the discourse link from the help file](#c9-remove-the-discourse-link-from-the-help-file)
- [ ] [C10: manifest.json bugs url must point to module repo](#c10-hemanifestjson-bugs-url-must-point-to-the-module-repo)
- [ ] [M1: No need for build-config.cjs](#m1-no-need-for-build-configcjs)
- [ ] [M2: Manifest.json shortname and description should include Dante](#m2-manufestjson-shortname-and-description-should-include-dante)

**Non-Blocking**

- [ ] [N1: manifest.json version can be made 0.0.0](#n1-manifestjson-version-can-be-made-000)
- [ ] [N2: Remove .github/.DS_Store file](#n2-remove-ds_store-from-github-folder)

---

## 🔴 Critical

### C1: .gitignore missing template entry /*.tgz

**File:** `.gitignore`

The module's `.gitignore` is missing the template entry `/*.tgz`. Without it, packaged tarballs get committed (see C4).

**Fix:** Add `/*.tgz` to `.gitignore` to match the official template.

### C3: tsconfig.build.json extends non-ESM recommended config

**File:** `tsconfig.build.json` (line 2)

Extends `@companion-module/tools/tsconfig/node22/recommended.json`, but the template (and the module's ESM `type: module` setup) expects `@companion-module/tools/tsconfig/node22/recommended-esm.json`. Building against the non-ESM base can produce a CommonJS-shaped emit that mismatches the package's ESM runtime entry.

**Fix:** Change the `extends` to `.../node22/recommended-esm.json`.

### C4: Packaged tarball studiotech-dante-0.7.2.tgz committed to the repo

**File:** `studiotech-dante-0.7.2.tgz`

A built npm pack tarball is committed to the repository; the template `.gitignore` excludes `/*.tgz`. Build artifacts must not be tracked.

**Fix:** `git rm --cached studiotech-dante-0.7.2.tgz`, delete the file, and add `/*.tgz` to `.gitignore` (C1).

### C5: package.json repository.url points at the wrong repo

**File:** `package.json`

`repository.url` is `git+https://github.com/MeestorX/companion-module-studio-tech.git` but should be `git+https://github.com/bitfocus/companion-module-studiotech-dante.git` (the Bitfocus-org repo matching the module id).

**Fix:** Update `repository.url` to the canonical Bitfocus repo URL.

### C6: manifest id does not match name

**File:** `companion/manifest.json`

`id` is `studiotech-dante` but `name` is `studio tech`. Companion expects the manifest `id` and `name` to correspond; the mismatch indicates a stale/placeholder name field. (The npm `package.json` name is also `companion-module-studio-tech`, reinforcing the inconsistency.)

**Fix:** Set the manifest `name` to match the module identity (e.g. `studiotech-dante`), and align `package.json` `name` accordingly.

### C7: manifest contains banned keyword Dante

**File:** `companion/manifest.json`

There is no value in repeating parts of the manufacturer or module name in the keywords.

**Fix:** Remove Dante and Studio Technologiesfrom the manifest `keywords` array; use specific, descriptive keywords.

### C8: help file does not need changelog in it

In the help.md file, we do not typically put a full change log into it.  The help.md file should tell them how to configure and use the module.

**Fix:** update the help.md with configuration instructions and usage instructions.  Keep the supported device list.

### C9: remove the discourse link from the help file

Bugs and Questions should go through the Github issues for the module so that everything is on the Bitfocus repository and not a server that only you have access to.

**Fix:** In the help.md remove the link to your support site.

### C10: hemanifest.json bugs url must point to the module repo

The bugs should be tracked on the module repo in Github issues.

**Fix:** update the manifest.json to point to the Bitfocus module repo url

---

## Medium

### M1: No need for build-config.cjs

There does not appear to be any need for the build-config.cjs file and I do not see it used in any of the build scripts in package.json.  I am also not seeing the extraFiles being used anywhere.

**Fix:** remove the build-config.cjs file.

### M2: manufest.json shortname and description should include Dante

The manifest.json has the shortname as ST and the description says it controls any Studio Technologies device but they make more than just Dante devices

**Fix:** update short name to "ST Dante" and description to say "....Dante Devices"

## Nice to Have

## N1: manifest.json version can be made 0.0.0

For the manifest.json, the version can be made 0.0.0 as during the publish process, Companion will auto update that value to the version number that is listed in the package.json.

This is optional so that you don't have to remember to update the manifest.json with each release.

**Fix:** update manifest.json version to 0.0.0

## N2: Remove .ds_store from .github folder

The .DS_Store is in the .gitignore list but got checked into the .github folder

**Fix:** remove the .github/.DS_Store from github.  
