import {Timestamp} from "firebase-admin/firestore";
import {onRequest, type Request} from "firebase-functions/v2/https";
import {onDocumentCreated} from "firebase-functions/v2/firestore";
import {onSchedule} from "firebase-functions/v2/scheduler";
import * as logger from "firebase-functions/logger";
import type {Response} from "express";
import {formPaymentRuntime, formPaymentsConfigured} from "./formPaymentRuntime";
import {InvalidFormPaymentWebhook, processFormPaymentWebhook,
  recordFormPaymentWebhook} from "./formPaymentWebhook";
import {expireFormPaymentReservation} from "./formPaymentSubmission";

export async function organizerFormPaymentOauthCallbackHandler(
  request: Request, response: Response,
  runtime: typeof formPaymentRuntime = formPaymentRuntime): Promise<void> {
  response.set({"Cache-Control": "no-store", "Referrer-Policy": "no-referrer",
    "Content-Security-Policy": "default-src 'none'; frame-ancestors 'none'",
    "X-Content-Type-Options": "nosniff"});
  if (request.method !== "GET") {
    response.status(405).send("Method not allowed."); return;
  }
  const {state, code} = request.query;
  if (typeof state !== "string" || typeof code !== "string" ||
      request.query.error !== undefined) {
    response.status(400).send("Connection was not completed. " +
      "Return to Catch to reconnect Razorpay."); return;
  }
  try {
    const {connections} = await runtime();
    await connections.complete(state, code);
    response.status(200).type("text/plain").send(
      "Razorpay connected. You can close this window and return to Catch.");
  } catch {
    // OAuth codes, state, provider replies and secrets must never be logged or
    // interpolated into this page. There is no user-controlled redirect.
    response.status(400).type("text/plain").send(
      "Connection could not be verified. Return to Catch to reconnect.");
  }
}

export async function organizerFormPaymentWebhookHandler(
  request: Request, response: Response,
  runtime: typeof formPaymentRuntime = formPaymentRuntime): Promise<void> {
  response.set("Cache-Control", "no-store");
  if (request.method !== "POST") {
    response.status(405).send("Method not allowed."); return;
  }
  if (typeof request.query.connectionId !== "string" ||
      !Buffer.isBuffer(request.rawBody) ||
      request.rawBody.length > 64 * 1024) {
    response.status(400).send("Invalid webhook."); return;
  }
  try {
    const deps = await runtime();
    await recordFormPaymentWebhook({
      connectionId: request.query.connectionId, rawBody: request.rawBody,
      signature: request.get("x-razorpay-signature"),
      providerEventId: request.get("x-razorpay-event-id"),
    }, deps);
    // Acknowledgment means durably recorded. The trigger and sweep retry
    // provider verification and fulfillment even when this request ends.
    response.status(200).send("Recorded.");
  } catch (error) {
    if (error instanceof InvalidFormPaymentWebhook) {
      response.status(400).send("Invalid webhook."); return;
    }
    logger.warn("Form payment webhook persistence unavailable");
    response.status(503).send("Please retry.");
  }
}

export async function reconcileOrganizerFormPaymentsHandler(
  deps: Awaited<ReturnType<typeof formPaymentRuntime>>, now = Date.now()) {
  const {db, processor} = deps;
  const cutoff = Timestamp.fromMillis(now - 120_000);
  const [receipts, payments, completed] = await Promise.all([
    db.collection("organizerFormPaymentWebhooks")
      .where("status", "==", "pending")
      .where("nextAttemptAt", "<=", Timestamp.fromMillis(now))
      .orderBy("nextAttemptAt").limit(40).get(),
    db.collection("organizerFormPayments").where("status", "in", [
      "creatingOrder", "orderUnknown", "checkoutReady", "verifying",
      "captured", "failed", "expired", "refundPending"])
      .where("updatedAt", "<=", cutoff).orderBy("updatedAt").limit(40).get(),
    // Recent completed payments get a slower reconciliation pass in case a
    // refund callback was missed. No application state is changed by refunds.
    db.collection("organizerFormPayments").where("status", "==", "submitted")
      .where("createdAt", ">=", Timestamp.fromMillis(now - 45 * 86400_000))
      .where("updatedAt", "<=", Timestamp.fromMillis(now - 6 * 3600_000))
      .orderBy("createdAt").orderBy("updatedAt").limit(20).get(),
  ]);
  let processed = 0;
  let failed = 0;
  for (const receipt of receipts.docs) {
    try {
      await processFormPaymentWebhook(receipt.id, deps);
      processed++;
    } catch {
      failed++;
    } finally {
      // Failed receipts move behind other work instead of starving the queue.
      await receipt.ref.update({nextAttemptAt:
        Timestamp.fromMillis(now + 5 * 60_000)});
    }
  }
  for (const payment of [...payments.docs, ...completed.docs]) {
    try {
      await processor.reconcile(payment.id);
      processed++;
    } catch {
      failed++;
    } finally {
      // Provider outages must not hold capacity forever. A later capture of a
      // released reservation is refunded by the same reconciliation path.
      await expireFormPaymentReservation({db, paymentId: payment.id,
        now: Timestamp.fromMillis(now)});
      await payment.ref.update({updatedAt: Timestamp.fromMillis(now)});
    }
  }
  return {processed, failed};
}

export const organizerFormPaymentOauthCallback = onRequest({
  timeoutSeconds: 120, maxInstances: 10, invoker: "public",
}, (request, response) =>
  organizerFormPaymentOauthCallbackHandler(request, response));

export const organizerFormPaymentWebhook = onRequest({
  timeoutSeconds: 60, maxInstances: 20, invoker: "public",
}, (request, response) =>
  organizerFormPaymentWebhookHandler(request, response));

export const onOrganizerFormPaymentWebhook = onDocumentCreated({
  document: "organizerFormPaymentWebhooks/{receiptId}",
  timeoutSeconds: 120, maxInstances: 20, retry: true,
}, async (event) => {
  if (!formPaymentsConfigured()) return;
  try {
    await processFormPaymentWebhook(event.params.receiptId,
      await formPaymentRuntime());
  } catch {
    // Throw a sanitized error so infrastructure retries cannot log secrets.
    throw new Error("Form payment webhook reconciliation is pending.");
  }
});

export const reconcileOrganizerFormPayments = onSchedule({
  schedule: "every 5 minutes", timeZone: "Asia/Kolkata",
  timeoutSeconds: 540, maxInstances: 1,
}, async () => {
  if (!formPaymentsConfigured()) return;
  try {
    const summary = await reconcileOrganizerFormPaymentsHandler(
      await formPaymentRuntime());
    if (summary.processed || summary.failed) {
      logger.info("Form payment reconciliation", summary);
    }
  } catch {
    throw new Error("Form payment recovery sweep is unavailable.");
  }
});
