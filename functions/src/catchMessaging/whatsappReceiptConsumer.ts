import type {Firestore} from "firebase-admin/firestore";
import {runAssistanceTransaction as transact} from
  "../eventSuccess/operations/transactionCallback";
import {catchEndpointHash, safeMillis} from "./whatsappReply";
import type {CatchReplyOperation} from "./whatsappReply";
import {CATCH_REPLY_OPERATIONS, readCatchOperation} from "./whatsappReplyStore";
import {CATCH_RECEIPTS, readCatchReceipt, isCatchStopReceipt,
  persistCatchStopReceipt} from "./whatsappEndpointStops";

export interface CatchReceiptScope {wabaId: string; phoneNumberId: string}
function inScope(scope: CatchReceiptScope,
  value: CatchReceiptScope): boolean {
  return /^[0-9]{1,32}$/u.test(scope.wabaId) &&
    /^[0-9]{1,32}$/u.test(scope.phoneNumberId) &&
    scope.wabaId === value.wabaId &&
    scope.phoneNumberId === value.phoneNumberId;
}

/** Receipt-created dispatcher; no provider I/O or send claims. */
export async function processCatchWhatsappReceipt(db: Firestore,
  eventId: string, scope: CatchReceiptScope, nowMillis: number):
  Promise<"applied" | "unchanged" | "unmatched" | "deferred"> {
  if (!/^cwhe_[a-f0-9]{64}$/u.test(eventId) || !safeMillis(nowMillis)) {
    throw new Error("Invalid Catch receipt identity");
  }
  const snapshot = await db.collection(CATCH_RECEIPTS).doc(eventId).get();
  if (!snapshot.exists) return "unmatched";
  const event = readCatchReceipt(snapshot.data());
  if (event.eventId !== eventId || !inScope(scope, event)) return "unmatched";
  if (isCatchStopReceipt(event)) {
    // Idempotent repair also supports explicitly replayed retained receipts.
    // This does not prove completeness of history lost to TTL.
    await persistCatchStopReceipt(db, event, nowMillis);
    return "applied";
  }
  if (event.eventKind !== "status") return "unchanged";
  const candidates = await db.collection(CATCH_REPLY_OPERATIONS)
    .where("wabaId", "==", event.wabaId)
    .where("phoneNumberId", "==", event.phoneNumberId)
    .where("endpointHash", "==", catchEndpointHash("+" + event.participantId))
    .where("providerMessageId", "==", event.messageId).limit(2).get();
  if (candidates.empty || candidates.docs.length === 0) return "deferred";
  if (candidates.docs.length !== 1) {
    throw new Error("Ambiguous Catch status correlation");
  }
  return consumeCatchReplyStatus(db, candidates.docs[0].id, eventId, nowMillis);
}

/**
 * Operation-completed companion for statuses arriving before result save.
 * Either the receipt-created reader sees the saved operation or this reader
 * sees the already committed receipt. Both revalidate immutable correlation.
 * No mutable processed flag, receipt TTL extension, or unbounded query.
 */
export async function reconcileCatchReplyStatuses(db: Firestore,
  operationId: string, scope: CatchReceiptScope, nowMillis: number):
  Promise<number> {
  if (!/^cwreply_[a-f0-9]{64}$/u.test(operationId) || !safeMillis(nowMillis)) {
    throw new Error("Invalid Catch operation identity");
  }
  const snapshot = await db.collection(CATCH_REPLY_OPERATIONS)
    .doc(operationId).get();
  if (!snapshot.exists) return 0;
  const operation = readCatchOperation(snapshot.data());
  if (operation.operationId !== operationId || !inScope(scope, operation) ||
      operation.state !== "completed" || !operation.providerMessageId) return 0;
  const receipts = await db.collection(CATCH_RECEIPTS)
    .where("wabaId", "==", operation.wabaId)
    .where("phoneNumberId", "==", operation.phoneNumberId)
    .where("eventKind", "==", "status")
    .where("messageId", "==", operation.providerMessageId).limit(51).get();
  if (receipts.docs.length > 50) {
    throw new Error("Catch status reconciliation exceeds bounded scope");
  }
  let applied = 0;
  for (const receipt of receipts.docs) {
    if (await consumeCatchReplyStatus(db, operationId, receipt.id,
      nowMillis) ===
        "applied") applied++;
  }
  return applied;
}

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
