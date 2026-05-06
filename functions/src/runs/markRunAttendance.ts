import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {RunDoc} from "../shared/firestore";
import {requireAuth} from "../shared/auth";
import {validateCallable} from "../shared/validation";
import {checkRateLimit} from "../shared/rateLimit";
import {z} from "zod";
import {appCheckCallableOptions} from "../shared/callableOptions";
import {
  runParticipationId,
  runParticipationPatch,
} from "../shared/relationshipDocuments";

const MarkAttendanceSchema = z.object({
  runId: z.string(),
  userId: z.string(),
});

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
  const uid = requireAuth(request);
  const {runId, userId} = validateCallable(request, MarkAttendanceSchema);

  await checkRateLimit(admin.firestore(), uid, "markRunAttendance");

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
  if (club.hostUserId !== uid) {
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

  const participationRef = db
    .collection("runParticipations")
    .doc(runParticipationId(runId, userId));
  const participationSnap = await participationRef.get();
  const existingParticipation = participationSnap.exists ?
    participationSnap.data() as {status?: string} :
    null;
  const alreadyAttended =
    existingParticipation?.status === "attended" ||
    (run.attendedUserIds ?? []).includes(userId);

  const batch = db.batch();
  batch.update(runRef, {
    attendedUserIds: alreadyAttended ?
      admin.firestore.FieldValue.arrayRemove(userId) :
      admin.firestore.FieldValue.arrayUnion(userId),
    checkedInCount: admin.firestore.FieldValue.increment(
      alreadyAttended ? -1 : 1
    ),
  });
  batch.set(participationRef, runParticipationPatch({
    exists: participationSnap.exists,
    runId,
    runClubId: run.runClubId,
    uid: userId,
    status: alreadyAttended ? "signedUp" : "attended",
  }), {merge: true});
  await batch.commit();

  return {userId, attended: !alreadyAttended};
});
