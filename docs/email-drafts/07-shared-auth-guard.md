# Email Draft: Extracting shared auth guard for Cloud Functions

## Why we're making this change

Eleven callable functions / handlers each repeated the same 3-line auth check:

```ts
if (!request.auth) {
  throw new HttpsError("unauthenticated", "...");
}
const userId = request.auth.uid;
```

This is a classic "don't repeat yourself" violation. If the auth check semantics
ever need to change (e.g. adding App Check validation, logging failed auth
attempts, or changing the error message), we'd have to touch 11 files.

## What changed

Created `functions/src/shared/auth.ts`:

```ts
import {CallableRequest, HttpsError} from "firebase-functions/v2/https";

export function requireAuth(request: CallableRequest<unknown>): string {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "You must be signed in.");
  }
  return request.auth.uid;
}
```

Each call site now does:
```ts
const uid = requireAuth(request);
```

## Why a single generic error message

The previous messages were function-specific ("Must be signed in to book.",
"Must be signed in to block.", etc.). We standardized on "You must be signed
in." because:

- The error **code** (`"unauthenticated"`) is what the client uses for routing
  (sending unauthenticated users to the login screen).
- The error **message** is only shown to users as a fallback — the client
  already has its own `authErrorMessage()` function for user-facing display.
- If we ever need function-specific messages, we can add an optional `context`
  parameter to `requireAuth()`.

## Files changed (11 files)

- `safety/blocking.ts` — `blockUserHandler` and `unblockUserHandler`
- `safety/reporting.ts` — `reportUserHandler`
- `safety/accountDeletion.ts` — `requestAccountDeletionHandler`
- `runs/signUpForFreeRun.ts` — `signUpForFreeRun`
- `runs/selfCheckInAttendance.ts` — `selfCheckInAttendance`
- `runs/joinRunWaitlist.ts` — `joinRunWaitlist`
- `runs/markRunAttendance.ts` — `markRunAttendance`
- `runs/cancelRunSignUp.ts` — `cancelRunSignUp`
- `payments/createRazorpayOrder.ts` — `createRazorpayOrderHandler`
- `payments/verifyRazorpayPayment.ts` — `verifyRazorpayPaymentHandler`

## One deliberate exclusion

`createRazorpayOrder.ts` has a wrapper function that checks `if (request.auth)`
(positive check, not negative guard) purely to optionally apply rate limiting
for authenticated users. This is NOT a security guard — it's a "do this if
authenticated" pattern. It was left unchanged.

## How to verify

```bash
cd functions && npx tsc --noEmit
```

No errors = clean compile. The existing tests for each callable exercise the
auth paths.
