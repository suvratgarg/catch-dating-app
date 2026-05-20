import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {EventDoc} from "../shared/firestore";
import {requireAuth} from "../shared/auth";
import {MarkEventAttendanceCallablePayload} from
  "../shared/generated/markEventAttendanceCallablePayload";
import {validateMarkEventAttendanceCallablePayload} from
  "../shared/generated/schemaValidators";
import {validateCallableWithAjv} from "../shared/validation";
import {checkRateLimit} from "../shared/rateLimit";
import {appCheckCallableOptions} from "../shared/callableOptions";
import {
  eventParticipationId,
  eventParticipationPatch,
} from "../shared/relationshipDocuments";
import {normalizeMarkEventAttendancePayload} from "./eventPayloadNormalization";
import {buildAttendanceSignalFact} from "../marketplace/signalBuilders";
import {
  recordParticipantSignalFactsBestEffort,
} from "../marketplace/participantSignals";
import {isClubHost} from "../shared/clubHosts";

/**
 * Callable function that toggles a single user's attendance for an event.
 *
 * Must be called by one of the event club's hosts.
 * Check-in window opens 10 minutes before the event's start time.
 *
 * If the user is already attended they are moved back to signed up; otherwise
 * they are marked attended. The eventParticipation edge is the roster source.
 */
export const markEventAttendance = onCall(appCheckCallableOptions, async (
  request
) => {
  const uid = requireAuth(request);
  const {eventId, userId} =
    validateCallableWithAjv<MarkEventAttendanceCallablePayload>(
      request,
      validateMarkEventAttendanceCallablePayload,
      normalizeMarkEventAttendancePayload
    );

  await checkRateLimit(admin.firestore(), uid, "markEventAttendance");

  const db = admin.firestore();
  const eventRef = db.collection("events").doc(eventId);
  const eventSnap = await eventRef.get();

  if (!eventSnap.exists) {
    throw new HttpsError("not-found", "Event not found.");
  }

  const event = eventSnap.data() as EventDoc;
  if (event.status === "cancelled") {
    throw new HttpsError(
      "failed-precondition",
      "This event has been cancelled."
    );
  }

  // Verify the caller is the host of the event's club.
  const clubRef = db.collection("clubs").doc(event.clubId);
  const clubSnap = await clubRef.get();
  if (!clubSnap.exists) {
    throw new HttpsError("not-found", "Club not found.");
  }
  const club = clubSnap.data() as Parameters<typeof isClubHost>[0];
  if (!isClubHost(club, uid)) {
    throw new HttpsError(
      "permission-denied",
      "Only the club host can mark attendance."
    );
  }

  // Check-in window opens 10 minutes before the event starts.
  const startTime = (event.startTime as FirebaseFirestore.Timestamp).toDate();
  const checkinWindow = new Date(startTime.getTime() - 10 * 60 * 1000);
  if (new Date() < checkinWindow) {
    throw new HttpsError(
      "failed-precondition",
      "Attendance check-in is not open yet."
    );
  }

  const participationRef = db
    .collection("eventParticipations")
    .doc(eventParticipationId(eventId, userId));
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
      "This runner is not booked for this event."
    );
  }
  const alreadyAttended = existingParticipation.status === "attended";

  const batch = db.batch();
  batch.update(eventRef, {
    checkedInCount: admin.firestore.FieldValue.increment(
      alreadyAttended ? -1 : 1
    ),
  });
  batch.set(participationRef, eventParticipationPatch({
    exists: participationSnap.exists,
    eventId,
    clubId: event.clubId,
    uid: userId,
    status: alreadyAttended ? "signedUp" : "attended",
  }), {merge: true});
  await batch.commit();

  await recordParticipantSignalFactsBestEffort(db, [
    buildAttendanceSignalFact({
      eventId,
      clubId: event.clubId,
      uid: userId,
      attended: !alreadyAttended,
      sourceId: `host_attendance_${eventId}_${userId}_${!alreadyAttended}`,
    }),
  ]);

  return {userId, attended: !alreadyAttended};
});
