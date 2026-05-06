import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {z} from "zod";
import {RunDoc} from "../shared/firestore";
import {requireAuth} from "../shared/auth";
import {assertNoBlockingRelationshipInTransaction} from "../safety/blocking";
import {appCheckCallableOptions} from "../shared/callableOptions";
import {validateCallable} from "../shared/validation";
import {
  runParticipationId,
  runParticipationPatch,
} from "../shared/relationshipDocuments";
import {checkRateLimit} from "../shared/rateLimit";

const JoinRunWaitlistSchema = z.object({
  runId: z.string(),
});

/**
 * Adds a user to a run waitlist after applying the same block boundary as
 * booking. Kept server-side so block state is not exposed through rules.
 */
export const joinRunWaitlist = onCall(appCheckCallableOptions, async (
  request
) => {
  const userId = requireAuth(request);
  const {runId} = validateCallable(request, JoinRunWaitlistSchema);

  const db = admin.firestore();
  await checkRateLimit(db, userId, "joinRunWaitlist");

  const runRef = db.collection("runs").doc(runId);
  const participationRef = db
    .collection("runParticipations")
    .doc(runParticipationId(runId, userId));

  await db.runTransaction(async (tx) => {
    const [runSnap, participationSnap] = await Promise.all([
      tx.get(runRef),
      tx.get(participationRef),
    ]);
    if (!runSnap.exists) {
      throw new HttpsError("not-found", "Run not found.");
    }

    const run = runSnap.data() as RunDoc;
    const existingParticipation = participationSnap.exists ?
      participationSnap.data() as {status?: string} :
      null;
    if (run.signedUpUserIds.includes(userId)) {
      throw new HttpsError(
        "already-exists",
        "You are already booked for this run."
      );
    }

    if (
      run.waitlistUserIds?.includes(userId) ||
      existingParticipation?.status === "waitlisted"
    ) {
      return;
    }

    await assertNoBlockingRelationshipInTransaction(tx, db, userId, [
      ...run.signedUpUserIds,
      ...(run.attendedUserIds ?? []),
    ]);

    tx.update(runRef, {
      waitlistUserIds: admin.firestore.FieldValue.arrayUnion(userId),
      waitlistedCount: admin.firestore.FieldValue.increment(1),
    });
    tx.set(participationRef, runParticipationPatch({
      exists: participationSnap.exists,
      runId,
      runClubId: run.runClubId,
      uid: userId,
      status: "waitlisted",
    }), {merge: true});
  });

  return {waitlisted: true};
});
