# Email Draft: Consolidating Cloud Functions logging

## Why we're making this change

Five Cloud Functions files used `console.log` / `console.error` while six others
already used `firebase-functions/logger`. This was inconsistent:

- `console.log` writes unstructured text to stdout. In Cloud Logging, it shows
  up with severity DEFAULT (not INFO) and no structured metadata.
- `firebase-functions/logger` (`logger.info`, `logger.error`, etc.) writes
  structured JSON with proper severity levels matching Cloud Logging's native
  severity model. This means you can filter by severity in the GCP console,
  set up log-based alerts on ERROR, and get automatic correlation with function
  invocation traces.

## What changed

Five files (3 `console.log` sites, 3 `console.error` sites across 4 files +
1 new file):

| File | Before | After |
|---|---|---|
| `verifyRazorpayPayment.ts` | `console.error(...)` | `logger.error(...)` |
| `cancelRunSignUp.ts` | `console.error(...)` | `logger.error(...)` |
| `moderateMessage.ts` | `console.log(...)` x2 | `logger.info(...)` x2 |
| `moderatePhoto.ts` | `console.log(...)` x2, `console.error(...)` | `logger.info(...)` x2, `logger.error(...)` |
| `selfCheckInAttendance.ts` | `console.log(...)` | `logger.info(...)` |

## No new dependency

`firebase-functions/logger` is already bundled with `firebase-functions` v7.0.0
which the project already depends on. No `package.json` changes needed.

## How to verify

```bash
cd functions && npx tsc --noEmit
```

No output = clean compile. The existing function tests exercise these log paths
since they run through the moderation triggers, payment verification, and
attendance flows.
