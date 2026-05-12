import * as admin from "firebase-admin";
import {HttpsError} from "firebase-functions/v2/https";
import {UserProfileDoc, RunDoc} from "../shared/firestore";
import {assertNoBlockingRelationshipInTransaction} from "../safety/blocking";
import {computeAge} from "../shared/dates";
import {requireDoc} from "../shared/validation";
import {
  participantUids,
  runParticipationId,
  runParticipationPatch,
  runParticipationsByStatusInTransaction,
} from "../shared/relationshipDocuments";
import {
  activityNotificationId,
  runActivityNotificationCopy,
  setActivityNotificationInTransaction,
} from "../shared/notifications";
import {claimUserRunScheduleInTransaction} from "./scheduleConflicts";

/**
 * Core sign-up business logic — shared by verifyRazorpayPayment (paid runs)
 * and signUpForFreeRun (free runs).
 *
 * Uses a transaction to atomically:
 *   1. Read the run and the user's profile.
 *   2. Enforce eligibility constraints (age range, gender caps).
 *   3. Check overall capacity.
 *   4. Write the user's runParticipation edge.
 *   5. Update aggregate count projections on the run.
 *
 * Enforces blocks against signed-up and attended participation edges inside
 * this transaction. The error remains generic so callers cannot infer
 * who blocked whom.
 *
 * Idempotent — calling it twice for the same user/run is safe.
 * @param {FirebaseFirestore.Firestore} db Firestore instance.
 * @param {string} runId Run to sign the user up for.
 * @param {string} userId User being signed up.
 * @param {string=} paymentId Optional payment document linked to the signup.
 * @return {Promise<void>} Resolves when the transaction completes.
 */
export async function signUpUserForRun(
  db: FirebaseFirestore.Firestore,
  runId: string,
  userId: string,
  paymentId?: string
): Promise<void> {
  const runRef = db.collection("runs").doc(runId);
  const userRef = db.collection("users").doc(userId);
  const participationRef = db
    .collection("runParticipations")
    .doc(runParticipationId(runId, userId));

  await db.runTransaction(async (tx) => {
    const [
      runSnap,
      userSnap,
      participationSnap,
      activeParticipations,
    ] = await Promise.all([
      tx.get(runRef),
      tx.get(userRef),
      tx.get(participationRef),
      runParticipationsByStatusInTransaction(tx, db, runId, [
        "signedUp",
        "attended",
      ]),
    ]);

    if (!runSnap.exists) {
      throw new HttpsError("not-found", "Run not found.");
    }
    if (!userSnap.exists) {
      throw new HttpsError("not-found", "User profile not found.");
    }

    const run = requireDoc<RunDoc>(runSnap, "RunDoc");
    if (run.status === "cancelled") {
      throw new HttpsError(
        "failed-precondition",
        "This run has been cancelled."
      );
    }
    const user = requireDoc<UserProfileDoc>(userSnap, "UserProfileDoc");
    const existingParticipation = participationSnap.exists ?
      participationSnap.data() as {status?: string} :
      null;

    // Idempotent — user already signed up.
    if (
      existingParticipation?.status === "signedUp" ||
      existingParticipation?.status === "attended"
    ) {
      return;
    }

    const activeParticipantIds = participantUids(activeParticipations);
    await assertNoBlockingRelationshipInTransaction(
      tx,
      db,
      userId,
      activeParticipantIds
    );

    const constraints = run.constraints ?? {minAge: 0, maxAge: 99};

    // Age check.
    if (constraints.minAge > 0 || constraints.maxAge < 99) {
      const age = computeAge(
        (user.dateOfBirth as FirebaseFirestore.Timestamp).toDate()
      );
      if (age < constraints.minAge) {
        throw new HttpsError(
          "failed-precondition",
          `You must be at least ${constraints.minAge} ` +
            "years old to join this run."
        );
      }
      if (age > constraints.maxAge) {
        throw new HttpsError(
          "failed-precondition",
          `You must be ${constraints.maxAge} ` +
            "or younger to join this run."
        );
      }
    }

    // Gender cap check.
    const gender = user.gender;
    const genderCap =
      gender === "man" ?
        constraints.maxMen :
        gender === "woman" ?
          constraints.maxWomen :
          undefined;

    if (genderCap !== undefined && genderCap !== null) {
      const currentCount = (run.genderCounts ?? {})[gender] ?? 0;
      if (currentCount >= genderCap) {
        throw new HttpsError(
          "failed-precondition",
          "Spots for your gender are full for this run."
        );
      }
    }

    // Overall capacity check.
    const signedUpCount = activeParticipations
      .filter((participation) => participation.data.status === "signedUp")
      .length;
    const currentBookedCount = run.bookedCount ?? signedUpCount;
    if (currentBookedCount >= run.capacityLimit) {
      throw new HttpsError(
        "failed-precondition",
        "This run is now full."
      );
    }

    await claimUserRunScheduleInTransaction(tx, db, {
      uid: userId,
      runId,
      runClubId: run.runClubId,
      startTimeMillis: run.startTime.toMillis(),
      endTimeMillis: run.endTime.toMillis(),
    });

    const wasWaitlisted = existingParticipation?.status === "waitlisted";
    const notificationType = wasWaitlisted ?
      "waitlistPromotion" :
      "runSignup";
    const notificationCopy =
      runActivityNotificationCopy(notificationType, run);
    const runUpdate: Record<string, unknown> = {
      bookedCount: admin.firestore.FieldValue.increment(1),
      [`genderCounts.${gender}`]: admin.firestore.FieldValue.increment(1),
    };
    if (wasWaitlisted) {
      runUpdate.waitlistedCount = admin.firestore.FieldValue.increment(-1);
    }

    tx.update(runRef, runUpdate);
    tx.set(participationRef, runParticipationPatch({
      exists: participationSnap.exists,
      runId,
      runClubId: run.runClubId,
      uid: userId,
      status: "signedUp",
      genderAtSignup: gender,
      paymentId,
    }), {merge: true});
    setActivityNotificationInTransaction(tx, db, {
      id: activityNotificationId(notificationType, runId),
      uid: userId,
      type: notificationType,
      title: notificationCopy.title,
      body: notificationCopy.body,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      runId,
      runClubId: run.runClubId,
    });
  });
}
