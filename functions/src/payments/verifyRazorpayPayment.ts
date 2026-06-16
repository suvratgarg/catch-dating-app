import {
  CallableRequest,
  HttpsError,
  onCall,
} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import Razorpay from "razorpay";
import {signUpUserForEvent} from "../events/signUpUserForEvent";
import {verifyPaidEventBooking} from "./paymentValidation";
import {
  fulfillRazorpayPayment,
  razorpayRefundFromClient,
} from "./razorpayFulfillment";
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

  // Fulfillment (sign up -> completed payments doc, or refund-on-failure) is
  // shared with the Razorpay webhook and the reconciliation sweep so all three
  // paths stay idempotent and never double-fulfill or double-charge.
  await fulfillRazorpayPayment({
    db,
    orderId,
    paymentId,
    booking,
    deps: {
      signUpForEvent: deps.signUpForEvent,
      refund: razorpayRefundFromClient(razorpay),
      serverTimestamp: deps.serverTimestamp,
    },
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
