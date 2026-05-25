/**
 * Participant self-check-in for event attendance with GPS verification.
 *
 * This removes the single-host dependency from the attendance flow.
 * Previously, only the club host could call `markEventAttendance`. If
 * the host forgot, every participant got zero swipe windows and the
 * product loop was dead. Now participants can check themselves in.
 *
 * ## Validation gates (all must pass)
 *
 *   1. Caller must be authenticated.
 *   2. Caller must have a signed-up eventParticipation edge.
 *   3. Check-in window: configured in tool/contracts/business_rules.json.
 *      Outside this window, only the host can mark attendance.
 *   4. GPS proximity: caller must be within the configured distance of the
 *      meeting point. Events without coordinates skip this check (graceful
 *      degradation for existing events created before this feature).
 *
 * ## Idempotent
 *
 * Calling twice returns `{attended: true}` with no error — the user is
 * already attended.
 */

import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import {requireAuth} from "../shared/auth";
import {SelfCheckInAttendanceCallablePayload} from
  "../shared/generated/selfCheckInAttendanceCallablePayload";
import {validateSelfCheckInAttendanceCallablePayload} from
  "../shared/generated/schemaValidators";
import {validateCallableWithAjv} from "../shared/validation";
import {checkRateLimit} from "../shared/rateLimit";
import {EventDoc} from "../shared/generated/firestoreAdminTypes";
import {appCheckCallableOptions} from "../shared/callableOptions";
import {
  eventParticipationId,
  eventParticipationPatch,
} from "../shared/relationshipDocuments";
import {
  EVENT_SELF_CHECK_IN_MAX_DISTANCE_METERS,
  EVENT_SELF_CHECK_IN_WINDOW_AFTER_MINUTES,
  EVENT_SELF_CHECK_IN_WINDOW_BEFORE_MINUTES,
} from "../shared/businessRules";
import {normalizeEventIdPayload} from "./eventPayloadNormalization";
import {buildAttendanceSignalFact} from "../marketplace/signalBuilders";
import {
  recordParticipantSignalFactsBestEffort,
} from "../marketplace/participantSignals";

// ── Constants ──────────────────────────────────────────────────────────────

/** Earth's mean radius in metres — used by the Haversine formula. */
const EARTH_RADIUS_M = 6_371_000;

// ── GPS proximity ──────────────────────────────────────────────────────────

/**
 * Haversine distance between two lat/lng points, in metres.
 *
 * We inline this rather than adding a geo dependency so the function has
 * zero cold-start overhead — same algorithm as the `latlong2` Dart package.
 * @param {number} lat1 First point latitude.
 * @param {number} lng1 First point longitude.
 * @param {number} lat2 Second point latitude.
 * @param {number} lng2 Second point longitude.
 * @return {number} Distance in metres.
 */
function haversineDistanceM(
  lat1: number, lng1: number,
  lat2: number, lng2: number
): number {
  const dLat = toRad(lat2 - lat1);
  const dLng = toRad(lng2 - lng1);
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) *
    Math.sin(dLng / 2) * Math.sin(dLng / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return EARTH_RADIUS_M * c;
}

/**
 * Converts degrees to radians.
 * @param {number} deg Angle in degrees.
 * @return {number} Angle in radians.
 */
function toRad(deg: number): number {
  return (deg * Math.PI) / 180;
}

// ── Handler ────────────────────────────────────────────────────────────────

export const selfCheckInAttendance = onCall(appCheckCallableOptions, async (
  request
) => {
  const userId = requireAuth(request);
  const {eventId, latitude, longitude} = validateCallableWithAjv<
    SelfCheckInAttendanceCallablePayload
  >(
    request,
    validateSelfCheckInAttendanceCallablePayload,
    normalizeEventIdPayload
  );

  await checkRateLimit(admin.firestore(), userId, "selfCheckInAttendance");

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
  const participationRef = db
    .collection("eventParticipations")
    .doc(eventParticipationId(eventId, userId));
  const participationSnap = await participationRef.get();
  const existingParticipation = participationSnap.exists ?
    participationSnap.data() as {status?: string} :
    null;

  // ── 1. Must be signed up ────────────────────────────────────────────────

  if (
    existingParticipation?.status !== "signedUp" &&
    existingParticipation?.status !== "attended"
  ) {
    throw new HttpsError(
      "failed-precondition",
      "You must be signed up for this event to check in."
    );
  }

  // ── 2. Idempotent — already checked in ───────────────────────────────────

  if (existingParticipation?.status === "attended") {
    return {userId, attended: true};
  }

  // ── 3. Check-in window ──────────────────────────────────────────────────

  const startTime = (event.startTime as FirebaseFirestore.Timestamp).toDate();
  const windowStart = new Date(
    startTime.getTime() - EVENT_SELF_CHECK_IN_WINDOW_BEFORE_MINUTES * 60 * 1000
  );
  const windowEnd = new Date(
    startTime.getTime() + EVENT_SELF_CHECK_IN_WINDOW_AFTER_MINUTES * 60 * 1000
  );
  const now = new Date();

  if (now < windowStart) {
    throw new HttpsError(
      "failed-precondition",
      `Check-in opens ${EVENT_SELF_CHECK_IN_WINDOW_BEFORE_MINUTES} min ` +
      "before the event starts."
    );
  }

  if (now > windowEnd) {
    throw new HttpsError(
      "failed-precondition",
      "Check-in closed. " +
      `The ${EVENT_SELF_CHECK_IN_WINDOW_AFTER_MINUTES}-min post-event ` +
      "window ended. " +
      "Contact the host."
    );
  }

  // ── 4. GPS proximity ────────────────────────────────────────────────────

  const eventLat = event.meetingLocation?.latitude ?? event.startingPointLat;
  const eventLng = event.meetingLocation?.longitude ?? event.startingPointLng;

  if (eventLat != null && eventLng != null) {
    if (latitude == null || longitude == null) {
      throw new HttpsError(
        "invalid-argument",
        "Location is required to check in. Please enable GPS and try again."
      );
    }

    const distance = haversineDistanceM(
      latitude, longitude,
      eventLat, eventLng
    );

    if (distance > EVENT_SELF_CHECK_IN_MAX_DISTANCE_METERS) {
      throw new HttpsError(
        "failed-precondition",
        `You must be within ${EVENT_SELF_CHECK_IN_MAX_DISTANCE_METERS} m ` +
        "of the meeting point to check in. You appear to be " +
        `${Math.round(distance)} m away.`
      );
    }
  }
  // If the event has no coordinates, skip GPS check — graceful degradation
  // for events created before this feature was added.

  // ── 5. Mark attendance ──────────────────────────────────────────────────

  const batch = db.batch();
  batch.update(eventRef, {
    checkedInCount: admin.firestore.FieldValue.increment(1),
  });
  batch.set(participationRef, eventParticipationPatch({
    exists: participationSnap.exists,
    eventId,
    clubId: event.clubId,
    uid: userId,
    status: "attended",
  }), {merge: true});
  await batch.commit();

  await recordParticipantSignalFactsBestEffort(db, [
    buildAttendanceSignalFact({
      eventId,
      clubId: event.clubId,
      uid: userId,
      attended: true,
      sourceId: `self_check_in_${eventId}_${userId}`,
    }),
  ]);

  logger.info(
    `[attendance] Self-check-in: user ${userId} → event ${eventId}`
  );

  return {userId, attended: true};
});
