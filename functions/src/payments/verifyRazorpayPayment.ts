import {
  CallableRequest,
  HttpsError,
  onCall,
} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import Razorpay from "razorpay";
import {signUpUserForRun} from "../runs/signUpUserForRun";
import {buildPaymentRecord, verifyPaidRunBooking} from "./paymentValidation";
import {
  createRazorpayClient,
  razorpayKeyId,
  razorpayKeySecret,
  verifyPaymentSignature,
} from "./razorpay";

interface VerifyPaymentData {
  paymentId: string;
  orderId: string;
  signature: string;
}

interface VerifyRazorpayPaymentDeps {
  createClient: () => Razorpay;
  firestore: () => FirebaseFirestore.Firestore;
  serverTimestamp: () => unknown;
  signUpForRun: typeof signUpUserForRun;
  verifySignature: typeof verifyPaymentSignature;
}

const defaultDeps: VerifyRazorpayPaymentDeps = {
  createClient: createRazorpayClient,
  firestore: () => admin.firestore(),
  serverTimestamp: () => admin.firestore.FieldValue.serverTimestamp(),
  signUpForRun: signUpUserForRun,
  verifySignature: verifyPaymentSignature,
};

/**
 * Verifies Razorpay payment truth, signs up the user, and records payment.
 * @param {CallableRequest<Partial<VerifyPaymentData> | null>} request Callable.
 * @param {VerifyRazorpayPaymentDeps} deps Injectable service dependencies.
 * @return {Promise<{verified: boolean, runId: string}>} Verification result.
 */
export async function verifyRazorpayPaymentHandler(
  request: CallableRequest<Partial<VerifyPaymentData> | null>,
  deps: VerifyRazorpayPaymentDeps = defaultDeps
) {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Must be signed in.");
  }

  const paymentId = request.data?.paymentId;
  const orderId = request.data?.orderId;
  const signature = request.data?.signature;

  if (!paymentId || !orderId || !signature) {
    throw new HttpsError("invalid-argument", "Missing required fields.");
  }

  if (!deps.verifySignature({orderId, paymentId, signature})) {
    throw new HttpsError(
      "invalid-argument",
      "Payment signature verification failed."
    );
  }

  const db = deps.firestore();
  const userId = request.auth.uid;
  const razorpay = deps.createClient();
  const [order, payment] = await Promise.all([
    razorpay.orders.fetch(orderId),
    razorpay.payments.fetch(paymentId),
  ]);
  const booking = verifyPaidRunBooking({
    order,
    payment,
    expectedUserId: userId,
  });

  // Sign the user up for the run. If this fails (e.g. run filled up in a
  // race condition between order creation and payment), issue an immediate
  // refund so the user is never charged for a spot they didn't get.
  try {
    await deps.signUpForRun(db, booking.runId, userId);
  } catch (signUpError) {
    let refundSucceeded = false;
    try {
      await razorpay.payments.refund(paymentId, {
        amount: booking.amountInPaise,
      });
      refundSucceeded = true;
    } catch (refundError) {
      console.error("Refund failed for payment", paymentId, refundError);
    }

    await db.collection("payments").doc(paymentId).set({
      ...buildPaymentRecord({
        userId,
        orderId,
        paymentId,
        runId: booking.runId,
        amountInPaise: booking.amountInPaise,
        currency: booking.currency,
        status: refundSucceeded ? "refunded" : "completed",
        signUpFailed: true,
      }),
      createdAt: deps.serverTimestamp(),
    });

    throw signUpError;
  }

  // Record the completed payment.
  await db.collection("payments").doc(paymentId).set({
    ...buildPaymentRecord({
      userId,
      orderId,
      paymentId,
      runId: booking.runId,
      amountInPaise: booking.amountInPaise,
      currency: booking.currency,
      status: "completed",
    }),
    createdAt: deps.serverTimestamp(),
  });

  return {verified: true, runId: booking.runId};
}

export const verifyRazorpayPayment = onCall(
  {enforceAppCheck: true, secrets: [razorpayKeyId, razorpayKeySecret]},
  (request) => verifyRazorpayPaymentHandler(request)
);
