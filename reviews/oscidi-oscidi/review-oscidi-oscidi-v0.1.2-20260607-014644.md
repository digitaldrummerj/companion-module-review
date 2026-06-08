# Review: oscidi-oscidi v0.1.2

| | |
|---|---|
| **Module** | oscidi-oscidi |
| **Version** | v0.1.2 |
| **Scope** | `tag` → **first release** (no `previousTag`), so this is a **full `src/` review**; every finding is 🆕 NEW |
| **Language / API** | TypeScript · `@companion-module/base` 2.0.4 (API v2) |
| **Protocols** | OSC over UDP |
| **Build / Lint** | ✅ `yarn build` (exit 0) · ✅ `yarn lint` (exit 0) |
| **Reviewed** | 2026-06-07 (UTC) |

## Verdict: Changed Reviewed

## 📋 Issues

**Blocking**

- the manifest.json name should match what is in the id value.
- for the manifest.json you can make the version 0.0.0 as it will be replaced by the version in package.json during the publish process.
- in package.json you don't need the keywords, bugs, homepage, and description sections.
- I would also suggest node-osc over osc since node-osc natively supports being in a module without you having to create the osc.d.ts file.
- before release, it would be good to add feedbacks.

**Non-blocking**

- None
