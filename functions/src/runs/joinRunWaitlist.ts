import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {z} from "zod";
import {RunDoc} from "../shared/firestore";
import {requireAuth} from "../shared/auth";
import {assertNoBlockingRelationshipInTransaction} from "../safety/blocking";
import {appCheckCallableOptions} from "../shared/callableOptions";
import {validateCallable} from "../shared/validation";
import {
  participantUids,
  runParticipationId,
  runParticipationPatch,
  runParticipationsByStatusInTransaction,
} from "../shared/relationshipDocuments";
import {checkRateLimit} from "../shared/rateLimit";

const RunWaitlistSchema = z.object({
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
  const {runId} = validateCallable(request, RunWaitlistSchema);

  const db = admin.firestore();
  await checkRateLimit(db, userId, "joinRunWaitlist");

  const runRef = db.collection("runs").doc(runId);
  const participationRef = db
    .collection("runParticipations")
    .doc(runParticipationId(runId, userId));

  await db.runTransaction(async (tx) => {
    const [runSnap, participationSnap, activeParticipations] =
      await Promise.all([
        tx.get(runRef),
        tx.get(participationRef),
        runParticipationsByStatusInTransaction(tx, db, runId, [
          "signedUp",
          "attended",
        ]),
      ]);
    if (!runSnap.exists) {
      throw new HttpsError("not-found", "Run not found.");
    }

    const run = runSnap.data() as RunDoc;
    if (run.status === "cancelled") {
      throw new HttpsError(
        "failed-precondition",
        "This run has been cancelled."
      );
    }
    const existingParticipation = participationSnap.exists ?
      participationSnap.data() as {status?: string} :
      null;
    if (
      existingParticipation?.status === "signedUp" ||
      existingParticipation?.status === "attended"
    ) {
      throw new HttpsError(
        "already-exists",
        "You are already booked for this run."
      );
    }

    if (existingParticipation?.status === "waitlisted") {
      return;
    }

    await assertNoBlockingRelationshipInTransaction(
      tx,
      db,
      userId,
      participantUids(activeParticipations)
    );

    tx.update(runRef, {
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

/**
 * Removes the caller from a run waitlist through the same callable boundary as
 * joining, so clients never update the canonical run document directly.
 */
export const leaveRunWaitlist = onCall(appCheckCallableOptions, async (
  request
) => {
  const userId = requireAuth(request);
  const {runId} = validateCallable(request, RunWaitlistSchema);

  const db = admin.firestore();
  await checkRateLimit(db, userId, "leaveRunWaitlist");

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
    const isWaitlisted = existingParticipation?.status === "waitlisted";

    if (!isWaitlisted) {
      return;
    }

    const currentWaitlistedCount =
      run.waitlistedCount ?? 1;
    tx.update(runRef, {
      waitlistedCount: Math.max(0, currentWaitlistedCount - 1),
    });
    tx.set(participationRef, runParticipationPatch({
      exists: participationSnap.exists,
      runId,
      runClubId: run.runClubId,
      uid: userId,
      status: "cancelled",
    }), {merge: true});
  });

  return {waitlisted: false};
});
