import * as admin from "firebase-admin";
import {HttpsError} from "firebase-functions/v2/https";
import {
  CrossPathsPairHoldDocument,
  EventDocument,
  UserProfileDocument,
} from "../shared/generated/firestoreAdminTypes";
import {crossPathsEventPlanId} from "../crossPaths/identifiers";
import {assertNoBlockingRelationshipInTransaction} from "../safety/blocking";
import {computeAge} from "../shared/dates";
import {assertBookingReadyUserProfile} from "../shared/profileReadiness";
import {assertRunPreferencesReadyForEvent} from
  "../shared/runPreferencesReadiness";
import {requireDoc} from "../shared/validation";
import {
  participantUids,
  eventParticipationId,
  eventParticipationPatch,
  eventParticipationsByStatusInTransaction,
} from "../shared/relationshipDocuments";
import {
  activityNotificationId,
  eventActivityNotificationCopy,
  setActivityNotificationInTransaction,
} from "../shared/notifications";
import {claimUserEventScheduleInTransaction} from "./scheduleConflicts";
import {
  assertPolicyAllowsSignup,
  cohortIdForUser,
  decrementCount,
  eventPolicyFromEvent,
  incrementCount,
  rosterFromEvent,
  rosterWithReservedWaitlistOffersInTransaction,
} from "./eventPolicy";
import {eventDiscoveryProjection} from "./eventDiscoveryProjection";
import {
  incrementInviteLinkCounterInTransaction,
  inviteAttributionWriteFields,
  InviteAttribution,
} from "./inviteLinks";

/**
 * Core sign-up business logic — shared by verifyRazorpayPayment (paid events)
 * and signUpForFreeEvent (free events).
 *
 * Uses a transaction to atomically:
 *   1. Read the event and the user's profile.
 *   2. Enforce eligibility constraints (age range, gender caps).
 *   3. Check overall capacity.
 *   4. Write the user's eventParticipation edge.
 *   5. Update aggregate count projections on the event.
 *   6. Preserve invite-only validation made by the caller.
 *
 * Enforces blocks against signed-up and attended participation edges inside
 * this transaction. The error remains generic so callers cannot infer
 * who blocked whom.
 *
 * Idempotent — calling it twice for the same user/event is safe.
 * @param {FirebaseFirestore.Firestore} db Firestore instance.
 * @param {string} eventId Event to sign the user up for.
 * @param {string} userId User being signed up.
 * @param {string=} paymentId Optional payment document linked to the signup.
 * @param {object=} options Admission context already verified by caller.
 * @return {Promise<void>} Resolves when the transaction completes.
 */
