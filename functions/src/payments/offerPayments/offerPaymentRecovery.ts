import * as admin from "firebase-admin";
import {Timestamp} from "firebase-admin/firestore";
import {onSchedule} from "firebase-functions/v2/scheduler";
import * as logger from "firebase-functions/logger";
import {OFFER_PAYMENT_COLLECTION} from "./offerPaymentReservation";
import {releaseOfferPaymentHold} from "./offerPaymentExpiry";
import type {OfferPaymentProcessor} from "./offerPaymentProcessor";
import {offerPaymentExecutionFor} from "./offerPaymentRuntime";

/** Bounded oldest-first recovery; expiry is independent of provider outages. */
export async function reconcileOfferPayments(input: {
  db: FirebaseFirestore.Firestore; nowMillis: number;
}, ops: {execution: (input: {db: FirebaseFirestore.Firestore;
    paymentId: string}) => Promise<Pick<OfferPaymentProcessor, "reconcile">>;
  release: typeof releaseOfferPaymentHold; clock: () => number;
} = {execution: offerPaymentExecutionFor,
  release: releaseOfferPaymentHold, clock: Date.now}) {
  const {db, nowMillis} = input;
  const deadline = ops.clock() + 8 * 60_000;
  const collection = db.collection(OFFER_PAYMENT_COLLECTION);
  const [pending, completed] = await Promise.all([
    collection.where("status", "in", ["creatingOrder", "orderUnknown",
      "checkoutReady", "verifying", "captured", "expired", "failed",
      "refundPending", "reviewRequired"])
      .where("updatedAt", "<=", Timestamp.fromMillis(nowMillis - 120_000))
      .orderBy("updatedAt").limit(40).get(),
    collection.where("status", "==", "admitted")
      .where("createdAt", ">=",
        Timestamp.fromMillis(nowMillis - 45 * 86400_000))
      .where("updatedAt", "<=", Timestamp.fromMillis(nowMillis - 6 * 3600_000))
      .orderBy("createdAt").orderBy("updatedAt").limit(20).get(),
  ]);
  const jobs = [...pending.docs, ...completed.docs];
  let cursor = 0;
  let processed = 0;
  let failed = 0;
  await Promise.all(Array.from({length: Math.min(4, jobs.length)}, async () => {
    while (cursor < jobs.length && ops.clock() < deadline) {
      const job = jobs[cursor++];
      let succeeded = true;
      try {
        await ops.release({db, paymentId: job.id,
          reason: "expired", nowMillis});
      } catch {
        succeeded = false;
      }
      try {
        if (job.get("status") !== "reviewRequired") {
          const processor = await ops.execution({db, paymentId: job.id});
          await processor.reconcile();
        }
      } catch {
        succeeded = false;
      }
      try {
        // Move malformed records behind other work without clearing errors.
        await job.ref.update({updatedAt: Timestamp.fromMillis(nowMillis)});
      } catch {
        succeeded = false;
      }
      if (succeeded) processed++;
      else failed++;
    }
  }));
  return {processed, failed, deferred: jobs.length - cursor};
}

export const reconcileOrganizerEventOfferPayments = onSchedule({
  schedule: "every 5 minutes", timeZone: "Asia/Kolkata",
  timeoutSeconds: 540, maxInstances: 1,
}, async () => {
  try {
    const summary = await reconcileOfferPayments({db: admin.firestore(),
      nowMillis: Date.now()});
    if (summary.processed || summary.failed || summary.deferred) {
      logger.info("Offer payment reconciliation", summary);
    }
  } catch {
    throw new Error("Offer payment recovery is unavailable.");
  }
});
