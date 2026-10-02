import type {Firestore} from "firebase-admin/firestore";
import {runAssistanceTransaction as transact} from
  "../eventSuccess/operations/transactionCallback";
import {catchEndpointHash, safeMillis} from "./whatsappReply";
import type {CatchReplyOperation} from "./whatsappReply";
import {CATCH_RECEIPTS, CATCH_REPLY_OPERATIONS, readCatchOperation,
  readCatchReceipt} from "./whatsappReplyStore";

/**
 * Bounded trusted-worker boundary. Reads the immutable receipt itself, never
 * a caller-supplied status. The future worker must supply/retry an exact
 * operation ID; no discovery index or deployed trigger is added in this slice.
 * Early receipts stay untouched and return deferred until message ID is saved.
 */
export async function consumeCatchReplyStatus(db: Firestore,
  operationId: string, eventId: string, nowMillis: number):
  Promise<"applied" | "unchanged" | "unmatched" | "deferred"> {
  if (!/^cwreply_[a-f0-9]{64}$/u.test(operationId) ||
      !/^cwhe_[a-f0-9]{64}$/u.test(eventId) || !safeMillis(nowMillis)) {
    throw new Error("Invalid Catch status identity");
  }
  return transact(db, async (tx) => {
    const ref = db.collection(CATCH_REPLY_OPERATIONS).doc(operationId);
    const [operationSnap, eventSnap] = await Promise.all([
      tx.get(ref), tx.get(db.collection(CATCH_RECEIPTS).doc(eventId)),
    ]);
    if (!operationSnap.exists || !eventSnap.exists) return "unmatched";
    const operation = readCatchOperation(operationSnap.data());
    const event = readCatchReceipt(eventSnap.data());
    const at = Number(event.providerTimestampSeconds) * 1000;
    if (operation.operationId !== operationId || event.eventId !== eventId ||
        event.eventKind !== "status" ||
        (event.deliveryStatus !== "failed" && event.errorCodes.length > 0) ||
        event.wabaId !== operation.wabaId ||
        event.phoneNumberId !== operation.phoneNumberId ||
        catchEndpointHash("+" + event.participantId) !==
          operation.endpointHash ||
        !safeMillis(at) || at > event.receivedAtMillis ||
        // Meta has second precision; allow the attempt's containing second.
        at < Math.floor(operation.createdAtMillis / 1000) * 1000 ||
        event.receivedAtMillis > nowMillis || event.expiresAt.toMillis() <=
          nowMillis) return "unmatched";
    if (operation.providerMessageId === null) return "deferred";
    if (operation.providerMessageId !== event.messageId) return "unmatched";
    const nextStatus = advanceCatchDelivery(operation.deliveryStatus,
      event.deliveryStatus!);
    if (nextStatus === operation.deliveryStatus) return "unchanged";
    const next = readCatchOperation({...operation, deliveryStatus: nextStatus,
      deliveryEventId: eventId, deliveryAtMillis: at,
      updatedAtMillis: Math.max(nowMillis, operation.updatedAtMillis)});
    tx.update(ref, {deliveryStatus: next.deliveryStatus,
      deliveryEventId: next.deliveryEventId,
      deliveryAtMillis: next.deliveryAtMillis,
      updatedAtMillis: next.updatedAtMillis});
    return "applied";
  });
}

/**
 * Positive delivery/read proof dominates failure; otherwise failure dominates
 * sent/accepted. All contradictory observations remain immutable receipts.
 * Status never releases claims or grants retry, consent or billing authority.
 */
export function advanceCatchDelivery(current: CatchReplyOperation[
  "deliveryStatus"], proposed: "sent" | "delivered" | "read" | "failed"):
  CatchReplyOperation["deliveryStatus"] {
  const rank = {pending: 0, accepted: 1, sent: 2, failed: 3,
    delivered: 4, read: 5};
  return rank[proposed] > rank[current] ? proposed : current;
}
