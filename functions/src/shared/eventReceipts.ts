import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";

/** Firestore gRPC status code for a create() that hit an existing document. */
const ALREADY_EXISTS = 6;

/** Handlers that guard non-idempotent side effects with a receipt. */
export type EventReceiptHandler =
  | "onMessageCreated"
  | "onMatchCreated"
  | "moderatePhotoOnUpload";

/**
 * Runs [sideEffect] at most once per [receiptId] across at-least-once trigger
 * and webhook redeliveries.
 *
 * Firestore/Storage triggers and payment webhooks can fire more than once for
 * the same event. Non-idempotent side effects — push notifications, auto-id
 * flag writes, counter increments — would otherwise be re-applied on every
 * redelivery. This claims a `functionEventReceipts/{receiptId}` marker with an
 * atomic create() (which fails ALREADY_EXISTS when a prior delivery, or a
 * concurrent one, already claimed it) and only invokes [sideEffect] for the
 * delivery that wins the claim.
 *
 * The receipt is written before [sideEffect] runs, mirroring the existing
 * onMessageCreated pattern: a best-effort side effect (e.g. a push) is not
 * retried if it later fails, which is the desired behavior for notifications.
 *
 * @param {FirebaseFirestore.Firestore} db Firestore instance.
 * @param {object} options Receipt identity and optional metadata.
 * @param {() => Promise<void>} sideEffect Non-idempotent work to run at most
 *   once.
 * @return {Promise<boolean>} true when this delivery claimed the receipt and
 *   ran [sideEffect]; false when a prior delivery already did.
 */
export async function withEventReceipt(
  db: FirebaseFirestore.Firestore,
  options: {
    receiptId: string;
    handler: EventReceiptHandler;
    eventId?: string;
    matchId?: string;
    messageId?: string;
  },
  sideEffect: () => Promise<void>
): Promise<boolean> {
  const receiptRef = db
    .collection("functionEventReceipts")
    .doc(options.receiptId);

  try {
    await receiptRef.create({
      handler: options.handler,
      ...(options.eventId !== undefined && {eventId: options.eventId}),
      ...(options.matchId !== undefined && {matchId: options.matchId}),
      ...(options.messageId !== undefined && {messageId: options.messageId}),
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  } catch (error) {
    if ((error as {code?: number} | null)?.code === ALREADY_EXISTS) {
      logger.debug("Skipping already-processed event", {
        handler: options.handler,
        receiptId: options.receiptId,
      });
      return false;
    }
    throw error;
  }

  await sideEffect();
  return true;
}
