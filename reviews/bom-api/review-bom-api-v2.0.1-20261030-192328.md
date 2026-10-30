# Review: companion-module-bom-api v2.0.1 (follow-up)

| | |
| --- | --- |
| **Module** | [companion-module-bom-api](https://github.com/bitfocus/companion-module-bom-api) |
| **Scope** | `tag` (changes since v1.0.1) |
| **Version** | v2.0.1 |
| **Release** | Update — last published v1.0.1 |
| **API** | 2.2 (base 2.2.2, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Review commit** | [`23e622e`](https://github.com/bitfocus/companion-module-bom-api/tree/23e622ed2eae9f1c87e60dbf5cc6ab7bb27af3dd) |
| **Prior review** | [v2.0.0 (2026-10-30)](review-bom-api-v2.0.0-20261030-003407.md) |
| **Build** | `yarn install --immutable`, `yarn package` and `yarn lint` pass |
| **Reviewed** | 2026-10-30 |

## Verdict: ✅ Approved

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Users built buttons on the v1.0.1 Hourly Forecast variable ids, which held daily-shaped data because of the endpoint bug. How many did is unknown | the v1.0.1 code in the diff (`getForecastHourly` fetched the daily endpoint and parsed it with the daily schema); how far the old ids reach in user configs can't be checked from the code | [L1](#l1-hourly-forecast-variables-get-new-names-so-buttons-using-the-old-v101-names-go-blank) |
| A2 | In expression mode, Companion may pass a text input option to the callback as a non-string value instead of skipping the action. The base typings say invalid values cause the action to be skipped unless `allowInvalidValues` is set, so Companion may block this case before the callback runs | `@companion-module/base` 2.2.2 `input.d.ts` notes on expression mode and `allowInvalidValues`; Companion's host behaviour not checked | [N2](#n2-get-data-fails-with-an-unclear-error-if-the-geohash-option-evaluates-to-a-non-string) |

## 📋 Issues

### Non-blocking

- [ ] [L1: Hourly forecast variables get new names, so buttons using the old v1.0.1 names go blank](#l1-hourly-forecast-variables-get-new-names-so-buttons-using-the-old-v101-names-go-blank)
- [ ] [L2: Poll failures are logged as a confusing schema error instead of the BOM's explanation](#l2-poll-failures-are-logged-as-a-confusing-schema-error-instead-of-the-boms-explanation)
- [ ] [N1: Hourly forecast now creates around 1,600 variables, all redefined on every poll](#n1-hourly-forecast-now-creates-around-1600-variables-all-redefined-on-every-poll)
- [ ] [N2: Get Data fails with an unclear error if the Geohash option evaluates to a non-string](#n2-get-data-fails-with-an-unclear-error-if-the-geohash-option-evaluates-to-a-non-string)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🔁 Prior Review Follow-up

This release is a resubmission after the [v2.0.0 review](review-bom-api-v2.0.0-20261030-003407.md). Every blocking finding from that review is fixed:

| Prior finding | Status |
| --- | --- |
| C1: Required `.gitattributes` file is missing | ✅ Fixed — [`.gitattributes`](https://github.com/bitfocus/companion-module-bom-api/blob/23e622ed2eae9f1c87e60dbf5cc6ab7bb27af3dd/.gitattributes) added |
| C2: `.gitignore` is missing `/*.tgz` and `/.vscode` | ✅ Fixed — both entries added in [`.gitignore`](https://github.com/bitfocus/companion-module-bom-api/blob/23e622ed2eae9f1c87e60dbf5cc6ab7bb27af3dd/.gitignore) |
| H1: Release workflow builds its own package | ✅ Fixed — the validator no longer reports `release.yaml` |
| H2: Node CI workflow differs from the template | ✅ Fixed — the validator no longer reports `node.yaml` |
| H3: Module checks workflow drops the template-repo guard | ✅ Fixed — the `if:` guard is restored in [`.github/workflows/companion-module-checks.yaml:10`](https://github.com/bitfocus/companion-module-bom-api/blob/23e622ed2eae9f1c87e60dbf5cc6ab7bb27af3dd/.github/workflows/companion-module-checks.yaml#L10) |
| L1: Aborting Select Location logs misleading warnings | ✅ Fixed — Select Location no longer passes the abort signal to the update ([`src/actions.ts:38-46`](https://github.com/bitfocus/companion-module-bom-api/blob/23e622ed2eae9f1c87e60dbf5cc6ab7bb27af3dd/src/actions.ts#L38-L46)) |
| L2: Aborting Select Location leaves mixed-location variables | ✅ Fixed — `updateData()` takes no abort signal and always fetches everything ([`src/main.ts:180-196`](https://github.com/bitfocus/companion-module-bom-api/blob/23e622ed2eae9f1c87e60dbf5cc6ab7bb27af3dd/src/main.ts#L180-L196)) |
| N1: Get Data fails on a non-string Geohash | ⬜ Not changed — carried forward as [N2](#n2-get-data-fails-with-an-unclear-error-if-the-geohash-option-evaluates-to-a-non-string) |

The findings below are new in this review.

## 🟢 Low

### L1: Hourly forecast variables get new names, so buttons using the old v1.0.1 names go blank

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:103-112`](https://github.com/bitfocus/companion-module-bom-api/blob/23e622ed2eae9f1c87e60dbf5cc6ab7bb27af3dd/src/main.ts#L103-L112), [`src/api.ts:20`](https://github.com/bitfocus/companion-module-bom-api/blob/23e622ed2eae9f1c87e60dbf5cc6ab7bb27af3dd/src/api.ts#L20)

**What goes wrong:** In v1.0.1 the "Hourly Forecast [n]" variables actually held daily forecast data, under ids such as `$(bom-api:fc_hour_0_temp_max)`, `$(bom-api:fc_hour_0_short_text)` and `$(bom-api:fc_hour_0_astronomical_sunrise_time)`. v2.0.1 fixes this and fetches the real hourly forecast, so those ids disappear and new ones appear instead, such as `$(bom-api:fc_hour_0_temp)`, `$(bom-api:fc_hour_0_wind_speed_kilometre)` and `$(bom-api:fc_hour_0_relative_humidity)`. A user who updates and has a button showing `$(bom-api:fc_hour_0_temp_max)` now sees an empty value, and nothing tells them why. Users who never used the Hourly Forecast variables are not affected.

**Why it happens:** v1.0.1 fetched the daily endpoint for the hourly poll and parsed it with the daily schema. v2.0.1 fetches the hourly endpoint and parses it with the hourly schema. The module builds the `fc_hour_*` variable ids from the keys of the response, so the ids follow the new data. Companion upgrade scripts can't rename variables, so the only way to help these users is to tell them.

**Fix:** keep the fix, and add a note to [`companion/HELP.md`](https://github.com/bitfocus/companion-module-bom-api/blob/23e622ed2eae9f1c87e60dbf5cc6ab7bb27af3dd/companion/HELP.md) and the release notes that the Hourly Forecast variables now hold real hourly data and have new names, with a few old and new examples (e.g. `fc_hour_0_temp_max` becomes `fc_hour_0_temp`), so users know to update the buttons that use them.

### L2: Poll failures are logged as a confusing schema error instead of the BOM's explanation

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:154-156`](https://github.com/bitfocus/companion-module-bom-api/blob/23e622ed2eae9f1c87e60dbf5cc6ab7bb27af3dd/src/main.ts#L154-L156), [`src/main.ts:204-229`](https://github.com/bitfocus/companion-module-bom-api/blob/23e622ed2eae9f1c87e60dbf5cc6ab7bb27af3dd/src/main.ts#L204-L229)

**What goes wrong:** A user sets the connection to a location the BOM can't serve, or the API returns HTTP 404 or 500 during a poll. The connection log shows `undefined` as an error, then five warnings such as `Daily Forecast request failed: ✖ Invalid input: expected object, received undefined`. It never shows the BOM's own message (for example `No locations: Location cannot be found.`), even though this release added an error formatter to produce exactly that. The connection status does go to Connection Failure with a code such as `ERR_BAD_REQUEST`, so the failure is visible; the log just doesn't say why. The Get Data action is not affected: it reports the BOM's message.

**Why it happens:** The shared request helper (`queryApi`) catches the HTTP error, logs its `cause` (which is empty for an HTTP error response) and returns nothing. The polling helper (`pollQuery`) then validates that empty response against the expected schema, which fails with a schema error. So the error formatter (`describeError`) only ever sees the schema error on the polling path, never the HTTP error whose body carries the BOM's explanation.

**Fix:** log the BOM's explanation where the HTTP error is caught, or pass the original error on to the poll so the warning can show it.

```ts
.catch((error) => {
	this.log('error', describeError(error))
	this.statusManager.updateStatus(InstanceStatus.ConnectionFailure, error.code)
	...
})
```

## 💡 Nice to Have

### N1: Hourly forecast now creates around 1,600 variables, all redefined on every poll

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/variables.ts:48-68`](https://github.com/bitfocus/companion-module-bom-api/blob/23e622ed2eae9f1c87e60dbf5cc6ab7bb27af3dd/src/variables.ts#L48-L68), [`src/main.ts:190-191`](https://github.com/bitfocus/companion-module-bom-api/blob/23e622ed2eae9f1c87e60dbf5cc6ab7bb27af3dd/src/main.ts#L190-L191)

**What goes wrong:** The hourly endpoint returns about 73 hours (per the fixture comment in [`src/__tests__/fixtures.ts:149`](https://github.com/bitfocus/companion-module-bom-api/blob/23e622ed2eae9f1c87e60dbf5cc6ab7bb27af3dd/src/__tests__/fixtures.ts#L149)), each with about 22 fields (rain, precipitation, temperature, dew point, wind, humidity, UV, icon and so on). The connection's variable list therefore grows by about 1,600 `fc_hour_N_*` entries, compared with the roughly 8 days the old (wrong) endpoint produced. The module still works; the variable list just becomes very long to browse, and every poll (every 5 minutes by default) pushes all of them to Companion again.

**Why it happens:** Every field of every hourly item becomes its own variable, and the variable definitions are rebuilt and resent at the end of every update, not only when the set of ids changes.

**Fix:** consider limiting how many hours are exposed as variables (for example the next 12 or 24, or a config option), leaving the full response to the Get Data action's result, and only redefine the variables when the set of ids actually changes.

### N2: Get Data fails with an unclear error if the Geohash option evaluates to a non-string

- **Source:** 🔎 QA reviewer (carried forward from the v2.0.0 review, N1)
- **Classification:** 🆕 NEW
- **File:** [`src/api.ts:59-64`](https://github.com/bitfocus/companion-module-bom-api/blob/23e622ed2eae9f1c87e60dbf5cc6ab7bb27af3dd/src/api.ts#L59-L64), [`src/actions.ts:74`](https://github.com/bitfocus/companion-module-bom-api/blob/23e622ed2eae9f1c87e60dbf5cc6ab7bb27af3dd/src/actions.ts#L74)

**What goes wrong:** A user switches the Geohash option of Get Data to expression mode, and the expression returns a number (for example a variable holding an all-digit geohash such as `123456`). The action can then fail with `input.trim is not a function` instead of a clear validation message.

**Why it happens:** The geohash parser calls `trim()` on the value without checking its type, and an expression can produce a value that is not a string.

**Fix:** convert the value to a string before parsing it.

```ts
const geohash = parseGeohash(String(action.options.geohash ?? '')) ?? self.location.geohash
```

## 📝 Additional Notes

- `tsconfig.build.json` drops the template's `"verbatimModuleSyntax": true` from `compilerOptions`. Fine as long as the module builds; no change required.
- The API compliance check covered the v2.0 and v2.1 references only: the review skill has no v2.2 reference yet, so nothing specific to API 2.2 was checked.
