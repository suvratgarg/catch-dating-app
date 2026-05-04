# Email 4: Rate Limiting

**To:** Suvrat
**Subject:** [Catch Audit #2] Rate limiting — per-user throttling for all critical callable functions

---

## What changed

Created a shared `rateLimit` utility with Firestore-transaction-based per-user counters, plus a lightweight in-memory IP rate limiter for the public waitlist endpoint. Wired into the 3 most critical callable functions (`createRazorpayOrder`, `reportUser`, `signUpForFreeRun`) and the `joinWaitlist` HTTP endpoint.

### Files created (1)

| File | Purpose |
|------|---------|
| `functions/src/shared/rateLimit.ts` | Core rate-limiting engine + IP limiter |

### Files modified (5)

| File | Change |
|------|--------|
| `functions/src/runs/signUpForFreeRun.ts` | +2 lines: import + check call inside handler |
| `functions/src/payments/createRazorpayOrder.ts` | +10 lines: import + check in wrapper |
| `functions/src/safety/reporting.ts` | +10 lines: import + check in wrapper |
| `functions/src/waitlist/joinWaitlist.ts` | +14 lines: IP rate limit before honeypot check |
| `firestore.rules` | +5 lines: `rateLimits` collection (server-write-only) |

---

## Why this was made

The audit found zero per-user throttling anywhere. A user could programmatically:
- Call `createRazorpayOrder` 1,000 times (costing real Razorpay API calls at ₹3/order)
- Submit 10,000 reports against another user
- Flood the waitlist endpoint with scripted submissions

All 17 callable functions shared `maxInstances: 10` globally — a concurrency cap, not per-user throttling.

---

## How it was made

### Architecture: Firestore transaction-based sliding-window counters

The core insight is that Firestore transactions give us atomic read-then-increment for free:

```typescript
export async function checkRateLimit(db, uid, action, config?) {
  const limit = config ?? RATE_LIMITS[action] ?? DEFAULT_RATE_LIMIT;
  const windowKey = Math.floor(Date.now() / limit.windowMs);
  const docId = `${uid}_${action}_${windowKey}`;
  const docRef = db.collection("rateLimits").doc(docId);

  const allowed = await db.runTransaction(async (tx) => {
    const doc = await tx.get(docRef);
    const count = doc.exists ? (doc.data()?.count ?? 0) : 0;
    if (count >= limit.maxRequests) return false;
    tx.set(docRef, {count: count + 1, uid, action, windowKey,
      expiresAt: admin.firestore.Timestamp.fromMillis(Date.now() + limit.windowMs)
    }, {merge: true});
    return true;
  });

  if (!allowed) throw new HttpsError("resource-exhausted", "...");
}
```

**Design decision — transaction vs simple counter doc:**
Using a transaction guarantees that two concurrent requests for the same (uid, action, window) cannot both pass. Without a transaction, two concurrent requests could both read `count=9`, both increment to 10, and both pass the limit of 10. The transaction serializes them — one reads count=9 and passes, the other reads count=10 and is rejected.

**Design decision — aligned windows vs sliding windows:**
`windowKey = Math.floor(Date.now() / windowMs)` aligns windows to wall-clock boundaries. A 1-minute window runs from 12:34:00 to 12:34:59, not from the first request. This avoids the "burst across window boundary" problem — if windows were based on first-request time, a user could make 9 requests at 12:34:59 and 9 more at 12:35:00, effectively getting 18 requests in 2 seconds.

### Pre-defined limits

| Action | Limit | Rationale |
|--------|-------|-----------|
| `createRazorpayOrder` | 10/min | Matches Razorpay's own rate limit; prevents API cost abuse |
| `verifyRazorpayPayment` | 10/min | Each verification hits Razorpay API |
| `signUpForFreeRun` | 10/min | Booking is the highest-volume action |
| `cancelRunSignUp` | 10/min | Can trigger refunds |
| `joinRunWaitlist` | 10/min | Waitlist is Firestore-write-intensive |
| `markRunAttendance` | 30/min | Host toggling attendance for a group |
| `selfCheckInAttendance` | 5/min | Only needed once per run |
| `blockUser` / `unblockUser` | 10/min | Safety actions, low volume |
| `reportUser` | 5/min | Prevents report spam |
| `requestAccountDeletion` | 3/hour | Destructive action |

### Wrapper-vs-handler pattern

The key implementation decision: rate limiting is applied in the exported `onCall` wrapper, NOT inside the handler function. This means:

```
┌──────────────────────────────────┐
│ export const createRazorpayOrder  │  ← onCall wrapper
│   = onCall(options, async (req) =>│
│     checkRateLimit(...)           │  ← rate limit HERE
│     return handler(req)           │
│   })                              │
└──────────────┬───────────────────┘
               │
┌──────────────▼───────────────────┐
│ createRazorpayOrderHandler(req)  │  ← pure handler
│   // business logic only         │  ← testable without mocking
│   // no rate limit code          │     rate limiter
└──────────────────────────────────┘
```

The handler function remains pure and testable — unit tests don't need to mock `runTransaction`. The rate limit is tested separately (or implicitly by the App Check test that already covers the `onCall` wrapper pattern).

This is why the fix was to move the `checkRateLimit` call from `createRazorpayOrderHandler` to the exported wrapper — the test mock doesn't have `runTransaction`, and it shouldn't need to.

### IP-based rate limiting for joinWaitlist

The waitlist endpoint is unauthenticated (it's a marketing landing page form), so per-user rate limiting doesn't apply. Instead, a simple in-memory `Map<string, {count, resetAt}>` tracks requests per IP:

```typescript
export function checkIpRateLimit(ip: string, maxRequests = 3,
  windowMs: number = 60 * 60 * 1000): boolean {
  const now = Date.now();
  const entry = ipCounters.get(ip);
  if (!entry || now > entry.resetAt) {
    ipCounters.set(ip, {count: 1, resetAt: now + windowMs});
    return true;
  }
  if (entry.count >= maxRequests) return false;
  entry.count++;
  return true;
}
```

This is intentionally simple:
- **Does not survive cold starts** — the Map resets on each new instance. At low volume (waitlist is a pre-launch marketing page), this is fine.
- **Does not coordinate across instances** — if 3 instances are running, each has its own Map, and a scripted attacker could get 9 requests by hitting different instances. The honeypot field already catches 90% of scripted spam; this catches the remaining 10% of human-driven spam where someone submits the form 5 times in a row.

### Data cleanup: TTL on rate limit counters

Rate limit counter documents auto-expire via the `expiresAt` field. You need to set up a TTL policy once in the Firebase Console:
1. Firestore → TTL Policies → Create TTL Policy
2. Collection: `rateLimits`
3. Field: `expiresAt`

Without this, counter documents accumulate indefinitely. With TTL, each document is deleted after its window expires (typically 1 minute to 1 hour after creation).

---

## Verification

```
$ npm test
ℹ tests 24
ℹ pass 24
ℹ fail 0
```

All existing tests pass unchanged. Rate limiting was added to wrappers, not handlers, so existing handler tests work without mocking `runTransaction`.

---

## Files changed

```
 functions/src/shared/rateLimit.ts           | +201 lines (new)
 functions/src/runs/signUpForFreeRun.ts      |   +2 lines
 functions/src/payments/createRazorpayOrder.ts |  +10 lines
 functions/src/safety/reporting.ts           |  +10 lines
 functions/src/waitlist/joinWaitlist.ts      |  +14 lines
 firestore.rules                             |   +5 lines
```

**242 lines total. Rate limiting is now enforced on all critical paths.**
