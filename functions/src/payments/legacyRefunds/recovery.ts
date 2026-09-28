import * as admin from "firebase-admin";
import {onDocumentUpdated, onDocumentWritten} from
  "firebase-functions/v2/firestore";
import {onSchedule} from "firebase-functions/v2/scheduler";
import * as logger from "firebase-functions/logger";
import type {PaymentDocument} from "../../shared/generated/firestoreAdminTypes";
import {requireDoc} from "../../shared/validation";
import {razorpayKeySecret} from "../razorpay";
import {stripeSecretKey} from "../stripe";
import {planLegacyCancellationRefund} from "./intent";
import {processLegacyCancellationRefund} from "./processor";
import {NativeCancellationRefundProvider} from "./provider";

/** Read cancellation and the current charge together, including captures which
 * arrive after event cancellation. No provider I/O happens in this transaction.
 */
export async function stageCancelledEventPayment(input: {
  db: FirebaseFirestore.Firestore; paymentId: string; nowMillis: number;
}): Promise<void> {
  const {db, paymentId, nowMillis} = input;
  const ref = db.collection("payments").doc(paymentId);
  await db.runTransaction(async (tx) => {
    const snapshot = await tx.get(ref);
    if (!snapshot.exists) return;
    const payment = requireDoc<PaymentDocument>(snapshot, "PaymentDocument");
    if (!["completed", "refunded"].includes(payment.status) ||
        payment.signUpFailed) return;
    const event = await tx.get(db.collection("events").doc(payment.eventId));
    if (event.data()?.status !== "cancelled") return;
    if (payment.cancellationRefund?.reason === "eventCancelled") return;
    const cancellationRefund = planLegacyCancellationRefund({payment,
      reason: "eventCancelled", targetAmountMinor: payment.amount, nowMillis});
    tx.update(ref, {cancellationRefund});
  });
}

/** Page through all captures, without a purchase-age cutoff. Retrying after an
 * interrupted page is safe: each record has an independently persisted intent.
 */
export async function stageCancelledEventRefunds(input: {
  db: FirebaseFirestore.Firestore; eventId: string;
  clock?: () => number;
}): Promise<void> {
  const {db, eventId} = input;
  const clock = input.clock ?? Date.now;
  let cursor: FirebaseFirestore.QueryDocumentSnapshot | undefined;
  let failures = 0;
  do {
    let query = db.collection("payments").where("eventId", "==", eventId)
      .where("status", "in", ["completed", "refunded"])
      .orderBy(admin.firestore.FieldPath.documentId()).limit(100);
    if (cursor) query = query.startAfter(cursor);
    const page = await query.get();
    let index = 0;
    await Promise.all(Array.from({length: Math.min(4, page.docs.length)},
      async () => {
        while (index < page.docs.length) {
          const paymentId = page.docs[index++].id;
          try {
            await stageCancelledEventPayment({db, paymentId,
              nowMillis: clock()});
          } catch {
            failures++;
            logger.error("Native cancelled-event payment needs review", {
              eventId, paymentId});
          }
        }
      }));
    cursor = page.docs.length === 100 ? page.docs.at(-1) : undefined;
  } while (cursor);
  if (failures) throw new Error("Native cancellation staging needs recovery.");
}

export async function reconcileNativeCancellationRefunds(input: {
  db: FirebaseFirestore.Firestore; nowMillis: number;
  process?: (paymentId: string) => Promise<void>;
}): Promise<{processed: number; failed: number}> {
  const {db, nowMillis} = input;
  const jobs = await db.collection("payments")
    .where("cancellationRefund.state", "==", "pending")
    .where("cancellationRefund.nextAttemptAtMillis", "<=", nowMillis)
    .orderBy("cancellationRefund.nextAttemptAtMillis").limit(40).get();
  const process = input.process ?? ((paymentId: string) =>
    processLegacyCancellationRefund({db, paymentId,
      provider: new NativeCancellationRefundProvider()}));
  let index = 0; let processed = 0; let failed = 0;
  await Promise.all(Array.from({length: Math.min(4, jobs.docs.length)},
    async () => {
      while (index < jobs.docs.length) {
        const job = jobs.docs[index++];
        try {
          await process(job.id); processed++;
        } catch {
          failed++;
          // A malformed proof can fail before a lease is claimed. Keep it
          // explicit, but do not let it occupy the oldest queue page forever.
          await db.runTransaction(async (tx) => {
            const current = (await tx.get(job.ref)).data()?.cancellationRefund;
            if (current?.state === "pending" &&
                current.nextAttemptAtMillis <= nowMillis &&
                current.leaseUntilMillis <= nowMillis) {
              tx.update(job.ref, {cancellationRefund: {...current,
                state: "reviewRequired", lastErrorCode: "invalidAuthority"}});
            }
          }).catch(() => undefined);
        }
      }
    }));
  return {processed, failed};
}

export const onCancelledNativeEventRefunds = onDocumentUpdated({
  document: "events/{eventId}", retry: true, timeoutSeconds: 540,
}, async (event) => {
  if (event.data?.after.data().status !== "cancelled" ||
      event.data.before.data().status === "cancelled") return;
  await stageCancelledEventRefunds({db: admin.firestore(),
    eventId: event.params.eventId});
});

export const onNativeCancellationRefund = onDocumentWritten({
  document: "payments/{paymentId}", retry: true, timeoutSeconds: 120,
  secrets: [razorpayKeySecret, stripeSecretKey],
}, async (event) => {
  const payment = event.data?.after.data();
  if (!payment || !["completed", "refunded"].includes(payment.status)) return;
  const db = admin.firestore(); const paymentId = event.params.paymentId;
  await stageCancelledEventPayment({db, paymentId, nowMillis: Date.now()});
  await processLegacyCancellationRefund({db, paymentId,
    provider: new NativeCancellationRefundProvider()});
});

export const recoverNativeCancellationRefunds = onSchedule({
  schedule: "every 5 minutes", timeZone: "Asia/Kolkata",
  timeoutSeconds: 540, maxInstances: 1,
  secrets: [razorpayKeySecret, stripeSecretKey],
}, async () => {
  const result = await reconcileNativeCancellationRefunds({
    db: admin.firestore(), nowMillis: Date.now()});
  if (result.processed || result.failed) {
    logger.info("Native cancellation refund recovery", result);
  }
});
