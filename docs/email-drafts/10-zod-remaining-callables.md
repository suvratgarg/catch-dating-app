# Email Draft: Finishing zod validation across all Cloud Functions callables

## Why we're making this change

After the first pass converted 3 callables to zod, 5 more were still using
manual `request.data as Foo` casts with ad-hoc null checks. These are now
converted, completing the validation migration.

Every callable that takes user input now validates it through zod before any
business logic runs.

## What changed

Five callables converted:

### createRazorpayOrder.ts
```ts
const CreateOrderSchema = z.object({ runId: z.string() });
const {runId} = validateCallable(request, CreateOrderSchema);
```
Replaced: `request.data?.runId` + manual `if (!runId)` throw.

### verifyRazorpayPayment.ts
```ts
const VerifyPaymentSchema = z.object({
  paymentId: z.string(),
  orderId: z.string(),
  signature: z.string(),
});
const {paymentId, orderId, signature} = validateCallable(request, VerifyPaymentSchema);
```
Replaced: 3 separate `request.data?.` reads + manual `if (!a || !b || !c)`.

### markRunAttendance.ts
```ts
const MarkAttendanceSchema = z.object({
  runId: z.string(),
  userId: z.string(),
});
```
Replaced: `request.data as {runId?: string; userId?: string}` + manual null checks.

### selfCheckInAttendance.ts
```ts
const SelfCheckInSchema = z.object({
  runId: z.string(),
  latitude: z.number().optional(),
  longitude: z.number().optional(),
});
```
Replaced: inline `as` cast with nullable fields + manual `if (!runId)`.

### cancelRunSignUp.ts
```ts
const CancelSchema = z.object({ runId: z.string() });
```
Replaced: `request.data as CancelData` interface + manual `if (!runId)`.

## Status

All 10 callable endpoints now use `validateCallable()` with zod schemas.
No more `request.data as` casts or manual `if (!field)` validation anywhere
in the callable layer.
