import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {RunDoc} from "../shared/firestore";

/**
 * Callable function that copies signedUpUserIds → attendedUserIds for a run.
 *
 * Must be called by the host of the run (the run club's hostUserId).
 * Intended to be triggered manually after the run ends.
 *
 * Idempotent — calling it multiple times is safe; it uses arrayUnion.
 */
export const markRunAttendance = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Must be signed in.");
  }

  const {runId} = request.data as {runId?: string};
  if (!runId) {
    throw new HttpsError("invalid-argument", "runId is required.");
  }

  const db = admin.firestore();
  const runRef = db.collection("runs").doc(runId);
  const runSnap = await runRef.get();

  if (!runSnap.exists) {
    throw new HttpsError("not-found", "Run not found.");
  }

  const run = runSnap.data() as RunDoc;

  // Verify the caller is the host of the run's club.
  const clubRef = db.collection("runClubs").doc(run.runClubId);
  const clubSnap = await clubRef.get();
  if (!clubSnap.exists) {
    throw new HttpsError("not-found", "Run club not found.");
  }
  const club = clubSnap.data() as {hostUserId: string};
  if (club.hostUserId !== request.auth.uid) {
    throw new HttpsError(
      "permission-denied",
      "Only the club host can mark attendance."
    );
  }

  // Ensure the run has ended.
  const endTime = (run.endTime as FirebaseFirestore.Timestamp).toDate();
  if (endTime > new Date()) {
    throw new HttpsError(
      "failed-precondition",
      "Cannot mark attendance before the run has ended."
    );
  }

  await runRef.update({
    attendedUserIds: admin.firestore.FieldValue.arrayUnion(
      ...run.signedUpUserIds
    ),
  });

  return {markedCount: run.signedUpUserIds.length};
});
