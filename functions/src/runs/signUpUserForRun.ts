import * as admin from "firebase-admin";
import {HttpsError} from "firebase-functions/v2/https";
import {AppUserDoc, RunDoc} from "../types/firestore";

/**
 * Core sign-up business logic — shared by verifyRazorpayPayment (paid runs)
 * and signUpForFreeRun (free runs).
 *
 * Uses a transaction to atomically:
 *   1. Read the run and the user's profile.
 *   2. Enforce eligibility constraints (age range, gender caps).
 *   3. Check overall capacity.
 *   4. Add the user to signedUpUserIds and increment genderCounts.
 *   5. Remove the user from waitlistUserIds if present.
 *
 * Idempotent — calling it twice for the same user/run is safe.
 */
export async function signUpUserForRun(
  db: FirebaseFirestore.Firestore,
  runId: string,
  userId: string
): Promise<void> {
  const runRef = db.collection("runs").doc(runId);
  const userRef = db.collection("users").doc(userId);

  await db.runTransaction(async (tx) => {
    const [runSnap, userSnap] = await Promise.all([
      tx.get(runRef),
      tx.get(userRef),
    ]);

    if (!runSnap.exists) {
      throw new HttpsError("not-found", "Run not found.");
    }
    if (!userSnap.exists) {
      throw new HttpsError("not-found", "User profile not found.");
    }

    const run = runSnap.data() as RunDoc;
    const user = userSnap.data() as AppUserDoc;

    // Idempotent — user already signed up.
    if (run.signedUpUserIds.includes(userId)) {
      return;
    }

    const constraints = run.constraints ?? {minAge: 0, maxAge: 99};

    // ── Age check ─────────────────────────────────────────────────────────────
    if (constraints.minAge > 0 || constraints.maxAge < 99) {
      const age = computeAge(
        (user.dateOfBirth as FirebaseFirestore.Timestamp).toDate()
      );
      if (age < constraints.minAge) {
        throw new HttpsError(
          "failed-precondition",
          `You must be at least ${constraints.minAge} years old to join this run.`
        );
      }
      if (age > constraints.maxAge) {
        throw new HttpsError(
          "failed-precondition",
          `You must be ${constraints.maxAge} or younger to join this run.`
        );
      }
    }

    // ── Gender cap check ──────────────────────────────────────────────────────
    const gender = user.gender;
    const genderCap =
      gender === "man"
        ? constraints.maxMen
        : gender === "woman"
          ? constraints.maxWomen
          : undefined;

    if (genderCap !== undefined && genderCap !== null) {
      const currentCount = (run.genderCounts ?? {})[gender] ?? 0;
      if (currentCount >= genderCap) {
        throw new HttpsError(
          "failed-precondition",
          "Spots for your gender are full for this run."
        );
      }
    }

    // ── Overall capacity check ─────────────────────────────────────────────────
    if (run.signedUpUserIds.length >= run.capacityLimit) {
      throw new HttpsError(
        "failed-precondition",
        "This run is now full."
      );
    }

    // ── Atomic write ──────────────────────────────────────────────────────────
    tx.update(runRef, {
      signedUpUserIds: admin.firestore.FieldValue.arrayUnion(userId),
      waitlistUserIds: admin.firestore.FieldValue.arrayRemove(userId),
      [`genderCounts.${gender}`]: admin.firestore.FieldValue.increment(1),
    });
  });
}

function computeAge(dob: Date): number {
  const today = new Date();
  let age = today.getFullYear() - dob.getFullYear();
  const monthDiff = today.getMonth() - dob.getMonth();
  if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < dob.getDate())) {
    age--;
  }
  return age;
}
