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

Modules that have been cloned but not yet reviewed appear as subdirectories here:

```bash
ls /Users/lynbh/Development/companion-module-review/ | grep '^companion-module-' | grep -v 'template-js$' | grep -v 'template-ts$'
```

The two **permanent** reference directories (never reviewed as modules):
- `companion-module-template-js/` — JavaScript template baseline
- `companion-module-template-ts/` — TypeScript template baseline

---

## Review Checklist (shared context)

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
reviews/{module-directory-name}/review-{module-name}-{tag}-{YYYY-MM-DD-HHmmss}.md
```
Where `{module-name}` is the module directory name with `companion-module-` stripped (e.g., `softouch-easyworship`). The module name in the filename makes the file self-identifying even if copied out of its directory.

Example: `reviews/companion-module-softouch-easyworship/review-softouch-easyworship-v2.1.0-2026-04-02-041821.md`

The `{tag}` is the release tag being reviewed (e.g., `v2.1.0`). The Coordinator must create `reviews/{module-directory-name}/` if it doesn't exist before writing.

The final review uses severity order: 🔴 Critical → 🟠 High → 🟡 Medium → 🟢 Low → 💡 Nice to Have → 🔮 Next Release → ✅ What's Solid

**No individual agent review files.** Only the single assembled file goes in `reviews/`. Scribe cleans up the inbox findings files after the final review is written.

**Module directories are temporary.** After a review is delivered to the maintainer, Justin manually removes the module directory from the workspace root. The `reviews/` folder is permanent and provides historical records across releases.

⚠️ **External write policy: READ ONLY.** The team must NEVER write to GitHub (no PR comments, issue comments, releases) or the BitFocus API (no POST/PUT/PATCH/DELETE). The only output from any review is the local markdown file above.
