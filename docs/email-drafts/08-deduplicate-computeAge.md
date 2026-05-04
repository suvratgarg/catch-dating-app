# Email Draft: Deduplicating computeAge with date-fns

## Why we're making this change

Two files had identical age-computation logic with slightly different
signatures:

- `syncPublicProfile.ts` — `computeAge(Timestamp)` using `toDate()` internally
- `signUpUserForRun.ts` — `computeAge(Date)`

Both manually calculated `today.getFullYear() - dob.getFullYear()` with a
birthday-has-occurred-this-year adjustment. This is easy to get wrong (the
two implementations even wrote the condition differently — one used a
positive has-had-birthday check, the other a negative monthDiff check). It's
also exactly what `date-fns` `differenceInYears` does, correctly handling leap
years and edge cases.

## What changed

Created `functions/src/shared/dates.ts`:

```ts
import {differenceInYears} from "date-fns";

export function computeAge(dob: Date): number {
  return differenceInYears(new Date(), dob);
}
```

Both callers now use this shared function. The Timestamp caller converts first:

```ts
// syncPublicProfile.ts
age: computeAge(user.dateOfBirth.toDate()),

// signUpUserForRun.ts
const age = computeAge(
  (user.dateOfBirth as FirebaseFirestore.Timestamp).toDate()
);
```

The 12-line manual function in each file is removed.

## Decision: single Date signature

The shared function takes `Date` (not `Timestamp`) because:
- `Date` is the universal JS date type
- `Timestamp.toDate()` at the call site is explicit about the conversion
- This avoids coupling the shared utility to Firebase-specific types

## How to verify

```bash
cd functions && npx tsc --noEmit
```

The existing tests for `syncPublicProfile` and sign-up flows exercise the
age computation paths.
