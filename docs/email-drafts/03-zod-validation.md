# Email Draft: Adding zod validation to Cloud Functions callables

## Why we're making this change

10+ callable endpoints used manual type casts (`request.data as SomeType`)
followed by ad-hoc null checks. This is the "we trust the client" pattern —
but the client is outside our trust boundary. Malformed or malicious requests
get a weak error message at best, or silently pass with null/undefined values
at worst.

zod replaces the manual pattern with declarative schema validation:

```ts
// Before (manual)
interface JoinRunWaitlistData { runId: string; }
const {runId} = request.data as JoinRunWaitlistData;
if (!runId) {
  throw new HttpsError("invalid-argument", "runId is required.");
}

// After (zod)
const JoinRunWaitlistSchema = z.object({ runId: z.string() });
const {runId} = validateCallable(request, JoinRunWaitlistSchema);
```

## What changed

Created `functions/src/shared/validation.ts`:

```ts
import {CallableRequest, HttpsError} from "firebase-functions/v2/https";
import {ZodType} from "zod";

export function validateCallable<T>(
  request: CallableRequest<unknown>,
  schema: ZodType<T>,
): T {
  const result = schema.safeParse(request.data);
  if (!result.success) {
    const message = result.error.issues
      .map((i) => `${i.path.join(".")}: ${i.message}`)
      .join("; ");
    throw new HttpsError("invalid-argument", message);
  }
  return result.data;
}
```

Three callables updated with zod schemas:

### joinRunWaitlist.ts — simple schema
```ts
const JoinRunWaitlistSchema = z.object({ runId: z.string() });
```

### reporting.ts — complex schema (optionals + max lengths)
```ts
const ReportUserSchema = z.object({
  targetUserId: z.string(),
  source: z.string().optional(),
  reasonCode: z.string().max(64).optional(),
  contextId: z.string().max(128).optional(),
  notes: z.string().max(2000).optional(),
});
```
This eliminated `normalizeReportText()` from the handler (zod handles the
max-length enforcement). The function is kept exported for other callers.

### blocking.ts — shared schema for block/unblock
```ts
const BlockUserSchema = z.object({
  targetUserId: z.string(),
  source: z.string().optional(),
  reasonCode: z.string().optional(),
});
```
Both `blockUserHandler` and `unblockUserHandler` now use `validateCallable`,
replacing the manual `request.data?.targetUserId` null checks and optional
chaining.

## Key decisions

1. **`safeParse` not `parse`.** `safeParse` returns a result object instead of
   throwing. We catch the failure and throw `HttpsError` with the appropriate
   Firebase error code (`"invalid-argument"`) so the client gets a structured
   Firebase error, not a generic internal error.

2. **Schema defined at module level.** Each file defines its schema as a `const`
   at the top of the file (not inline). This keeps the handler function clean
   and makes the expected shape visible at a glance.

3. **`request.data` defaults to `null`** for empty callable requests. zod's
   `safeParse(null)` fails with a type error, so callables that accept no
   data (like `requestAccountDeletion`) simply skip `validateCallable`.

## Files to update next

The remaining callables follow the same pattern and can be updated in a
follow-up:
- `cancelRunSignUp.ts` — `z.object({ runId: z.string() })`
- `markRunAttendance.ts` — `z.object({ runId: z.string(), userId: z.string() })`
- `selfCheckInAttendance.ts` — `z.object({ runId: z.string(), latitude: z.number().optional(), longitude: z.number().optional() })`
- `createRazorpayOrder.ts` — `z.object({ runId: z.string() })`
- `verifyRazorpayPayment.ts` — `z.object({ paymentId: z.string(), orderId: z.string(), signature: z.string() })`

## How to verify

```bash
cd functions && npx tsc --noEmit
```

No errors = clean compile. Existing tests for reporting/blocking exercise the
validation paths.
