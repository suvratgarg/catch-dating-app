import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import {UserProfileDoc, PaymentDoc, RunDoc} from "../shared/firestore";
import {hasBlockingRelationshipInTransaction} from "../safety/blocking";
import {requireAuth} from "../shared/auth";
import {RunIdCallablePayload} from "../shared/generated/runIdCallablePayload";
import {validateRunIdCallablePayload} from
  "../shared/generated/schemaValidators";
import {validateCallableWithAjv, requireDoc} from "../shared/validation";
import {
  appCheckCallableOptionsWithSecrets,
} from "../shared/callableOptions";
import {
  createRazorpayClient,
  razorpayKeyId,
  razorpayKeySecret,
} from "../payments/razorpay";
import {
  participantUids,
  runParticipationId,
  runParticipationPatch,
  runParticipationsByStatusInTransaction,
  waitlistedRunParticipationsInTransaction,
} from "../shared/relationshipDocuments";
import {checkRateLimit} from "../shared/rateLimit";
import {
  allowsPushPreference,
  activityNotificationId,
  runActivityNotificationCopy,
  sendFcmNotification,
  setActivityNotificationInTransaction,
} from "../shared/notifications";
import {
  claimUserRunScheduleInTransaction,
  releaseUserRunScheduleInTransaction,
} from "./scheduleConflicts";
import {normalizeRunIdPayload} from "./runPayloadNormalization";
import {
  assertPolicyAllowsSignup,
  cohortIdForUser,
  decrementCount,
  eventPolicyFromRun,
  incrementCount,
  rosterFromRun,
} from "./eventPolicy";

interface PromotionPush {
  token: string;
  title: string;
  body: string;
  runId: string;
  runClubId: string;
}

/**
 * Atomically cancels a user's sign-up for a run.
 *
 * - Marks the user's runParticipation edge cancelled.
 * - Promotes the first eligible waitlist user into the freed spot.
 * - Issues a full Razorpay refund if the booking was paid.
 * - Idempotent — calling it when the user is already not signed up is a no-op.
 */
