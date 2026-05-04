import assert from "node:assert/strict";

/**
 * Asserts that an error is an HttpsError with the expected code and message.
 */
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
