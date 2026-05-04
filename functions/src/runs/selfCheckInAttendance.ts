/**
 * Participant self-check-in for run attendance with GPS verification.
 *
 * This removes the single-host dependency from the attendance flow.
 * Previously, only the run club host could call `markRunAttendance`. If
 * the host forgot, every participant got zero swipe windows and the
 * product loop was dead. Now participants can check themselves in.
 *
 * ## Validation gates (all must pass)
 *
 *   1. Caller must be authenticated.
 *   2. Caller must be in the run's `signedUpUserIds`.
 *   3. Check-in window: 30 minutes before start to 30 minutes after start.
 *      Outside this window, only the host can mark attendance.
 *   4. GPS proximity: caller's lat/lng must be within 200 m of the run's
 *      meeting point. Runs without coordinates skip this check (graceful
 *      degradation for existing runs created before this feature).
 *
 * ## Idempotent
 *
 * Calling twice returns `{attended: true}` with no error — the user is
 * already in `attendedUserIds`.
 */

import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import {requireAuth} from "../shared/auth";
import {validateCallable} from "../shared/validation";
import {checkRateLimit} from "../shared/rateLimit";
import {z} from "zod";
import {RunDoc} from "../shared/firestore";
import {appCheckCallableOptions} from "../shared/callableOptions";

const SelfCheckInSchema = z.object({
  runId: z.string(),
  latitude: z.number().optional(),
  longitude: z.number().optional(),
});

// ── Constants ──────────────────────────────────────────────────────────────

/** Max distance (m) from meeting point to allow self check-in. */
const MAX_CHECK_IN_DISTANCE_M = 200;

/** Minutes before the run start that the self-check-in window opens. */
const CHECK_IN_WINDOW_BEFORE_MIN = 30;

/** Minutes after the run start that the self-check-in window closes. */
const CHECK_IN_WINDOW_AFTER_MIN = 30;

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
  const {runId, latitude, longitude} = validateCallable(
    request,
    SelfCheckInSchema
  );

  await checkRateLimit(admin.firestore(), userId, "selfCheckInAttendance");

  const db = admin.firestore();
  const runRef = db.collection("runs").doc(runId);
  const runSnap = await runRef.get();

  if (!runSnap.exists) {
    throw new HttpsError("not-found", "Run not found.");
  }

  const run = runSnap.data() as RunDoc;

  // ── 1. Must be signed up ────────────────────────────────────────────────

  if (!run.signedUpUserIds.includes(userId)) {
    throw new HttpsError(
      "failed-precondition",
      "You must be signed up for this run to check in."
    );
  }

  // ── 2. Idempotent — already checked in ───────────────────────────────────

  if ((run.attendedUserIds ?? []).includes(userId)) {
    return {userId, attended: true};
  }

  // ── 3. Check-in window ──────────────────────────────────────────────────

  const startTime = (run.startTime as FirebaseFirestore.Timestamp).toDate();
  const windowStart = new Date(
    startTime.getTime() - CHECK_IN_WINDOW_BEFORE_MIN * 60 * 1000
  );
  const windowEnd = new Date(
    startTime.getTime() + CHECK_IN_WINDOW_AFTER_MIN * 60 * 1000
  );
  const now = new Date();

  if (now < windowStart) {
    throw new HttpsError(
      "failed-precondition",
      `Check-in opens ${CHECK_IN_WINDOW_BEFORE_MIN} min before the run starts.`
    );
  }

  if (now > windowEnd) {
    throw new HttpsError(
      "failed-precondition",
      "Check-in closed. " +
      `The ${CHECK_IN_WINDOW_AFTER_MIN}-min post-run window ended. ` +
      "Contact the host."
    );
  }

  // ── 4. GPS proximity ────────────────────────────────────────────────────

  const runLat = run.startingPointLat;
  const runLng = run.startingPointLng;

  if (runLat != null && runLng != null) {
    if (latitude == null || longitude == null) {
      throw new HttpsError(
        "invalid-argument",
        "Location is required to check in. Please enable GPS and try again."
      );
    }

    const distance = haversineDistanceM(
      latitude, longitude,
      runLat, runLng
    );

    if (distance > MAX_CHECK_IN_DISTANCE_M) {
      throw new HttpsError(
        "failed-precondition",
        `You must be within ${MAX_CHECK_IN_DISTANCE_M} m of the meeting ` +
        `point to check in. You appear to be ${Math.round(distance)} m away.`
      );
    }
  }
  // If the run has no coordinates, skip GPS check — graceful degradation
  // for runs created before this feature was added.

  // ── 5. Mark attendance ──────────────────────────────────────────────────

  await runRef.update({
    attendedUserIds: admin.firestore.FieldValue.arrayUnion(userId),
  });

  logger.info(
    `[attendance] Self-check-in: user ${userId} → run ${runId}`
  );

  return {userId, attended: true};
});