export const cancelRunSignUp = onCall(
  appCheckCallableOptionsWithSecrets([razorpayKeyId, razorpayKeySecret]),
  async (request) => {
    const userId = requireAuth(request);
    const {runId} = validateCallableWithAjv<RunIdCallablePayload>(
      request,
      validateRunIdCallablePayload,
      normalizeRunIdPayload
    );

    const db = admin.firestore();
    await checkRateLimit(db, userId, "cancelRunSignUp");

    const runRef = db.collection("runs").doc(runId);
    const userRef = db.collection("users").doc(userId);
    const participationRef = db
      .collection("runParticipations")
      .doc(runParticipationId(runId, userId));

    // Look up a completed payment for this user + run before entering the
    // transaction so we can issue a refund afterwards.
    const paymentQuery = await db
      .collection("payments")
      .where("userId", "==", userId)
      .where("runId", "==", runId)
      .where("status", "==", "completed")
      .limit(1)
      .get();
    const paymentDoc = paymentQuery.empty ? null : paymentQuery.docs[0];
    const promotionPushes: PromotionPush[] = [];

    await db.runTransaction(async (tx) => {
      const [
        runSnap,
        userSnap,
        participationSnap,
        activeParticipations,
        waitlistedParticipations,
      ] = await Promise.all([
        tx.get(runRef),
        tx.get(userRef),
        tx.get(participationRef),
        runParticipationsByStatusInTransaction(tx, db, runId, [
          "signedUp",
          "attended",
        ]),
        waitlistedRunParticipationsInTransaction(tx, db, runId),
      ]);

      if (!runSnap.exists) {
        throw new HttpsError("not-found", "Run not found.");
      }
      if (!userSnap.exists) {
        throw new HttpsError("not-found", "User profile not found.");
      }

      const run = requireDoc<RunDoc>(runSnap, "RunDoc");
      const user = requireDoc<UserProfileDoc>(userSnap, "UserProfileDoc");
      const participation = participationSnap.exists ?
        participationSnap.data() as {status?: string; cohortAtSignup?: string} :
        null;

      // Idempotent — already not signed up.
      if (participation?.status !== "signedUp") {
        return;
      }

      const cancellerGender = user.gender;
      const cancellerCohort =
        participation?.cohortAtSignup ?? cohortIdForUser(user);

      const currentSignedUpCount = run.bookedCount ??
        activeParticipations.filter((edge) =>
          edge.data.status === "signedUp").length;
      const currentWaitlistedCount = run.waitlistedCount ??
        waitlistedParticipations.length;
      let nextBookedCount = Math.max(0, currentSignedUpCount - 1);
      let nextWaitlistedCount = currentWaitlistedCount;
      const newGenderCounts = {...run.genderCounts};
      newGenderCounts[cancellerGender] =
        Math.max(0, (newGenderCounts[cancellerGender] ?? 1) - 1);
      let newCohortCounts = decrementCount(
        run.cohortCounts ?? {},
        cancellerCohort
      );
      let promotedParticipationRef:
        FirebaseFirestore.DocumentReference | null = null;
      let promotedParticipationPatch: Record<string, unknown> | null = null;
      let promotedNotification:
        {uid: string; token?: string; title: string; body: string} | null =
        null;

      // Promote the first waitlist user who passes gender-cap and block checks.
      const activePeerIds = participantUids(activeParticipations, userId);
      for (const waitlistedParticipation of waitlistedParticipations) {
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

        const waitlistUser = requireDoc<UserProfileDoc>(
          waitlistUserSnap, "UserProfileDoc (waitlist)"
        );
        const wGender = waitlistUser.gender;
        const wCohort = waitlistedParticipation.data.cohortAtSignup ??
          cohortIdForUser(waitlistUser);

        try {
          assertPolicyAllowsSignup({
            policy: eventPolicyFromRun(run),
            cohortId: wCohort,
            roster: {
              ...rosterFromRun({...run, cohortCounts: newCohortCounts}),
              totalBooked: nextBookedCount,
            },
          });
          await claimUserRunScheduleInTransaction(tx, db, {
            uid: waitlistUserId,
            runId,
            runClubId: run.runClubId,
            startTimeMillis: run.startTime.toMillis(),
            endTimeMillis: run.endTime.toMillis(),
          });
        } catch (error) {
          if (error instanceof HttpsError &&
              error.code === "failed-precondition") {
            continue;
          }
          throw error;
        }

        // Promote this user.
        nextBookedCount += 1;
        nextWaitlistedCount = Math.max(0, nextWaitlistedCount - 1);
        newGenderCounts[wGender] = (newGenderCounts[wGender] ?? 0) + 1;
        newCohortCounts = incrementCount(newCohortCounts, wCohort);
        promotedParticipationRef = waitlistedParticipation.ref;
        promotedParticipationPatch = runParticipationPatch({
          exists: true,
          runId,
          runClubId: run.runClubId,
          uid: waitlistUserId,
          status: "signedUp",
          genderAtSignup: wGender,
          cohortAtSignup: wCohort,
        });
        const notificationCopy = runActivityNotificationCopy(
          "waitlistPromotion",
          run
        );
        promotedNotification = {
          uid: waitlistUserId,
          token: allowsPushPreference(waitlistUser, "runStatusUpdates") ?
            waitlistUser.fcmToken :
            undefined,
          title: notificationCopy.title,
          body: notificationCopy.body,
        };
        break;
      }

      tx.update(runRef, {
        bookedCount: nextBookedCount,
        waitlistedCount: nextWaitlistedCount,
        genderCounts: newGenderCounts,
        cohortCounts: newCohortCounts,
      });
      tx.set(participationRef, runParticipationPatch({
        exists: participationSnap.exists,
        runId,
        runClubId: run.runClubId,
        uid: userId,
        status: "cancelled",
        genderAtSignup: cancellerGender,
        cohortAtSignup: cancellerCohort,
      }), {merge: true});
      releaseUserRunScheduleInTransaction(tx, db, {
        uid: userId,
        runId,
        startTimeMillis: run.startTime.toMillis(),
        endTimeMillis: run.endTime.toMillis(),
      });
      if (promotedParticipationRef && promotedParticipationPatch) {
        tx.set(promotedParticipationRef, promotedParticipationPatch, {
          merge: true,
        });
      }
      if (promotedNotification) {
        setActivityNotificationInTransaction(tx, db, {
          id: activityNotificationId("waitlistPromotion", runId),
          uid: promotedNotification.uid,
          type: "waitlistPromotion",
          title: promotedNotification.title,
          body: promotedNotification.body,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          runId,
          runClubId: run.runClubId,
        });
        if (promotedNotification.token) {
          promotionPushes.push({
            token: promotedNotification.token,
            title: promotedNotification.title,
            body: promotedNotification.body,
            runId,
            runClubId: run.runClubId,
          });
        }
      }
    });

    for (const promotionPush of promotionPushes) {
      await sendFcmNotification({
        token: promotionPush.token,
        title: promotionPush.title,
        body: promotionPush.body,
        type: "waitlistPromotion",
        runId: promotionPush.runId,
        runClubId: promotionPush.runClubId,
      });
    }

    // Issue a refund outside the transaction if the run was paid.
    if (paymentDoc) {
      const payment = requireDoc<PaymentDoc>(paymentDoc, "PaymentDoc");
      const razorpay = createRazorpayClient();

      try {
        await razorpay.payments.refund(payment.paymentId, {
          amount: payment.amount,
        });
        await paymentDoc.ref.update({status: "refunded"});
      } catch (refundError) {
        // Log and continue — cancellation itself succeeded; refund can be
        // retried manually via the Razorpay dashboard.
        logger.error(
          "Refund failed for payment",
          payment.paymentId,
          refundError
        );
      }
    }
  }
);
