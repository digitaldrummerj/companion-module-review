# Squad — Companion Module Review Team

## Project Context

- **Owner:** Justin James
- **Project:** companion-module-review
- **Purpose:** Review BitFocus Companion modules submitted by maintainers for release approval.
- **Stack:** TypeScript / JavaScript, Node.js, Yarn v4 (no package-lock.json), `@companion-module/base`, `@companion-module/tools`
- **Protocols reviewed:** TCP, UDP, OSC, HTTP, Bonjour/mDNS
- **Tests:** Jest or Vitest (present in some modules — absence is OK)
- **Templates:** companion-module-template-ts, companion-module-template-js
- **Build:** `yarn package` must succeed without errors to approve a module

## Members

| Name   | Role                  | Specialty                                                             | Badge        |
|--------|-----------------------|-----------------------------------------------------------------------|--------------|
| Mal    | Lead                  | Architecture review, SDK patterns, code quality gates, final sign-off | 🏗️ Lead      |
| Wash   | Protocol Specialist   | TCP/UDP/OSC/HTTP/Bonjour implementations, connection lifecycle         | 🔧 Protocol  |
| Kaylee | Module Dev Reviewer   | Template compliance, actions/feedbacks/presets/variables, yarn build  | ⚛️ Module    |
| Zoe    | QA Reviewer           | Bugs, edge cases, error handling, performance, test coverage          | 🧪 QA        |
| Simon  | Test Runner           | Jest detection & execution, test validity & missing coverage review   | 🧪 Tests     |
| Scribe | (silent)              | Memory, decisions, session logs                                       | 📋 (silent)  |
| Ralph  | Work Monitor          | Work queue, backlog, keep-alive                                       | 🔄 Monitor   |

## How the Queue Works

Modules are discovered via the **BitFocus developer portal API** and cloned into the workspace root. Once a review is complete, Justin removes the directory. The queue has two layers:

### Layer 1 — BitFocus Pending Queue (authoritative)

The BitFocus portal tracks which module releases need manual review:

```bash
TOKEN=$(gh auth token)
curl -s -H "Authorization: Bearer $TOKEN" \
  "https://developer.bitfocus.io/api/v1/modules-pending-review"
```

Returns `{versions: [{moduleName, moduleType, gitTag, createdAt}]}`. See `.squad/skills/companion-bitfocus-dashboard/SKILL.md` for full API docs, previous-tag lookup, and GitHub URL derivation.

### Layer 2 — Local Workspace Queue (cloned modules)

Modules that have been cloned but not yet reviewed appear under `companion-modules-reviewing/`
**inside this repo** (gitignored). From the repo root:

```bash
ls companion-modules-reviewing/ | grep '^companion-module-'
```

(Override the location with `$COMPANION_MODULES_DIR` if needed.)

**Template baselines** are a separate concern: `validate-template.ps1` / `module-facts.ps1` resolve
them from `companion-module-templates/` inside the repo (cloned by `setup.ps1`; override `COMPANION_TEMPLATES_DIR`)
— `companion-module-template-{js,ts}` for v2 and the `-v1` variants for v1. They are NOT under `companion-modules-reviewing/`.

---

## Review Bootstrap (run once, before spawning reviewers)

Reviews get expensive when five agents each re-read `package.json`, `manifest.json`, the file
tree, and re-derive the API version. Gather that **once** and share it.

1. **Set up the module** (if not already cloned): `pwsh scripts/bitfocus-setup-module.ps1` — it auto-skips modules already reviewed locally with feedback pending (see `companion-bitfocus-dashboard`).
2. **Generate the fact sheet:**
   ```powershell
   pwsh scripts/module-facts.ps1 -ModuleDir <module-path> -GitTag <tag> -Json > .squad/decisions/inbox/module-facts.json
   ```
   It reports language (JS/TS), API version (v1/v2), the **single** api-compliance skill that applies, `package.json` + `manifest.json` essentials, detected protocols, the source-tree list, and a template-compliance summary (it invokes `scripts/validate-template.ps1`).
3. **Hand the fact sheet to every reviewer** in their spawn prompt. Reviewers READ it instead of re-deriving the basics.

### Skill loading during review (keep context small)

