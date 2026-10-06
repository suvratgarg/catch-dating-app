import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import {defineBoolean, defineSecret, defineString} from
  "firebase-functions/params";
import {onRequest} from "firebase-functions/v2/https";
import {handleCatchWhatsappWebhook, WEBHOOK_RETENTION_MILLIS} from
  "./whatsappWebhookProtocol";
import type {CatchWebhookEvent} from "./whatsappWebhookProtocol";
import {validateCatchWhatsappWebhookEventDocument} from
  "../shared/generated/validators/catchWhatsappWebhookEventDocument";

import {CATCH_RECEIPTS, isCatchStopReceipt} from
  "./whatsappEndpointStops";
import {persistCatchVerifiedIngressEvent} from "./whatsappIngressStore";

export const CATCH_WEBHOOK_COLLECTION = CATCH_RECEIPTS;
const appSecret = defineSecret("CATCH_WHATSAPP_APP_SECRET");
const verifyToken = defineSecret("CATCH_WHATSAPP_WEBHOOK_VERIFY_TOKEN");
const webhookEnabled = defineBoolean("CATCH_WHATSAPP_WEBHOOK_ENABLED",
  {default: false});
const wabaId = defineString("CATCH_WHATSAPP_WABA_ID", {default: ""});
const phoneNumberId = defineString("CATCH_WHATSAPP_PHONE_NUMBER_ID",
  {default: ""});

export async function persistCatchWhatsappWebhookEvents(
  db: FirebaseFirestore.Firestore, events: CatchWebhookEvent[],
  nowMillis = Date.now()
): Promise<void> {
  const expiresAt = admin.firestore.Timestamp.fromMillis(
    nowMillis + WEBHOOK_RETENTION_MILLIS);
  if (events.length === 0) return;
  for (const event of events) {
    if (!validateCatchWhatsappWebhookEventDocument({...event,
      receivedAtMillis: nowMillis, expiresAt: {
        _seconds: expiresAt.seconds, _nanoseconds: expiresAt.nanoseconds,
      }})) throw new Error("Invalid Catch webhook receipt.");
  }
  // Validate the whole batch above before writing. STOP and its immutable
  // receipt commit together, before any other same-batch receipt can become
  // eligible for a reply. A conflict still durably suppresses the signed STOP,
  // and must not prevent later STOPs in this batch from being attempted.
  let stopFailure: {error: unknown} | undefined;
  for (const event of events.filter(isCatchStopReceipt)) {
    try {
      await persistCatchVerifiedIngressEvent(db, event, nowMillis);
    } catch (error) {
      stopFailure ??= {error};
    }
  }
  if (stopFailure) throw stopFailure.error;
  for (const event of events.filter((event) => !isCatchStopReceipt(event))) {
    // Canonical evidence and the immutable receipt share a transaction; a
    // duplicate receipt alone cannot establish eligibility or renew its TTL.
    await persistCatchVerifiedIngressEvent(db, event, nowMillis);
  }
}

export const catchWhatsappWebhook = onRequest({
  secrets: [appSecret, verifyToken], maxInstances: 2, concurrency: 10,
  invoker: "public",
}, async (request, response) => {
  const result = await handleCatchWhatsappWebhook({
    method: request.method, query: request.query,
    rawBody: request.rawBody,
    signature: request.header("x-hub-signature-256"),
  }, {enabled: webhookEnabled.value(), wabaId: wabaId.value().trim(),
    phoneNumberId: phoneNumberId.value().trim(), appSecret: appSecret.value(),
    verifyToken: verifyToken.value()}, (events) =>
    persistCatchWhatsappWebhookEvents(admin.firestore(), events));
  if (result.status === 503) {
    logger.warn("Catch WhatsApp webhook unavailable", {status: result.status});
  }
  response.type("text/plain").status(result.status).send(result.body);
});
