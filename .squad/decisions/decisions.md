# Review Session Decisions Log

## 2025-04-05: highcriteria-lhs v1.0.0 — CHANGES REQUIRED

**Module:** companion-module-highcriteria-lhs  
**Version:** v1.0.0  
**Date:** 2025-04-05  
**Reviewed by:** Mal (Lead), Kaylee (Dev), Wash (Protocol), Zoe (QA), Simon (Tests)  
**Verdict:** ❌ CHANGES REQUIRED

### Key Findings

- **Missing `"type": "connection"` field in manifest.json** — Critical blocker for Companion 4.3+ compatibility; module will not load without this
- **3 critical template violations** — `.gitignore` has extra `*.pcap` entry, `eslint.config.mjs` has unnecessary test config, `tsconfig.build.json` uses `nodenext` instead of `Node16` (requires justification)
- **Unhandled promise rejections in action callbacks** — 6 action handlers lack try-catch blocks; errors will crash process without user feedback
- **Protocol implementation solid** — Binary TCP client well-designed with proper framing, queue management, and heartbeat; protocol analysis excellent
- **No automated test suite** — Module lacks test framework, test configuration, and test files; first release untested

### Summary

First-release module provides solid Liberty Hardware System (LHS) protocol support with excellent binary protocol implementation and proper connection lifecycle management. TypeScript structure is clean and v2.0 API compliance is generally strong. Build succeeds. However, missing critical `type: "connection"` manifest field blocks loading, action error handling poses stability risk, and three template compliance violations require fixes. Address blocking manifest issue and error handling before release.

---

## 2026-04-05: leolabs-ableset v1.8.0 — CHANGES REQUIRED

**Module:** companion-module-leolabs-ableset  
**Version:** v1.8.0  
**Date:** 2026-04-05  
**Reviewed by:** Mal (Lead), Kaylee (Dev), Wash (Protocol), Zoe (QA), Simon (Tests)  
**Verdict:** ❌ CHANGES REQUIRED

### Key Findings

- **Missing UpgradeScript for removed action** — `SetAutoLoopCurrentSection` removed without upgrade path; existing user buttons will silently break
- **Removed variable without migration** — `autoLoopCurrentSection` variable removed from API, breaking user expressions
- **Missing `.gitattributes` file** — Required template file not present; template compliance violation
- **Potential division by zero** — Progress calculations in feedback callbacks lack zero-check guards on duration calculations
- **No test suite** — Module has no automated tests; consider establishing test coverage for reliability

### Summary

Module adds valuable AbleSet 3 settings support with improved error handling and TypeScript practices. Build succeeds and most template compliance is solid. However, breaking changes to action/variable removal without proper migration paths pose risk to existing user configurations. Missing `.gitattributes` and lack of test automation should be addressed before release.

---

## 2026-04-05: generic-websocket v2.3.0 — CHANGES REQUIRED

**Module:** companion-module-generic-websocket  
**Version:** v2.3.0  
**Date:** 2026-04-05  
**Reviewed by:** Mal (Lead), Kaylee (Dev), Wash (Protocol), Zoe (QA), Simon (Tests)  
**Verdict:** ❌ CHANGES REQUIRED

### Key Findings

- **Deprecated `isVisible` function** — Three new config fields use deprecated function form; must use `isVisibleExpression` string instead (v1.12 API compliance)
- **Critical: WebSocket listener leak on reconnect** — Old event listeners not removed before reconnection, causing memory leaks and potential duplicate message processing
- **Critical template violations** — Source files at root instead of `src/`, missing `.gitattributes`, invalid `.gitignore`/`.prettierignore`, missing `engines` and `prettier` in package.json
- **Critical race condition in `send_command`** — No connection state check before sending; `send_hex` has correct pattern but `send_command` lacks it

### Summary

Module adds useful features (User-Agent support, ping/keepalive, hex sending) with generally solid architecture. However, critical WebSocket listener management flaw creates memory leak on reconnection, and the new `send_command` action lacks connection state checking that should be applied consistently. Template compliance violations (non-standard structure, missing files) must be resolved. Two deprecated API patterns require modernization.

---

## 2026-04-16T06:24:44Z: generic-websocket v2.3.1 — Follow-up release, CHANGES REQUIRED

**Module:** companion-module-generic-websocket  
**Version:** v2.3.1  
**Type:** Follow-up patch to v2.3.0  
**Reviewed by:** Mal (Lead)  
**Verdict:** ❌ CHANGES REQUIRED

**Summary:** Generic-websocket v2.3.1 fixes 8 of 10 prior findings from v2.3.0 (C1, C2, C4, C5, M3, M4, L3, L4), but 2 blocking high issues remain open: H1 (ping timer error callbacks still missing) and H2 (Origin header still hardcodes `http://` for `wss://` URLs). No new delta issues introduced.

