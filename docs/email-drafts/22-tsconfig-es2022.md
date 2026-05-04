# Email Draft: Raising TypeScript compile target to ES2022

## Why

`functions/tsconfig.json` had `"target": "es2017"`. The Cloud Functions
runtime is Node 24, which natively supports all ES2022 features (and most
ES2023/ES2024). Compiling to ES2017 meant:

- `async`/`await` was transpiled to generators + `__awaiter` helper
- `Object.hasOwn()` was unavailable
- `Array.prototype.flatMap()` was polyfilled
- `??` and `?.` were transpiled to verbose ternaries
- Class fields used `Object.defineProperty` instead of native syntax

## What changed

```json
// Before
"target": "es2017"

// After
"target": "es2022"
```

The compiled output is now smaller (no `__awaiter` wrappers), faster (native
async), and easier to debug (stack traces map directly to source).

## Verification

```bash
cd functions && npx tsc --noEmit
```

Existing tests pass with the new target since Node 24 supports all ES2022
features natively.
