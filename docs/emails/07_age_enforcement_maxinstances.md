# Email 7: Server-Side Age Enforcement + maxInstances

**To:** Suvrat
**Subject:** [Catch Audit #4, #21] Age gate + instance ceiling raised

---

## What changed

Two quick backend changes:

1. **Server-side age enforcement** — `syncPublicProfile` now checks `age < 18` before writing a public profile. Underage users are blocked from appearing in any swipe queue, even if they bypass the client-side date picker.

2. **maxInstances raised from 10 to 50** — `functions/src/index.ts` global concurrency ceiling lifted so payment functions don't queue under booking spikes.

---

## Why

**Age enforcement:** The client-side DOB picker already blocks <18 (`isAtLeastAge` check in `name_dob_page.dart:147`). But a modified client or direct API call could bypass it. The server-side check in `syncPublicProfile` is the second layer — no public profile = invisible to all swipe queues. This is a safety and compliance requirement for any dating app.

**maxInstances:** `maxInstances: 10` globally meant at most 10 concurrent function executions across all 17 functions. A popular run opening for booking would saturate this instantly. Cloud Functions v2 charges per invocation, not per instance-minute — more instances don't cost more. The Firestore write limit is 10,000/second, far above what 50 concurrent instances can generate.

---

## How

### Age enforcement (7 lines)

`syncPublicProfile` already computed `age` from the user's DOB. The check is added between that computation and the profile write:

```typescript
const age = computeAge(user.dateOfBirth.toDate());

if (age < 18) {
  logger.warn("Blocking underage public profile sync", {userId, age});
  await publicProfileRef.delete();  // Remove any existing public profile
  return;                            // Don't write a new one
}
```

If a user who previously had a valid public profile changes their DOB to under-18, the existing public profile is deleted. This covers the edge case of a user editing their profile after onboarding.

### maxInstances (one character)

```diff
-setGlobalOptions({region: "asia-south1", maxInstances: 10});
+setGlobalOptions({region: "asia-south1", maxInstances: 50});
```

No per-function overrides needed. 50 concurrent executions is sufficient for pre-launch/early scale. Individual function overrides can be added later if specific functions need isolation (e.g., payment functions at 100, analytics at 5).

---

## Files changed

```
 functions/src/profiles/syncPublicProfile.ts  | +7 lines
 functions/src/index.ts                        | 1 character changed
```
