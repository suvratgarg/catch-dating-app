/* eslint-disable require-jsdoc */
import {onRequest} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import {signUpUserForEvent} from "../events/signUpUserForEvent";
import {eventParticipationId} from "../shared/relationshipDocuments";
import {hasHostApprovedJoinRequest} from "../events/eventPolicy";
import {
  createStripeClient,
  normalizeStripeAccount,
  StripeCheckoutSessionSnapshot,
  StripeClient,
  stripeSecretKey,
  stripeWebhookSecret,
  verifyStripeWebhookSignature,
} from "./stripe";
import {
  syncHostPaymentAccountByStripeAccountId,
} from "./stripeHostAccounts";

interface StripeWebhookDeps {
  firestore: () => FirebaseFirestore.Firestore;
  stripe: () => StripeClient;
  serverTimestamp: () => unknown;
  signUpForEvent: typeof signUpUserForEvent;
}

const defaultDeps: StripeWebhookDeps = {
  firestore: () => admin.firestore(),
  stripe: createStripeClient,
  serverTimestamp: () => admin.firestore.FieldValue.serverTimestamp(),
  signUpForEvent: signUpUserForEvent,
};

export async function stripeWebhookHandler(
  payload: Buffer,
  signatureHeader: string | undefined,
  secret: string,
  deps: StripeWebhookDeps = defaultDeps
): Promise<void> {
  if (!verifyStripeWebhookSignature({
    payload,
    signatureHeader,
    secret,
  })) {
    throw new Error("Invalid Stripe webhook signature.");
  }

  const event = parseStripeEvent(payload);
  const db = deps.firestore();
  if (
    event.type === "checkout.session.completed" ||
    event.type === "checkout.session.async_payment_succeeded"
  ) {
    const sessionId = objectId(event.data.object);
    const session = await deps.stripe().retrieveCheckoutSession(sessionId);
    await fulfillStripeCheckoutSession({db, session, deps});
    return;
  }

  if (
    event.type === "checkout.session.async_payment_failed" ||
    event.type === "checkout.session.expired"
  ) {
    const sessionId = objectId(event.data.object);
    await markStripeCheckoutFailed({
      db,
      sessionId,
      serverTimestamp: deps.serverTimestamp(),
    });
    return;
  }

  if (event.type.startsWith("account.") ||
      event.type.startsWith("v2.core.account")) {
    const account = normalizeStripeAccount(event.data.object);
    await syncHostPaymentAccountByStripeAccountId({
      db,
      stripeAccountId: account.id,
      account,
      serverTimestamp: deps.serverTimestamp(),
      lastStripeEventId: event.id,
    });
  }
}

