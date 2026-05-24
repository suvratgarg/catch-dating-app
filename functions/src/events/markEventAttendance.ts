import {CallableRequest, onCall, HttpsError} from
  "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
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
import {
  allowsPushPreference,
  eventCompanionReadyNotificationCopy,
  NotificationPreferenceDoc,
  sendFcmNotification,
} from "../shared/notifications";

interface MarkEventAttendanceDeps {
  firestore: () => FirebaseFirestore.Firestore;
  now: () => Date;
  increment: (value: number) => FirebaseFirestore.FieldValue;
  checkRateLimit: typeof checkRateLimit;
  recordSignalFacts: typeof recordParticipantSignalFactsBestEffort;
  sendNotification: typeof sendFcmNotification;
}

interface EventSuccessPlanLike {
  selectedModuleIds?: unknown;
  contextualOpenersEnabled?: unknown;
}

const CONTEXTUAL_OPENERS_MODULE_ID = "contextual_openers";
const DECOMPOSED_FEEDBACK_MODULE_ID = "decomposed_feedback";

const defaultDeps: MarkEventAttendanceDeps = {
  firestore: () => admin.firestore(),
  now: () => new Date(),
  increment: (value) => admin.firestore.FieldValue.increment(value),
  checkRateLimit,
  recordSignalFacts: recordParticipantSignalFactsBestEffort,
  sendNotification: sendFcmNotification,
};

/**
 * Callable function that toggles a single user's attendance for an event.
 *
 * Must be called by one of the event club's hosts.
 * Check-in window opens 10 minutes before the event's start time.
 *
 * If the user is already attended they are moved back to signed up; otherwise
 * they are marked attended. The eventParticipation edge is the roster source.
 * @param {CallableRequest<unknown>} request Callable request.
 * @param {MarkEventAttendanceDeps} deps Injectable dependencies for tests.
 * @return {Promise<object>} Attendance result.
 */
export async function markEventAttendanceHandler(
  request: CallableRequest<unknown>,
  deps: MarkEventAttendanceDeps = defaultDeps
): Promise<{userId: string; attended: boolean}> {
  const uid = requireAuth(request);
  const {eventId, userId} =
    validateCallableWithAjv<MarkEventAttendanceCallablePayload>(
      request,
      validateMarkEventAttendanceCallablePayload,
      normalizeMarkEventAttendancePayload
    );

  const db = deps.firestore();
  await deps.checkRateLimit(db, uid, "markEventAttendance");

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
  if (deps.now() < checkinWindow) {
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
    checkedInCount: deps.increment(alreadyAttended ? -1 : 1),
  });
  batch.set(participationRef, eventParticipationPatch({
    exists: participationSnap.exists,
    eventId,
    clubId: event.clubId,
    uid: userId,
    status: alreadyAttended ? "signedUp" : "attended",
  }), {merge: true});
  await batch.commit();

  const attended = !alreadyAttended;
  await deps.recordSignalFacts(db, [
    buildAttendanceSignalFact({
      eventId,
      clubId: event.clubId,
      uid: userId,
      attended,
      sourceId: `host_attendance_${eventId}_${userId}_${attended}`,
    }),
  ]);

  if (attended) {
    await notifyCompanionReadyBestEffort({
      db,
      deps,
      eventId,
      userId,
      event,
    });
  }

  return {userId, attended};
}

export const markEventAttendance = onCall(appCheckCallableOptions, async (
  request
) => markEventAttendanceHandler(request));

/**
 * Sends a best-effort background companion deep link after host check-in.
 * @param {object} params Notification parameters.
 * @param {FirebaseFirestore.Firestore} params.db Firestore instance.
 * @param {MarkEventAttendanceDeps} params.deps Injectable dependencies.
 * @param {string} params.eventId Event id.
 * @param {string} params.userId Attendee uid.
 * @param {EventDoc} params.event Event document.
 * @return {Promise<void>}
 */
async function notifyCompanionReadyBestEffort(params: {
  db: FirebaseFirestore.Firestore;
  deps: MarkEventAttendanceDeps;
  eventId: string;
  userId: string;
  event: EventDoc;
}): Promise<void> {
  try {
    const [planSnap, userSnap] = await Promise.all([
      params.db.collection("eventSuccessPlans").doc(params.eventId).get(),
      params.db.collection("users").doc(params.userId).get(),
    ]);
    if (!planSnap.exists) return;

    const plan = planSnap.data() as EventSuccessPlanLike | undefined;
    if (!plan || !companionHasRelevantSurface({
      event: params.event,
      plan,
      now: params.deps.now(),
    })) {
      return;
    }

    const user = userSnap.data() as (
      NotificationPreferenceDoc & {fcmToken?: string}
    ) | undefined;
    if (!user?.fcmToken ||
        !allowsPushPreference(user, "eventStatusUpdates")) {
      return;
    }

    const copy = eventCompanionReadyNotificationCopy(params.event);
    await params.deps.sendNotification({
      token: user.fcmToken,
      title: copy.title,
      body: copy.body,
      type: "eventCompanionReady",
      eventId: params.eventId,
      clubId: params.event.clubId,
    });
  } catch (error) {
    logger.error("Failed to send companion-ready notification", {
      eventId: params.eventId,
      userId: params.userId,
      error,
      reasonMessage: error instanceof Error ? error.message : String(error),
    });
  }
}

/**
 * Returns whether a companion push can land on an active attendee surface.
 * @param {object} params Runtime parameters.
 * @param {EventDoc} params.event Event document.
 * @param {EventSuccessPlanLike} params.plan Event-success plan.
 * @param {Date} params.now Current time.
 * @return {boolean} Whether the companion has relevant attendee content.
 */
function companionHasRelevantSurface(params: {
  event: EventDoc;
  plan: EventSuccessPlanLike;
  now: Date;
}): boolean {
  const eventEndTime = (
    params.event.endTime as FirebaseFirestore.Timestamp
  ).toDate();
  if (eventEndTime > params.now) return true;

  return moduleSelected(
    params.plan.selectedModuleIds,
    DECOMPOSED_FEEDBACK_MODULE_ID
  ) || (
    params.plan.contextualOpenersEnabled === true &&
    moduleSelected(
      params.plan.selectedModuleIds,
      CONTEXTUAL_OPENERS_MODULE_ID
    )
  );
}

/**
 * Checks whether a persisted event-success module id is selected.
 * @param {unknown} selectedModuleIds Persisted selected module ids.
 * @param {string} moduleId Module id to check.
 * @return {boolean} Whether the module is selected.
 */
function moduleSelected(selectedModuleIds: unknown, moduleId: string): boolean {
  return Array.isArray(selectedModuleIds) &&
    selectedModuleIds.includes(moduleId);
}