**Review file:** `reviews/generic-websocket/review-generic-websocket-v2.3.1-20260416-062107.md`

---

## 2026-04-06: logos-proclaim v1.2.0 — CHANGES REQUIRED

**Module:** companion-module-logos-proclaim  
**Version:** v1.2.0  
**Date:** 2026-04-06  
**Reviewed by:** Mal (Lead), Kaylee (Dev), Wash (Protocol), Zoe (QA), Simon (Tests)  
**Verdict:** ⚠️ CHANGES REQUIRED

### Key Findings

- **Deprecated `isVisible` pattern** — Config field `password` uses deprecated function form instead of `isVisibleExpression` string form; violation for v1.14 API
- **Password field type** — Should use `secret-text` (available v1.13+) instead of `textinput` to prevent credential exposure in exports
- **Critical error handling** — Unhandled `error.response` access in `sendAppCommand()` causes crash on network errors; missing null checks
- **Method call error** — `this.log()` called on ProclaimAPI instance where `this.instance.log()` is required; will crash on non-success responses
- **Template compliance** — All required files present, manifest compliant, source properly organized in `src/`; builds successfully

### Summary

Module architecture is solid with good separation of concerns across 8 source files. Template compliance and build are clean. However, critical error handling vulnerabilities (pre-existing from v1.1.1) pose stability risks on network failures. Two v1.14 API compliance violations require fixes. Address deprecated `isVisible` and error handling before release.

**Review files:** 
- `reviews/logos-proclaim/review-logos-proclaim-v1.2.0-20260406-*.md`
- `.squad/decisions/inbox/mal-review-findings.md`
- `.squad/decisions/inbox/kaylee-review-findings.md`
- `.squad/decisions/inbox/wash-review-findings.md`
- `.squad/decisions/inbox/zoe-review-findings.md`
- `.squad/decisions/inbox/simon-review-findings.md`

---

## 2025-04-05: prodlink-draw-on-slides v1.0.0 — CHANGES REQUIRED

**Module:** companion-module-prodlink-draw-on-slides  
**Version:** v1.0.0  
**Date:** 2025-04-05  
**Reviewed by:** Mal (Lead), Kaylee (Dev), Wash (Protocol), Zoe (QA), Simon (Tests)  
**Verdict:** ❌ CHANGES REQUIRED

### Key Findings

- **24 critical template violations** — Missing `.gitattributes`, `.prettierignore`, `.yarnrc.yml`, `yarn.lock`; incorrect `repository.url` (should use `bitfocus` org); missing required package.json fields (`engines`, `prettier`, `packageManager`, `type`) and scripts; missing devDependencies
- **Critical fetch timeout vulnerability** — Network partition causes indefinite hangs; requests lack abort timeout, blocking polling indefinitely (5+ min default)
- **Critical polling race condition** — Unprotected immediate poll allows concurrent API calls; initial poll rejection unhandled, preventing polling start
- **Deprecated `isVisible` function** — Config fields for `host`/`port` use deprecated function pattern instead of `isVisibleExpression` string form
- **Missing automated tests** — No test framework, no test scripts, no test files; untested first release

### Summary

Architecture is sound with proper v1.x entry point, clean lifecycle methods, good API consolidation (`/api/state` endpoint), and comprehensive presets (70+ buttons). Build succeeds. Critical infrastructure gaps prevent approval: template compliance (24 violations including missing files and config), network timeout handling vulnerability, polling race condition, and complete lack of test coverage. Module needs significant infrastructure work and network robustness fixes before production use.

**Review files:**
- `.squad/decisions/inbox/mal-review-findings.md` 
- `.squad/decisions/inbox/kaylee-review-findings.md`
- `.squad/decisions/inbox/wash-review-findings.md`
- `.squad/decisions/inbox/zoe-review-findings.md`
- `.squad/decisions/inbox/simon-review-findings.md`

---

## 2026-04-16T18:58:40Z: eventsync-server v0.9.9 — Corrected Follow-up, APPROVED

**Module:** companion-module-eventsync-server  
**Version:** v0.9.9  
**Type:** Corrected follow-up review (prior mis-targeted v0.8 review replaced)  
**Reviewed by:** Mal (Lead)  
**Verdict:** ✅ APPROVED

**Summary:** Corrected follow-up review of eventsync-server v0.9.9. No blocking issues remain. Prior non-blocking reconnect advisory carried forward as guidance. No new issues introduced by corrected tag.

**Review file:** `reviews/eventsync-server/review-eventsync-server-v0.9.9-20260416-115648.md`