async function fulfillStripeCheckoutSession({
  db,
  session,
  deps,
}: {
  db: FirebaseFirestore.Firestore;
  session: StripeCheckoutSessionSnapshot;
  deps: StripeWebhookDeps;
}) {
  if (session.paymentStatus !== "paid") return;
  const metadata = session.metadata;
  const paymentId = requiredMetadata(metadata, "paymentId");
  const eventId = requiredMetadata(metadata, "eventId");
  const userId = requiredMetadata(metadata, "userId");
  const amountMinor = Number(requiredMetadata(metadata, "amountMinor"));
  const currency = requiredMetadata(metadata, "currency").toUpperCase();
  const paymentIntentId = session.paymentIntentId;
  if (!Number.isInteger(amountMinor) || amountMinor <= 0) {
    throw new Error("Stripe Checkout Session amount metadata is invalid.");
  }
  if (session.amountTotal !== amountMinor || session.currency !== currency) {
    throw new Error("Stripe Checkout Session amount or currency mismatch.");
  }

  const paymentRef = db.collection("payments").doc(paymentId);
  const paymentSnap = await paymentRef.get();
  const existingStatus = paymentSnap.exists ?
    paymentSnap.data()?.status :
    null;
  const createdAt = paymentSnap.data()?.createdAt ?? deps.serverTimestamp();
  if (existingStatus === "completed" || existingStatus === "refunded") {
    return;
  }

  try {
    const participationSnap = await db
      .collection("eventParticipations")
      .doc(eventParticipationId(eventId, userId))
      .get();
    const hasHostApproval =
      hasHostApprovedJoinRequest(participationSnap.data());
    await deps.signUpForEvent(db, eventId, userId, paymentId, {
      hasValidInvite: metadata.inviteVerified === "true",
      ...(hasHostApproval ? {hasHostApproval} : {}),
    });
  } catch (signUpError) {
    let refundSucceeded = false;
    if (paymentIntentId !== null) {
      try {
        await deps.stripe().createRefund({paymentIntentId, amountMinor});
        refundSucceeded = true;
      } catch (refundError) {
        logger.error(
          "Stripe refund failed for payment",
          paymentId,
          refundError
        );
      }
    }
    await paymentRef.set({
      orderId: session.id,
      paymentId,
      eventId,
      userId,
      amount: amountMinor,
      amountMinor,
      currency,
      provider: "stripe",
      providerPaymentId: paymentIntentId,
      checkoutSessionId: session.id,
      status: refundSucceeded ? "refunded" : "completed",
      signUpFailed: true,
      updatedAt: deps.serverTimestamp(),
      createdAt,
    }, {merge: true});
    throw signUpError;
  }

  await paymentRef.set({
    orderId: session.id,
    paymentId,
    eventId,
    userId,
    amount: amountMinor,
    amountMinor,
    currency,
    provider: "stripe",
    providerPaymentId: paymentIntentId,
    checkoutSessionId: session.id,
    status: "completed",
    signUpFailed: false,
    updatedAt: deps.serverTimestamp(),
    createdAt,
  }, {merge: true});
}

async function markStripeCheckoutFailed({
  db,
  sessionId,
  serverTimestamp,
}: {
  db: FirebaseFirestore.Firestore;
  sessionId: string;
  serverTimestamp: unknown;
}) {
  const snap = await db
    .collection("payments")
    .where("checkoutSessionId", "==", sessionId)
    .limit(1)
    .get();
  if (snap.empty) return;
  await snap.docs[0].ref.set({
    status: "failed",
    updatedAt: serverTimestamp,
  }, {merge: true});
}

interface StripeWebhookEvent {
  id: string;
  type: string;
  data: {object: unknown};
}

function parseStripeEvent(payload: Buffer): StripeWebhookEvent {
  const parsed = JSON.parse(payload.toString("utf8")) as unknown;
  if (parsed === null || typeof parsed !== "object") {
    throw new Error("Stripe webhook event was malformed.");
  }
  const event = parsed as Record<string, unknown>;
  if (
    typeof event.id !== "string" ||
    typeof event.type !== "string" ||
    event.data === null ||
    typeof event.data !== "object"
  ) {
    throw new Error("Stripe webhook event was malformed.");
  }
  return {
    id: event.id,
    type: event.type,
    data: event.data as {object: unknown},
  };
}

function objectId(object: unknown): string {
  if (object === null || typeof object !== "object") {
    throw new Error("Stripe webhook object was malformed.");
  }
  const id = (object as Record<string, unknown>).id;
  if (typeof id !== "string" || id.length === 0) {
    throw new Error("Stripe webhook object id was missing.");
  }
  return id;
}

function requiredMetadata(
  metadata: Record<string, string>,
  key: string
): string {
  const value = metadata[key];
  if (typeof value !== "string" || value.length === 0) {
    throw new Error(`Stripe Checkout Session missing ${key} metadata.`);
  }
  return value;
}

export const stripeWebhook = onRequest(
  {secrets: [stripeSecretKey, stripeWebhookSecret]},
  async (request, response) => {
    const rawBody = (request as {rawBody?: Buffer}).rawBody;
    if (!rawBody) {
      response.status(400).send("Missing raw Stripe webhook body.");
      return;
    }
    try {
      await stripeWebhookHandler(
        rawBody,
        request.header("stripe-signature"),
        stripeWebhookSecret.value()
      );
      response.status(200).send("ok");
    } catch (error) {
      logger.error("Stripe webhook failed", error);
      response.status(400).send("Stripe webhook failed.");
    }
  }
);
