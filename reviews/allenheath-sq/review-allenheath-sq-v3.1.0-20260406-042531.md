# Module Review: allenheath-sq v3.1.0

**Module:** companion-module-allenheath-sq  
**Version:** v3.1.0 (previous: v3.0.0)  
**API:** v1.x (~1.11.3)  
**Protocol:** MIDI over TCP  
**Requested by:** Justin James  
**Review Date:** 2026-04-06  
**Reviewers:** Mal (Lead), Wash (Protocol), Kaylee (Module Dev), Zoe (QA), Simon (Test Runner)

---

## Verdict

✅ **APPROVED** — no blocking issues

---

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 1 | 0 | 1 |
| 🟠 High | 0 | 0 | 0 |
| 🟡 Medium | 0 | 1 | 1 |
| 🟢 Low | 0 | 0 | 0 |
| 💡 Nice to Have | 3 | 0 | 3 |
| **Total** | **4** | **1** | **5** |

**Blocking:** 0 issues  
**Fix complexity:** Quick — all fixes are one-liners or simple additions  
**Health delta:** 4 introduced · 1 pre-existing surfaced

---

## 📋 Issues

**Non-blocking**
- [ ] [C1: Missing required file `.gitattributes`](#c1-missing-required-file-gitattributes)
- [ ] [M1: EventEmitter listener leak on reconnect (PRE-EXISTING)](#m1-eventemitter-listener-leak-on-reconnect-pre-existing)
- [ ] [N1: `.prettierignore` content differs from template](#n1-prettierignore-content-differs-from-template)
- [ ] [N2: Peer dependency version mismatches](#n2-peer-dependency-version-mismatches)
- [ ] [N3: Consider upgrading to v1.12+ API](#n3-consider-upgrading-to-v112-api)

---

## 🔴 Critical

### C1: Missing required file `.gitattributes`

| Attribute | Value |
|-----------|-------|
| **Severity** | 🔴 Critical |
| **Classification** | 🆕 NEW |
| **Blocking** | No |
| **Location** | Repository root |

**Details:**  
The `.gitattributes` file is required by the Companion module template but does not exist in this module.

```
Template expects:  .gitattributes file with content: * text=auto eol=lf
Found:             File does not exist
```

**Fix:**  
Create `.gitattributes` in repository root with a single line:
```
* text=auto eol=lf
```

---

## 🟡 Medium

### M1: EventEmitter listener leak on reconnect (PRE-EXISTING)

| Attribute | Value |
|-----------|-------|
| **Severity** | 🟡 Medium |
| **Classification** | ⚠️ PRE-EXISTING |
| **Blocking** | No |
| **Location** | `src/mixer/mixer.ts:348-427` |

**Details:**  
Each time `Mixer.start()` is called (including on config changes that require reconnect), new `ChannelParser` and `MidiTokenizer` instances are created with event listeners attached. These listeners are never explicitly removed before the old instances are discarded.

**Reconnection Flow:**
1. `configUpdated()` calls `mixer.stop()`
2. A new `Mixer` instance is created
3. `mixer.start()` calls `#processMixerReplies()` which creates new EventEmitter instances
4. Old `ChannelParser` still exists with listeners intact

**Listeners affected per reconnect:**
- `ChannelParser`: `scene`, `mute`, `fader_level`, `pan_level` (4 listeners)
- `MidiTokenizer`: `channel_message`, `system_common`, `system_realtime`, `system_exclusive` (4 listeners)

**Impact:**  
- Memory leak accumulates on each reconnect
- Long-running instances with frequent config changes or network instability will see growing memory usage
- eventemitter3 has no max listeners warning by default

**Fix:**  
Store `ChannelParser` as a class field and clean up in `#stop()`:

```typescript
// Add field:
#channelParser: ChannelParser | null = null

// In #stop():
#stop(status: InstanceStatus, reason: string): void {
    this.#instance.updateStatus(status, reason)
    
    if (this.#channelParser !== null) {
        this.#channelParser.removeAllListeners()
        this.#channelParser = null
    }
    
    const socket = this.#socket
    if (socket !== null) {
        socket.destroy()
        this.#socket = null
    }
}
```

---

## 💡 Nice to Have

### N1: `.prettierignore` content differs from template

| Attribute | Value |
|-----------|-------|
| **Severity** | 💡 Nice to Have |
| **Classification** | 🆕 NEW |
| **Blocking** | No |
| **Location** | `.prettierignore` |

**Details:**  
```
Template expects:  package.json, /LICENSE.md
Found:             package.json, pkg
```

The module has `pkg` instead of `/LICENSE.md`. Since the module uses `LICENSE` (not `LICENSE.md`) and formatting of license files is optional, this is a minor deviation.

---

### N2: Peer dependency version mismatches

| Attribute | Value |
|-----------|-------|
| **Severity** | 💡 Nice to Have |
| **Classification** | 🆕 NEW |
| **Blocking** | No |
| **Location** | `package.json` |

**Details:**  
Yarn reports peer dependency warnings during install:
- `@companion-module/base`: has 1.11.3, tools wants ^1.12.0
- `eslint`: has 10.0.3, tools wants ^9.36.0
- `prettier`: has 3.5.3, tools wants ^3.6.2

Build succeeds despite warnings. Consider aligning versions in a future update.

---

### N3: Consider upgrading to v1.12+ API

| Attribute | Value |
|-----------|-------|
| **Severity** | 💡 Nice to Have |
| **Classification** | 🆕 NEW |
| **Blocking** | No |

**Details:**  
The module uses `@companion-module/base ~1.11.3`. Consider upgrading to v1.12+ in a future release for:
- `isVisibleExpression` support for conditional config fields
- `secret-text` input type for credential fields (v1.13+)

---

## 🔮 Next Release

| Recommendation | Priority |
|----------------|----------|
| Upgrade `@companion-module/base` to ^1.12.0 | Low |
| Align eslint/prettier versions with tools peer requirements | Low |
| Add explicit EventEmitter cleanup to prevent listener leaks | Medium |
| Consider `secret-text` for credential fields (v1.13+) | Low |

---

## 🧪 Tests

### Test Results: ✅ PASS

| Metric | Value |
|--------|-------|
| **Test Files** | 30 passed (30 total) |
| **Total Tests** | 527 passed (527 total) |
| **Duration** | 660ms |
| **Framework** | Vitest v4.0.18 |
| **Pass Rate** | **100%** (527/527) |

### Test Coverage by Area
- **Actions:** 4 test files (assign, level, output, pan-balance)
- **MIDI Processing:** 13 test files (tokenization + parsing)
- **Mixer/NRPN:** 7 test files (mute, level, balance, assign, etc.)
- **Mixer Core:** 3 test files (LR, pan-balance, model)
- **Utils:** 2 test files
- **Config:** 1 test file

### Test Quality Assessment
- ⭐⭐⭐⭐⭐ **EXCELLENT**
- Comprehensive MIDI protocol testing
- Good boundary and edge case coverage
- Well-structured with clear test names
- Fast execution (1.25ms/test average)

---

## ✅ What's Solid

### v1.x API Compliance
| Check | Status |
|-------|--------|
| Entry point `runEntrypoint()` | ✅ |
| `UpgradeScripts` exported | ✅ |
| `init()` implemented | ✅ |
| `destroy()` implemented | ✅ |
| `configUpdated()` implemented | ✅ |
| `getConfigFields()` implemented | ✅ |
| No `package-lock.json` | ✅ |
| `dist/` gitignored | ✅ |

### Notable Improvements in v3.1.0
- **Runtime upgraded to Node 22** — Positive change aligned with v1.11 recommendations
- **API base updated to v1.11** — Appropriate for Node 22 support
- **MIDI channel type safety** — New `UserMidiChannel` (1-16) vs `MidiChannel` (0-15) types prevent off-by-one errors
- **Config field renames with upgrade script** — Clean implementation (`level` → `faderLaw`, `talkback` → `talkbackChannel`, etc.)
- **Tooling updates** — ESLint 10.x, TypeScript 5.9, Vitest 4.x, Yarn 4.13.0

### Code Quality
- ✅ Comprehensive 201-line HELP.md documentation
- ✅ Valid MIT license with real copyright holder (Bitfocus AS)
- ✅ Real maintainer information (Max Kiusso, Joseph Adams, Jeff Walden)
- ✅ Clean commit history with logical separation of concerns
- ✅ Proper manifest.json with $schema reference
- ✅ Husky pre-commit hook configured

### Architecture
- ✅ InstanceStatus transitions are clean and deterministic
- ✅ Socket lifecycle is deterministic (no dangling references)
- ✅ Config hot-update vs full-restart is explicit
- ✅ State isolation between mixer instances
- ✅ No race conditions in configUpdated flow

---

## Fix Summary for Maintainer

**Recommended Fixes (non-blocking):**

1. **Create `.gitattributes`** (repository root)
   ```
   * text=auto eol=lf
   ```

**Total: 0 blocking fixes required — module is approved**
