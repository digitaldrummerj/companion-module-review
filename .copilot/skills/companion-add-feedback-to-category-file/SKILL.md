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
	CameraStatus = 'camera_status',
}

// After — add the new member
export enum FeedbackIdDeviceSettings {
	MuteStatus = 'mute_status',
	CameraStatus = 'camera_status',
	SelectedMic = 'selected_mic',  // ← new
}
```

> The string value is the feedback ID registered with Companion. It **must be globally unique** across all enums in the module. Changing an existing string value breaks saved button configs.

### Step 3 — Add the feedback definition

Add a matching entry in the `feedbacks` object inside `GetFeedbacks{Category}()`.

**Boolean feedback (simple true/false style toggle):**

```typescript
[FeedbackIdDeviceSettings.SelectedMic]: {
	type: 'boolean',
	name: 'Selected Mic',
	description: 'True when the room mic matches the given name',
	defaultStyle: { bgcolor: 0x00ff00 },
	options: [
		roomOpt,
		{ type: 'textinput', label: 'Mic name', id: 'mic_name', default: '' },
	],
	callback: (feedback) => {
		const roomId = feedback.options.roomId as string
		if (!roomId) return false
		const room = instance.state.rooms[roomId]
		if (!room) return false
		return room.selectedMic === (feedback.options.mic_name as string)
	},
},
```

**Advanced feedback (dynamic text or color based on state value):**

```typescript
[FeedbackIdDeviceSettings.MicNameDisplay]: {
	type: 'advanced',
	name: 'Mic Name Display',
	description: 'Shows the currently selected mic name on the button',
	options: [roomOpt],
	callback: (feedback) => {
		const roomId = feedback.options.roomId as string
		const mic = instance.state.rooms[roomId]?.selectedMic ?? '—'
		return {
			text: mic,
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

The `roomOpt` variable is already declared at the top of `GetFeedbacks{Category}()` via:

```typescript
const roomOpt = getRoomOption(instance)
```

Include it in your new feedback's `options` array if the feedback is room-scoped. You can also add additional option fields alongside it.

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
	const roomId = feedback.options.roomId as string

	// Guard against empty selection
	if (!roomId) return false

	// Guard against missing room
	const room = instance.state.rooms[roomId]
	if (!room) return false

	// Read cached state — never query the device synchronously
	return room.someProperty === true
}
```

---

## Common Mistakes

| Mistake | Fix |
| ------- | --- |
| Duplicate enum string value | String IDs must be unique across **all** category enums — check the others |
| `feedback.options.x` used without a cast | Cast explicitly: `as string`, `as number`, `as boolean` |
| Enum member name doesn't match the key in the `feedbacks` object | They must match: `FeedbackIdFoo.Bar` → `[FeedbackIdFoo.Bar]: { … }` |
| Forgot to guard against empty `roomId` | Always check `if (!roomId) return false` before reading state |
| Forgot to guard against missing room state | Check `if (!room) return false` before accessing room properties |
| Used `advanced` type but forgot to return an object | `advanced` callbacks must always return a `CompanionAdvancedFeedbackResult` object |

---

## References

- **`companion-feedback-file-pattern`** skill — use when creating a brand-new feedback category file (includes aggregator wiring)
- `src/feedbacks/feedback-utils.ts` — `getRoomOption()` and `roomChoices()` shared helpers
- `src/feedbacks/feedback-room-status.ts` — example of a boolean feedback category file with multiple feedbacks
