# Email Draft: Adding rate limiting to attendance callables

## Why

`markRunAttendance` and `selfCheckInAttendance` were the only callable
endpoints without `checkRateLimit()` calls. Every other callable
(`signUpForFreeRun`, `createRazorpayOrder`, `reportUser`, etc.) had rate
limiting. An attacker could spam attendance check-ins to degrade Firestore
performance or inflate costs.

## What changed

Both callables now call `checkRateLimit()` immediately after auth + validation:

```ts
// markRunAttendance.ts
const uid = requireAuth(request);
const {runId, userId} = validateCallable(request, MarkAttendanceSchema);
await checkRateLimit(admin.firestore(), uid, "markRunAttendance");

// selfCheckInAttendance.ts
const userId = requireAuth(request);
const {runId, latitude, longitude} = validateCallable(request, SelfCheckInSchema);
await checkRateLimit(admin.firestore(), userId, "selfCheckInAttendance");
```

The rate limiter uses the existing fixed-window Firestore-backed
implementation at `shared/rateLimit.ts`. Default thresholds apply
(10 requests per 60s window per user).

## How to verify

```bash
cd functions && npx tsc --noEmit
```
