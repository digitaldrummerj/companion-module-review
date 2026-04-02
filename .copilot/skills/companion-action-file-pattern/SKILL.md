---
name: companion-action-file-pattern
description: 'Teaches the multi-file action pattern used in split-file Companion modules. Use when asked to add a new action category, create an action file, register actions in an aggregator, or extend the actions layer of a Companion module that splits actions across multiple files with a GetActions aggregator.'
---

# Companion Action File Pattern

This module splits action definitions across many files (one per category), then aggregates them in a single `actions.ts` that calls `setActionDefinitions()`. This skill documents the exact structure and wiring required to add a new action category.

## When to Use This Skill

### ✅ Use this skill when:

- You are adding a **new logical category** of actions that does not fit into any existing `src/actions/action-*.ts` file
- You need to create a brand new `src/actions/action-{category}.ts` file from scratch
- You need to wire a new file into the `actions.ts` aggregator for the first time
- The new actions are conceptually distinct from existing categories (e.g., adding breakout room actions when none exist, or adding a recording actions file)

### ❌ Do NOT use this skill when:

- You only need to **add one or more actions to an existing file** — just open the existing `src/actions/action-{category}.ts`, add the new enum member(s) and action definition(s), and you're done. No new file, no aggregator changes needed.
- You are modifying or renaming an existing action definition
- You are adding a single utility action that logically belongs to a category that already has a file

**The rule of thumb:** If a file for your category already exists → edit it directly. If no file exists for your category → use this skill to create one and wire it up.

## Pattern Overview

```
src/
  actions.ts                        ← aggregator (imports + combines all categories)
  actions/
    action-{category-a}.ts          ← one file per action category
    action-{category-b}.ts
    action-{category-c}.ts
    action-utils.ts                 ← shared helpers used by action files
```

`index.ts` calls:

```typescript
this.setActionDefinitions(GetActions(this))
```

`GetActions()` (in `actions.ts`) calls each category's `GetActions{Category}(instance)`, collects the typed objects, spreads them into one combined object, and returns it.

---

## Pattern 0 — Shared Action Helpers (`action-utils.ts`)

### When to create it

Create `src/actions/action-utils.ts` when **two or more** category files share the same helper — for example: a shared option field definition, a shared OSC path builder, or a shared validation function. Do not put these in `actions.ts` (the aggregator); put them in a separate utils file that category files can import.

### What to put in it

- **Exported constants** — shared option field arrays, e.g. `ROOM_TARGET_OPTIONS`
- **Exported helper functions** — path builders, option-value validators, factory wrappers

```typescript
// action-utils.ts

// Shared option field reused across many category files
export const ROOM_TARGET_OPTIONS: SomeCompanionActionInputField = {
    id: 'roomIndex',
    type: 'textinput',
    label: 'Room Index',
    default: '1',
}

// Shared path builder
export function buildRoomPath(roomIndex: number, command: string): string {
    return `/zoom/room/${roomIndex}/${command}`
}
```

### Instance-dependent helpers

If a helper needs `instance` (e.g. to call `instance.OSC?.sendCommand` or `instance.log`), it **must accept `instance` as an explicit parameter** — it cannot close over it, because category files receive `instance` from their factory call, not at module load time.

```typescript
// action-utils.ts
export function myCommandHelper(instance: YourInstanceType, command: string) {
    return (action: { options: Record<string, unknown> }) => {
        try {
            // ... do work using instance and action.options ...
            instance.OSC?.sendCommand(command)
        } catch (e) {
            instance.log('error', e instanceof Error ? e.message : String(e))
        }
    }
}
```

### Validation helpers

Prefer validators that **throw** on invalid input rather than silently defaulting, so the user sees a clear error in the Companion log. Pattern for numeric string fields:

```typescript
export function parseRangedInt(value: unknown, min: number, max: number, fieldName: string): number {
    const n = Math.round(Number(value))
    if (!isFinite(n) || n < min || n > max) {
        throw new Error(`Invalid ${fieldName}: "${value}". Must be a number between ${min} and ${max}.`)
    }
    return n
}
```

### Error handling

Wrap action callbacks in `try/catch` and log errors via `instance.log('error', ...)` — never let uncaught errors silently fail.

```typescript
callback: async (action): Promise<void> => {
    try {
        const index = parseRangedInt(action.options.roomIndex, 1, 999, 'roomIndex')
        instance.OSC?.sendCommand(buildRoomPath(index, 'mute'))
    } catch (e) {
        instance.log('error', e instanceof Error ? e.message : String(e))
    }
}
```

---

## Pattern 1 — The Action File Structure

### Imports

