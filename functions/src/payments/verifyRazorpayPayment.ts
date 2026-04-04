import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {defineSecret} from "firebase-functions/params";
import * as crypto from "crypto";
import {signUpUserForRun} from "../runs/signUpUserForRun";

const razorpayKeySecret = defineSecret("RAZORPAY_KEY_SECRET");

interface VerifyPaymentData {
  paymentId: string;
  orderId: string;
  signature: string;
  activityId: string; // runId
  amountInPaise: number;
}

export const verifyRazorpayPayment = onCall(
  {secrets: [razorpayKeySecret]},
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Must be signed in.");
    }

    const {paymentId, orderId, signature, activityId, amountInPaise} =
      request.data as VerifyPaymentData;

    if (!paymentId || !orderId || !signature || !activityId) {
      throw new HttpsError("invalid-argument", "Missing required fields.");
    }

    // Verify HMAC-SHA256 signature.
    const expectedSignature = crypto
      .createHmac("sha256", razorpayKeySecret.value())
      .update(`${orderId}|${paymentId}`)
      .digest("hex");

    if (expectedSignature !== signature) {
      throw new HttpsError(
        "invalid-argument",
        "Payment signature verification failed."
      );
    }

    const db = admin.firestore();
    const userId = request.auth.uid;

    // Sign the user up for the run. This is transactional — if the run is
    // somehow full (race condition), this throws and the payment record is
    // still written below so we have an audit trail for a potential refund.
    try {
      await signUpUserForRun(db, activityId, userId);
    } catch (signUpError) {
      // Record the payment with a note that sign-up failed, then re-throw
      // so the client knows something went wrong.
      await db.collection("payments").doc(paymentId).set({
        userId,
        orderId,
        paymentId,
        activityId,
        amount: amountInPaise ?? 0,
        currency: "INR",
        status: "completed",
        signUpFailed: true,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      throw signUpError;
    }

    // Record the completed payment.
    await db.collection("payments").doc(paymentId).set({
      userId,
      orderId,
      paymentId,
      activityId,
      amount: amountInPaise ?? 0,
      currency: "INR",
      status: "completed",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return {verified: true};
  }
);
