# Routing — Companion Module Review Team

## How to Identify What Needs Review

### From the BitFocus API (Authoritative)

The BitFocus developer portal exposes a REST API that lists all modules currently queued for manual review. Use this as the authoritative source.

```bash
TOKEN=$(gh auth token)
curl -s -H "Authorization: Bearer $TOKEN" \
  "https://developer.bitfocus.io/api/v1/modules-pending-review"
```

Returns `{versions: [{moduleName, moduleType, gitTag, createdAt}]}`. GitHub repo URL pattern: `https://github.com/bitfocus/companion-module-{moduleName}`.

Read `.squad/skills/companion-bitfocus-dashboard/SKILL.md` for full API patterns, previous-tag lookup, and clone workflow.

### From the Workspace (Local State)

**Permanent directories (never review these as modules):**
- `companion-module-template-js/` — JS reference template
- `companion-module-template-ts/` — TS reference template

**Modules already cloned and awaiting review:**  
Any other `companion-module-*` directory present in the workspace root has been cloned and is ready to review:

```bash
ls /Users/lynbh/Development/companion-module-review/ | grep '^companion-module-' | grep -v 'template-js$' | grep -v 'template-ts$'
```

When a module is done being reviewed, Justin removes it from the directory.

---

## Routing Table

| Signal | Route To | Mode |
|--------|----------|------|
| "review `{module}`" / "review this module" / "what do you think of `{module}`" | Mal + Wash + Kaylee + Zoe (parallel fan-out) | Background |
| "what's pending" / "what needs reviewing" / "show the queue" / "check the dashboard" / "check the BitFocus portal" | Coordinator: call BitFocus API + cross-ref workspace, print table | Direct |
| "what modules are waiting?" / "what's cloned?" / "show local queue" | Coordinator scans workspace root (direct) | Direct |
| "clone `{module}`" / "set up `{module}`" / "pull down `{module}`" | Coordinator: derive GitHub URL, `git clone`, confirm cloned | Direct |
| "review all pending" / "work through the queue" / "pick the next module" | Ralph loop: fetch API → clone each → review each in order | Ralph |
| "next module" / "what should we review next" | Coordinator: call API, find oldest pending not in workspace | Direct |
| "architecture" / "SDK usage" / "structure" | Mal | Standard |
| "protocol" / "TCP" / "UDP" / "OSC" / "HTTP" / "Bonjour" | Wash | Standard |
| "build" / "package" / "yarn" / "template" / "actions" / "feedbacks" / "presets" / "variables" | Kaylee | Standard |
| "tests" / "jest" / "run tests" / "test suite" | Simon | Standard |
| "bugs" / "edge cases" / "error handling" / "performance" | Zoe | Standard |
| "full review" / "team, review" | Mal + Wash + Kaylee + Zoe (parallel fan-out) | Background |
| "Mal, ..." | Mal | Standard |
| "Wash, ..." | Wash | Standard |
| "Kaylee, ..." | Kaylee | Standard |
| "Zoe, ..." | Zoe | Standard |
| "Ralph, go" / "Ralph, status" | Ralph | Direct / Loop |
| Log / decisions / session summary | Scribe | Background |

---

## Full Review Fan-Out (Standard Pattern)

When a full review is requested for a module, spawn all four reviewers in parallel with the same module path:

- 🏗️ **Mal** — architecture, SDK compliance, `package.json`, overall structure
- 🔧 **Wash** — protocol implementation, connection lifecycle, socket cleanup
- ⚛️ **Kaylee** — template compliance, `yarn package` build, actions/feedbacks/presets
- 🧪 **Simon** — Jest detection & execution; "no tests" is not a rejection
- 🧪 **Zoe** — Bugs, edge cases, error handling, async correctness, test quality (if tests exist)

Each reviewer produces an independent verdict. Mal synthesizes into a final decision:
- **Approved** — all clear
- **Approved with Notes** — passes, but issues should be addressed before next release
- **Changes Required** — one or more blocking issues; list them explicitly

---

## Template Reference

When any reviewer needs to compare against the template:
- **TypeScript module:** `companion-module-template-ts/`
- **JavaScript module:** `companion-module-template-js/`

These are always available at the workspace root.

---

## Review Output Format

Each reviewer reports:

```
## {Reviewer Name} — {Module Name}

**Verdict:** Approved | Approved with Notes | Changes Required

### Blocking Issues
- (none) | list each one

### Notes
- (none) | list each one

### Summary
One or two sentences.
```

Mal assembles the final review verdict after all four reports are in.
