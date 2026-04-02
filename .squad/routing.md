# Routing — Companion Module Review Team

## How to Identify What Needs Review

**Permanent directories (never review these as modules):**
- `companion-module-template-js/` — JS reference template
- `companion-module-template-ts/` — TS reference template

**Modules awaiting review:**  
Any other `companion-module-*` directory present in the workspace root is a module waiting to be reviewed. To find them:

```bash
ls /Users/lynbh/Development/companion-module-review/ | grep '^companion-module-' | grep -v 'template-js$' | grep -v 'template-ts$'
```

When a module is done being reviewed, Justin removes it from the directory. New modules appear as new directories.

---

## Routing Table

| Signal | Route To | Mode |
|--------|----------|------|
| "review `{module}`" / "review this module" / "what do you think of `{module}`" | Mal + Wash + Kaylee + Zoe (parallel fan-out) | Background |
| "what modules are waiting?" / "what needs review?" / "show the queue" | Coordinator scans workspace root (direct) | Direct |
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
- **APPROVED** — all clear
- **APPROVED WITH NOTES** — passes, but issues should be addressed before next release
- **REJECTED** — one or more blocking issues; list them explicitly

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

**Verdict:** APPROVED | APPROVED WITH NOTES | REJECTED

### Blocking Issues
- (none) | list each one

### Notes
- (none) | list each one

### Summary
One or two sentences.
```

Mal assembles the final review verdict after all four reports are in.
