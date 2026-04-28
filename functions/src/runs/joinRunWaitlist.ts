import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {RunDoc} from "../shared/firestore";
import {assertNoBlockingRelationshipInTransaction} from "../safety/blocking";

interface JoinRunWaitlistData {
  runId: string;
}

/**
 * Adds a user to a run waitlist after applying the same block boundary as
 * booking. Kept server-side so block state is not exposed through rules.
 */
export const joinRunWaitlist = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError(
      "unauthenticated",
      "Must be signed in to join a waitlist."
    );
  }

  const {runId} = request.data as JoinRunWaitlistData;
  if (!runId) {
    throw new HttpsError("invalid-argument", "runId is required.");
  }

  const db = admin.firestore();
  const runRef = db.collection("runs").doc(runId);
  const userId = request.auth.uid;

  await db.runTransaction(async (tx) => {
    const runSnap = await tx.get(runRef);
    if (!runSnap.exists) {
      throw new HttpsError("not-found", "Run not found.");
    }

    const run = runSnap.data() as RunDoc;
    if (run.signedUpUserIds.includes(userId)) {
      throw new HttpsError(
        "already-exists",
        "You are already booked for this run."
      );
    }

    if (run.waitlistUserIds?.includes(userId)) {
      return;
    }

    await assertNoBlockingRelationshipInTransaction(tx, db, userId, [
      ...run.signedUpUserIds,
      ...(run.attendedUserIds ?? []),
    ]);

    tx.update(runRef, {
      waitlistUserIds: admin.firestore.FieldValue.arrayUnion(userId),
    });
  });

  return {waitlisted: true};
});
