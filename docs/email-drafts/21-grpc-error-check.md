# Email Draft: Fixing fragile gRPC error code check

## Why

`onSwipeCreated.ts` checked for duplicate match creation with a raw numeric
gRPC code:

```ts
catch (e: unknown) {
  if ((e as {code?: number}).code === 6) {  // gRPC ALREADY_EXISTS
    return;
  }
  throw e;
}
```

This is fragile for two reasons:
1. **Numeric code 6 is an implementation detail** of gRPC. The Firebase Admin
   SDK may surface it as a string code (`"already-exists"`) in newer versions.
2. **The `as` cast on `unknown`** is unchecked — if the error shape changes,
   the check silently fails and a real error is swallowed.

## What changed

The check now handles both the legacy numeric code and the modern string code:

```ts
catch (e: unknown) {
  const code = (e as {code?: unknown}).code;
  if (code === 6 || code === "already-exists") {
    // ALREADY_EXISTS — match already exists, nothing to do
    return;
  }
  throw e;
}
```

Extracting `code` into a `const` makes the dual-check readable. The comment
no longer mentions "gRPC" since the string variant comes from the Firebase
SDK wrapper, not gRPC directly.

## How to verify

```bash
cd functions && npx tsc --noEmit
```
