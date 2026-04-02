---
name: companion-feedback-file-pattern
description: 'Creates a new feedback category file in a Companion module and wires it into the aggregator. Use when no src/feedbacks/feedback-{category}.ts exists yet for the category. Does NOT apply when the category file already exists — use companion-add-feedback-to-category-file instead to add feedbacks to an existing file.'
---

# Companion Feedback File Pattern

This module splits feedback definitions across many files (one per category), then aggregates them in a single `feedback.ts` that calls `setFeedbackDefinitions()`. This skill documents the exact structure and wiring required to add a new feedback category.

## When to Use This Skill

### ✅ Use this skill when:

- You are adding a **new logical category** of feedbacks that does not fit into any existing `src/feedbacks/feedback-*.ts` file
- You need to create a brand new `src/feedbacks/feedback-{category}.ts` file from scratch
- You need to wire a new file into the `feedback.ts` aggregator for the first time
- The new feedbacks are conceptually distinct from existing categories (e.g., adding NDI feedbacks when none exist)

### ❌ Do NOT use this skill when:

- You only need to **add one or more feedbacks to an existing file** — just open the existing `src/feedbacks/feedback-{category}.ts`, add the new enum member(s) and feedback definition(s), and you're done. No new file, no aggregator changes needed.
- You are modifying or renaming an existing feedback definition
- You are adding a single feedback that logically belongs to a category that already has a file

**The rule of thumb:** If a file for your category already exists → edit it directly. If no file exists for your category → use this skill to create one and wire it up.

## Pattern Overview

```
src/
  feedback.ts                          ← aggregator (imports + combines all categories)
  feedbacks/
    feedback-{category-a}.ts           ← one file per feedback category
    feedback-{category-b}.ts
    feedback-{category-c}.ts
    feedback-utils.ts                  ← shared helpers used by feedback files
```

`index.ts` calls:

```typescript
this.setFeedbackDefinitions(GetFeedbacks(this))
```

`GetFeedbacks()` (in `feedback.ts`) calls each category's `GetFeedbacks{Category}(instance)`, collects the typed objects, spreads them into one combined object, and returns it.

---

## Pattern 0 — Shared Feedback Helpers (`feedback-utils.ts`)

### When to create / update it

`src/feedbacks/feedback-utils.ts` holds helpers shared by **two or more** category files — for example: a shared room picker dropdown, a shared state accessor, or a shared option field factory. Do not put these in `feedback.ts` (the aggregator); put them in the utils file.

### What to put in it

- **Exported helper functions** — option field factories, state accessors, shared validators

```typescript
// feedback-utils.ts

import type { SomeCompanionFeedbackInputField } from '@companion-module/base'
import type { ZoomRoomsInstance } from '../types.js'

// Returns the list of rooms for dropdown choices, preferring paired rooms
export function roomChoices(instance: ZoomRoomsInstance): { id: string; label: string }[] {
	const choices = [{ id: '', label: '(Select room)' }]
	const rooms = instance.state.pairedRooms.length ? instance.state.pairedRooms : instance.state.addedRooms
	for (const r of rooms) {
		if (r.roomID) choices.push({ id: r.roomID, label: r.roomName || r.roomID })
	}
	return choices
}

// Factory for the standard room picker option field — call inside each GetFeedbacks{Category}
export function getRoomOption(instance: ZoomRoomsInstance): SomeCompanionFeedbackInputField {
	return {
		type: 'dropdown',
		label: 'Room',
		id: 'roomId',
		default: '',
		choices: roomChoices(instance),
	}
}
```

### Why getRoomOption is a factory function

`roomChoices` reads live instance state at the time `GetFeedbacks` is called, so the dropdown is populated with the current room list. If it were a module-level constant, it would always be empty. Always call `getRoomOption(instance)` inside the `GetFeedbacks{Category}` factory, not at module load time.

---

## Pattern 1 — The Feedback File Structure

### Imports

```typescript
import type { CompanionFeedbackDefinition } from '@companion-module/base'
import type { ZoomRoomsInstance } from '../types.js'
import { getRoomOption } from './feedback-utils.js'
```

### Enum of Feedback IDs

Every feedback file exports an enum that names all its feedbacks. Enum string values must **exactly match** the feedback IDs registered with Companion — changing them breaks existing user configs.

