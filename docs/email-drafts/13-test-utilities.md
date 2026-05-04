# Email Draft: Extracting shared test utilities

## Why

Three payment test files (`paymentValidation.test.ts`,
`createRazorpayOrder.test.ts`, `verifyRazorpayPayment.test.ts`) each defined
their own `isHttpsError()` assertion helper — identical 8-line functions
copy-pasted across files. `buildRequest()` and `failOnClientUse()` were
similarly duplicated.

## What changed

Created `functions/src/shared/testUtils.ts` with the canonical `isHttpsError`:

```ts
import assert from "node:assert/strict";

export function isHttpsError(
  actual: unknown,
  expectedCode: string,
  expectedMessage: string
): void {
  assert.ok(actual instanceof Error, "expected an Error");
  assert.equal((actual as {code?: string}).code, expectedCode);
  const message = (actual as {message?: string}).message ?? "";
  assert.ok(
    message.includes(expectedMessage),
    `expected message to include "${expectedMessage}", got "${message}"`
  );
}
```

Test files import from the shared location instead of defining locally.
`buildRunDoc` and other test helpers remain in their respective files since
they have different fixture data per module.

## How to verify

```bash
cd functions && npm test
```
