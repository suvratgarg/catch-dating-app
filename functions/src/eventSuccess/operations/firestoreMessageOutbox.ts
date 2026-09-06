import type {
  DocumentReference, Firestore, Transaction,
} from "firebase-admin/firestore";
import {operationContentHash} from "../../operations/durableActions";
import {
  parseMessageIntent, prepareDeliveryAttempt,
} from "./messageProtocol";
import {mergeDeliveryReceipt, VerifiedDeliveryReceipt} from
  "./deliveryReceipts";
import {
  assistanceMessageId, canClaimLiveAttempt, evaluateOutbox,
  MessageRecord, newMessageRecord, OutboxFacts, parseMessageRecord,
  PermitResult, LiveAttempt, LiveDispatchPermit,
} from "./messageOutbox";
import type {DeliveryDecision} from "./messagingPolicy";

export const EVENT_ASSISTANCE_MESSAGES = "eventAssistanceMessages";

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
 */
export class FirestoreMessageOutbox {
  constructor(
    private readonly db: Firestore,
    private readonly readFacts: ReadOutboxFacts,
    private readonly clock: () => number = Date.now
  ) {}

  async enqueue(value: unknown): Promise<MessageRecord> {
    const intent = structuredClone(parseMessageIntent(value));
    const reference = this.reference(assistanceMessageId(intent));
    return this.db.runTransaction(async (transaction) => {
      const snapshot = await transaction.get(reference);
      if (snapshot.exists) {
        const existing = parseMessageRecord(snapshot.data());
        if (operationContentHash(existing.intent) !==
            operationContentHash(intent)) {
          throw new Error("Message intent identity already has other content");
        }
        return existing;
      }
      const now = this.now(intent.createdAt);
      if (now >= intent.expiresAt) throw new Error("Message intent expired");
      const record = newMessageRecord(intent, now);
      transaction.create(reference, record);
      return record;
    });
  }

  async get(messageId: string): Promise<MessageRecord | null> {
    const snapshot = await this.reference(messageId).get();
    if (!snapshot.exists) return null;
    const record = parseMessageRecord(snapshot.data());
    if (record.messageId !== messageId) throw new Error("Message id mismatch");
    return record;
  }

  async reserve(messageId: string): Promise<{
    record: MessageRecord; decision: DeliveryDecision;
  }> {
    return this.db.runTransaction(async (transaction) => {
      const record = await this.read(transaction, messageId);
      const facts = await this.readFacts(transaction, record.intent,
        this.now(record.updatedAt));
      // Re-sample after fact reads: a slow/retried transaction cannot extend
      // the validity of an earlier permission snapshot.
      const now = this.now(record.updatedAt);
      const decision = evaluateOutbox(record, facts, now);
      if (decision.kind !== "dispatch") return {record, decision};
      const attempt = prepareDeliveryAttempt({...facts, intent: record.intent,
        lifecycle: record.lifecycle, attempts: record.attempts, now});
      if (!attempt) throw new Error("Message reservation decision drift");
      return {record: this.write(transaction, record,
        {...record, attempts: [...record.attempts, attempt]}, now), decision};
    });
  }

  async claimLiveDispatch<T = undefined>(
    messageId: string, attemptId: string,
    prepareResource?: PrepareDispatchResource<T>
  ): Promise<PermitResult<T>> {
    return this.db.runTransaction(async (transaction) => {
      const record = await this.read(transaction, messageId);
      const facts = await this.readFacts(transaction, record.intent,
        this.now(record.updatedAt));
      const now = this.now(record.updatedAt);
      const result = canClaimLiveAttempt(record, attemptId, facts, now);
      if (result.kind === "withheld") return {...result, record};
      const resource = prepareResource ? await prepareResource(transaction,
        record, result.attempt, now) : null;
      if (resource?.kind === "withheld") {
        return {kind: "withheld", record, reason: "resourceUnavailable"};
      }
      const committedAt = this.now(now);
      const validUntil = Math.min(result.validUntil,
        resource?.validUntil ?? result.validUntil);
      if (!Number.isSafeInteger(validUntil) || committedAt >= validUntil) {
        return {kind: "withheld", record, reason: "authorizationExpired"};
      }
      // Debit and payload evidence commit with the single-send claim.
      resource?.commit();
      const attempt = {...result.attempt, state: {
        kind: "unknown" as const, at: committedAt, providerMessageId: null,
        reason: "workerInterrupted" as const,
        reconcileAfter: committedAt + 120_000,
      }};
      const next = this.write(transaction, record, {...record,
        attempts: record.attempts.map((a) =>
          a.attemptId === attemptId ? attempt : a)}, committedAt);
      return {kind: "claimed", record: next,
        resource: resource?.value as T, permit: {
          messageId, intent: record.intent, attempt,
          validUntil,
        }};
    });
  }

