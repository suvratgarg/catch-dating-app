import * as admin from "firebase-admin";
import {Timestamp} from "firebase-admin/firestore";
import {onDocumentUpdated} from "firebase-functions/v2/firestore";
import {cancelPaidOfferForCancelledEvent} from "./offerPaymentCancellation";
import {OFFER_PAYMENT_COLLECTION} from "./offerPaymentReservation";

/** Status transitions are the durable cursor: successful rows leave admitted.
 * A retry resumes the remaining page, and provider work runs in the payment
 * recovery queue. No attendee count or payment creation date truncates refunds.
 */
export async function queueCancelledEventOfferRefunds(input: {
  db: FirebaseFirestore.Firestore; eventId: string;
}, deps: {
  now: () => number; cancel: typeof cancelPaidOfferForCancelledEvent;
} = {
  now: Date.now, cancel: cancelPaidOfferForCancelledEvent,
}): Promise<{queued: number; review: number}> {
  const {db, eventId} = input;
  const deadline = deps.now() + 8 * 60_000;
  let queued = 0;
  let review = 0;
  while (deps.now() < deadline) {
    const event = (await db.collection("events").doc(eventId).get()).data();
    if (event?.status !== "cancelled") return {queued, review};
    const page = await db.collection(OFFER_PAYMENT_COLLECTION)
      .where("eventId", "==", eventId).where("status", "in", ["admitted",
        "cancelled"])
      .limit(50).get();
    if (page.empty) return {queued, review};
    let cursor = 0;
    const workers = await Promise.allSettled(Array.from({
      length: Math.min(4, page.docs.length)},
    async () => {
      while (cursor < page.docs.length && deps.now() < deadline) {
        const row = page.docs[cursor++];
        try {
          if (await deps.cancel({db, paymentId: row.id,
            nowMillis: deps.now()})) queued++;
        } catch (error) {
          // Only explicit authority failures require review. Network/commit
          // failures must retry this event, not hide an unprocessed refund.
          if (!(error instanceof Error) ||
                !("code" in error) || error.code !== "failed-precondition") {
            throw error;
          }
          await db.runTransaction(async (tx) => {
            const current = (await tx.get(row.ref)).data();
            if (current?.eventId !== eventId ||
                  !["admitted", "cancelled"].includes(current.status)) return;
            tx.update(row.ref, {status: "reviewRequired",
              lastErrorCode: "cancellationNeedsReview",
              updatedAt: Timestamp.fromMillis(deps.now())});
            review++;
          });
        }
      }
    }));
    const failure = workers.find((result) => result.status === "rejected");
    if (failure?.status === "rejected") throw failure.reason;
  }
  throw new Error("Event cancellation refund queue needs another attempt.");
}

export const onCancelledEventOfferPayments = onDocumentUpdated({
  document: "events/{eventId}", retry: true, timeoutSeconds: 540,
  maxInstances: 2,
}, async (event) => {
  if (event.data?.before.get("status") === "cancelled" ||
      event.data?.after.get("status") !== "cancelled") return;
  await queueCancelledEventOfferRefunds({db: admin.firestore(),
    eventId: event.params.eventId});
});
