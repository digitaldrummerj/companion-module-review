# Skill: JavaScript Template Literals Over String Concatenation

**Confidence:** low
**Blocking:** no
**Applies to:** JavaScript modules (all API versions)

## Pattern

Prefer ES6 template literals over `+` string concatenation for any string that embeds a variable or expression.

**Avoid:**
```js
this.log('info', 'Connected to ' + this.config.host)
this.setVariableValues({ ['GSname' + i]: 'Snap ' + i })
let name = args[0].value + 'Name'
```

**Prefer:**
```js
this.log('info', `Connected to ${this.config.host}`)
this.setVariableValues({ [`GSname${i}`]: `Snap ${i}` })
let name = `${args[0].value}Name`
```

## Why

- Improves readability — structure of the string is immediately visible
- Avoids accidental type coercion bugs (e.g., `'Snap ' + value + 1` → `"Snap 01"` instead of `"Snap 1"`)
- Consistent with modern JS style used across the Companion module ecosystem

## Review Notes

Flag as **low / non-blocking** during reviews. Do not require authors to fix this before merge, but recommend converting any new string concatenations to template literals.

## Observed In

- `companion-module-audiostrom-liveprofessor/LiveProfessor.js` — 10 instances converted (2026-04-05)
