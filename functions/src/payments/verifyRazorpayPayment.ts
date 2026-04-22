import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {defineSecret} from "firebase-functions/params";
import * as crypto from "crypto";
import Razorpay from "razorpay";
import {signUpUserForRun} from "../runs/signUpUserForRun";

const razorpayKeyId = defineSecret("RAZORPAY_KEY_ID");
const razorpayKeySecret = defineSecret("RAZORPAY_KEY_SECRET");

interface VerifyPaymentData {
  paymentId: string;
  orderId: string;
  signature: string;
  activityId: string; // runId
  amountInPaise: number;
}

export const verifyRazorpayPayment = onCall(
  {secrets: [razorpayKeyId, razorpayKeySecret]},
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

    // Sign the user up for the run. If this fails (e.g. run filled up in a
    // race condition between order creation and payment), issue an immediate
    // refund so the user is never charged for a spot they didn't get.
    try {
      await signUpUserForRun(db, activityId, userId);
    } catch (signUpError) {
      const razorpay = new Razorpay({
        key_id: razorpayKeyId.value(),
        key_secret: razorpayKeySecret.value(),
      });

      let refundSucceeded = false;
      try {
        await razorpay.payments.refund(paymentId, {amount: amountInPaise ?? 0});
        refundSucceeded = true;
      } catch (refundError) {
        console.error("Refund failed for payment", paymentId, refundError);
      }

      await db.collection("payments").doc(paymentId).set({
        userId,
        orderId,
        paymentId,
        activityId,
        amount: amountInPaise ?? 0,
        currency: "INR",
        status: refundSucceeded ? "refunded" : "completed",
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