export async function signUpUserForEvent(
  db: FirebaseFirestore.Firestore,
  eventId: string,
  userId: string,
  paymentId?: string,
  options: {
    hasValidInvite?: boolean;
    hasHostApproval?: boolean;
    inviteAttribution?: InviteAttribution | null;
    crossPathsPairHoldId?: string | null;
  } = {}
): Promise<void> {
  const eventRef = db.collection("events").doc(eventId);
  const userRef = db.collection("users").doc(userId);
  const participationRef = db
    .collection("eventParticipations")
    .doc(eventParticipationId(eventId, userId));
  const pairHoldRef = options.crossPathsPairHoldId ?
    db.collection("crossPathsPairHolds").doc(options.crossPathsPairHoldId) :
    null;

  await db.runTransaction(async (tx) => {
    const [
      eventSnap,
      userSnap,
      participationSnap,
      activeParticipations,
    ] = await Promise.all([
      tx.get(eventRef),
      tx.get(userRef),
      tx.get(participationRef),
      eventParticipationsByStatusInTransaction(tx, db, eventId, [
        "signedUp",
        "attended",
      ]),
    ]);

    if (!eventSnap.exists) {
      throw new HttpsError("not-found", "Event not found.");
    }
    if (!userSnap.exists) {
      throw new HttpsError("not-found", "User profile not found.");
    }

    const event = requireDoc<EventDocument>(

      eventSnap,

      "EventDocument"

    );
    const pairHoldSnap = pairHoldRef ? await tx.get(pairHoldRef) : null;
    const pairHold = pairHoldSnap?.exists ?
      requireDoc<CrossPathsPairHoldDocument>(
        pairHoldSnap,
        "CrossPathsPairHoldDocument (booking)"
      ) : null;
    if (options.crossPathsPairHoldId && !pairHold) {
      throw new HttpsError(
        "failed-precondition",
        "This Cross Paths hold is no longer available."
      );
    }
    if (event.status === "cancelled") {
      throw new HttpsError(
        "failed-precondition",
        "This event has been cancelled."
      );
    }
    const user = requireDoc<UserProfileDocument>(
      userSnap,
      "UserProfileDocument"
    );
    assertBookingReadyUserProfile(user);
    assertRunPreferencesReadyForEvent(user, event);
    const existingParticipation = participationSnap.exists ?
      participationSnap.data() as {
        status?: string;
        inviteLinkId?: string | null;
        inviteSource?: string | null;
      } :
      null;

    if (
      existingParticipation?.status === "signedUp" ||
      existingParticipation?.status === "attended"
    ) {
      if (!pairHold) return;
      if (
        pairHold.eventId === eventId &&
        pairHold.requesterUid === userId &&
        pairHold.status === "confirmed" &&
        pairHold.requesterBookingStatus === "confirmed"
      ) {
        return;
      }
      throw new HttpsError(
        "failed-precondition",
        "This Cross Paths hold does not match the confirmed booking."
      );
    }

    let pairConversationId: string | null = null;
    let pairPlanRef: FirebaseFirestore.DocumentReference | null = null;

    if (pairHold) {
      if (
        pairHold.eventId !== eventId ||
        pairHold.requesterUid !== userId ||
        pairHold.status !== "active" ||
        pairHold.requesterBookingStatus !== "held" ||
        pairHold.expiresAt.toMillis() <= Date.now() ||
        !activeParticipations.some((row) =>
          row.data.uid === pairHold.attendeeUid &&
          (row.data.status === "signedUp" || row.data.status === "attended"))
      ) {
        throw new HttpsError(
          "failed-precondition",
          "This Cross Paths hold is no longer available."
        );
      }
      const invitationSnap = await tx.get(
        db.collection("crossPathsInvitations").doc(pairHold.invitationId)
      );
      if (
        !invitationSnap.exists ||
        invitationSnap.data()?.status !== "accepted" ||
        invitationSnap.data()?.pairHoldId !== pairHoldSnap?.id
      ) {
        throw new HttpsError(
          "failed-precondition",
          "This Cross Paths hold is no longer available."
        );
      }
      pairConversationId = crossPathsEventPlanId(
        eventId,
        pairHold.requesterUid,
        pairHold.attendeeUid
      );
      pairPlanRef = db.collection("matches").doc(pairConversationId);
      const pairPlanSnap = await tx.get(pairPlanRef);
      if (pairPlanSnap.exists) {
        throw new HttpsError(
          "failed-precondition",
          "This Cross Paths event plan already exists."
        );
      }
    }

    const activeParticipantIds = participantUids(activeParticipations);
    await assertNoBlockingRelationshipInTransaction(
      tx,
      db,
      userId,
      activeParticipantIds
    );

    const constraints = event.constraints ?? {minAge: 0, maxAge: 99};

    // Age check.
    if (constraints.minAge > 0 || constraints.maxAge < 99) {
      const age = computeAge(
        (user.dateOfBirth as FirebaseFirestore.Timestamp).toDate()
      );
      if (age < constraints.minAge) {
        throw new HttpsError(
          "failed-precondition",
          `You must be at least ${constraints.minAge} ` +
            "years old to join this event."
        );
      }
      if (age > constraints.maxAge) {
        throw new HttpsError(
          "failed-precondition",
          `You must be ${constraints.maxAge} ` +
            "or younger to join this event."
        );
      }
    }

    const gender = user.gender;
    const policy = eventPolicyFromEvent(event);
    const cohortId = cohortIdForUser(user);
    const signedUpCount = activeParticipations
      .filter((participation) => participation.data.status === "signedUp")
      .length;
    const currentBookedCount = event.bookedCount ?? signedUpCount;
    const baseRoster = {
      ...rosterFromEvent(event),
      totalBooked: currentBookedCount +
        Math.max(0, event.crossPathsPairHeldCount ?? 0),
    };
    const reservedRoster = await rosterWithReservedWaitlistOffersInTransaction(
      tx,
      db,
      eventId,
      baseRoster,
      {excludeUid: userId}
    );
    const admissionRoster = pairHold ? {
      ...reservedRoster,
      totalBooked: Math.max(0, reservedRoster.totalBooked - 1),
      bookedCountsByCohort: decrementCount(
        reservedRoster.bookedCountsByCohort,
        pairHold.requesterCohortId
      ),
      crossPathsPairHeldCount: Math.max(
        0,
        (reservedRoster.crossPathsPairHeldCount ?? 0) - 1
      ),
    } : reservedRoster;
    assertPolicyAllowsSignup({
      policy,
      cohortId,
      roster: admissionRoster,
      hasValidInvite: options.hasValidInvite,
      hasHostApproval: options.hasHostApproval,
      admissionMode: pairHold ? "crossPathsPair" : "general",
    });

    await claimUserEventScheduleInTransaction(tx, db, {
      uid: userId,
      eventId,
      clubId: event.clubId,

      organizerId: event.organizerId ?? event.clubId,
      startTimeMillis: event.startTime.toMillis(),
      endTimeMillis: event.endTime.toMillis(),
    });

    const wasWaitlisted = existingParticipation?.status === "waitlisted";
    const nextBookedCount = currentBookedCount + 1;
    const notificationType = wasWaitlisted ?
      "waitlistPromotion" :
      "eventSignup";
    const notificationCopy =
      eventActivityNotificationCopy(notificationType, event);
    const eventUpdate: Record<string, unknown> = {
      bookedCount: admin.firestore.FieldValue.increment(1),
      [`genderCounts.${gender}`]: admin.firestore.FieldValue.increment(1),
      cohortCounts: incrementCount(event.cohortCounts ?? {}, cohortId),
      ...eventDiscoveryProjection({
        event,
        clubLocation: event.discoveryCityName,
        clubLocationMarketId: event.discoveryMarketId,
        bookedCount: nextBookedCount,
      }),
    };
    if (wasWaitlisted) {
      eventUpdate.waitlistedCount = admin.firestore.FieldValue.increment(-1);
      eventUpdate.waitlistedCohortCounts = decrementCount(
        event.waitlistedCohortCounts ?? {},
        cohortId
      );
    }
    if (pairHold) {
      eventUpdate.crossPathsPairHeldCount =
        admin.firestore.FieldValue.increment(-1);
      eventUpdate.crossPathsPairConfirmedCount =
        admin.firestore.FieldValue.increment(1);
      eventUpdate.crossPathsPairHeldCohortCounts = decrementCount(
        event.crossPathsPairHeldCohortCounts ?? {},
        pairHold.requesterCohortId
      );
    }

    tx.update(eventRef, eventUpdate);
    const attribution = attributionForSignup({
      existingParticipation,
      candidate: options.inviteAttribution,
    });
    tx.set(participationRef, {
      ...eventParticipationPatch({
        exists: participationSnap.exists,
        eventId,
        clubId: event.clubId,

        organizerId: event.organizerId ?? event.clubId,
        uid: userId,
        status: "signedUp",
        genderAtSignup: gender,
        cohortAtSignup: cohortId,
        paymentId,
      }),
      ...inviteAttributionWriteFields(attribution.write),
    }, {merge: true});
    incrementInviteLinkCounterInTransaction({
      tx,
      db,
      attribution: attribution.counter,
      field: "confirmedCount",
    });
    setActivityNotificationInTransaction(tx, db, {
      id: activityNotificationId(notificationType, eventId),
      uid: userId,
      type: notificationType,
      title: notificationCopy.title,
      body: notificationCopy.body,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      eventId,
      clubId: event.clubId,

      organizerId: event.organizerId ?? event.clubId,
    });
    if (
      pairHold &&
      pairHoldRef &&
      pairPlanRef &&
      pairConversationId
    ) {
      const now = admin.firestore.Timestamp.now();
      tx.create(pairPlanRef, {
        user1Id: pairHold.requesterUid,
        user2Id: pairHold.attendeeUid,
        eventIds: [eventId],
        createdAt: now,
        lastMessageAt: null,
        lastMessagePreview: null,
        lastMessageSenderId: null,
        unreadCounts: {
          [pairHold.requesterUid]: 0,
          [pairHold.attendeeUid]: 0,
        },
        status: "active",
        blockedBy: null,
        blockedAt: null,
        participantIds: [pairHold.requesterUid, pairHold.attendeeUid],
        conversationType: "crossPathsEventPlan",
        crossPathsInvitationId: pairHold.invitationId,
        eventPlanExpiresAt: admin.firestore.Timestamp.fromMillis(
          event.endTime.toMillis() + 24 * 60 * 60 * 1000
        ),
        closedAt: null,
      });
      tx.update(pairHoldRef, {
        status: "confirmed",
        requesterBookingStatus: "confirmed",
        updatedAt: now,
        confirmedAt: now,
        paymentId: paymentId ?? null,
        conversationId: pairConversationId,
      });
      tx.update(
        db.collection("crossPathsInvitations").doc(pairHold.invitationId),
        {updatedAt: now, conversationId: pairConversationId}
      );
      setActivityNotificationInTransaction(tx, db, {
        id: activityNotificationId(
          "crossPathsInvitationAccepted",
          pairHold.invitationId
        ),
        uid: pairHold.attendeeUid,
        type: "crossPathsInvitationAccepted",
        title: "Your event plan is ready",
        body: "Both spots are confirmed. Open your Cross Paths event plan.",
        createdAt: now,
        eventId,
        matchId: pairConversationId,
        invitationId: pairHold.invitationId,
        actorUid: pairHold.requesterUid,
      });
    }
  });
}