- Load **only** the api-compliance skill named in the fact sheet (`apiVersion` → `companion-v1-api-compliance` **or** `companion-v2-api-compliance`) — never both.
- Kaylee loads `companion-template-compliance` (she runs `validate-template.ps1`; the skill is now a thin wrapper + judgment items).
- Do **NOT** load the authoring skills (`companion-action*`, `companion-feedback*`, `companion-preset*`, `companion-config`, `companion-variable*`, `companion-upgrades`) during a review — they teach how to *build* a module, not how to *review* one. Pull one on demand only if a reviewer is inspecting that exact area and needs the API reference.

## Review Checklist (shared context)

> Items 1–3 and 9 are produced **deterministically** by `scripts/validate-template.ps1` (run via the fact sheet, or with `-RunBuild` to execute build + lint). Reviewers confirm those findings and spend their attention on 5–8, which require judgment.

A module is **approved** when all of the following pass:

0. **`yarn install`** — always run first in the module directory before any build/test/lint commands
1. **Build** — `yarn package` runs without errors and produces a `.tgz`
2. **No package-lock.json** — only `yarn.lock` allowed
3. **Template compliance** — folder structure, file names, and scripts match the JS or TS template
4. **SDK version** — `@companion-module/base` is on a supported version (~1.x or ~2.x as appropriate)
5. **Protocol implementation** — connection lifecycle handled correctly (connect/disconnect/reconnect/error), no leaked sockets, appropriate timeouts
6. **Actions/Feedbacks/Presets** — properly typed, labelled, and structured; options have descriptions
7. **Error handling** — `try/catch` on async calls, graceful degradation, no silent failures
8. **Performance** — no busy-loops, appropriate debouncing/throttling, no memory leaks
9. **Lint** — `yarn lint` passes (or linter not present — note in review)
10. **Tests** — Jest/Vitest tests pass if present; absence is acceptable but noted

---

## Review Output Flow

**Agents write findings to the drop-box (no conflicts possible):**

Each agent writes ONLY to their own named inbox file:
- Mal → `.squad/decisions/inbox/mal-review-findings.md`
- Wash → `.squad/decisions/inbox/wash-review-findings.md`
- Kaylee → `.squad/decisions/inbox/kaylee-review-findings.md`
- Zoe → `.squad/decisions/inbox/zoe-review-findings.md`
- Simon → `.squad/decisions/inbox/simon-review-findings.md`

**Coordinator assembles the single final review:**

After all agents complete, the Coordinator combines all findings into one file written to the **centralized `reviews/` directory at the workspace root**:
```
reviews/{module-name}/review-{module-name}-{tag}-{YYYY-MM-DD-HHmmss}.md
```
Where `{module-name}` is the module name with `companion-module-` stripped from both the directory and the filename (e.g., `softouch-easyworship`). This keeps paths concise while remaining self-identifying.

Example: `reviews/softouch-easyworship/review-softouch-easyworship-v2.1.0-2026-04-02-041821.md`

The `{tag}` is the release tag being reviewed (e.g., `v2.1.0`). The Coordinator must create `reviews/{module-directory-name}/` if it doesn't exist before writing.

The final review uses severity order: 🔴 Critical → 🟠 High → 🟡 Medium → 🟢 Low → 💡 Nice to Have → 🔮 Next Release → ✅ What's Solid

**No individual agent review files.** Only the single assembled file goes in `reviews/`. Scribe cleans up the inbox findings files after the final review is written.

**Module directories are temporary.** After a review is delivered to the maintainer, Justin manually removes the module directory from the workspace root. The `reviews/` folder is permanent and provides historical records across releases.

⚠️ **External write policy: READ ONLY.** The team must NEVER write to GitHub (no PR comments, issue comments, releases) or the BitFocus API (no POST/PUT/PATCH/DELETE). The only output from any review is the local markdown file above.

⚠️ **Reviews are report-only.** The squad never modifies the module under review — no fix branches, no edits to module code, no commits or pushes to the module's repo. We review and report; the maintainer applies the fixes. (A resubmission gets a re-review that verifies their changes.) The review markdown is delivered to the maintainer and pushed only to *this* repo, by Justin.
