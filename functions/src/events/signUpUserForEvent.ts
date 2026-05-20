import * as admin from "firebase-admin";
import {HttpsError} from "firebase-functions/v2/https";
import {UserProfileDoc, EventDoc} from "../shared/firestore";
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
} from "./eventPolicy";

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
  options: {hasValidInvite?: boolean} = {}
): Promise<void> {
  const eventRef = db.collection("events").doc(eventId);
  const userRef = db.collection("users").doc(userId);
  const participationRef = db
    .collection("eventParticipations")
    .doc(eventParticipationId(eventId, userId));

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

    const event = requireDoc<EventDoc>(eventSnap, "EventDoc");
    if (event.status === "cancelled") {
      throw new HttpsError(
        "failed-precondition",
        "This event has been cancelled."
      );
    }
    const user = requireDoc<UserProfileDoc>(userSnap, "UserProfileDoc");
    assertBookingReadyUserProfile(user);
    assertRunPreferencesReadyForEvent(user, event);
    const existingParticipation = participationSnap.exists ?
      participationSnap.data() as {status?: string} :
      null;

    // Idempotent — user already signed up.
    if (
      existingParticipation?.status === "signedUp" ||
      existingParticipation?.status === "attended"
    ) {
      return;
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
    assertPolicyAllowsSignup({
      policy,
      cohortId,
      roster: {...rosterFromEvent(event), totalBooked: currentBookedCount},
      hasValidInvite: options.hasValidInvite,
    });

    await claimUserEventScheduleInTransaction(tx, db, {
      uid: userId,
      eventId,
      clubId: event.clubId,
      startTimeMillis: event.startTime.toMillis(),
      endTimeMillis: event.endTime.toMillis(),
    });

    const wasWaitlisted = existingParticipation?.status === "waitlisted";
    const notificationType = wasWaitlisted ?
      "waitlistPromotion" :
      "eventSignup";
    const notificationCopy =
      eventActivityNotificationCopy(notificationType, event);
    const eventUpdate: Record<string, unknown> = {
      bookedCount: admin.firestore.FieldValue.increment(1),
      [`genderCounts.${gender}`]: admin.firestore.FieldValue.increment(1),
      cohortCounts: incrementCount(event.cohortCounts ?? {}, cohortId),
    };
    if (wasWaitlisted) {
      eventUpdate.waitlistedCount = admin.firestore.FieldValue.increment(-1);
      eventUpdate.waitlistedCohortCounts = decrementCount(
        event.waitlistedCohortCounts ?? {},
        cohortId
      );
    }

    tx.update(eventRef, eventUpdate);
    tx.set(participationRef, eventParticipationPatch({
      exists: participationSnap.exists,
      eventId,
      clubId: event.clubId,
      uid: userId,
      status: "signedUp",
      genderAtSignup: gender,
      cohortAtSignup: cohortId,
      paymentId,
    }), {merge: true});
    setActivityNotificationInTransaction(tx, db, {
      id: activityNotificationId(notificationType, eventId),
      uid: userId,
      type: notificationType,
      title: notificationCopy.title,
      body: notificationCopy.body,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      eventId,
      clubId: event.clubId,
    });
  });
}