```typescript
export enum FeedbackIdMyCategory {
	someFeedback = 'some_feedback',
	anotherFeedback = 'another_feedback',
}
```

> Convention: enum member names are PascalCase; string values are the feedback IDs (snake_case to match existing module convention).

### The Factory Function

```typescript
export function GetFeedbacksMyCategory(instance: ZoomRoomsInstance): {
	[id in FeedbackIdMyCategory]: CompanionFeedbackDefinition | undefined
} {
	const roomOpt = getRoomOption(instance)

	const feedbacks: { [id in FeedbackIdMyCategory]: CompanionFeedbackDefinition | undefined } = {
		[FeedbackIdMyCategory.someFeedback]: {
			type: 'boolean',
			name: 'Some Feedback',
			description: 'True when the condition is met',
			defaultStyle: { bgcolor: 0x00ff00 },
			options: [roomOpt],
			callback: (feedback) => {
				const roomId = feedback.options.roomId as string
				if (!roomId) return false
				return instance.state.rooms[roomId]?.someProperty === true
			},
		},

		[FeedbackIdMyCategory.anotherFeedback]: {
			type: 'boolean',
			name: 'Another Feedback',
			description: 'True when another condition is met',
			defaultStyle: { bgcolor: 0xff0000 },
			options: [roomOpt],
			callback: (feedback) => {
				const roomId = feedback.options.roomId as string
				if (!roomId) return false
				return instance.state.rooms[roomId]?.otherProperty === true
			},
		},
	}

	return feedbacks
}
```

### Accessing Instance State in Callbacks

```typescript
callback: (feedback) => {
	// Cast options — TypeScript types them as any
	const roomId = feedback.options.roomId as string

	// Guard against empty selection or missing state
	if (!roomId) return false
	const room = instance.state.rooms[roomId]
	if (!room) return false

	// Read from state — never query the device synchronously
	return room.someProperty === true
}
```

### Boolean vs. Advanced Feedbacks

- **Boolean** (`type: 'boolean'`) — Returns `true`/`false`. Companion applies `defaultStyle` when `true`. Use for simple on/off styling.
- **Advanced** (`type: 'advanced'`) — Returns a full `CompanionAdvancedFeedbackResult` object. Use when you need custom text, colors, or images that vary by state value.

```typescript
// Advanced feedback example
[FeedbackIdMyCategory.levelDisplay]: {
	type: 'advanced',
	name: 'Level Display',
	options: [roomOpt],
	callback: (feedback) => {
		const roomId = feedback.options.roomId as string
		const level = instance.state.rooms[roomId]?.level ?? 0
		return {
			text: `${level}%`,
			bgcolor: level > 75 ? 0xff0000 : 0x00ff00,
		}
	},
},
```

---

## Pattern 2 — The Aggregator (`feedback.ts`)

`feedback.ts` has three responsibilities:

1. Import every category's enum and factory function
2. Call each factory, store the typed result in a local variable
3. Build a combined object (spread all categories) and return it

### Import each file

```typescript
import { FeedbackIdMyCategory, GetFeedbacksMyCategory } from './feedbacks/feedback-my-category.js'
```

### Call each factory and type the local variable

```typescript
const feedbacksMyCategory: { [id in FeedbackIdMyCategory]: CompanionFeedbackDefinition | undefined } =
	GetFeedbacksMyCategory(instance)
```

### Build the combined object

```typescript
export function GetFeedbacks(instance: ZoomRoomsInstance): CompanionFeedbackDefinitions {
	const feedbacksMyCategory: { [id in FeedbackIdMyCategory]: CompanionFeedbackDefinition | undefined } =
		GetFeedbacksMyCategory(instance)
	const feedbacksOtherCategory: { [id in FeedbackIdOtherCategory]: CompanionFeedbackDefinition | undefined } =
		GetFeedbacksOtherCategory(instance)

	const feedbacks: {
		[id in
			| FeedbackIdMyCategory
			| FeedbackIdOtherCategory]: CompanionFeedbackDefinition | undefined
	} = {
		...feedbacksMyCategory,
		...feedbacksOtherCategory,
	}

	return feedbacks
}
```

`index.ts` then calls:

```typescript
this.setFeedbackDefinitions(GetFeedbacks(this))
```

---

## Pattern 3 — Step-by-Step Recipe

### 1. Create the file

```
src/feedbacks/feedback-{category}.ts
```

### 2. File template