```typescript
import { CompanionActionDefinition } from '@companion-module/base'
import { YourConfig } from '../config.js'
import { InstanceBaseExt } from '../utils.js'
// Add any other helpers you need, e.g.:
// import { someHelper } from './action-utils.js'
```

> **Instance type note:** The instance type varies per module. `InstanceBaseExt<YourConfig>` above is a module-specific extension type — use whatever your module's instance type is. Common patterns:
> - `InstanceBase<YourConfig>` — the plain SDK base class (imported from `@companion-module/base`)
> - A custom class like `ZoomRoomsInstance` that extends `InstanceBase`
> - A generic extension wrapper like `InstanceBaseExt<YourConfig>` defined in `utils.ts`
>
> The key is **consistency** — use the same type your `index.ts` uses for `this`.

### Enum of Action IDs

Every action file exports an enum that names all its actions. This enum is the key type for the return object and is re-exported to the aggregator.

```typescript
export enum ActionIdMyCategory {
	doSomething = 'myDevice_doSomething',
	doSomethingElse = 'myDevice_doSomethingElse',
}
```

> Convention: enum member names are camelCase; string values are the action IDs registered with Companion (snake_case or camelCase, your choice — just be consistent).

### The Factory Function

```typescript
export function GetActionsMyCategory(instance: InstanceBaseExt<YourConfig>): {
	[id in ActionIdMyCategory]: CompanionActionDefinition | undefined
} {
	const actions: { [id in ActionIdMyCategory]: CompanionActionDefinition | undefined } = {
		[ActionIdMyCategory.doSomething]: {
			name: 'Do Something',
			options: [],
			callback: (): void => {
				// call a method on the instance to trigger device behavior
				instance.someDeviceMethod()
			},
		},

		[ActionIdMyCategory.doSomethingElse]: {
			name: 'Do Something Else',
			description: 'Optional help text shown in Companion UI',
			options: [
				{
					id: 'targetName',
					type: 'textinput',
					label: 'Target Name',
					default: '',
				},
			],
			callback: (action): void => {
				const name = action.options.targetName as string
				instance.someDeviceMethodWithArg(name)
			},
		},
	}

	return actions
}
```

### Accessing Instance State in Callbacks

The `instance` parameter is the full module instance. Common patterns:

```typescript
callback: async (action): Promise<void> => {
	// Read module state
	const currentValue = instance.someStateProperty

	// Log messages
	instance.log('info', `Doing something with ${text}`)
	instance.log('warn', 'Something unexpected')
	instance.log('error', 'Something failed')

	// Trigger feedbacks to re-evaluate
	instance.checkFeedbacks('someFeedbackId')

	// Mutate config and save
	instance.config.someFlag = true
	instance.saveConfig(instance.config)

	// Call your device integration layer
	instance.sendToDevice(text)
}
```

> Cast `action.options.*` values explicitly — TypeScript types them as `any`: `action.options.level as number`, `action.options.name as string`.

---

## Pattern 2 — The Aggregator (`actions.ts`)

`actions.ts` has three responsibilities:

1. Import every category's enum and factory function
2. Call each factory, store the typed result in a local variable
3. Build a combined object (spread all categories) and return it

### Import each file

```typescript
import { ActionIdMyCategory, GetActionsMyCategory } from './actions/action-my-category.js'
```

### Call each factory and type the local variable

```typescript
const actionsMyCategory: { [id in ActionIdMyCategory]: CompanionActionDefinition | undefined } =
	GetActionsMyCategory(instance)
```

### Extend the union type on the combined `actions` object

The `actions` const has a mapped type whose key is a union of **all** category enums:

```typescript
const actions: {
	[id in
		| ActionId // ← local enum for one-off actions defined inline
		| ActionIdMyCategory
		| ActionIdOtherCategory /* ... */]: CompanionActionDefinition | undefined
} = {
	...actionsMyCategory,
	...actionsOtherCategory,
	/* ... inline one-off actions ... */
}
```

### Return and hand off to Companion

```typescript
export function GetActions(instance: InstanceBaseExt<YourConfig>): CompanionActionDefinitions {
	// ... (all the above) ...
	return actions
}
```

`index.ts` then calls:

```typescript
this.setActionDefinitions(GetActions(this))
```

### The `ActionId` enum for inline actions

Any actions defined **directly in `actions.ts`** (not yet split into their own category files) must also be covered by an enum — `export enum ActionId` — defined in `actions.ts` itself.

- Create one enum member per inline action
- Enum string values must **exactly match** the action ID strings registered with Companion. Companion persists these IDs in saved button configs — changing a string value breaks existing user configs.
- As you split categories out, move their members from `ActionId` to the new category enum and remove them from `actions.ts`.

```typescript
// In actions.ts — covers actions not yet split into their own files
export enum ActionId {
    getDeviceStatus = 'getDeviceStatus',
    rebootDevice = 'rebootDevice',
    // ...one entry per inline action...
}
```

