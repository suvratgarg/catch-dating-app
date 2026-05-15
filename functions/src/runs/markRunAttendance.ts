import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {RunDoc} from "../shared/firestore";
import {requireAuth} from "../shared/auth";
import {MarkRunAttendanceCallablePayload} from
  "../shared/generated/markRunAttendanceCallablePayload";
import {validateMarkRunAttendanceCallablePayload} from
  "../shared/generated/schemaValidators";
import {validateCallableWithAjv} from "../shared/validation";
import {checkRateLimit} from "../shared/rateLimit";
import {appCheckCallableOptions} from "../shared/callableOptions";
import {
  runParticipationId,
  runParticipationPatch,
} from "../shared/relationshipDocuments";
import {normalizeMarkRunAttendancePayload} from "./runPayloadNormalization";

/**
 * Callable function that toggles a single user's attendance for a run.
 *
 * Must be called by the host of the run (the run club's hostUserId).
 * Check-in window opens 10 minutes before the run's start time.
 *
 * If the user is already attended they are moved back to signed up; otherwise
 * they are marked attended. The runParticipation edge is the roster source.
 */
export const markRunAttendance = onCall(appCheckCallableOptions, async (
  request
) => {
  const uid = requireAuth(request);
  const {runId, userId} =
    validateCallableWithAjv<MarkRunAttendanceCallablePayload>(
      request,
      validateMarkRunAttendanceCallablePayload,
      normalizeMarkRunAttendancePayload
    );

  await checkRateLimit(admin.firestore(), uid, "markRunAttendance");

  const db = admin.firestore();
  const runRef = db.collection("runs").doc(runId);
  const runSnap = await runRef.get();

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
  if (
    existingParticipation?.status !== "signedUp" &&
    existingParticipation?.status !== "attended"
  ) {
    throw new HttpsError(
      "failed-precondition",
      "This runner is not booked for this run."
    );
  }
  const alreadyAttended = existingParticipation.status === "attended";

  const batch = db.batch();
  batch.update(runRef, {
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