  /** Only for a worker that proves permit expiry prevented all provider I/O. */
  async recordExpiredBeforeSend(permit: LiveDispatchPermit):
    Promise<MessageRecord> {
    return this.db.runTransaction(async (tx) => {
      const record = await this.read(tx, permit.messageId);
      const attempt = record.attempts.find((a) =>
        a.attemptId === permit.attempt.attemptId);
      const now = this.now(record.updatedAt);
      if (now < permit.validUntil ||
          operationContentHash(record.intent) !==
            operationContentHash(permit.intent) ||
          !attempt || attempt.mode !== "live") {
        throw new Error("Unsent evidence is outside the expired permit");
      }
      if (operationContentHash(attempt) !==
          operationContentHash(permit.attempt) ||
          attempt.state.kind !== "unknown" ||
          attempt.state.reason !== "workerInterrupted") return record;
      return this.write(tx, record, {...record,
        attempts: record.attempts.map((a) => a.attemptId !== attempt.attemptId ?
          a : {...a, state: {kind: "notDispatched", at: now,
            reason: "expired"}}),
      }, now);
    });
  }

  /** Authenticated/correlated normalized evidence; never a raw HTTP body. */
  async recordReceipt(
    messageId: string, receipt: VerifiedDeliveryReceipt
  ) {
    return this.db.runTransaction(async (transaction) => {
      const record = await this.read(transaction, messageId);
      const now = this.now(record.updatedAt);
      if (receipt.receivedAt > now) throw new Error("Future provider receipt");
      const attempt = record.attempts.find((a) =>
        a.attemptId === receipt.attemptId);
      if (!attempt || attempt.mode !== "live") {
        throw new Error("Receipt has no live message attempt");
      }
      const merged = mergeDeliveryReceipt(attempt, receipt);
      const conflict = record.deliveryConflict ||
        merged.disposition === "conflictingEvidence";
      if (operationContentHash(merged.attempt) ===
          operationContentHash(attempt) &&
          conflict === record.deliveryConflict) {
        return {record, disposition: merged.disposition};
      }
      return {record: this.write(transaction, record, {...record,
        deliveryConflict: conflict, attempts: record.attempts.map((a) =>
          a.attemptId === attempt.attemptId ? merged.attempt : a)}, now),
      disposition: merged.disposition};
    });
  }

  async close(
    messageId: string, expectedRevision: number,
    lifecycle: "cancelled" | "superseded"
  ): Promise<MessageRecord> {
    if (lifecycle !== "cancelled" && lifecycle !== "superseded") {
      throw new Error("Invalid message closure");
    }
    return this.db.runTransaction(async (transaction) => {
      const record = await this.read(transaction, messageId);
      if (record.lifecycle === lifecycle) return record;
      if (record.lifecycle !== "active" ||
          record.revision !== expectedRevision) {
        throw new Error("Message revision or lifecycle changed");
      }
      return this.write(transaction, record, {...record, lifecycle},
        this.now(record.updatedAt));
    });
  }

  private reference(messageId: string): DocumentReference {
    if (!/^outbox:[a-f0-9]{64}$/.test(messageId)) {
      throw new Error("Invalid outbox id");
    }
    return this.db.collection(EVENT_ASSISTANCE_MESSAGES).doc(messageId);
  }

  private async read(transaction: Transaction, messageId: string) {
    const snapshot = await transaction.get(this.reference(messageId));
    if (!snapshot.exists) throw new Error("Message not found");
    const record = parseMessageRecord(snapshot.data());
    if (record.messageId !== messageId) throw new Error("Message id mismatch");
    return record;
  }

  private write(
    transaction: Transaction, previous: MessageRecord,
    changed: MessageRecord, now: number
  ): MessageRecord {
    const next = parseMessageRecord({...changed,
      revision: previous.revision + 1, updatedAt: now});
    transaction.set(this.reference(previous.messageId), next);
    return next;
  }

  private now(previous: number): number {
    const now = this.clock();
    if (!Number.isSafeInteger(now) || now < previous) {
      throw new Error("Message worker clock is invalid or moved backwards");
    }
    return now;
  }
}
