import {
  CallableRequest,
  HttpsError,
  onCall,
} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import Razorpay from "razorpay";
import {signUpUserForEvent} from "../events/signUpUserForEvent";
import {eventParticipationId} from "../shared/relationshipDocuments";
import {hasHostApprovedJoinRequest} from "../events/eventPolicy";
import {buildPaymentRecord, verifyPaidEventBooking} from "./paymentValidation";
import {
  createRazorpayClient,
  razorpayKeyId,
  razorpayKeySecret,
  verifyPaymentSignature,
} from "./razorpay";
import {appCheckCallableOptionsWithSecrets} from "../shared/callableOptions";
import {checkRateLimit as defaultCheckRateLimit} from "../shared/rateLimit";
import {requireAuth} from "../shared/auth";
import {normalizePayloadStrings} from "../shared/callablePayloadNormalization";
import {validateVerifyRazorpayPaymentCallablePayload} from
  "../shared/generated/schemaValidators";
import {VerifyRazorpayPaymentCallablePayload} from
  "../shared/generated/verifyRazorpayPaymentCallablePayload";
import {validateCallableWithAjv} from "../shared/validation";

interface VerifyRazorpayPaymentDeps {
  createClient: () => Razorpay;
  firestore: () => FirebaseFirestore.Firestore;
  serverTimestamp: () => unknown;
  signUpForEvent: typeof signUpUserForEvent;
  verifySignature: typeof verifyPaymentSignature;
  checkRateLimit?: (
    db: FirebaseFirestore.Firestore,
    uid: string,
    action: string
  ) => Promise<void>;
}

const defaultDeps: VerifyRazorpayPaymentDeps = {
  createClient: createRazorpayClient,
  firestore: () => admin.firestore(),
  serverTimestamp: () => admin.firestore.FieldValue.serverTimestamp(),
  signUpForEvent: signUpUserForEvent,
  verifySignature: verifyPaymentSignature,
  checkRateLimit: defaultCheckRateLimit,
};

/**
 * Verifies Razorpay payment truth, signs up the user, and records payment.
 * @param {CallableRequest<Partial<VerifyPaymentData> | null>} request Callable.
 * @param {VerifyRazorpayPaymentDeps} deps Injectable service dependencies.
 * @return {Promise<{verified: boolean, eventId: string}>} Verification result.
 */
export async function verifyRazorpayPaymentHandler(
  request: CallableRequest<unknown>,
  deps: VerifyRazorpayPaymentDeps = defaultDeps
) {
  const userId = requireAuth(request);
  const {paymentId, orderId, signature} = validateCallableWithAjv<
    VerifyRazorpayPaymentCallablePayload
  >(
    request,
    validateVerifyRazorpayPaymentCallablePayload,
    normalizeVerifyPaymentPayload
  );

  const db = deps.firestore();
  await deps.checkRateLimit?.(db, userId, "verifyRazorpayPayment");

  if (!deps.verifySignature({orderId, paymentId, signature})) {
    throw new HttpsError(
      "invalid-argument",
      "Payment signature verification failed."
    );
  }

  const razorpay = deps.createClient();
  const [order, payment] = await Promise.all([
    razorpay.orders.fetch(orderId),
    razorpay.payments.fetch(paymentId),
  ]);
  const booking = verifyPaidEventBooking({
    order,
    payment,
    expectedUserId: userId,
  });

  // Sign the user up for the event. If this fails (e.g. event filled up in a
  // race condition between order creation and payment), issue an immediate
  // refund so the user is never charged for a spot they didn't get.
  try {
    const participationSnap = await db
      .collection("eventParticipations")
      .doc(eventParticipationId(booking.eventId, userId))
      .get();
    const hasHostApproval =
      hasHostApprovedJoinRequest(participationSnap.data());
    await deps.signUpForEvent(db, booking.eventId, userId, paymentId, {
      hasValidInvite: booking.inviteVerified,
      ...(hasHostApproval ? {hasHostApproval} : {}),
    });
  } catch (signUpError) {
    let refundSucceeded = false;
    try {
      await razorpay.payments.refund(paymentId, {
        amount: booking.amountInPaise,
      });
      refundSucceeded = true;
    } catch (refundError) {
      logger.error("Refund failed for payment", paymentId, refundError);
    }

    await db.collection("payments").doc(paymentId).set({
      ...buildPaymentRecord({
        userId,
        orderId,
        paymentId,
        eventId: booking.eventId,
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
      eventId: booking.eventId,
      amountInPaise: booking.amountInPaise,
      currency: booking.currency,
      status: "completed",
    }),
    createdAt: deps.serverTimestamp(),
  });

  return {verified: true, eventId: booking.eventId};
}

/**
 * Trims Razorpay verification payload fields before schema validation.
 * @param {unknown} data Raw callable payload.
 * @return {unknown} Normalized payload.
 */
function normalizeVerifyPaymentPayload(data: unknown): unknown {
  return normalizePayloadStrings(data, {
    stringFields: ["paymentId", "orderId", "signature"],
  });
}

export const verifyRazorpayPayment = onCall(
  appCheckCallableOptionsWithSecrets([razorpayKeyId, razorpayKeySecret]),
  (request) => verifyRazorpayPaymentHandler(request)
);
