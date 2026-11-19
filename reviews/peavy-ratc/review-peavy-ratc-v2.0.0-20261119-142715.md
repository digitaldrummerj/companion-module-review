# Review: peavy-ratc v2.0.0

| Field | Value |
| --- | --- |
| **Module** | `companion-module-peavy-ratc` |
| **Version** | v2.0.0 |
| **Release** | Update — last published v1.1.4 |
| **API** | 2.2 (base 2.2.2, yarn.lock) — requires Companion 5.1+ |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Scope** | `tag` (v1.1.4..v2.0.0) |
| **Commit** | [`6c5cb91`](https://github.com/bitfocus/companion-module-peavy-ratc/tree/6c5cb9120bb46d2b96a4607405ea7b243cd55a09) |
| **Reviewed** | 2026-11-19 |

## Verdict: ✅ Approved

## ❓ Assumptions

Some findings depend on assumptions the reviewers couldn't check. They're listed in [❓ Assumptions to Confirm](#-assumptions-to-confirm) at the end of this review.

## 📋 Issues

### Non-blocking

- [ ] [L1: A line break in a String, Control Alias or Change Group value is sent to the DSP as two separate commands](#l1-a-line-break-in-a-string-control-alias-or-change-group-value-is-sent-to-the-dsp-as-two-separate-commands)
- [ ] [L2: Control values are written to variables before those variables are defined](#l2-control-values-are-written-to-variables-before-those-variables-are-defined)
- [ ] [N1: Control Get could hand its value straight to the button as an action result](#n1-control-get-could-hand-its-value-straight-to-the-button-as-an-action-result)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟢 Low

### L1: A line break in a String, Control Alias or Change Group value is sent to the DSP as two separate commands

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/protocol.ts:18-21`](https://github.com/bitfocus/companion-module-peavy-ratc/blob/6c5cb9120bb46d2b96a4607405ea7b243cd55a09/src/protocol.ts#L18-L21), [`src/protocol.ts:50-52`](https://github.com/bitfocus/companion-module-peavy-ratc/blob/6c5cb9120bb46d2b96a4607405ea7b243cd55a09/src/protocol.ts#L50-L52)
- **Assumption:** [A1](#-assumptions-to-confirm)

**What goes wrong:** A user fills the String field of a "Control Set String" action from a variable, for example `$(othermodule:title)`. If that variable holds a line break, say `Line 1` and `Line 2` on two lines, the module sends `cs "Message" "Line 1` and then `Line 2"` as two separate command lines. The control gets a cut-off string, and the DSP receives the second half as a malformed command of its own. The same happens with a custom Control Alias or a Change Group name built from a variable or expression. Values typed by hand are not affected, because they can't hold a line break.

**Why it happens:** The module ends every command with a CR/LF line break (`EOM = '\r\n'`, sent in [`src/connection.ts:130`](https://github.com/bitfocus/companion-module-peavy-ratc/blob/6c5cb9120bb46d2b96a4607405ea7b243cd55a09/src/connection.ts#L130)). The `quote()` helper refuses a value that contains `"`, but lets CR and LF through, and the option helpers `textValue()` / `aliasValue()` pass the text on unchanged. So a line break inside a value ends the command early.

**Evidence:**

```ts
// src/protocol.ts:18-21
export function quote(text: string, what = 'Alias'): string {
	if (text.includes(QUOTE)) throw new Error(`${what} must not contain ${QUOTE}: ${text}`)
	return QUOTE + text + QUOTE
}
// src/protocol.ts:50-52
export function controlSetString(version: RatcVersion, alias: string, text: string): string {
	return join(cmd[version].controlSet, quote(alias), quote(text, 'String'))
}
```

**Fix:** refuse CR and LF in `quote()` the same way it refuses a quote (or strip line breaks from String values before sending), and add a case to `protocol.spec.ts`.

```ts
export function quote(text: string, what = 'Alias'): string {
	if (/["\r\n]/.test(text)) throw new Error(`${what} must not contain " or a line break: ${text}`)
	return QUOTE + text + QUOTE
}
```

### L2: Control values are written to variables before those variables are defined

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:209-233`](https://github.com/bitfocus/companion-module-peavy-ratc/blob/6c5cb9120bb46d2b96a4607405ea7b243cd55a09/src/main.ts#L209-L233)
- **Assumption:** [A2](#-assumptions-to-confirm)

**What goes wrong:** When the connection logs in, the DSP lists its controls. The module asks for each control's value straight away, but only defines the matching variables (for example "Control Alias Value Gain 1", `controlAliasValue_Gain_1`) about 500 ms after the last control is listed. So the first replies, such as `valueIs "Gain 1" -10.0dB 0.75`, are written to variables that don't exist yet. Users see no difference today, because the module turns off Companion's variable validation and the early values are kept. If those values were ever dropped, "Control Alias Value …" and "Control Alias Position …" would stay empty after connecting until the control next changed on the DSP. v1.1.4 defined each control's variables before it asked for the value.

**Why it happens:** `#onAlias` queues a "control get" for each newly listed control as soon as it arrives, while the variable definitions are only sent in `#publishAliases`, once the settle timer fires. `#onValue` sets the variables for whatever reply arrives, and the replies arrive during that settle window. Companion expects a variable to be defined before its value is set; only `this.instanceOptions.disableVariableValidation = true` in the constructor ([`src/main.ts:61`](https://github.com/bitfocus/companion-module-peavy-ratc/blob/6c5cb9120bb46d2b96a4607405ea7b243cd55a09/src/main.ts#L61)) hides it.

**Evidence:**

```ts
// src/main.ts:209-224
#onAlias(alias: string): void {
	this.log('debug', `Control alias listed: ${alias}`)
	if (this.#listed.has(alias)) return
	this.#listed.add(alias)
	if (!isRawAlias(alias)) this.queueCommands(controlGet(this.version, alias))
	clearTimeout(this.#listTimer)
	this.#listTimer = setTimeout(() => this.#publishAliases(), this.aliasListSettle)
}

#publishAliases(): void {
	this.#listTimer = undefined
	this.#aliases = [...this.#listed]
	UpdateActions(this)
	UpdateVariableDefinitions(this)
	this.setVariableValues(aliasNameValues(this.#aliases))
}
```

**Fix:** ask for the control values only after their variables exist: collect the "control get" commands in `#onAlias` and send them at the end of `#publishAliases`, after `UpdateVariableDefinitions(this)`. Clear the pending list wherever `#listed` is cleared.

```ts
#pendingGets: string[] = []

#onAlias(alias: string): void {
	this.log('debug', `Control alias listed: ${alias}`)
	if (this.#listed.has(alias)) return
	this.#listed.add(alias)
	if (!isRawAlias(alias)) this.#pendingGets.push(controlGet(this.version, alias))
	clearTimeout(this.#listTimer)
	this.#listTimer = setTimeout(() => this.#publishAliases(), this.aliasListSettle)
}

#publishAliases(): void {
	this.#listTimer = undefined
	this.#aliases = [...this.#listed]
	UpdateActions(this)
	UpdateVariableDefinitions(this)
	this.setVariableValues(aliasNameValues(this.#aliases))
	this.queueCommands(...this.#pendingGets.splice(0))
}
```

## 💡 Nice to Have

### N1: Control Get could hand its value straight to the button as an action result

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:195-204`](https://github.com/bitfocus/companion-module-peavy-ratc/blob/6c5cb9120bb46d2b96a4607405ea7b243cd55a09/src/actions.ts#L195-L204)

**What goes wrong:** Nothing is broken. Today a button with "Control Get" (Control Alias = `Gain 1`) only sends the query; the answer turns up later in the `controlAliasValue_Gain_1` variable, so a following action on the same button can't rely on the value already being there. API 2.2, which this module targets, lets an action return a result that Companion can store in a local or custom variable, so Control Get could give the button the value directly.

**Why it happens:** Control Get has no result type and no `hasResult: true`, so its callback sends `cg "alias"` and returns nothing. The value only reaches Companion through the later `valueIs` reply handled in `#onValue` in `src/main.ts`.

**Fix:** optional. Declare a result type for Control Get in the action schema (for example `result: string`) and set `hasResult: true`. In the callback, after sending the query, wait (honouring `context.signal`) for the next `valueIs` reply for that alias and return its value. Keep setting the variables as now.

## 📝 Additional Notes

- `tsconfig.build.json` differs from the template: the `exclude` globs are widened to `"src/**/__tests__/**"` and `"src/**/__mocks__/**"` (the template has `"src/**/__tests__/*"` and `"src/**/__mocks__/*"`). Fine as long as the module builds, which it does — no change required.

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | A Companion variable or expression result can hold a line break, and Companion passes it unchanged into an action's text field or custom dropdown value | General Companion behaviour: variable values are arbitrary strings set by other modules; the host code was not checked | [L1](#l1-a-line-break-in-a-string-control-alias-or-change-group-value-is-sent-to-the-dsp-as-two-separate-commands) |
| A2 | For an API 2.2 module, Companion 5.1 honours `instanceOptions.disableVariableValidation = true`: it keeps values set for variables that aren't defined yet, and they stay once `setVariableDefinitions` defines those ids, so the early values reach users today | The option is declared in `@companion-module/base` 2.2.2 (`InstanceBaseOptions.disableVariableValidation`), but it is enforced in the Companion host, which wasn't checked. If the host dropped such values, the value variables would stay empty after connecting and the finding would rate Medium | [L2](#l2-control-values-are-written-to-variables-before-those-variables-are-defined) |
