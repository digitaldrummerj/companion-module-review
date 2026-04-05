# Re-Review: panasonic-ak-hrp1000 @ v1.0.1

| Field | Value |
|-------|-------|
| **Module** | `companion-module-panasonic-ak-hrp1000` |
| **Tag** | `v1.0.1` |
| **Commit** | `8acb039` |
| **Previous reviewed version** | `v1.0.0` |
| **Reviewed** | 2026-04-05 |
| **Reviewers** | Mal (Lead), Wash (Protocol), Kaylee (Template/Build), Zoe (QA) |
| **API version** | v2.0 (`@companion-module/base ~2.0.3`) |
| **Module type** | TypeScript / ESM |
| **Build** | ✅ `yarn package` → `panasonic-ak-hrp1000-1.0.1.tgz` |

---

## Verdict

### ✅ APPROVED — ready for release

All blocking issues from v1.0.0 have been resolved. No new issues introduced. No regressions detected. The v1.0.1 release is a clean maintenance patch addressing the review findings from the initial submission.

---

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 0 | 0 | 0 |
| 🟠 High | 0 | 0 | 0 |
| 🟡 Medium | 0 | 0 | 0 |
| 🟢 Low | 0 | 0 | 0 |
| **Total** | **0** | **0** | **0** |

**Blocking:** 0 issues  
**Health delta:** 0 introduced · 0 pre-existing  

---

## Fix Verification (v1.0.0 → v1.0.1)

| ID | v1.0.0 Finding | Severity | Resolution |
|----|---------------|----------|------------|
| C1 | `manifest.json` missing `"type": "connection"` field | 🔴 Critical | ✅ **Fixed** — `"type": "connection"` added at line 4 |
| H1 | Action callback throws `Error` instead of `self.log('error', ...)` | 🟠 High | ✅ **Resolved** — original diagnosis was incorrect; both `throw` and `self.log('error', ...)` are valid patterns in Companion action callbacks (see companion-actions skill). No change needed. |
| L2 | Commented-out dead code in `presets.ts` | 🟢 Low | ✅ **Fixed** — commented code removed, replaced with descriptive comment |
| L3 | `tsconfig.json` extends tools config directly instead of `tsconfig.build.json` | 🟢 Low | ✅ **Fixed** — now extends `./tsconfig.build.json` per template pattern |
| N2 | HELP.md typo "recieves" | 💡 Nice to Have | ✅ **Fixed** — corrected to "receives" |

**5 of 7 findings fixed.** Remaining 2 are advisory carry-forwards (see below).

---

## ⚠️ Carried Forward (Advisory)

These non-blocking items from v1.0.0 were not addressed in v1.0.1. They remain advisory and do not block approval.

| ID | Finding | Severity | Note |
|----|---------|----------|------|
| L1 | `rp150_to_ak-hrp1000.pcap` development artifact committed to repo root | 🟢 Low | Maintainer is choosing to keep the pcap for reference. No action required. |
| N1 | No presets defined for the single action | 💡 Nice to Have | Not required. Module has one action; presets would be helpful but are optional. |

---

## ✅ What's Solid

- **Responsive maintainer.** All blocking issues resolved promptly in a clean patch release. Non-blocking fixes (L2, L3, N2) also addressed — good hygiene.

- **Clean v2.0 module structure.** Correct `export default class ModuleInstance extends InstanceBase<PanasonicTypes>`, typed `InstanceTypes`-shaped generic, proper `export { UpgradeScripts }` re-export. All v2.0 critical patterns in place.

- **Elegant HTTP queue pattern.** PQueue + AbortController combination — clear queue → abort in-flight → fresh controller → enqueue — is exactly right for "only the last command matters" semantics.

- **Build passes cleanly.** `yarn package` produces `panasonic-ak-hrp1000-1.0.1.tgz` with zero errors, zero warnings.

- **Template fully compliant.** All required files present, correct config chain (`tsconfig.json` → `tsconfig.build.json` → base tools), proper engines/packageManager fields.

- **Real HELP.md.** Includes firmware requirements, step-by-step device setup, and honest documentation of the device's unusual HTTP error behavior.

- **Input validation in action callback.** Defensive `Number.isInteger` check on top of field constraints — good practice.

---

## 🔮 Next Release (Suggestions from v1.0.0, unchanged)

1. **Add a `last_camera` variable** — expose last-selected camera as `$(panasonic-ak-hrp1000:last_camera)`
2. **Add presets** — camera 1–9 button presets for quick setup
3. **Remove unused `priority` parameter** from `httpGet` method signature
4. **Consider `secret-text` for credentials** if device adds auth in future firmware

---

*Review conducted by Mal (Lead), with input from Wash (Protocol), Kaylee (Template/Build), and Zoe (QA). All reviewers unanimous: ✅ APPROVED.*
