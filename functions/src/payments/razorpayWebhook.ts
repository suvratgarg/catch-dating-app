import {onRequest} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import Razorpay from "razorpay";
import {signUpUserForEvent} from "../events/signUpUserForEvent";
import {verifyPaidEventBooking} from "./paymentValidation";
import {
  fulfillRazorpayPayment,
  markRazorpayPendingOrder,
  razorpayRefundFromClient,
} from "./razorpayFulfillment";
import {
  createRazorpayClient,
  razorpayKeyId,
  razorpayKeySecret,
  razorpayWebhookSecret,
  verifyRazorpayWebhookSignature,
} from "./razorpay";

interface RazorpayWebhookDeps {
  firestore: () => FirebaseFirestore.Firestore;
  createClient: () => Razorpay;
  serverTimestamp: () => unknown;
  signUpForEvent: typeof signUpUserForEvent;
}

const defaultDeps: RazorpayWebhookDeps = {
  firestore: () => admin.firestore(),
  createClient: createRazorpayClient,
  serverTimestamp: () => admin.firestore.FieldValue.serverTimestamp(),
  signUpForEvent: signUpUserForEvent,
};

/**
 * Processes a verified Razorpay webhook delivery.
 *
 * Handles `payment.captured` by re-fetching and validating the order + payment
 * (so we trust Razorpay's server state, not the webhook body) and running the
 * shared fulfillment helper — idempotent if the client callback already
 * fulfilled the booking. Handles `payment.failed` by marking the matching
 * pending-order tracking doc failed.
 *
 * Throws on an invalid signature or a malformed event so the onRequest wrapper
 * can answer 400 and Razorpay retries.
 * @param {Buffer} rawBody Exact raw request body bytes.
 * @param {string|undefined} signatureHeader x-razorpay-signature header value.
 * @param {string} secret Razorpay webhook secret.
 * @param {RazorpayWebhookDeps} deps Injectable dependencies.
 * @return {Promise<void>} Resolves when processing completes.
 */
export async function razorpayWebhookHandler(
  rawBody: Buffer,
  signatureHeader: string | undefined,
  secret: string,
  deps: RazorpayWebhookDeps = defaultDeps
): Promise<void> {
  if (!verifyRazorpayWebhookSignature(rawBody, signatureHeader, secret)) {
    throw new Error("Invalid Razorpay webhook signature.");
  }

  const event = parseRazorpayEvent(rawBody);
  const db = deps.firestore();

  if (event.event === "payment.captured") {
    await handlePaymentCaptured({db, deps, payment: paymentEntity(event)});
    return;
  }

  if (event.event === "payment.failed") {
    const payment = paymentEntity(event);
    if (payment.order_id) {
      await markRazorpayPendingOrder({
        db,
        orderId: payment.order_id,
        status: "failed",
        serverTimestamp: deps.serverTimestamp,
      });
    }
    return;
  }

  // Other event types (e.g. order.paid, refund.*) are not acted on here.
}

/**
 * Fulfills a captured Razorpay payment, validating against Razorpay truth.
 * @param {object} params Handler parameters.
 * @param {FirebaseFirestore.Firestore} params.db Firestore instance.
 * @param {RazorpayWebhookDeps} params.deps Injectable dependencies.
 * @param {RazorpayWebhookPayment} params.payment Webhook payment entity.
 * @return {Promise<void>} Resolves when fulfillment settles.
 */
async function handlePaymentCaptured({
  db,
  deps,
  payment: webhookPayment,
}: {
  db: FirebaseFirestore.Firestore;
  deps: RazorpayWebhookDeps;
  payment: RazorpayWebhookPayment;
}): Promise<void> {
  const orderId = webhookPayment.order_id;
  const paymentId = webhookPayment.id;
  if (!orderId) {
    throw new Error("Razorpay payment.captured event has no order_id.");
  }

  const razorpay = deps.createClient();
  // Re-fetch from Razorpay rather than trusting the webhook body, and discover
  // the booking owner from the order notes (the user id lives there, set at
  // order-creation time).
  const [order, payment] = await Promise.all([
    razorpay.orders.fetch(orderId),
    razorpay.payments.fetch(paymentId),
  ]);
  const expectedUserId = noteString(
    order as {notes?: Record<string, unknown> | null},
    "userId"
  );
  if (!expectedUserId) {
    throw new Error("Razorpay order is missing the userId note.");
  }

  const booking = verifyPaidEventBooking({
    order,
    payment,
    expectedUserId,
  });

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
}

interface RazorpayWebhookPayment {
  id: string;
  order_id: string | null;
  status?: string;
}

interface RazorpayWebhookEvent {
  event: string;
  payload: {
    payment?: {entity?: unknown};
  };
}

/**
 * Reads the payment entity from a Razorpay webhook event.
 * @param {RazorpayWebhookEvent} event Parsed webhook event.
 * @return {RazorpayWebhookPayment} Payment entity with id and order id.
 */
function paymentEntity(event: RazorpayWebhookEvent): RazorpayWebhookPayment {
  const entity = event.payload?.payment?.entity;
  if (entity === null || typeof entity !== "object") {
    throw new Error("Razorpay webhook payment entity was missing.");
  }
  const record = entity as Record<string, unknown>;
  const id = record.id;
  if (typeof id !== "string" || id.length === 0) {
    throw new Error("Razorpay webhook payment id was missing.");
  }
  const orderId = record.order_id;
  return {
    id,
    order_id: typeof orderId === "string" && orderId.length > 0 ?
      orderId :
      null,
    status: typeof record.status === "string" ? record.status : undefined,
  };
}

/**
 * Parses and shape-checks a Razorpay webhook event body.
 * @param {Buffer} rawBody Raw request body bytes.
 * @return {RazorpayWebhookEvent} Parsed event.
 */
function parseRazorpayEvent(rawBody: Buffer): RazorpayWebhookEvent {
  const parsed = JSON.parse(rawBody.toString("utf8")) as unknown;
  if (parsed === null || typeof parsed !== "object") {
    throw new Error("Razorpay webhook event was malformed.");
  }
  const event = parsed as Record<string, unknown>;
  if (
    typeof event.event !== "string" ||
    event.payload === null ||
    typeof event.payload !== "object"
  ) {
    throw new Error("Razorpay webhook event was malformed.");
  }
  return {
    event: event.event,
    payload: event.payload as RazorpayWebhookEvent["payload"],
  };
}

/**
 * Reads a non-empty string note from a Razorpay order.
 * @param {object} order Razorpay order with optional notes map.
 * @param {string} key Note key.
 * @return {string|null} Note value when present.
 */
function noteString(
  order: {notes?: Record<string, unknown> | null},
  key: string
): string | null {
  const value = order.notes?.[key];
  if (typeof value !== "string") return null;
  const trimmed = value.trim();
  return trimmed.length > 0 ? trimmed : null;
}

export const razorpayWebhook = onRequest(
  {secrets: [razorpayKeyId, razorpayKeySecret, razorpayWebhookSecret]},
  async (request, response) => {
    const rawBody = (request as {rawBody?: Buffer}).rawBody;
    if (!rawBody) {
      response.status(400).send("Missing raw Razorpay webhook body.");
      return;
    }
    try {
      await razorpayWebhookHandler(
        rawBody,
        request.header("x-razorpay-signature"),
        razorpayWebhookSecret.value()
      );
      response.status(200).send("ok");
    } catch (error) {
      logger.error("Razorpay webhook failed", error);
      response.status(400).send("Razorpay webhook failed.");
    }
  }
);
