import {onCall, HttpsError, CallableRequest} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import type {
  EventDocument,
  PaymentDocument,
  UserProfileDocument,
} from "../shared/generated/firestoreAdminTypes";
import {hasBlockingRelationshipInTransaction} from "../safety/blocking";
import {requireAuth} from "../shared/auth";
import type {
  EventIdCallablePayload,
} from "../shared/generated/eventIdCallablePayload";
import {
  validateEventIdCallablePayload,
} from "../shared/generated/validators/eventIdInput";
import {validateCallableWithAjv, requireDoc} from "../shared/validation";
import {
  appCheckCallableOptionsWithSecrets,
} from "../shared/callableOptions";
import {
  createRazorpayClient,
  razorpayKeySecret,
} from "../payments/razorpay";
import {
  participantUids,
  eventParticipationId,
  eventWaitlistOfferId,
  eventParticipationPatch,
  eventParticipationsByStatusInTransaction,
  waitlistedEventParticipationsInTransaction,
} from "../shared/relationshipDocuments";
import {checkRateLimit} from "../shared/rateLimit";
import {
  allowsPushPreference,
  activityNotificationId,
  eventActivityNotificationCopy,
  sendFcmNotification,
  setActivityNotificationInTransaction,
} from "../shared/notifications";
import {
  prepareUserEventScheduleClaimInTransaction,
  releaseUserEventScheduleInTransaction,
} from "./scheduleConflicts";
import {readSeatMigrationWriterFence} from "./seatMigrationPaged";
import {FirestoreSeatIdentityAuthority} from "./seatIdentityAuthority";
import {applyFirestoreSeatBatch, FirestoreSeatBatchPreparation,
  FirestoreSeatTransaction, prepareFirestoreSeatBatch} from
  "./seatAuthority/firestoreAdapter";
import {normalizeEventIdPayload} from "./eventPayloadNormalization";
import {
  assertPolicyAllowsSignup,
  cohortIdForUser,
  decrementCount,
  eventPolicyFromEvent,
  incrementCount,
  quoteAttendeeCancellation,
  quotePriceInPaise,
  rosterFromEvent,
} from "./eventPolicy";
import {eventDiscoveryProjection} from "./eventDiscoveryProjection";
import {requireEventTimeRange} from "./configuredEvent";
import {isEventPubliclyAccessible} from "./eventPublicationAccess";

interface PromotionPush {
  token: string;
  title: string;
  body: string;
  eventId: string;
  clubId: string;
  organizerId?: string;
}

interface CancelEventSignUpDeps {
  firestore: () => FirebaseFirestore.Firestore;
  checkRateLimit: (
    db: FirebaseFirestore.Firestore,
    uid: string,
    action: string
  ) => Promise<void>;
  nowMillis: () => number;
  refundPayment: (paymentId: string, amountInPaise: number) => Promise<void>;
  sendNotification: (push: PromotionPush) => Promise<void>;
}

interface RefundPlan {
  paymentId: string;
  amountInPaise: number;
  paymentRef: FirebaseFirestore.DocumentReference;
}

const defaultDeps: CancelEventSignUpDeps = {
  firestore: () => admin.firestore(),
  checkRateLimit,
  nowMillis: () => Date.now(),
  refundPayment: async (paymentId, amountInPaise) => {
    const razorpay = createRazorpayClient();
    await razorpay.payments.refund(paymentId, {amount: amountInPaise});
  },
  sendNotification: async (push) => {
    await sendFcmNotification({
      token: push.token,
      title: push.title,
      body: push.body,
      type: "waitlistPromotion",
      eventId: push.eventId,
      clubId: push.clubId,
    });
  },
};

/**
 * Atomically cancels a user's sign-up for an event.
 *
 * - Marks the user's eventParticipation edge cancelled.
 * - Promotes the first eligible waitlist user into the freed spot.
 * - Applies the configured cancellation policy to any completed payment.
 * - Idempotent — calling it when the user is already not signed up is a
 *   no-op.
 * @param {CallableRequest<unknown>} request Callable request.
 * @param {CancelEventSignUpDeps} deps Injectable dependencies.
 * @return {Promise<{cancelled: boolean}>} Operation result.
 */
