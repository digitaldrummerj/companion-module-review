# Review: crewlan-connect v2.0.3 (follow-up)

| | |
| --- | --- |
| **Module** | crewlan-connect |
| **Scope** | `tag` (`v1.4.3..v2.0.3`) |
| **Version** | v2.0.3 |
| **Release** | Update — last published v1.4.3 |
| **API** | 2.0 (base 2.0.4, yarn.lock) — requires Companion 4.3+ |
| **Template** | `companion-module-template-ts-v2.0.4` @ `d62230e` (2026-08-28, pinned) |
| **Review commit** | [`d63256a`](https://github.com/bitfocus/companion-module-crewlan-connect/tree/d63256a149e6450fc5f31dd8dde4dfc1551363c8) |
| **Prior review** | [v1.1.0 (2026-08-03)](review-crewlan-connect-v1.1.0-20260803-184441.md) |
| **Reviewed** | 2026-10-30 |

## Verdict: ❌ Changes Required

## 📋 Issues

### Blocking

- [ ] [H1: The CI workflow node.yaml differs from the template](#h1-the-ci-workflow-nodeyaml-differs-from-the-template)

### Non-blocking

- [ ] [L1: The Status list on hand-built indicator buttons shows your own statuses, not the ones the indicator accepts](#l1-the-status-list-on-hand-built-indicator-buttons-shows-your-own-statuses-not-the-ones-the-indicator-accepts)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟠 High

### H1: The CI workflow node.yaml differs from the template

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW (first raised in this review; `.github/workflows/node.yaml` is unchanged since v1.4.3)
- **File:** [`.github/workflows/node.yaml:24-31`](https://github.com/bitfocus/companion-module-crewlan-connect/blob/d63256a149e6450fc5f31dd8dde4dfc1551363c8/.github/workflows/node.yaml#L24-L31), [`.github/workflows/node.yaml:60-64`](https://github.com/bitfocus/companion-module-crewlan-connect/blob/d63256a149e6450fc5f31dd8dde4dfc1551363c8/.github/workflows/node.yaml#L60-L64)

**What goes wrong:** The GitHub Actions workflow that builds, lints and tests the module on every push doesn't match the one in the Companion module template. When CI behaves differently from other modules, people troubleshooting it look at the module first, when the real cause is that its workflow drifted from the template.

**Why it happens:** Two things differ. The lint job drops the template's `Prepare Environment (For template repository)` step. And the test job, which the template ships commented out (enabling it is fine), gains an extra `Check types of sources and tests` step that runs `yarn check:types` before the tests.

**Evidence:** validator message: "Differs from template (line 23: found '- name: Prepare module', template '- name: Prepare Environment (For template repository)')".

```yaml
# .github/workflows/node.yaml:60-64 (not in the template's test job)
      - name: Check types of sources and tests
        run: |
          yarn check:types
        env:
          CI: true
```

**Confirm by:** `diff companion-module-templates/companion-module-template-ts-v2.0.4/.github/workflows/node.yaml .github/workflows/node.yaml`, then compare [`.github/workflows/node.yaml:43-69`](https://github.com/bitfocus/companion-module-crewlan-connect/blob/d63256a149e6450fc5f31dd8dde4dfc1551363c8/.github/workflows/node.yaml#L43-L69) with the template's commented-out test job.

**Fix:** copy `.github/workflows/node.yaml` from the [v2.0.4 TypeScript template](https://github.com/bitfocus/companion-module-template-ts), then uncomment its test job exactly as shipped, without adding steps.

## 🟢 Low

### L1: The Status list on hand-built indicator buttons shows your own statuses, not the ones the indicator accepts

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:488-511`](https://github.com/bitfocus/companion-module-crewlan-connect/blob/d63256a149e6450fc5f31dd8dde4dfc1551363c8/src/actions.ts#L488-L511), [`src/feedbacks.ts:81-93`](https://github.com/bitfocus/companion-module-crewlan-connect/blob/d63256a149e6450fc5f31dd8dde4dfc1551363c8/src/feedbacks.ts#L81-L93)

**What goes wrong:** A user builds a button by hand (not from a preset) with the "Set Indicator Status" action, or the "Indicator Status Is" or "Indicator Ready" feedback, and picks an indicator such as "Stage Door". The Status dropdown lists the statuses the participant may set for itself ("Ready", "Attention", "Critical"…), not the statuses CrewLAN lets this connection set on that indicator. A status only the indicator accepts (say a custom "Doors Open") is missing, so the user has to type its id. A listed status the indicator doesn't accept does nothing when pressed; the only sign is a log warning ("CrewLAN does not let this connection set Stage Door to …, so nothing was sent"). On a connection that only acts for indicators, the list can even be empty. Buttons made from the indicator presets are not affected.

**Why it happens:** The Status option of the action and of both indicator feedbacks is filled from the connection's own selectable statuses. The indicator presets instead build each button from the indicator's own list of allowed statuses ([`src/presets.ts:105-131`](https://github.com/bitfocus/companion-module-crewlan-connect/blob/d63256a149e6450fc5f31dd8dde4dfc1551363c8/src/presets.ts#L105-L131)), so the module already treats them as two different lists.

**Fix:** fill the Status choices for `set_indicator_status`, `indicator_status_is` and `indicator_ready` from the statuses the indicators accept (the union of each indicator's `statusIds`, labelled from the full status catalogue, not only the selectable statuses). Keep `allowCustom: true`, and default to the first indicator's first allowed status.

## 📝 Additional Notes

- Follow-up to the [v1.1.0 review](review-crewlan-connect-v1.1.0-20260803-184441.md): its blocking items are all resolved in v2.0.3. `instance.ts` is merged into `main.ts`; `.gitattributes`, `.prettierignore`, `LICENSE`, husky/lint-staged and the template `.gitignore` entries are present; `eslint.config.mjs` uses `generateEslintConfig`; the tsconfig extends chain matches the template; `package.json` has the `prettier` field and the `format`, `build:main`, `lint:raw` scripts; `legacyIds` is empty and `stream deck` is gone from the keywords; every HTTP request has a deadline; polling re-arms with `setTimeout` instead of `setInterval`; and the talk release has its own timeout.
- `tsconfig.build.json` differs from the template: it adds `"exactOptionalPropertyTypes": true` and `"noUncheckedIndexedAccess": true` after `"verbatimModuleSyntax": true`. Fine as long as the module builds — no change required.