The combined `actions` const inside `GetActions()` includes `ActionId` in its union type:

```typescript
const actions: {
    [id in
        | ActionId               // ← inline actions in actions.ts
        | ActionIdMyCategory    // ← from action-my-category.ts
        | ActionIdOtherCategory // ← from action-other-category.ts
    ]: CompanionActionDefinition | undefined
} = {
    [ActionId.getDeviceStatus]: { /* ... */ },
    [ActionId.rebootDevice]: { /* ... */ },
    ...actionsMyCategory,
    ...actionsOtherCategory,
}
```

> When `ActionId` becomes empty (all inline actions have been split out), remove it from the union type entirely.

---

## Pattern 3 — Step-by-Step Recipe

### 1. Create the file

```
src/actions/action-{category}.ts
```

Use the template below (copy verbatim, replace all `{placeholders}`).

### 2. File template

```typescript
import { CompanionActionDefinition } from '@companion-module/base'
import { YourConfig } from '../config.js'
import { InstanceBaseExt } from '../utils.js'

export enum ActionId{Category} {
  firstAction = '{category}_firstAction',
  secondAction = '{category}_secondAction',
}

export function GetActions{Category}(instance: InstanceBaseExt<YourConfig>): {
  [id in ActionId{Category}]: CompanionActionDefinition | undefined
} {
  const actions: { [id in ActionId{Category}]: CompanionActionDefinition | undefined } = {

    [ActionId{Category}.firstAction]: {
      name: 'First Action',
      options: [],
      callback: (): void => {
        instance.log('debug', 'firstAction triggered')
        // TODO: call device integration layer
      },
    },

    [ActionId{Category}.secondAction]: {
      name: 'Second Action',
      options: [
        {
          id: 'param',
          type: 'textinput',
          label: 'Parameter',
          default: '',
        },
      ],
      callback: (action): void => {
        const param = action.options.param as string
        instance.log('debug', `secondAction triggered with param: ${param}`)
        // TODO: call device integration layer with param
      },
    },

  }

  return actions
}
```

### 3. Import in `actions.ts`

Add at the top of `actions.ts` alongside the other imports:

```typescript
import { ActionId{Category}, GetActions{Category} } from './actions/action-{category}.js'
```

### 3.5 Remove split actions from `ActionId` in `actions.ts`

When you are moving **existing inline actions** (previously defined directly in `actions.ts`) into a new category file, you must also clean up the aggregator:

- Delete their members from the `ActionId` enum in `actions.ts`
- Remove their entries from the inline `actions` object
- If `ActionId` becomes empty, remove `ActionId` from the union type entirely (and the enum declaration itself)
- TypeScript will error if you forget either direction — trust the compiler: missing enum members and stale keys both cause type errors

### 4. Call the factory in `GetActions()`

Add inside `GetActions()`, alongside the other factory calls:

```typescript
const actions{Category}: { [id in ActionId{Category}]: CompanionActionDefinition | undefined } =
  GetActions{Category}(instance)
```

### 5. Extend the union type and spread into `actions`

In the `actions` const, add `ActionId{Category}` to the union type:

```typescript
const actions: {
  [id in
    | ActionId
    | /* ... existing enums ... */
    | ActionId{Category}   // ← add here
    ]: CompanionActionDefinition | undefined
} = {
  /* ... existing spreads ... */
  ...actions{Category},   // ← add here
}
```

### 6. Build and verify

```bash
yarn build
# or: npm run build
```

Zero TypeScript errors means your new file is properly typed and wired.

---

## Common Mistakes

| Mistake                                            | Fix                                                             |
| -------------------------------------------------- | --------------------------------------------------------------- |
| Enum string value duplicates an existing action ID | Check all other enums — IDs must be globally unique             |
| Added spread but forgot to add enum to union type  | TypeScript will error — add the enum to the `[id in ...]` union |
| Forgot `.js` extension on import in `actions.ts`   | This is ESM — always use `.js` extension on relative imports    |
| `callback` not marked `async` but uses `await`     | Add `async` keyword and change return type to `Promise<void>`   |
| Used `action.options.x` without casting            | Cast: `action.options.x as string` / `as number` / `as boolean` |

## References

- `src/actions.ts` — the aggregator (authoritative example of the full pattern in your module)
- `src/actions/action-{category}.ts` — any existing category file in your module is a working example
- `src/actions/action-room-utils.ts` — example of a shared action utilities file (if present)
- `@companion-module/base` TypeScript types — `CompanionActionDefinition`, `CompanionActionDefinitions`, `SomeCompanionActionInputField`
- Companion module development docs: https://companion-module.github.io/companion-module-tools/
