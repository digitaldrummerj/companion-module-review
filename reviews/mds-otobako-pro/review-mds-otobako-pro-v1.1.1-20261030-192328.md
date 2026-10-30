# Review: mds-otobako-pro v1.1.1 (follow-up to the v1.1.0 review)

| | |
| --- | --- |
| **Module** | `companion-module-mds-otobako-pro` |
| **Version** | v1.1.1 |
| **Release** | New module — never published |
| **API** | 2.1 (base 2.1.3, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-js` @ `76d25b2` (2026-10-11) |
| **Scope** | `tag` (first release: no published previous tag to diff against, so the whole module was reviewed) |
| **Commit** | [`b957c23`](https://github.com/bitfocus/companion-module-mds-otobako-pro/blob/b957c237a9a8840b57e98e020b250ad7ad9dcbef) |
| **Prior review** | [v1.1.0 (2026-10-30)](review-mds-otobako-pro-v1.1.0-20261030-003407.md) — ❌ Changes Required |
| **Reviewed** | 2026-10-30 |

This is a follow-up to the v1.1.0 review. The module has never been published, so this is still its first release: there is no diff, the whole module was reviewed again, and every finding below is classified 🆕 NEW. All nine findings of the v1.1.0 review are fixed in v1.1.1 (see [📝 Additional Notes](#-additional-notes)); the findings below are new to this review.

## Verdict: ✅ Approved

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | When a user adds the connection, Companion names it after the manifest shortname with non-word characters replaced by `_`, so "otobako Pro" becomes the label `otobako_Pro` | Reviewer's recollection of how Companion builds a new connection's label; not checked in the module or `@companion-module/base` | [L2](#l2-the-variables-in-the-help-page-dont-work-with-a-new-connections-default-name) |
| A2 | When a preset is placed, Companion rewrites the hard-coded `$(otobako:…)` prefix in the preset text to the connection's real label, so the GO and Now playing presets show their variables. If Companion 5 no longer does this, those two presets would show an unresolved variable and this would become a Medium finding | Reviewer's recollection of Companion's preset handling; not visible in the `@companion-module/base` typings | No finding today: the preset text in [`src/main.js:189`](https://github.com/bitfocus/companion-module-mds-otobako-pro/blob/b957c237a9a8840b57e98e020b250ad7ad9dcbef/src/main.js#L189) and [`src/main.js:233`](https://github.com/bitfocus/companion-module-mds-otobako-pro/blob/b957c237a9a8840b57e98e020b250ad7ad9dcbef/src/main.js#L233) |

## 📋 Issues

### Non-blocking

- [ ] [L1: Playing and Fading out buttons stay lit after a token or HTTP error](#l1-playing-and-fading-out-buttons-stay-lit-after-a-token-or-http-error)
- [ ] [L2: The variables in the help page don't work with a new connection's default name](#l2-the-variables-in-the-help-page-dont-work-with-a-new-connections-default-name)
- [ ] [N1: No upgrade scripts list yet for future renames](#n1-no-upgrade-scripts-list-yet-for-future-renames)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟢 Low

### L1: Playing and Fading out buttons stay lit after a token or HTTP error

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:361-370`](https://github.com/bitfocus/companion-module-mds-otobako-pro/blob/b957c237a9a8840b57e98e020b250ad7ad9dcbef/src/main.js#L361-L370)

**What goes wrong:** An operator has the GO preset, lit green by the "Playing / 再生中" feedback, and a "Now playing" button showing `$(otobako:playing)` = "Opening BGM". Someone reissues the token in otobako Pro, or the app answers with HTTP 503. The connection turns red ("Invalid token / トークンが違います" or "HTTP 503"), but the buttons stay green and keep showing "Opening BGM" as if the cue were still playing. They only clear when the request fails outright, for example on a timeout or a refused connection.

**Why it happens:** The status poll clears the feedbacks and variables (`applyStatus(null)`) only when the request itself fails. When the app answers with 401 or another error code, the poll sets the connection status and returns, so the buttons keep the last good state while the connection says that state can no longer be read.

**Fix:** clear the playback state in the 401 and error-reply branches too, the same way the request-failure branch does.

```js
if (response.status === 401) {
	this.updateStatus(InstanceStatus.AuthenticationFailure, 'Invalid token / トークンが違います')
	this.applyStatus(null)
	return
}
if (!response.ok) {
	this.updateStatus(InstanceStatus.ConnectionFailure, `HTTP ${response.status}`)
	this.applyStatus(null)
	return
}
```

### L2: The variables in the help page don't work with a new connection's default name

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`companion/HELP.md:52`](https://github.com/bitfocus/companion-module-mds-otobako-pro/blob/b957c237a9a8840b57e98e020b250ad7ad9dcbef/companion/HELP.md#L52)

**What goes wrong:** The help page tells users to type `$(otobako:playing)`, `$(otobako:standby)` and `$(otobako:se_count)`. A newly added connection isn't called `otobako`: its default name comes from the shortname "otobako Pro" (see A1), so the working variable is `$(otobako_Pro:playing)`. A user who copies the help text onto a button sees `$NA` or nothing instead of the cue title. The presets aren't affected (see A2), and users who rename the connection to `otobako` aren't either.

**Why it happens:** The help text assumes the connection is named `otobako`, which is only true if the user renames it.

**Fix:** write the variables with a placeholder for the connection name and give the default as an example, or tell users to name the connection `otobako` if they want to copy the examples as written.

```markdown
- Variables: `$(<connection name>:playing)` (playing cue), … — e.g. `$(otobako_Pro:playing)` with the default connection name.
```

## 💡 Nice to Have

### N1: No upgrade scripts list yet for future renames

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:34`](https://github.com/bitfocus/companion-module-mds-otobako-pro/blob/b957c237a9a8840b57e98e020b250ad7ad9dcbef/src/main.js#L34)

**What goes wrong:** Nothing visible today: a first release needs no upgrade scripts. Later, if an action, option or feedback id is renamed (for example the "Play pad" option `pad` to `pad_number`), the maintainer needs an upgrade script so users' existing buttons keep working, and there is no place for it yet.

**Why it happens:** The whole module is in `src/main.js`, which exports only the instance class. The template keeps its upgrade scripts in a separate `src/upgrades.js` and hands that list to Companion from `main.js`.

**Fix:** add an empty upgrade scripts list in `src/upgrades.js` and export it from `main.js` next to the class; append future migrations there.

```js
// src/upgrades.js
export const UpgradeScripts = []

// src/main.js
import { UpgradeScripts } from './upgrades.js'
export { UpgradeScripts }
```

## 📝 Additional Notes

- Prior review C1 (Node 22 runtime) is fixed: `companion/manifest.json` declares `node26` and `package.json` `engines.node` is `^26`.
- Prior review C2 (`test.js` at the repository root) is fixed: the test moved to [`src/main.test.js`](https://github.com/bitfocus/companion-module-mds-otobako-pro/blob/b957c237a9a8840b57e98e020b250ad7ad9dcbef/src/main.test.js).
- Prior review M1 (token stored as plain config) is fixed: the "Token / トークン" field is now `secret-text` and is read from the `secrets` passed to `init()` and `configUpdated()` ([`src/main.js:96-104`](https://github.com/bitfocus/companion-module-mds-otobako-pro/blob/b957c237a9a8840b57e98e020b250ad7ad9dcbef/src/main.js#L96-L104)).
- Prior review M2 (release workflow missing) is fixed: `.github/workflows/release.yaml` is present and matches the template.
- Prior review L1 (status says only "fetch failed") is fixed: `describeError()` reports the timeout or the underlying cause ([`src/main.js:330-335`](https://github.com/bitfocus/companion-module-mds-otobako-pro/blob/b957c237a9a8840b57e98e020b250ad7ad9dcbef/src/main.js#L330-L335)).
- Prior review L2 (token with a trailing space) is fixed: the token is trimmed in [`src/main.js:281`](https://github.com/bitfocus/companion-module-mds-otobako-pro/blob/b957c237a9a8840b57e98e020b250ad7ad9dcbef/src/main.js#L281).
- Prior review L3 (cancelled actions keep waiting) is fixed: every action passes its abort signal, combined with the timeout ([`src/main.js:324-327`](https://github.com/bitfocus/companion-module-mds-otobako-pro/blob/b957c237a9a8840b57e98e020b250ad7ad9dcbef/src/main.js#L324-L327)).
- Prior review N1 (unread HTTP replies) is fixed: unused reply bodies are cancelled ([`src/main.js:300`](https://github.com/bitfocus/companion-module-mds-otobako-pro/blob/b957c237a9a8840b57e98e020b250ad7ad9dcbef/src/main.js#L300), [`src/main.js:362`](https://github.com/bitfocus/companion-module-mds-otobako-pro/blob/b957c237a9a8840b57e98e020b250ad7ad9dcbef/src/main.js#L362)).
- Prior review N2 (variables re-sent every 500 ms) is fixed: only changed variables are sent ([`src/main.js:384-394`](https://github.com/bitfocus/companion-module-mds-otobako-pro/blob/b957c237a9a8840b57e98e020b250ad7ad9dcbef/src/main.js#L384-L394)).
