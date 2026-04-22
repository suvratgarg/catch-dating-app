import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {defineSecret} from "firebase-functions/params";
import Razorpay from "razorpay";
import {AppUserDoc, PaymentDoc, RunDoc} from "../types/firestore";

const razorpayKeyId = defineSecret("RAZORPAY_KEY_ID");
const razorpayKeySecret = defineSecret("RAZORPAY_KEY_SECRET");

interface CancelData {
  runId: string;
}

/**
 * Atomically cancels a user's sign-up for a run.
 *
 * - Removes the user from signedUpUserIds and decrements their gender count.
 * - Promotes the first eligible waitlist user into the freed spot.
 * - Issues a full Razorpay refund if the booking was paid.
 * - Idempotent — calling it when the user is already not signed up is a no-op.
 */
export const cancelRunSignUp = onCall(
  {secrets: [razorpayKeyId, razorpayKeySecret]},
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Must be signed in to cancel.");
    }

    const {runId} = request.data as CancelData;

    if (!runId) {
      throw new HttpsError("invalid-argument", "runId is required.");
    }

    const db = admin.firestore();
    const userId = request.auth.uid;
    const runRef = db.collection("runs").doc(runId);
    const userRef = db.collection("users").doc(userId);

    // Look up a completed payment for this user + run before entering the
    // transaction so we can issue a refund afterwards.
    const paymentQuery = await db
      .collection("payments")
      .where("userId", "==", userId)
      .where("activityId", "==", runId)
      .where("status", "==", "completed")
      .limit(1)
      .get();
    const paymentDoc = paymentQuery.empty ? null : paymentQuery.docs[0];

    await db.runTransaction(async (tx) => {
      const [runSnap, userSnap] = await Promise.all([
        tx.get(runRef),
        tx.get(userRef),
      ]);

      if (!runSnap.exists) {
        throw new HttpsError("not-found", "Run not found.");
      }
      if (!userSnap.exists) {
        throw new HttpsError("not-found", "User profile not found.");
      }

      const run = runSnap.data() as RunDoc;
      const user = userSnap.data() as AppUserDoc;

      // Idempotent — already not signed up.
      if (!run.signedUpUserIds.includes(userId)) {
        return;
      }

      const cancellerGender = user.gender;

      // Compute the new signedUpUserIds array in-memory so we can atomically
      // remove the canceller and optionally add a promoted waitlist user in a
      // single tx.update call (Firestore doesn't allow arrayRemove + arrayUnion
      // on the same field path in one update).
      let newSignedUpIds = run.signedUpUserIds.filter((id) => id !== userId);
      let newWaitlistIds = [...(run.waitlistUserIds ?? [])];
      const newGenderCounts = {...run.genderCounts};
      newGenderCounts[cancellerGender] = (newGenderCounts[cancellerGender] ?? 1) - 1;

      // Promote the first waitlist user who passes gender-cap constraints.
      for (let i = 0; i < newWaitlistIds.length; i++) {
        const waitlistUserId = newWaitlistIds[i];
        const waitlistUserSnap = await tx.get(
          db.collection("users").doc(waitlistUserId)
        );
        if (!waitlistUserSnap.exists) continue;

        const waitlistUser = waitlistUserSnap.data() as AppUserDoc;
        const wGender = waitlistUser.gender;
        const currentCount = run.genderCounts[wGender] ?? 0;

        if (wGender === "man" && run.constraints.maxMen !== undefined &&
            currentCount >= run.constraints.maxMen) continue;
        if (wGender === "woman" && run.constraints.maxWomen !== undefined &&
            currentCount >= run.constraints.maxWomen) continue;

        // Promote this user.
        newSignedUpIds = [...newSignedUpIds, waitlistUserId];
        newWaitlistIds = newWaitlistIds.filter((_, idx) => idx !== i);
        newGenderCounts[wGender] = (newGenderCounts[wGender] ?? 0) + 1;
        break;
      }

      tx.update(runRef, {
        signedUpUserIds: newSignedUpIds,
        waitlistUserIds: newWaitlistIds,
        genderCounts: newGenderCounts,
      });
    });

    // Issue a refund outside the transaction if the run was paid.
    if (paymentDoc) {
      const payment = paymentDoc.data() as PaymentDoc;
      const razorpay = new Razorpay({
        key_id: razorpayKeyId.value(),
        key_secret: razorpayKeySecret.value(),
      });

      try {
        await razorpay.payments.refund(payment.paymentId, {
          amount: payment.amount,
        });
        await paymentDoc.ref.update({status: "refunded"});
      } catch (refundError) {
        // Log and continue — cancellation itself succeeded; refund can be
        // retried manually via the Razorpay dashboard.
        console.error(
          "Refund failed for payment",
          payment.paymentId,
          refundError
        );
      }
    }
  }
);