/**
 * Chooses whether a signup should write or count invite attribution.
 * @param {object} params Existing participation and candidate attribution.
 * @return {object} Attribution write fields and counter attribution.
 */
function attributionForSignup(params: {
  existingParticipation: {
    status?: string;
    inviteLinkId?: string | null;
    inviteSource?: string | null;
  } | null;
  candidate: InviteAttribution | null | undefined;
}): {
  write: InviteAttribution | null;
  counter: InviteAttribution | null;
} {
  const existingLinkId = params.existingParticipation?.inviteLinkId;
  const existingSource = params.existingParticipation?.inviteSource;
  if (typeof existingLinkId === "string" && existingLinkId.length > 0) {
    const existing = {
      inviteLinkId: existingLinkId,
      inviteSource: typeof existingSource === "string" &&
        existingSource.length > 0 ? existingSource : null,
    };
    const status = params.existingParticipation?.status;
    if (status !== "cancelled" && status !== "deleted") {
      return {write: null, counter: existing};
    }
  }
  if (!params.candidate) return {write: null, counter: null};
  const status = params.existingParticipation?.status;
  if (
    typeof existingLinkId === "string" &&
    existingLinkId.length > 0 &&
    status !== "cancelled" &&
    status !== "deleted"
  ) {
    return {write: null, counter: null};
  }
  return {write: params.candidate, counter: params.candidate};
}
