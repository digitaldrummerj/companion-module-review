---
name: companion-add-feedback-to-category-file
description: 'Add one or more feedbacks to an existing feedback category file in a Companion module. Use when you need to extend feedbacks in an existing src/feedbacks/feedback-{category}.ts file, add a feedback to a feedback category file, or grow the feedback list of an existing category file. Does NOT apply when no feedback category file exists yet — use companion-feedback-file-pattern instead.'
---

# Companion Add Feedback to Category File

Add a new feedback to an **existing** feedback category file. Three steps — nothing else changes.

## When to Use This Skill

### ✅ Use when:

- Adding 1+ feedbacks to an **existing** `src/feedbacks/feedback-{category}.ts` file
- The category file already exists and you just need to extend it

### ❌ Do NOT use when:

- No `src/feedbacks/feedback-{category}.ts` file exists yet for the category → use **`companion-feedback-file-pattern`** instead (it creates the file and wires the aggregator)
- Modifying or deleting an existing feedback definition

**The rule:** file already exists → this skill. File doesn't exist yet → `companion-feedback-file-pattern`.

---

## The Pattern

### Step 1 — Open the target file

```
src/feedbacks/feedback-{category}.ts
```

### Step 2 — Add an enum member

```typescript
// Before
export enum FeedbackIdDeviceSettings {
	MuteStatus = 'mute_status',
	PowerStatus = 'power_status',
}

// After — add the new member
export enum FeedbackIdDeviceSettings {
	MuteStatus = 'mute_status',
	PowerStatus = 'power_status',
	SelectedInput = 'selected_input',  // ← new
}
```

> The string value is the feedback ID registered with Companion. It **must be globally unique** across all enums in the module. Changing an existing string value breaks saved button configs.

### Step 3 — Add the feedback definition

Add a matching entry in the `feedbacks` object inside `GetFeedbacks{Category}()`.

**Boolean feedback (simple true/false style toggle):**

```typescript
[FeedbackIdDeviceSettings.SelectedInput]: {
	type: 'boolean',
	name: 'Selected Input',
	description: 'True when the target input matches the given name',
	defaultStyle: { bgcolor: 0x00ff00 },
	options: [
		targetOpt,
		{ type: 'textinput', label: 'Input name', id: 'input_name', default: '' },
	],
	callback: (feedback) => {
		const targetId = feedback.options.targetId as string
		if (!targetId) return false
		const target = instance.state.targets[targetId]
		if (!target) return false
		return target.selectedInput === (feedback.options.input_name as string)
	},
},
```

**Advanced feedback (dynamic text or color based on state value):**

```typescript
[FeedbackIdDeviceSettings.InputNameDisplay]: {
	type: 'advanced',
	name: 'Input Name Display',
	description: 'Shows the currently selected input name on the button',
	options: [targetOpt],
	callback: (feedback) => {
		const targetId = feedback.options.targetId as string
		const input = instance.state.targets[targetId]?.selectedInput ?? '—'
		return {
			text: input,
			size: '14',
			color: 0xffffff,
			bgcolor: 0x000000,
		}
	},
},
```

#### Feedback types

| Type       | Callback return                      | Use when                                           |
| ---------- | ------------------------------------ | -------------------------------------------------- |
| `boolean`  | `true` / `false`                     | Simple on/off styling using `defaultStyle`         |
| `advanced` | `CompanionAdvancedFeedbackResult`    | Dynamic text, colors, or images based on state     |

---

## Shared Options

The `targetOpt` variable is already declared at the top of `GetFeedbacks{Category}()` via:

```typescript
const targetOpt = getTargetOption(instance)
```

Include it in your new feedback's `options` array if the feedback is target-scoped. You can also add additional option fields alongside it.

---

## Option Types Quick Reference

| Type        | Required extra fields               | Notes                                    |
| ----------- | ----------------------------------- | ---------------------------------------- |
| `textinput` | `default: string`                   | Supports Companion variable substitution |
| `number`    | `default`, `min`, `max`             | Add `range: true` for a slider           |
| `dropdown`  | `choices: [{id, label}]`, `default` | Single selection                         |
| `checkbox`  | `default: boolean`                  | On/off toggle                            |

---

## Accessing State in Callbacks

The `instance` parameter is in scope throughout `GetFeedbacks{Category}()`. Common patterns:

```typescript
callback: (feedback) => {
	// Always cast options — typed as any
	const targetId = feedback.options.targetId as string

	// Guard against empty selection
	if (!targetId) return false

	// Guard against missing target
	const target = instance.state.targets[targetId]
	if (!target) return false

	// Read cached state — never query the device synchronously
	return target.someProperty === true
}
```

---

## Common Mistakes

| Mistake | Fix |
| ------- | --- |
| Duplicate enum string value | String IDs must be unique across **all** category enums — check the others |
| `feedback.options.x` used without a cast | Cast explicitly: `as string`, `as number`, `as boolean` |
| Enum member name doesn't match the key in the `feedbacks` object | They must match: `FeedbackIdFoo.Bar` → `[FeedbackIdFoo.Bar]: { … }` |
| Forgot to guard against empty `targetId` | Always check `if (!targetId) return false` before reading state |
| Forgot to guard against missing target state | Check `if (!target) return false` before accessing target properties |
| Used `advanced` type but forgot to return an object | `advanced` callbacks must always return a `CompanionAdvancedFeedbackResult` object |

---

## References

- **`companion-feedback-file-pattern`** skill — use when creating a brand-new feedback category file (includes aggregator wiring)
- `src/feedbacks/feedback-utils.ts` — `getTargetOption()` and `targetChoices()` shared helpers
- `src/feedbacks/feedback-target-status.ts` — example of a boolean feedback category file with multiple feedbacks
