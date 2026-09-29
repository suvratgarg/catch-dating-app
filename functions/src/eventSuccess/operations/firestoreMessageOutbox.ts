import type {Firestore, Transaction} from "firebase-admin/firestore";
import type {VerifiedDeliveryReceipt} from "./deliveryReceipts";
import {
  MessageRecord, OutboxFacts, PermitResult, LiveAttempt,
  LiveDispatchPermit,
} from "./messageOutbox";
import type {DeliveryDecision} from "./messagingPolicy";
import {FirestoreDeliveryOutbox} from
  "../../delivery/firestoreDeliveryOutbox";
import {eventAssistanceDeliveryAdapter} from "./eventAssistanceDelivery";

export const EVENT_ASSISTANCE_MESSAGES =
  eventAssistanceDeliveryAdapter.collection;

/**
 * Trusted source reader: read domain/permission documents through this same
 * transaction. It must have no writes, provider I/O or user-supplied authority.
 */
export type ReadOutboxFacts = (
  transaction: Transaction, intent: MessageRecord["intent"], now: number
) => Promise<OutboxFacts>;

/** Trusted transaction preparation; commit stages writes without more reads. */
export type PrepareDispatchResource<T> = (
  tx: Transaction, record: MessageRecord, attempt: LiveAttempt, now: number
) => Promise<{kind: "ready"; value: T; validUntil: number;
  commit: () => void} | {kind: "withheld"}>;

/**
 * Private delivery persistence used by the Operations worker. CAS on one
 * bounded record owns reservation/dispatch contention; no provider runs in a
 * transaction. A completed workflow cannot prevent a delayed delivery receipt
 * from being reconciled here.
 *
 * The lifecycle lives in `FirestoreDeliveryOutbox` — the shared delivery
 * core — behind `eventAssistanceDeliveryAdapter`, which keeps EA's generated
 * contracts, identity, and revision semantics. Behavior is unchanged.
 */
export class FirestoreMessageOutbox {
  private readonly core: FirestoreDeliveryOutbox<
    MessageRecord["intent"]["context"],
    LiveAttempt["binding"],
    MessageRecord["intent"], MessageRecord["attempts"][number], MessageRecord>;

  constructor(
    db: Firestore,
    readFacts: ReadOutboxFacts,
    clock: () => number = Date.now
  ) {
    this.core = new FirestoreDeliveryOutbox(db, eventAssistanceDeliveryAdapter,
      readFacts, clock);
  }

  enqueue(value: unknown): Promise<MessageRecord> {
    return this.core.enqueue(value);
  }

  get(messageId: string): Promise<MessageRecord | null> {
    return this.core.get(messageId);
  }

  async reserve(messageId: string): Promise<{
    record: MessageRecord; decision: DeliveryDecision;
  }> {
    const result = await this.core.reserve(messageId);
    return {record: result.record,
      decision: result.decision as DeliveryDecision};
  }

  claimLiveDispatch<T = undefined>(
    messageId: string, attemptId: string,
    prepareResource?: PrepareDispatchResource<T>
  ): Promise<PermitResult<T>> {
    return this.core.claimLiveDispatch<T>(messageId, attemptId,
      prepareResource) as Promise<PermitResult<T>>;
  }

  /** Only for a worker that proves permit expiry prevented all provider I/O. */
  recordExpiredBeforeSend(permit: LiveDispatchPermit):
    Promise<MessageRecord> {
    return this.core.recordExpiredBeforeSend(permit);
  }

  /** Authenticated/correlated normalized evidence; never a raw HTTP body. */
  recordReceipt(messageId: string, receipt: VerifiedDeliveryReceipt) {
    return this.core.recordReceipt(messageId, receipt);
  }

  close(
    messageId: string, expectedRevision: number,
    lifecycle: "cancelled" | "superseded"
  ): Promise<MessageRecord> {
    return this.core.close(messageId, expectedRevision, lifecycle);
  }
}