```typescript
import type { CompanionFeedbackDefinition } from '@companion-module/base'
import type { ZoomRoomsInstance } from '../types.js'
import { getRoomOption } from './feedback-utils.js'

export enum FeedbackId{Category} {
	firstFeedback = '{category}_first_feedback',
	secondFeedback = '{category}_second_feedback',
}

export function GetFeedbacks{Category}(instance: ZoomRoomsInstance): {
	[id in FeedbackId{Category}]: CompanionFeedbackDefinition | undefined
} {
	const roomOpt = getRoomOption(instance)

	const feedbacks: { [id in FeedbackId{Category}]: CompanionFeedbackDefinition | undefined } = {

		[FeedbackId{Category}.firstFeedback]: {
			type: 'boolean',
			name: 'First Feedback',
			description: 'True when the first condition is met',
			defaultStyle: { bgcolor: 0x00ff00 },
			options: [roomOpt],
			callback: (feedback) => {
				const roomId = feedback.options.roomId as string
				if (!roomId) return false
				// TODO: check instance.state for the relevant condition
				return false
			},
		},

		[FeedbackId{Category}.secondFeedback]: {
			type: 'boolean',
			name: 'Second Feedback',
			description: 'True when the second condition is met',
			defaultStyle: { bgcolor: 0x00ff00 },
			options: [roomOpt],
			callback: (feedback) => {
				const roomId = feedback.options.roomId as string
				if (!roomId) return false
				// TODO: check instance.state for the relevant condition
				return false
			},
		},

	}

	return feedbacks
}
```

### 3. Import in `feedback.ts`

```typescript
import { FeedbackId{Category}, GetFeedbacks{Category} } from './feedbacks/feedback-{category}.js'
```

### 3.5 Remove split feedbacks from `FeedbackId` in `feedback.ts`

When moving **existing inline feedbacks** into a new category file, clean up the aggregator:

- Delete their members from the `FeedbackId` enum in `feedback.ts`
- Remove their entries from the inline `feedbacks` object
- If `FeedbackId` becomes empty, remove it from the union type and delete the enum declaration
- TypeScript will error if you forget either direction — trust the compiler

### 4. Call the factory in `GetFeedbacks()`

```typescript
const feedbacks{Category}: { [id in FeedbackId{Category}]: CompanionFeedbackDefinition | undefined } =
	GetFeedbacks{Category}(instance)
```

### 5. Extend the union type and spread into `feedbacks`

```typescript
const feedbacks: {
	[id in
		| /* ... existing enums ... */
		| FeedbackId{Category}   // ← add here
	]: CompanionFeedbackDefinition | undefined
} = {
	/* ... existing spreads ... */
	...feedbacks{Category},   // ← add here
}
```

### 6. Build and verify

```bash
yarn build
```

Zero TypeScript errors means the new file is properly typed and wired.

---

## Common Mistakes

| Mistake | Fix |
| ------- | --- |
| Enum string value duplicates an existing feedback ID | Check all other enums — IDs must be globally unique |
| Added spread but forgot to add enum to union type | TypeScript will error — add the enum to the `[id in ...]` union |
| Forgot `.js` extension on import in `feedback.ts` | This is ESM — always use `.js` extension on relative imports |
| Called `roomChoices()` at module level instead of inside factory | Always call `getRoomOption(instance)` inside `GetFeedbacks{Category}()` |
| `callback` accesses `feedback.options.x` without casting | Cast: `feedback.options.x as string` / `as number` / `as boolean` |
| Forgot to guard against empty `roomId` | Always check `if (!roomId) return false` before reading state |
| Forgot to guard against missing room state | Always check `if (!room) return false` before accessing room properties |

## References

- `src/feedback.ts` — the aggregator (authoritative example of the full pattern in your module)
- `src/feedbacks/feedback-utils.ts` — shared helpers (`roomChoices`, `getRoomOption`)
- `src/feedbacks/feedback-{category}.ts` — any existing category file is a working example
- `@companion-module/base` TypeScript types — `CompanionFeedbackDefinition`, `CompanionFeedbackDefinitions`, `SomeCompanionFeedbackInputField`
- **companion-feedbacks** skill — reference for `CompanionFeedbackDefinition` API details, boolean vs advanced, subscribe/unsubscribe
- Companion module development docs: https://companion-module.github.io/companion-module-tools/
