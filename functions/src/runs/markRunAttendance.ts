import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {RunDoc} from "../shared/firestore";
import {appCheckCallableOptions} from "../shared/callableOptions";

/**
 * Callable function that toggles a single user's attendance for a run.
 *
 * Must be called by the host of the run (the run club's hostUserId).
 * Check-in window opens 10 minutes before the run's start time.
 *
 * If the user is already in attendedUserIds they are removed;
 * otherwise they are added.
 */
export const markRunAttendance = onCall(appCheckCallableOptions, async (
  request
) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Must be signed in.");
  }

  const {runId, userId} = request.data as {runId?: string; userId?: string};
  if (!runId || !userId) {
    throw new HttpsError(
      "invalid-argument",
      "runId and userId are required."
    );
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

  // Check-in window opens 10 minutes before the run starts.
  const startTime = (run.startTime as FirebaseFirestore.Timestamp).toDate();
  const checkinWindow = new Date(startTime.getTime() - 10 * 60 * 1000);
  if (new Date() < checkinWindow) {
    throw new HttpsError(
      "failed-precondition",
      "Attendance check-in is not open yet."
    );
  }

  const alreadyAttended = (run.attendedUserIds ?? []).includes(userId);

  await runRef.update({
    attendedUserIds: alreadyAttended
      ? admin.firestore.FieldValue.arrayRemove(userId)
      : admin.firestore.FieldValue.arrayUnion(userId),
  });

  return {userId, attended: !alreadyAttended};
});