export async function cancelEventSignUpHandler(
  request: CallableRequest<unknown>,
  deps: CancelEventSignUpDeps = defaultDeps
): Promise<{cancelled: boolean}> {
  const userId = requireAuth(request);
  const {eventId} = validateCallableWithAjv<EventIdCallablePayload>(
    request,
    validateEventIdCallablePayload,
    normalizeEventIdPayload
  );

  const db = deps.firestore();
  await deps.checkRateLimit(db, userId, "cancelEventSignUp");

  const eventRef = db.collection("events").doc(eventId);
  const userRef = db.collection("users").doc(userId);
  const participationRef = db
    .collection("eventParticipations")
    .doc(eventParticipationId(eventId, userId));

  // Look up a completed payment for this user + event before entering the
  // transaction so we can issue a refund afterwards.
  const paymentQuery = await db
    .collection("payments")
    .where("userId", "==", userId)
    .where("eventId", "==", eventId)
    .where("status", "==", "completed")
    .limit(1)
    .get();
  const paymentDoc = paymentQuery.empty ? null : paymentQuery.docs[0];
  const promotionPushes: PromotionPush[] = [];
  const refundPlan: {value: RefundPlan | null} = {value: null};

  await db.runTransaction(async (tx) => {
    const [
      eventSnap,
      userSnap,
      participationSnap,
      activeParticipations,
      waitlistedParticipations,
    ] = await Promise.all([
      tx.get(eventRef),
      tx.get(userRef),
      tx.get(participationRef),
      eventParticipationsByStatusInTransaction(tx, db, eventId, [
        "signedUp",
        "attended",
      ]),
      waitlistedEventParticipationsInTransaction(tx, db, eventId),
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
    const seatMode = await readSeatMigrationWriterFence({db, tx, eventId});
    const user = requireDoc<UserProfileDocument>(
      userSnap,
      "UserProfileDocument"
    );
    const participation = participationSnap.exists ?
        participationSnap.data() as {status?: string; cohortAtSignup?: string} :
      null;

    // Idempotent — already not signed up.
    if (participation?.status !== "signedUp") {
      return;
    }
    const scheduledEvent = requireEventTimeRange(event);

    const cancellerGender = user.gender;
    const cancellerCohort =
        participation?.cohortAtSignup ?? cohortIdForUser(user);
    const policy = eventPolicyFromEvent(event);
    if (paymentDoc) {
      const payment = requireDoc<PaymentDocument>(
        paymentDoc,
        "PaymentDocument"
      );
      const cancellationQuote = quoteAttendeeCancellation({
        policy,
        paidAmountInPaise: payment.amount,
        startTimeMillis: event.startTime.toMillis(),
        nowMillis: deps.nowMillis(),
      });
      refundPlan.value = cancellationQuote.refundAmountInPaise > 0 ? {
        paymentId: payment.paymentId,
        amountInPaise: cancellationQuote.refundAmountInPaise,
        paymentRef: paymentDoc.ref,
      } : null;
    }

    const seatTransaction = seatMode === "ready" ?
      new FirestoreSeatTransaction(db, tx) : null;
    const seatLedger = seatTransaction ?
      await seatTransaction.ledger(eventId) : null;
    const currentSignedUpCount = seatLedger?.occupied ??
      event.bookedCount ??
        activeParticipations.filter((edge) =>
          edge.data.status === "signedUp").length;
    const currentWaitlistedCount = event.waitlistedCount ??
        waitlistedParticipations.length;
    let nextBookedCount = Math.max(0, currentSignedUpCount - 1);
    let nextWaitlistedCount = currentWaitlistedCount;
    const newGenderCounts = {...event.genderCounts};
    newGenderCounts[cancellerGender] =
        Math.max(0, (newGenderCounts[cancellerGender] ?? 1) - 1);
    let newCohortCounts = decrementCount(
      event.cohortCounts ?? {},
      cancellerCohort
    );
    let newWaitlistedCohortCounts = {
      ...(event.waitlistedCohortCounts ?? {}),
    };
    let promotedParticipationRef:
        FirebaseFirestore.DocumentReference | null = null;
    let promotedParticipationPatch: Record<string, unknown> | null = null;
    let promotedOfferRef:
        FirebaseFirestore.DocumentReference | null = null;
    let promotedOfferPatch: Record<string, unknown> | null = null;
    let promotedNotification:
        {uid: string; token?: string; title: string; body: string} | null =
        null;
    let promotedUid: string | null = null;
    let promotedScheduleClaim: {apply: () => void} | null = null;

    // Promote the first waitlist user who passes gender-cap and block checks.
    const activePeerIds = participantUids(activeParticipations, userId);
    for (const waitlistedParticipation of isEventPubliclyAccessible(event) ?
      waitlistedParticipations : []) {
      const waitlistUserId = waitlistedParticipation.data.uid;
      const waitlistUserSnap =
          await tx.get(db.collection("users").doc(waitlistUserId));
      if (!waitlistUserSnap.exists) continue;

      if (await hasBlockingRelationshipInTransaction(
        tx,
        db,
        waitlistUserId,
        activePeerIds
      )) {
        continue;
      }

      const waitlistUser = requireDoc<UserProfileDocument>(
        waitlistUserSnap, "UserProfileDocument (waitlist)"
      );
      const wGender = waitlistUser.gender;
      const wCohort = waitlistedParticipation.data.cohortAtSignup ??
          cohortIdForUser(waitlistUser);
      const nextRoster = {
        ...rosterFromEvent({...event, cohortCounts: newCohortCounts}),
        totalBooked: nextBookedCount,
      };

      try {
        assertPolicyAllowsSignup({
          policy,
          cohortId: wCohort,
          roster: nextRoster,
        });
        const quotedAmountInPaise = quotePriceInPaise({
          policy,
          cohortId: wCohort,
          roster: nextRoster,
        });
        if (quotedAmountInPaise > 0) {
          continue;
        }
        promotedScheduleClaim =
          await prepareUserEventScheduleClaimInTransaction(tx, db, {
          uid: waitlistUserId,
          eventId,
          clubId: event.clubId,

          organizerId: event.organizerId ?? event.clubId,
          startTimeMillis: event.startTime.toMillis(),
          endTimeMillis: scheduledEvent.endTime.toMillis(),
        });
      } catch (error) {
        if (error instanceof HttpsError &&
              error.code === "failed-precondition") {
          continue;
        }
        throw error;
      }

      // Promote this user.
      promotedUid = waitlistUserId;
      const promotedOfferId = eventWaitlistOfferId(eventId, waitlistUserId);
      const promotionTimestamp =
          admin.firestore.Timestamp.fromMillis(deps.nowMillis());
      nextBookedCount += 1;
      nextWaitlistedCount = Math.max(0, nextWaitlistedCount - 1);
      newGenderCounts[wGender] = (newGenderCounts[wGender] ?? 0) + 1;
      newCohortCounts = incrementCount(newCohortCounts, wCohort);
      newWaitlistedCohortCounts = decrementCount(
        newWaitlistedCohortCounts,
        wCohort
      );
      promotedParticipationRef = waitlistedParticipation.ref;
      promotedParticipationPatch = eventParticipationPatch({
        exists: true,
        eventId,
        clubId: event.clubId,

        organizerId: event.organizerId ?? event.clubId,
        uid: waitlistUserId,
        status: "signedUp",
        genderAtSignup: wGender,
        cohortAtSignup: wCohort,
      });
      promotedParticipationPatch.waitlistOfferStatus = "accepted";
      promotedParticipationPatch.waitlistOfferedAt = promotionTimestamp;
      promotedParticipationPatch.waitlistOfferExpiresAt = promotionTimestamp;
      promotedParticipationPatch.waitlistOfferAcceptedAt = promotionTimestamp;
      promotedParticipationPatch.waitlistOfferId = promotedOfferId;
      promotedOfferRef = db
        .collection("eventWaitlistOffers")
        .doc(promotedOfferId);
      promotedOfferPatch = {
        eventId,
        clubId: event.clubId,

        organizerId: event.organizerId ?? event.clubId,
        uid: waitlistUserId,
        cohortAtOffer: wCohort,
        status: "accepted",
        source: "cancellation",
        offeredBy: null,
        offeredAt: promotionTimestamp,
        expiresAt: promotionTimestamp,
        decidedAt: promotionTimestamp,
        expiringNotifiedAt: null,
        inviteLinkId: typeof (
          waitlistedParticipation.data as Record<string, unknown>
        ).inviteLinkId === "string" ?
          (waitlistedParticipation.data as Record<string, unknown>)
            .inviteLinkId :
          null,
        createdAt: promotionTimestamp,
        updatedAt: promotionTimestamp,
      };
      const notificationCopy = eventActivityNotificationCopy(
        "waitlistPromotion",
        event
      );
      promotedNotification = {
        uid: waitlistUserId,
        token: allowsPushPreference(waitlistUser, "eventStatusUpdates") ?
          waitlistUser.fcmToken :
          undefined,
        title: notificationCopy.title,
        body: notificationCopy.body,
      };
      break;
    }

    let seatPreparation: FirestoreSeatBatchPreparation | null = null;
    if (seatMode === "ready") {
      if (!seatLedger || !seatTransaction) {
        throw new HttpsError("failed-precondition",
          "Event seat authority is unavailable.");
      }
      const authority = new FirestoreSeatIdentityAuthority();
      const organizerId = event.organizerId ?? event.clubId;
      const uids = promotedUid ? [userId, promotedUid] : [userId];
      const identities = await Promise.all(uids.map((uid) =>
        authority.resolve({db, tx, eventId, organizerId,
          subject: {kind: "verifiedUid", uid}})));
      if (identities.some((identity) => identity === null)) {
        throw new HttpsError("failed-precondition",
          "Verified seat identity is unavailable.");
      }
      const reservations = await Promise.all(identities.map((identity) =>
        seatTransaction.reservation(eventId, identity!.key)));
      const releaseRevision = reservations[0]?.revision ?? 0;
      seatPreparation = await prepareFirestoreSeatBatch({db, tx,
        identityAuthority: authority,
        command: {eventId,
          batchId: `cancel_${userId}_${releaseRevision}`,
          expectedLedgerRevision: seatLedger.revision,
          expectedCapacityRevision: seatLedger.capacityRevision,
          expectedMigrationRevision: seatLedger.migrationRevision,
          nowMillis: deps.nowMillis(),
          operations: uids.map((uid, index) => ({
            subject: {kind: "verifiedUid" as const, uid},
            operation: index === 0 ? "release" as const : "reserve" as const,
            requestId: index === 0 ?
              `cancel_${uid}_${releaseRevision}` :
              `promote_${uid}_${reservations[index]?.revision ?? 0}`,
            expectedReservationRevision: reservations[index]?.revision ?? 0,
          }))}});
    }

    if (seatPreparation) applyFirestoreSeatBatch(seatPreparation);
    promotedScheduleClaim?.apply();
    tx.update(eventRef, {
      bookedCount: nextBookedCount,
      waitlistedCount: nextWaitlistedCount,
      genderCounts: newGenderCounts,
      cohortCounts: newCohortCounts,
      waitlistedCohortCounts: newWaitlistedCohortCounts,
      ...eventDiscoveryProjection({
        event,
        clubLocation: event.discoveryCityName,
        clubLocationMarketId: event.discoveryMarketId,
        bookedCount: nextBookedCount,
      }),
    });
    tx.set(participationRef, eventParticipationPatch({
      exists: participationSnap.exists,
      eventId,
      clubId: event.clubId,

      organizerId: event.organizerId ?? event.clubId,
      uid: userId,
      status: "cancelled",
      genderAtSignup: cancellerGender,
      cohortAtSignup: cancellerCohort,
    }), {merge: true});
    releaseUserEventScheduleInTransaction(tx, db, {
      uid: userId,
      eventId,
      startTimeMillis: event.startTime.toMillis(),
      endTimeMillis: scheduledEvent.endTime.toMillis(),
    });
    if (promotedParticipationRef && promotedParticipationPatch) {
      tx.set(promotedParticipationRef, promotedParticipationPatch, {
        merge: true,
      });
    }
    if (promotedOfferRef && promotedOfferPatch) {
      tx.set(promotedOfferRef, promotedOfferPatch, {merge: true});
    }
    if (promotedNotification) {
      setActivityNotificationInTransaction(tx, db, {
        id: activityNotificationId("waitlistPromotion", eventId),
        uid: promotedNotification.uid,
        type: "waitlistPromotion",
        title: promotedNotification.title,
        body: promotedNotification.body,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        eventId,
        clubId: event.clubId,

        organizerId: event.organizerId ?? event.clubId,
      });
      if (promotedNotification.token) {
        promotionPushes.push({
          token: promotedNotification.token,
          title: promotedNotification.title,
          body: promotedNotification.body,
          eventId,
          clubId: event.clubId,

          organizerId: event.organizerId ?? event.clubId,
        });
      }
    }
  });

  for (const promotionPush of promotionPushes) {
    try {
      await deps.sendNotification(promotionPush);
    } catch (notificationError) {
      // The cancellation and waitlist promotion are already committed. Push
      // delivery is best-effort and must not prevent the independent refund
      // side effect below from running.
      logger.error("Failed to send waitlist promotion notification", {
        eventId,
        clubId: promotionPush.clubId,
        error: notificationError,
        reasonMessage: notificationError instanceof Error ?
          notificationError.message :
          String(notificationError),
      });
    }
  }

  // Issue a refund outside the transaction when the selected policy allows it.
  if (refundPlan.value) {
    try {
      await deps.refundPayment(
        refundPlan.value.paymentId,
        refundPlan.value.amountInPaise
      );
      await refundPlan.value.paymentRef.update({status: "refunded"});
    } catch (refundError) {
      // Log and continue — cancellation itself succeeded; refund can be
      // retried manually via the Razorpay dashboard.
      logger.error(
        "Refund failed for payment",
        refundPlan.value.paymentId,
        refundError
      );
    }
  }
  return {cancelled: true};
}

export const cancelEventSignUp = onCall(
  appCheckCallableOptionsWithSecrets([razorpayKeySecret]),
  async (request) => cancelEventSignUpHandler(request)
);
