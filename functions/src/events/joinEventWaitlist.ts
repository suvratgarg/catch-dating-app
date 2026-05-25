import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {
  EventDoc,
  UserProfileDoc,
} from "../shared/generated/firestoreAdminTypes";
import {requireAuth} from "../shared/auth";
import {assertNoBlockingRelationshipInTransaction} from "../safety/blocking";
import {appCheckCallableOptions} from "../shared/callableOptions";
import {
  EventIdCallablePayload,
} from "../shared/generated/eventIdCallablePayload";
import {validateEventIdCallablePayload} from
  "../shared/generated/schemaValidators";
import {validateCallableWithAjv} from "../shared/validation";
import {
  participantUids,
  eventParticipationId,
  eventParticipationPatch,
  eventParticipationsByStatusInTransaction,
} from "../shared/relationshipDocuments";
import {checkRateLimit} from "../shared/rateLimit";
import {
  claimUserEventScheduleInTransaction,
  releaseUserEventScheduleInTransaction,
} from "./scheduleConflicts";
import {normalizeEventIdPayload} from "./eventPayloadNormalization";
import {
  cohortIdForUser,
  eventPolicyFromEvent,
  incrementCount,
  decrementCount,
  normalizeInviteCode,
} from "./eventPolicy";
import {assertBookingReadyUserProfile} from "../shared/profileReadiness";
import {assertRunPreferencesReadyForEvent} from
  "../shared/runPreferencesReadiness";

/**
 * Adds a user to an event waitlist after applying the same block boundary as
 * booking. Kept server-side so block state is not exposed through rules.
 */
export const joinEventWaitlist = onCall(appCheckCallableOptions, async (
  request
) => {
  const userId = requireAuth(request);
  const {eventId, inviteCode} = validateCallableWithAjv<EventIdCallablePayload>(
    request,
    validateEventIdCallablePayload,
    normalizeEventIdPayload
  );

  const db = admin.firestore();
  await checkRateLimit(db, userId, "joinEventWaitlist");

  const eventRef = db.collection("events").doc(eventId);
  const participationRef = db
    .collection("eventParticipations")
    .doc(eventParticipationId(eventId, userId));

  await db.runTransaction(async (tx) => {
    const [
      eventSnap,
      userSnap,
      participationSnap,
      activeParticipations,
      privateAccessSnap,
    ] =
      await Promise.all([
        tx.get(eventRef),
        tx.get(db.collection("users").doc(userId)),
        tx.get(participationRef),
        eventParticipationsByStatusInTransaction(tx, db, eventId, [
          "signedUp",
          "attended",
        ]),
        tx.get(db.collection("eventPrivateAccess").doc(eventId)),
      ]);
    if (!eventSnap.exists) {
      throw new HttpsError("not-found", "Event not found.");
    }
    if (!userSnap.exists) {
      throw new HttpsError("not-found", "User profile not found.");
    }

    const event = eventSnap.data() as EventDoc;
    const user = userSnap.data() as UserProfileDoc;
    if (event.status === "cancelled") {
      throw new HttpsError(
        "failed-precondition",
        "This event has been cancelled."
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
        "You are already booked for this event."
      );
    }

    assertBookingReadyUserProfile(user);
    assertRunPreferencesReadyForEvent(user, event);

    if (existingParticipation?.status === "waitlisted") {
      return;
    }

    await assertNoBlockingRelationshipInTransaction(
      tx,
      db,
      userId,
      participantUids(activeParticipations)
    );

    const policy = eventPolicyFromEvent(event);
    const submittedInviteCode = normalizeInviteCode(inviteCode);
    const storedInviteCode = normalizeInviteCode(
      privateAccessSnap.data()?.inviteCode
    );
    const hasValidInvite =
      storedInviteCode !== null &&
      submittedInviteCode !== null &&
      storedInviteCode.toLowerCase() === submittedInviteCode.toLowerCase();
    if (policy.admission.inviteRequired && !hasValidInvite) {
      throw new HttpsError(
        "failed-precondition",
        "Enter a valid invite code to join the waitlist."
      );
    }

    const cohortAtSignup = cohortIdForUser(user);
    await claimUserEventScheduleInTransaction(tx, db, {
      uid: userId,
      eventId,
      clubId: event.clubId,
      startTimeMillis: event.startTime.toMillis(),
      endTimeMillis: event.endTime.toMillis(),
    });

    tx.update(eventRef, {
      waitlistedCount: admin.firestore.FieldValue.increment(1),
      waitlistedCohortCounts: incrementCount(
        event.waitlistedCohortCounts ?? {},
        cohortAtSignup
      ),
    });
    tx.set(participationRef, eventParticipationPatch({
      exists: participationSnap.exists,
      eventId,
      clubId: event.clubId,
      uid: userId,
      status: "waitlisted",
      genderAtSignup: user.gender,
      cohortAtSignup,
    }), {merge: true});
    tx.set(participationRef, policy.admission.manualApprovalRequired ? {
      hostApprovalStatus: "pending",
      hostApprovalDecidedAt: null,
      hostApprovalDecidedBy: null,
    } : {
      hostApprovalStatus: admin.firestore.FieldValue.delete(),
      hostApprovalDecidedAt: admin.firestore.FieldValue.delete(),
      hostApprovalDecidedBy: admin.firestore.FieldValue.delete(),
    }, {merge: true});
  });

  return {waitlisted: true};
});

/**
 * Removes the caller from an event waitlist through the same callable boundary
 * as joining, so clients never update the canonical event document directly.
 */
export const leaveEventWaitlist = onCall(appCheckCallableOptions, async (
  request
) => {
  const userId = requireAuth(request);
  const {eventId} = validateCallableWithAjv<EventIdCallablePayload>(
    request,
    validateEventIdCallablePayload,
    normalizeEventIdPayload
  );

  const db = admin.firestore();
  await checkRateLimit(db, userId, "leaveEventWaitlist");

  const eventRef = db.collection("events").doc(eventId);
  const participationRef = db
    .collection("eventParticipations")
    .doc(eventParticipationId(eventId, userId));

  await db.runTransaction(async (tx) => {
    const [eventSnap, participationSnap] = await Promise.all([
      tx.get(eventRef),
      tx.get(participationRef),
    ]);
    if (!eventSnap.exists) {
      throw new HttpsError("not-found", "Event not found.");
    }

    const event = eventSnap.data() as EventDoc;
    const existingParticipation = participationSnap.exists ?
      participationSnap.data() as {status?: string} :
      null;
    const isWaitlisted = existingParticipation?.status === "waitlisted";

    if (!isWaitlisted) {
      return;
    }

    const cohortAtSignup =
      (existingParticipation as {cohortAtSignup?: string} | null)
        ?.cohortAtSignup;
    const currentWaitlistedCount =
      event.waitlistedCount ?? 1;
    tx.update(eventRef, {
      waitlistedCount: Math.max(0, currentWaitlistedCount - 1),
      ...(cohortAtSignup ?
        {
          waitlistedCohortCounts: decrementCount(
            event.waitlistedCohortCounts ?? {},
            cohortAtSignup
          ),
        } :
        {}),
    });
    releaseUserEventScheduleInTransaction(tx, db, {
      uid: userId,
      eventId,
      startTimeMillis: event.startTime.toMillis(),
      endTimeMillis: event.endTime.toMillis(),
    });
    tx.set(participationRef, eventParticipationPatch({
      exists: participationSnap.exists,
      eventId,
      clubId: event.clubId,
      uid: userId,
      status: "cancelled",
    }), {merge: true});
  });

  return {waitlisted: false};
});
